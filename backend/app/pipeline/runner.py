"""Pipeline orchestrator: State 2 → 3 → 4 → 5/6."""
import logging

from app.data.store import DataStore
from app.models.extraction import ExtractedData
from app.models.state import GlobalState
from app.pipeline import (
    state2_validation,
    state3_policy,
    state4_commercial,
    state5_output,
    state6_escalation,
)

logger = logging.getLogger(__name__)


def build_response(state: GlobalState) -> dict:
    """Serialise GlobalState into the canonical API response format."""
    d = state.extracted_data

    # Request interpretation
    req_interp: dict = {
        "category_l1": d.category_l1,
        "category_l2": d.category_l2,
        "quantity": d.quantity,
        "unit_of_measure": d.unit_of_measure,
        "budget_amount": d.budget_amount,
        "currency": d.currency,
        "delivery_countries": d.delivery_countries,
        "required_by_date": d.required_by_date,
        "data_residency_required": d.data_residency_constraint,
        "esg_requirement": d.esg_requirement,
        "preferred_supplier_stated": d.preferred_supplier_mentioned,
        "incumbent_supplier": d.incumbent_supplier,
        "request_language": d.request_language,
    }
    if d.required_by_date and d.created_at:
        try:
            from datetime import date

            req_date = date.fromisoformat(d.required_by_date)
            created = date.fromisoformat(d.created_at[:10])
            req_interp["days_until_required"] = (req_date - created).days
        except (ValueError, AttributeError):
            pass

    # Validation
    validation = {
        "completeness": state.validation_completeness,
        "issues_detected": [
            {
                "issue_id": vi.issue_id,
                "severity": vi.severity,
                "type": vi.type,
                "description": vi.description,
                "action_required": vi.action_required,
            }
            for vi in state.validation_issues
        ],
    }

    # Policy evaluation
    # Build restricted_suppliers section showing both restricted and notable non-restricted
    restricted_section = dict(state.restricted_suppliers_flagged)
    for excl in state.excluded_suppliers:
        key = f"{excl.supplier_id}_{excl.supplier_name.replace(' ', '_')}"
        if excl.supplier_id not in restricted_section:
            # Add non-restricted excluded suppliers for transparency
            if "risk" in excl.reason.lower() or "ranked" in excl.reason.lower():
                row = None
                if state.eligible_suppliers:
                    matches = [r for r in state.eligible_suppliers if r["supplier_id"] == excl.supplier_id]
                    row = matches[0] if matches else None
                if row:
                    restricted_section[key] = {
                        "restricted": False,
                        "note": excl.reason,
                    }

    policy_eval = {
        "approval_threshold": state.approval_threshold_result,
        "preferred_supplier": state.preferred_supplier_result,
        "restricted_suppliers": restricted_section,
        "category_rules_applied": state.category_rules_applied,
        "geography_rules_applied": state.geography_rules_applied,
    }

    # Shortlist
    shortlist = [
        {
            "rank": s.rank,
            "supplier_id": s.supplier_id,
            "supplier_name": s.supplier_name,
            "preferred": s.preferred,
            "incumbent": s.incumbent,
            "pricing_tier_applied": s.pricing_tier_applied,
            "unit_price_eur": s.unit_price_eur,
            "total_price_eur": s.total_price_eur,
            "standard_lead_time_days": s.standard_lead_time_days,
            "expedited_lead_time_days": s.expedited_lead_time_days,
            "expedited_unit_price_eur": s.expedited_unit_price_eur,
            "expedited_total_eur": s.expedited_total_eur,
            "quality_score": s.quality_score,
            "risk_score": s.risk_score,
            "esg_score": s.esg_score,
            "composite_score": s.composite_score,
            "policy_compliant": s.policy_compliant,
            "covers_delivery_country": s.covers_delivery_country,
            "historical_precedent": s.historical_precedent,
            "recommendation_note": s.recommendation_note,
        }
        for s in state.shortlist
    ]

    # De-duplicated excluded list
    seen_excl: set[str] = set()
    excluded = []
    for e in state.excluded_suppliers:
        if e.supplier_id not in seen_excl:
            seen_excl.add(e.supplier_id)
            excluded.append(
                {
                    "supplier_id": e.supplier_id,
                    "supplier_name": e.supplier_name,
                    "reason": e.reason,
                }
            )

    # Escalations
    escalations = [
        {
            "escalation_id": e.escalation_id,
            "rule": e.rule,
            "trigger": e.trigger,
            "escalate_to": e.escalate_to,
            "blocking": e.blocking,
        }
        for e in state.escalations
    ]

    return {
        "request_id": state.request_id,
        "processed_at": state.processed_at,
        "request_interpretation": req_interp,
        "validation": validation,
        "policy_evaluation": policy_eval,
        "supplier_shortlist": shortlist,
        "suppliers_excluded": excluded,
        "escalations": escalations,
        "recommendation": state.recommendation,
        "audit_trail": state.audit_trail,
    }


def run_pipeline(
    request_id: str,
    extracted_data: ExtractedData,
    store: DataStore,
    start_from: str = "state2",
) -> dict:
    state = GlobalState(request_id=request_id, extracted_data=extracted_data)
    logger.info("Pipeline start: %s (start_from=%s)", request_id, start_from)

    # State 2 — Validation
    if start_from == "state2":
        state = state2_validation.run(state, store)
        if state.validation_completeness == "fail":
            state = state5_output.run(state, store)
            state = state6_escalation.run(state, store)
            return build_response(state)

    # State 3 — Policy & compliance
    if start_from in ("state2", "state3"):
        state = state3_policy.run(state, store)
        if not state.eligible_suppliers:
            state = state5_output.run(state, store)
            state = state6_escalation.run(state, store)
            return build_response(state)

    # State 4 — Commercial evaluation & scoring
    if start_from in ("state2", "state3", "state4"):
        state = state4_commercial.run(state, store)

    # State 5 — Output formatting
    state = state5_output.run(state, store)

    # State 6 — Escalation routing
    state = state6_escalation.run(state, store)

    logger.info(
        "Pipeline complete: %s → %s (escalations: %d)",
        request_id,
        state.recommendation.get("status"),
        len(state.escalations),
    )
    return build_response(state)
