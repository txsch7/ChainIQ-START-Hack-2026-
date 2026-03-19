"""State 5 — Audit output generation (success path)."""
import logging

from app.config import FX_RATES
from app.data.store import DataStore
from app.models.state import GlobalState

logger = logging.getLogger(__name__)


def run(state: GlobalState, store: DataStore) -> GlobalState:
    state.log("state5", "start", "Formatting output and building audit provenance")
    d = state.extracted_data

    # ------------------------------------------------------------------ #
    # Recommendation
    # ------------------------------------------------------------------ #
    if not state.has_blocking_escalation and state.shortlist:
        top = state.shortlist[0]
        state.recommendation = {
            "status": "recommended",
            "winner": top.supplier_name,
            "winner_id": top.supplier_id,
            "total_price_eur": top.total_price_eur,
            "rationale": (
                top.recommendation_note
                or f"Highest composite score ({top.composite_score:.1f}) among eligible suppliers."
            ),
        }
    elif state.shortlist:
        top = state.shortlist[0]
        blocking = [e for e in state.escalations if e.blocking]
        reasons = "; ".join(e.trigger[:90] for e in blocking[:3])
        state.recommendation = {
            "status": "cannot_proceed",
            "reason": (
                f"{len(blocking)} blocking issue(s) prevent autonomous award: {reasons}."
            ),
            "preferred_supplier_if_resolved": top.supplier_name,
            "preferred_supplier_rationale": top.recommendation_note,
        }
        if d.budget_amount:
            min_total = min(e.total_price_eur for e in state.shortlist)
            state.recommendation["minimum_budget_required"] = round(min_total, 2)
            state.recommendation["minimum_budget_currency"] = "EUR"
    else:
        state.recommendation = {
            "status": "cannot_proceed",
            "reason": "No eligible suppliers found after policy and commercial evaluation.",
        }

    # ------------------------------------------------------------------ #
    # Audit trail
    # ------------------------------------------------------------------ #
    all_supplier_ids = list(
        {s.supplier_id for s in state.shortlist}
        | {e.supplier_id for e in state.excluded_suppliers}
    )

    policies_checked: list[str] = []
    if at := state.approval_threshold_result.get("rule_applied"):
        policies_checked.append(at)
    policies_checked.extend(state.category_rules_applied)
    policies_checked.extend(state.geography_rules_applied)
    for esc in state.escalations:
        policies_checked.append(esc.rule)
    # Dedup preserving order
    seen: set[str] = set()
    policies_checked = [p for p in policies_checked if not (p in seen or seen.add(p))]

    # Historical precedent note
    hist_consulted = any(s.historical_precedent for s in state.shortlist)
    hist_note: str | None = None
    if hist_consulted:
        delivery_countries = d.delivery_countries or ([d.country] if d.country else [""])
        for s in state.shortlist:
            if s.historical_precedent:
                awards = []
                for country in delivery_countries:
                    awards.extend(
                        store.get_historical_awards(d.category_l2 or "", country, s.supplier_id)
                    )
                if awards:
                    ids = [a["award_id"] for a in awards[:3]]
                    hist_note = (
                        f"{', '.join(ids)} show prior awards to {s.supplier_name} "
                        f"for {d.category_l2} in this region. "
                        "Prior decision used for pattern context only."
                    )
                    break

    state.audit_trail = {
        "policies_checked": policies_checked,
        "supplier_ids_evaluated": all_supplier_ids,
        "pricing_region": state.scoring_weights.get("_pricing_region", "EU"),
        "scoring_weights": {
            k: v for k, v in state.scoring_weights.items() if not k.startswith("_")
        },
        "fx_rates_used": FX_RATES,
        "data_sources_used": [
            "suppliers.csv",
            "pricing.csv",
            "policies.json",
            "historical_awards.csv",
        ],
        "historical_awards_consulted": hist_consulted,
        "historical_award_note": hist_note,
    }

    state.log(
        "state5",
        "complete",
        f"Output formatted. Status: {state.recommendation.get('status')}",
    )
    return state
