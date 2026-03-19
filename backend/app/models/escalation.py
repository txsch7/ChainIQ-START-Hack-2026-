from pydantic import BaseModel


class EscalationPayload(BaseModel):
    rule_id: str
    trigger: str
    escalate_to: str
    blocking: bool = True
    resume_from_state: str | None = None
    resolution_required: list[str] = []
