"""PostgreSQL connection pool and schema initialisation."""
import os
import psycopg2
import psycopg2.pool
from contextlib import contextmanager

_pool: psycopg2.pool.SimpleConnectionPool | None = None

CREATE_SQL = """
CREATE TABLE IF NOT EXISTS request_records (
    id              SERIAL PRIMARY KEY,
    request_id      TEXT NOT NULL UNIQUE,
    status          TEXT NOT NULL DEFAULT 'completed',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    extracted_data  JSONB NOT NULL,
    response_json   JSONB NOT NULL,
    escalations     JSONB NOT NULL,
    resume_from     TEXT,
    resolved_by     TEXT,
    resolution_note TEXT
);
CREATE INDEX IF NOT EXISTS idx_rr_status   ON request_records(status);
CREATE INDEX IF NOT EXISTS idx_rr_created  ON request_records(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_rr_esc_gin  ON request_records USING GIN (escalations);
"""


def init_db() -> None:
    global _pool
    database_url = os.environ["DATABASE_URL"]
    _pool = psycopg2.pool.SimpleConnectionPool(1, 10, database_url)
    with get_conn() as conn:
        with conn.cursor() as cur:
            cur.execute(CREATE_SQL)


@contextmanager
def get_conn():
    conn = _pool.getconn()
    try:
        yield conn
        conn.commit()
    except Exception:
        conn.rollback()
        raise
    finally:
        _pool.putconn(conn)
