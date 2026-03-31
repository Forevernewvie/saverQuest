# GitHub Actions 점검 체크리스트

PR에 체크가 붙지 않거나 `pending`만 보이고 아무 run도 생기지 않을 때 확인할 항목입니다.

## 1. 저장소에서 Actions가 켜져 있는지
- GitHub 저장소 → **Settings** → **Actions** → **General**
- Actions permissions가 꺼져 있지 않은지 확인
- 최소한 **Allow all actions and reusable workflows** 또는 현재 workflow를 허용하는 설정이어야 함

## 2. Workflow permissions
- Settings → Actions → General → **Workflow permissions**
- 기본은 `Read repository contents permission`이면 충분하지만,
  조직 정책 때문에 제한되어 있지 않은지 확인

## 3. Fork / branch 정책 확인
- 현재 PR 브랜치가 `codex/feature/*` 형태로 push 되었을 때
  workflow 실행이 차단되지 않는지 확인
- 조직/저장소 정책상 특정 브랜치 패턴이 차단되어 있지 않은지 확인

## 4. Actions 탭에서 실제 run 존재 여부 확인
- 저장소의 **Actions** 탭으로 이동
- `Flutter CI` workflow가 보이는지 확인
- workflow는 보이는데 run이 없다면 트리거/권한 문제 가능성이 큼
- workflow 자체가 안 보이면 YAML 인식 또는 Actions 설정 문제 가능성이 큼

## 5. PR required checks 설정 확인
- Settings → Branches → branch protection rules
- `main` 보호 규칙에서 존재하지 않는 check name을 required로 걸어둔 경우 없는지 확인
- 예: 예전 workflow 이름/잡 이름을 required check로 유지한 경우

## 6. 수동 실행 테스트
- 현재 workflow에는 `workflow_dispatch`가 추가되어 있음
- Actions 탭에서 `Flutter CI`를 직접 선택해 **Run workflow**가 보이는지 확인
- 수동 실행도 안 보이면 권한/설정 문제 가능성이 높음

## 7. 가장 최근 로컬 확인 결과
현재 로컬에서는 아래가 모두 통과한 상태여야 함:

```bash
flutter analyze
flutter test
flutter build apk --debug
```

즉, Actions가 안 붙는 경우 코드보다 저장소 설정 문제일 확률이 높습니다.

## 8. 이 저장소에서 바로 확인할 workflow 파일
- `.github/workflows/flutter_ci.yml`

현재 workflow는 다음을 지원합니다:
- `push` on `main`, `codex/**`
- `pull_request` on `main`, `codex/develop`
- `workflow_dispatch`
- concurrency 설정 포함

## 9. 권장 조치 순서
1. Actions가 켜져 있는지 확인
2. Actions 탭에서 `Flutter CI` workflow가 보이는지 확인
3. `Run workflow` 수동 실행 가능 여부 확인
4. branch protection required checks가 옛 이름을 요구하는지 확인
5. 그래도 안 되면 저장소/조직 정책에서 Actions 차단 여부 확인
