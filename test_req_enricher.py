import json

# ---------------------------
# REGION MAPPING
# ---------------------------
REGION_MAP = {
    "EU": ["DE", "FR", "NL", "BE", "AT", "IT", "ES", "PL", "UK"],
    "CH": ["CH"],
    "Americas": ["US", "CA", "BR", "MX"],
    "APAC": ["SG", "AU", "IN", "JP"],
    "MEA": ["UAE", "ZA"]
}


def map_countries_to_regions(delivery_countries):
    regions = set()

    for country in delivery_countries:
        for region, countries in REGION_MAP.items():
            if country in countries:
                regions.add(region)

    return list(regions)


# ---------------------------
# MAIN FUNCTION
# ---------------------------
def enrich_requests_with_region(input_path, output_path):
    with open(input_path, "r") as f:
        data = json.load(f)

    # Handle both single object and list
    if isinstance(data, dict):
        data = [data]

    enriched_requests = []

    for req in data:
        delivery_countries = req.get("delivery_countries", [])

        regions = map_countries_to_regions(delivery_countries)

        # Add region field
        req["region"] = regions

        enriched_requests.append(req)

    # If only one request → save as object (not list)
    output_data = enriched_requests[0] if len(enriched_requests) == 1 else enriched_requests

    with open(output_path, "w") as f:
        json.dump(output_data, f, indent=2)

    print(f"Region enrichment complete → {output_path}")


# ---------------------------
# TEST RUN
# ---------------------------
if __name__ == "__main__":
    enrich_requests_with_region(
        input_path="data/requests.json",
        output_path="data/test_requests.json"
    )