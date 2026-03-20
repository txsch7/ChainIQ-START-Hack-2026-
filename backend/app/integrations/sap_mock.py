"""Mock SAP data layer — no real HTTP calls, ever."""
from datetime import date

MOCK_BUSINESS_PARTNERS: list[dict] = [
    {
        "BusinessPartner": "SAP-BP-0001",
        "BusinessPartnerFullName": "TechNord GmbH",
        "BusinessPartnerCategory": "2",
        "CountryOfOrigin": "DE",
        "Industry": "IT",
        "Currency": "EUR",
        "PaymentTerms": "ZB14",
    },
    {
        "BusinessPartner": "SAP-BP-0002",
        "BusinessPartnerFullName": "Nordic Supplies AB",
        "BusinessPartnerCategory": "2",
        "CountryOfOrigin": "SE",
        "Industry": "IT",
        "Currency": "EUR",
        "PaymentTerms": "ZB30",
    },
    {
        "BusinessPartner": "SAP-BP-0003",
        "BusinessPartnerFullName": "Iberian Tech Solutions SL",
        "BusinessPartnerCategory": "2",
        "CountryOfOrigin": "ES",
        "Industry": "IT",
        "Currency": "EUR",
        "PaymentTerms": "ZB14",
    },
    {
        "BusinessPartner": "SAP-BP-0004",
        "BusinessPartnerFullName": "Alpine Systems AG",
        "BusinessPartnerCategory": "2",
        "CountryOfOrigin": "CH",
        "Industry": "IT",
        "Currency": "CHF",
        "PaymentTerms": "ZB30",
    },
    {
        "BusinessPartner": "SAP-BP-0005",
        "BusinessPartnerFullName": "Benelux Digital BV",
        "BusinessPartnerCategory": "2",
        "CountryOfOrigin": "NL",
        "Industry": "IT",
        "Currency": "EUR",
        "PaymentTerms": "ZB14",
    },
]


def generate_mock_po_response(payload: dict) -> dict:
    today = date.today().isoformat()
    return {
        "@odata.context": "$metadata#A_PurchaseOrder/$entity",
        "PurchaseOrder": "45A3F9C1B2",
        "PurchaseOrderType": "NB",
        "Supplier": payload.get("supplier_id", ""),
        "DocumentCurrency": payload.get("currency", "EUR"),
        "PurchasingOrganization": payload.get("purchasing_org", "1000"),
        "PurchasingGroup": payload.get("purchasing_group", "001"),
        "CompanyCode": payload.get("company_code", "1000"),
        "CreationDate": today,
        "PurchaseOrderDate": today,
        "PaymentTerms": "ZB14",
        "PurchaseOrderStatus": "I",
    }
