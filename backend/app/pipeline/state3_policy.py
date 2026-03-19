"""State 3 — Policy & compliance enforcement."""
import logging

from app.config import POLICY_REGION_COUNTRIES
from app.data.store import DataStore
from app.models.state import ExcludedSupplier, GlobalState

logger = logging.getLogger(__name__)


def _country_to_policy_regions(country: str) -> list[str]:
    """Return policy region names that contain this country (e.g. DE → ['EU'])."""
    return [
        region
        for region, countries in POLICY_REGION_COUNTRIES.items()
        if country in countries
    ] or ["global"]


def _supplier_covers_countries(service_regions: set, delivery_countries: list[str]) -> bool:
    for country in delivery_countries:
        if country in service_regions:
            return True
    return False


def _already_excluded(state: GlobalState, supplier_id: str) -> bool:
    return any(e.supplier_id == supplier_id for e in state.excluded_suppliers)


def run(state: GlobalState, store: DataStore) -> GlobalState:
    state.log("state3", "start", "Running policy and compliance checks")
    d = state.extracted_data

    if not d.category_l2:
        state.log("state3", "skip", "No category_l2; skipping state3")
        return state

    delivery_countries = d.delivery_countries or ([d.country] if d.country else [])
    primary_country = delivery_countries[0] if delivery_countries else None
    primary_regions = _country_to_policy_regions(primary_country) if primary_country else ["global"]

    # ------------------------------------------------------------------ #
    # 1. Resolve & check preferred supplier
    # ------------------------------------------------------------------ #
    preferred_result: dict = {"supplier": d.preferred_supplier_mentioned}

    if d.preferred_supplier_mentioned:
        pref_id = store.find_supplier_id_by_name(d.preferred_supplier_mentioned)
        if pref_id:
            is_preferred_in_policy = any(
                store.is_preferred(pref_id, d.category_l2, region)
                for region in primary_regions
            )
            is_restricted, restriction_reason = store.is_restricted_for_countries(
                pref_id, d.category_l2, delivery_countries
            )
            pref_rows = store.suppliers[store.suppliers["supplier_id"] == pref_id]
            covers = _supplier_covers_countries(
                pref_rows.iloc[0]["service_regions_set"] if not pref_rows.empty else set(),
                delivery_countries,
            )

            preferred_result.update(
                {
                    "supplier_id": pref_id,
                    "status": "restricted" if is_restricted else "eligible",
                    "is_preferred": is_preferred_in_policy,
                    "covers_delivery_country": covers,
                    "is_restricted": is_restricted,
                }
            )

            if is_restricted:
                preferred_result["policy_note"] = (
                    f"Preferred supplier is policy-restricted for {d.category_l2} "
                    f"in {delivery_countries}: {restriction_reason}"
                )
                state.add_escalation(
                    "ER-002",
                    (
                        f"Preferred supplier '{d.preferred_supplier_mentioned}' (ID: {pref_id}) "
                        f"is restricted for {d.category_l2} in {delivery_countries}. "
                        f"Reason: {restriction_reason}"
                    ),
                    "Procurement Manager",
                    blocking=True,
                )
                state.log("state3", "ER-002", f"Preferred supplier restricted: {pref_id}")
            elif not is_preferred_in_policy:
                preferred_result["policy_note"] = (
                    f"'{d.preferred_supplier_mentioned}' is not a policy-preferred supplier for "
                    f"{d.category_l2} in this region. Will be included if they serve the delivery area."
                )
            else:
                preferred_result["policy_note"] = (
                    f"{d.preferred_supplier_mentioned} is a policy-preferred supplier for "
                    f"{d.category_l2} in this region. Preferred status means inclusion in the comparison "
                    "— it does not mandate single-source selection."
                )
        else:
            preferred_result["status"] = "not_found"
            preferred_result["policy_note"] = (
                f"Could not resolve supplier ID for '{d.preferred_supplier_mentioned}'. "
                "Treating as non-preferred; subject to standard evaluation."
            )

    state.preferred_supplier_result = preferred_result

    # ------------------------------------------------------------------ #
    # 2. Get all candidates for this category
    # ------------------------------------------------------------------ #
    all_candidates = store.get_suppliers_for_category(d.category_l2)
    if not all_candidates:
        state.add_escalation(
            "ER-004",
            f"No suppliers found in DataStore for category: {d.category_l2}.",
            "Head of Category",
            blocking=True,
        )
        state.log("state3", "ER-004", f"No suppliers for {d.category_l2}")
        return state

    # ------------------------------------------------------------------ #
    # 3. Geographic filter
    # ------------------------------------------------------------------ #
    eligible: list[dict] = []
    for row in all_candidates:
        if _supplier_covers_countries(row["service_regions_set"], delivery_countries):
            eligible.append(row)
        elif not _already_excluded(state, row["supplier_id"]):
            state.excluded_suppliers.append(
                ExcludedSupplier(
                    supplier_id=row["supplier_id"],
                    supplier_name=row["supplier_name"],
                    reason=f"Does not serve delivery countries: {delivery_countries}.",
                )
            )

    state.log(
        "state3",
        "geo_filter",
        f"{len(eligible)} suppliers cover delivery countries; "
        f"{len(all_candidates) - len(eligible)} excluded.",
    )

    # ------------------------------------------------------------------ #
    # 4. Data residency filter
    # ------------------------------------------------------------------ #
    if d.data_residency_constraint:
        dr_ok = [r for r in eligible if r.get("data_residency_supported")]
        dr_fail = [r for r in eligible if not r.get("data_residency_supported")]
        for row in dr_fail:
            if not _already_excluded(state, row["supplier_id"]):
                state.excluded_suppliers.append(
                    ExcludedSupplier(
                        supplier_id=row["supplier_id"],
                        supplier_name=row["supplier_name"],
                        reason="Data residency constraint active; supplier does not support data residency.",
                    )
                )
        eligible = dr_ok
        state.log("state3", "dr_filter", f"{len(eligible)} suppliers support data residency")
        if not eligible:
            state.add_escalation(
                "ER-005",
                (
                    f"Data residency constraint is active but no eligible supplier supports it "
                    f"for {d.category_l2} in {delivery_countries}."
                ),
                "Security and Compliance Review",
                blocking=True,
            )

    # ------------------------------------------------------------------ #
    # 5. Restriction filter
    # ------------------------------------------------------------------ #
    non_restricted: list[dict] = []
    for row in eligible:
        is_restricted, reason = store.is_restricted_for_countries(
            row["supplier_id"], d.category_l2, delivery_countries
        )
        if is_restricted:
            state.restricted_suppliers_flagged[row["supplier_id"]] = {
                "supplier_name": row["supplier_name"],
                "restricted": True,
                "reason": reason,
            }
            if not _already_excluded(state, row["supplier_id"]):
                state.excluded_suppliers.append(
                    ExcludedSupplier(
                        supplier_id=row["supplier_id"],
                        supplier_name=row["supplier_name"],
                        reason=f"Restricted for {d.category_l2} in {delivery_countries}: {reason}",
                    )
                )
            state.log("state3", "restriction", f"Excluded restricted: {row['supplier_id']}")
        else:
            non_restricted.append(row)

    eligible = non_restricted

    if not eligible:
        state.add_escalation(
            "ER-004",
            (
                f"No compliant suppliers remain after geographic and restriction filters "
                f"for {d.category_l2} in {delivery_countries}."
            ),
            "Head of Category",
            blocking=True,
        )
        state.log("state3", "ER-004", "No eligible suppliers after filtering")
        state.eligible_suppliers = eligible
        return state

    state.eligible_suppliers = eligible

    # ------------------------------------------------------------------ #
    # 6. Category rules
    # ------------------------------------------------------------------ #
    cat_rules_applied: list[str] = []
    for cr in store.policies.get("category_rules", []):
        # Only apply if it matches the exact category_l2, or has no category_l2 (L1-level rule)
        rule_cat2 = cr.get("category_l2")
        rule_cat1 = cr.get("category_l1")
        if rule_cat2 == d.category_l2 or (rule_cat2 is None and rule_cat1 == d.category_l1):
            cat_rules_applied.append(cr["rule_id"])
            _apply_category_rule(state, cr)
    state.category_rules_applied = cat_rules_applied

    # ------------------------------------------------------------------ #
    # 7. Geography rules
    # ------------------------------------------------------------------ #
    geo_rules_applied: list[str] = []
    for gr in store.policies.get("geography_rules", []):
        gr_countries = gr.get("countries", [gr.get("country")] if gr.get("country") else [])
        if any(c in delivery_countries for c in gr_countries if c):
            geo_rules_applied.append(gr["rule_id"])
            _apply_geography_rule(state, gr, delivery_countries)
    state.geography_rules_applied = geo_rules_applied

    # ------------------------------------------------------------------ #
    # 8. Influencer campaign brand safety (ER-007)
    # ------------------------------------------------------------------ #
    if d.category_l2 == "Influencer Campaign Management":
        state.add_escalation(
            "ER-007",
            (
                "Influencer Campaign Management requires brand-safety review before final award. "
                "Human approval is mandatory per CR-010."
            ),
            "Marketing Governance Lead",
            blocking=True,
        )

    state.log(
        "state3",
        "complete",
        f"Eligible suppliers: {len(state.eligible_suppliers)}, escalations: {len(state.escalations)}",
    )
    return state


# ------------------------------------------------------------------ #
# Helper: apply a single category rule
# ------------------------------------------------------------------ #

def _apply_category_rule(state: GlobalState, cr: dict) -> None:
    rule_id = cr["rule_id"]
    rule_text = cr.get("rule_text", "")
    d = state.extracted_data

    if rule_id == "CR-001":
        if d.budget_amount and d.budget_amount >= 100_000 and d.currency in ("EUR", "CHF"):
            state.add_validation_issue(
                severity="medium",
                type_="mandatory_comparison",
                description=f"CR-001: {rule_text} Budget {d.budget_amount:,.2f} {d.currency} meets threshold.",
                action="Ensure at least 3 compliant supplier options are compared.",
            )
    elif rule_id == "CR-002":
        if d.quantity and d.quantity > 50:
            state.add_validation_issue(
                severity="medium",
                type_="engineering_spec_review",
                description=f"CR-002: {rule_text} Quantity {d.quantity} > 50 units.",
                action="Obtain compatibility review from engineering or CAD lead before award.",
            )
    elif rule_id == "CR-007":
        if d.quantity and d.quantity > 60:
            state.add_validation_issue(
                severity="medium",
                type_="cv_review",
                description=f"CR-007: {rule_text} Quantity {int(d.quantity)} days > 60.",
                action="Request named consultant CVs or equivalent capability profiles.",
            )
    elif rule_id == "CR-005":
        if d.budget_amount and d.budget_amount >= 250_000:
            state.add_validation_issue(
                severity="medium",
                type_="security_review",
                description=f"CR-005: {rule_text} Budget {d.budget_amount:,.2f} {d.currency} meets threshold.",
                action="Initiate security architecture review before award.",
            )


# ------------------------------------------------------------------ #
# Helper: apply a single geography rule
# ------------------------------------------------------------------ #

def _apply_geography_rule(state: GlobalState, gr: dict, delivery_countries: list[str]) -> None:
    rule_id = gr.get("rule_id", "GR-?")
    rule_text = gr.get("rule_text") or gr.get("rule", "")
    d = state.extracted_data

    if rule_id == "GR-001" and "CH" in delivery_countries and d.data_residency_constraint:
        state.add_validation_issue(
            severity="high",
            type_="sovereign_preference",
            description=f"GR-001: {rule_text}",
            action="Evaluate only sovereign or approved providers for Swiss data residency.",
        )
    elif rule_id == "GR-005" and d.category_l1 in ("IT", "Professional Services"):
        state.add_validation_issue(
            severity="medium",
            type_="data_sovereignty_us",
            description=f"GR-005: {rule_text}",
            action="Verify supplier US data centre availability for sensitive workloads.",
        )
    elif rule_id == "GR-006" and d.category_l1 in ("IT", "Professional Services"):
        state.add_validation_issue(
            severity="medium",
            type_="data_sovereignty_apac",
            description=f"GR-006: {rule_text}",
            action="Verify supplier in-country data residency for regulated APAC categories.",
        )
    elif rule_id == "GR-007" and d.category_l1 in ("IT", "Professional Services"):
        state.add_validation_issue(
            severity="medium",
            type_="data_sovereignty_mea",
            description=f"GR-007: {rule_text}",
            action="Validate supplier PDPL/POPIA compliance documentation before award.",
        )
    elif rule_id == "GR-008":
        state.add_validation_issue(
            severity="medium",
            type_="data_sovereignty_latam",
            description=f"GR-008: {rule_text}",
            action="Ensure data processing agreements (DPA) are in place before contract signature.",
        )
