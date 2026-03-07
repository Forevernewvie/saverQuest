# SaverQuest UI Tokens Quality Prompt

## Target
공통 UI shell과 reusable widget 계층을 아래 기준으로 정리해줘.

### 기준
- 공통 디자인 토큰 도입
- 위젯 계층의 매직넘버 제거
- reusable decoration/helper로 중복 제거
- 위젯 생명주기 함수 목적 주석 추가
- 재사용 위젯 입력 변경 시 필요한 reload 조건만 수행

### 실행 순서
1. screen shell/common widgets/theme의 크기, radius, constraint 숫자 수집
2. 공통 UI 토큰 파일 생성
3. 공통 위젯이 토큰과 helper를 사용하도록 리팩터링
4. `flutter analyze`, `flutter test`, `flutter build apk --debug` 검증
