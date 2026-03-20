"""FastAPI application — ChainIQ Backend (States 2–6)."""
import logging
import os
from contextlib import asynccontextmanager

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware

from app.data.store import get_store
from app.db.database import init_db
from app.db import repository
from app.models.extraction import ExtractedData
from app.pipeline.runner import run_pipeline
from app.routers.admin import router as admin_router

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(name)s — %(message)s",
)
logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    if os.environ.get("DATABASE_URL"):
        logger.info("Initialising database…")
        init_db()
        logger.info("Database ready")
    else:
        logger.warning("DATABASE_URL not set — persistence disabled")

    logger.info("Loading DataStore…")
    store = get_store()
    logger.info(
        "DataStore ready: %d supplier rows, %d pricing rows",
        len(store.suppliers),
        len(store.pricing),
    )
    yield
    logger.info("Shutdown")


app = FastAPI(
    title="ChainIQ Sourcing Backend",
    description="Deterministic Phase 2 pipeline: policy, compliance, scoring, output (States 2–6).",
    version="0.1.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(admin_router)

from app.routers.sap import router as sap_router
app.include_router(sap_router)


# ------------------------------------------------------------------ #
# Routes
# ------------------------------------------------------------------ #

@app.get("/health")
async def health():
    return {"status": "ok"}


@app.post("/pipeline/run")
async def pipeline_run(data: ExtractedData):
    """
    Run the full sourcing pipeline (States 2–6) for an extracted purchase request.

    Accepts the same schema as `example_request.json` — the payload produced by
    n8n after State 1 HITL extraction approval.

    Returns a structured sourcing response with validation, policy evaluation,
    supplier shortlist, escalations, recommendation, and audit trail.
    """
    if not data.request_id:
        raise HTTPException(status_code=422, detail="request_id is required")

    store = get_store()
    try:
        result = run_pipeline(data.request_id, data, store)
    except Exception as exc:
        logger.exception("Pipeline error for %s", data.request_id)
        raise HTTPException(status_code=500, detail=str(exc)) from exc

    if os.environ.get("DATABASE_URL"):
        has_blocking = any(e.get("blocking") for e in result.get("escalations", []))
        status = "escalated" if has_blocking else "completed"
        try:
            repository.upsert_request(data.request_id, status, data.model_dump(), result)
        except Exception:
            logger.exception("Failed to persist request %s", data.request_id)

    return result
