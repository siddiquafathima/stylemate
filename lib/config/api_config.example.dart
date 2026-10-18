/// Where the app finds its AI backend (the FastAPI service in /backend,
/// deployed on Railway). The Gemini API key is NOT stored in the app --
/// it lives only in Railway's environment variables.
///
/// 1. After deploying, paste the Railway public URL below (no trailing slash needed).
/// 2. Paste the same APP_TOKEN you set in Railway.
///
/// Do not commit real values to a public repo: this file is git-ignored,
/// and api_config.example.dart shows the shape.
const String aiBackendUrl = 'https://YOUR-APP.up.railway.app';
const String aiAppToken = 'PASTE_YOUR_APP_TOKEN_HERE';
