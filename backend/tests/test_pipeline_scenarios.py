"""Parametrized scenario tests — driven by scenario_tags in requests.json."""
import json
from pathlib import Path

import pytest

_ALL: list[dict] = json.loads(
    (Path(__file__).parent.parent.parent / "data" / "requests.json").read_text()
)


def _tag(tag: str) -> list[dict]:
    return [r for r in _ALL if tag in r.get("scenario_tags", [])]


def _ids(rs: list[dict]) -> list[str]:
    return [r["request_id"] for r in rs]


def _post(client, payload: dict):
    r = client.post("/pipeline/run", json=payload)
    assert r.status_code == 200, r.text
    return r.json()


def _escalation_rules(body: dict) -> set[str]:
    return {e["rule"] for e in body.get("escalations", [])}


# ------------------------------------------------------------------ #
# standard (141 requests)
# ------------------------------------------------------------------ #

@pytest.mark.parametrize("payload", _tag("standard"), ids=_ids(_tag("standard")))
def test_standard_completeness_pass(client, payload):
    body = _post(client, payload)
    assert body["validation"]["completeness"] == "pass"


@pytest.mark.parametrize("payload", _tag("standard"), ids=_ids(_tag("standard")))
def test_standard_status_recommended(client, payload):
    body = _post(client, payload)
    assert body["recommendation"]["status"] == "recommended"


@pytest.mark.parametrize("payload", _tag("standard"), ids=_ids(_tag("standard")))
def test_standard_shortlist_non_empty(client, payload):
    body = _post(client, payload)
    assert body["supplier_shortlist"], "standard requests should have a non-empty shortlist"


# ------------------------------------------------------------------ #
# missing_info (28 requests)
# ------------------------------------------------------------------ #

@pytest.mark.parametrize("payload", _tag("missing_info"), ids=_ids(_tag("missing_info")))
def test_missing_info_completeness_fail(client, payload):
    body = _post(client, payload)
    assert body["validation"]["completeness"] == "fail"


@pytest.mark.parametrize("payload", _tag("missing_info"), ids=_ids(_tag("missing_info")))
def test_missing_info_er001_present(client, payload):
    body = _post(client, payload)
    assert "ER-001" in _escalation_rules(body)


@pytest.mark.parametrize("payload", _tag("missing_info"), ids=_ids(_tag("missing_info")))
def test_missing_info_er001_blocking(client, payload):
    body = _post(client, payload)
    er001 = [e for e in body["escalations"] if e["rule"] == "ER-001"]
    assert er001 and er001[0]["blocking"] is True


@pytest.mark.parametrize("payload", _tag("missing_info"), ids=_ids(_tag("missing_info")))
def test_missing_info_status_cannot_proceed(client, payload):
    body = _post(client, payload)
    assert body["recommendation"]["status"] == "cannot_proceed"


# ------------------------------------------------------------------ #
# threshold (29 requests)
# ------------------------------------------------------------------ #

@pytest.mark.parametrize("payload", _tag("threshold"), ids=_ids(_tag("threshold")))
def test_threshold_completeness_pass(client, payload):
    body = _post(client, payload)
    assert body["validation"]["completeness"] == "pass"


@pytest.mark.parametrize("payload", _tag("threshold"), ids=_ids(_tag("threshold")))
def test_threshold_rule_applied(client, payload):
    body = _post(client, payload)
    at = body["policy_evaluation"]["approval_threshold"]
    assert at.get("rule_applied"), f"rule_applied missing for {payload['request_id']}: {at}"


@pytest.mark.parametrize("payload", _tag("threshold"), ids=_ids(_tag("threshold")))
def test_threshold_quotes_required(client, payload):
    body = _post(client, payload)
    at = body["policy_evaluation"]["approval_threshold"]
    quotes = at.get("quotes_required", 0)
    assert quotes >= 1, f"quotes_required should be >= 1, got {quotes}"


# ------------------------------------------------------------------ #
# lead_time (29 requests)
# ------------------------------------------------------------------ #

@pytest.mark.parametrize("payload", _tag("lead_time"), ids=_ids(_tag("lead_time")))
def test_lead_time_http_200(client, payload):
    r = client.post("/pipeline/run", json=payload)
    assert r.status_code == 200


@pytest.mark.parametrize("payload", _tag("lead_time"), ids=_ids(_tag("lead_time")))
def test_lead_time_er004_or_cannot_proceed(client, payload):
    body = _post(client, payload)
    rules = _escalation_rules(body)
    status = body["recommendation"]["status"]
    # ER-004 fires on tight lead time OR status is cannot_proceed from other blocking rules
    assert "ER-004" in rules or status == "cannot_proceed", (
        f"{payload['request_id']}: expected ER-004 or cannot_proceed, got rules={rules}, status={status}"
    )


# ------------------------------------------------------------------ #
# restricted (18 requests)
# ------------------------------------------------------------------ #

@pytest.mark.parametrize("payload", _tag("restricted"), ids=_ids(_tag("restricted")))
def test_restricted_er002_present(client, payload):
    body = _post(client, payload)
    assert "ER-002" in _escalation_rules(body), (
        f"{payload['request_id']}: ER-002 not in escalations {_escalation_rules(body)}"
    )


@pytest.mark.parametrize("payload", _tag("restricted"), ids=_ids(_tag("restricted")))
def test_restricted_er002_blocking(client, payload):
    body = _post(client, payload)
    er002 = [e for e in body["escalations"] if e["rule"] == "ER-002"]
    assert er002 and er002[0]["blocking"] is True


@pytest.mark.parametrize("payload", _tag("restricted"), ids=_ids(_tag("restricted")))
def test_restricted_preferred_supplier_shows_restriction(client, payload):
    body = _post(client, payload)
    ps = body["policy_evaluation"].get("preferred_supplier", {})
    status = ps.get("status", "")
    is_restricted = ps.get("is_restricted", False)
    assert "restricted" in status.lower() or is_restricted, (
        f"{payload['request_id']}: preferred_supplier should indicate restriction, got {ps}"
    )


# ------------------------------------------------------------------ #
# contradictory (21 requests)
# ------------------------------------------------------------------ #

@pytest.mark.parametrize("payload", _tag("contradictory"), ids=_ids(_tag("contradictory")))
def test_contradictory_status_cannot_proceed(client, payload):
    body = _post(client, payload)
    assert body["recommendation"]["status"] == "cannot_proceed"


@pytest.mark.parametrize("payload", _tag("contradictory"), ids=_ids(_tag("contradictory")))
def test_contradictory_has_blocking_escalation(client, payload):
    body = _post(client, payload)
    blocking = [e for e in body["escalations"] if e["blocking"] is True]
    assert blocking, f"{payload['request_id']}: no blocking escalation found"


# ------------------------------------------------------------------ #
# capacity (18 requests) — soft assertion
# ------------------------------------------------------------------ #

@pytest.mark.parametrize("payload", _tag("capacity"), ids=_ids(_tag("capacity")))
def test_capacity_http_200(client, payload):
    r = client.post("/pipeline/run", json=payload)
    assert r.status_code == 200


# ------------------------------------------------------------------ #
# multilingual (18 requests)
# ------------------------------------------------------------------ #

@pytest.mark.parametrize("payload", _tag("multilingual"), ids=_ids(_tag("multilingual")))
def test_multilingual_http_200(client, payload):
    r = client.post("/pipeline/run", json=payload)
    assert r.status_code == 200


@pytest.mark.parametrize("payload", _tag("multilingual"), ids=_ids(_tag("multilingual")))
def test_multilingual_valid_status(client, payload):
    body = _post(client, payload)
    assert body["recommendation"]["status"] in ("recommended", "cannot_proceed")


@pytest.mark.parametrize("payload", _tag("multilingual"), ids=_ids(_tag("multilingual")))
def test_multilingual_request_id_echoed(client, payload):
    body = _post(client, payload)
    assert body["request_id"] == payload["request_id"]


# ------------------------------------------------------------------ #
# multi_country (3 requests)
# ------------------------------------------------------------------ #

@pytest.mark.parametrize("payload", _tag("multi_country"), ids=_ids(_tag("multi_country")))
def test_multi_country_http_200(client, payload):
    r = client.post("/pipeline/run", json=payload)
    assert r.status_code == 200


@pytest.mark.parametrize("payload", _tag("multi_country"), ids=_ids(_tag("multi_country")))
def test_multi_country_delivery_countries_present(client, payload):
    body = _post(client, payload)
    countries = body["request_interpretation"].get("delivery_countries")
    assert countries is not None, "delivery_countries must be in request_interpretation"
