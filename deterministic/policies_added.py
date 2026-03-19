import json

def load_json(path):
    with open(path, "r") as f:
        return json.load(f)


def match_region(request_regions, supplier_region_scope):
    if not supplier_region_scope:
        return True
    return any(r in supplier_region_scope for r in request_regions)


def match_country(request_countries, restriction_scope):
    if not restriction_scope:
        return False
    if "all" in restriction_scope:
        return True
    return any(c in restriction_scope for c in request_countries)


def find_approval_threshold(policies, request, supplier):
    currency = request["currency"]
    total_value = supplier.get("selected_total_price", supplier.get("total_price"))

    for t in policies["approval_thresholds"]:
        if t.get("currency") != currency:
            continue

        min_val = t.get("min_amount", t.get("min_value"))
        max_val = t.get("max_amount", t.get("max_value"))

        if max_val is None:
            max_val = float("inf")

        if min_val <= total_value <= max_val:
            return t

    return None


def evaluate_policies(filtered_suppliers, policies, request):
    enriched = []    

    for supplier in filtered_suppliers:
        approval = find_approval_threshold(policies, request, supplier)
        supplier_id = supplier["supplier_id"]

        policy_result = {
            "approval": approval,
            "preferred_status": None,
            "restrictions": [],
            "category_rules": [],
            "geography_rules": [],
            "escalations": []
        }

        # ---------------------------
        # Preferred Supplier Check
        # ---------------------------
        preferred_matches = [
            p for p in policies["preferred_suppliers"]
            if p["supplier_id"] == supplier_id
            and p["category_l1"] == request["category_l1"]
            and p["category_l2"] == request["category_l2"]
            and match_region(request["region"], p.get("region_scope", []))
        ]

        if preferred_matches:
            policy_result["preferred_status"] = {
                "is_preferred": True,
                "policy": preferred_matches[0]
            }
        else:
            policy_result["preferred_status"] = {
                "is_preferred": False
            }

        # ---------------------------
        # Restricted Supplier Check
        # ---------------------------
        restrictions = [
            r for r in policies["restricted_suppliers"]
            if r["supplier_id"] == supplier_id
            and r["category_l1"] == request["category_l1"]
            and r["category_l2"] == request["category_l2"]
            and match_country(request["delivery_countries"], r.get("restriction_scope", []))
        ]

        if restrictions:
            policy_result["restrictions"] = restrictions

        # ---------------------------
        # Category Rules
        # ---------------------------
        category_rules = [
            r for r in policies["category_rules"]
            if r["category_l1"] == request["category_l1"]
            and r["category_l2"] == request["category_l2"]
        ]

        policy_result["category_rules"] = category_rules

        # ---------------------------
        # Geography Rules
        # ---------------------------
        geo_rules = []

        for rule in policies["geography_rules"]:
            if "country" in rule:
                if rule["country"] in request["delivery_countries"]:
                    geo_rules.append(rule)

            elif "countries" in rule:
                if any(c in rule["countries"] for c in request["delivery_countries"]):
                    geo_rules.append(rule)

        policy_result["geography_rules"] = geo_rules

        # ---------------------------
        # Escalation Logic
        # ---------------------------
        if restrictions and policy_result["preferred_status"]["is_preferred"]:
            policy_result["escalations"].append({
                "trigger": "preferred_supplier_restricted",
                "action": "Procurement Manager"
            })

        if not filtered_suppliers:
            policy_result["escalations"].append({
                "trigger": "no_compliant_supplier_found",
                "action": "Head of Category"
            })

        # ---------------------------
        # Final Recommendation Note
        # ---------------------------
        recommendation = []

        if restrictions:
            recommendation.append("⚠️ Supplier is restricted")

        if policy_result["preferred_status"]["is_preferred"]:
            recommendation.append("✅ Preferred supplier")

        if approval:
            recommendation.append(f"Approval required: {approval['threshold_id']}")

        supplier["policies"] = policy_result
        supplier["recommendation_note"] = " | ".join(recommendation)

        enriched.append(supplier)

    return enriched


def run_policy_enrichment(filtered_path, policies_path, output_path, request):
    filtered_data = load_json(filtered_path)
    policies = load_json(policies_path)

    suppliers = filtered_data["suppliers"]

    enriched = evaluate_policies(suppliers, policies, request)

    with open(output_path, "w") as f:
        json.dump({"suppliers": enriched}, f, indent=2)

    print(f"Policy enrichment complete. Output written to {output_path}")


# ---------------------------
# TEST RUN
# ---------------------------
if __name__ == "__main__":

    sample_request = {
        "request_id": "REQ-000005",
        "created_at": "2026-03-27T08:01:00Z",
        "request_channel": "teams",
        "request_language": "de",
        "business_unit": "Data & Analytics",
        "country": "DE",
        "site": "Hamburg",
        "requester_id": "USR-3005",
        "requester_role": "Workplace Lead",
        "submitted_for_id": "USR-8005",
        "category_l1": "IT",
        "category_l2": "Desktop Workstations",
        "title": "High-performance desktop workstation order",
        "request_text": "Need 50 desktop workstations for design and data teams. Delivery required by 2026-06-03. Budget is approximately 120 000.00 EUR.",
        "currency": "EUR",
        "budget_amount": 1200000,
        "quantity": 50,
        "unit_of_measure": "device",
        "required_by_date": "2026-06-03",
        "preferred_supplier_mentioned": "HP Enterprise Devices",
        "incumbent_supplier": "Lenovo Commercial EU",
        "contract_type_requested": "purchase",
        "delivery_countries": [
            "CH",
            "DE",
            "NL"
            ],
        "region": ["EU", "CH"]
    }

    run_policy_enrichment(
        "deterministic\\filtered_suppliers.json",
        "data\\policies.json",
        f"deterministic\\enriched_suppliers{sample_request["request_id"]}.json",
        sample_request
    )