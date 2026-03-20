"""SAP integration router — mock only, feature-flagged via SAP_ENABLED."""
import os

import pandas as pd
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

from app.config import SAP_ENABLED
from app.data.store import get_store
from app.integrations import sap_mock

router = APIRouter(prefix="/sap", tags=["sap"])

_DISABLED_MSG = "SAP integration is disabled (set SAP_ENABLED=true)"


class SupplierSyncBody(BaseModel):
    category_l1: str
    category_l2: str
    dry_run: bool = False


class OrderExportBody(BaseModel):
    request_id: str
    purchasing_org: str = "1000"
    purchasing_group: str = "001"
    company_code: str = "1000"


@router.post("/suppliers/sync")
async def suppliers_sync(body: SupplierSyncBody):
    if not SAP_ENABLED:
        raise HTTPException(status_code=503, detail=_DISABLED_MSG)

    mapped = []
    for bp in sap_mock.MOCK_BUSINESS_PARTNERS:
        supplier_id = bp["BusinessPartner"]
        country = bp["CountryOfOrigin"]
        row = {
            "supplier_id": supplier_id,
            "supplier_name": bp["BusinessPartnerFullName"],
            "category_l1": body.category_l1,
            "category_l2": body.category_l2,
            "country_hq": country,
            "service_regions": country,
            "service_regions_set": {country},
            "quality_score": 70,
            "risk_score": 30,
            "esg_score": 60,
            "preferred_supplier": False,
            "is_restricted": False,
            "data_residency_supported": False,
            "capacity_per_month": 5000,
            "currency": "EUR",
            "pricing_model": "tiered",
            "notes": f"Imported from SAP mock. BP: {supplier_id}",
        }
        mapped.append(row)

    if not body.dry_run:
        store = get_store()
        new_rows = pd.DataFrame(mapped)
        store.suppliers = pd.concat([store.suppliers, new_rows], ignore_index=True)
        for row in mapped:
            key = (row["supplier_id"], row["category_l2"])
            store._supplier_index[key] = row

    return {
        "sap_mode": "mock",
        "total_fetched": len(sap_mock.MOCK_BUSINESS_PARTNERS),
        "suppliers_mapped": mapped,
        "dry_run": body.dry_run,
        "message": (
            f"Dry run — no changes applied."
            if body.dry_run
            else f"{len(mapped)} suppliers imported into DataStore."
        ),
    }


@router.post("/orders/export")
async def orders_export(body: OrderExportBody):
    if not SAP_ENABLED:
        raise HTTPException(status_code=503, detail=_DISABLED_MSG)

    if not os.environ.get("DATABASE_URL"):
        raise HTTPException(status_code=503, detail="DATABASE_URL not set — persistence disabled")

    from app.db import repository

    record = repository.get_request(body.request_id)
    if not record:
        raise HTTPException(status_code=404, detail=f"Request '{body.request_id}' not found")

    response_json = record.get("response_json") or {}
    recommendation = response_json.get("recommendation") or {}

    if recommendation.get("status") != "recommended":
        raise HTTPException(
            status_code=422,
            detail=f"Request is not in 'recommended' state (status={recommendation.get('status')!r})",
        )

    winner_id = recommendation.get("winner_id", "")
    winner = recommendation.get("winner", "")

    # Extract price from shortlist rank-1 entry
    shortlist = response_json.get("supplier_shortlist", [])
    unit_price_eur = None
    if shortlist:
        top = sorted(shortlist, key=lambda s: s.get("rank", 999))[0]
        unit_price_eur = top.get("unit_price_eur") or top.get("total_price_eur")

    request_interp = response_json.get("request_interpretation") or {}
    quantity = request_interp.get("quantity")
    currency = request_interp.get("currency", "EUR")

    total_price_eur = (
        round(unit_price_eur * quantity, 2)
        if unit_price_eur is not None and quantity is not None
        else None
    )

    payload = {
        "supplier_id": winner_id,
        "supplier_name": winner,
        "currency": currency,
        "purchasing_org": body.purchasing_org,
        "purchasing_group": body.purchasing_group,
        "company_code": body.company_code,
        "quantity": quantity,
        "unit_price_eur": unit_price_eur,
    }

    sap_response = sap_mock.generate_mock_po_response(payload)

    return {
        "sap_mode": "mock",
        "request_id": body.request_id,
        "sap_purchase_order": sap_response["PurchaseOrder"],
        "supplier_id": winner_id,
        "supplier_name": winner,
        "total_price_eur": total_price_eur,
        "payload_sent": payload,
        "sap_response": sap_response,
    }
