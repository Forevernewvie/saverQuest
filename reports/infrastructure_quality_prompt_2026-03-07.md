# SaverQuest Infrastructure Quality Prompt

## Target
남아 있는 consent, ad service, widget 인프라 계층을 아래 기준으로 리팩터링해줘.

### 기준
- 콜백/비동기 중복 제거
- 예외 발생 지점 로깅 추가
- 매직넘버 상수화
- 함수 목적 주석 추가
- 서비스 초기화 실패 시 graceful fallback 유지
- 테스트가 깨지지 않도록 DI 구조 유지

### 실행 순서
1. consent controller의 callback-Completer 중복 제거
2. ad service의 초기화/blocked flow 로깅 통일
3. widget 레벨 재시도 정책/치수 상수화
4. `flutter analyze`, `flutter test`, `flutter build apk --debug`로 검증
