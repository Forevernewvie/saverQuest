# Android Internal Testing Handoff

## Build status
- Branch source: `main`
- Package: `com.saverquest.app`
- App name: `SaverQuest`
- Version: `1.0.0+1`
- Latest verified AAB: `build/app/outputs/bundle/release/app-release.aab`
- AAB rebuilt on: `2026-03-07 11:54:54 KST`

## Verification completed
- `flutter analyze`: pass
- `flutter test`: pass
- `flutter build appbundle --release`: pass
- `flutter build apk --debug`: pass
- Android emulator install: pass
- Android emulator launch: pass

## Emulator smoke QA
Device:
- `emulator-5554`
- Android 14 / API 34

Checked flows:
- App install and launch
- Onboarding screen renders under `com.saverquest.app`
- Settings screen renders correctly
- Calculator screen renders correctly and input fields are present

Observed note:
- One early emulator screenshot returned a stale task snapshot from another app.
- UI Automator dump and a fresh screenshot confirmed the current foreground UI is the SaverQuest app.
- This is an emulator snapshot artifact, not a confirmed app defect.

## Monetization and compliance state
- Android AdMob App ID configured
- Android banner ad unit configured
- Interstitial and rewarded remain optional and unconfigured
- Consent flow is implemented
- Privacy settings entry point is present in Settings

## Internal testing upload checklist
1. Upload `build/app/outputs/bundle/release/app-release.aab` to Play Console Internal testing.
2. Confirm app name, screenshots, and store listing text.
3. Add privacy policy URL before production rollout.
4. Keep `android/key.properties` and the upload keystore backed up outside the repo.
5. Verify banner ad behavior on a real Android device before closed or production rollout.

## Remaining release blockers
- Play Console upload must be done manually.
- Privacy policy URL is still required for production listing.
- Real-device Android QA is still recommended before public release.
