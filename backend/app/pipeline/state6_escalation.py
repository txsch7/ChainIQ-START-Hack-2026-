"""State 6 — Escalation routing and EscalationPayload formatting."""
import logging

from app.data.store import DataStore
from app.models.state import GlobalState

logger = logging.getLogger(__name__)


def run(state: GlobalState, store: DataStore) -> GlobalState:
    """Log and enrich escalation payloads if any escalations exist."""
    if not state.escalations:
        state.log("state6", "skip", "No escalations to process")
        return state

    state.log(
        "state6",
        "start",
        f"Processing {len(state.escalations)} escalation(s)",
    )

    # Map rule_id → resume_from_state hint
    resume_hints = {
        "ER-001": "state2",   # missing info / budget → needs requester clarification
        "ER-002": "state3",   # restricted preferred supplier → procurement decision
        "ER-003": "state4",   # high value → strategic sourcing approval
        "ER-004": "state4",   # no compliant supplier / lead time → category head
        "ER-005": "state3",   # data residency → security review
        "ER-006": "state4",   # capacity → sourcing excellence
        "ER-007": "state3",   # brand safety → marketing governance
        "ER-008": "state3",   # supplier not registered → regional compliance
    }

    for esc in state.escalations:
        resume = resume_hints.get(esc.rule, "state3")
        state.log(
            "state6",
            "escalation",
            (
                f"{esc.escalation_id} | {esc.rule} → {esc.escalate_to} "
                f"(resume_from: {resume}) | {esc.trigger[:120]}"
            ),
        )

    state.log("state6", "complete", "Escalation processing done")
    return state
