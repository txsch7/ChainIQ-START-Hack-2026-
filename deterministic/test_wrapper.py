import json
import os

from deterministic_filtering import filter_pricing
from policies_added import run_policy_enrichment


def run_tests(test_file):
    with open(test_file, "r") as f:
        test_requests = json.load(f)

    os.makedirs("test_outputs", exist_ok=True)

    summary = []

    for req in test_requests:
        print(f"\n--- Running {req['request_id']} ---")

        try:
            filter_pricing(
                pricing_csv_path="data/pricing.csv",
                request=req,
                output_path=f"test_outputs/{req['request_id']}_filtered.json",
                log_path=f"test_outputs/{req['request_id']}_log.json"
            )

            run_policy_enrichment(
                filtered_path=f"test_outputs/{req['request_id']}_filtered.json",
                policies_path="data/policies.json",
                output_path=f"test_outputs/{req['request_id']}_enriched.json",
                request=req
            )

            summary.append({
                "request_id": req["request_id"],
                "status": "success"
            })

        except Exception as e:
            print(f"Error: {e}")
            summary.append({
                "request_id": req["request_id"],
                "status": "failed",
                "error": str(e)
            })

    # Summary file
    with open("test_outputs/summary.json", "w") as f:
        json.dump(summary, f, indent=2)

    print("\nAll tests completed")


if __name__ == "__main__":
    run_tests("data/test_requests.json")