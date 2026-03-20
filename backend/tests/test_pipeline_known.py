"""Pinned assertions for specific request_ids — regression harness."""


def _post(client, payload: dict):
    r = client.post("/pipeline/run", json=payload)
    assert r.status_code == 200, r.text
    return r.json()


def _escalation_rules(body: dict) -> set[str]:
    return {e["rule"] for e in body.get("escalations", [])}


# ------------------------------------------------------------------ #
# REQ-000001 — standard (budget insufficient → cannot_proceed)
# ------------------------------------------------------------------ #

def test_req000001_completeness_pass(client, requests_by_id):
    body = _post(client, requests_by_id["REQ-000001"])
    assert body["validation"]["completeness"] == "pass"


def test_req000001_shortlist_non_empty(client, requests_by_id):
    """Shortlist is computed even when budget is insufficient."""
    body = _post(client, requests_by_id["REQ-000001"])
    shortlist = body["supplier_shortlist"]
    assert shortlist, "shortlist must not be empty for REQ-000001"


def test_req000001_shortlist_rank_starts_at_one(client, requests_by_id):
    body = _post(client, requests_by_id["REQ-000001"])
    shortlist = body["supplier_shortlist"]
    assert shortlist
    assert shortlist[0]["rank"] == 1


def test_req000001_status_is_valid(client, requests_by_id):
    """Regression: pin that REQ-000001 produces a valid status (budget shortage → cannot_proceed)."""
    body = _post(client, requests_by_id["REQ-000001"])
    assert body["recommendation"]["status"] in ("recommended", "cannot_proceed")


# ------------------------------------------------------------------ #
# REQ-000002 — missing_info
# ------------------------------------------------------------------ #

def test_req000002_completeness_fail(client, requests_by_id):
    body = _post(client, requests_by_id["REQ-000002"])
    assert body["validation"]["completeness"] == "fail"


def test_req000002_er001_present(client, requests_by_id):
    body = _post(client, requests_by_id["REQ-000002"])
    assert "ER-001" in _escalation_rules(body)


def test_req000002_er001_blocking(client, requests_by_id):
    body = _post(client, requests_by_id["REQ-000002"])
    er001 = [e for e in body["escalations"] if e["rule"] == "ER-001"]
    assert er001, "ER-001 escalation missing"
    assert er001[0]["blocking"] is True


def test_req000002_status_cannot_proceed(client, requests_by_id):
    body = _post(client, requests_by_id["REQ-000002"])
    assert body["recommendation"]["status"] == "cannot_proceed"


# ------------------------------------------------------------------ #
# REQ-000004 — contradictory
# ------------------------------------------------------------------ #

def test_req000004_completeness_pass(client, requests_by_id):
    body = _post(client, requests_by_id["REQ-000004"])
    assert body["validation"]["completeness"] == "pass"


def test_req000004_has_blocking_escalation(client, requests_by_id):
    body = _post(client, requests_by_id["REQ-000004"])
    blocking = [e for e in body["escalations"] if e["blocking"] is True]
    assert blocking, "contradictory request must have at least one blocking escalation"


def test_req000004_status_cannot_proceed(client, requests_by_id):
    body = _post(client, requests_by_id["REQ-000004"])
    assert body["recommendation"]["status"] == "cannot_proceed"


# ------------------------------------------------------------------ #
# REQ-000003 — threshold
# ------------------------------------------------------------------ #

def test_req000003_approval_threshold_rule_applied(client, requests_by_id):
    body = _post(client, requests_by_id["REQ-000003"])
    at = body["policy_evaluation"]["approval_threshold"]
    assert at.get("rule_applied"), f"rule_applied should be set, got: {at}"


def test_req000003_quotes_required_gte_2(client, requests_by_id):
    body = _post(client, requests_by_id["REQ-000003"])
    at = body["policy_evaluation"]["approval_threshold"]
    quotes = at.get("quotes_required", 0)
    assert quotes >= 2, f"Expected quotes_required >= 2, got {quotes}"


# ------------------------------------------------------------------ #
# REQ-000006 — restricted tag (high-value, fires ER-003)
# ------------------------------------------------------------------ #

def test_req000006_has_escalation(client, requests_by_id):
    """REQ-000006 fires at least one blocking escalation (ER-003 for high value)."""
    body = _post(client, requests_by_id["REQ-000006"])
    assert body["escalations"], "REQ-000006 should have escalations"


def test_req000006_status_cannot_proceed(client, requests_by_id):
    body = _post(client, requests_by_id["REQ-000006"])
    assert body["recommendation"]["status"] == "cannot_proceed"


def test_req000006_preferred_supplier_present(client, requests_by_id):
    """Preferred supplier field is always returned (even if not actually preferred)."""
    body = _post(client, requests_by_id["REQ-000006"])
    ps = body["policy_evaluation"].get("preferred_supplier")
    assert ps is not None, "preferred_supplier must be in policy_evaluation"
