# **Architecture Baseline: Neuro-Symbolic Sourcing Workflow**

**Project:** Audit-Ready Autonomous Sourcing Agent

**Scope:** State 1 to State 6 (End-to-End Pipeline)

**Design Principle:** **Neuro-Symbolic Architecture ("LLM as a Parser, Code as the Decider")**. The system is strictly divided into two distinct phases to guarantee 100% deterministic policy enforcement:

* **Phase 1 (Neural \- State 1):** An AI Agent receives intentionally messy, human-written natural language input. Using a "planning" mode, the agent performs a single-pass extraction to fully populate a strictly typed JSON schema, outputting a confidence score per field and detecting text-vs-field contradictions. After extraction, the human reviews and approves the mapped fields — this is the single HITL touchpoint. It performs *zero* policy or sourcing decision-making.
* **Phase 2 (Symbolic \- States 2-6):** A traditional, deterministic Python script (Directed Acyclic Graph) takes that JSON and runs it against policies.json and categories.csv, dynamically building a Log Trace with each step. If an auditor asks why a supplier was blocked, the system points directly to a hardcoded logic gate, not a probabilistic AI prompt.

## **0\. The Global State Object (Payload)**

Data passed sequentially through all states must conform to a strict schema. The pipeline mutates this object or halts if an escalation is triggered.

```json
{
  "request_id": "REQ-000001",
  "raw_request": {},
  "extracted_data": {},
  "fx_rates": {},
  "eligible_suppliers": [],
  "calculated_metrics": {},
  "audit_log": [],
  "escalation": null
}
```

**Field notes:**
- `raw_request`: Original unstructured input. Read only by State 1; never accessed after Phase 1 completes.
- `extracted_data`: Output from Phase 1 (State 1) Pydantic Schema. Must include `contradictions_detected: []` and `field_confidence: {}` as top-level fields.
- `fx_rates`: Fixed EUR/CHF/USD conversion table declared from system config (e.g., `{EUR_CHF: 0.93, EUR_USD: 1.08}`). Logged per request so auditors can reproduce any currency conversion.
- `eligible_suppliers`: Array of supplier objects, shrinks as filters apply.
- `calculated_metrics`: Tiers, Total Cost, Required Quotes.
- `audit_log`: Append-only log of every inclusion/exclusion decision.
- `escalation`: Populated only if a terminal ER-rule is triggered.

## **State 1: Neural Data Extraction (Phase 1\)**

**Objective:** Use an AI agent to parse messy human input, extract structured data in a single pass, detect contradictions, and obtain human approval of the mapped fields. Do not allow the LLM to filter suppliers or evaluate policies.

**Input:** Intentionally messy, human-written natural language input

### **Execution Logic:**

1. **Intake & Translation:** The agent receives the unstructured, messy natural language request (handling spelling errors, ambiguities, and non-English languages).
2. **Single-Pass Extraction & Confidence Scoring:** The agent maps the unstructured intent against the strict Pydantic JSON model (e.g., standardizing currencies, extracting integer quantities, mapping to `category_l1/l2`). For every extracted field, the agent outputs a `field_confidence` score (0.0–1.0) alongside the extracted value. There is no iterative dialogue loop — extraction is performed in one pass.
3. **Text-vs-Field Contradiction Detection:** The LLM compares the numeric `quantity` field against the quantity implied in `request_text` and compares `budget_amount` currency against the region's standard currency. Output: `contradictions_detected: [{field, text_value, field_value, severity}]` where `severity` is either `"hard"` or `"soft"`. This is the only point in the pipeline where `raw_request` is read.
4. **User Approval:** Present the mapped fields (`category_l1/l2`, `quantity`, `budget_amount`, `delivery_countries`) and all `contradictions_detected` to the user for review and confirmation. The user may correct any mapped value. Only after explicit approval does schema validation run and the payload pass to Phase 2. Human-confirmed category mappings lock in here and are not re-evaluated downstream.

### **Transition Rules:**

* **IF** schema validation fails after user approval:
  * **Action:** Halt pipeline.
  * **Transition to State 6 (Escalation):** Trigger ER-001 (Target: Requester for clarification).
* **IF** any field has `field_confidence < 0.7` and the user did not correct it during the approval step:
  * **Action:** Halt pipeline.
  * **Transition to State 6 (Escalation):** Trigger ER-001. Append the specific low-confidence field names and scores to `audit_log`.
* **ELSE:** Transition to Phase 2 (State 2).

## **State 2: Completeness Validation (Phase 2 Begins)**

**Objective:** Ensure the extracted data contains the minimum viable parameters to execute a sourcing event. State 2 reads only `extracted_data` — it never accesses `raw_request` or `request_text`.

**Input:** `extracted_data`

### **Execution Logic:**

1. **Null Value Check:** Verify that `category_l1`, `category_l2`, `delivery_countries`, `quantity`, and `budget_amount` are not null.
2. **Contradiction Severity Gate:** Read `extracted_data.contradictions_detected` (populated by State 1):
   * `severity == "hard"`: Halt pipeline → trigger ER-001. Append the contradiction details to `audit_log`.
   * `severity == "soft"`: Log the contradiction to `audit_log` with a warning flag. Pipeline continues.
3. **Threshold Validation:** Ensure `required_by_date` is in the future.

### **Transition Rules:**

* **IF** any required field is null, or any `hard` contradiction is found:
  * **Action:** Halt pipeline.
  * **Transition to State 6 (Escalation):** Trigger ER-001 (Target: Requester). Append specifics to `audit_log`.
* **ELSE:** Transition to State 3\.

## **State 3: Policy & Compliance Enforcement**

**Objective:** Cross-reference request against policies.json and suppliers.csv to build a compliant baseline shortlist.

**Input:** `extracted_data`, initial load of all suppliers in categories.csv matching `category_l1/l2`.

### **Execution Logic:**

0. **Preferred Supplier Validity Check** *(executed before any geographic filter)*:
   * If `preferred_supplier_mentioned` is not null, perform three independent checks and log each result individually:
     * **Category mismatch:** Check if the supplier exists in `suppliers.csv` for this exact `category_l2`. If not → append to `audit_log`: `"[SUPPLIER]: Preference discarded. Reason: Registered for [actual_category], not [requested_category]."`
     * **Geographic mismatch:** Check if the supplier's `service_regions` covers all `delivery_countries`. If not → append to `audit_log` listing the exact missing countries.
     * **Restriction check:** Check the supplier's `is_restricted` flag against `policies.json restricted_suppliers`. If restricted → trigger ER-002, append to `audit_log` with the exact restriction rule and scope.

1. **Geographic & Registration Filter:**
   * Filter suppliers where `service_regions` does not intersect with all `delivery_countries`.
   * *Trigger check:* If 0 suppliers remain, trigger ER-008 (Target: Regional Compliance Lead).
2. **Geography Rules (Data Residency):**
   * Lookup `delivery_countries` in `policies.json -> geography_rules`.
   * *Trigger check:* If `data_residency_constraint == True`, but no remaining suppliers meet local hosting rules, trigger ER-005 (Target: Security/Compliance).
3. **Category Rules:**
   * Lookup `category_l1` in `policies.json -> category_rules`.
   * *Trigger check:* If category is "Marketing" and requires brand safety review that cannot be automated, trigger ER-007 (Target: Marketing Governance Lead).
4. **Restriction Filter:**
   * Evaluate remaining suppliers against `policies.json -> restricted_suppliers` and `is_restricted` flag. Apply specific rules (Global vs. Country-scoped).
   * *Action:* Remove all restricted suppliers from `eligible_suppliers`.

### **Transition Rules:**

* **IF** `eligible_suppliers` count == 0:
  * **Action:** Halt pipeline.
  * **Transition to State 6 (Escalation):** Trigger ER-004 (Target: Head of Category).
* **ELSE:** Transition to State 4\.

## **State 4: Commercial Evaluation**

**Objective:** Calculate exact financials, score all compliant suppliers, and then evaluate escalation thresholds against the full ranked shortlist.

**Input:** `eligible_suppliers`, `pricing.csv`, `policies.json -> approval_thresholds`, `fx_rates` from Global State Object.

**FX Rate Config:** Currency conversions use the fixed table declared in `fx_rates` (e.g., `{EUR_CHF: 0.93, EUR_USD: 1.08}`). The exact rate used is logged to `audit_log` for every conversion. Live FX APIs are not used.

### **Execution Logic:**

1. **Capacity Check:**
   * Compare `quantity` against `capacity_per_month` for each supplier.
   * Suppliers with `capacity_per_month == 0` for the category are removed from `eligible_suppliers`.
   * Suppliers where `capacity_per_month < quantity` but `> 0` are **not** removed. Instead, log: `"SUP-XXXX: Partial capacity. Can supply [n] of [requested] units."` and flag them as `capacity_status: partial` in `eligible_suppliers`.
   * *Trigger check:* ER-006 triggers only if ALL remaining suppliers have `capacity_status: none` (i.e., all have `capacity_per_month == 0`). Target: Sourcing Excellence Lead.
2. **Pricing Tier Calculation:**
   * For each remaining supplier, look up `pricing.csv`. Match `quantity` to `min_quantity / max_quantity` bounds.
   * Determine `lead_time_days`. If `required_by_date` is shorter than standard lead time, apply `expedited_unit_price` (if available).
   * Calculate: `total_value = unit_price * quantity`.
3. **Threshold & Quote Validation:**
   * Convert `total_value` to policy currency using `fx_rates`. Log the rate used to `audit_log`.
   * Lookup `policies.json -> approval_thresholds` to determine Tier (1 to 5) and Required Quotes (1 to 3).
4. **Supplier Scoring Matrix:**
   * **Dynamic weight set:** Select weights based on request flags:
     * Default: `w_price = 0.50`, `w_esg = 0.10`
     * If `esg_requirement == True`: `w_price = 0.35`, `w_esg = 0.25`
     * Quality and risk weights are fixed: `w_quality = 0.25`, `w_risk = 0.15`
     * Weights always sum to 1.0.
   * **Normalization formulas:**
     * `price_score = min_price_in_set / supplier_price` (lower price → score approaches 1.0)
     * `quality_norm = quality_score / 100`
     * `risk_norm = 1 - (risk_score / 100)` (lower risk → higher normalized score)
     * `esg_norm = esg_score / 100`
   * **Scoring formula:**
     * `Score = (price_score * w_price) + (quality_norm * w_quality) + (risk_norm * w_risk) + (esg_norm * w_esg)`
   * **Incumbent bonus:** If `incumbent_supplier` matches a supplier ID, add `incumbent_bonus = +5` to that supplier's raw score. Log this addition explicitly to `audit_log`.
   * **Historical precedent flag:** After scoring, cross-reference `historical_awards.csv`. If the top-ranked supplier matches the most frequent prior award winner for this `category_l2` + country pair, set `historical_precedent: true` on that supplier entry (informational flag only — not a score modifier).
   * Log all raw values, normalized values, weight set used, incumbent bonus (if applied), and final score per supplier to `audit_log`.
   * Sort `eligible_suppliers` by highest score. Flag the #1 ranked supplier as "Recommended Award".
5. **Escalation Threshold Evaluation** *(executed after full scoring and ranking)*:
   * *Trigger check:* If the required approval tier is Tier 4 or 5 (e.g., > 500K EUR), trigger ER-003 (Target: Head of Strategic Sourcing).
   * *Trigger check:* If Required Quotes == 3, but `eligible_suppliers` count < 3, trigger ER-004 (Target: Head of Category).
   * Any escalation payload sent to a human includes the full ranked shortlist from Step 4.

### **Transition Rules:**

* **IF** an ER- rule is triggered: Transition to State 6\.
* **ELSE:** Transition to State 5\.

## **State 5: Audit Output Generation (Terminal: Success)**

**Objective:** Format the executed logic into a transparent, human-readable justification report.

**Input:** Fully populated Global State Object.

### **Execution Logic:**

1. Generate the **Structured Shortlist**: Print the top N suppliers (based on Required Quotes from State 4).
2. Generate the **Financial Breakdown**: Print the matched pricing tier, unit cost, extended cost, standard vs. expedited lead time, and the FX rate applied (from `fx_rates`).
3. Generate the **Audit Provenance Tree**: Iterate through the `audit_log` array. For every supplier in the initial dataset, print the exact reason for inclusion/exclusion (e.g., *"SUP-0014: Excluded at State 3. Reason: Fails CH Data Residency Policy"*). For each recommended supplier, append a **Historical Precedent Note**: surface whether the recommendation matches prior awards for this `category_l2` + country pair (e.g., *"SUP-0021: Recommended. 4 of 6 historical awards for Cloud Compute in DE went to this supplier."*).
4. **Output:** Return the final JSON payload to the UI or calling system.

## **State 6: Escalation Terminal (Terminal: Failure)**

**Objective:** Safely halt the automation and format a routing ticket for a human.

**Input:** Global State Object containing an `escalation_trigger`.

### **Execution Logic:**

1. Extract the ER-XXX code and the Target Persona.
2. Format the Context Payload: Provide the human with exactly *why* it failed, utilizing the `audit_log` up to the point of failure.
   * *Example Output:* "Escalation to **Procurement Manager** (Rule ER-002). Reason: Requester specified preferred supplier 'TechCorp', but TechCorp is flagged as `is_restricted` for L2 Category 'Laptops' in region 'FR'."
3. **Output:** Return Escalation JSON payload. Pipeline terminates.
   * The escalation JSON must include:
     * `resume_from_state: <state_number>` — the state the pipeline re-enters after human resolution (e.g., ER-002 resolution re-enters at State 3; ER-001 resolution re-enters at State 2).
     * `resolution_required: "<what the human must provide>"` — a plain-language description of the input or decision required from the human reviewer.
