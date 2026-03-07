# SaverQuest Infrastructure Quality Execution

## Applied changes
- `ConsentController`에 logger를 주입하고 SDK callback 흐름을 `_runSdkFlow`로 통합했다.
- `GoogleMobileAdService`에 logger를 주입하고 공통 ad parameter/helper 메서드를 도입했다.
- `AdBannerSlot`의 retry/size/margin 값을 명시 상수로 분리했다.
- 관련 함수에 목적 주석을 추가했다.

## Files changed
- lib/core/consent/consent_controller.dart
- lib/core/ads/google_mobile_ad_service.dart
- lib/widgets/ad_banner_slot.dart
- lib/app/app_bootstrapper.dart
- test/helpers/fakes.dart
- test/core/consent/consent_controller_test.dart

## Error/Security/Performance notes
- consent SDK callback 예외는 logger + state sync fallback으로 흡수됨
- ads SDK 초기화 실패는 app crash 대신 skip event와 error log로 전환됨
- banner retry는 bounded retry로 유지되어 무한 재시도 위험이 없음
- 추가 logging은 lightweight metadata 수준이며 병목 가능성 낮음

## Validation
- `flutter analyze` passed
- `flutter test` passed
- `flutter build apk --debug` passed
