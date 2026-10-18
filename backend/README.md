# StyleMate AI backend (FastAPI on Railway)

Holds the Gemini API key and forwards the app's AI requests to Google.

## Environment variables (set in Railway -> Variables)
| Name | Value |
|---|---|
| `GEMINI_API_KEY` | your (new) Gemini API key from Google AI Studio |
| `APP_TOKEN` | any long random string; the same value goes in the app's `api_config.dart` |
| `GEMINI_MODEL` | optional, default `gemini-3.5-flash-lite` |

## Endpoints
- `GET /health` - status check (also shows whether the key and token are configured)
- `POST /generate` - header `x-app-token`, body = a Gemini `generateContent` request

## Run locally
```
pip install -r requirements.txt
set GEMINI_API_KEY=...   (Windows: set / PowerShell: $env:GEMINI_API_KEY="...")
set APP_TOKEN=secret123
uvicorn main:app --reload
```
