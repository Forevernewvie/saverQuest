# SaverQuest Autonomous Improvement Execution

## Executed prompts
- Prompt 1: 공통 `ScreenShell`과 `ThemeData`를 정리해 전체 화면의 배경 깊이, 여백, 앱바 톤을 통일했다.
- Prompt 2: 배너 슬롯의 공격적인 placeholder 문구를 제거하고 로딩 스켈레톤/비노출 정책으로 바꿨다.
- Prompt 3: 리워드 광고 미설정 상태에서 리포트 화면이 가짜 CTA를 노출하지 않도록 fallback 흐름으로 수정했다.
- Prompt 4: 본 문서와 프롬프트 문서를 생성했다.

## Changed files
- lib/core/design/app_colors.dart
- lib/core/design/app_theme.dart
- lib/widgets/screen_shell.dart
- lib/widgets/ad_banner_slot.dart
- lib/features/report/report_page.dart
- lib/core/localization/app_localizations.dart
- test/features/report/report_page_test.dart

## Verification
- `flutter analyze`
- `flutter test`
- `flutter build apk --debug`

## Result
- 전체 화면이 같은 서비스형 레이아웃 톤으로 통일됨
- 광고 미설정 상태를 사용자가 불필요하게 인식하지 않도록 정리됨
- 리포트 화면이 현재 수익화 단계와 일치하도록 수정됨

## Follow-up
- 실제 Android 실기기에서 광고 로드 시 카드 높이 점프가 과하지 않은지 확인
- 리워드 광고 단위 ID를 받을 때만 상세 리포트 잠금 해제 흐름 재활성화
