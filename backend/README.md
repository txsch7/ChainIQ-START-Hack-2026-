# ChainIQ Backend — States 2–6

Deterministic sourcing pipeline: policy enforcement, commercial scoring, escalation routing.
Receives extracted purchase requests from n8n (State 1 HITL) and returns audit-ready sourcing decisions.

---

## Stack

- Python 3.12 · FastAPI · Pydantic v2 · Pandas · uv

---

## Run locally

```bash
pip install fastapi "uvicorn[standard]" pydantic pandas
uvicorn app.main:app --reload --port 8000
```

Data files are loaded from `../data/` relative to `backend/` at startup.

---

## API

### `POST /pipeline/run`

Accepts the full extracted request payload (same schema as `examples/example_request.json`).

```bash
curl -X POST http://localhost:8000/pipeline/run \
  -H "Content-Type: application/json" \
  -d @../examples/example_request.json
```

**Response fields:**

| Field | Description |
|---|---|
| `request_interpretation` | Structured fields + `days_until_required` |
| `validation.completeness` | `pass` / `fail` |
| `validation.issues_detected` | V-001… with severity, type, action |
| `policy_evaluation` | AT threshold, preferred supplier, restrictions, category/geo rules applied |
| `supplier_shortlist` | Ranked entries with price (EUR), lead times, scores, composite |
| `suppliers_excluded` | Every excluded supplier with reason |
| `escalations` | ESC-001… with rule, trigger, escalate_to, blocking |
| `recommendation` | `status`, winner or cannot_proceed reason, min budget |
| `audit_trail` | Policies checked, FX rates used, data sources, historical awards |

### `GET /health`

```json
{ "status": "ok" }
```

---

## Pipeline states

| State | File | Responsibility |
|---|---|---|
| 2 | `state2_validation.py` | Null checks, date sanity, single-supplier conflict detection |
| 3 | `state3_policy.py` | Geo filter → data residency → restriction filter → category/geo rules → ER-002/005/007 |
| 4 | `state4_commercial.py` | Pricing tier lookup, FX conversion, scoring matrix, AT threshold, ER-001/003/004/006 |
| 5 | `state5_output.py` | Recommendation, audit trail |
| 6 | `state6_escalation.py` | Escalation log with `resume_from_state` hints |

Each state receives `GlobalState` and returns `GlobalState`. Escalations accumulate — pipeline never hard-crashes.

---

## Escalation rules

| Rule | Trigger | Target |
|---|---|---|
| ER-001 | Missing fields / budget insufficient | Requester Clarification |
| ER-002 | Preferred supplier is restricted | Procurement Manager |
| ER-003 | Contract value ≥ 500K EUR/CHF / 540K USD | Head of Strategic Sourcing |
| ER-004 | No compliant supplier / lead time infeasible | Head of Category |
| ER-005 | Data residency constraint, no compliant supplier | Security and Compliance Review |
| ER-006 | All suppliers below required capacity | Sourcing Excellence Lead |
| ER-007 | Influencer Campaign Management (brand safety) | Marketing Governance Lead |
| AT-xxx | Single-supplier instruction vs. multi-quote policy | Procurement Manager |

---

## Scoring matrix

Default weights (adjusted if `esg_requirement: true`):

| Dimension | Default | ESG mode |
|---|---|---|
| Price (inverted) | 40% | 35% |
| Quality | 25% | 25% |
| Risk (inverted) | 20% | 15% |
| ESG | 15% | 25% |

Incumbent supplier: **+5 bonus points**.

---

## FX rates (static)

```
EUR → CHF  0.93    CHF → EUR  1.075
EUR → USD  1.08    USD → EUR  0.926
```

Logged in every `audit_trail.fx_rates_used` for reproducibility.

---

## Docker

```bash
docker build -t chainiq-backend .
docker run -p 8000:8000 chainiq-backend
```

> The `Dockerfile` copies `../data/` into the image. Build from `backend/`.
