"""Response shape contract — asserts structural guarantees for any valid request."""
import re


REQUIRED_TOP_LEVEL_KEYS = {
    "request_id",
    "processed_at",
    "request_interpretation",
    "validation",
    "policy_evaluation",
    "supplier_shortlist",
    "suppliers_excluded",
    "escalations",
    "recommendation",
    "audit_trail",
}

SHORTLIST_ENTRY_KEYS = {
    "rank",
    "supplier_id",
    "supplier_name",
    "composite_score",
    "unit_price_eur",
    "total_price_eur",
    "quality_score",
    "risk_score",
    "esg_score",
}

ESCALATION_ENTRY_KEYS = {
    "escalation_id",
    "rule",
    "trigger",
    "escalate_to",
    "blocking",
}

AUDIT_TRAIL_KEYS = {
    "policies_checked",
    "supplier_ids_evaluated",
    "data_sources_used",
}

ISO_8601_RE = re.compile(r"\d{4}-\d{2}-\d{2}T")


def _post(client, payload: dict):
    r = client.post("/pipeline/run", json=payload)
    assert r.status_code == 200, r.text
    return r.json()


def test_top_level_keys(client, requests_by_id):
    payload = requests_by_id["REQ-000001"]
    body = _post(client, payload)
    assert REQUIRED_TOP_LEVEL_KEYS <= set(body.keys())


def test_request_id_echoed(client, requests_by_id):
    payload = requests_by_id["REQ-000001"]
    body = _post(client, payload)
    assert body["request_id"] == payload["request_id"]


def test_processed_at_is_iso(client, requests_by_id):
    payload = requests_by_id["REQ-000001"]
    body = _post(client, payload)
    assert isinstance(body["processed_at"], str)
    assert ISO_8601_RE.match(body["processed_at"]), f"Not ISO 8601: {body['processed_at']}"


def test_validation_completeness_enum(client, requests_by_id):
    payload = requests_by_id["REQ-000001"]
    body = _post(client, payload)
    assert body["validation"]["completeness"] in ("pass", "fail")


def test_validation_issues_is_list(client, requests_by_id):
    payload = requests_by_id["REQ-000001"]
    body = _post(client, payload)
    assert isinstance(body["validation"]["issues_detected"], list)


def test_shortlist_is_list(client, requests_by_id):
    payload = requests_by_id["REQ-000001"]
    body = _post(client, payload)
    assert isinstance(body["supplier_shortlist"], list)


def test_shortlist_entry_keys(client, requests_by_id):
    payload = requests_by_id["REQ-000001"]
    body = _post(client, payload)
    shortlist = body["supplier_shortlist"]
    assert shortlist, "Expected a non-empty shortlist for REQ-000001"
    for entry in shortlist:
        assert SHORTLIST_ENTRY_KEYS <= set(entry.keys()), f"Missing keys in: {entry}"


def test_shortlist_ranks_start_at_one(client, requests_by_id):
    payload = requests_by_id["REQ-000001"]
    body = _post(client, payload)
    shortlist = body["supplier_shortlist"]
    if shortlist:
        ranks = [e["rank"] for e in shortlist]
        assert ranks[0] == 1


def test_escalations_is_list(client, requests_by_id):
    payload = requests_by_id["REQ-000001"]
    body = _post(client, payload)
    assert isinstance(body["escalations"], list)


def test_escalation_entry_keys(client, requests_by_id):
    # Use a request that produces escalations
    payload = requests_by_id["REQ-000002"]
    body = _post(client, payload)
    for entry in body["escalations"]:
        assert ESCALATION_ENTRY_KEYS <= set(entry.keys()), f"Missing keys in: {entry}"
        assert isinstance(entry["blocking"], bool)


def test_recommendation_status_enum(client, requests_by_id):
    payload = requests_by_id["REQ-000001"]
    body = _post(client, payload)
    assert body["recommendation"]["status"] in ("recommended", "cannot_proceed")


def test_audit_trail_keys(client, requests_by_id):
    payload = requests_by_id["REQ-000001"]
    body = _post(client, payload)
    assert AUDIT_TRAIL_KEYS <= set(body["audit_trail"].keys())


def test_audit_trail_lists(client, requests_by_id):
    payload = requests_by_id["REQ-000001"]
    body = _post(client, payload)
    at = body["audit_trail"]
    assert isinstance(at["policies_checked"], list)
    assert isinstance(at["supplier_ids_evaluated"], list)
    assert isinstance(at["data_sources_used"], list)
