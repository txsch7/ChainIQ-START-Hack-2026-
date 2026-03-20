"""State 4 — Capacity, pricing, scoring, threshold evaluation."""
import logging
import math
from datetime import date

from app.config import (
    COUNTRY_TO_PRICING_REGION,
    DEFAULT_WEIGHTS,
    ESG_WEIGHTS,
    FX_RATES,
    HIGH_VALUE_THRESHOLDS,
    INCUMBENT_BONUS,
    MAX_SHORTLIST,
)
from app.data.store import DataStore
from app.models.state import ExcludedSupplier, GlobalState, SupplierShortlistEntry

logger = logging.getLogger(__name__)


# ------------------------------------------------------------------ #
# Currency helpers
# ------------------------------------------------------------------ #

def convert_to_eur(amount: float, currency: str) -> float:
    if currency == "EUR":
        return amount
    key = f"{currency}_EUR"
    rate = FX_RATES.get(key)
    if rate:
        return amount * rate
    # Try inverse
    rev_key = f"EUR_{currency}"
    rev_rate = FX_RATES.get(rev_key)
    if rev_rate:
        return amount / rev_rate
    return amount  # fallback: assume already EUR


def eur_to_currency(amount_eur: float, currency: str) -> float:
    if currency == "EUR":
        return amount_eur
    key = f"EUR_{currency}"
    rate = FX_RATES.get(key)
    if rate:
        return amount_eur * rate
    rev_key = f"{currency}_EUR"
    rev_rate = FX_RATES.get(rev_key)
    if rev_rate:
        return amount_eur / rev_rate
    return amount_eur


def _safe_float(val) -> float | None:
    try:
        f = float(val)
        return None if math.isnan(f) else f
    except (TypeError, ValueError):
        return None


# ------------------------------------------------------------------ #
# Main state function
# ------------------------------------------------------------------ #

def run(state: GlobalState, store: DataStore) -> GlobalState:
    state.log("state4", "start", "Running commercial evaluation and scoring")
    d = state.extracted_data
    quantity = float(d.quantity)

    delivery_countries = d.delivery_countries or ([d.country] if d.country else [])
    primary_country = delivery_countries[0] if delivery_countries else "DE"
    pricing_region = COUNTRY_TO_PRICING_REGION.get(primary_country, "EU")

    state.log(
        "state4",
        "fx_rates",
        f"FX rates: {FX_RATES} | pricing_region: {pricing_region}",
    )

    weights = ESG_WEIGHTS if d.esg_requirement else DEFAULT_WEIGHTS
    state.scoring_weights = {**weights, "_pricing_region": pricing_region}

    # Resolve incumbent
    incumbent_id = store.find_supplier_id_by_name(d.incumbent_supplier) if d.incumbent_supplier else None

    # ------------------------------------------------------------------ #
    # Build candidate list with pricing
    # ------------------------------------------------------------------ #
    candidates: list[dict] = []

    for row in state.eligible_suppliers:
        supplier_id = row["supplier_id"]
        supplier_name = row["supplier_name"]

        tier = store.get_pricing_tier(supplier_id, d.category_l2, pricing_region, quantity)
        if not tier:
            if not any(e.supplier_id == supplier_id for e in state.excluded_suppliers):
                state.excluded_suppliers.append(
                    ExcludedSupplier(
                        supplier_id=supplier_id,
                        supplier_name=supplier_name,
                        reason=f"No pricing data found for {d.category_l2} in region {pricing_region}.",
                    )
                )
            state.log("state4", "no_pricing", f"{supplier_id} has no pricing")
            continue

        sup_currency = str(tier.get("currency") or row.get("currency") or "EUR")
        unit_price_local = float(tier["unit_price"])
        unit_price_eur = convert_to_eur(unit_price_local, sup_currency)
        total_price_eur = unit_price_eur * quantity

        exp_price_local = _safe_float(tier.get("expedited_unit_price"))
        exp_price_eur = convert_to_eur(exp_price_local, sup_currency) if exp_price_local else None
        exp_total_eur = exp_price_eur * quantity if exp_price_eur else None

        std_lead = int(_safe_float(tier.get("standard_lead_time_days")) or 0)
        exp_lead_raw = _safe_float(tier.get("expedited_lead_time_days"))
        exp_lead = int(exp_lead_raw) if exp_lead_raw else None

        min_q = int(_safe_float(tier.get("min_quantity")) or 0)
        max_q_raw = _safe_float(tier.get("max_quantity"))
        if max_q_raw and not math.isinf(max_q_raw):
            tier_label = f"{min_q}–{int(max_q_raw)} units"
        else:
            tier_label = f"{min_q}+ units"

        capacity = int(_safe_float(row.get("capacity_per_month")) or 0)

        # Historical precedent
        hist_awards = []
        for country in delivery_countries:
            hist_awards.extend(store.get_historical_awards(d.category_l2, country, supplier_id))

        candidates.append(
            {
                "supplier_id": supplier_id,
                "supplier_name": supplier_name,
                "unit_price_local": unit_price_local,
                "unit_price_eur": unit_price_eur,
                "total_price_eur": total_price_eur,
                "currency": sup_currency,
                "tier_label": tier_label,
                "std_lead": std_lead,
                "exp_lead": exp_lead,
                "exp_price_eur": exp_price_eur,
                "exp_total_eur": exp_total_eur,
                "quality_score": int(_safe_float(row.get("quality_score")) or 50),
                "risk_score": int(_safe_float(row.get("risk_score")) or 50),
                "esg_score": int(_safe_float(row.get("esg_score")) or 50),
                "capacity": capacity,
                "is_incumbent": supplier_id == incumbent_id,
                "has_precedent": len(hist_awards) > 0,
                "hist_awards": hist_awards,
                "preferred": bool(row.get("preferred_supplier", False)),
                "row": row,
            }
        )

    if not candidates:
        state.add_escalation(
            "ER-004",
            f"No eligible suppliers have pricing data for {d.category_l2} / region {pricing_region}. "
            "Insufficient quotes to proceed with automated sourcing.",
            "Head of Category",
            blocking=True,
        )
        state.log("state4", "ER-004", "No candidates with pricing")
        return state

    min_total_eur = min(c["total_price_eur"] for c in candidates)
    max_total_eur = max(c["total_price_eur"] for c in candidates)
    contract_currency = d.currency or "EUR"
    min_in_currency = eur_to_currency(min_total_eur, contract_currency)
    max_in_currency = eur_to_currency(max_total_eur, contract_currency)

    # ------------------------------------------------------------------ #
    # Approval threshold
    # ------------------------------------------------------------------ #
    at = store.get_approval_threshold(contract_currency, min_in_currency)
    threshold_result: dict = {
        "rule_applied": at.get("threshold_id", "unknown") if at else "unknown",
        "basis": (
            f"Estimated contract value range: {contract_currency} "
            f"{min_in_currency:,.2f}–{max_in_currency:,.2f}"
        ),
        "quotes_required": (
            at.get("min_supplier_quotes", at.get("quotes_required", 1)) if at else 1
        ),
        "approvers": at.get("managed_by", at.get("approvers", [])) if at else [],
        "deviation_approval": at.get("deviation_approval_required_from", []) if at else [],
    }
    state.approval_threshold_result = threshold_result

    # AT-threshold policy conflict: single-supplier instruction vs. quotes required
    has_single_supplier_issue = any(
        vi.type == "policy_conflict" for vi in state.validation_issues
    )
    quotes_required_at = int(
        at.get("min_supplier_quotes", at.get("quotes_required", 1)) if at else 1
    )
    if has_single_supplier_issue and quotes_required_at > 1:
        at_id = at.get("threshold_id", "AT-???") if at else "AT-???"
        state.add_escalation(
            at_id,
            (
                f"Policy conflict: requester instruction cannot override {at_id}. "
                f"Estimated contract value {contract_currency} {min_in_currency:,.2f}–"
                f"{max_in_currency:,.2f} requires {quotes_required_at} quotes. "
                f"Deviation requires approval from: "
                f"{', '.join(at.get('deviation_approval_required_from', []) if at else [])}."
            ),
            (at.get("deviation_approval_required_from", ["Procurement Manager"])[0]
             if at and at.get("deviation_approval_required_from")
             else "Procurement Manager"),
            blocking=True,
        )

    # ER-003: high-value tier
    hv_threshold = HIGH_VALUE_THRESHOLDS.get(contract_currency, 500_000.0)
    if max_in_currency >= hv_threshold:
        state.add_escalation(
            "ER-003",
            (
                f"Estimated contract value {contract_currency} {max_in_currency:,.2f} "
                f"exceeds high-value threshold ({contract_currency} {hv_threshold:,.0f}). "
                "Requires Head of Strategic Sourcing approval."
            ),
            "Head of Strategic Sourcing",
            blocking=True,
        )

    # ------------------------------------------------------------------ #
    # Budget validation
    # ------------------------------------------------------------------ #
    if d.budget_amount:
        budget_eur = convert_to_eur(float(d.budget_amount), contract_currency)
        if min_total_eur > budget_eur:
            cheapest = min(candidates, key=lambda c: c["total_price_eur"])
            shortfall = min_total_eur - budget_eur
            state.add_validation_issue(
                severity="critical",
                type_="budget_insufficient",
                description=(
                    f"Budget of {contract_currency} {d.budget_amount:,.2f} is insufficient. "
                    f"Minimum total price is EUR {min_total_eur:,.2f} "
                    f"({cheapest['supplier_name']}, tier {cheapest['tier_label']}). "
                    f"Shortfall: EUR {shortfall:,.2f}."
                ),
                action=(
                    f"Increase budget to at least EUR {min_total_eur:,.2f} "
                    f"or reduce quantity to a maximum of "
                    f"{int(budget_eur / cheapest['unit_price_eur'])} units within the stated budget."
                ),
            )
            state.add_escalation(
                "ER-001",
                (
                    f"Budget {contract_currency} {d.budget_amount:,.2f} cannot cover "
                    f"{int(quantity)} units at any compliant supplier price "
                    f"(minimum EUR {min_total_eur:,.2f})."
                ),
                "Requester Clarification",
                blocking=True,
            )

    # ------------------------------------------------------------------ #
    # Lead time feasibility
    # ------------------------------------------------------------------ #
    if d.required_by_date:
        try:
            req_date = date.fromisoformat(d.required_by_date)
            created_str = (d.created_at or "")[:10]
            created = date.fromisoformat(created_str) if created_str else date.today()
            days_available = (req_date - created).days

            can_meet_std = [c for c in candidates if c["std_lead"] <= days_available]
            can_meet_exp = [
                c for c in candidates
                if c["exp_lead"] is not None and c["exp_lead"] <= days_available
            ]

            if not can_meet_std and not can_meet_exp:
                min_std = min(c["std_lead"] for c in candidates)
                exp_vals = [c["exp_lead"] for c in candidates if c["exp_lead"] is not None]
                min_exp = min(exp_vals) if exp_vals else "N/A"
                state.add_validation_issue(
                    severity="high",
                    type_="lead_time_infeasible",
                    description=(
                        f"Required delivery {d.required_by_date} is {days_available} day(s) away. "
                        f"All suppliers' standard lead times ({min_std}d minimum) and expedited lead "
                        f"times ({min_exp}d minimum) exceed the available window."
                    ),
                    action=(
                        "Confirm whether the delivery date is a hard constraint. "
                        "If so, no compliant supplier can meet the deadline."
                    ),
                )
                state.add_escalation(
                    "ER-004",
                    (
                        f"Lead time infeasible: required delivery {d.required_by_date} "
                        f"({days_available} days). Minimum standard lead time: {min_std}d, "
                        f"expedited: {min_exp}d. No supplier can meet the deadline."
                    ),
                    "Head of Category",
                    blocking=True,
                )
        except (ValueError, AttributeError):
            pass

    # ------------------------------------------------------------------ #
    # Capacity check (ER-006)
    # ------------------------------------------------------------------ #
    insufficient_capacity = [c for c in candidates if 0 < c["capacity"] < quantity]
    zero_capacity = [c for c in candidates if c["capacity"] == 0]
    if len(insufficient_capacity) + len(zero_capacity) == len(candidates):
        state.add_escalation(
            "ER-006",
            (
                f"All eligible suppliers have insufficient or unconfirmed capacity for "
                f"quantity {int(quantity)}. Multi-supplier split or lead time extension required."
            ),
            "Sourcing Excellence Lead",
            blocking=True,
        )

    # ------------------------------------------------------------------ #
    # Scoring
    # ------------------------------------------------------------------ #
    prices = [c["total_price_eur"] for c in candidates]
    min_price, max_price = min(prices), max(prices)

    for c in candidates:
        price_score = (
            (max_price - c["total_price_eur"]) / (max_price - min_price) * 100
            if max_price > min_price
            else 50.0
        )
        quality_score = float(c["quality_score"])
        risk_score = 100.0 - float(c["risk_score"])  # inverted
        esg_score = float(c["esg_score"])

        composite = (
            weights["price"] * price_score
            + weights["quality"] * quality_score
            + weights["risk"] * risk_score
            + weights["esg"] * esg_score
        )
        if c["is_incumbent"]:
            composite += INCUMBENT_BONUS

        c["composite_score"] = round(composite, 2)

    candidates.sort(key=lambda c: c["composite_score"], reverse=True)

    quotes_req = int(threshold_result.get("quotes_required", 1))
    shortlist_size = max(quotes_req, min(MAX_SHORTLIST, len(candidates)))

    # ------------------------------------------------------------------ #
    # Build shortlist entries
    # ------------------------------------------------------------------ #
    for i, c in enumerate(candidates[:shortlist_size]):
        note_parts: list[str] = []
        if c["is_incumbent"]:
            note_parts.append("Incumbent supplier with established delivery capability")
        if c["has_precedent"]:
            awards = c["hist_awards"]
            award_ids = [a["award_id"] for a in awards[:2]]
            note_parts.append(
                f"Prior award history: {', '.join(award_ids)} for {d.category_l2}"
            )
        if c["preferred"]:
            note_parts.append("Policy-preferred supplier")
        if 0 < c["capacity"] < quantity:
            note_parts.append(
                f"Partial capacity: {c['capacity']:,} units/month vs {int(quantity):,} required"
            )
        elif c["capacity"] == 0:
            note_parts.append("Monthly capacity data unavailable")
        note_parts.append(
            f"Total price EUR {c['total_price_eur']:,.2f} "
            f"(composite score: {c['composite_score']:.1f})"
        )

        state.shortlist.append(
            SupplierShortlistEntry(
                rank=i + 1,
                supplier_id=c["supplier_id"],
                supplier_name=c["supplier_name"],
                preferred=bool(c["preferred"]),
                incumbent=c["is_incumbent"],
                pricing_tier_applied=c["tier_label"],
                unit_price_local=round(c["unit_price_local"], 2),
                unit_price_eur=round(c["unit_price_eur"], 2),
                total_price_eur=round(c["total_price_eur"], 2),
                currency=c["currency"],
                standard_lead_time_days=c["std_lead"],
                expedited_lead_time_days=c["exp_lead"],
                expedited_unit_price_eur=(
                    round(c["exp_price_eur"], 2) if c["exp_price_eur"] else None
                ),
                expedited_total_eur=(
                    round(c["exp_total_eur"], 2) if c["exp_total_eur"] else None
                ),
                quality_score=c["quality_score"],
                risk_score=c["risk_score"],
                esg_score=c["esg_score"],
                capacity_per_month=c["capacity"],
                composite_score=c["composite_score"],
                historical_precedent=c["has_precedent"],
                recommendation_note=". ".join(note_parts),
            )
        )

    # Suppliers not in shortlist (ranked out)
    for c in candidates[shortlist_size:]:
        if not any(e.supplier_id == c["supplier_id"] for e in state.excluded_suppliers):
            state.excluded_suppliers.append(
                ExcludedSupplier(
                    supplier_id=c["supplier_id"],
                    supplier_name=c["supplier_name"],
                    reason=(
                        f"Ranked outside top {shortlist_size} by composite score "
                        f"({c['composite_score']:.1f}). "
                        f"preferred={c['preferred']}, risk_score={c['risk_score']}."
                    ),
                )
            )

    state.log(
        "state4",
        "complete",
        f"Shortlist: {len(state.shortlist)}, excluded: {len(state.excluded_suppliers)}, "
        f"escalations: {len(state.escalations)}",
    )
    return state
