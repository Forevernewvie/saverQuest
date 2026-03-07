# SaverQuest UI Tokens Quality Execution

## Applied changes
- `AppUiTokens`를 추가해 공통 반경, 크기, 제약값을 중앙화했다.
- `AppTheme`, `ScreenShell`, `AppBlocks`, `AppPanel`, `AsyncFeedback`가 토큰을 사용하도록 정리했다.
- `AppBlocks`에 공통 surface decoration helper를 추가해 중복 BoxDecoration 구성을 제거했다.
- `AdBannerSlot`은 입력 값이 바뀌는 경우에만 reload하도록 조건을 확장했다.

## Files changed
- lib/core/design/app_ui_tokens.dart
- lib/core/design/app_theme.dart
- lib/widgets/screen_shell.dart
- lib/widgets/common/app_blocks.dart
- lib/widgets/common/app_panel.dart
- lib/widgets/common/async_feedback.dart
- lib/widgets/ad_banner_slot.dart

## Quality impact
- UI 크기와 반경 변경이 한 파일에서 관리됨
- 공통 위젯의 시각 규칙이 일관됨
- widget lifecycle reload 조건이 명확해져 불필요한 banner reload 위험 감소

## Validation
- `flutter analyze` passed
- `flutter test` passed
- `flutter build apk --debug` passed
