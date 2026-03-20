"""CRUD operations for request_records."""
import json

from app.db.database import get_conn

RESUME_HINTS = {
    "ER-001": "state2", "ER-002": "state3", "ER-003": "state4",
    "ER-004": "state4", "ER-005": "state3", "ER-006": "state4",
    "ER-007": "state3", "ER-008": "state3",
}


def upsert_request(request_id: str, status: str, extracted_data: dict, response: dict) -> None:
    escalations = response.get("escalations", [])
    resume_from = next(
        (RESUME_HINTS.get(e["rule"]) for e in escalations if e.get("blocking")), None
    )
    with get_conn() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                INSERT INTO request_records
                    (request_id, status, extracted_data, response_json, escalations, resume_from)
                VALUES (%s, %s, %s::jsonb, %s::jsonb, %s::jsonb, %s)
                ON CONFLICT (request_id) DO UPDATE SET
                    status         = EXCLUDED.status,
                    updated_at     = NOW(),
                    extracted_data = EXCLUDED.extracted_data,
                    response_json  = EXCLUDED.response_json,
                    escalations    = EXCLUDED.escalations,
                    resume_from    = EXCLUDED.resume_from
                """,
                (
                    request_id,
                    status,
                    json.dumps(extracted_data),
                    json.dumps(response),
                    json.dumps(escalations),
                    resume_from,
                ),
            )


def list_requests(status: str | None = None, limit: int = 100, offset: int = 0) -> list[dict]:
    with get_conn() as conn:
        with conn.cursor() as cur:
            if status:
                cur.execute(
                    "SELECT * FROM request_records WHERE status=%s ORDER BY created_at DESC LIMIT %s OFFSET %s",
                    (status, limit, offset),
                )
            else:
                cur.execute(
                    "SELECT * FROM request_records ORDER BY created_at DESC LIMIT %s OFFSET %s",
                    (limit, offset),
                )
            cols = [d[0] for d in cur.description]
            return [dict(zip(cols, row)) for row in cur.fetchall()]


def get_request(request_id: str) -> dict | None:
    with get_conn() as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT * FROM request_records WHERE request_id=%s", (request_id,))
            row = cur.fetchone()
            if not row:
                return None
            cols = [d[0] for d in cur.description]
            return dict(zip(cols, row))


def update_request_status(
    request_id: str,
    status: str,
    response: dict | None = None,
    resolved_by: str | None = None,
    resolution_note: str | None = None,
) -> None:
    with get_conn() as conn:
        with conn.cursor() as cur:
            if response is not None:
                cur.execute(
                    """
                    UPDATE request_records
                    SET status=%s, updated_at=NOW(), response_json=%s::jsonb,
                        escalations=%s::jsonb, resolved_by=%s, resolution_note=%s
                    WHERE request_id=%s
                    """,
                    (
                        status,
                        json.dumps(response),
                        json.dumps(response.get("escalations", [])),
                        resolved_by,
                        resolution_note,
                        request_id,
                    ),
                )
            else:
                cur.execute(
                    """
                    UPDATE request_records
                    SET status=%s, updated_at=NOW(), resolved_by=%s, resolution_note=%s
                    WHERE request_id=%s
                    """,
                    (status, resolved_by, resolution_note, request_id),
                )
