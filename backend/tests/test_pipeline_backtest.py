"""Backtesting: system recommendations vs. historical award decisions.

Each parametrized case represents one procurement request where a historical
winner was recorded (awarded=True). We run the pipeline and compare the
outcome against what actually happened.

Assertions are deliberately graduated:
  - HARD  → must always pass (supplier in shortlist, escalation alignment)
  - SOFT  → xfail(strict=False): we measure alignment without blocking CI
"""
import csv
import json
from collections import defaultdict
from pathlib import Path

import pytest

_DATA = Path(__file__).parent.parent / "data"


# ---------------------------------------------------------------------------
# Data loading
# ---------------------------------------------------------------------------

def _load_awards() -> dict[str, list[dict]]:
    by_req: dict[str, list[dict]] = defaultdict(list)
    with open(_DATA / "historical_awards.csv", newline="", encoding="utf-8") as f:
        for row in csv.DictReader(f):
            by_req[row["request_id"]].append(row)
    return dict(by_req)


_ALL_REQUESTS: dict[str, dict] = {
    r["request_id"]: r
    for r in json.loads((_DATA / "requests.json").read_text(encoding="utf-8"))
}

_AWARDS_BY_REQUEST: dict[str, list[dict]] = _load_awards()


def _historical_winner(award_list: list[dict]) -> dict | None:
    return next((a for a in award_list if a["awarded"].strip() == "True"), None)


def _historical_ranked(award_list: list[dict]) -> list[dict]:
    return sorted(award_list, key=lambda a: int(a["award_rank"]))


# Build backtest cases: only requests that exist in both datasets
_BACKTEST: list[tuple[str, dict, list[dict]]] = []
for _req_id, _award_list in sorted(_AWARDS_BY_REQUEST.items()):
    if _req_id not in _ALL_REQUESTS:
        continue
    _winner = _historical_winner(_award_list)
    if _winner is None:
        continue
    _BACKTEST.append((_req_id, _winner, _historical_ranked(_award_list)))

_IDS = [t[0] for t in _BACKTEST]


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _post(client, req_id: str) -> dict:
    r = client.post("/pipeline/run", json=_ALL_REQUESTS[req_id])
    assert r.status_code == 200, r.text
    return r.json()


def _shortlist_ids(body: dict) -> list[str]:
    return [e["supplier_id"] for e in body["supplier_shortlist"]]


def _shortlist_rank(body: dict, supplier_id: str) -> int | None:
    """Return system rank for a supplier, or None if not in shortlist."""
    for entry in body["supplier_shortlist"]:
        if entry["supplier_id"] == supplier_id:
            return entry["rank"]
    return None


# ---------------------------------------------------------------------------
# HARD assertions
# ---------------------------------------------------------------------------

@pytest.mark.parametrize("req_id,winner,ranked", _BACKTEST, ids=_IDS)
def test_awarded_supplier_in_shortlist(client, req_id, winner, ranked):
    """The historically awarded supplier must appear somewhere in the system shortlist.

    Skipped when the pipeline produces an empty shortlist (separate coverage-gap signal).
    """
    body = _post(client, req_id)
    shortlist = body["supplier_shortlist"]
    if not shortlist:
        pytest.skip("empty shortlist — pipeline has no supplier coverage for this request")
    shortlist_ids = _shortlist_ids(body)
    assert winner["supplier_id"] in shortlist_ids, (
        f"{req_id}: historical winner {winner['supplier_id']} ({winner['supplier_name']}) "
        f"not found in system shortlist {shortlist_ids}"
    )


@pytest.mark.parametrize("req_id,winner,ranked", _BACKTEST, ids=_IDS)
def test_escalation_required_alignment(client, req_id, winner, ranked):
    """If the historical decision required escalation, the system must fire at least one escalation."""
    if winner["escalation_required"].strip() != "True":
        pytest.skip("no escalation required historically")
    body = _post(client, req_id)
    assert body["escalations"], (
        f"{req_id}: historical record shows escalation_required=True "
        f"but system fired no escalations"
    )


@pytest.mark.parametrize("req_id,winner,ranked", _BACKTEST, ids=_IDS)
def test_shortlist_overlaps_historical_suppliers(client, req_id, winner, ranked):
    """When the pipeline produces a non-empty shortlist, at least one supplier
    should have been historically ranked for this request."""
    body = _post(client, req_id)
    shortlist = body["supplier_shortlist"]
    if not shortlist:
        pytest.skip("pipeline produced empty shortlist — coverage gap tested separately")
    shortlisted_ids = set(_shortlist_ids(body))
    historically_ranked = {a["supplier_id"] for a in ranked}
    overlap = shortlisted_ids & historically_ranked
    assert overlap, (
        f"{req_id}: system shortlist {shortlisted_ids} has no overlap with "
        f"historically ranked suppliers {historically_ranked}"
    )


@pytest.mark.parametrize("req_id,winner,ranked", _BACKTEST, ids=_IDS)
@pytest.mark.xfail(strict=False, reason="system may be stricter than historical human decisions (ER-001/ER-003/ER-004)")
def test_no_escalation_required_gets_recommended(client, req_id, winner, ranked):
    """If the historical winner had no escalation and was awarded, the system should recommend.

    Note: policy_compliant in the CSV refers to the award decision, not the original
    request. We use escalation_required=False on the winner as a proxy for clean cases.
    """
    if winner["escalation_required"].strip() == "True":
        pytest.skip("historical winner required escalation — not a clean case")
    # Only meaningful for requests where completeness is not the issue
    payload = _ALL_REQUESTS[req_id]
    if "missing_info" in payload.get("scenario_tags", []):
        pytest.skip("missing_info request — pipeline cannot proceed by design")
    body = _post(client, req_id)
    assert body["recommendation"]["status"] == "recommended", (
        f"{req_id}: historical winner had no escalation but system returned "
        f"status={body['recommendation']['status']}"
    )


# ---------------------------------------------------------------------------
# SOFT assertions (xfail strict=False — measure alignment without blocking CI)
# ---------------------------------------------------------------------------

@pytest.mark.parametrize("req_id,winner,ranked", _BACKTEST, ids=_IDS)
@pytest.mark.xfail(strict=False, reason="system ranking may differ from historical decision")
def test_system_rank1_matches_historical_winner(client, req_id, winner, ranked):
    """System's top-ranked supplier matches the historically awarded supplier (rank 1 == rank 1)."""
    body = _post(client, req_id)
    shortlist = body["supplier_shortlist"]
    if not shortlist:
        pytest.skip("empty shortlist")
    system_top1 = shortlist[0]["supplier_id"]
    assert system_top1 == winner["supplier_id"], (
        f"{req_id}: system rank-1 = {system_top1}, historical winner = {winner['supplier_id']} "
        f"({winner['supplier_name']})"
    )


@pytest.mark.parametrize("req_id,winner,ranked", _BACKTEST, ids=_IDS)
@pytest.mark.xfail(strict=False, reason="system ranking may differ from historical decision")
def test_historical_winner_in_system_top3(client, req_id, winner, ranked):
    """Historical winner appears in system's top-3 shortlist positions."""
    body = _post(client, req_id)
    top3_ids = [e["supplier_id"] for e in body["supplier_shortlist"] if e["rank"] <= 3]
    assert winner["supplier_id"] in top3_ids, (
        f"{req_id}: historical winner {winner['supplier_id']} not in system top-3 {top3_ids}"
    )


@pytest.mark.parametrize("req_id,winner,ranked", _BACKTEST, ids=_IDS)
@pytest.mark.xfail(strict=False, reason="system may rank differently than historical records")
def test_rank_order_correlation(client, req_id, winner, ranked):
    """Historical rank order and system rank order agree for suppliers present in both."""
    body = _post(client, req_id)

    historical_order = {a["supplier_id"]: int(a["award_rank"]) for a in ranked}
    system_order = {
        e["supplier_id"]: e["rank"]
        for e in body["supplier_shortlist"]
        if e["supplier_id"] in historical_order
    }

    if len(system_order) < 2:
        pytest.skip("fewer than 2 overlapping suppliers to compare order")

    # Build ordered lists by system rank and check historical rank also increases
    by_system_rank = sorted(system_order.items(), key=lambda x: x[1])
    historical_ranks_in_system_order = [historical_order[sid] for sid, _ in by_system_rank]

    inversions = sum(
        1
        for i in range(len(historical_ranks_in_system_order))
        for j in range(i + 1, len(historical_ranks_in_system_order))
        if historical_ranks_in_system_order[i] > historical_ranks_in_system_order[j]
    )
    total_pairs = len(historical_ranks_in_system_order) * (len(historical_ranks_in_system_order) - 1) // 2
    agreement_ratio = 1 - (inversions / total_pairs) if total_pairs else 1.0

    assert agreement_ratio >= 0.5, (
        f"{req_id}: rank order agreement {agreement_ratio:.0%} < 50% "
        f"(system={by_system_rank}, historical={historical_order})"
    )
