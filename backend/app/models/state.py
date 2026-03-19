from datetime import datetime
from pydantic import BaseModel, Field
from app.models.extraction import ExtractedData


class ValidationIssue(BaseModel):
    issue_id: str
    severity: str  # critical, high, medium, low
    type: str
    description: str
    action_required: str | None = None


class EscalationItem(BaseModel):
    escalation_id: str
    rule: str
    trigger: str
    escalate_to: str
    blocking: bool = True


class SupplierShortlistEntry(BaseModel):
    rank: int
    supplier_id: str
    supplier_name: str
    preferred: bool
    incumbent: bool
    pricing_tier_applied: str
    unit_price_local: float
    unit_price_eur: float
    total_price_eur: float
    currency: str
    standard_lead_time_days: int
    expedited_lead_time_days: int | None = None
    expedited_unit_price_eur: float | None = None
    expedited_total_eur: float | None = None
    quality_score: int
    risk_score: int
    esg_score: int
    capacity_per_month: int
    composite_score: float
    policy_compliant: bool = True
    covers_delivery_country: bool = True
    historical_precedent: bool = False
    recommendation_note: str = ""


class ExcludedSupplier(BaseModel):
    supplier_id: str
    supplier_name: str
    reason: str


class AuditLogEntry(BaseModel):
    state: str
    timestamp: str
    action: str
    detail: str


class GlobalState(BaseModel):
    request_id: str
    extracted_data: ExtractedData
    processed_at: str = Field(
        default_factory=lambda: datetime.utcnow().isoformat() + "Z"
    )

    # State 2 output
    validation_completeness: str = "pass"
    validation_issues: list[ValidationIssue] = Field(default_factory=list)

    # State 3 output
    eligible_suppliers: list[dict] = Field(default_factory=list)
    approval_threshold_result: dict = Field(default_factory=dict)
    preferred_supplier_result: dict = Field(default_factory=dict)
    category_rules_applied: list[str] = Field(default_factory=list)
    geography_rules_applied: list[str] = Field(default_factory=list)
    restricted_suppliers_flagged: dict = Field(default_factory=dict)

    # State 4 output
    shortlist: list[SupplierShortlistEntry] = Field(default_factory=list)
    excluded_suppliers: list[ExcludedSupplier] = Field(default_factory=list)
    scoring_weights: dict = Field(default_factory=dict)

    # Escalations accumulated across all states
    escalations: list[EscalationItem] = Field(default_factory=list)

    # Final output
    recommendation: dict = Field(default_factory=dict)
    audit_trail: dict = Field(default_factory=dict)

    # Internal audit log
    audit_log: list[AuditLogEntry] = Field(default_factory=list)

    def log(self, state_name: str, action: str, detail: str) -> None:
        self.audit_log.append(
            AuditLogEntry(
                state=state_name,
                timestamp=datetime.utcnow().isoformat() + "Z",
                action=action,
                detail=detail,
            )
        )

    def add_escalation(
        self,
        rule: str,
        trigger: str,
        escalate_to: str,
        blocking: bool = True,
    ) -> None:
        # Deduplicate by rule
        if any(e.rule == rule for e in self.escalations):
            return
        n = len(self.escalations) + 1
        self.escalations.append(
            EscalationItem(
                escalation_id=f"ESC-{n:03d}",
                rule=rule,
                trigger=trigger,
                escalate_to=escalate_to,
                blocking=blocking,
            )
        )

    def add_validation_issue(
        self,
        severity: str,
        type_: str,
        description: str,
        action: str | None = None,
    ) -> None:
        issue_id = f"V-{len(self.validation_issues) + 1:03d}"
        self.validation_issues.append(
            ValidationIssue(
                issue_id=issue_id,
                severity=severity,
                type=type_,
                description=description,
                action_required=action,
            )
        )

    @property
    def has_blocking_escalation(self) -> bool:
        return any(e.blocking for e in self.escalations)
