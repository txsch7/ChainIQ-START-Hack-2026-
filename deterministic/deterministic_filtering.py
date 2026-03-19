import pandas as pd
import json
from datetime import datetime

pricing_csv = "data\pricing.csv"

suppliers_csv = "data\suppliers.csv"

def format_supplier_output(df, request, max_lead_days):
    qty = request["quantity"]
    budget_per_unit = request["budget_amount"] / qty
    
    results = []

    for _, row in df.iterrows():
        preferred = request["preferred_supplier_mentioned"]==row["supplier_name"]
        incumbent = request["incumbent_supplier"]==row["supplier_name"]
        # Determine which pricing was applied
        if (
            row["standard_lead_time_days"] <= max_lead_days and
            row["unit_price"] <= budget_per_unit
        ):
            applied_price = row["unit_price"]
            pricing_type = "standard"
        else:
            applied_price = row["expedited_unit_price"]
            pricing_type = "expedited"

        # Pricing tier label
        tier_label = f"{int(row['min_quantity'])}-{int(row['max_quantity'])} units"

        supplier_output = {
            "rank": "???",
            "supplier_id": row["supplier_id"],
            "supplier_name": row.get("supplier_name", "UNKNOWN"),  # if not in CSV
            "region": row.get("region"),
            "preferred": preferred,
            "incumbent": incumbent,
            "pricing_tier_applied": tier_label,
            "capacity_per_month": row.get("capacity_per_month"),
            "currency": row.get("currency"),
            "unit_price": round(row["unit_price"], 2),
            "total_price": round(row["unit_price"] * qty, 2),

            "standard_lead_time_days": int(row["standard_lead_time_days"]),
            "expedited_lead_time_days": int(row["expedited_lead_time_days"]),

            "expedited_unit_price": round(row["expedited_unit_price"], 2),
            "expedited_total": round(row["expedited_unit_price"] * qty, 2),

            "selected_pricing_type": pricing_type,
            "selected_unit_price": round(applied_price, 2),
            "selected_total_price": round(applied_price * qty, 2),
            "quality_score": row.get("quality_score"),
            "risk_score": row.get("risk_score"),
            "esg_score": row.get("esg_score"),
            "restricted": row.get("is_restricted")
            #"covers_delivery_country": "???", --> brauchen wir nicht, weil schon gegeben
        }

        results.append(supplier_output)

    return results

def filter_pricing(request, pricing_csv_path=pricing_csv, supplier_csv_path=suppliers_csv, output_path="deterministic\\filtered_suppliers.json", log_path="deterministic\\filter_log.json"):
    df = pd.read_csv(pricing_csv_path)
    suppliers_df = pd.read_csv(supplier_csv_path)

    log = {
        "request": request,
        "steps": [],
        "status": "running"
    }

    def log_step(message, df_before, df_after):
        step = {
            "message": message,
            "before_count": len(df_before),
            "after_count": len(df_after),
            "timestamp": datetime.utcnow().isoformat()
        }

        if len(df_after) < 3:
            step["warning"] = "Supplier pool dropped below 3"

        if len(df_after) == 0:
            step["error"] = "No suppliers remaining after this step"

        log["steps"].append(step)

    def stop_with_escalation(reason):
        log["status"] = "failed"
        log["escalation"] = {
            "reason": reason,
            "action": "ESCALATE_TO_???",
            "placeholder": True
        }

        with open(log_path, "w") as f:
            json.dump(log, f, indent=2)

        with open(output_path, "w") as f:
            json.dump({"suppliers": []}, f, indent=2)

        return None

    # ---------------------------
    # FILTER PIPELINE
    # ---------------------------

    # 1. category_l1
    before = df.copy()
    df = df[df["category_l1"] == request["category_l1"]]
    log_step(f"Limiting category_l1 to {request['category_l1']}", before, df)

    if df.empty:
        return stop_with_escalation("No suppliers after category_l1 filter")

    # 2. category_l2
    before = df.copy()
    df = df[df["category_l2"] == request["category_l2"]]
    log_step(f"Limiting category_l2 to {request['category_l2']}", before, df)

    if df.empty:
        return stop_with_escalation("No suppliers after category_l2 filter")

    # 3. region
    before = df.copy()
    
    df = df[df["region"].isin(request["region"])]

    log_step(f"Limiting region to {request['region']}", before, df)

    if df.empty:
        return stop_with_escalation("No suppliers after region filter")

    # 4. quantity range
    qty = request["quantity"]
    before = df.copy()
    df = df[(df["min_quantity"] <= qty) & (df["max_quantity"] >= qty)]
    log_step(f"Filtering suppliers supporting quantity {qty}", before, df)

    if df.empty:
        return stop_with_escalation("No suppliers after quantity filter")

    # 5. lead time + pricing (standard first)
    budget_per_unit = request["budget_amount"] / qty
    #buffer_per_unit = budget_per_unit * 1.05 --> vielleicht als Lösungsansatz später
    # ---------------------------
    # DATE CALCULATION
    # ---------------------------
   
    # 1. Convert to datetime
    created_at = pd.to_datetime(request["created_at"])
    required_by = pd.to_datetime(request["required_by_date"])

    # 2. STRIP THE TIMEZONE (The Fix...maybe)
    # This converts '2026-04-19T15:25:00Z' to just '2026-04-19 15:25:00'
    if created_at.tz is not None:
        created_at = created_at.tz_localize(None)

    if required_by.tz is not None:
        required_by = required_by.tz_localize(None)

    # 3. Now you can safely subtract
    lead_time_required = (required_by - created_at).days

    # Safety check: if the date is in the past, lead_time might be negative
    if lead_time_required < 0:
        return stop_with_escalation(f"Required date {request['required_by_date']} is in the past.")

    before = df.copy()

    standard_df = df[
        (df["standard_lead_time_days"] <= lead_time_required)
    ]

    if not standard_df.empty:
        standard_price_df = standard_df[
            (df["unit_price"] <= budget_per_unit)
        ]
        if not standard_price_df.empty:
            df = standard_price_df
            log_step(
                f"Limiting to standard lead time <= {lead_time_required} days and price <= {budget_per_unit:.2f}",
                before,
                df
            )
        else:
            return stop_with_escalation("No suppliers after standard lead time + pricing filter")
    else:
        # fallback to expedited
        expedited_df = df[
            (df["expedited_lead_time_days"] <= lead_time_required) &
            (df["expedited_unit_price"] <= budget_per_unit)
        ]

        log_step(
            f"No suppliers met standard lead time {lead_time_required} days and/or budget of {budget_per_unit} per unit (total: {request["budget_amount"]}), checking expedited options",
            before,
            expedited_df
        )

        if expedited_df.empty:
            return stop_with_escalation("No suppliers after expedited lead time + pricing filter")

        df = expedited_df
    #Enrich with data from supplier.csv
    df = df.merge(
    suppliers_df[
        [
            "supplier_id",
            "category_l1",
            "category_l2",
            "supplier_name",
            "quality_score",
            "risk_score",
            "esg_score",
            "is_restricted", 
            "capacity_per_month"
        ]
        ],
        on=["supplier_id", "category_l1", "category_l2"],
        how="left"
    )

    # ---------------------------
    # FINAL OUTPUT
    # ---------------------------


    formatted_result = format_supplier_output(df, request, lead_time_required)

    log["status"] = "success"
    log["final_supplier_count"] = len(formatted_result)

    with open(output_path, "w") as f:
        json.dump({"suppliers": formatted_result}, f, indent=2)

    with open(log_path, "w") as f:
        json.dump(log, f, indent=2)

    return formatted_result

# --- TEST BLOCK ---
if __name__ == "__main__":

    # 1. Define a sample request
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
        "budget_amount": 620000,
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

    # 3. Run the function
    print("Running filter_pricing...")
    results = filter_pricing(sample_request, output_path=f"deterministic\\filtered_suppliers_{sample_request["request_id"]}.json", log_path=f"deterministic\\filter_log_{sample_request["request_id"]}.json")

    if results:
        print(f"Success! Found {len(results)} suppliers.")
        print(f"First match: {results[0]['supplier_name']}")
    else:
        print("No suppliers matched. Check filter_log.json for details.")