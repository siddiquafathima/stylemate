# StyleMate

Smart wardrobe and outfit planner (Flutter) with AI tagging, outfit suggestions and a wardrobe chat assistant.

- `lib/` - the Flutter app
- `backend/` - FastAPI service (deployed on Railway) that holds the Gemini API key

## Run the app
```
flutter create .
flutter pub get
# copy lib/config/api_config.example.dart to lib/config/api_config.dart
# and fill in your Railway URL + APP_TOKEN
flutter run
```

## Build an APK
Add `<uses-permission android:name="android.permission.INTERNET"/>` to
`android/app/src/main/AndroidManifest.xml` (above `<application`), then:
```
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

## Icon
Replace `assets/images/app_icon_source.png`, then `dart run flutter_launcher_icons`.
