import json
import logging
import math
from pathlib import Path

import pandas as pd

from app.config import DATA_DIR

logger = logging.getLogger(__name__)


class DataStore:
    def __init__(self) -> None:
        self.suppliers: pd.DataFrame | None = None
        self.pricing: pd.DataFrame | None = None
        self.policies: dict = {}
        self.historical_awards: pd.DataFrame | None = None
        self.categories: pd.DataFrame | None = None

        # Indexed structures
        self._supplier_index: dict[tuple, dict] = {}      # (supplier_id, category_l2) -> row
        self._pricing_index: dict[tuple, list] = {}       # (supplier_id, category_l2, region) -> [tier rows]
        self._preferred_set: set[tuple] = set()           # (supplier_id, category_l2, region)
        self._restricted_map: dict[tuple, list] = {}      # (supplier_id, category_l2) -> [{scope, reason}]
        self._historical_index: dict[tuple, list] = {}    # (category_l2, country, supplier_id) -> [award rows]

    def load(self, data_dir: Path = DATA_DIR) -> None:
        logger.info("Loading DataStore from %s", data_dir)

        # --- Suppliers ---
        self.suppliers = pd.read_csv(data_dir / "suppliers.csv")
        self.suppliers["service_regions_set"] = self.suppliers["service_regions"].apply(
            lambda x: set(str(x).split(";")) if pd.notna(x) else set()
        )
        for col in ("preferred_supplier", "is_restricted", "data_residency_supported"):
            self.suppliers[col] = self.suppliers[col].apply(
                lambda x: str(x).strip().lower() in ("true", "1", "yes")
            )
        for _, row in self.suppliers.iterrows():
            key = (row["supplier_id"], row["category_l2"])
            self._supplier_index[key] = row.to_dict()

        # --- Pricing ---
        self.pricing = pd.read_csv(data_dir / "pricing.csv")
        for col in ("min_quantity", "max_quantity", "unit_price", "expedited_unit_price",
                    "standard_lead_time_days", "expedited_lead_time_days"):
            if col in self.pricing.columns:
                self.pricing[col] = pd.to_numeric(self.pricing[col], errors="coerce")

        for _, row in self.pricing.iterrows():
            key = (row["supplier_id"], row["category_l2"], row["region"])
            self._pricing_index.setdefault(key, []).append(row.to_dict())
        for key in self._pricing_index:
            self._pricing_index[key].sort(key=lambda r: r.get("min_quantity") or 0)

        # --- Policies ---
        with open(data_dir / "policies.json") as f:
            self.policies = json.load(f)

        for ps in self.policies.get("preferred_suppliers", []):
            sid, cat = ps["supplier_id"], ps["category_l2"]
            for region in ps.get("region_scope", ["global"]):
                self._preferred_set.add((sid, cat, region))

        for rs in self.policies.get("restricted_suppliers", []):
            sid, cat = rs["supplier_id"], rs["category_l2"]
            self._restricted_map.setdefault((sid, cat), []).append(
                {"scope": rs.get("restriction_scope", ["all"]), "reason": rs.get("restriction_reason", "")}
            )

        # --- Historical awards ---
        self.historical_awards = pd.read_csv(data_dir / "historical_awards.csv")
        for _, row in self.historical_awards.iterrows():
            key = (row["category_l2"], row["country"], row["supplier_id"])
            self._historical_index.setdefault(key, []).append(row.to_dict())

        # --- Categories ---
        self.categories = pd.read_csv(data_dir / "categories.csv")

        logger.info(
            "DataStore loaded: %d supplier rows, %d pricing rows, %d historical awards",
            len(self.suppliers),
            len(self.pricing),
            len(self.historical_awards),
        )

    # ------------------------------------------------------------------ #
    # Supplier helpers
    # ------------------------------------------------------------------ #

    def get_suppliers_for_category(self, category_l2: str) -> list[dict]:
        return [row for (_, cat), row in self._supplier_index.items() if cat == category_l2]

    def get_supplier_row(self, supplier_id: str, category_l2: str) -> dict | None:
        return self._supplier_index.get((supplier_id, category_l2))

    def find_supplier_id_by_name(self, name: str) -> str | None:
        if not name:
            return None
        name_lower = name.lower()
        for supplier_id in self.suppliers["supplier_id"].unique():
            rows = self.suppliers[self.suppliers["supplier_id"] == supplier_id]
            if not rows.empty:
                sup_name = str(rows.iloc[0]["supplier_name"])
                if name_lower in sup_name.lower() or sup_name.lower() in name_lower:
                    return supplier_id
        return None

    # ------------------------------------------------------------------ #
    # Pricing helpers
    # ------------------------------------------------------------------ #

    def get_pricing_tier(
        self,
        supplier_id: str,
        category_l2: str,
        region: str,
        quantity: float,
    ) -> dict | None:
        """Find the pricing tier row matching supplier/category/region/quantity."""
        tiers = self._pricing_index.get((supplier_id, category_l2, region), [])
        if not tiers and region == "CH":
            tiers = self._pricing_index.get((supplier_id, category_l2, "EU"), [])
        if not tiers:
            # Fallback: any region for this supplier+category
            for key, rows in self._pricing_index.items():
                if key[0] == supplier_id and key[1] == category_l2:
                    tiers = rows
                    break

        if not tiers:
            return None

        for tier in sorted(tiers, key=lambda r: r.get("min_quantity") or 0):
            min_q = tier.get("min_quantity") or 0
            max_q = tier.get("max_quantity")
            if max_q is None or (isinstance(max_q, float) and math.isnan(max_q)):
                max_q = float("inf")
            if min_q <= quantity <= max_q:
                return tier

        # Quantity exceeds all tiers — use the largest tier
        return sorted(tiers, key=lambda r: r.get("min_quantity") or 0)[-1]

    # ------------------------------------------------------------------ #
    # Policy helpers
    # ------------------------------------------------------------------ #

    def is_preferred(self, supplier_id: str, category_l2: str, region: str) -> bool:
        return (
            (supplier_id, category_l2, region) in self._preferred_set
            or (supplier_id, category_l2, "global") in self._preferred_set
        )

    def get_restrictions(self, supplier_id: str, category_l2: str) -> list[dict]:
        return self._restricted_map.get((supplier_id, category_l2), [])

    def is_restricted_for_countries(
        self, supplier_id: str, category_l2: str, countries: list[str]
    ) -> tuple[bool, str]:
        """Returns (is_restricted, reason)."""
        for r in self.get_restrictions(supplier_id, category_l2):
            scope = r["scope"]
            if "all" in scope:
                return True, r["reason"]
            for country in countries:
                if country in scope:
                    return True, r["reason"]
        return False, ""

    def get_approval_threshold(self, currency: str, amount: float) -> dict | None:
        for at in self.policies.get("approval_thresholds", []):
            if at.get("currency", "").upper() != currency.upper():
                continue
            min_a = at.get("min_amount", at.get("min_value", 0)) or 0
            max_a = at.get("max_amount", at.get("max_value"))
            if max_a is None:
                max_a = float("inf")
            if min_a <= amount <= max_a:
                return at
        return None

    def get_historical_awards(
        self, category_l2: str, country: str, supplier_id: str
    ) -> list[dict]:
        return self._historical_index.get((category_l2, country, supplier_id), [])


# Singleton
_store: DataStore | None = None


def get_store() -> DataStore:
    global _store
    if _store is None:
        _store = DataStore()
        _store.load()
    return _store
