# SaverQuest

SaverQuest is a Flutter mobile app focused on savings habits, quick calculators, and lightweight reporting. The current release target is Android first, with AdMob banner monetization and consent handling prepared for store distribution.

## Stack
- Flutter
- Firebase Analytics / Crashlytics / Remote Config
- Google Mobile Ads (AdMob)

## Run
```bash
flutter pub get
flutter run
```

## Quality Gate
```bash
flutter analyze
flutter test
flutter build apk --debug
```

## Branch Strategy
This repository follows a git-flow style model with the following branch roles:

- `main`: production-ready history
- `codex/develop`: integration branch
- `codex/feature/*`: feature work
- `codex/release/*`: release hardening
- `codex/hotfix/*`: production fixes

## Release Notes
- Android signing is configured locally through `android/key.properties`
- Upload keystore and Firebase config files are intentionally excluded from Git
- Android App Bundle output is generated with `flutter build appbundle --release`
