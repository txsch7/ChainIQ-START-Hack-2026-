"""Edge-case tests using hand-crafted synthetic payloads — no dependency on requests.json."""
import re

ISO_8601_RE = re.compile(r"\d{4}-\d{2}-\d{2}T")

_MINIMAL_VALID = {
    "request_id": "REQ-EDGE-001",
    "created_at": "2026-01-01T00:00:00",
    "request_channel": "email",
    "request_language": "en",
    "business_unit": "IT",
    "country": "CH",
    "site": "Zurich",
    "requester_id": "USR-001",
    "requester_role": "buyer",
    "submitted_for_id": None,
    "category_l1": "IT",
    "category_l2": "Software Licenses",
    "title": "Edge case minimal",
    "request_text": "Need software licenses.",
    "currency": "EUR",
    "budget_amount": 50000,
    "quantity": 10,
    "unit_of_measure": "units",
    "required_by_date": "2026-06-01",
    "preferred_supplier_mentioned": None,
    "incumbent_supplier": None,
    "contract_type_requested": None,
    "delivery_countries": ["CH"],
    "data_residency_constraint": False,
    "esg_requirement": False,
    "status": "approved",
    "scenario_tags": [],
}


def _post(client, payload: dict):
    r = client.post("/pipeline/run", json=payload)
    return r


# ------------------------------------------------------------------ #
# Minimal valid payload
# ------------------------------------------------------------------ #

def test_minimal_valid_http_200(client):
    r = _post(client, _MINIMAL_VALID)
    assert r.status_code == 200, r.text


def test_minimal_valid_processed_at_iso(client):
    r = _post(client, _MINIMAL_VALID)
    assert r.status_code == 200
    body = r.json()
    assert ISO_8601_RE.search(body["processed_at"])


def test_minimal_valid_data_sources_in_audit(client):
    r = _post(client, _MINIMAL_VALID)
    assert r.status_code == 200
    body = r.json()
    sources = body["audit_trail"]["data_sources_used"]
    assert any("suppliers" in s.lower() for s in sources), f"suppliers.csv not in {sources}"
    assert any("pricing" in s.lower() for s in sources), f"pricing.csv not in {sources}"


# ------------------------------------------------------------------ #
# quantity=None → completeness=fail, ER-001
# ------------------------------------------------------------------ #

def test_null_quantity_completeness_fail(client):
    payload = {**_MINIMAL_VALID, "request_id": "REQ-EDGE-002", "quantity": None}
    r = _post(client, payload)
    assert r.status_code == 200, r.text
    body = r.json()
    assert body["validation"]["completeness"] == "fail"


def test_null_quantity_er001(client):
    payload = {**_MINIMAL_VALID, "request_id": "REQ-EDGE-002", "quantity": None}
    r = _post(client, payload)
    assert r.status_code == 200
    body = r.json()
    rules = {e["rule"] for e in body["escalations"]}
    assert "ER-001" in rules


# ------------------------------------------------------------------ #
# budget_amount=None → completeness=fail
# ------------------------------------------------------------------ #

def test_null_budget_completeness_fail(client):
    payload = {**_MINIMAL_VALID, "request_id": "REQ-EDGE-003", "budget_amount": None}
    r = _post(client, payload)
    assert r.status_code == 200, r.text
    body = r.json()
    assert body["validation"]["completeness"] == "fail"


# ------------------------------------------------------------------ #
# delivery_countries=[] → completeness=fail
# ------------------------------------------------------------------ #

def test_empty_delivery_countries_completeness_fail(client):
    payload = {**_MINIMAL_VALID, "request_id": "REQ-EDGE-004", "delivery_countries": []}
    r = _post(client, payload)
    assert r.status_code == 200, r.text
    body = r.json()
    assert body["validation"]["completeness"] == "fail"


# ------------------------------------------------------------------ #
# Missing request_id field → HTTP 422
# ------------------------------------------------------------------ #

def test_missing_request_id_422(client):
    payload = {k: v for k, v in _MINIMAL_VALID.items() if k != "request_id"}
    r = _post(client, payload)
    assert r.status_code == 422


# ------------------------------------------------------------------ #
# processed_at contains "T" (ISO 8601 datetime separator)
# ------------------------------------------------------------------ #

def test_processed_at_contains_T(client):
    r = _post(client, _MINIMAL_VALID)
    assert r.status_code == 200
    body = r.json()
    assert "T" in body["processed_at"], f"processed_at not ISO 8601: {body['processed_at']}"


# ------------------------------------------------------------------ #
# audit_trail.data_sources_used includes suppliers and pricing files
# ------------------------------------------------------------------ #

def test_audit_data_sources_suppliers_csv(client):
    r = _post(client, _MINIMAL_VALID)
    assert r.status_code == 200
    body = r.json()
    sources = body["audit_trail"]["data_sources_used"]
    assert any("suppliers" in s for s in sources), f"suppliers not in data_sources: {sources}"


def test_audit_data_sources_pricing_csv(client):
    r = _post(client, _MINIMAL_VALID)
    assert r.status_code == 200
    body = r.json()
    sources = body["audit_trail"]["data_sources_used"]
    assert any("pricing" in s for s in sources), f"pricing not in data_sources: {sources}"
