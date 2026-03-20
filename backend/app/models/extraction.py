from pydantic import BaseModel, Field


class ExtractedData(BaseModel):
    request_id: str
    created_at: str | None = None
    request_channel: str | None = None
    request_language: str | None = None
    business_unit: str | None = None
    country: str | None = None
    site: str | None = None
    requester_id: str | None = None
    requester_role: str | None = None
    submitted_for_id: str | None = None
    category_l1: str | None = None
    category_l2: str | None = None
    title: str | None = None
    request_text: str | None = None
    currency: str | None = None
    budget_amount: float | None = None
    quantity: float | None = None
    unit_of_measure: str | None = None
    required_by_date: str | None = None
    preferred_supplier_mentioned: str | None = None
    incumbent_supplier: str | None = None
    contract_type_requested: str | None = None
    delivery_countries: list[str] = Field(default_factory=list)
    data_residency_constraint: bool = False
    esg_requirement: bool = False
    status: str | None = None
    scenario_tags: list[str] = Field(default_factory=list)
