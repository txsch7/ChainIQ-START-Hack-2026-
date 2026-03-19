-- Seed: mock procurement requests
-- Translated from frontend mockData.ts (12 requests)
-- Timestamps are relative to execution time via NOW() + INTERVAL
-- Run after 001_schema (CREATE TABLE IF NOT EXISTS is handled by init_db on startup)

INSERT INTO request_records
    (request_id, status, created_at, updated_at, extracted_data, response_json, escalations, resume_from)
VALUES

-- ─────────────────────────────────────────────────────────────────────────────
-- REQ-000001 · IT / Hardware Laptops · escalated (ER-002: preferred≠incumbent)
-- ─────────────────────────────────────────────────────────────────────────────
(
  'REQ-000001', 'escalated',
  NOW() - INTERVAL '2 hours', NOW() - INTERVAL '2 hours',
  $ext1${
    "request_id": "REQ-000001",
    "request_channel": "portal", "request_language": "en",
    "business_unit": "Corporate IT", "country": "Switzerland",
    "category_l1": "IT", "category_l2": "Hardware - Laptops",
    "request_text": "We need 150 enterprise laptops for the new Zurich office expansion. Minimum specs: i7, 16GB RAM, 512GB SSD. Must include docking stations and monitors. Delivery to Zurich and Geneva offices.",
    "quantity": 150, "unit_of_measure": "units",
    "currency": "CHF", "budget_amount": 375000,
    "required_by_date": "2026-04-18",
    "preferred_supplier_mentioned": "Dell Technologies",
    "incumbent_supplier": "Lenovo",
    "delivery_countries": ["Switzerland"],
    "data_residency_constraint": false, "esg_requirement": true
  }$ext1$::jsonb,
  $rsp1${
    "request_id": "REQ-000001",
    "processed_at": "2026-03-19T10:00:00Z",
    "request_interpretation": {
      "category_l1": "IT", "category_l2": "Hardware - Laptops",
      "quantity": 150, "unit_of_measure": "units",
      "budget_amount": 375000, "currency": "CHF",
      "delivery_countries": ["Switzerland"],
      "required_by_date": "2026-04-18",
      "data_residency_required": false, "esg_requirement": true,
      "preferred_supplier_stated": "Dell Technologies",
      "incumbent_supplier": "Lenovo",
      "request_language": "en", "days_until_required": 30
    },
    "validation": {
      "completeness": "pass",
      "issues_detected": []
    },
    "policy_evaluation": {
      "approval_threshold": {"result": "within_limit", "threshold_eur": 500000, "request_value_eur": 375000},
      "preferred_supplier": {"stated": "Dell Technologies", "in_approved_list": true, "conflict_with_incumbent": true},
      "restricted_suppliers": {},
      "category_rules_applied": ["prefer_incumbent_unless_significant_saving", "esg_required"],
      "geography_rules_applied": ["ch_delivery_approved"]
    },
    "supplier_shortlist": [
      {"rank": 1, "supplier_id": "SUP-000001-01", "supplier_name": "Dell Technologies", "preferred": true,  "incumbent": false, "pricing_tier_applied": "Tier 3: 100+ units", "unit_price_eur": null, "total_price_eur": 356250, "quality_score": 88, "risk_score": 85, "esg_score": 78, "composite_score": 85, "policy_compliant": true,  "covers_delivery_country": true, "historical_precedent": false, "recommendation_note": "Strong enterprise portfolio. Volume discount available."},
      {"rank": 2, "supplier_id": "SUP-000001-02", "supplier_name": "Lenovo",             "preferred": false, "incumbent": true,  "pricing_tier_applied": "Tier 3: 100+ units", "unit_price_eur": null, "total_price_eur": 330000, "quality_score": 80, "risk_score": 82, "esg_score": 75, "composite_score": 82, "policy_compliant": true,  "covers_delivery_country": true, "historical_precedent": true,  "recommendation_note": "Incumbent supplier. Competitive pricing on volume."},
      {"rank": 3, "supplier_id": "SUP-000001-03", "supplier_name": "HP Inc.",            "preferred": false, "incumbent": false, "pricing_tier_applied": "Tier 3: 100+ units", "unit_price_eur": null, "total_price_eur": 382500, "quality_score": 82, "risk_score": 80, "esg_score": 80, "composite_score": 79, "policy_compliant": true,  "covers_delivery_country": true, "historical_precedent": false, "recommendation_note": "Good ESG rating. Slightly higher pricing."}
    ],
    "suppliers_excluded": [
      {"supplier_id": "SUP-000001-04", "supplier_name": "Huawei Enterprise", "reason": "Supplier is on restricted list due to geopolitical compliance requirements."}
    ],
    "escalations": [
      {"escalation_id": "REQ-000001-ESC-01", "rule": "ER-002", "trigger": "Preferred/incumbent supplier conflict", "escalate_to": "category_manager", "blocking": true}
    ],
    "recommendation": {"status": "escalated", "recommended_supplier": null, "rationale": "Supplier conflict between preferred (Dell Technologies) and incumbent (Lenovo) requires human decision."},
    "audit_trail": [
      {"step_id": "REQ-000001-S01", "timestamp": "2026-03-19T10:00:15Z", "step_type": "parsing",       "title": "Request Parsed",           "outcome": "pass",    "confidence_score": 0.95, "triggered_rule": null},
      {"step_id": "REQ-000001-S02", "timestamp": "2026-03-19T10:00:30Z", "step_type": "interpretation", "title": "Intent Classification",    "outcome": "pass",    "confidence_score": 0.88, "triggered_rule": null},
      {"step_id": "REQ-000001-S03", "timestamp": "2026-03-19T10:00:45Z", "step_type": "validation",     "title": "Data Completeness Check",  "outcome": "pass",    "confidence_score": 0.92, "triggered_rule": null},
      {"step_id": "REQ-000001-S04", "timestamp": "2026-03-19T10:01:00Z", "step_type": "supplier_lookup","title": "Supplier Database Search", "outcome": "info",    "confidence_score": null, "triggered_rule": null},
      {"step_id": "REQ-000001-S05", "timestamp": "2026-03-19T10:01:15Z", "step_type": "rule_check",     "title": "Compliance & Policy Check","outcome": "escalate","confidence_score": 0.85, "triggered_rule": "ER-002"},
      {"step_id": "REQ-000001-S06", "timestamp": "2026-03-19T10:01:30Z", "step_type": "escalation",     "title": "Escalation Triggered",     "outcome": "escalate","confidence_score": null, "triggered_rule": "ER-002"},
      {"step_id": "REQ-000001-S07", "timestamp": "2026-03-19T10:01:45Z", "step_type": "decision",       "title": "Decision: Awaiting Human Review", "outcome": "escalate", "confidence_score": null, "triggered_rule": null}
    ]
  }$rsp1$::jsonb,
  $esc1$[{"escalation_id": "REQ-000001-ESC-01", "rule": "ER-002", "trigger": "Preferred/incumbent supplier conflict", "escalate_to": "category_manager", "blocking": true}]$esc1$::jsonb,
  'state3'
),

-- ─────────────────────────────────────────────────────────────────────────────
-- REQ-000002 · Facilities / Cleaning Services · escalated (ER-001: no budget)
-- ─────────────────────────────────────────────────────────────────────────────
(
  'REQ-000002', 'escalated',
  NOW() - INTERVAL '5 hours', NOW() - INTERVAL '5 hours',
  $ext2${
    "request_id": "REQ-000002",
    "request_channel": "email", "request_language": "de",
    "business_unit": "Facility Management", "country": "Germany",
    "category_l1": "Facilities", "category_l2": "Cleaning Services",
    "request_text": "Wir benötigen einen neuen Reinigungsdienstleister für unsere Büros in Frankfurt und München. Der Vertrag soll ab Q2 2025 laufen. Bitte ESG-zertifizierte Anbieter bevorzugen.",
    "quantity": null, "unit_of_measure": null,
    "currency": "EUR", "budget_amount": null,
    "required_by_date": "2026-03-24",
    "preferred_supplier_mentioned": null,
    "incumbent_supplier": "ISS Facilities",
    "delivery_countries": ["Germany"],
    "data_residency_constraint": false, "esg_requirement": true
  }$ext2$::jsonb,
  $rsp2${
    "request_id": "REQ-000002",
    "processed_at": "2026-03-19T07:00:00Z",
    "request_interpretation": {
      "category_l1": "Facilities", "category_l2": "Cleaning Services",
      "quantity": null, "unit_of_measure": null,
      "budget_amount": null, "currency": "EUR",
      "delivery_countries": ["Germany"],
      "required_by_date": "2026-03-24",
      "data_residency_required": false, "esg_requirement": true,
      "preferred_supplier_stated": null,
      "incumbent_supplier": "ISS Facilities",
      "request_language": "de", "days_until_required": 5
    },
    "validation": {
      "completeness": "fail",
      "issues_detected": [
        {"issue_id": "V-001", "severity": "high", "type": "missing_field", "description": "Budget amount is required for automated processing.", "action_required": "Provide budget estimate or spend range."}
      ]
    },
    "policy_evaluation": {
      "approval_threshold": {"result": "unknown", "threshold_eur": null, "request_value_eur": null},
      "preferred_supplier": {"stated": null, "in_approved_list": null, "conflict_with_incumbent": false},
      "restricted_suppliers": {},
      "category_rules_applied": ["esg_required"],
      "geography_rules_applied": ["de_delivery_approved"]
    },
    "supplier_shortlist": [
      {"rank": 1, "supplier_id": "SUP-000002-02", "supplier_name": "Sodexo",       "preferred": false, "incumbent": false, "pricing_tier_applied": null, "unit_price_eur": null, "total_price_eur": 171000, "quality_score": 82, "risk_score": 85, "esg_score": 90, "composite_score": 83, "policy_compliant": true,  "covers_delivery_country": true, "historical_precedent": false, "recommendation_note": "Top ESG performer. Competitive offering."},
      {"rank": 2, "supplier_id": "SUP-000002-01", "supplier_name": "ISS Facilities","preferred": false, "incumbent": true,  "pricing_tier_applied": null, "unit_price_eur": null, "total_price_eur": 165000, "quality_score": 85, "risk_score": 82, "esg_score": 88, "composite_score": 80, "policy_compliant": true,  "covers_delivery_country": true, "historical_precedent": true,  "recommendation_note": "Incumbent with strong ESG credentials."},
      {"rank": 3, "supplier_id": "SUP-000002-03", "supplier_name": "CBRE",          "preferred": false, "incumbent": false, "pricing_tier_applied": null, "unit_price_eur": null, "total_price_eur": 189000, "quality_score": 80, "risk_score": 80, "esg_score": 78, "composite_score": 77, "policy_compliant": true,  "covers_delivery_country": true, "historical_precedent": false, "recommendation_note": "Global presence. Higher pricing tier."}
    ],
    "suppliers_excluded": [
      {"supplier_id": "SUP-000002-04", "supplier_name": "Local Facility Co.", "reason": "ESG certification missing. Quality score below threshold."}
    ],
    "escalations": [
      {"escalation_id": "REQ-000002-ESC-01", "rule": "ER-001", "trigger": "Missing budget information", "escalate_to": "procurement_ops", "blocking": true}
    ],
    "recommendation": {"status": "escalated", "recommended_supplier": null, "rationale": "Budget amount missing — cannot evaluate financial thresholds or approval tier."},
    "audit_trail": [
      {"step_id": "REQ-000002-S01", "timestamp": "2026-03-19T07:00:15Z", "step_type": "parsing",       "title": "Request Parsed",           "outcome": "pass",    "confidence_score": 0.92, "triggered_rule": null},
      {"step_id": "REQ-000002-S02", "timestamp": "2026-03-19T07:00:30Z", "step_type": "interpretation", "title": "Intent Classification",    "outcome": "pass",    "confidence_score": 0.87, "triggered_rule": null},
      {"step_id": "REQ-000002-S03", "timestamp": "2026-03-19T07:00:45Z", "step_type": "validation",     "title": "Data Completeness Check",  "outcome": "fail",    "confidence_score": 0.92, "triggered_rule": "ER-001"},
      {"step_id": "REQ-000002-S04", "timestamp": "2026-03-19T07:01:00Z", "step_type": "escalation",     "title": "Escalation Triggered",     "outcome": "escalate","confidence_score": null, "triggered_rule": "ER-001"},
      {"step_id": "REQ-000002-S05", "timestamp": "2026-03-19T07:01:15Z", "step_type": "decision",       "title": "Decision: Awaiting Human Review", "outcome": "escalate", "confidence_score": null, "triggered_rule": null}
    ]
  }$rsp2$::jsonb,
  $esc2$[{"escalation_id": "REQ-000002-ESC-01", "rule": "ER-001", "trigger": "Missing budget information", "escalate_to": "procurement_ops", "blocking": true}]$esc2$::jsonb,
  'state2'
),

-- ─────────────────────────────────────────────────────────────────────────────
-- REQ-000003 · Professional Services / Management Consulting · completed
-- ─────────────────────────────────────────────────────────────────────────────
(
  'REQ-000003', 'completed',
  NOW() - INTERVAL '24 hours', NOW() - INTERVAL '24 hours',
  $ext3${
    "request_id": "REQ-000003",
    "request_channel": "teams", "request_language": "fr",
    "business_unit": "Strategy & Consulting", "country": "France",
    "category_l1": "Professional Services", "category_l2": "Management Consulting",
    "request_text": "Besoin d'un cabinet de conseil pour un projet de transformation digitale. Budget estimé entre 200k et 300k EUR. Durée prévue: 6 mois. Expertise requise en supply chain et procurement.",
    "quantity": 1, "unit_of_measure": "project",
    "currency": "EUR", "budget_amount": 280000,
    "required_by_date": "2026-04-09",
    "preferred_supplier_mentioned": "Accenture",
    "incumbent_supplier": "Accenture",
    "delivery_countries": ["France"],
    "data_residency_constraint": false, "esg_requirement": false
  }$ext3$::jsonb,
  $rsp3${
    "request_id": "REQ-000003",
    "processed_at": "2026-03-18T12:00:00Z",
    "request_interpretation": {
      "category_l1": "Professional Services", "category_l2": "Management Consulting",
      "quantity": 1, "unit_of_measure": "project",
      "budget_amount": 280000, "currency": "EUR",
      "delivery_countries": ["France"],
      "required_by_date": "2026-04-09",
      "data_residency_required": false, "esg_requirement": false,
      "preferred_supplier_stated": "Accenture",
      "incumbent_supplier": "Accenture",
      "request_language": "fr", "days_until_required": 21
    },
    "validation": {"completeness": "pass", "issues_detected": []},
    "policy_evaluation": {
      "approval_threshold": {"result": "within_limit", "threshold_eur": 500000, "request_value_eur": 280000},
      "preferred_supplier": {"stated": "Accenture", "in_approved_list": true, "conflict_with_incumbent": false},
      "restricted_suppliers": {},
      "category_rules_applied": ["strategic_tier_preferred", "incumbent_continuity"],
      "geography_rules_applied": ["fr_delivery_approved"]
    },
    "supplier_shortlist": [
      {"rank": 1, "supplier_id": "SUP-000003-01", "supplier_name": "Accenture", "preferred": true,  "incumbent": true,  "pricing_tier_applied": "Tier 1: Strategic", "unit_price_eur": null, "total_price_eur": 308000, "quality_score": 95, "risk_score": 90, "esg_score": 85, "composite_score": 88, "policy_compliant": true, "covers_delivery_country": true, "historical_precedent": true,  "recommendation_note": "Premium consulting partner. Preferred and incumbent — strong continuity case."},
      {"rank": 2, "supplier_id": "SUP-000003-02", "supplier_name": "Deloitte",  "preferred": false, "incumbent": false, "pricing_tier_applied": "Tier 1: Strategic", "unit_price_eur": null, "total_price_eur": 274400, "quality_score": 90, "risk_score": 88, "esg_score": 82, "composite_score": 85, "policy_compliant": true, "covers_delivery_country": true, "historical_precedent": false, "recommendation_note": "Strong track record in procurement transformation."},
      {"rank": 3, "supplier_id": "SUP-000003-03", "supplier_name": "KPMG",     "preferred": false, "incumbent": false, "pricing_tier_applied": "Tier 1: Strategic", "unit_price_eur": null, "total_price_eur": 260400, "quality_score": 85, "risk_score": 82, "esg_score": 78, "composite_score": 81, "policy_compliant": true, "covers_delivery_country": true, "historical_precedent": false, "recommendation_note": "Competitive pricing. Good availability."}
    ],
    "suppliers_excluded": [],
    "escalations": [],
    "recommendation": {"status": "approved", "recommended_supplier": "Accenture", "rationale": "Top-ranked supplier with composite score 88/100. Preferred and incumbent — no conflict. Budget within threshold."},
    "audit_trail": [
      {"step_id": "REQ-000003-S01", "timestamp": "2026-03-18T12:00:15Z", "step_type": "parsing",        "title": "Request Parsed",           "outcome": "pass", "confidence_score": 0.95, "triggered_rule": null},
      {"step_id": "REQ-000003-S02", "timestamp": "2026-03-18T12:00:30Z", "step_type": "interpretation",  "title": "Intent Classification",    "outcome": "pass", "confidence_score": 0.91, "triggered_rule": null},
      {"step_id": "REQ-000003-S03", "timestamp": "2026-03-18T12:00:45Z", "step_type": "validation",      "title": "Data Completeness Check",  "outcome": "pass", "confidence_score": 0.97, "triggered_rule": null},
      {"step_id": "REQ-000003-S04", "timestamp": "2026-03-18T12:01:00Z", "step_type": "supplier_lookup", "title": "Supplier Database Search", "outcome": "info", "confidence_score": null, "triggered_rule": null},
      {"step_id": "REQ-000003-S05", "timestamp": "2026-03-18T12:01:15Z", "step_type": "rule_check",      "title": "Compliance & Policy Check","outcome": "pass", "confidence_score": 0.89, "triggered_rule": null},
      {"step_id": "REQ-000003-S06", "timestamp": "2026-03-18T12:01:30Z", "step_type": "scoring",         "title": "Supplier Scoring",         "outcome": "pass", "confidence_score": 0.93, "triggered_rule": null},
      {"step_id": "REQ-000003-S07", "timestamp": "2026-03-18T12:01:45Z", "step_type": "comparison",      "title": "Supplier Comparison",      "outcome": "pass", "confidence_score": 0.91, "triggered_rule": null},
      {"step_id": "REQ-000003-S08", "timestamp": "2026-03-18T12:02:00Z", "step_type": "decision",        "title": "Decision: Approved",       "outcome": "pass", "confidence_score": 0.94, "triggered_rule": null}
    ]
  }$rsp3$::jsonb,
  $esc3$[]$esc3$::jsonb,
  null
),

-- ─────────────────────────────────────────────────────────────────────────────
-- REQ-000004 · Marketing / Digital Advertising · escalated (ER-002)
-- ─────────────────────────────────────────────────────────────────────────────
(
  'REQ-000004', 'escalated',
  NOW() - INTERVAL '3 days', NOW() - INTERVAL '3 days',
  $ext4${
    "request_id": "REQ-000004",
    "request_channel": "portal", "request_language": "en",
    "business_unit": "Marketing EMEA", "country": "United Kingdom",
    "category_l1": "Marketing", "category_l2": "Digital Advertising",
    "request_text": "Need a creative agency for our Q3 brand campaign across DACH and UK markets. Must have experience with B2B procurement brands. Deliverables: social media, display ads, video content.",
    "quantity": 1, "unit_of_measure": "campaign",
    "currency": "EUR", "budget_amount": 95000,
    "required_by_date": "2026-04-02",
    "preferred_supplier_mentioned": "WPP",
    "incumbent_supplier": "Publicis",
    "delivery_countries": ["United Kingdom", "Germany", "Austria", "Switzerland"],
    "data_residency_constraint": false, "esg_requirement": false
  }$ext4$::jsonb,
  $rsp4${
    "request_id": "REQ-000004",
    "processed_at": "2026-03-16T12:00:00Z",
    "request_interpretation": {
      "category_l1": "Marketing", "category_l2": "Digital Advertising",
      "quantity": 1, "unit_of_measure": "campaign",
      "budget_amount": 95000, "currency": "EUR",
      "delivery_countries": ["United Kingdom", "Germany", "Austria", "Switzerland"],
      "required_by_date": "2026-04-02",
      "data_residency_required": false, "esg_requirement": false,
      "preferred_supplier_stated": "WPP",
      "incumbent_supplier": "Publicis",
      "request_language": "en", "days_until_required": 14
    },
    "validation": {"completeness": "pass", "issues_detected": []},
    "policy_evaluation": {
      "approval_threshold": {"result": "within_limit", "threshold_eur": 500000, "request_value_eur": 95000},
      "preferred_supplier": {"stated": "WPP", "in_approved_list": true, "conflict_with_incumbent": true},
      "restricted_suppliers": {},
      "category_rules_applied": ["multi_country_review"],
      "geography_rules_applied": ["uk_de_at_ch_delivery_approved"]
    },
    "supplier_shortlist": [
      {"rank": 1, "supplier_id": "SUP-000004-01", "supplier_name": "WPP",            "preferred": true,  "incumbent": false, "pricing_tier_applied": null, "unit_price_eur": null, "total_price_eur": 92150,  "quality_score": 88, "risk_score": 85, "esg_score": 80, "composite_score": 84, "policy_compliant": true, "covers_delivery_country": true, "historical_precedent": false, "recommendation_note": "Global network. Strong B2B capabilities."},
      {"rank": 2, "supplier_id": "SUP-000004-02", "supplier_name": "Publicis Groupe","preferred": false, "incumbent": true,  "pricing_tier_applied": null, "unit_price_eur": null, "total_price_eur": 85500,  "quality_score": 82, "risk_score": 80, "esg_score": 78, "composite_score": 81, "policy_compliant": true, "covers_delivery_country": true, "historical_precedent": true,  "recommendation_note": "Incumbent agency. Cost-effective option."},
      {"rank": 3, "supplier_id": "SUP-000004-03", "supplier_name": "Omnicom Group",  "preferred": false, "incumbent": false, "pricing_tier_applied": null, "unit_price_eur": null, "total_price_eur": 102600, "quality_score": 80, "risk_score": 78, "esg_score": 76, "composite_score": 78, "policy_compliant": true, "covers_delivery_country": true, "historical_precedent": false, "recommendation_note": "Premium positioning. Higher cost."}
    ],
    "suppliers_excluded": [
      {"supplier_id": "SUP-000004-04", "supplier_name": "Local Creative Studio", "reason": "Insufficient scale for multi-market campaign. No B2B procurement brand experience."}
    ],
    "escalations": [
      {"escalation_id": "REQ-000004-ESC-01", "rule": "ER-002", "trigger": "Preferred/incumbent supplier conflict", "escalate_to": "category_manager", "blocking": true}
    ],
    "recommendation": {"status": "escalated", "recommended_supplier": null, "rationale": "Conflict between preferred (WPP) and incumbent (Publicis) requires category manager decision."},
    "audit_trail": [
      {"step_id": "REQ-000004-S01", "timestamp": "2026-03-16T12:00:15Z", "step_type": "parsing",       "title": "Request Parsed",           "outcome": "pass",    "confidence_score": 0.93, "triggered_rule": null},
      {"step_id": "REQ-000004-S02", "timestamp": "2026-03-16T12:00:30Z", "step_type": "interpretation", "title": "Intent Classification",    "outcome": "pass",    "confidence_score": 0.86, "triggered_rule": null},
      {"step_id": "REQ-000004-S03", "timestamp": "2026-03-16T12:00:45Z", "step_type": "validation",     "title": "Data Completeness Check",  "outcome": "pass",    "confidence_score": 0.94, "triggered_rule": null},
      {"step_id": "REQ-000004-S04", "timestamp": "2026-03-16T12:01:00Z", "step_type": "supplier_lookup","title": "Supplier Database Search", "outcome": "info",    "confidence_score": null, "triggered_rule": null},
      {"step_id": "REQ-000004-S05", "timestamp": "2026-03-16T12:01:15Z", "step_type": "rule_check",     "title": "Compliance & Policy Check","outcome": "escalate","confidence_score": 0.85, "triggered_rule": "ER-002"},
      {"step_id": "REQ-000004-S06", "timestamp": "2026-03-16T12:01:30Z", "step_type": "escalation",     "title": "Escalation Triggered",     "outcome": "escalate","confidence_score": null, "triggered_rule": "ER-002"},
      {"step_id": "REQ-000004-S07", "timestamp": "2026-03-16T12:01:45Z", "step_type": "decision",       "title": "Decision: Awaiting Human Review", "outcome": "escalate", "confidence_score": null, "triggered_rule": null}
    ]
  }$rsp4$::jsonb,
  $esc4$[{"escalation_id": "REQ-000004-ESC-01", "rule": "ER-002", "trigger": "Preferred/incumbent supplier conflict", "escalate_to": "category_manager", "blocking": true}]$esc4$::jsonb,
  'state3'
),

-- ─────────────────────────────────────────────────────────────────────────────
-- REQ-000005 · IT / Cloud Services · escalated (ER-002, ER-003, ER-005)
-- ─────────────────────────────────────────────────────────────────────────────
(
  'REQ-000005', 'escalated',
  NOW() - INTERVAL '8 hours', NOW() - INTERVAL '8 hours',
  $ext5${
    "request_id": "REQ-000005",
    "request_channel": "email", "request_language": "en",
    "business_unit": "Cloud Infrastructure", "country": "Switzerland",
    "category_l1": "IT", "category_l2": "Cloud Services",
    "request_text": "Procurement of cloud hosting services for our new analytics platform. Strict data residency requirement - all data must remain within EU/CH borders. Need dedicated instances with SLA 99.95%.",
    "quantity": null, "unit_of_measure": null,
    "currency": "CHF", "budget_amount": 520000,
    "required_by_date": "2026-05-03",
    "preferred_supplier_mentioned": "AWS",
    "incumbent_supplier": "Azure",
    "delivery_countries": ["Switzerland", "Germany"],
    "data_residency_constraint": true, "esg_requirement": true
  }$ext5$::jsonb,
  $rsp5${
    "request_id": "REQ-000005",
    "processed_at": "2026-03-19T04:00:00Z",
    "request_interpretation": {
      "category_l1": "IT", "category_l2": "Cloud Services",
      "quantity": null, "unit_of_measure": null,
      "budget_amount": 520000, "currency": "CHF",
      "delivery_countries": ["Switzerland", "Germany"],
      "required_by_date": "2026-05-03",
      "data_residency_required": true, "esg_requirement": true,
      "preferred_supplier_stated": "AWS",
      "incumbent_supplier": "Azure",
      "request_language": "en", "days_until_required": 45
    },
    "validation": {"completeness": "pass", "issues_detected": []},
    "policy_evaluation": {
      "approval_threshold": {"result": "exceeds_limit", "threshold_eur": 500000, "request_value_eur": 520000},
      "preferred_supplier": {"stated": "AWS", "in_approved_list": true, "conflict_with_incumbent": true},
      "restricted_suppliers": {},
      "category_rules_applied": ["data_residency_review_required", "high_value_approval", "esg_required"],
      "geography_rules_applied": ["ch_de_delivery_approved", "eu_data_residency_flag"]
    },
    "supplier_shortlist": [
      {"rank": 1, "supplier_id": "SUP-000005-01", "supplier_name": "Dell Technologies", "preferred": false, "incumbent": false, "pricing_tier_applied": "Tier 3: 100+ units", "unit_price_eur": null, "total_price_eur": 494000, "quality_score": 88, "risk_score": 85, "esg_score": 78, "composite_score": 85, "policy_compliant": true, "covers_delivery_country": true, "historical_precedent": false, "recommendation_note": "Strong enterprise portfolio."},
      {"rank": 2, "supplier_id": "SUP-000005-02", "supplier_name": "Lenovo",            "preferred": false, "incumbent": true,  "pricing_tier_applied": "Tier 3: 100+ units", "unit_price_eur": null, "total_price_eur": 457600, "quality_score": 80, "risk_score": 82, "esg_score": 75, "composite_score": 82, "policy_compliant": true, "covers_delivery_country": true, "historical_precedent": true,  "recommendation_note": "Incumbent supplier. Competitive pricing."},
      {"rank": 3, "supplier_id": "SUP-000005-03", "supplier_name": "HP Inc.",           "preferred": false, "incumbent": false, "pricing_tier_applied": "Tier 3: 100+ units", "unit_price_eur": null, "total_price_eur": 530400, "quality_score": 82, "risk_score": 80, "esg_score": 80, "composite_score": 79, "policy_compliant": true, "covers_delivery_country": true, "historical_precedent": false, "recommendation_note": "Good ESG rating."}
    ],
    "suppliers_excluded": [
      {"supplier_id": "SUP-000005-04", "supplier_name": "Huawei Enterprise", "reason": "Supplier is on restricted list due to geopolitical compliance requirements."}
    ],
    "escalations": [
      {"escalation_id": "REQ-000005-ESC-01", "rule": "ER-002", "trigger": "Preferred/incumbent supplier conflict",    "escalate_to": "category_manager",  "blocking": true},
      {"escalation_id": "REQ-000005-ESC-02", "rule": "ER-003", "trigger": "Budget exceeds approval threshold",        "escalate_to": "finance_director",   "blocking": true},
      {"escalation_id": "REQ-000005-ESC-03", "rule": "ER-005", "trigger": "Data residency constraint",               "escalate_to": "legal_compliance",   "blocking": true}
    ],
    "recommendation": {"status": "escalated", "recommended_supplier": null, "rationale": "Three blocking escalations: supplier conflict, high-value threshold breach, and data residency compliance review required."},
    "audit_trail": [
      {"step_id": "REQ-000005-S01", "timestamp": "2026-03-19T04:00:15Z", "step_type": "parsing",       "title": "Request Parsed",           "outcome": "pass",    "confidence_score": 0.95, "triggered_rule": null},
      {"step_id": "REQ-000005-S02", "timestamp": "2026-03-19T04:00:30Z", "step_type": "validation",    "title": "Data Completeness Check",  "outcome": "pass",    "confidence_score": 0.93, "triggered_rule": null},
      {"step_id": "REQ-000005-S03", "timestamp": "2026-03-19T04:00:45Z", "step_type": "rule_check",    "title": "Compliance & Policy Check","outcome": "escalate","confidence_score": 0.85, "triggered_rule": "ER-002"},
      {"step_id": "REQ-000005-S04", "timestamp": "2026-03-19T04:01:00Z", "step_type": "escalation",    "title": "Escalation Triggered",     "outcome": "escalate","confidence_score": null, "triggered_rule": "ER-002"},
      {"step_id": "REQ-000005-S05", "timestamp": "2026-03-19T04:01:15Z", "step_type": "decision",      "title": "Decision: Awaiting Human Review", "outcome": "escalate", "confidence_score": null, "triggered_rule": null}
    ]
  }$rsp5$::jsonb,
  $esc5$[
    {"escalation_id": "REQ-000005-ESC-01", "rule": "ER-002", "trigger": "Preferred/incumbent supplier conflict", "escalate_to": "category_manager",  "blocking": true},
    {"escalation_id": "REQ-000005-ESC-02", "rule": "ER-003", "trigger": "Budget exceeds approval threshold",    "escalate_to": "finance_director",   "blocking": true},
    {"escalation_id": "REQ-000005-ESC-03", "rule": "ER-005", "trigger": "Data residency constraint",           "escalate_to": "legal_compliance",   "blocking": true}
  ]$esc5$::jsonb,
  'state3'
),

-- ─────────────────────────────────────────────────────────────────────────────
-- REQ-000006 · Professional Services / Training · escalated (ER-001: no budget)
-- ─────────────────────────────────────────────────────────────────────────────
(
  'REQ-000006', 'escalated',
  NOW() - INTERVAL '12 hours', NOW() - INTERVAL '12 hours',
  $ext6${
    "request_id": "REQ-000006",
    "request_channel": "portal", "request_language": "de",
    "business_unit": "HR Operations", "country": "Austria",
    "category_l1": "Professional Services", "category_l2": "Training & Development",
    "request_text": "Schulungsanbieter für Leadership-Programm gesucht. 40 Teilnehmer, 5 Module über 3 Monate. Sprachen: Deutsch und Englisch. Vor-Ort in Wien und remote.",
    "quantity": 40, "unit_of_measure": "participants",
    "currency": "EUR", "budget_amount": null,
    "required_by_date": "2026-03-17",
    "preferred_supplier_mentioned": null,
    "incumbent_supplier": "Deloitte",
    "delivery_countries": ["Austria"],
    "data_residency_constraint": false, "esg_requirement": false
  }$ext6$::jsonb,
  $rsp6${
    "request_id": "REQ-000006",
    "processed_at": "2026-03-19T00:00:00Z",
    "request_interpretation": {
      "category_l1": "Professional Services", "category_l2": "Training & Development",
      "quantity": 40, "unit_of_measure": "participants",
      "budget_amount": null, "currency": "EUR",
      "delivery_countries": ["Austria"],
      "required_by_date": "2026-03-17",
      "data_residency_required": false, "esg_requirement": false,
      "preferred_supplier_stated": null,
      "incumbent_supplier": "Deloitte",
      "request_language": "de", "days_until_required": -2
    },
    "validation": {
      "completeness": "fail",
      "issues_detected": [
        {"issue_id": "V-001", "severity": "high", "type": "missing_field", "description": "Budget amount is required.", "action_required": "Provide budget estimate."},
        {"issue_id": "V-002", "severity": "medium", "type": "date_past", "description": "Required-by date is in the past.", "action_required": "Confirm new delivery date."}
      ]
    },
    "policy_evaluation": {
      "approval_threshold": {"result": "unknown", "threshold_eur": null, "request_value_eur": null},
      "preferred_supplier": {"stated": null, "in_approved_list": null, "conflict_with_incumbent": false},
      "restricted_suppliers": {},
      "category_rules_applied": ["incumbent_continuity"],
      "geography_rules_applied": ["at_delivery_approved"]
    },
    "supplier_shortlist": [
      {"rank": 1, "supplier_id": "SUP-000006-01", "supplier_name": "Accenture", "preferred": false, "incumbent": false, "pricing_tier_applied": "Tier 1: Strategic", "unit_price_eur": null, "total_price_eur": 300000, "quality_score": 95, "risk_score": 90, "esg_score": 85, "composite_score": 88, "policy_compliant": true, "covers_delivery_country": true, "historical_precedent": false, "recommendation_note": "Premium consulting partner."},
      {"rank": 2, "supplier_id": "SUP-000006-02", "supplier_name": "Deloitte",  "preferred": false, "incumbent": true,  "pricing_tier_applied": "Tier 1: Strategic", "unit_price_eur": null, "total_price_eur": 270000, "quality_score": 90, "risk_score": 88, "esg_score": 82, "composite_score": 85, "policy_compliant": true, "covers_delivery_country": true, "historical_precedent": true,  "recommendation_note": "Incumbent. Strong track record."},
      {"rank": 3, "supplier_id": "SUP-000006-03", "supplier_name": "KPMG",     "preferred": false, "incumbent": false, "pricing_tier_applied": "Tier 1: Strategic", "unit_price_eur": null, "total_price_eur": 260000, "quality_score": 85, "risk_score": 82, "esg_score": 78, "composite_score": 81, "policy_compliant": true, "covers_delivery_country": true, "historical_precedent": false, "recommendation_note": "Competitive pricing."}
    ],
    "suppliers_excluded": [],
    "escalations": [
      {"escalation_id": "REQ-000006-ESC-01", "rule": "ER-001", "trigger": "Missing budget information", "escalate_to": "procurement_ops", "blocking": true}
    ],
    "recommendation": {"status": "escalated", "recommended_supplier": null, "rationale": "Budget missing and required date has passed — needs human review."},
    "audit_trail": [
      {"step_id": "REQ-000006-S01", "timestamp": "2026-03-19T00:00:15Z", "step_type": "parsing",    "title": "Request Parsed",          "outcome": "pass",    "confidence_score": 0.91, "triggered_rule": null},
      {"step_id": "REQ-000006-S02", "timestamp": "2026-03-19T00:00:30Z", "step_type": "validation", "title": "Data Completeness Check", "outcome": "fail",    "confidence_score": 0.94, "triggered_rule": "ER-001"},
      {"step_id": "REQ-000006-S03", "timestamp": "2026-03-19T00:00:45Z", "step_type": "escalation", "title": "Escalation Triggered",    "outcome": "escalate","confidence_score": null, "triggered_rule": "ER-001"},
      {"step_id": "REQ-000006-S04", "timestamp": "2026-03-19T00:01:00Z", "step_type": "decision",   "title": "Decision: Awaiting Human Review", "outcome": "escalate", "confidence_score": null, "triggered_rule": null}
    ]
  }$rsp6$::jsonb,
  $esc6$[{"escalation_id": "REQ-000006-ESC-01", "rule": "ER-001", "trigger": "Missing budget information", "escalate_to": "procurement_ops", "blocking": true}]$esc6$::jsonb,
  'state2'
),

-- ─────────────────────────────────────────────────────────────────────────────
-- REQ-000007 · Facilities / Security Services · completed
-- ─────────────────────────────────────────────────────────────────────────────
(
  'REQ-000007', 'completed',
  NOW() - INTERVAL '48 hours', NOW() - INTERVAL '48 hours',
  $ext7${
    "request_id": "REQ-000007",
    "request_channel": "teams", "request_language": "es",
    "business_unit": "Operations Iberia", "country": "Spain",
    "category_l1": "Facilities", "category_l2": "Security Services",
    "request_text": "Necesitamos un proveedor de servicios de seguridad para nuestras oficinas en Madrid y Barcelona. Contrato anual con opción de renovación. Requisito ESG obligatorio.",
    "quantity": 2, "unit_of_measure": "locations",
    "currency": "EUR", "budget_amount": 180000,
    "required_by_date": "2026-05-18",
    "preferred_supplier_mentioned": "Securitas",
    "incumbent_supplier": "Securitas",
    "delivery_countries": ["Spain"],
    "data_residency_constraint": false, "esg_requirement": true
  }$ext7$::jsonb,
  $rsp7${
    "request_id": "REQ-000007",
    "processed_at": "2026-03-17T12:00:00Z",
    "request_interpretation": {
      "category_l1": "Facilities", "category_l2": "Security Services",
      "quantity": 2, "unit_of_measure": "locations",
      "budget_amount": 180000, "currency": "EUR",
      "delivery_countries": ["Spain"],
      "required_by_date": "2026-05-18",
      "data_residency_required": false, "esg_requirement": true,
      "preferred_supplier_stated": "Securitas",
      "incumbent_supplier": "Securitas",
      "request_language": "es", "days_until_required": 60
    },
    "validation": {"completeness": "pass", "issues_detected": []},
    "policy_evaluation": {
      "approval_threshold": {"result": "within_limit", "threshold_eur": 500000, "request_value_eur": 180000},
      "preferred_supplier": {"stated": "Securitas", "in_approved_list": true, "conflict_with_incumbent": false},
      "restricted_suppliers": {},
      "category_rules_applied": ["esg_required", "incumbent_continuity"],
      "geography_rules_applied": ["es_delivery_approved"]
    },
    "supplier_shortlist": [
      {"rank": 1, "supplier_id": "SUP-000007-02", "supplier_name": "Sodexo",        "preferred": false, "incumbent": false, "pricing_tier_applied": null, "unit_price_eur": null, "total_price_eur": 171000, "quality_score": 82, "risk_score": 85, "esg_score": 90, "composite_score": 83, "policy_compliant": true, "covers_delivery_country": true, "historical_precedent": false, "recommendation_note": "Top ESG performer."},
      {"rank": 2, "supplier_id": "SUP-000007-01", "supplier_name": "ISS Facilities","preferred": false, "incumbent": false, "pricing_tier_applied": null, "unit_price_eur": null, "total_price_eur": 165600, "quality_score": 85, "risk_score": 82, "esg_score": 88, "composite_score": 80, "policy_compliant": true, "covers_delivery_country": true, "historical_precedent": false, "recommendation_note": "Strong ESG credentials."},
      {"rank": 3, "supplier_id": "SUP-000007-03", "supplier_name": "CBRE",          "preferred": false, "incumbent": false, "pricing_tier_applied": null, "unit_price_eur": null, "total_price_eur": 189000, "quality_score": 80, "risk_score": 80, "esg_score": 78, "composite_score": 77, "policy_compliant": true, "covers_delivery_country": true, "historical_precedent": false, "recommendation_note": "Global presence."}
    ],
    "suppliers_excluded": [
      {"supplier_id": "SUP-000007-04", "supplier_name": "Local Facility Co.", "reason": "ESG certification missing. Quality score below threshold."}
    ],
    "escalations": [],
    "recommendation": {"status": "approved", "recommended_supplier": "Sodexo", "rationale": "Top-ranked supplier with composite score 83/100. Highest ESG rating meets mandatory ESG requirement."},
    "audit_trail": [
      {"step_id": "REQ-000007-S01", "timestamp": "2026-03-17T12:00:15Z", "step_type": "parsing",        "title": "Request Parsed",           "outcome": "pass", "confidence_score": 0.94, "triggered_rule": null},
      {"step_id": "REQ-000007-S02", "timestamp": "2026-03-17T12:00:30Z", "step_type": "interpretation",  "title": "Intent Classification",    "outcome": "pass", "confidence_score": 0.89, "triggered_rule": null},
      {"step_id": "REQ-000007-S03", "timestamp": "2026-03-17T12:00:45Z", "step_type": "validation",      "title": "Data Completeness Check",  "outcome": "pass", "confidence_score": 0.96, "triggered_rule": null},
      {"step_id": "REQ-000007-S04", "timestamp": "2026-03-17T12:01:00Z", "step_type": "supplier_lookup", "title": "Supplier Database Search", "outcome": "info", "confidence_score": null, "triggered_rule": null},
      {"step_id": "REQ-000007-S05", "timestamp": "2026-03-17T12:01:15Z", "step_type": "rule_check",      "title": "Compliance & Policy Check","outcome": "pass", "confidence_score": 0.91, "triggered_rule": null},
      {"step_id": "REQ-000007-S06", "timestamp": "2026-03-17T12:01:30Z", "step_type": "scoring",         "title": "Supplier Scoring",         "outcome": "pass", "confidence_score": 0.93, "triggered_rule": null},
      {"step_id": "REQ-000007-S07", "timestamp": "2026-03-17T12:01:45Z", "step_type": "decision",        "title": "Decision: Approved",       "outcome": "pass", "confidence_score": 0.92, "triggered_rule": null}
    ]
  }$rsp7$::jsonb,
  $esc7$[]$esc7$::jsonb,
  null
),

-- ─────────────────────────────────────────────────────────────────────────────
-- REQ-000008 · IT / Software Licenses · escalated (ER-001 + ER-005)
-- ─────────────────────────────────────────────────────────────────────────────
(
  'REQ-000008', 'escalated',
  NOW() - INTERVAL '1 hour', NOW() - INTERVAL '1 hour',
  $ext8${
    "request_id": "REQ-000008",
    "request_channel": "portal", "request_language": "fr",
    "business_unit": "Data & Analytics", "country": "France",
    "category_l1": "IT", "category_l2": "Software Licenses",
    "request_text": "Renouvellement des licences Tableau pour 200 utilisateurs. Contrainte de résidence des données stricte pour la France. Budget à confirmer après négociation volumétrique.",
    "quantity": 200, "unit_of_measure": "licenses",
    "currency": "EUR", "budget_amount": null,
    "required_by_date": "2026-03-22",
    "preferred_supplier_mentioned": "Tableau (Salesforce)",
    "incumbent_supplier": "Tableau (Salesforce)",
    "delivery_countries": ["France"],
    "data_residency_constraint": true, "esg_requirement": false
  }$ext8$::jsonb,
  $rsp8${
    "request_id": "REQ-000008",
    "processed_at": "2026-03-19T11:00:00Z",
    "request_interpretation": {
      "category_l1": "IT", "category_l2": "Software Licenses",
      "quantity": 200, "unit_of_measure": "licenses",
      "budget_amount": null, "currency": "EUR",
      "delivery_countries": ["France"],
      "required_by_date": "2026-03-22",
      "data_residency_required": true, "esg_requirement": false,
      "preferred_supplier_stated": "Tableau (Salesforce)",
      "incumbent_supplier": "Tableau (Salesforce)",
      "request_language": "fr", "days_until_required": 3
    },
    "validation": {
      "completeness": "fail",
      "issues_detected": [
        {"issue_id": "V-001", "severity": "high", "type": "missing_field", "description": "Budget amount required.", "action_required": "Confirm budget after volumetric negotiation."}
      ]
    },
    "policy_evaluation": {
      "approval_threshold": {"result": "unknown", "threshold_eur": null, "request_value_eur": null},
      "preferred_supplier": {"stated": "Tableau (Salesforce)", "in_approved_list": true, "conflict_with_incumbent": false},
      "restricted_suppliers": {},
      "category_rules_applied": ["data_residency_review_required"],
      "geography_rules_applied": ["fr_delivery_approved", "fr_data_residency_flag"]
    },
    "supplier_shortlist": [
      {"rank": 1, "supplier_id": "SUP-000008-01", "supplier_name": "Dell Technologies", "preferred": false, "incumbent": false, "pricing_tier_applied": "Tier 3: 100+ units", "unit_price_eur": null, "total_price_eur": 350000, "quality_score": 88, "risk_score": 85, "esg_score": 78, "composite_score": 85, "policy_compliant": true, "covers_delivery_country": true, "historical_precedent": false, "recommendation_note": "Strong enterprise portfolio."},
      {"rank": 2, "supplier_id": "SUP-000008-02", "supplier_name": "Lenovo",            "preferred": false, "incumbent": true,  "pricing_tier_applied": "Tier 3: 100+ units", "unit_price_eur": null, "total_price_eur": 330000, "quality_score": 80, "risk_score": 82, "esg_score": 75, "composite_score": 82, "policy_compliant": true, "covers_delivery_country": true, "historical_precedent": true,  "recommendation_note": "Incumbent supplier."},
      {"rank": 3, "supplier_id": "SUP-000008-03", "supplier_name": "HP Inc.",           "preferred": false, "incumbent": false, "pricing_tier_applied": "Tier 3: 100+ units", "unit_price_eur": null, "total_price_eur": 380000, "quality_score": 82, "risk_score": 80, "esg_score": 80, "composite_score": 79, "policy_compliant": true, "covers_delivery_country": true, "historical_precedent": false, "recommendation_note": "Good ESG rating."}
    ],
    "suppliers_excluded": [
      {"supplier_id": "SUP-000008-04", "supplier_name": "Huawei Enterprise", "reason": "Supplier is on restricted list due to geopolitical compliance requirements."}
    ],
    "escalations": [
      {"escalation_id": "REQ-000008-ESC-01", "rule": "ER-001", "trigger": "Missing budget information", "escalate_to": "procurement_ops", "blocking": true},
      {"escalation_id": "REQ-000008-ESC-02", "rule": "ER-005", "trigger": "Data residency constraint",  "escalate_to": "legal_compliance",  "blocking": true}
    ],
    "recommendation": {"status": "escalated", "recommended_supplier": null, "rationale": "Budget missing and data residency constraint requires legal compliance review. Urgent — required by 2026-03-22."},
    "audit_trail": [
      {"step_id": "REQ-000008-S01", "timestamp": "2026-03-19T11:00:15Z", "step_type": "parsing",    "title": "Request Parsed",          "outcome": "pass",    "confidence_score": 0.93, "triggered_rule": null},
      {"step_id": "REQ-000008-S02", "timestamp": "2026-03-19T11:00:30Z", "step_type": "validation", "title": "Data Completeness Check", "outcome": "fail",    "confidence_score": 0.95, "triggered_rule": "ER-001"},
      {"step_id": "REQ-000008-S03", "timestamp": "2026-03-19T11:00:45Z", "step_type": "rule_check", "title": "Compliance & Policy Check","outcome": "escalate","confidence_score": 0.88, "triggered_rule": "ER-005"},
      {"step_id": "REQ-000008-S04", "timestamp": "2026-03-19T11:01:00Z", "step_type": "escalation", "title": "Escalation Triggered",    "outcome": "escalate","confidence_score": null, "triggered_rule": "ER-001"},
      {"step_id": "REQ-000008-S05", "timestamp": "2026-03-19T11:01:15Z", "step_type": "decision",   "title": "Decision: Awaiting Human Review", "outcome": "escalate", "confidence_score": null, "triggered_rule": null}
    ]
  }$rsp8$::jsonb,
  $esc8$[
    {"escalation_id": "REQ-000008-ESC-01", "rule": "ER-001", "trigger": "Missing budget information", "escalate_to": "procurement_ops", "blocking": true},
    {"escalation_id": "REQ-000008-ESC-02", "rule": "ER-005", "trigger": "Data residency constraint",  "escalate_to": "legal_compliance",  "blocking": true}
  ]$esc8$::jsonb,
  'state2'
),

-- ─────────────────────────────────────────────────────────────────────────────
-- REQ-000009 · Marketing / Event Management · completed
-- ─────────────────────────────────────────────────────────────────────────────
(
  'REQ-000009', 'completed',
  NOW() - INTERVAL '72 hours', NOW() - INTERVAL '72 hours',
  $ext9${
    "request_id": "REQ-000009",
    "request_channel": "email", "request_language": "pt",
    "business_unit": "Marketing LATAM", "country": "Brazil",
    "category_l1": "Marketing", "category_l2": "Event Management",
    "request_text": "Precisamos de uma agência para organizar nosso evento anual de clientes em São Paulo. Esperamos 500 convidados. O fornecedor deve ter certificação de sustentabilidade.",
    "quantity": 1, "unit_of_measure": "event",
    "currency": "USD", "budget_amount": 120000,
    "required_by_date": "2026-06-17",
    "preferred_supplier_mentioned": null,
    "incumbent_supplier": null,
    "delivery_countries": ["Brazil"],
    "data_residency_constraint": false, "esg_requirement": false
  }$ext9$::jsonb,
  $rsp9${
    "request_id": "REQ-000009",
    "processed_at": "2026-03-16T00:00:00Z",
    "request_interpretation": {
      "category_l1": "Marketing", "category_l2": "Event Management",
      "quantity": 1, "unit_of_measure": "event",
      "budget_amount": 120000, "currency": "USD",
      "delivery_countries": ["Brazil"],
      "required_by_date": "2026-06-17",
      "data_residency_required": false, "esg_requirement": false,
      "preferred_supplier_stated": null,
      "incumbent_supplier": null,
      "request_language": "pt", "days_until_required": 90
    },
    "validation": {"completeness": "pass", "issues_detected": []},
    "policy_evaluation": {
      "approval_threshold": {"result": "within_limit", "threshold_eur": 500000, "request_value_eur": 110000},
      "preferred_supplier": {"stated": null, "in_approved_list": null, "conflict_with_incumbent": false},
      "restricted_suppliers": {},
      "category_rules_applied": ["open_competition"],
      "geography_rules_applied": ["br_delivery_approved"]
    },
    "supplier_shortlist": [
      {"rank": 1, "supplier_id": "SUP-000009-01", "supplier_name": "WPP",            "preferred": false, "incumbent": false, "pricing_tier_applied": null, "unit_price_eur": null, "total_price_eur": 116400, "quality_score": 88, "risk_score": 85, "esg_score": 80, "composite_score": 84, "policy_compliant": true, "covers_delivery_country": true, "historical_precedent": false, "recommendation_note": "Global network. Strong event capabilities."},
      {"rank": 2, "supplier_id": "SUP-000009-02", "supplier_name": "Publicis Groupe","preferred": false, "incumbent": false, "pricing_tier_applied": null, "unit_price_eur": null, "total_price_eur": 108000, "quality_score": 82, "risk_score": 80, "esg_score": 78, "composite_score": 81, "policy_compliant": true, "covers_delivery_country": true, "historical_precedent": false, "recommendation_note": "Cost-effective option."},
      {"rank": 3, "supplier_id": "SUP-000009-03", "supplier_name": "Omnicom Group",  "preferred": false, "incumbent": false, "pricing_tier_applied": null, "unit_price_eur": null, "total_price_eur": 129600, "quality_score": 80, "risk_score": 78, "esg_score": 76, "composite_score": 78, "policy_compliant": true, "covers_delivery_country": true, "historical_precedent": false, "recommendation_note": "Premium positioning."}
    ],
    "suppliers_excluded": [
      {"supplier_id": "SUP-000009-04", "supplier_name": "Local Creative Studio", "reason": "Insufficient scale for 500-guest event. No sustainability certification."}
    ],
    "escalations": [],
    "recommendation": {"status": "approved", "recommended_supplier": "WPP", "rationale": "Top-ranked supplier with composite score 84/100. Global presence suits LATAM market."},
    "audit_trail": [
      {"step_id": "REQ-000009-S01", "timestamp": "2026-03-16T00:00:15Z", "step_type": "parsing",       "title": "Request Parsed",           "outcome": "pass", "confidence_score": 0.90, "triggered_rule": null},
      {"step_id": "REQ-000009-S02", "timestamp": "2026-03-16T00:00:30Z", "step_type": "validation",    "title": "Data Completeness Check",  "outcome": "pass", "confidence_score": 0.93, "triggered_rule": null},
      {"step_id": "REQ-000009-S03", "timestamp": "2026-03-16T00:00:45Z", "step_type": "rule_check",    "title": "Compliance & Policy Check","outcome": "pass", "confidence_score": 0.88, "triggered_rule": null},
      {"step_id": "REQ-000009-S04", "timestamp": "2026-03-16T00:01:00Z", "step_type": "scoring",       "title": "Supplier Scoring",         "outcome": "pass", "confidence_score": 0.91, "triggered_rule": null},
      {"step_id": "REQ-000009-S05", "timestamp": "2026-03-16T00:01:15Z", "step_type": "decision",      "title": "Decision: Approved",       "outcome": "pass", "confidence_score": 0.90, "triggered_rule": null}
    ]
  }$rsp9$::jsonb,
  $esc9$[]$esc9$::jsonb,
  null
),

-- ─────────────────────────────────────────────────────────────────────────────
-- REQ-000010 · IT / Network Equipment · escalated (ER-002 + ER-005)
-- ─────────────────────────────────────────────────────────────────────────────
(
  'REQ-000010', 'escalated',
  NOW() - INTERVAL '4 hours', NOW() - INTERVAL '4 hours',
  $ext10${
    "request_id": "REQ-000010",
    "request_channel": "teams", "request_language": "ja",
    "business_unit": "Asia Pacific IT", "country": "Japan",
    "category_l1": "IT", "category_l2": "Network Equipment",
    "request_text": "東京オフィスのネットワーク機器の更新が必要です。Cisco製品を希望しますが、他のサプライヤーも検討可能です。データレジデンシー要件あり。",
    "quantity": 50, "unit_of_measure": "units",
    "currency": "USD", "budget_amount": 89000,
    "required_by_date": "2026-04-13",
    "preferred_supplier_mentioned": "Cisco Systems",
    "incumbent_supplier": "Juniper Networks",
    "delivery_countries": ["Japan"],
    "data_residency_constraint": true, "esg_requirement": false
  }$ext10$::jsonb,
  $rsp10${
    "request_id": "REQ-000010",
    "processed_at": "2026-03-19T08:00:00Z",
    "request_interpretation": {
      "category_l1": "IT", "category_l2": "Network Equipment",
      "quantity": 50, "unit_of_measure": "units",
      "budget_amount": 89000, "currency": "USD",
      "delivery_countries": ["Japan"],
      "required_by_date": "2026-04-13",
      "data_residency_required": true, "esg_requirement": false,
      "preferred_supplier_stated": "Cisco Systems",
      "incumbent_supplier": "Juniper Networks",
      "request_language": "ja", "days_until_required": 25
    },
    "validation": {"completeness": "pass", "issues_detected": []},
    "policy_evaluation": {
      "approval_threshold": {"result": "within_limit", "threshold_eur": 500000, "request_value_eur": 82000},
      "preferred_supplier": {"stated": "Cisco Systems", "in_approved_list": true, "conflict_with_incumbent": true},
      "restricted_suppliers": {},
      "category_rules_applied": ["data_residency_review_required"],
      "geography_rules_applied": ["jp_delivery_approved", "jp_data_residency_flag"]
    },
    "supplier_shortlist": [
      {"rank": 1, "supplier_id": "SUP-000010-01", "supplier_name": "Dell Technologies", "preferred": false, "incumbent": false, "pricing_tier_applied": "Tier 3: 100+ units", "unit_price_eur": null, "total_price_eur": 84550, "quality_score": 88, "risk_score": 85, "esg_score": 78, "composite_score": 85, "policy_compliant": true, "covers_delivery_country": true, "historical_precedent": false, "recommendation_note": "Strong enterprise portfolio."},
      {"rank": 2, "supplier_id": "SUP-000010-02", "supplier_name": "Lenovo",            "preferred": false, "incumbent": true,  "pricing_tier_applied": "Tier 3: 100+ units", "unit_price_eur": null, "total_price_eur": 78320, "quality_score": 80, "risk_score": 82, "esg_score": 75, "composite_score": 82, "policy_compliant": true, "covers_delivery_country": true, "historical_precedent": true,  "recommendation_note": "Incumbent. Competitive pricing."},
      {"rank": 3, "supplier_id": "SUP-000010-03", "supplier_name": "HP Inc.",           "preferred": false, "incumbent": false, "pricing_tier_applied": "Tier 3: 100+ units", "unit_price_eur": null, "total_price_eur": 90780, "quality_score": 82, "risk_score": 80, "esg_score": 80, "composite_score": 79, "policy_compliant": true, "covers_delivery_country": true, "historical_precedent": false, "recommendation_note": "Good ESG rating."}
    ],
    "suppliers_excluded": [
      {"supplier_id": "SUP-000010-04", "supplier_name": "Huawei Enterprise", "reason": "Supplier is on restricted list due to geopolitical compliance requirements."}
    ],
    "escalations": [
      {"escalation_id": "REQ-000010-ESC-01", "rule": "ER-002", "trigger": "Preferred/incumbent supplier conflict", "escalate_to": "category_manager", "blocking": true},
      {"escalation_id": "REQ-000010-ESC-02", "rule": "ER-005", "trigger": "Data residency constraint",            "escalate_to": "legal_compliance",  "blocking": true}
    ],
    "recommendation": {"status": "escalated", "recommended_supplier": null, "rationale": "Supplier conflict (Cisco vs Juniper) and Japan data residency requirement need human review."},
    "audit_trail": [
      {"step_id": "REQ-000010-S01", "timestamp": "2026-03-19T08:00:15Z", "step_type": "parsing",    "title": "Request Parsed",           "outcome": "pass",    "confidence_score": 0.88, "triggered_rule": null},
      {"step_id": "REQ-000010-S02", "timestamp": "2026-03-19T08:00:30Z", "step_type": "validation", "title": "Data Completeness Check",  "outcome": "pass",    "confidence_score": 0.94, "triggered_rule": null},
      {"step_id": "REQ-000010-S03", "timestamp": "2026-03-19T08:00:45Z", "step_type": "rule_check", "title": "Compliance & Policy Check","outcome": "escalate","confidence_score": 0.86, "triggered_rule": "ER-002"},
      {"step_id": "REQ-000010-S04", "timestamp": "2026-03-19T08:01:00Z", "step_type": "escalation", "title": "Escalation Triggered",     "outcome": "escalate","confidence_score": null, "triggered_rule": "ER-002"},
      {"step_id": "REQ-000010-S05", "timestamp": "2026-03-19T08:01:15Z", "step_type": "decision",   "title": "Decision: Awaiting Human Review", "outcome": "escalate", "confidence_score": null, "triggered_rule": null}
    ]
  }$rsp10$::jsonb,
  $esc10$[
    {"escalation_id": "REQ-000010-ESC-01", "rule": "ER-002", "trigger": "Preferred/incumbent supplier conflict", "escalate_to": "category_manager", "blocking": true},
    {"escalation_id": "REQ-000010-ESC-02", "rule": "ER-005", "trigger": "Data residency constraint",            "escalate_to": "legal_compliance",  "blocking": true}
  ]$esc10$::jsonb,
  'state3'
),

-- ─────────────────────────────────────────────────────────────────────────────
-- REQ-000011 · Professional Services / Legal Advisory · escalated (ER-002 + ER-003)
-- ─────────────────────────────────────────────────────────────────────────────
(
  'REQ-000011', 'escalated',
  NOW() - INTERVAL '96 hours', NOW() - INTERVAL '96 hours',
  $ext11${
    "request_id": "REQ-000011",
    "request_channel": "portal", "request_language": "en",
    "business_unit": "Legal & Compliance", "country": "United Kingdom",
    "category_l1": "Professional Services", "category_l2": "Legal Advisory",
    "request_text": "Require external legal counsel for GDPR compliance audit across 5 EU entities. Must have experience with Swiss and EU data protection law. Tier 1 law firm preferred.",
    "quantity": 1, "unit_of_measure": "engagement",
    "currency": "CHF", "budget_amount": 450000,
    "required_by_date": "2026-03-29",
    "preferred_supplier_mentioned": "Baker McKenzie",
    "incumbent_supplier": "KPMG Legal",
    "delivery_countries": ["United Kingdom", "Switzerland", "Germany", "France", "Netherlands"],
    "data_residency_constraint": false, "esg_requirement": false
  }$ext11$::jsonb,
  $rsp11${
    "request_id": "REQ-000011",
    "processed_at": "2026-03-15T12:00:00Z",
    "request_interpretation": {
      "category_l1": "Professional Services", "category_l2": "Legal Advisory",
      "quantity": 1, "unit_of_measure": "engagement",
      "budget_amount": 450000, "currency": "CHF",
      "delivery_countries": ["United Kingdom", "Switzerland", "Germany", "France", "Netherlands"],
      "required_by_date": "2026-03-29",
      "data_residency_required": false, "esg_requirement": false,
      "preferred_supplier_stated": "Baker McKenzie",
      "incumbent_supplier": "KPMG Legal",
      "request_language": "en", "days_until_required": 10
    },
    "validation": {"completeness": "pass", "issues_detected": []},
    "policy_evaluation": {
      "approval_threshold": {"result": "near_limit", "threshold_eur": 500000, "request_value_eur": 450000},
      "preferred_supplier": {"stated": "Baker McKenzie", "in_approved_list": true, "conflict_with_incumbent": true},
      "restricted_suppliers": {},
      "category_rules_applied": ["strategic_tier_preferred", "multi_country_review"],
      "geography_rules_applied": ["uk_ch_de_fr_nl_delivery_approved"]
    },
    "supplier_shortlist": [
      {"rank": 1, "supplier_id": "SUP-000011-01", "supplier_name": "Accenture", "preferred": false, "incumbent": false, "pricing_tier_applied": "Tier 1: Strategic", "unit_price_eur": null, "total_price_eur": 495000, "quality_score": 95, "risk_score": 90, "esg_score": 85, "composite_score": 88, "policy_compliant": true, "covers_delivery_country": true, "historical_precedent": false, "recommendation_note": "Premium advisory capability."},
      {"rank": 2, "supplier_id": "SUP-000011-02", "supplier_name": "Deloitte",  "preferred": false, "incumbent": false, "pricing_tier_applied": "Tier 1: Strategic", "unit_price_eur": null, "total_price_eur": 441000, "quality_score": 90, "risk_score": 88, "esg_score": 82, "composite_score": 85, "policy_compliant": true, "covers_delivery_country": true, "historical_precedent": false, "recommendation_note": "Strong GDPR and compliance track record."},
      {"rank": 3, "supplier_id": "SUP-000011-03", "supplier_name": "KPMG",     "preferred": false, "incumbent": true,  "pricing_tier_applied": "Tier 1: Strategic", "unit_price_eur": null, "total_price_eur": 418500, "quality_score": 85, "risk_score": 82, "esg_score": 78, "composite_score": 81, "policy_compliant": true, "covers_delivery_country": true, "historical_precedent": true,  "recommendation_note": "Incumbent. Competitive pricing."}
    ],
    "suppliers_excluded": [],
    "escalations": [
      {"escalation_id": "REQ-000011-ESC-01", "rule": "ER-002", "trigger": "Preferred/incumbent supplier conflict", "escalate_to": "category_manager", "blocking": true},
      {"escalation_id": "REQ-000011-ESC-02", "rule": "ER-003", "trigger": "Budget exceeds approval threshold",    "escalate_to": "finance_director",  "blocking": true}
    ],
    "recommendation": {"status": "escalated", "recommended_supplier": null, "rationale": "Supplier conflict (Baker McKenzie vs KPMG Legal) and high-value threshold (450k CHF) require senior approval."},
    "audit_trail": [
      {"step_id": "REQ-000011-S01", "timestamp": "2026-03-15T12:00:15Z", "step_type": "parsing",    "title": "Request Parsed",           "outcome": "pass",    "confidence_score": 0.96, "triggered_rule": null},
      {"step_id": "REQ-000011-S02", "timestamp": "2026-03-15T12:00:30Z", "step_type": "validation", "title": "Data Completeness Check",  "outcome": "pass",    "confidence_score": 0.98, "triggered_rule": null},
      {"step_id": "REQ-000011-S03", "timestamp": "2026-03-15T12:00:45Z", "step_type": "rule_check", "title": "Compliance & Policy Check","outcome": "escalate","confidence_score": 0.87, "triggered_rule": "ER-002"},
      {"step_id": "REQ-000011-S04", "timestamp": "2026-03-15T12:01:00Z", "step_type": "escalation", "title": "Escalation Triggered",     "outcome": "escalate","confidence_score": null, "triggered_rule": "ER-002"},
      {"step_id": "REQ-000011-S05", "timestamp": "2026-03-15T12:01:15Z", "step_type": "decision",   "title": "Decision: Awaiting Human Review", "outcome": "escalate", "confidence_score": null, "triggered_rule": null}
    ]
  }$rsp11$::jsonb,
  $esc11$[
    {"escalation_id": "REQ-000011-ESC-01", "rule": "ER-002", "trigger": "Preferred/incumbent supplier conflict", "escalate_to": "category_manager", "blocking": true},
    {"escalation_id": "REQ-000011-ESC-02", "rule": "ER-003", "trigger": "Budget exceeds approval threshold",    "escalate_to": "finance_director",  "blocking": true}
  ]$esc11$::jsonb,
  'state3'
),

-- ─────────────────────────────────────────────────────────────────────────────
-- REQ-000012 · Facilities / Office Supplies · escalated (ER-002)
-- ─────────────────────────────────────────────────────────────────────────────
(
  'REQ-000012', 'escalated',
  NOW() - INTERVAL '30 minutes', NOW() - INTERVAL '30 minutes',
  $ext12${
    "request_id": "REQ-000012",
    "request_channel": "email", "request_language": "en",
    "business_unit": "Procurement Center", "country": "Switzerland",
    "category_l1": "Facilities", "category_l2": "Office Supplies",
    "request_text": "Bulk order for office supplies across all EMEA offices. Standard items: paper, toner, desk accessories. Current supplier contract expiring. Need competitive quotes from at least 3 vendors.",
    "quantity": null, "unit_of_measure": null,
    "currency": "EUR", "budget_amount": 35000,
    "required_by_date": "2026-04-03",
    "preferred_supplier_mentioned": "Staples",
    "incumbent_supplier": "Lyreco",
    "delivery_countries": ["Switzerland", "Germany", "France", "United Kingdom", "Spain"],
    "data_residency_constraint": false, "esg_requirement": false
  }$ext12$::jsonb,
  $rsp12${
    "request_id": "REQ-000012",
    "processed_at": "2026-03-19T11:30:00Z",
    "request_interpretation": {
      "category_l1": "Facilities", "category_l2": "Office Supplies",
      "quantity": null, "unit_of_measure": null,
      "budget_amount": 35000, "currency": "EUR",
      "delivery_countries": ["Switzerland", "Germany", "France", "United Kingdom", "Spain"],
      "required_by_date": "2026-04-03",
      "data_residency_required": false, "esg_requirement": false,
      "preferred_supplier_stated": "Staples",
      "incumbent_supplier": "Lyreco",
      "request_language": "en", "days_until_required": 15
    },
    "validation": {"completeness": "pass", "issues_detected": []},
    "policy_evaluation": {
      "approval_threshold": {"result": "within_limit", "threshold_eur": 500000, "request_value_eur": 35000},
      "preferred_supplier": {"stated": "Staples", "in_approved_list": true, "conflict_with_incumbent": true},
      "restricted_suppliers": {},
      "category_rules_applied": ["multi_country_review", "open_competition_3_vendors"],
      "geography_rules_applied": ["ch_de_fr_uk_es_delivery_approved"]
    },
    "supplier_shortlist": [
      {"rank": 1, "supplier_id": "SUP-000012-02", "supplier_name": "Sodexo",        "preferred": false, "incumbent": false, "pricing_tier_applied": null, "unit_price_eur": null, "total_price_eur": 33250, "quality_score": 82, "risk_score": 85, "esg_score": 90, "composite_score": 83, "policy_compliant": true, "covers_delivery_country": true, "historical_precedent": false, "recommendation_note": "Top ESG performer. Covers all 5 delivery countries."},
      {"rank": 2, "supplier_id": "SUP-000012-01", "supplier_name": "ISS Facilities","preferred": false, "incumbent": false, "pricing_tier_applied": null, "unit_price_eur": null, "total_price_eur": 32200, "quality_score": 85, "risk_score": 82, "esg_score": 88, "composite_score": 80, "policy_compliant": true, "covers_delivery_country": true, "historical_precedent": false, "recommendation_note": "Strong ESG credentials."},
      {"rank": 3, "supplier_id": "SUP-000012-03", "supplier_name": "CBRE",          "preferred": false, "incumbent": false, "pricing_tier_applied": null, "unit_price_eur": null, "total_price_eur": 36750, "quality_score": 80, "risk_score": 80, "esg_score": 78, "composite_score": 77, "policy_compliant": true, "covers_delivery_country": true, "historical_precedent": false, "recommendation_note": "Global presence."}
    ],
    "suppliers_excluded": [
      {"supplier_id": "SUP-000012-04", "supplier_name": "Local Facility Co.", "reason": "ESG certification missing. Does not cover required delivery countries."}
    ],
    "escalations": [
      {"escalation_id": "REQ-000012-ESC-01", "rule": "ER-002", "trigger": "Preferred/incumbent supplier conflict", "escalate_to": "category_manager", "blocking": true}
    ],
    "recommendation": {"status": "escalated", "recommended_supplier": null, "rationale": "Conflict between preferred (Staples) and incumbent (Lyreco) requires category manager decision."},
    "audit_trail": [
      {"step_id": "REQ-000012-S01", "timestamp": "2026-03-19T11:30:15Z", "step_type": "parsing",    "title": "Request Parsed",           "outcome": "pass",    "confidence_score": 0.96, "triggered_rule": null},
      {"step_id": "REQ-000012-S02", "timestamp": "2026-03-19T11:30:30Z", "step_type": "validation", "title": "Data Completeness Check",  "outcome": "pass",    "confidence_score": 0.95, "triggered_rule": null},
      {"step_id": "REQ-000012-S03", "timestamp": "2026-03-19T11:30:45Z", "step_type": "rule_check", "title": "Compliance & Policy Check","outcome": "escalate","confidence_score": 0.83, "triggered_rule": "ER-002"},
      {"step_id": "REQ-000012-S04", "timestamp": "2026-03-19T11:31:00Z", "step_type": "escalation", "title": "Escalation Triggered",     "outcome": "escalate","confidence_score": null, "triggered_rule": "ER-002"},
      {"step_id": "REQ-000012-S05", "timestamp": "2026-03-19T11:31:15Z", "step_type": "decision",   "title": "Decision: Awaiting Human Review", "outcome": "escalate", "confidence_score": null, "triggered_rule": null}
    ]
  }$rsp12$::jsonb,
  $esc12$[{"escalation_id": "REQ-000012-ESC-01", "rule": "ER-002", "trigger": "Preferred/incumbent supplier conflict", "escalate_to": "category_manager", "blocking": true}]$esc12$::jsonb,
  'state3'
)

ON CONFLICT (request_id) DO NOTHING;
