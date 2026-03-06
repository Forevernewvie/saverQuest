# SaverQuest Quality Architecture Execution

## Applied architectural changes
- `AppBootstrapper` 도입으로 앱 시작 책임을 `main.dart`에서 분리했다.
- `AppRuntimeOptions` 도입으로 환경변수 파싱을 테스트 가능한 객체로 분리했다.
- `AppLogger` 도입으로 서비스 계층 로깅을 일관되게 통합했다.
- `StaticAppContentRepository` 도입으로 홈/리포트/인사이트/계산기 기본 데이터를 UI 밖으로 이동했다.
- 금액/일수/카테고리 표시를 로컬라이징 함수 기반으로 변경했다.

## Files changed
- lib/app/app_bootstrapper.dart
- lib/app/app_dependencies.dart
- lib/main.dart
- lib/core/config/app_environment.dart
- lib/core/config/app_runtime_options.dart
- lib/core/content/app_content_repository.dart
- lib/core/logging/app_logger.dart
- lib/core/analytics/analytics_service.dart
- lib/core/config/remote_config_service.dart
- lib/core/crash/crash_reporter.dart
- lib/core/localization/app_localizations.dart
- lib/features/home/home_page.dart
- lib/features/report/report_page.dart
- lib/features/insights/insights_page.dart
- lib/features/tool/tool_page.dart
- lib/features/tool/domain/savings_calculator.dart
- test/helpers/fakes.dart
- test/core/config/app_runtime_options_test.dart
- test/core/content/static_app_content_repository_test.dart
- test/core/consent/consent_controller_test.dart

## Error risk analysis
- Firebase 초기화 실패: `AppBootstrapper`에서 graceful fallback 처리
- Remote Config 실패: 기본값 유지 + warning/error logging
- 광고/동의 실패: 기존 fallback 유지, UI는 저장소와 상태만 소비
- 환경변수 파싱 오류: `AppRuntimeOptions`에서 기본 환경/빈 리스트로 normalize

## Security analysis
- 로그 민감정보 노출 위험: `AppLogger`가 `token/password/secret/authorization` 키를 redaction
- 프로덕션 테스트 광고 노출 위험: 환경 옵션과 기존 AdMob readiness 경고 유지
- Firebase 미설정 상태에서 크래시 가능성: SDK optional 주입 유지

## Performance analysis
- 화면별 정적 콘텐츠를 immutable repository에서 재사용해 중복 문자열 조합 감소
- 부트스트랩 책임 분리로 startup path 추적 가능성 향상
- 추가 dependency injection은 lightweight object allocation 수준이며 병목 아님
- 잠재 병목은 여전히 광고 SDK/에뮬레이터 부팅이며 앱 구조 변경과는 무관

## Validation
- `flutter analyze` passed
- `flutter test` passed
- `flutter build apk --debug` passed
