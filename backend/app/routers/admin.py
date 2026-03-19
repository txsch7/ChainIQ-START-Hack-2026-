"""Admin API for managing and resuming escalated requests."""
import logging

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

from app.data.store import get_store
from app.db import repository
from app.models.extraction import ExtractedData
from app.pipeline.runner import run_pipeline

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/admin", tags=["admin"])


class ResumeBody(BaseModel):
    extracted_data: dict
    start_from: str | None = None


class ResolveBody(BaseModel):
    resolved_by: str | None = None
    resolution_note: str | None = None


@router.get("/requests")
def list_requests(status: str | None = None, limit: int = 100, offset: int = 0):
    return repository.list_requests(status=status, limit=limit, offset=offset)


@router.get("/requests/{request_id}")
def get_request(request_id: str):
    record = repository.get_request(request_id)
    if not record:
        raise HTTPException(status_code=404, detail="Request not found")
    return record


@router.post("/requests/{request_id}/resume")
def resume_request(request_id: str, body: ResumeBody):
    record = repository.get_request(request_id)
    if not record:
        raise HTTPException(status_code=404, detail="Request not found")

    start_from = body.start_from or record.get("resume_from") or "state2"

    try:
        extracted = ExtractedData(**body.extracted_data)
    except Exception as exc:
        raise HTTPException(status_code=422, detail=str(exc)) from exc

    repository.update_request_status(request_id, "processing")

    store = get_store()
    try:
        result = run_pipeline(request_id, extracted, store, start_from=start_from)
    except Exception as exc:
        logger.exception("Resume pipeline error for %s", request_id)
        repository.update_request_status(request_id, "escalated")
        raise HTTPException(status_code=500, detail=str(exc)) from exc

    has_blocking = any(e.get("blocking") for e in result.get("escalations", []))
    new_status = "escalated" if has_blocking else "completed"
    repository.update_request_status(request_id, new_status, response=result)

    return result


@router.patch("/requests/{request_id}/resolve")
def resolve_request(request_id: str, body: ResolveBody):
    record = repository.get_request(request_id)
    if not record:
        raise HTTPException(status_code=404, detail="Request not found")

    repository.update_request_status(
        request_id,
        "resolved",
        resolved_by=body.resolved_by,
        resolution_note=body.resolution_note,
    )
    return {"request_id": request_id, "status": "resolved"}
