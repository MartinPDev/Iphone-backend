"""End-to-end contract smoke test for the FastAPI routes used by NexoraMobile.

Run from the backend repository:
    DATABASE_URL=sqlite:////tmp/nexora-mobile-test.db \
    ENCRYPTION_KEY=<fernet-key> \
    python /path/to/Iphone-backend/tests/mobile_api_contract.py
"""

from __future__ import annotations

import os
import sys
import uuid
from pathlib import Path


BACKEND_ROOT = Path(os.environ.get("NEXORA_BACKEND_ROOT", Path(__file__).parents[2]))
sys.path.insert(0, str(BACKEND_ROOT))

from fastapi.testclient import TestClient
from app.main import app
from app.core.database import Base, engine
from app.models import bot, exchange_key, strategy, user  # noqa: F401


def assert_status(response, expected: int = 200):
    assert response.status_code == expected, (
        f"{response.request.method} {response.request.url}: "
        f"expected {expected}, got {response.status_code}: {response.text}"
    )
    return response.json()


def run() -> None:
    Base.metadata.create_all(bind=engine)
    suffix = uuid.uuid4().hex[:10]
    username = f"mobile-{suffix}"
    password = f"Mobile-{suffix}-Pass!"

    with TestClient(app) as client:
        user = assert_status(
            client.post(
                "/api/v1/auth/register",
                json={
                    "email": f"{username}@example.com",
                    "username": username,
                    "password": password,
                },
            )
        )
        assert user["username"] == username

        login = assert_status(
            client.post(
                "/api/v1/auth/login",
                json={"username_or_email": username, "password": password},
            )
        )
        token = login["access_token"]
        headers = {"Authorization": f"Bearer {token}"}

        profile = assert_status(client.get("/api/v1/users/me", headers=headers))
        assert profile["id"] == user["id"]

        strategy = assert_status(
            client.post(
                "/api/v1/strategies",
                headers=headers,
                json={
                    "name": "Mobile smoke strategy",
                    "symbol": "BTC/USD",
                    "timeframe": "15m",
                    "risk_percent": 1.0,
                    "take_profit_percent": 4.0,
                    "stop_loss_percent": 2.0,
                    "is_ai_enabled": True,
                    "config_json": {},
                },
            )
        )
        strategies = assert_status(client.get("/api/v1/strategies", headers=headers))
        assert strategy["id"] in {item["id"] for item in strategies}

        exchange = assert_status(
            client.post(
                "/api/v1/exchanges/keys",
                headers=headers,
                json={
                    "exchange_name": "kraken",
                    "api_key": "test-key",
                    "api_secret": "test-secret",
                    "is_testnet": True,
                    "label": "Mobile smoke exchange",
                },
            )
        )
        assert "api_key" not in exchange and "api_secret" not in exchange
        exchanges = assert_status(client.get("/api/v1/exchanges/keys", headers=headers))
        assert exchange["id"] in {item["id"] for item in exchanges}

        bot = assert_status(
            client.post(
                "/api/v1/bots",
                headers=headers,
                json={
                    "name": "Mobile smoke bot",
                    "strategy_id": strategy["id"],
                    "exchange_key_id": exchange["id"],
                },
            )
        )
        bots = assert_status(client.get("/api/v1/bots", headers=headers))
        assert bot["id"] in {item["id"] for item in bots}

        toggled = assert_status(
            client.patch(
                f"/api/v1/bots/{bot['id']}/toggle",
                headers=headers,
                json={"is_enabled": True},
            )
        )
        assert toggled["is_enabled"] is True
        assert toggled["status"] == "queued"

        unauthorized = client.get("/api/v1/bots")
        assert unauthorized.status_code in {401, 403}

    print("mobile-api-contract: PASS")


if __name__ == "__main__":
    run()
