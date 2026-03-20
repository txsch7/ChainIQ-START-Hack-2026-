import os
from pathlib import Path

# Paths
DATA_DIR = Path(__file__).parent.parent / "data"

# FX Rates (static, logged per request for reproducibility)
FX_RATES: dict[str, float] = {
    "EUR_CHF": 0.93,
    "EUR_USD": 1.08,
    "CHF_EUR": 1.075,
    "USD_EUR": 0.926,
}

# Confidence threshold for LLM extraction acceptance
CONFIDENCE_THRESHOLD = 0.7

# Scoring weights
DEFAULT_WEIGHTS = {"price": 0.40, "quality": 0.25, "risk": 0.20, "esg": 0.15}
ESG_WEIGHTS = {"price": 0.35, "quality": 0.25, "risk": 0.15, "esg": 0.25}

# Incumbent bonus points
INCUMBENT_BONUS = 5.0

# Max shortlist size
MAX_SHORTLIST = 5

# High-value thresholds triggering ER-003 (AT-004/005 equivalent)
HIGH_VALUE_THRESHOLDS = {
    "EUR": 500_000.0,
    "CHF": 500_000.0,
    "USD": 540_000.0,
}

# Country → pricing region mapping
EU_COUNTRIES = {
    "DE", "FR", "NL", "BE", "AT", "IT", "ES", "PL", "SE", "NO",
    "DK", "FI", "CZ", "HU", "RO", "PT", "GR", "IE", "LU", "SK",
    "SI", "HR", "BG", "EE", "LV", "LT", "MT", "CY", "UK",
}
AMERICAS_COUNTRIES = {"US", "CA", "AR", "CL", "CO", "PE", "BR", "MX"}
APAC_COUNTRIES = {"SG", "AU", "JP", "IN", "TH", "MY", "PH", "VN", "ID", "HK", "TW", "NZ", "KR", "CN"}
MEA_COUNTRIES = {"UAE", "ZA", "SA", "QA", "KW", "BH", "EG", "NG", "KE"}

COUNTRY_TO_PRICING_REGION: dict[str, str] = {}
for _c in EU_COUNTRIES:
    COUNTRY_TO_PRICING_REGION[_c] = "EU"
COUNTRY_TO_PRICING_REGION["CH"] = "CH"
for _c in AMERICAS_COUNTRIES:
    COUNTRY_TO_PRICING_REGION[_c] = "Americas"
for _c in APAC_COUNTRIES:
    COUNTRY_TO_PRICING_REGION[_c] = "APAC"
for _c in MEA_COUNTRIES:
    COUNTRY_TO_PRICING_REGION[_c] = "MEA"

# Policy region grouping (for preferred supplier region_scope matching)
POLICY_REGION_COUNTRIES: dict[str, set[str]] = {
    "EU": EU_COUNTRIES,
    "CH": {"CH"},
    "Americas": AMERICAS_COUNTRIES,
    "APAC": APAC_COUNTRIES,
    "MEA": MEA_COUNTRIES,
}

# SAP integration feature flag (mock-only, no real HTTP calls)
SAP_ENABLED: bool = os.environ.get("SAP_ENABLED", "false").lower() in ("true", "1", "yes")
