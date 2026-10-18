"""
StyleMate AI proxy (FastAPI) -- deploy this on Railway.

The Flutter app sends its Gemini-style request body to POST /generate.
This service adds the Gemini API key (kept in a Railway environment
variable, never in the app) and forwards the request to Google. The
model name is also chosen here, so it can be changed without
rebuilding the APK.
"""
import os

import httpx
from fastapi import FastAPI, Header, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import Response

GEMINI_API_KEY = os.environ.get("GEMINI_API_KEY", "")
APP_TOKEN = os.environ.get("APP_TOKEN", "")
GEMINI_MODEL = os.environ.get("GEMINI_MODEL", "gemini-3.5-flash-lite")
GEMINI_BASE_URL = os.environ.get(
    "GEMINI_BASE_URL", "https://generativelanguage.googleapis.com/v1beta"
)
MAX_BODY_BYTES = 15 * 1024 * 1024  # photos are sent as Base64, so allow ~15 MB

app = FastAPI(title="StyleMate AI Proxy")
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_methods=["*"], allow_headers=["*"])


@app.get("/")
@app.get("/health")
def health():
    return {
        "status": "ok",
        "service": "StyleMate AI proxy",
        "model": GEMINI_MODEL,
        "gemini_key_configured": bool(GEMINI_API_KEY),
        "app_token_required": bool(APP_TOKEN),
    }


@app.post("/generate")
async def generate(request: Request, x_app_token: str = Header(default="")):
    # Shared-secret check: stops casual strangers from spending your quota.
    if APP_TOKEN and x_app_token != APP_TOKEN:
        raise HTTPException(status_code=401, detail="Invalid app token")
    if not GEMINI_API_KEY:
        raise HTTPException(status_code=500, detail="GEMINI_API_KEY is not set on the server")

    raw = await request.body()
    if len(raw) > MAX_BODY_BYTES:
        raise HTTPException(status_code=413, detail="Request too large")

    url = f"{GEMINI_BASE_URL}/models/{GEMINI_MODEL}:generateContent"
    try:
        async with httpx.AsyncClient(timeout=60) as client:
            upstream = await client.post(
                url,
                content=raw,
                headers={"Content-Type": "application/json", "x-goog-api-key": GEMINI_API_KEY},
            )
    except httpx.TimeoutException:
        raise HTTPException(status_code=504, detail="Gemini timed out")
    except httpx.HTTPError as e:
        raise HTTPException(status_code=502, detail=f"Could not reach Gemini: {e}")

    # Pass Gemini's answer (and its status code, e.g. 429 quota) straight back.
    return Response(content=upstream.content, status_code=upstream.status_code,
                    media_type="application/json")
