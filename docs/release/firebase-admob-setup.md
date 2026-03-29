# Firebase / AdMob 설정 메모

이 문서는 SaverQuest의 **개발 환경 경고를 줄인 현재 동작 방식**과  
**실제 Firebase / AdMob 릴리즈 준비 절차**를 빠르게 이어가기 위한 메모입니다.

## 현재 기본 동작

- `dev` / `stage` 환경
  - Firebase: **기본 비활성화**
  - AdMob: **Google test app id / test ad unit id 사용**
- `prod` 환경
  - Firebase: **기본 활성화**
  - AdMob: **프로덕션 app id / unit id 사용**

즉, 개발 환경에서는 설정 파일이 없더라도 앱이 경고 없이 최대한 안전하게 뜨도록 정리되어 있습니다.

## 왜 이렇게 바뀌었는가

저장소에는 현재 아래 파일이 없습니다.

- `google-services.json`
- `firebase_options.dart`
- `GoogleService-Info.plist`

그런데 Firebase SDK 초기화 코드는 이미 존재하므로, 개발 환경에서 Firebase를 무조건 켜면 아래와 같은 경고가 발생했습니다.

- `Missing google_app_id`
- `Firebase Analytics disabled`

또한 Android debug 빌드에서 production AdMob app id를 쓰면 UMP / AdMob misconfiguration 경고가 섞여 디버깅이 지저분해졌습니다.

## 관련 코드 위치

- Firebase enable/disable:
  - `lib/core/config/app_runtime_options.dart`
  - `lib/app/app_bootstrapper.dart`
- AdMob unit id:
  - `lib/core/ads/admob_ids.dart`
- Android AdMob app id:
  - `android/app/build.gradle.kts`
  - `android/app/src/main/AndroidManifest.xml`

## 비생산 환경에서 Firebase를 강제로 켜고 싶을 때

기본값은 꺼져 있지만, 필요하면 compile-time define으로 켤 수 있습니다.

```bash
flutter run \
  --dart-define=APP_ENV=dev \
  --dart-define=ENABLE_FIREBASE=true
```

단, 이 경우 실제 Firebase 설정 파일이나 옵션 코드가 준비되어 있어야 합니다.

## Firebase를 실제로 붙이려면

둘 중 하나는 반드시 필요합니다.

### 방식 A: FlutterFire 설정 사용

권장 방식:

1. Firebase 프로젝트 생성/선택
2. Android 앱 `com.saverquest.app` 등록
3. `flutterfire configure` 실행
4. 생성된 `lib/firebase_options.dart`를 프로젝트에 포함
5. `Firebase.initializeApp()`에 options 연결

예시:

```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

### 방식 B: Android 전통 방식

1. Firebase 콘솔에서 Android 앱 등록
2. `google-services.json` 다운로드
3. `android/app/google-services.json` 배치
4. 필요 시 Gradle Google Services plugin 연결

현재 저장소는 아직 이 구성이 들어있지 않습니다.

## AdMob 준비

### 개발 / QA

- 현재 debug 쪽은 Google sample app id를 사용하도록 정리되어 있음
- non-prod unit id도 Google test unit id를 기본 사용
- 실제 광고 대신 테스트 광고 검증에 적합

### 프로덕션

다음 값은 실제 운영 계정 기준으로 다시 검토해야 합니다.

- Android App ID
- Home / Report / Settings banner unit id
- Interstitial / Rewarded unit id 사용 여부

## Android release 체크리스트

### 필수

- [ ] `android/key.properties` 준비
- [ ] release keystore 준비
- [ ] Firebase 설정 연결 (`google-services.json` 또는 `firebase_options.dart`)
- [ ] prod AdMob app id / unit id 검증
- [ ] `flutter analyze`
- [ ] `flutter test`
- [ ] `flutter build appbundle --release`

### 권장

- [ ] 실제 Android 기기에서 온보딩/동의 흐름 확인
- [ ] 홈/리포트/설정 하단 광고 영역 확인
- [ ] Crashlytics 수집 여부 확인
- [ ] Analytics 이벤트 수집 여부 확인

## 현재 남아 있는 외부 의존 리스크

- Firebase 실환경 연결은 아직 미완
- release signing 자료가 저장소에 없음
- production AdMob 계정/폼 설정은 저장소 밖에서 검증 필요

## 한 줄 요약

지금 SaverQuest는 **개발 환경에서 불필요한 Firebase/AdMob 경고 없이 뜨도록 안정화된 상태**이며,  
실서비스 전환은 **설정 파일 / 계정 값 / 릴리즈 서명**을 붙이는 작업이 남아 있습니다.
