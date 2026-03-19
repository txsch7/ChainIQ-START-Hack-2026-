"""State 2 — Completeness validation and contradiction detection."""
import logging
from datetime import date

from app.data.store import DataStore
from app.models.state import GlobalState

logger = logging.getLogger(__name__)

SINGLE_SUPPLIER_PHRASES = [
    "no exception",
    "single source",
    "sole source",
    "only this supplier",
    "exclusively",
    "no alternative",
]


def run(state: GlobalState, store: DataStore) -> GlobalState:
    state.log("state2", "start", "Running completeness validation")
    d = state.extracted_data

    # --- Required field checks ---
    missing: list[str] = []
    if not d.category_l1:
        missing.append("category_l1")
    if not d.category_l2:
        missing.append("category_l2")
    if d.quantity is None or d.quantity <= 0:
        missing.append("quantity")
    if d.budget_amount is None or d.budget_amount <= 0:
        missing.append("budget_amount")
    if not d.delivery_countries:
        missing.append("delivery_countries")

    if missing:
        state.validation_completeness = "fail"
        state.add_validation_issue(
            severity="critical",
            type_="missing_required_fields",
            description=(
                f"Required fields missing or invalid: {', '.join(missing)}. "
                "Pipeline cannot proceed without complete sourcing information."
            ),
            action=(
                "Requester must provide all required fields before sourcing can continue."
            ),
        )
        state.add_escalation(
            "ER-001",
            f"Missing required information: {', '.join(missing)}. Cannot proceed with automated sourcing.",
            "Requester Clarification",
            blocking=True,
        )
        state.log("state2", "fail", f"Missing fields: {missing}")
        return state

    state.validation_completeness = "pass"

    # --- Required-by-date sanity ---
    if d.required_by_date:
        try:
            req_date = date.fromisoformat(d.required_by_date)
            today = date.today()
            if req_date < today:
                state.add_validation_issue(
                    severity="medium",
                    type_="date_in_past",
                    description=f"Required by date {d.required_by_date} is in the past.",
                    action="Confirm the correct delivery date.",
                )
        except ValueError:
            state.add_validation_issue(
                severity="medium",
                type_="invalid_date_format",
                description=f"Required by date '{d.required_by_date}' is not a valid ISO date.",
                action="Provide a valid date in YYYY-MM-DD format.",
            )

    # --- Single-supplier instruction vs policy conflict ---
    if d.preferred_supplier_mentioned and d.request_text:
        text_lower = d.request_text.lower()
        matched_phrase = next(
            (p for p in SINGLE_SUPPLIER_PHRASES if p in text_lower), None
        )
        if matched_phrase:
            state.add_validation_issue(
                severity="high",
                type_="policy_conflict",
                description=(
                    f"Requester instruction ('{matched_phrase}') appears to mandate single-supplier "
                    f"selection for '{d.preferred_supplier_mentioned}'. This conflicts with procurement "
                    "policy requiring multiple quotes above certain value thresholds."
                ),
                action=(
                    "Verify that single-source selection complies with the applicable approval threshold. "
                    "Policy AT-002+ requires 2–3 quotes above EUR 25,000. "
                    "A deviation requires Procurement Manager approval."
                ),
            )

    state.log(
        "state2",
        "complete",
        f"Validation pass. Issues found: {len(state.validation_issues)}",
    )
    return state
