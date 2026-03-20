import json
from pathlib import Path

import pytest
from fastapi.testclient import TestClient

from app.main import app

_DATA_ROOT = Path(__file__).parent.parent.parent / "data"


@pytest.fixture(scope="session")
def client():
    """Single TestClient for entire session — DataStore loaded once."""
    with TestClient(app) as c:
        yield c


@pytest.fixture(scope="session")
def all_requests() -> list[dict]:
    with open(_DATA_ROOT / "requests.json") as f:
        return json.load(f)


@pytest.fixture(scope="session")
def requests_by_id(all_requests) -> dict[str, dict]:
    return {r["request_id"]: r for r in all_requests}
