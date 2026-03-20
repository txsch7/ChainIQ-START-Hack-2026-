# ChainIQ Backend — Integration Test Suite

Tests drive the real `POST /pipeline/run` endpoint using the 304-request synthetic dataset. No mocking — real data files, real pipeline.

## Structure

| File | Tests | Purpose |
|------|-------|---------|
| `test_health.py` | 1 | App boots and `/health` responds |
| `test_pipeline_schema.py` | 13 | Response shape contract (top-level keys, field types, enums) |
| `test_pipeline_known.py` | 14 | Pinned regression assertions for specific request IDs |
| `test_pipeline_scenarios.py` | ~660 | Parametrized by `scenario_tags` across all 304 requests |
| `test_pipeline_edge_cases.py` | 11 | Synthetic hand-crafted payloads (nulls, missing fields, 422) |

## Quick Start

```bash
# From backend/
cd backend

# Install test deps (first time)
pip install -e ".[test]"

# Smoke test — app boots and contract holds
pytest tests/test_health.py tests/test_pipeline_schema.py -v

# Regression harness — known request assertions
pytest tests/test_pipeline_known.py -v

# Edge cases
pytest tests/test_pipeline_edge_cases.py -v

# Full suite
pytest tests/ -v --tb=short
```

## Scenario Tags

Run a single scenario tag with `-k`:

```bash
pytest tests/test_pipeline_scenarios.py -k "standard" -v
pytest tests/test_pipeline_scenarios.py -k "missing_info" -v
pytest tests/test_pipeline_scenarios.py -k "restricted" -v
```

| Tag | Count | Expected behavior |
|-----|-------|-------------------|
| `standard` | 141 | `completeness=pass`, `status=recommended`, non-empty shortlist |
| `missing_info` | 28 | `completeness=fail`, `ER-001` blocking, `status=cannot_proceed` |
| `threshold` | 29 | `approval_threshold.rule_applied` set, `quotes_required >= 1` |
| `lead_time` | 29 | `ER-004` present or `status=cannot_proceed` |
| `restricted` | 18 | `ER-002` blocking, preferred supplier shows restriction |
| `contradictory` | 21 | `status=cannot_proceed`, ≥1 blocking escalation |
| `capacity` | 18 | HTTP 200 (soft — ER-006 only fires if all suppliers below capacity) |
| `multilingual` | 18 | HTTP 200, valid status, `request_id` echoed |
| `multi_country` | 3 | HTTP 200, `delivery_countries` present in `request_interpretation` |

## Current Status

```
769 passed, 126 failed (895 total)
```

The 126 failing tests are **TDD targets** that expose known backend gaps — they define intended behavior, not test bugs:

| Failing group | Count | Backend gap |
|---|---|---|
| `test_standard_status_recommended` | 74 | Budget validation blocks ~52% of standard requests |
| `test_restricted_er002_*` | 45 | ER-002 fires for only 3/18 restricted requests |
| `test_lead_time_er004_or_cannot_proceed` | 3 | Some lead_time requests bypass ER-004 |
| `test_standard_shortlist_non_empty` | 2 | 2 standard requests produce empty shortlists |
| `test_contradictory_*` | 2 | REQ-000287 missing blocking escalation |

Fix the backend → failing tests go green. No test changes needed.

## Key Constraints

- `esg_requirement` is `bool` (not nullable) — synthetic payloads must use `True`/`False`
- `delivery_countries` defaults to `[]` — empty list triggers `completeness=fail`
- `request_id` missing → HTTP 422 (Pydantic validation, not pipeline logic)
- DataStore is session-scoped — loaded once for all 895 tests (~100ms startup)
