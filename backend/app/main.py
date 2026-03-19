"""FastAPI application — ChainIQ Backend (States 2–6)."""
import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware

from app.data.store import get_store
from app.models.extraction import ExtractedData
from app.pipeline.runner import run_pipeline

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(name)s — %(message)s",
)
logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
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

    return result
