# Repository Governance

## Branch Model
- `main`: production-ready branch
- `codex/develop`: integration branch for tested work
- `codex/feature/*`: feature branches created from `codex/develop`
- `codex/release/*`: release hardening from `codex/develop`
- `codex/hotfix/*`: urgent production fixes from `main`

## Merge Policy
- Feature work lands in `codex/develop` first
- Release branches merge into `main` after validation
- Hotfix branches merge into both `main` and `codex/develop`
- Direct pushes to `main` should be avoided except for repository bootstrap or emergency maintenance

## CI Policy
- Every push to `main`, `codex/develop`, and `codex/feature/*` runs:
  - `flutter pub get`
  - `flutter analyze`
  - `flutter test`
  - `flutter build apk --debug`

## Protection Rules
- Protect `main`
- Protect `codex/develop`
- Require status check: `quality`
- Block force pushes
- Block branch deletion
- Keep administrator bypass disabled unless recovery is required

## Release Checklist
- Version updated in `pubspec.yaml`
- `flutter analyze` passes
- `flutter test` passes
- `flutter build appbundle --release` passes
- AdMob IDs verified for production
- Privacy policy URL configured in store listing
- Internal testing track validated before production rollout
