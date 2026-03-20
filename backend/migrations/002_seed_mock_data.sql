-- =============================================================================
-- Seed: request_records — ChainIQ ultra-realistic procurement scenarios
-- 12 scenarios covering all pipeline outcomes (completed / escalated / resolved)
-- =============================================================================

BEGIN;

-- --------------------------------------------------------------
-- REQ-2026-001 | IT / Laptops | Germany | 50 units | completed
-- Standard laptop fleet refresh. Dell incumbent wins on price + score.
-- --------------------------------------------------------------
INSERT INTO request_records
  (request_id, status, created_at, updated_at,
   extracted_data, response_json, escalations,
   resume_from, resolved_by, resolution_note)
VALUES (
  'REQ-2026-001', 'completed',
  '2026-03-01 09:14:00+00', '2026-03-01 09:14:38+00',
  '{
    "request_id": "REQ-2026-001",
    "created_at": "2026-03-01T09:14:00Z",
    "request_channel": "portal",
    "request_language": "en",
    "business_unit": "Digital Workplace",
    "country": "DE",
    "site": "Munich",
    "requester_id": "USR-4101",
    "requester_role": "IT Operations Lead",
    "submitted_for_id": "USR-8201",
    "category_l1": "IT",
    "category_l2": "Laptops",
    "title": "Laptop fleet refresh Q1 – Munich office",
    "request_text": "Need 50 standard business laptops for the Munich office. Budget around EUR 36 000. Please keep Dell Enterprise Europe as incumbent. Required by end of March.",
    "currency": "EUR",
    "budget_amount": 36000.00,
    "quantity": 50.0,
    "unit_of_measure": "unit",
    "required_by_date": "2026-03-28",
    "preferred_supplier_mentioned": "Dell Enterprise Europe",
    "incumbent_supplier": "Dell Enterprise Europe",
    "contract_type_requested": "purchase",
    "delivery_countries": ["DE"],
    "data_residency_constraint": false,
    "esg_requirement": false,
    "status": "new",
    "scenario_tags": ["standard", "incumbent"]
  }'::jsonb,
  '{
    "request_id": "REQ-2026-001",
    "processed_at": "2026-03-01T09:14:38Z",
    "request_interpretation": {
      "category_l1": "IT",
      "category_l2": "Laptops",
      "quantity": 50.0,
      "unit_of_measure": "unit",
      "budget_amount": 36000.00,
      "currency": "EUR",
      "delivery_countries": ["DE"],
      "required_by_date": "2026-03-28",
      "data_residency_required": false,
      "esg_requirement": false,
      "preferred_supplier_stated": "Dell Enterprise Europe",
      "incumbent_supplier": "Dell Enterprise Europe",
      "request_language": "en",
      "days_until_required": 27
    },
    "validation": {
      "completeness": "pass",
      "issues_detected": [
        {
          "issue_id": "V-001",
          "severity": "medium",
          "type": "engineering_spec_review",
          "description": "CR-002: Hardware orders above 50 units require compatibility review. Quantity 50 units meets threshold.",
          "action_required": "Obtain compatibility review from engineering or CAD lead before award."
        }
      ]
    },
    "policy_evaluation": {
      "approval_threshold": {
        "rule_applied": "AT-002",
        "basis": "Estimated contract value range: EUR 36,000.00–39,000.00",
        "quotes_required": 2,
        "approvers": ["business", "procurement"],
        "deviation_approval": ["Procurement Manager"]
      },
      "preferred_supplier": {
        "supplier": "Dell Enterprise Europe",
        "supplier_id": "SUP-0001",
        "status": "eligible",
        "is_preferred": true,
        "covers_delivery_country": true,
        "is_restricted": false,
        "policy_note": "Dell Enterprise Europe is a policy-preferred supplier for Laptops in this region. Preferred status means inclusion in the comparison — it does not mandate single-source selection."
      },
      "restricted_suppliers": {
        "SUP-0008": {
          "supplier_name": "Computacenter Devices",
          "restricted": true,
          "reason": "Restricted for selected categories and countries in policy set"
        }
      },
      "category_rules_applied": ["CR-002"],
      "geography_rules_applied": []
    },
    "supplier_shortlist": [
      {
        "rank": 1,
        "supplier_id": "SUP-0001",
        "supplier_name": "Dell Enterprise Europe",
        "preferred": true,
        "incumbent": true,
        "pricing_tier_applied": "0–100 units",
        "unit_price_eur": 720.00,
        "total_price_eur": 36000.00,
        "standard_lead_time_days": 10,
        "expedited_lead_time_days": 5,
        "expedited_unit_price_eur": 810.00,
        "expedited_total_eur": 40500.00,
        "quality_score": 87,
        "risk_score": 16,
        "esg_score": 73,
        "composite_score": 94.5,
        "policy_compliant": true,
        "covers_delivery_country": true,
        "historical_precedent": true,
        "recommendation_note": "Incumbent supplier with established delivery capability. Prior award history: AWD-2025-0041, AWD-2025-0038 for Laptops. Policy-preferred supplier. Total price EUR 36,000.00 (composite score: 94.5)"
      },
      {
        "rank": 2,
        "supplier_id": "SUP-0003",
        "supplier_name": "Lenovo Commercial EU",
        "preferred": true,
        "incumbent": false,
        "pricing_tier_applied": "0–100 units",
        "unit_price_eur": 740.00,
        "total_price_eur": 37000.00,
        "standard_lead_time_days": 12,
        "expedited_lead_time_days": 6,
        "expedited_unit_price_eur": 830.00,
        "expedited_total_eur": 41500.00,
        "quality_score": 83,
        "risk_score": 28,
        "esg_score": 74,
        "composite_score": 66.25,
        "policy_compliant": true,
        "covers_delivery_country": true,
        "historical_precedent": false,
        "recommendation_note": "Policy-preferred supplier. Total price EUR 37,000.00 (composite score: 66.25)"
      },
      {
        "rank": 3,
        "supplier_id": "SUP-0002",
        "supplier_name": "HP Enterprise Devices",
        "preferred": true,
        "incumbent": false,
        "pricing_tier_applied": "0–100 units",
        "unit_price_eur": 768.00,
        "total_price_eur": 38400.00,
        "standard_lead_time_days": 14,
        "expedited_lead_time_days": 7,
        "expedited_unit_price_eur": 860.00,
        "expedited_total_eur": 43000.00,
        "quality_score": 85,
        "risk_score": 18,
        "esg_score": 74,
        "composite_score": 62.10,
        "policy_compliant": true,
        "covers_delivery_country": true,
        "historical_precedent": false,
        "recommendation_note": "Policy-preferred supplier. Total price EUR 38,400.00 (composite score: 62.10)"
      },
      {
        "rank": 4,
        "supplier_id": "SUP-0004",
        "supplier_name": "Apple Business Channel",
        "preferred": false,
        "incumbent": false,
        "pricing_tier_applied": "0–100 units",
        "unit_price_eur": 1040.00,
        "total_price_eur": 52000.00,
        "standard_lead_time_days": 8,
        "expedited_lead_time_days": 4,
        "expedited_unit_price_eur": 1160.00,
        "expedited_total_eur": 58000.00,
        "quality_score": 90,
        "risk_score": 22,
        "esg_score": 76,
        "composite_score": 55.80,
        "policy_compliant": true,
        "covers_delivery_country": true,
        "historical_precedent": false,
        "recommendation_note": "Total price EUR 52,000.00 (composite score: 55.80)"
      },
      {
        "rank": 5,
        "supplier_id": "SUP-0007",
        "supplier_name": "Bechtle Workplace Solutions",
        "preferred": true,
        "incumbent": false,
        "pricing_tier_applied": "0–100 units",
        "unit_price_eur": 780.00,
        "total_price_eur": 39000.00,
        "standard_lead_time_days": 11,
        "expedited_lead_time_days": 6,
        "expedited_unit_price_eur": 870.00,
        "expedited_total_eur": 43500.00,
        "quality_score": 82,
        "risk_score": 17,
        "esg_score": 71,
        "composite_score": 53.20,
        "policy_compliant": true,
        "covers_delivery_country": true,
        "historical_precedent": false,
        "recommendation_note": "Policy-preferred supplier. Total price EUR 39,000.00 (composite score: 53.20)"
      }
    ],
    "suppliers_excluded": [
      {
        "supplier_id": "SUP-0008",
        "supplier_name": "Computacenter Devices",
        "reason": "Restricted for Laptops in [\"DE\"]: Restricted for selected categories and countries in policy set"
      }
    ],
    "escalations": [],
    "recommendation": {
      "status": "recommended",
      "winner": "Dell Enterprise Europe",
      "winner_id": "SUP-0001",
      "total_price_eur": 36000.00,
      "rationale": "Incumbent supplier with established delivery capability. Prior award history: AWD-2025-0041, AWD-2025-0038 for Laptops. Policy-preferred supplier. Total price EUR 36,000.00 (composite score: 94.5)"
    },
    "audit_trail": {
      "policies_checked": ["AT-002", "CR-002"],
      "supplier_ids_evaluated": ["SUP-0001", "SUP-0002", "SUP-0003", "SUP-0004", "SUP-0007", "SUP-0008"],
      "pricing_region": "EU",
      "scoring_weights": {"price": 0.40, "quality": 0.25, "risk": 0.20, "esg": 0.15},
      "fx_rates_used": {"EUR_CHF": 0.93, "EUR_USD": 1.08, "CHF_EUR": 1.075, "USD_EUR": 0.926},
      "data_sources_used": ["suppliers.csv", "pricing.csv", "policies.json", "historical_awards.csv"],
      "historical_awards_consulted": true,
      "historical_award_note": "AWD-2025-0041, AWD-2025-0038 show prior awards to Dell Enterprise Europe for Laptops in this region. Prior decision used for pattern context only."
    }
  }'::jsonb,
  '[]'::jsonb,
  NULL, NULL, NULL
);

-- --------------------------------------------------------------
-- REQ-2026-002 | IT / Cloud Compute | Netherlands | ESG req | completed
-- Azure preferred. ESG scoring weights active. 12-month subscription.
-- --------------------------------------------------------------
INSERT INTO request_records
  (request_id, status, created_at, updated_at,
   extracted_data, response_json, escalations,
   resume_from, resolved_by, resolution_note)
VALUES (
  'REQ-2026-002', 'completed',
  '2026-03-03 14:22:00+00', '2026-03-03 14:23:11+00',
  '{
    "request_id": "REQ-2026-002",
    "created_at": "2026-03-03T14:22:00Z",
    "request_channel": "portal",
    "request_language": "en",
    "business_unit": "Regional IT EU",
    "country": "NL",
    "site": "Amsterdam",
    "requester_id": "USR-4102",
    "requester_role": "Infrastructure Manager",
    "submitted_for_id": "USR-8202",
    "category_l1": "IT",
    "category_l2": "Cloud Compute",
    "title": "Cloud compute capacity – 12-month subscription",
    "request_text": "We need cloud compute capacity for 12 months. Budget EUR 120 000. ESG-certified provider mandatory for our sustainability reporting. Prefer Azure Enterprise if commercially competitive.",
    "currency": "EUR",
    "budget_amount": 120000.00,
    "quantity": 12.0,
    "unit_of_measure": "monthly_subscription",
    "required_by_date": "2026-04-01",
    "preferred_supplier_mentioned": "Azure Enterprise",
    "incumbent_supplier": "Azure Enterprise",
    "contract_type_requested": "framework call-off",
    "delivery_countries": ["NL"],
    "data_residency_constraint": false,
    "esg_requirement": true,
    "status": "new",
    "scenario_tags": ["esg", "cloud", "preferred"]
  }'::jsonb,
  '{
    "request_id": "REQ-2026-002",
    "processed_at": "2026-03-03T14:23:11Z",
    "request_interpretation": {
      "category_l1": "IT",
      "category_l2": "Cloud Compute",
      "quantity": 12.0,
      "unit_of_measure": "monthly_subscription",
      "budget_amount": 120000.00,
      "currency": "EUR",
      "delivery_countries": ["NL"],
      "required_by_date": "2026-04-01",
      "data_residency_required": false,
      "esg_requirement": true,
      "preferred_supplier_stated": "Azure Enterprise",
      "incumbent_supplier": "Azure Enterprise",
      "request_language": "en",
      "days_until_required": 29
    },
    "validation": {
      "completeness": "pass",
      "issues_detected": []
    },
    "policy_evaluation": {
      "approval_threshold": {
        "rule_applied": "AT-003",
        "basis": "Estimated contract value range: EUR 105,600.00–120,000.00",
        "quotes_required": 3,
        "approvers": ["procurement"],
        "deviation_approval": ["Head of Category"]
      },
      "preferred_supplier": {
        "supplier": "Azure Enterprise",
        "supplier_id": "SUP-0010",
        "status": "eligible",
        "is_preferred": true,
        "covers_delivery_country": true,
        "is_restricted": false,
        "policy_note": "Azure Enterprise is a policy-preferred supplier for Cloud Compute in this region. Preferred status means inclusion in the comparison — it does not mandate single-source selection."
      },
      "restricted_suppliers": {},
      "category_rules_applied": ["CR-001"],
      "geography_rules_applied": []
    },
    "supplier_shortlist": [
      {
        "rank": 1,
        "supplier_id": "SUP-0010",
        "supplier_name": "Azure Enterprise",
        "preferred": true,
        "incumbent": true,
        "pricing_tier_applied": "0+ units",
        "unit_price_eur": 9200.00,
        "total_price_eur": 110400.00,
        "standard_lead_time_days": 3,
        "expedited_lead_time_days": 1,
        "expedited_unit_price_eur": 10350.00,
        "expedited_total_eur": 124200.00,
        "quality_score": 89,
        "risk_score": 17,
        "esg_score": 71,
        "composite_score": 81.40,
        "policy_compliant": true,
        "covers_delivery_country": true,
        "historical_precedent": true,
        "recommendation_note": "Incumbent supplier with established delivery capability. Prior award history: AWD-2024-0112, AWD-2024-0087 for Cloud Compute. Policy-preferred supplier. Total price EUR 110,400.00 (composite score: 81.4)"
      },
      {
        "rank": 2,
        "supplier_id": "SUP-0013",
        "supplier_name": "OVHcloud Enterprise",
        "preferred": false,
        "incumbent": false,
        "pricing_tier_applied": "0+ units",
        "unit_price_eur": 8800.00,
        "total_price_eur": 105600.00,
        "standard_lead_time_days": 5,
        "expedited_lead_time_days": 2,
        "expedited_unit_price_eur": 9900.00,
        "expedited_total_eur": 118800.00,
        "quality_score": 76,
        "risk_score": 18,
        "esg_score": 82,
        "composite_score": 76.80,
        "policy_compliant": true,
        "covers_delivery_country": true,
        "historical_precedent": false,
        "recommendation_note": "Total price EUR 105,600.00 (composite score: 76.8)"
      },
      {
        "rank": 3,
        "supplier_id": "SUP-0011",
        "supplier_name": "AWS Enterprise EMEA",
        "preferred": false,
        "incumbent": false,
        "pricing_tier_applied": "0+ units",
        "unit_price_eur": 9600.00,
        "total_price_eur": 115200.00,
        "standard_lead_time_days": 3,
        "expedited_lead_time_days": 1,
        "expedited_unit_price_eur": 10800.00,
        "expedited_total_eur": 129600.00,
        "quality_score": 87,
        "risk_score": 16,
        "esg_score": 67,
        "composite_score": 68.20,
        "policy_compliant": true,
        "covers_delivery_country": true,
        "historical_precedent": false,
        "recommendation_note": "Total price EUR 115,200.00 (composite score: 68.2)"
      },
      {
        "rank": 4,
        "supplier_id": "SUP-0012",
        "supplier_name": "Google Cloud Europe",
        "preferred": false,
        "incumbent": false,
        "pricing_tier_applied": "0+ units",
        "unit_price_eur": 9900.00,
        "total_price_eur": 118800.00,
        "standard_lead_time_days": 3,
        "expedited_lead_time_days": 1,
        "expedited_unit_price_eur": 11100.00,
        "expedited_total_eur": 133200.00,
        "quality_score": 89,
        "risk_score": 15,
        "esg_score": 75,
        "composite_score": 65.10,
        "policy_compliant": true,
        "covers_delivery_country": true,
        "historical_precedent": false,
        "recommendation_note": "Total price EUR 118,800.00 (composite score: 65.1)"
      }
    ],
    "suppliers_excluded": [],
    "escalations": [],
    "recommendation": {
      "status": "recommended",
      "winner": "Azure Enterprise",
      "winner_id": "SUP-0010",
      "total_price_eur": 110400.00,
      "rationale": "Incumbent supplier with established delivery capability. Prior award history: AWD-2024-0112, AWD-2024-0087 for Cloud Compute. Policy-preferred supplier. Total price EUR 110,400.00 (composite score: 81.4)"
    },
    "audit_trail": {
      "policies_checked": ["AT-003", "CR-001"],
      "supplier_ids_evaluated": ["SUP-0010", "SUP-0011", "SUP-0012", "SUP-0013"],
      "pricing_region": "EU",
      "scoring_weights": {"price": 0.35, "quality": 0.25, "risk": 0.15, "esg": 0.25},
      "fx_rates_used": {"EUR_CHF": 0.93, "EUR_USD": 1.08, "CHF_EUR": 1.075, "USD_EUR": 0.926},
      "data_sources_used": ["suppliers.csv", "pricing.csv", "policies.json", "historical_awards.csv"],
      "historical_awards_consulted": true,
      "historical_award_note": "AWD-2024-0112, AWD-2024-0087 show prior awards to Azure Enterprise for Cloud Compute in this region. Prior decision used for pattern context only."
    }
  }'::jsonb,
  '[]'::jsonb,
  NULL, NULL, NULL
);

-- --------------------------------------------------------------
-- REQ-2026-003 | Professional Services / IT PM | Spain | 500 days | ESCALATED
-- High-value contract exceeds EUR 500 k threshold → ER-003.
-- --------------------------------------------------------------
INSERT INTO request_records
  (request_id, status, created_at, updated_at,
   extracted_data, response_json, escalations,
   resume_from, resolved_by, resolution_note)
VALUES (
  'REQ-2026-003', 'escalated',
  '2026-03-04 11:33:00+00', '2026-03-04 11:34:07+00',
  '{
    "request_id": "REQ-2026-003",
    "created_at": "2026-03-04T11:33:00Z",
    "request_channel": "teams",
    "request_language": "en",
    "business_unit": "Digital Workplace",
    "country": "ES",
    "site": "Madrid",
    "requester_id": "USR-4103",
    "requester_role": "Programme Director",
    "submitted_for_id": "USR-8203",
    "category_l1": "Professional Services",
    "category_l2": "IT Project Management Services",
    "title": "IT transformation programme – PMO staffing",
    "request_text": "We need 500 consulting days of senior IT project management for our ERP transformation. Budget approximately EUR 490 000. Accenture Advisory Europe is our preferred partner. Delivery by 2026-06-30.",
    "currency": "EUR",
    "budget_amount": 490000.00,
    "quantity": 500.0,
    "unit_of_measure": "consulting_day",
    "required_by_date": "2026-06-30",
    "preferred_supplier_mentioned": "Accenture Advisory Europe",
    "incumbent_supplier": "Accenture Advisory Europe",
    "contract_type_requested": "purchase",
    "delivery_countries": ["ES"],
    "data_residency_constraint": false,
    "esg_requirement": false,
    "status": "new",
    "scenario_tags": ["high_value", "threshold"]
  }'::jsonb,
  '{
    "request_id": "REQ-2026-003",
    "processed_at": "2026-03-04T11:34:07Z",
    "request_interpretation": {
      "category_l1": "Professional Services",
      "category_l2": "IT Project Management Services",
      "quantity": 500.0,
      "unit_of_measure": "consulting_day",
      "budget_amount": 490000.00,
      "currency": "EUR",
      "delivery_countries": ["ES"],
      "required_by_date": "2026-06-30",
      "data_residency_required": false,
      "esg_requirement": false,
      "preferred_supplier_stated": "Accenture Advisory Europe",
      "incumbent_supplier": "Accenture Advisory Europe",
      "request_language": "en",
      "days_until_required": 118
    },
    "validation": {
      "completeness": "pass",
      "issues_detected": [
        {
          "issue_id": "V-001",
          "severity": "medium",
          "type": "cv_review",
          "description": "CR-007: Professional Services engagements above 60 days require named consultant CVs. Quantity 500 days > 60.",
          "action_required": "Request named consultant CVs or equivalent capability profiles."
        }
      ]
    },
    "policy_evaluation": {
      "approval_threshold": {
        "rule_applied": "AT-003",
        "basis": "Estimated contract value range: EUR 490,000.00–525,000.00",
        "quotes_required": 3,
        "approvers": ["procurement"],
        "deviation_approval": ["Head of Category"]
      },
      "preferred_supplier": {
        "supplier": "Accenture Advisory Europe",
        "supplier_id": "SUP-0030",
        "status": "eligible",
        "is_preferred": true,
        "covers_delivery_country": true,
        "is_restricted": false,
        "policy_note": "Accenture Advisory Europe is a policy-preferred supplier for IT Project Management Services in this region. Preferred status means inclusion in the comparison — it does not mandate single-source selection."
      },
      "restricted_suppliers": {},
      "category_rules_applied": ["CR-007"],
      "geography_rules_applied": []
    },
    "supplier_shortlist": [
      {
        "rank": 1,
        "supplier_id": "SUP-0030",
        "supplier_name": "Accenture Advisory Europe",
        "preferred": true,
        "incumbent": true,
        "pricing_tier_applied": "0+ units",
        "unit_price_eur": 980.00,
        "total_price_eur": 490000.00,
        "standard_lead_time_days": 14,
        "expedited_lead_time_days": 7,
        "expedited_unit_price_eur": 1100.00,
        "expedited_total_eur": 550000.00,
        "quality_score": 90,
        "risk_score": 25,
        "esg_score": 66,
        "composite_score": 82.10,
        "policy_compliant": true,
        "covers_delivery_country": true,
        "historical_precedent": true,
        "recommendation_note": "Incumbent supplier with established delivery capability. Prior award history: AWD-2025-0019 for IT Project Management Services. Policy-preferred supplier. Total price EUR 490,000.00 (composite score: 82.1)"
      },
      {
        "rank": 2,
        "supplier_id": "SUP-0031",
        "supplier_name": "Capgemini Consulting",
        "preferred": true,
        "incumbent": false,
        "pricing_tier_applied": "0+ units",
        "unit_price_eur": 1050.00,
        "total_price_eur": 525000.00,
        "standard_lead_time_days": 21,
        "expedited_lead_time_days": 10,
        "expedited_unit_price_eur": 1180.00,
        "expedited_total_eur": 590000.00,
        "quality_score": 86,
        "risk_score": 22,
        "esg_score": 69,
        "composite_score": 71.30,
        "policy_compliant": true,
        "covers_delivery_country": true,
        "historical_precedent": false,
        "recommendation_note": "Policy-preferred supplier. Total price EUR 525,000.00 (composite score: 71.3)"
      }
    ],
    "suppliers_excluded": [
      {
        "supplier_id": "SUP-0033",
        "supplier_name": "Deloitte Technology Advisory",
        "reason": "Does not serve delivery countries: [\"ES\"]."
      },
      {
        "supplier_id": "SUP-0039",
        "supplier_name": "Infosys Consulting",
        "reason": "Does not serve delivery countries: [\"ES\"]."
      }
    ],
    "escalations": [
      {
        "escalation_id": "ESC-001",
        "rule": "ER-003",
        "trigger": "Estimated contract value EUR 525,000.00 exceeds high-value threshold (EUR 500,000). Requires Head of Strategic Sourcing approval.",
        "escalate_to": "Head of Strategic Sourcing",
        "blocking": true
      }
    ],
    "recommendation": {
      "status": "cannot_proceed",
      "reason": "1 blocking issue(s) prevent autonomous award: Estimated contract value EUR 525,000.00 exceeds high-value threshold (EUR 500,000). Requires Head of Strategic Sourcing approval.",
      "preferred_supplier_if_resolved": "Accenture Advisory Europe",
      "preferred_supplier_rationale": "Incumbent supplier with established delivery capability. Prior award history: AWD-2025-0019 for IT Project Management Services. Policy-preferred supplier. Total price EUR 490,000.00 (composite score: 82.1)",
      "minimum_budget_required": 490000.00,
      "minimum_budget_currency": "EUR"
    },
    "audit_trail": {
      "policies_checked": ["AT-003", "CR-007", "ER-003"],
      "supplier_ids_evaluated": ["SUP-0030", "SUP-0031", "SUP-0033", "SUP-0039"],
      "pricing_region": "EU",
      "scoring_weights": {"price": 0.40, "quality": 0.25, "risk": 0.20, "esg": 0.15},
      "fx_rates_used": {"EUR_CHF": 0.93, "EUR_USD": 1.08, "CHF_EUR": 1.075, "USD_EUR": 0.926},
      "data_sources_used": ["suppliers.csv", "pricing.csv", "policies.json", "historical_awards.csv"],
      "historical_awards_consulted": true,
      "historical_award_note": "AWD-2025-0019 show prior awards to Accenture Advisory Europe for IT Project Management Services in this region. Prior decision used for pattern context only."
    }
  }'::jsonb,
  '[
    {
      "escalation_id": "ESC-001",
      "rule": "ER-003",
      "trigger": "Estimated contract value EUR 525,000.00 exceeds high-value threshold (EUR 500,000). Requires Head of Strategic Sourcing approval.",
      "escalate_to": "Head of Strategic Sourcing",
      "blocking": true
    }
  ]'::jsonb,
  'state4', NULL, NULL
);

-- --------------------------------------------------------------
-- REQ-2026-004 | IT / Managed Cloud Platform | France | 60 months | ESCALATED
-- Very high-value contract (>EUR 4.9 M) → ER-003 + AT-004.
-- --------------------------------------------------------------
INSERT INTO request_records
  (request_id, status, created_at, updated_at,
   extracted_data, response_json, escalations,
   resume_from, resolved_by, resolution_note)
VALUES (
  'REQ-2026-004', 'escalated',
  '2026-03-05 15:42:00+00', '2026-03-05 15:43:18+00',
  '{
    "request_id": "REQ-2026-004",
    "created_at": "2026-03-05T15:42:00Z",
    "request_channel": "portal",
    "request_language": "fr",
    "business_unit": "Regional IT EU",
    "country": "FR",
    "site": "Paris",
    "requester_id": "USR-4104",
    "requester_role": "Infrastructure Manager",
    "submitted_for_id": "USR-8204",
    "category_l1": "IT",
    "category_l2": "Managed Cloud Platform Services",
    "title": "Managed cloud platform – 5-year sourcing wave",
    "request_text": "Besoin dun service de plateforme cloud gérée pour 60 mois. Budget total estimé EUR 4 900 000. Livraison requise avant le 2026-05-01. Veuillez conseiller sur les offres et la procédure dapprobation.",
    "currency": "EUR",
    "budget_amount": 4900000.00,
    "quantity": 60.0,
    "unit_of_measure": "monthly_subscription",
    "required_by_date": "2026-05-01",
    "preferred_supplier_mentioned": null,
    "incumbent_supplier": "OVHcloud Enterprise",
    "contract_type_requested": "framework call-off",
    "delivery_countries": ["FR"],
    "data_residency_constraint": false,
    "esg_requirement": true,
    "status": "new",
    "scenario_tags": ["high_value", "threshold", "esg"]
  }'::jsonb,
  '{
    "request_id": "REQ-2026-004",
    "processed_at": "2026-03-05T15:43:18Z",
    "request_interpretation": {
      "category_l1": "IT",
      "category_l2": "Managed Cloud Platform Services",
      "quantity": 60.0,
      "unit_of_measure": "monthly_subscription",
      "budget_amount": 4900000.00,
      "currency": "EUR",
      "delivery_countries": ["FR"],
      "required_by_date": "2026-05-01",
      "data_residency_required": false,
      "esg_requirement": true,
      "preferred_supplier_stated": null,
      "incumbent_supplier": "OVHcloud Enterprise",
      "request_language": "fr",
      "days_until_required": 57
    },
    "validation": {
      "completeness": "pass",
      "issues_detected": [
        {
          "issue_id": "V-001",
          "severity": "medium",
          "type": "mandatory_comparison",
          "description": "CR-001: Managed Cloud Platform contracts above EUR 100 000 require formal multi-supplier comparison. Budget EUR 4,900,000.00 EUR meets threshold.",
          "action_required": "Ensure at least 3 compliant supplier options are compared."
        }
      ]
    },
    "policy_evaluation": {
      "approval_threshold": {
        "rule_applied": "AT-004",
        "basis": "Estimated contract value range: EUR 4,740,000.00–4,980,000.00",
        "quotes_required": 3,
        "approvers": ["procurement"],
        "deviation_approval": ["Head of Strategic Sourcing"]
      },
      "preferred_supplier": {
        "supplier": null
      },
      "restricted_suppliers": {},
      "category_rules_applied": ["CR-001"],
      "geography_rules_applied": []
    },
    "supplier_shortlist": [
      {
        "rank": 1,
        "supplier_id": "SUP-0010",
        "supplier_name": "Azure Enterprise",
        "preferred": true,
        "incumbent": false,
        "pricing_tier_applied": "0+ units",
        "unit_price_eur": 79000.00,
        "total_price_eur": 4740000.00,
        "standard_lead_time_days": 30,
        "expedited_lead_time_days": 14,
        "expedited_unit_price_eur": 88800.00,
        "expedited_total_eur": 5328000.00,
        "quality_score": 89,
        "risk_score": 12,
        "esg_score": 65,
        "composite_score": 79.40,
        "policy_compliant": true,
        "covers_delivery_country": true,
        "historical_precedent": false,
        "recommendation_note": "Policy-preferred supplier. Total price EUR 4,740,000.00 (composite score: 79.4)"
      },
      {
        "rank": 2,
        "supplier_id": "SUP-0013",
        "supplier_name": "OVHcloud Enterprise",
        "preferred": false,
        "incumbent": true,
        "pricing_tier_applied": "0+ units",
        "unit_price_eur": 76000.00,
        "total_price_eur": 4560000.00,
        "standard_lead_time_days": 30,
        "expedited_lead_time_days": 14,
        "expedited_unit_price_eur": 85500.00,
        "expedited_total_eur": 5130000.00,
        "quality_score": 76,
        "risk_score": 18,
        "esg_score": 82,
        "composite_score": 75.20,
        "policy_compliant": true,
        "covers_delivery_country": true,
        "historical_precedent": true,
        "recommendation_note": "Incumbent supplier with established delivery capability. Prior award history: AWD-2024-0033 for Managed Cloud Platform Services. Total price EUR 4,560,000.00 (composite score: 75.2)"
      },
      {
        "rank": 3,
        "supplier_id": "SUP-0011",
        "supplier_name": "AWS Enterprise EMEA",
        "preferred": false,
        "incumbent": false,
        "pricing_tier_applied": "0+ units",
        "unit_price_eur": 83000.00,
        "total_price_eur": 4980000.00,
        "standard_lead_time_days": 30,
        "expedited_lead_time_days": 14,
        "expedited_unit_price_eur": 93400.00,
        "expedited_total_eur": 5604000.00,
        "quality_score": 90,
        "risk_score": 21,
        "esg_score": 62,
        "composite_score": 66.80,
        "policy_compliant": true,
        "covers_delivery_country": true,
        "historical_precedent": false,
        "recommendation_note": "Total price EUR 4,980,000.00 (composite score: 66.8)"
      }
    ],
    "suppliers_excluded": [
      {
        "supplier_id": "SUP-0012",
        "supplier_name": "Google Cloud Europe",
        "reason": "Ranked outside top 3 by composite score (58.30). preferred=false, risk_score=21."
      }
    ],
    "escalations": [
      {
        "escalation_id": "ESC-001",
        "rule": "ER-003",
        "trigger": "Estimated contract value EUR 4,980,000.00 exceeds high-value threshold (EUR 500,000). Requires Head of Strategic Sourcing approval.",
        "escalate_to": "Head of Strategic Sourcing",
        "blocking": true
      }
    ],
    "recommendation": {
      "status": "cannot_proceed",
      "reason": "1 blocking issue(s) prevent autonomous award: Estimated contract value EUR 4,980,000.00 exceeds high-value threshold (EUR 500,000). Requires Head of Strategic Sourcing approval.",
      "preferred_supplier_if_resolved": "Azure Enterprise",
      "preferred_supplier_rationale": "Policy-preferred supplier. Total price EUR 4,740,000.00 (composite score: 79.4)",
      "minimum_budget_required": 4560000.00,
      "minimum_budget_currency": "EUR"
    },
    "audit_trail": {
      "policies_checked": ["AT-004", "CR-001", "ER-003"],
      "supplier_ids_evaluated": ["SUP-0010", "SUP-0011", "SUP-0012", "SUP-0013"],
      "pricing_region": "EU",
      "scoring_weights": {"price": 0.35, "quality": 0.25, "risk": 0.15, "esg": 0.25},
      "fx_rates_used": {"EUR_CHF": 0.93, "EUR_USD": 1.08, "CHF_EUR": 1.075, "USD_EUR": 0.926},
      "data_sources_used": ["suppliers.csv", "pricing.csv", "policies.json", "historical_awards.csv"],
      "historical_awards_consulted": true,
      "historical_award_note": "AWD-2024-0033 show prior awards to OVHcloud Enterprise for Managed Cloud Platform Services in this region. Prior decision used for pattern context only."
    }
  }'::jsonb,
  '[
    {
      "escalation_id": "ESC-001",
      "rule": "ER-003",
      "trigger": "Estimated contract value EUR 4,980,000.00 exceeds high-value threshold (EUR 500,000). Requires Head of Strategic Sourcing approval.",
      "escalate_to": "Head of Strategic Sourcing",
      "blocking": true
    }
  ]'::jsonb,
  'state4', NULL, NULL
);

-- --------------------------------------------------------------
-- REQ-2026-005 | Facilities / Office Chairs | Belgium | 150 units | completed
-- Kinnarps (preferred, incumbent) wins on composite score.
-- --------------------------------------------------------------
INSERT INTO request_records
  (request_id, status, created_at, updated_at,
   extracted_data, response_json, escalations,
   resume_from, resolved_by, resolution_note)
VALUES (
  'REQ-2026-005', 'completed',
  '2026-03-06 08:55:00+00', '2026-03-06 08:55:52+00',
  '{
    "request_id": "REQ-2026-005",
    "created_at": "2026-03-06T08:55:00Z",
    "request_channel": "portal",
    "request_language": "en",
    "business_unit": "Facilities Management",
    "country": "BE",
    "site": "Brussels",
    "requester_id": "USR-4105",
    "requester_role": "Facilities Manager",
    "submitted_for_id": "USR-8205",
    "category_l1": "Facilities",
    "category_l2": "Office Chairs",
    "title": "Office chair procurement – Brussels HQ refurbishment",
    "request_text": "Ordering 150 ergonomic office chairs for Brussels HQ refurbishment. Budget EUR 70 000. Kinnarps is our incumbent supplier. Required by 2026-04-15.",
    "currency": "EUR",
    "budget_amount": 70000.00,
    "quantity": 150.0,
    "unit_of_measure": "unit",
    "required_by_date": "2026-04-15",
    "preferred_supplier_mentioned": "Kinnarps Workplace",
    "incumbent_supplier": "Kinnarps Workplace",
    "contract_type_requested": "purchase",
    "delivery_countries": ["BE"],
    "data_residency_constraint": false,
    "esg_requirement": false,
    "status": "new",
    "scenario_tags": ["standard", "facilities", "incumbent"]
  }'::jsonb,
  '{
    "request_id": "REQ-2026-005",
    "processed_at": "2026-03-06T08:55:52Z",
    "request_interpretation": {
      "category_l1": "Facilities",
      "category_l2": "Office Chairs",
      "quantity": 150.0,
      "unit_of_measure": "unit",
      "budget_amount": 70000.00,
      "currency": "EUR",
      "delivery_countries": ["BE"],
      "required_by_date": "2026-04-15",
      "data_residency_required": false,
      "esg_requirement": false,
      "preferred_supplier_stated": "Kinnarps Workplace",
      "incumbent_supplier": "Kinnarps Workplace",
      "request_language": "en",
      "days_until_required": 40
    },
    "validation": {
      "completeness": "pass",
      "issues_detected": []
    },
    "policy_evaluation": {
      "approval_threshold": {
        "rule_applied": "AT-002",
        "basis": "Estimated contract value range: EUR 64,500.00–82,500.00",
        "quotes_required": 2,
        "approvers": ["business", "procurement"],
        "deviation_approval": ["Procurement Manager"]
      },
      "preferred_supplier": {
        "supplier": "Kinnarps Workplace",
        "supplier_id": "SUP-0020",
        "status": "eligible",
        "is_preferred": true,
        "covers_delivery_country": true,
        "is_restricted": false,
        "policy_note": "Kinnarps Workplace is a policy-preferred supplier for Office Chairs in this region. Preferred status means inclusion in the comparison — it does not mandate single-source selection."
      },
      "restricted_suppliers": {},
      "category_rules_applied": [],
      "geography_rules_applied": []
    },
    "supplier_shortlist": [
      {
        "rank": 1,
        "supplier_id": "SUP-0020",
        "supplier_name": "Kinnarps Workplace",
        "preferred": true,
        "incumbent": true,
        "pricing_tier_applied": "100–250 units",
        "unit_price_eur": 430.00,
        "total_price_eur": 64500.00,
        "standard_lead_time_days": 18,
        "expedited_lead_time_days": 10,
        "expedited_unit_price_eur": 485.00,
        "expedited_total_eur": 72750.00,
        "quality_score": 80,
        "risk_score": 19,
        "esg_score": 84,
        "composite_score": 93.80,
        "policy_compliant": true,
        "covers_delivery_country": true,
        "historical_precedent": true,
        "recommendation_note": "Incumbent supplier with established delivery capability. Prior award history: AWD-2025-0058, AWD-2024-0091 for Office Chairs. Policy-preferred supplier. Total price EUR 64,500.00 (composite score: 93.8)"
      },
      {
        "rank": 2,
        "supplier_id": "SUP-0021",
        "supplier_name": "Steelcase Europe",
        "preferred": true,
        "incumbent": false,
        "pricing_tier_applied": "100–250 units",
        "unit_price_eur": 480.00,
        "total_price_eur": 72000.00,
        "standard_lead_time_days": 21,
        "expedited_lead_time_days": 12,
        "expedited_unit_price_eur": 540.00,
        "expedited_total_eur": 81000.00,
        "quality_score": 89,
        "risk_score": 23,
        "esg_score": 70,
        "composite_score": 71.47,
        "policy_compliant": true,
        "covers_delivery_country": true,
        "historical_precedent": false,
        "recommendation_note": "Policy-preferred supplier. Total price EUR 72,000.00 (composite score: 71.47)"
      },
      {
        "rank": 3,
        "supplier_id": "SUP-0022",
        "supplier_name": "Herman Miller Contract",
        "preferred": false,
        "incumbent": false,
        "pricing_tier_applied": "100–250 units",
        "unit_price_eur": 550.00,
        "total_price_eur": 82500.00,
        "standard_lead_time_days": 28,
        "expedited_lead_time_days": 14,
        "expedited_unit_price_eur": 620.00,
        "expedited_total_eur": 93000.00,
        "quality_score": 91,
        "risk_score": 22,
        "esg_score": 80,
        "composite_score": 50.35,
        "policy_compliant": true,
        "covers_delivery_country": true,
        "historical_precedent": false,
        "recommendation_note": "Total price EUR 82,500.00 (composite score: 50.35)"
      }
    ],
    "suppliers_excluded": [
      {
        "supplier_id": "SUP-0023",
        "supplier_name": "IKEA Business",
        "reason": "No pricing data found for Office Chairs in region EU."
      }
    ],
    "escalations": [],
    "recommendation": {
      "status": "recommended",
      "winner": "Kinnarps Workplace",
      "winner_id": "SUP-0020",
      "total_price_eur": 64500.00,
      "rationale": "Incumbent supplier with established delivery capability. Prior award history: AWD-2025-0058, AWD-2024-0091 for Office Chairs. Policy-preferred supplier. Total price EUR 64,500.00 (composite score: 93.8)"
    },
    "audit_trail": {
      "policies_checked": ["AT-002"],
      "supplier_ids_evaluated": ["SUP-0020", "SUP-0021", "SUP-0022", "SUP-0023"],
      "pricing_region": "EU",
      "scoring_weights": {"price": 0.40, "quality": 0.25, "risk": 0.20, "esg": 0.15},
      "fx_rates_used": {"EUR_CHF": 0.93, "EUR_USD": 1.08, "CHF_EUR": 1.075, "USD_EUR": 0.926},
      "data_sources_used": ["suppliers.csv", "pricing.csv", "policies.json", "historical_awards.csv"],
      "historical_awards_consulted": true,
      "historical_award_note": "AWD-2025-0058, AWD-2024-0091 show prior awards to Kinnarps Workplace for Office Chairs in this region. Prior decision used for pattern context only."
    }
  }'::jsonb,
  '[]'::jsonb,
  NULL, NULL, NULL
);

-- --------------------------------------------------------------
-- REQ-2026-006 | Professional Services / Cybersecurity | Switzerland | 30 days | completed
-- CHF pricing region. Capgemini narrowly beats Accenture. Deloitte (incumbent) ranks 3rd.
-- --------------------------------------------------------------
INSERT INTO request_records
  (request_id, status, created_at, updated_at,
   extracted_data, response_json, escalations,
   resume_from, resolved_by, resolution_note)
VALUES (
  'REQ-2026-006', 'completed',
  '2026-03-07 10:08:00+00', '2026-03-07 10:08:55+00',
  '{
    "request_id": "REQ-2026-006",
    "created_at": "2026-03-07T10:08:00Z",
    "request_channel": "portal",
    "request_language": "de",
    "business_unit": "Group Information Security",
    "country": "CH",
    "site": "Zurich",
    "requester_id": "USR-4106",
    "requester_role": "CISO Office",
    "submitted_for_id": "USR-8206",
    "category_l1": "Professional Services",
    "category_l2": "Cybersecurity Advisory",
    "title": "Cybersecurity maturity assessment – 30 days",
    "request_text": "Wir benötigen 30 Beratertage für ein Cybersecurity Maturity Assessment. Budget CHF 65 000. Deloitte ist unser bisheriger Anbieter. Abschluss bis 2026-04-30.",
    "currency": "CHF",
    "budget_amount": 65000.00,
    "quantity": 30.0,
    "unit_of_measure": "consulting_day",
    "required_by_date": "2026-04-30",
    "preferred_supplier_mentioned": null,
    "incumbent_supplier": "Deloitte Technology Advisory",
    "contract_type_requested": "purchase",
    "delivery_countries": ["CH"],
    "data_residency_constraint": false,
    "esg_requirement": false,
    "status": "new",
    "scenario_tags": ["standard", "chf", "incumbent"]
  }'::jsonb,
  '{
    "request_id": "REQ-2026-006",
    "processed_at": "2026-03-07T10:08:55Z",
    "request_interpretation": {
      "category_l1": "Professional Services",
      "category_l2": "Cybersecurity Advisory",
      "quantity": 30.0,
      "unit_of_measure": "consulting_day",
      "budget_amount": 65000.00,
      "currency": "CHF",
      "delivery_countries": ["CH"],
      "required_by_date": "2026-04-30",
      "data_residency_required": false,
      "esg_requirement": false,
      "preferred_supplier_stated": null,
      "incumbent_supplier": "Deloitte Technology Advisory",
      "request_language": "de",
      "days_until_required": 54
    },
    "validation": {
      "completeness": "pass",
      "issues_detected": []
    },
    "policy_evaluation": {
      "approval_threshold": {
        "rule_applied": "AT-008",
        "basis": "Estimated contract value range: CHF 37,500.00–58,050.00",
        "quotes_required": 2,
        "approvers": ["business", "procurement"],
        "deviation_approval": ["Procurement Manager"]
      },
      "preferred_supplier": {
        "supplier": null
      },
      "restricted_suppliers": {},
      "category_rules_applied": [],
      "geography_rules_applied": []
    },
    "supplier_shortlist": [
      {
        "rank": 1,
        "supplier_id": "SUP-0031",
        "supplier_name": "Capgemini Consulting",
        "preferred": true,
        "incumbent": false,
        "pricing_tier_applied": "0+ units",
        "unit_price_eur": 1250.00,
        "total_price_eur": 37500.00,
        "standard_lead_time_days": 14,
        "expedited_lead_time_days": 7,
        "expedited_unit_price_eur": 1400.00,
        "expedited_total_eur": 42000.00,
        "quality_score": 83,
        "risk_score": 19,
        "esg_score": 69,
        "composite_score": 87.30,
        "policy_compliant": true,
        "covers_delivery_country": true,
        "historical_precedent": false,
        "recommendation_note": "Policy-preferred supplier. Total price EUR 37,500.00 (composite score: 87.3)"
      },
      {
        "rank": 2,
        "supplier_id": "SUP-0030",
        "supplier_name": "Accenture Advisory Europe",
        "preferred": true,
        "incumbent": false,
        "pricing_tier_applied": "0+ units",
        "unit_price_eur": 1350.00,
        "total_price_eur": 40500.00,
        "standard_lead_time_days": 14,
        "expedited_lead_time_days": 7,
        "expedited_unit_price_eur": 1520.00,
        "expedited_total_eur": 45600.00,
        "quality_score": 89,
        "risk_score": 21,
        "esg_score": 75,
        "composite_score": 83.46,
        "policy_compliant": true,
        "covers_delivery_country": true,
        "historical_precedent": false,
        "recommendation_note": "Policy-preferred supplier. Total price EUR 40,500.00 (composite score: 83.46)"
      },
      {
        "rank": 3,
        "supplier_id": "SUP-0033",
        "supplier_name": "Deloitte Technology Advisory",
        "preferred": false,
        "incumbent": true,
        "pricing_tier_applied": "0+ units",
        "unit_price_eur": 1935.00,
        "total_price_eur": 58050.00,
        "standard_lead_time_days": 10,
        "expedited_lead_time_days": 5,
        "expedited_unit_price_eur": 2175.00,
        "expedited_total_eur": 65250.00,
        "quality_score": 88,
        "risk_score": 22,
        "esg_score": 78,
        "composite_score": 51.90,
        "policy_compliant": true,
        "covers_delivery_country": true,
        "historical_precedent": true,
        "recommendation_note": "Incumbent supplier with established delivery capability. Prior award history: AWD-2025-0003 for Cybersecurity Advisory. Total price EUR 58,050.00 (composite score: 51.9)"
      }
    ],
    "suppliers_excluded": [],
    "escalations": [],
    "recommendation": {
      "status": "recommended",
      "winner": "Capgemini Consulting",
      "winner_id": "SUP-0031",
      "total_price_eur": 37500.00,
      "rationale": "Policy-preferred supplier. Total price EUR 37,500.00 (composite score: 87.3)"
    },
    "audit_trail": {
      "policies_checked": ["AT-008"],
      "supplier_ids_evaluated": ["SUP-0030", "SUP-0031", "SUP-0033"],
      "pricing_region": "CH",
      "scoring_weights": {"price": 0.40, "quality": 0.25, "risk": 0.20, "esg": 0.15},
      "fx_rates_used": {"EUR_CHF": 0.93, "EUR_USD": 1.08, "CHF_EUR": 1.075, "USD_EUR": 0.926},
      "data_sources_used": ["suppliers.csv", "pricing.csv", "policies.json", "historical_awards.csv"],
      "historical_awards_consulted": true,
      "historical_award_note": "AWD-2025-0003 show prior awards to Deloitte Technology Advisory for Cybersecurity Advisory in this region. Prior decision used for pattern context only."
    }
  }'::jsonb,
  '[]'::jsonb,
  NULL, NULL, NULL
);

-- --------------------------------------------------------------
-- REQ-2026-007 | IT / Laptops | Italy | 80 units | ESCALATED
-- Budget EUR 50 000 insufficient – min. supplier price is EUR 57 600. ER-001.
-- --------------------------------------------------------------
INSERT INTO request_records
  (request_id, status, created_at, updated_at,
   extracted_data, response_json, escalations,
   resume_from, resolved_by, resolution_note)
VALUES (
  'REQ-2026-007', 'escalated',
  '2026-03-08 13:17:00+00', '2026-03-08 13:17:44+00',
  '{
    "request_id": "REQ-2026-007",
    "created_at": "2026-03-08T13:17:00Z",
    "request_channel": "teams",
    "request_language": "it",
    "business_unit": "Regional IT EU",
    "country": "IT",
    "site": "Milan",
    "requester_id": "USR-4107",
    "requester_role": "IT Manager",
    "submitted_for_id": "USR-8207",
    "category_l1": "IT",
    "category_l2": "Laptops",
    "title": "Laptop order – Milan expansion",
    "request_text": "Ordine di 80 laptop per la nuova sede di Milano. Budget massimo EUR 50 000. Consegna entro il 2026-04-20.",
    "currency": "EUR",
    "budget_amount": 50000.00,
    "quantity": 80.0,
    "unit_of_measure": "unit",
    "required_by_date": "2026-04-20",
    "preferred_supplier_mentioned": null,
    "incumbent_supplier": null,
    "contract_type_requested": "purchase",
    "delivery_countries": ["IT"],
    "data_residency_constraint": false,
    "esg_requirement": false,
    "status": "new",
    "scenario_tags": ["budget_insufficient"]
  }'::jsonb,
  '{
    "request_id": "REQ-2026-007",
    "processed_at": "2026-03-08T13:17:44Z",
    "request_interpretation": {
      "category_l1": "IT",
      "category_l2": "Laptops",
      "quantity": 80.0,
      "unit_of_measure": "unit",
      "budget_amount": 50000.00,
      "currency": "EUR",
      "delivery_countries": ["IT"],
      "required_by_date": "2026-04-20",
      "data_residency_required": false,
      "esg_requirement": false,
      "preferred_supplier_stated": null,
      "incumbent_supplier": null,
      "request_language": "it",
      "days_until_required": 43
    },
    "validation": {
      "completeness": "pass",
      "issues_detected": [
        {
          "issue_id": "V-001",
          "severity": "critical",
          "type": "budget_insufficient",
          "description": "Budget of EUR 50,000.00 is insufficient. Minimum total price is EUR 57,600.00 (Dell Enterprise Europe, tier 0–100 units). Shortfall: EUR 7,600.00.",
          "action_required": "Increase budget to at least EUR 57,600.00 or reduce quantity to a maximum of 69 units within the stated budget."
        },
        {
          "issue_id": "V-002",
          "severity": "medium",
          "type": "engineering_spec_review",
          "description": "CR-002: Hardware orders above 50 units require compatibility review. Quantity 80 units > 50.",
          "action_required": "Obtain compatibility review from engineering or CAD lead before award."
        }
      ]
    },
    "policy_evaluation": {
      "approval_threshold": {
        "rule_applied": "AT-002",
        "basis": "Estimated contract value range: EUR 57,600.00–83,200.00",
        "quotes_required": 2,
        "approvers": ["business", "procurement"],
        "deviation_approval": ["Procurement Manager"]
      },
      "preferred_supplier": {
        "supplier": null
      },
      "restricted_suppliers": {
        "SUP-0008": {
          "supplier_name": "Computacenter Devices",
          "restricted": true,
          "reason": "Restricted for selected categories and countries in policy set"
        }
      },
      "category_rules_applied": ["CR-002"],
      "geography_rules_applied": []
    },
    "supplier_shortlist": [
      {
        "rank": 1,
        "supplier_id": "SUP-0001",
        "supplier_name": "Dell Enterprise Europe",
        "preferred": true,
        "incumbent": false,
        "pricing_tier_applied": "0–100 units",
        "unit_price_eur": 720.00,
        "total_price_eur": 57600.00,
        "standard_lead_time_days": 10,
        "expedited_lead_time_days": 5,
        "expedited_unit_price_eur": 810.00,
        "expedited_total_eur": 64800.00,
        "quality_score": 87,
        "risk_score": 16,
        "esg_score": 73,
        "composite_score": 89.5,
        "policy_compliant": true,
        "covers_delivery_country": true,
        "historical_precedent": false,
        "recommendation_note": "Policy-preferred supplier. Total price EUR 57,600.00 (composite score: 89.5)"
      },
      {
        "rank": 2,
        "supplier_id": "SUP-0003",
        "supplier_name": "Lenovo Commercial EU",
        "preferred": true,
        "incumbent": false,
        "pricing_tier_applied": "0–100 units",
        "unit_price_eur": 740.00,
        "total_price_eur": 59200.00,
        "standard_lead_time_days": 12,
        "expedited_lead_time_days": 6,
        "expedited_unit_price_eur": 830.00,
        "expedited_total_eur": 66400.00,
        "quality_score": 83,
        "risk_score": 28,
        "esg_score": 74,
        "composite_score": 72.30,
        "policy_compliant": true,
        "covers_delivery_country": true,
        "historical_precedent": false,
        "recommendation_note": "Policy-preferred supplier. Total price EUR 59,200.00 (composite score: 72.3)"
      },
      {
        "rank": 3,
        "supplier_id": "SUP-0002",
        "supplier_name": "HP Enterprise Devices",
        "preferred": true,
        "incumbent": false,
        "pricing_tier_applied": "0–100 units",
        "unit_price_eur": 768.00,
        "total_price_eur": 61440.00,
        "standard_lead_time_days": 14,
        "expedited_lead_time_days": 7,
        "expedited_unit_price_eur": 860.00,
        "expedited_total_eur": 68800.00,
        "quality_score": 85,
        "risk_score": 18,
        "esg_score": 74,
        "composite_score": 63.80,
        "policy_compliant": true,
        "covers_delivery_country": true,
        "historical_precedent": false,
        "recommendation_note": "Policy-preferred supplier. Total price EUR 61,440.00 (composite score: 63.8)"
      },
      {
        "rank": 4,
        "supplier_id": "SUP-0007",
        "supplier_name": "Bechtle Workplace Solutions",
        "preferred": true,
        "incumbent": false,
        "pricing_tier_applied": "0–100 units",
        "unit_price_eur": 780.00,
        "total_price_eur": 62400.00,
        "standard_lead_time_days": 11,
        "expedited_lead_time_days": 6,
        "expedited_unit_price_eur": 875.00,
        "expedited_total_eur": 70000.00,
        "quality_score": 82,
        "risk_score": 17,
        "esg_score": 71,
        "composite_score": 58.10,
        "policy_compliant": true,
        "covers_delivery_country": true,
        "historical_precedent": false,
        "recommendation_note": "Policy-preferred supplier. Total price EUR 62,400.00 (composite score: 58.1)"
      },
      {
        "rank": 5,
        "supplier_id": "SUP-0004",
        "supplier_name": "Apple Business Channel",
        "preferred": false,
        "incumbent": false,
        "pricing_tier_applied": "0–100 units",
        "unit_price_eur": 1040.00,
        "total_price_eur": 83200.00,
        "standard_lead_time_days": 8,
        "expedited_lead_time_days": 4,
        "expedited_unit_price_eur": 1165.00,
        "expedited_total_eur": 93200.00,
        "quality_score": 90,
        "risk_score": 22,
        "esg_score": 76,
        "composite_score": 49.60,
        "policy_compliant": true,
        "covers_delivery_country": true,
        "historical_precedent": false,
        "recommendation_note": "Total price EUR 83,200.00 (composite score: 49.6)"
      }
    ],
    "suppliers_excluded": [
      {
        "supplier_id": "SUP-0008",
        "supplier_name": "Computacenter Devices",
        "reason": "Restricted for Laptops in [\"IT\"]: Restricted for selected categories and countries in policy set"
      }
    ],
    "escalations": [
      {
        "escalation_id": "ESC-001",
        "rule": "ER-001",
        "trigger": "Budget EUR 50,000.00 cannot cover 80 units at any compliant supplier price (minimum EUR 57,600.00).",
        "escalate_to": "Requester Clarification",
        "blocking": true
      }
    ],
    "recommendation": {
      "status": "cannot_proceed",
      "reason": "1 blocking issue(s) prevent autonomous award: Budget EUR 50,000.00 cannot cover 80 units at any compliant supplier price (minimum EUR 57,600.00).",
      "preferred_supplier_if_resolved": "Dell Enterprise Europe",
      "preferred_supplier_rationale": "Policy-preferred supplier. Total price EUR 57,600.00 (composite score: 89.5)",
      "minimum_budget_required": 57600.00,
      "minimum_budget_currency": "EUR"
    },
    "audit_trail": {
      "policies_checked": ["AT-002", "CR-002", "ER-001"],
      "supplier_ids_evaluated": ["SUP-0001", "SUP-0002", "SUP-0003", "SUP-0004", "SUP-0007", "SUP-0008"],
      "pricing_region": "EU",
      "scoring_weights": {"price": 0.40, "quality": 0.25, "risk": 0.20, "esg": 0.15},
      "fx_rates_used": {"EUR_CHF": 0.93, "EUR_USD": 1.08, "CHF_EUR": 1.075, "USD_EUR": 0.926},
      "data_sources_used": ["suppliers.csv", "pricing.csv", "policies.json", "historical_awards.csv"],
      "historical_awards_consulted": false,
      "historical_award_note": null
    }
  }'::jsonb,
  '[
    {
      "escalation_id": "ESC-001",
      "rule": "ER-001",
      "trigger": "Budget EUR 50,000.00 cannot cover 80 units at any compliant supplier price (minimum EUR 57,600.00).",
      "escalate_to": "Requester Clarification",
      "blocking": true
    }
  ]'::jsonb,
  'state2', NULL, NULL
);

-- --------------------------------------------------------------
-- REQ-2026-008 | Professional Services / Software Dev | Germany | 80 days | completed
-- Thoughtworks preferred; wins on composite score.
-- --------------------------------------------------------------
INSERT INTO request_records
  (request_id, status, created_at, updated_at,
   extracted_data, response_json, escalations,
   resume_from, resolved_by, resolution_note)
VALUES (
  'REQ-2026-008', 'completed',
  '2026-03-10 09:30:00+00', '2026-03-10 09:31:03+00',
  '{
    "request_id": "REQ-2026-008",
    "created_at": "2026-03-10T09:30:00Z",
    "request_channel": "portal",
    "request_language": "en",
    "business_unit": "Product Engineering",
    "country": "DE",
    "site": "Berlin",
    "requester_id": "USR-4108",
    "requester_role": "Engineering Manager",
    "submitted_for_id": "USR-8208",
    "category_l1": "Professional Services",
    "category_l2": "Software Development Services",
    "title": "Mobile app development – 80 consultant days",
    "request_text": "We need 80 days of senior software development for our mobile app rewrite. Budget EUR 72 000. Prefer Thoughtworks – good track record. Required by 2026-05-15.",
    "currency": "EUR",
    "budget_amount": 72000.00,
    "quantity": 80.0,
    "unit_of_measure": "consulting_day",
    "required_by_date": "2026-05-15",
    "preferred_supplier_mentioned": "Thoughtworks Europe",
    "incumbent_supplier": null,
    "contract_type_requested": "purchase",
    "delivery_countries": ["DE"],
    "data_residency_constraint": false,
    "esg_requirement": false,
    "status": "new",
    "scenario_tags": ["standard", "software"]
  }'::jsonb,
  '{
    "request_id": "REQ-2026-008",
    "processed_at": "2026-03-10T09:31:03Z",
    "request_interpretation": {
      "category_l1": "Professional Services",
      "category_l2": "Software Development Services",
      "quantity": 80.0,
      "unit_of_measure": "consulting_day",
      "budget_amount": 72000.00,
      "currency": "EUR",
      "delivery_countries": ["DE"],
      "required_by_date": "2026-05-15",
      "data_residency_required": false,
      "esg_requirement": false,
      "preferred_supplier_stated": "Thoughtworks Europe",
      "incumbent_supplier": null,
      "request_language": "en",
      "days_until_required": 66
    },
    "validation": {
      "completeness": "pass",
      "issues_detected": [
        {
          "issue_id": "V-001",
          "severity": "medium",
          "type": "cv_review",
          "description": "CR-007: Professional Services engagements above 60 days require named consultant CVs. Quantity 80 days > 60.",
          "action_required": "Request named consultant CVs or equivalent capability profiles."
        }
      ]
    },
    "policy_evaluation": {
      "approval_threshold": {
        "rule_applied": "AT-002",
        "basis": "Estimated contract value range: EUR 64,800.00–80,000.00",
        "quotes_required": 2,
        "approvers": ["business", "procurement"],
        "deviation_approval": ["Procurement Manager"]
      },
      "preferred_supplier": {
        "supplier": "Thoughtworks Europe",
        "supplier_id": "SUP-0032",
        "status": "eligible",
        "is_preferred": false,
        "covers_delivery_country": true,
        "is_restricted": false,
        "policy_note": "Thoughtworks Europe is not a policy-preferred supplier for Software Development Services in this region. Will be included if they serve the delivery area."
      },
      "restricted_suppliers": {},
      "category_rules_applied": ["CR-007"],
      "geography_rules_applied": []
    },
    "supplier_shortlist": [
      {
        "rank": 1,
        "supplier_id": "SUP-0032",
        "supplier_name": "Thoughtworks Europe",
        "preferred": false,
        "incumbent": false,
        "pricing_tier_applied": "0+ units",
        "unit_price_eur": 810.00,
        "total_price_eur": 64800.00,
        "standard_lead_time_days": 14,
        "expedited_lead_time_days": 7,
        "expedited_unit_price_eur": 910.00,
        "expedited_total_eur": 72800.00,
        "quality_score": 89,
        "risk_score": 18,
        "esg_score": 74,
        "composite_score": 91.20,
        "policy_compliant": true,
        "covers_delivery_country": true,
        "historical_precedent": false,
        "recommendation_note": "Total price EUR 64,800.00 (composite score: 91.2)"
      },
      {
        "rank": 2,
        "supplier_id": "SUP-0031",
        "supplier_name": "Capgemini Consulting",
        "preferred": true,
        "incumbent": false,
        "pricing_tier_applied": "0+ units",
        "unit_price_eur": 890.00,
        "total_price_eur": 71200.00,
        "standard_lead_time_days": 21,
        "expedited_lead_time_days": 10,
        "expedited_unit_price_eur": 995.00,
        "expedited_total_eur": 79600.00,
        "quality_score": 89,
        "risk_score": 19,
        "esg_score": 76,
        "composite_score": 78.40,
        "policy_compliant": true,
        "covers_delivery_country": true,
        "historical_precedent": false,
        "recommendation_note": "Policy-preferred supplier. Total price EUR 71,200.00 (composite score: 78.4)"
      },
      {
        "rank": 3,
        "supplier_id": "SUP-0034",
        "supplier_name": "EPAM Delivery Services",
        "preferred": false,
        "incumbent": false,
        "pricing_tier_applied": "0+ units",
        "unit_price_eur": 1000.00,
        "total_price_eur": 80000.00,
        "standard_lead_time_days": 14,
        "expedited_lead_time_days": 7,
        "expedited_unit_price_eur": 1120.00,
        "expedited_total_eur": 89600.00,
        "quality_score": 81,
        "risk_score": 20,
        "esg_score": 75,
        "composite_score": 65.30,
        "policy_compliant": true,
        "covers_delivery_country": true,
        "historical_precedent": false,
        "recommendation_note": "Total price EUR 80,000.00 (composite score: 65.3)"
      }
    ],
    "suppliers_excluded": [],
    "escalations": [],
    "recommendation": {
      "status": "recommended",
      "winner": "Thoughtworks Europe",
      "winner_id": "SUP-0032",
      "total_price_eur": 64800.00,
      "rationale": "Total price EUR 64,800.00 (composite score: 91.2)"
    },
    "audit_trail": {
      "policies_checked": ["AT-002", "CR-007"],
      "supplier_ids_evaluated": ["SUP-0031", "SUP-0032", "SUP-0034"],
      "pricing_region": "EU",
      "scoring_weights": {"price": 0.40, "quality": 0.25, "risk": 0.20, "esg": 0.15},
      "fx_rates_used": {"EUR_CHF": 0.93, "EUR_USD": 1.08, "CHF_EUR": 1.075, "USD_EUR": 0.926},
      "data_sources_used": ["suppliers.csv", "pricing.csv", "policies.json", "historical_awards.csv"],
      "historical_awards_consulted": false,
      "historical_award_note": null
    }
  }'::jsonb,
  '[]'::jsonb,
  NULL, NULL, NULL
);

-- --------------------------------------------------------------
-- REQ-2026-009 | Marketing / SEM | France | 1 campaign | completed
-- Publicis (preferred) recommended. AT-002. Standard scenario.
-- --------------------------------------------------------------
INSERT INTO request_records
  (request_id, status, created_at, updated_at,
   extracted_data, response_json, escalations,
   resume_from, resolved_by, resolution_note)
VALUES (
  'REQ-2026-009', 'completed',
  '2026-03-11 16:05:00+00', '2026-03-11 16:05:41+00',
  '{
    "request_id": "REQ-2026-009",
    "created_at": "2026-03-11T16:05:00Z",
    "request_channel": "portal",
    "request_language": "fr",
    "business_unit": "Marketing EMEA",
    "country": "FR",
    "site": "Paris",
    "requester_id": "USR-4109",
    "requester_role": "Digital Marketing Manager",
    "submitted_for_id": "USR-8209",
    "category_l1": "Marketing",
    "category_l2": "Search Engine Marketing (SEM)",
    "title": "SEM campaign Q2 – France launch",
    "request_text": "Besoin d''une agence SEM pour la campagne de lancement Q2 en France. Budget EUR 45 000. Publicis Digital est notre partenaire habituel. Lancement au 2026-04-01.",
    "currency": "EUR",
    "budget_amount": 45000.00,
    "quantity": 1.0,
    "unit_of_measure": "campaign",
    "required_by_date": "2026-04-01",
    "preferred_supplier_mentioned": "Publicis Digital Europe",
    "incumbent_supplier": "Publicis Digital Europe",
    "contract_type_requested": "purchase",
    "delivery_countries": ["FR"],
    "data_residency_constraint": false,
    "esg_requirement": false,
    "status": "new",
    "scenario_tags": ["standard", "marketing", "incumbent"]
  }'::jsonb,
  '{
    "request_id": "REQ-2026-009",
    "processed_at": "2026-03-11T16:05:41Z",
    "request_interpretation": {
      "category_l1": "Marketing",
      "category_l2": "Search Engine Marketing (SEM)",
      "quantity": 1.0,
      "unit_of_measure": "campaign",
      "budget_amount": 45000.00,
      "currency": "EUR",
      "delivery_countries": ["FR"],
      "required_by_date": "2026-04-01",
      "data_residency_required": false,
      "esg_requirement": false,
      "preferred_supplier_stated": "Publicis Digital Europe",
      "incumbent_supplier": "Publicis Digital Europe",
      "request_language": "fr",
      "days_until_required": 21
    },
    "validation": {
      "completeness": "pass",
      "issues_detected": []
    },
    "policy_evaluation": {
      "approval_threshold": {
        "rule_applied": "AT-002",
        "basis": "Estimated contract value range: EUR 36,000.00–45,000.00",
        "quotes_required": 2,
        "approvers": ["business", "procurement"],
        "deviation_approval": ["Procurement Manager"]
      },
      "preferred_supplier": {
        "supplier": "Publicis Digital Europe",
        "supplier_id": "SUP-0041",
        "status": "eligible",
        "is_preferred": true,
        "covers_delivery_country": true,
        "is_restricted": false,
        "policy_note": "Publicis Digital Europe is a policy-preferred supplier for Search Engine Marketing (SEM) in this region. Preferred status means inclusion in the comparison — it does not mandate single-source selection."
      },
      "restricted_suppliers": {},
      "category_rules_applied": [],
      "geography_rules_applied": []
    },
    "supplier_shortlist": [
      {
        "rank": 1,
        "supplier_id": "SUP-0041",
        "supplier_name": "Publicis Digital Europe",
        "preferred": true,
        "incumbent": true,
        "pricing_tier_applied": "0+ units",
        "unit_price_eur": 38500.00,
        "total_price_eur": 38500.00,
        "standard_lead_time_days": 5,
        "expedited_lead_time_days": 2,
        "expedited_unit_price_eur": 43200.00,
        "expedited_total_eur": 43200.00,
        "quality_score": 84,
        "risk_score": 19,
        "esg_score": 68,
        "composite_score": 82.40,
        "policy_compliant": true,
        "covers_delivery_country": true,
        "historical_precedent": true,
        "recommendation_note": "Incumbent supplier with established delivery capability. Prior award history: AWD-2025-0072, AWD-2024-0109 for Search Engine Marketing (SEM). Policy-preferred supplier. Total price EUR 38,500.00 (composite score: 82.4)"
      },
      {
        "rank": 2,
        "supplier_id": "SUP-0040",
        "supplier_name": "WPP Performance Media",
        "preferred": true,
        "incumbent": false,
        "pricing_tier_applied": "0+ units",
        "unit_price_eur": 41000.00,
        "total_price_eur": 41000.00,
        "standard_lead_time_days": 7,
        "expedited_lead_time_days": 3,
        "expedited_unit_price_eur": 46000.00,
        "expedited_total_eur": 46000.00,
        "quality_score": 85,
        "risk_score": 18,
        "esg_score": 64,
        "composite_score": 75.10,
        "policy_compliant": true,
        "covers_delivery_country": true,
        "historical_precedent": false,
        "recommendation_note": "Policy-preferred supplier. Total price EUR 41,000.00 (composite score: 75.1)"
      },
      {
        "rank": 3,
        "supplier_id": "SUP-0044",
        "supplier_name": "Artefact Analytics",
        "preferred": false,
        "incumbent": false,
        "pricing_tier_applied": "0+ units",
        "unit_price_eur": 36000.00,
        "total_price_eur": 36000.00,
        "standard_lead_time_days": 7,
        "expedited_lead_time_days": 3,
        "expedited_unit_price_eur": 40500.00,
        "expedited_total_eur": 40500.00,
        "quality_score": 87,
        "risk_score": 17,
        "esg_score": 73,
        "composite_score": 68.30,
        "policy_compliant": true,
        "covers_delivery_country": true,
        "historical_precedent": false,
        "recommendation_note": "Total price EUR 36,000.00 (composite score: 68.3)"
      }
    ],
    "suppliers_excluded": [],
    "escalations": [],
    "recommendation": {
      "status": "recommended",
      "winner": "Publicis Digital Europe",
      "winner_id": "SUP-0041",
      "total_price_eur": 38500.00,
      "rationale": "Incumbent supplier with established delivery capability. Prior award history: AWD-2025-0072, AWD-2024-0109 for Search Engine Marketing (SEM). Policy-preferred supplier. Total price EUR 38,500.00 (composite score: 82.4)"
    },
    "audit_trail": {
      "policies_checked": ["AT-002"],
      "supplier_ids_evaluated": ["SUP-0040", "SUP-0041", "SUP-0044"],
      "pricing_region": "EU",
      "scoring_weights": {"price": 0.40, "quality": 0.25, "risk": 0.20, "esg": 0.15},
      "fx_rates_used": {"EUR_CHF": 0.93, "EUR_USD": 1.08, "CHF_EUR": 1.075, "USD_EUR": 0.926},
      "data_sources_used": ["suppliers.csv", "pricing.csv", "policies.json", "historical_awards.csv"],
      "historical_awards_consulted": true,
      "historical_award_note": "AWD-2025-0072, AWD-2024-0109 show prior awards to Publicis Digital Europe for Search Engine Marketing (SEM) in this region. Prior decision used for pattern context only."
    }
  }'::jsonb,
  '[]'::jsonb,
  NULL, NULL, NULL
);

-- --------------------------------------------------------------
-- REQ-2026-010 | IT / Managed Cloud Platform | Germany | 36 months | RESOLVED
-- Originally escalated ER-003; CPO approved and awarded to Azure.
-- --------------------------------------------------------------
INSERT INTO request_records
  (request_id, status, created_at, updated_at,
   extracted_data, response_json, escalations,
   resume_from, resolved_by, resolution_note)
VALUES (
  'REQ-2026-010', 'resolved',
  '2026-02-14 11:00:00+00', '2026-03-12 09:47:00+00',
  '{
    "request_id": "REQ-2026-010",
    "created_at": "2026-02-14T11:00:00Z",
    "request_channel": "portal",
    "request_language": "en",
    "business_unit": "Group Technology",
    "country": "DE",
    "site": "Frankfurt",
    "requester_id": "USR-4110",
    "requester_role": "Head of Cloud Infrastructure",
    "submitted_for_id": "USR-8210",
    "category_l1": "IT",
    "category_l2": "Managed Cloud Platform Services",
    "title": "Core cloud platform consolidation – 3-year contract",
    "request_text": "We are consolidating our cloud platform onto a single managed service. 36-month contract, budget EUR 2 700 000. Azure Enterprise preferred based on existing EA licensing. Required go-live 2026-06-01.",
    "currency": "EUR",
    "budget_amount": 2700000.00,
    "quantity": 36.0,
    "unit_of_measure": "monthly_subscription",
    "required_by_date": "2026-06-01",
    "preferred_supplier_mentioned": "Azure Enterprise",
    "incumbent_supplier": "Azure Enterprise",
    "contract_type_requested": "framework call-off",
    "delivery_countries": ["DE"],
    "data_residency_constraint": true,
    "esg_requirement": false,
    "status": "new",
    "scenario_tags": ["high_value", "data_residency", "resolved"]
  }'::jsonb,
  '{
    "request_id": "REQ-2026-010",
    "processed_at": "2026-02-14T11:01:22Z",
    "request_interpretation": {
      "category_l1": "IT",
      "category_l2": "Managed Cloud Platform Services",
      "quantity": 36.0,
      "unit_of_measure": "monthly_subscription",
      "budget_amount": 2700000.00,
      "currency": "EUR",
      "delivery_countries": ["DE"],
      "required_by_date": "2026-06-01",
      "data_residency_required": true,
      "esg_requirement": false,
      "preferred_supplier_stated": "Azure Enterprise",
      "incumbent_supplier": "Azure Enterprise",
      "request_language": "en",
      "days_until_required": 107
    },
    "validation": {
      "completeness": "pass",
      "issues_detected": [
        {
          "issue_id": "V-001",
          "severity": "medium",
          "type": "mandatory_comparison",
          "description": "CR-001: Managed Cloud Platform contracts above EUR 100 000 require formal multi-supplier comparison. Budget EUR 2,700,000.00 EUR meets threshold.",
          "action_required": "Ensure at least 3 compliant supplier options are compared."
        }
      ]
    },
    "policy_evaluation": {
      "approval_threshold": {
        "rule_applied": "AT-004",
        "basis": "Estimated contract value range: EUR 2,484,000.00–2,808,000.00",
        "quotes_required": 3,
        "approvers": ["procurement"],
        "deviation_approval": ["Head of Strategic Sourcing"]
      },
      "preferred_supplier": {
        "supplier": "Azure Enterprise",
        "supplier_id": "SUP-0010",
        "status": "eligible",
        "is_preferred": true,
        "covers_delivery_country": true,
        "is_restricted": false,
        "policy_note": "Azure Enterprise is a policy-preferred supplier for Managed Cloud Platform Services in this region. Preferred status means inclusion in the comparison — it does not mandate single-source selection."
      },
      "restricted_suppliers": {},
      "category_rules_applied": ["CR-001"],
      "geography_rules_applied": []
    },
    "supplier_shortlist": [
      {
        "rank": 1,
        "supplier_id": "SUP-0010",
        "supplier_name": "Azure Enterprise",
        "preferred": true,
        "incumbent": true,
        "pricing_tier_applied": "0+ units",
        "unit_price_eur": 69000.00,
        "total_price_eur": 2484000.00,
        "standard_lead_time_days": 30,
        "expedited_lead_time_days": 14,
        "expedited_unit_price_eur": 77600.00,
        "expedited_total_eur": 2793600.00,
        "quality_score": 89,
        "risk_score": 12,
        "esg_score": 65,
        "composite_score": 84.60,
        "policy_compliant": true,
        "covers_delivery_country": true,
        "historical_precedent": true,
        "recommendation_note": "Incumbent supplier with established delivery capability. Prior award history: AWD-2024-0055 for Managed Cloud Platform Services. Policy-preferred supplier. Data residency supported. Total price EUR 2,484,000.00 (composite score: 84.6)"
      },
      {
        "rank": 2,
        "supplier_id": "SUP-0011",
        "supplier_name": "AWS Enterprise EMEA",
        "preferred": false,
        "incumbent": false,
        "pricing_tier_applied": "0+ units",
        "unit_price_eur": 78000.00,
        "total_price_eur": 2808000.00,
        "standard_lead_time_days": 30,
        "expedited_lead_time_days": 14,
        "expedited_unit_price_eur": 87600.00,
        "expedited_total_eur": 3153600.00,
        "quality_score": 90,
        "risk_score": 21,
        "esg_score": 62,
        "composite_score": 67.20,
        "policy_compliant": true,
        "covers_delivery_country": true,
        "historical_precedent": false,
        "recommendation_note": "Total price EUR 2,808,000.00 (composite score: 67.2)"
      },
      {
        "rank": 3,
        "supplier_id": "SUP-0012",
        "supplier_name": "Google Cloud Europe",
        "preferred": false,
        "incumbent": false,
        "pricing_tier_applied": "0+ units",
        "unit_price_eur": 72400.00,
        "total_price_eur": 2606400.00,
        "standard_lead_time_days": 30,
        "expedited_lead_time_days": 14,
        "expedited_unit_price_eur": 81400.00,
        "expedited_total_eur": 2930400.00,
        "quality_score": 89,
        "risk_score": 21,
        "esg_score": 68,
        "composite_score": 63.80,
        "policy_compliant": true,
        "covers_delivery_country": true,
        "historical_precedent": false,
        "recommendation_note": "Total price EUR 2,606,400.00 (composite score: 63.8)"
      }
    ],
    "suppliers_excluded": [
      {
        "supplier_id": "SUP-0013",
        "supplier_name": "OVHcloud Enterprise",
        "reason": "Data residency constraint active; supplier does not support data residency."
      }
    ],
    "escalations": [
      {
        "escalation_id": "ESC-001",
        "rule": "ER-003",
        "trigger": "Estimated contract value EUR 2,808,000.00 exceeds high-value threshold (EUR 500,000). Requires Head of Strategic Sourcing approval.",
        "escalate_to": "Head of Strategic Sourcing",
        "blocking": true
      }
    ],
    "recommendation": {
      "status": "cannot_proceed",
      "reason": "1 blocking issue(s) prevent autonomous award: Estimated contract value EUR 2,808,000.00 exceeds high-value threshold (EUR 500,000). Requires Head of Strategic Sourcing approval.",
      "preferred_supplier_if_resolved": "Azure Enterprise",
      "preferred_supplier_rationale": "Incumbent supplier with established delivery capability. Policy-preferred supplier. Data residency supported. Total price EUR 2,484,000.00 (composite score: 84.6)",
      "minimum_budget_required": 2484000.00,
      "minimum_budget_currency": "EUR"
    },
    "audit_trail": {
      "policies_checked": ["AT-004", "CR-001", "ER-003"],
      "supplier_ids_evaluated": ["SUP-0010", "SUP-0011", "SUP-0012", "SUP-0013"],
      "pricing_region": "EU",
      "scoring_weights": {"price": 0.40, "quality": 0.25, "risk": 0.20, "esg": 0.15},
      "fx_rates_used": {"EUR_CHF": 0.93, "EUR_USD": 1.08, "CHF_EUR": 1.075, "USD_EUR": 0.926},
      "data_sources_used": ["suppliers.csv", "pricing.csv", "policies.json", "historical_awards.csv"],
      "historical_awards_consulted": true,
      "historical_award_note": "AWD-2024-0055 show prior awards to Azure Enterprise for Managed Cloud Platform Services in this region. Prior decision used for pattern context only."
    }
  }'::jsonb,
  '[
    {
      "escalation_id": "ESC-001",
      "rule": "ER-003",
      "trigger": "Estimated contract value EUR 2,808,000.00 exceeds high-value threshold (EUR 500,000). Requires Head of Strategic Sourcing approval.",
      "escalate_to": "Head of Strategic Sourcing",
      "blocking": true
    }
  ]'::jsonb,
  'state4',
  'Sarah Chen (CPO)',
  'High-value cloud contract reviewed at CPO level on 2026-03-10. Approved for award to Azure Enterprise (incumbent, data-residency compliant). Three-year term with break clause at 18 months. Sourcing committee minutes ref. SC-2026-014.'
);

-- --------------------------------------------------------------
-- REQ-2026-011 | IT / Mobile Workstations | Netherlands | 20 units | completed
-- Small order. Dell wins. AT-002.
-- --------------------------------------------------------------
INSERT INTO request_records
  (request_id, status, created_at, updated_at,
   extracted_data, response_json, escalations,
   resume_from, resolved_by, resolution_note)
VALUES (
  'REQ-2026-011', 'completed',
  '2026-03-13 14:40:00+00', '2026-03-13 14:40:49+00',
  '{
    "request_id": "REQ-2026-011",
    "created_at": "2026-03-13T14:40:00Z",
    "request_channel": "teams",
    "request_language": "en",
    "business_unit": "Field Operations EU",
    "country": "NL",
    "site": "Rotterdam",
    "requester_id": "USR-4111",
    "requester_role": "Field Services Lead",
    "submitted_for_id": "USR-8211",
    "category_l1": "IT",
    "category_l2": "Mobile Workstations",
    "title": "Mobile workstations for field engineering team",
    "request_text": "Need 20 rugged mobile workstations for our field engineering team in Rotterdam. Budget EUR 28 000. Delivery by 2026-04-10.",
    "currency": "EUR",
    "budget_amount": 28000.00,
    "quantity": 20.0,
    "unit_of_measure": "unit",
    "required_by_date": "2026-04-10",
    "preferred_supplier_mentioned": null,
    "incumbent_supplier": "Dell Enterprise Europe",
    "contract_type_requested": "purchase",
    "delivery_countries": ["NL"],
    "data_residency_constraint": false,
    "esg_requirement": false,
    "status": "new",
    "scenario_tags": ["standard"]
  }'::jsonb,
  '{
    "request_id": "REQ-2026-011",
    "processed_at": "2026-03-13T14:40:49Z",
    "request_interpretation": {
      "category_l1": "IT",
      "category_l2": "Mobile Workstations",
      "quantity": 20.0,
      "unit_of_measure": "unit",
      "budget_amount": 28000.00,
      "currency": "EUR",
      "delivery_countries": ["NL"],
      "required_by_date": "2026-04-10",
      "data_residency_required": false,
      "esg_requirement": false,
      "preferred_supplier_stated": null,
      "incumbent_supplier": "Dell Enterprise Europe",
      "request_language": "en",
      "days_until_required": 28
    },
    "validation": {
      "completeness": "pass",
      "issues_detected": []
    },
    "policy_evaluation": {
      "approval_threshold": {
        "rule_applied": "AT-002",
        "basis": "Estimated contract value range: EUR 25,400.00–28,200.00",
        "quotes_required": 2,
        "approvers": ["business", "procurement"],
        "deviation_approval": ["Procurement Manager"]
      },
      "preferred_supplier": {
        "supplier": null
      },
      "restricted_suppliers": {
        "SUP-0008": {
          "supplier_name": "Computacenter Devices",
          "restricted": true,
          "reason": "Restricted for selected categories and countries in policy set"
        }
      },
      "category_rules_applied": [],
      "geography_rules_applied": []
    },
    "supplier_shortlist": [
      {
        "rank": 1,
        "supplier_id": "SUP-0001",
        "supplier_name": "Dell Enterprise Europe",
        "preferred": true,
        "incumbent": true,
        "pricing_tier_applied": "0–50 units",
        "unit_price_eur": 1270.00,
        "total_price_eur": 25400.00,
        "standard_lead_time_days": 12,
        "expedited_lead_time_days": 6,
        "expedited_unit_price_eur": 1430.00,
        "expedited_total_eur": 28600.00,
        "quality_score": 85,
        "risk_score": 15,
        "esg_score": 75,
        "composite_score": 89.20,
        "policy_compliant": true,
        "covers_delivery_country": true,
        "historical_precedent": true,
        "recommendation_note": "Incumbent supplier with established delivery capability. Prior award history: AWD-2025-0044 for Mobile Workstations. Policy-preferred supplier. Total price EUR 25,400.00 (composite score: 89.2)"
      },
      {
        "rank": 2,
        "supplier_id": "SUP-0002",
        "supplier_name": "HP Enterprise Devices",
        "preferred": true,
        "incumbent": false,
        "pricing_tier_applied": "0–50 units",
        "unit_price_eur": 1410.00,
        "total_price_eur": 28200.00,
        "standard_lead_time_days": 14,
        "expedited_lead_time_days": 7,
        "expedited_unit_price_eur": 1585.00,
        "expedited_total_eur": 31700.00,
        "quality_score": 83,
        "risk_score": 18,
        "esg_score": 74,
        "composite_score": 74.60,
        "policy_compliant": true,
        "covers_delivery_country": true,
        "historical_precedent": false,
        "recommendation_note": "Policy-preferred supplier. Total price EUR 28,200.00 (composite score: 74.6)"
      }
    ],
    "suppliers_excluded": [
      {
        "supplier_id": "SUP-0008",
        "supplier_name": "Computacenter Devices",
        "reason": "Restricted for Mobile Workstations in [\"NL\"]: Restricted for selected categories and countries in policy set"
      }
    ],
    "escalations": [],
    "recommendation": {
      "status": "recommended",
      "winner": "Dell Enterprise Europe",
      "winner_id": "SUP-0001",
      "total_price_eur": 25400.00,
      "rationale": "Incumbent supplier with established delivery capability. Prior award history: AWD-2025-0044 for Mobile Workstations. Policy-preferred supplier. Total price EUR 25,400.00 (composite score: 89.2)"
    },
    "audit_trail": {
      "policies_checked": ["AT-002"],
      "supplier_ids_evaluated": ["SUP-0001", "SUP-0002", "SUP-0008"],
      "pricing_region": "EU",
      "scoring_weights": {"price": 0.40, "quality": 0.25, "risk": 0.20, "esg": 0.15},
      "fx_rates_used": {"EUR_CHF": 0.93, "EUR_USD": 1.08, "CHF_EUR": 1.075, "USD_EUR": 0.926},
      "data_sources_used": ["suppliers.csv", "pricing.csv", "policies.json", "historical_awards.csv"],
      "historical_awards_consulted": true,
      "historical_award_note": "AWD-2025-0044 show prior awards to Dell Enterprise Europe for Mobile Workstations in this region. Prior decision used for pattern context only."
    }
  }'::jsonb,
  '[]'::jsonb,
  NULL, NULL, NULL
);

-- --------------------------------------------------------------
-- REQ-2026-012 | Marketing / Influencer Campaign | Spain | ESCALATED
-- ER-007: brand-safety review mandatory. Boutique Creator Network conditional restriction.
-- --------------------------------------------------------------
INSERT INTO request_records
  (request_id, status, created_at, updated_at,
   extracted_data, response_json, escalations,
   resume_from, resolved_by, resolution_note)
VALUES (
  'REQ-2026-012', 'escalated',
  '2026-03-14 10:22:00+00', '2026-03-14 10:22:58+00',
  '{
    "request_id": "REQ-2026-012",
    "created_at": "2026-03-14T10:22:00Z",
    "request_channel": "teams",
    "request_language": "es",
    "business_unit": "Marketing EMEA",
    "country": "ES",
    "site": "Barcelona",
    "requester_id": "USR-4112",
    "requester_role": "Brand Manager",
    "submitted_for_id": "USR-8212",
    "category_l1": "Marketing",
    "category_l2": "Influencer Campaign Management",
    "title": "Influencer campaign – Spain product launch",
    "request_text": "Necesitamos una agencia para gestionar una campaña de influencers para el lanzamiento de producto en España. Presupuesto EUR 60 000. Boutique Creator Network es nuestra preferencia. Fecha límite 2026-05-01.",
    "currency": "EUR",
    "budget_amount": 60000.00,
    "quantity": 1.0,
    "unit_of_measure": "campaign",
    "required_by_date": "2026-05-01",
    "preferred_supplier_mentioned": "Boutique Creator Network",
    "incumbent_supplier": null,
    "contract_type_requested": "purchase",
    "delivery_countries": ["ES"],
    "data_residency_constraint": false,
    "esg_requirement": false,
    "status": "new",
    "scenario_tags": ["brand_safety", "influencer", "restricted"]
  }'::jsonb,
  '{
    "request_id": "REQ-2026-012",
    "processed_at": "2026-03-14T10:22:58Z",
    "request_interpretation": {
      "category_l1": "Marketing",
      "category_l2": "Influencer Campaign Management",
      "quantity": 1.0,
      "unit_of_measure": "campaign",
      "budget_amount": 60000.00,
      "currency": "EUR",
      "delivery_countries": ["ES"],
      "required_by_date": "2026-05-01",
      "data_residency_required": false,
      "esg_requirement": false,
      "preferred_supplier_stated": "Boutique Creator Network",
      "incumbent_supplier": null,
      "request_language": "es",
      "days_until_required": 48
    },
    "validation": {
      "completeness": "pass",
      "issues_detected": []
    },
    "policy_evaluation": {
      "approval_threshold": {
        "rule_applied": "AT-002",
        "basis": "Estimated contract value range: EUR 48,000.00–60,000.00",
        "quotes_required": 2,
        "approvers": ["business", "procurement"],
        "deviation_approval": ["Procurement Manager"]
      },
      "preferred_supplier": {
        "supplier": "Boutique Creator Network",
        "supplier_id": "SUP-0045",
        "status": "eligible",
        "is_preferred": false,
        "covers_delivery_country": true,
        "is_restricted": false,
        "policy_note": "Boutique Creator Network is not a policy-preferred supplier for Influencer Campaign Management in this region. Conditional: requires exception approval for contracts above EUR 75,000. Current value below conditional threshold."
      },
      "restricted_suppliers": {},
      "category_rules_applied": [],
      "geography_rules_applied": []
    },
    "supplier_shortlist": [
      {
        "rank": 1,
        "supplier_id": "SUP-0045",
        "supplier_name": "Boutique Creator Network",
        "preferred": false,
        "incumbent": false,
        "pricing_tier_applied": "0+ units",
        "unit_price_eur": 48000.00,
        "total_price_eur": 48000.00,
        "standard_lead_time_days": 10,
        "expedited_lead_time_days": 5,
        "expedited_unit_price_eur": 54000.00,
        "expedited_total_eur": 54000.00,
        "quality_score": 74,
        "risk_score": 29,
        "esg_score": 72,
        "composite_score": 74.80,
        "policy_compliant": true,
        "covers_delivery_country": true,
        "historical_precedent": false,
        "recommendation_note": "Total price EUR 48,000.00 (composite score: 74.8)"
      },
      {
        "rank": 2,
        "supplier_id": "SUP-0043",
        "supplier_name": "Monks Europe",
        "preferred": false,
        "incumbent": false,
        "pricing_tier_applied": "0+ units",
        "unit_price_eur": 60000.00,
        "total_price_eur": 60000.00,
        "standard_lead_time_days": 14,
        "expedited_lead_time_days": 7,
        "expedited_unit_price_eur": 67500.00,
        "expedited_total_eur": 67500.00,
        "quality_score": 80,
        "risk_score": 17,
        "esg_score": 72,
        "composite_score": 61.20,
        "policy_compliant": true,
        "covers_delivery_country": true,
        "historical_precedent": false,
        "recommendation_note": "Total price EUR 60,000.00 (composite score: 61.2)"
      }
    ],
    "suppliers_excluded": [],
    "escalations": [
      {
        "escalation_id": "ESC-001",
        "rule": "ER-007",
        "trigger": "Influencer Campaign Management requires brand-safety review before final award. Human approval is mandatory per CR-010.",
        "escalate_to": "Marketing Governance Lead",
        "blocking": true
      }
    ],
    "recommendation": {
      "status": "cannot_proceed",
      "reason": "1 blocking issue(s) prevent autonomous award: Influencer Campaign Management requires brand-safety review before final award. Human approval is mandatory per CR-010.",
      "preferred_supplier_if_resolved": "Boutique Creator Network",
      "preferred_supplier_rationale": "Total price EUR 48,000.00 (composite score: 74.8)",
      "minimum_budget_required": 48000.00,
      "minimum_budget_currency": "EUR"
    },
    "audit_trail": {
      "policies_checked": ["AT-002", "ER-007"],
      "supplier_ids_evaluated": ["SUP-0043", "SUP-0045"],
      "pricing_region": "EU",
      "scoring_weights": {"price": 0.40, "quality": 0.25, "risk": 0.20, "esg": 0.15},
      "fx_rates_used": {"EUR_CHF": 0.93, "EUR_USD": 1.08, "CHF_EUR": 1.075, "USD_EUR": 0.926},
      "data_sources_used": ["suppliers.csv", "pricing.csv", "policies.json", "historical_awards.csv"],
      "historical_awards_consulted": false,
      "historical_award_note": null
    }
  }'::jsonb,
  '[
    {
      "escalation_id": "ESC-001",
      "rule": "ER-007",
      "trigger": "Influencer Campaign Management requires brand-safety review before final award. Human approval is mandatory per CR-010.",
      "escalate_to": "Marketing Governance Lead",
      "blocking": true
    }
  ]'::jsonb,
  'state3', NULL, NULL
);

COMMIT;
