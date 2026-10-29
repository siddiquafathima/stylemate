# StyleMate

**Smart digital wardrobe and AI-based outfit recommendation app.**
Photograph your clothes once, let AI tag them, and get outfit suggestions made only from what you already own.

![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white)
![FastAPI](https://img.shields.io/badge/FastAPI-009688?logo=fastapi&logoColor=white)
![Gemini](https://img.shields.io/badge/Google%20Gemini-4285F4?logo=googlegemini&logoColor=white)
![Render](https://img.shields.io/badge/Backend-Render-46E3B7?logo=render&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white)

| | |
|---|---|
| **Promotional video** | [Watch on Google Drive](https://drive.google.com/file/d/1FJTosp79Z4_B0BIziI7yN6vcQDackb0C/view?usp=drivesdk) |
| **AI backend (Render)** | https://stylemate-ai-g4ho.onrender.com (health check: [`/health`](https://stylemate-ai-g4ho.onrender.com/health)) |
| **Source code** | [siddiquafathima/stylemate](https://github.com/siddiquafathima/stylemate) |

> The backend runs on Render's free tier and sleeps after 15 minutes without traffic. The first AI request after a
> pause can take about a minute; opening the `/health` link first wakes it up.

---

## Table of contents
1. [Overview](#overview)
2. [Screenshots](#screenshots)
3. [Features](#features)
4. [How the AI works](#how-the-ai-works)
5. [Architecture](#architecture)
6. [Tech stack](#tech-stack)
7. [Project structure](#project-structure)
8. [Getting started](#getting-started)
9. [Themes](#themes)
10. [Known limitations](#known-limitations)
11. [Roadmap](#roadmap)
12. [Team](#team)

---

## Overview

Most people own more clothes than they realise, yet still feel they have "nothing to wear". The cause is
decision fatigue, forgotten items at the back of the closet, and no record of what has actually been worn.

StyleMate turns a physical wardrobe into a searchable digital one:

- A photo of a garment is analysed by a multimodal AI model, which fills in its category, colour, pattern and season.
- The app recommends outfits for a chosen occasion, weather and style, using **only items the user owns**, and shows the real photos together on an outfit board.
- An "Ask StyleMate" assistant answers questions such as *"Do I already have blue jeans?"* and suggests what is genuinely missing before the user buys something new.
- A calendar and analytics screens show what has been worn and what has been forgotten.

## Screenshots

Captured on a physical Android 15 phone.

<table>
  <tr>
    <td><img width="180" alt="StyleMate screenshot 1" src="https://github.com/user-attachments/assets/7e2d0722-8db9-4d5a-a192-1a9c53a39a4b" /></td>
    <td><img width="180" alt="StyleMate screenshot 2" src="https://github.com/user-attachments/assets/45fa9485-afb4-4bb0-832a-fa528aac437a" /></td>
    <td><img width="180" alt="StyleMate screenshot 3" src="https://github.com/user-attachments/assets/55259207-4443-4e08-bb99-15798bc1a507" /></td>
    <td><img width="180" alt="StyleMate screenshot 4" src="https://github.com/user-attachments/assets/0af8c878-2dba-4722-8a84-515816e75f6b" /></td>
  </tr>
  <tr>
    <td><img width="180" alt="StyleMate screenshot 5" src="https://github.com/user-attachments/assets/5cca665c-e8dc-48d7-9b96-a741b70332b0" /></td>
    <td><img width="180" alt="StyleMate screenshot 6" src="https://github.com/user-attachments/assets/87cea404-af7b-4423-9599-b438a6b5bcbc" /></td>
    <td><img width="180" alt="StyleMate screenshot 7" src="https://github.com/user-attachments/assets/062c8191-4299-48d8-a4c0-ad8c8b560c48" /></td>
    <td><img width="180" alt="StyleMate screenshot 8" src="https://github.com/user-attachments/assets/b90ebfab-7dca-44b9-b82b-19d7e24eeff1" /></td>
  </tr>
  <tr>
    <td><img width="180" alt="StyleMate screenshot 9" src="https://github.com/user-attachments/assets/bffccf20-db75-4ad2-9352-a7866b6c0140" /></td>
    <td><img width="180" alt="StyleMate screenshot 10" src="https://github.com/user-attachments/assets/7faeae33-6e7b-45af-aecf-4b30658d1f77" /></td>
    <td><img width="180" alt="StyleMate screenshot 11" src="https://github.com/user-attachments/assets/db85af51-9713-4cea-a88c-25b55a7bb304" /></td>
    <td><img width="180" alt="StyleMate screenshot 12" src="https://github.com/user-attachments/assets/d4eb1a63-5fb6-4393-a77c-3c22f6eceb7b" /></td>
  </tr>
  <tr>
    <td><img width="180" alt="StyleMate screenshot 13" src="https://github.com/user-attachments/assets/c3cb3a72-9773-4892-9ea4-6633a25a9563" /></td>
    <td><img width="180" alt="StyleMate screenshot 14" src="https://github.com/user-attachments/assets/1dd05cfc-76e1-4d5e-9fd3-2a598ed8bd70" /></td>
    <td><img width="180" alt="StyleMate screenshot 15" src="https://github.com/user-attachments/assets/709c171d-963e-4528-8bfa-6a4962429d13" /></td>
    <td><img width="180" alt="StyleMate screenshot 16" src="https://github.com/user-attachments/assets/85411b4d-42fe-4b2d-91f3-dd75936613c2" /></td>
  </tr>
</table>

## Features

**Accounts**
- Sign up / log in with email-format and common-typo checks (for example `gmail.coom`), live password-match indicator and show/hide password.
- The session is remembered; each account's data is stored separately on the device.

**Digital wardrobe**
- Add items from the camera or gallery.
- AI auto-tagging of category, sub-category, colour, pattern and season, with an editable review step (an "auto-apply" switch skips it).
- Tag picker, category filter, favourites, delete with confirmation.
- Items without a photo get a garment-specific icon (dress, jeans, sneakers, bag, watch and so on).

**Outfits**
- Create, save, view and delete outfits.
- **What should I wear?** Pick occasion, weather and style and get an explanation plus an outfit board of the real photos.
- **Ask StyleMate** is a chat assistant for wardrobe questions; the history is saved per user.

**Planning and insights**
- Style calendar: assign outfits to days (past week to next two weeks).
- Analytics: wardrobe usage percentage, closet-composition donut chart, weekly activity line chart, monthly trends bar chart, most-worn and forgotten items.
- Home shows live or manual-city weather, today's outfit and in-app notifications generated from real wardrobe data.

## How the AI works

| Feature | Input | Output |
|---|---|---|
| Clothing tagging | Photo (Base64) + instruction prompt | JSON: category, sub-category, colour, pattern, season |
| What should I wear? | Wardrobe as text records + occasion / weather / style | JSON: explanation + chosen item IDs |
| Ask StyleMate | Wardrobe as text records + free-text question | Short answer: match found, or what to buy instead |

Design choices that keep the output trustworthy:

- **No model training.** A pre-trained Gemini model is used zero-shot through prompting.
- **No invented clothes.** Returned item IDs are validated against the user's real wardrobe; unknown IDs are discarded.
- **Controlled vocabularies.** Category and season come from fixed lists; Category and Colour are required before an item can be saved.
- **Graceful failure.** On a network error or quota limit the app shows a clear message and leaves tag fields blank instead of saving a wrong guess.
- **Format fallback.** If the model's JSON is malformed, items are matched from the colour and type words in the explanation, so the outfit board still appears.

## Architecture

```mermaid
flowchart LR
    A["Flutter app (Android)"] -->|"HTTPS + app token"| B["FastAPI proxy on Render"]
    B -->|"API key kept server-side"| C["Google Gemini API"]
    A --> D[("On-device storage<br/>SharedPreferences")]
    A --> E["Open-Meteo<br/>weather"]
```

The Gemini API key and the model name live **only** on the backend (Render environment variables), so the key is
never shipped inside the app and the model can be changed without rebuilding it. Wardrobe data stays on the device.

## Tech stack

| Layer | Technology |
|---|---|
| App | Flutter, Dart |
| State management | Provider |
| AI | Google Gemini API (default model `gemini-3.5-flash-lite`, set on the server) |
| Backend | FastAPI, httpx, Uvicorn, deployed on Render |
| Local storage | SharedPreferences (JSON, scoped per user) |
| Weather | Open-Meteo (forecast + geocoding), ipapi.co / ipwho.is for approximate location, manual city override |
| Charts | fl_chart |
| Images | image_picker |
| Typography | google_fonts |
| App icon | flutter_launcher_icons |

## Project structure

```
stylemate/
├── backend/                 # FastAPI AI proxy (deployed on Render)
│   ├── main.py
│   └── requirements.txt
├── lib/
│   ├── config/              # api_config.dart (git-ignored) and api_config.example.dart
│   ├── models/              # UserModel, ClothingItem, Outfit, CalendarEntry
│   ├── services/            # Auth, Wardrobe, AI, Weather, Notification
│   ├── theme/               # three themes, backgrounds, icon styles
│   ├── widgets/             # shared UI pieces
│   └── screens/             # auth, onboarding, home, wardrobe, outfit,
│                            # calendar, analytics, notifications, profile
├── assets/images/
└── pubspec.yaml
```

## Getting started

### Prerequisites
- Flutter SDK (stable) and an Android phone with USB debugging, or an emulator
- A Google Gemini API key from [Google AI Studio](https://aistudio.google.com)
- A Render account (to host the backend)

### 1. Deploy the backend (Render)
1. Push this repository to GitHub.
2. On Render choose **New +, Web Service**, connect the repository and use these settings:

   | Setting | Value |
   |---|---|
   | Root Directory | `backend` |
   | Runtime | Python 3 |
   | Build Command | `pip install -r requirements.txt` |
   | Start Command | `uvicorn main:app --host 0.0.0.0 --port $PORT` |
   | Instance Type | Free |

3. Add these environment variables:

   | Variable | Value |
   |---|---|
   | `GEMINI_API_KEY` | your Gemini API key |
   | `APP_TOKEN` | a long random string (the app sends the same value) |
   | `GEMINI_MODEL` | optional, default `gemini-3.5-flash-lite` |

4. When the service shows **Live**, open `<your-url>/health`. You should see `"status":"ok"` and `"gemini_key_configured":true`.

Endpoints: `GET /health`, and `POST /generate` (header `x-app-token`, body is a Gemini `generateContent` request).

### 2. Run the app
```bash
git clone https://github.com/siddiquafathima/stylemate.git
cd stylemate
flutter create .            # only if the android/ folder is missing
flutter pub get
copy lib\config\api_config.example.dart lib\config\api_config.dart     # macOS/Linux: cp
```
Edit `lib/config/api_config.dart`:
```dart
const String aiBackendUrl = 'https://your-service.onrender.com';
const String aiAppToken = 'the same APP_TOKEN you set on Render';
```
Then run:
```bash
flutter run
```
`api_config.dart` is git-ignored so your token is never committed.

### 3. Build an APK (optional)
Add `<uses-permission android:name="android.permission.INTERNET"/>` to
`android/app/src/main/AndroidManifest.xml` (above `<application`), because release builds have no internet access without it. Then:
```bash
flutter build apk --release
```
The file is created at `build/app/outputs/flutter-apk/app-release.apk`.

### Changing the app icon
Replace `assets/images/app_icon_source.png` with your logo, then run `dart run flutter_launcher_icons`.

## Themes

The user picks Female, Male or Neutral during onboarding and the whole app changes immediately; there is no separate theme page.

| Choice | Theme | Character |
|---|---|---|
| Female | Pink | rounded corners, hearts-and-sparkles background, rounded icons |
| Male | Blue & Black | sharp corners, geometric background, sharp icons |
| Neutral | Beige (default) | calm, warm, outlined icons |

Beige is also used on the splash, login and sign-up screens, and again after logging out.

## Known limitations

- Wardrobe data and accounts are stored on the device only (no cloud sync). The prototype stores passwords locally without hashing, and the forgot-password flow is simulated.
- The backend is protected by one shared app token that ships inside the app. This limits casual misuse but is not per-user authentication.
- The free Render service sleeps after 15 minutes idle, so the first AI request after a pause is slow.
- The free Gemini tier is rate limited; heavy use can return HTTP 429 until the quota resets.
- Saved items cannot be edited yet (delete and re-add).
- AI tags can occasionally be wrong, which is why a review step exists.
- IP-based weather can show the wrong city; a manual city can be set.
- The outfit board is an arrangement of the user's real photos, not an AI-generated image.
- Built and tested on Android only; no iOS build.
- No formal accuracy measurement of the AI tagging has been done yet; testing so far is manual on a physical device.

## Roadmap

- Firebase Authentication and Firestore for secure accounts and multi-device sync
- AI Outfit Customizer (choose pieces, get a coordinated look) and Outfit Visualizer
- Edit screen for saved items
- Measured accuracy report for AI tagging on a labelled photo set
- iOS build

## Team

Mobile Application Development (MAD) project, Group 8, Jain (Deemed-to-be University), Bengaluru.

| Name | USN |
|---|---|
| Siddiqua Fathima | 25MCAR0121 |
| Erika Fernandes | 25MCAR0092 |
