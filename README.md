# SaverQuest

SaverQuest는 **경량 가계부 + 절약 인사이트**에 초점을 둔 Flutter 앱입니다.  
거래를 빠르게 기록하고, 월 예산을 관리하고, 홈/리포트/인사이트 화면에서 바로 결과를 확인할 수 있도록 설계되어 있습니다.

현재는 **Android 우선 배포**를 기준으로 정리되어 있으며, 로컬 저장소 기반 동작, 광고/동의 처리, 기본 릴리즈 품질 게이트를 포함합니다.

## 주요 기능

- **온보딩 + 개인정보 동의 흐름**
  - AdMob/개인정보 처리 준비
  - 설정 화면에서 개인정보 옵션 재진입 가능
- **빠른 거래 기록**
  - 지출/수입 입력
  - 카테고리 선택
  - 날짜 선택
  - 거래 수정 / 삭제
- **월 예산 관리**
  - 월 예산 저장
  - 예산 대비 사용 현황 확인
- **홈 대시보드**
  - 최근 거래
  - 월간 예산 요약
  - 빠른 액션 진입점
- **월간 리포트**
  - 카테고리별 합계
  - 최근 거래 목록
  - 필터 기반 탐색
- **인사이트 화면**
  - 소비 패턴 요약
  - 절약 관점의 다음 액션 힌트
- **로컬 우선 아키텍처**
  - `SharedPreferences` 기반 저장
  - 네트워크 동기화 없이도 핵심 기능 사용 가능

## 기술 스택

- **Flutter / Dart**
- **Firebase**
  - Analytics
  - Crashlytics
  - Remote Config
- **Google Mobile Ads (AdMob)**
- **Shared Preferences**

## 프로젝트 구조

```text
lib/
  app/        앱 부트스트랩, 라우트, 의존성 구성
  core/       광고, 동의, 로깅, 로컬 저장, 디자인 토큰, 로컬라이제이션
  features/   home / tool / report / insights / onboarding / settings
  widgets/    공용 화면 셸 및 재사용 UI 블록

test/
  core/       도메인/서비스/컨트롤러 테스트
  features/   화면 회귀 테스트
  widgets/    공용 UI 블록 테스트
```

## 빠른 실행

```bash
flutter pub get
flutter run
```

## 품질 게이트

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug
```

## 문서

- 로드맵: `docs/product/saverquest-ledger-roadmap.md`
- 내부 테스트 핸드오프: `docs/release/android-internal-testing-handoff.md`
- 개인정보 처리방침 문서: `docs/legal/privacy-policy.md`
- 정적 개인정보 페이지: `docs/privacy/index.html`

## 브랜치 전략

이 저장소는 git-flow 스타일 브랜치 규칙을 사용합니다.

- `main`: 배포 기준 히스토리
- `codex/develop`: 통합 브랜치
- `codex/feature/*`: 기능 작업
- `codex/release/*`: 릴리즈 안정화
- `codex/hotfix/*`: 운영 긴급 수정

## 릴리즈 메모

- Android 서명 정보는 로컬 `android/key.properties`로 관리합니다.
- 업로드 keystore 및 Firebase 설정 파일은 Git에 포함하지 않습니다.
- 프로덕션 배포 전에는 실제 Android 기기에서 광고/동의 흐름 확인을 권장합니다.
- AAB 생성 예시:

```bash
flutter build appbundle --release
```

## 현재 방향

SaverQuest는 단순 절약 계산기 데모에서 벗어나,
**거래 기록 → 예산 확인 → 리포트 → 인사이트**로 자연스럽게 이어지는
개인 재무 습관 앱으로 확장되는 중입니다.
