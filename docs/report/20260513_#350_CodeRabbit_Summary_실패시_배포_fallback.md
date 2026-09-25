### 📌 작업 개요

deploy 브랜치 자동 CHANGELOG 워크플로우(`AUTO UPDATE PROJECT CHANGELOG`)가 CodeRabbit Summary 응답에 강하게 의존하던 구조를 개선. CodeRabbit이 rate limit·서비스 장애·응답 지연 등으로 Summary를 못 만들면 CHANGELOG 갱신뿐 아니라 deploy 머지·푸시 Job까지 모두 스킵되어, deploy 브랜치 push에 의존하는 Android/iOS 배포 워크플로우 전체가 발화되지 않던 문제를 우선순위 기반 fallback과 배포 게이트 분리로 해결.

### 🎯 구현 목표

- CodeRabbit Summary 외에도 CHANGELOG 입력 텍스트를 확보할 수 있는 fallback 경로 마련
- CHANGELOG 갱신 결과와 무관하게 deploy 머지·푸시는 항상 진행되도록 게이트 분리
- CodeRabbit이 명시적 에러 댓글을 남기는 경우 10분 폴링을 끝까지 기다리지 않고 즉시 fallback으로 전환
- fallback이 사용된 경우 PR 댓글로 운영자에게 알림
- 일반 feature PR과 릴리즈 PR 작성 흐름을 분리

### ✅ 구현 내용

#### 릴리즈 PR 전용 본문 템플릿 신규 생성

- 파일: `.github/PULL_REQUEST_TEMPLATE/release.md`
- 변경 내용: `<!-- changelog:start -->` / `<!-- changelog:end -->` 마커가 포함된 릴리즈 PR 전용 템플릿 추가
- 이유: deploy로 PR 생성 시 URL 파라미터 `?template=release.md`로 선택할 수 있어, 일반 feature PR 템플릿(`PULL_REQUEST_TEMPLATE.md`)은 손대지 않고 릴리즈 PR만 별도 양식 적용 가능

#### PR 본문 백업 Step 추가

- 파일: `.github/workflows/PROJECT-COMMON-AUTO-CHANGELOG-CONTROL.yaml`
- 변경 내용: `PR 본문 초기화` Step 직전에 `PR 본문 백업` Step 신규 추가. PR 본문을 `/tmp/original_pr_body.md`로 저장
- 이유: 기존 워크플로우는 시작 즉시 PR 본문을 빈 문자열로 PATCH해서 작성자가 적어둔 내용이 통째로 사라졌음. `/tmp`에 저장하면 이후 `actions/checkout`이 working directory를 reset해도 백업 파일이 살아남음

#### CodeRabbit 폴링 루프에 에러 댓글 조기 감지 추가

- 파일: `.github/workflows/PROJECT-COMMON-AUTO-CHANGELOG-CONTROL.yaml`
- 변경 내용: 폴링 매 회차마다 `coderabbitai[bot]` 또는 `coderabbitai` 사용자의 최신 댓글을 조회하여 다음 키워드가 보이면 즉시 break: `rate limit`, `quota`, `too many requests`, `couldn't process`, `unable to process`, `service unavailable`, `limit reached`, `exceeded`
- 이유: CodeRabbit이 명시적으로 응답 불가 댓글을 남기는 경우 10분 폴링을 끝까지 기다릴 필요 없이 즉시 fallback 경로로 전환. 다만 키워드 휴리스틱이라 모든 케이스를 잡지는 못함

#### 콘텐츠 소스 결정 Step 신규 추가

- 파일: `.github/workflows/PROJECT-COMMON-AUTO-CHANGELOG-CONTROL.yaml`
- 변경 내용: 폴링 직후, Summary 파일 업로드 직전에 `콘텐츠 소스 결정` Step 추가. 우선순위 로직으로 `pr_body.md` 최종 생성 + `content_source` 출력값 결정
  - 1순위: CodeRabbit Summary (기존 동작 유지) → `content_source=coderabbit`
  - 2순위: PR 작성자가 `<!-- changelog:start -->` 마커 안에 적은 텍스트 (20자 이상일 때만 인정) → `content_source=manual`
  - 3순위: PR 제목 + feat/fix 커밋 메시지 자동 조합 → `content_source=auto`
- 이유: CodeRabbit Summary 단일 의존성을 끊고, 어떤 경우에도 CHANGELOG 입력 텍스트가 확보되도록 함

#### Job 의존성 및 실행 조건 재조정

- 파일: `.github/workflows/PROJECT-COMMON-AUTO-CHANGELOG-CONTROL.yaml`
- 변경 내용:
  - Job 1 출력값을 `summary_found`(true/false)에서 `content_source`(coderabbit/manual/auto/none)로 변경
  - Job 2(`update-changelog`) 조건: `content_source != 'none'`
  - Job 3(`merge-and-deploy`) 조건: `always() && needs.detect-and-parse.result == 'success'`
- 이유: 배포 게이트를 CHANGELOG 갱신에서 분리. CHANGELOG 갱신이 실패하거나 스킵되더라도 deploy 머지·푸시는 항상 진행되도록 보장. Job 1 자체가 실패한 경우에만 배포가 중단됨

#### 콘텐츠 소스 알림 댓글 Step 추가

- 파일: `.github/workflows/PROJECT-COMMON-AUTO-CHANGELOG-CONTROL.yaml`
- 변경 내용: Job 3 최상단에 `콘텐츠 소스 알림 댓글` Step 신규 추가. `content_source` 값에 따라 분기:
  - coderabbit: 댓글 생략 (정상 동작)
  - manual: 작성자 본문 fallback 사용 안내 댓글
  - auto: 자동 생성 fallback 사용 안내 + 수동 보완 요청 댓글
  - none: CHANGELOG 갱신 실패 + 수동 작성 요청 댓글
  - Job 2 자체가 failure인 경우 별도 경고 댓글 추가
- 이유: fallback이 사용되었을 때 운영자가 즉시 인지하고 사후 보완할 수 있도록 가시성 확보

### 🔧 주요 변경사항 상세

#### 우선순위 기반 콘텐츠 소스 결정 로직

PR 본문 백업본(`/tmp/original_pr_body.md`)에서 `awk`로 `<!-- changelog:start -->` ~ `<!-- changelog:end -->` 사이 텍스트를 추출. 앞뒤 공백 제거 및 빈 줄 제거 후 길이가 20자 이상이면 "의미 있는 본문"으로 판정하여 `manual` 경로 채택. 그렇지 않으면 PR 제목과 feat/fix prefix를 가진 커밋 메시지를 GitHub API로 조회하여 `auto` 경로 fallback 생성. 어느 경로든 최종 결과물은 동일하게 `pr_body.md`로 통일되며, 기존 `changelog_manager.py`의 `markdown_failed` 경로(raw_summary만 저장)가 이미 임의 텍스트를 받아낼 수 있어 Python 스크립트는 수정 불필요.

특이사항:
- 20자 미만 본문은 자동 fallback으로 떨어짐. 한 줄짜리 메모는 인식 안 됨
- CodeRabbit 정상 동작 시에는 `<!-- changelog:start -->` 마커 안 내용이 어차피 CodeRabbit Summary로 덮어써지므로 무시됨

#### 배포 게이트 분리 (always 패턴)

Job 3의 `if` 조건을 `always() && needs.detect-and-parse.result == 'success'`로 변경. `always()`는 이전 Job이 실패해도 진행한다는 의미. Job 2(`update-changelog`)가 실패하거나 스킵되어도 Job 3은 실행되므로 deploy 브랜치 push가 발생하여 후속 Android/iOS 배포 워크플로우들이 정상 트리거됨. 단 Job 1 자체가 실패하면 콘텐츠 소스 자체가 결정되지 않으므로 의미가 없어 배포 중단.

특이사항:
- `always()`를 쓰면 Job 1이 cancelled 상태일 때도 진행할 수 있어 `needs.detect-and-parse.result == 'success'` 명시적 체크 필수
- Job 2 결과는 `needs.update-changelog.result`로 알림 댓글 Step에서 참조하여 별도 경고 댓글 작성

#### PR 본문 백업 위치 (`/tmp` 사용)

`/tmp/original_pr_body.md`는 GitHub Actions 러너의 임시 디렉토리. `actions/checkout`은 기본적으로 `$GITHUB_WORKSPACE`(레포 체크아웃 경로)에서 동작하므로 `/tmp` 영역은 영향받지 않음. 같은 Job 내 후속 Step에서 그대로 읽을 수 있음.

특이사항:
- Job 간(예: Job 2에서 사용)에 공유하려면 artifact 업로드가 필요하지만 현재는 Job 1 내부에서만 사용하므로 `/tmp`로 충분

#### CodeRabbit 봇 사용자 매칭

GitHub API에서 봇 사용자명은 `coderabbitai[bot]` 또는 `coderabbitai` 두 가지가 보고됨. `jq -r '[.[] | select(.user.login | test("coderabbitai"; "i"))] | last | .body'`로 대소문자 무시 부분 매칭하여 두 케이스 모두 잡음.

특이사항:
- 만약 다른 봇 사용자가 댓글에 "rate limit" 같은 단어를 포함하면 false positive 가능. 운영 중 문제되면 사용자명 매칭을 정확 일치로 강화 필요

### 📦 의존성 변경

- 없음 (기존 도구만 사용: `curl`, `jq`, `awk`, `sed`, `gh` CLI)

### 🧪 테스트 및 검증

- YAML 구조 검증: 22개 step 모두 정상 인식, tab 문자 없음
- 식별자 일관성 검증: `content_source`, `determine_source`, `/tmp/original_pr_body.md` 모두 step 간/job 간 정상 연결 확인
- 실제 동작 검증은 다음 시나리오로 deploy PR을 만들어 확인 필요:
  - 정상 케이스: CodeRabbit이 정상 응답 → `content_source=coderabbit`, 알림 댓글 없음
  - manual fallback: 본문 마커 안에 텍스트 입력 + CodeRabbit 차단/실패 상태 → 마커 안 본문이 CHANGELOG에 들어가고 ⚠️ 알림 댓글 표시
  - auto fallback: 본문 비움 + CodeRabbit 실패 → PR 제목 + 커밋 메시지로 자동 생성, ⚠️ 알림 댓글 표시
  - 조기 종료: CodeRabbit이 "rate limit reached" 류 댓글 작성 → 10분 안 기다리고 즉시 fallback 진입 (Action 로그에서 "CodeRabbit 에러 댓글 감지" 메시지 확인)
  - 어느 시나리오든 deploy 브랜치 push가 발생하여 Android/iOS 배포 워크플로우 트리거되는지 확인

### 📌 참고사항

- 릴리즈 PR 생성 시 URL에 `?template=release.md` 파라미터를 붙여야 신규 템플릿이 적용됨. 안 붙이면 기존 일반 PR 템플릿이 적용되어 자동 fallback(PR 제목 + 커밋) 경로로 동작
- 작성자 본문 판정 기준은 마커 안 텍스트 20자 이상. 너무 짧으면 자동 fallback으로 떨어짐
- 폴링 step에서 사용하는 에러 키워드 목록은 운영 중 새로운 케이스 발견 시 추가 가능. 현재 키워드는 일반적인 CodeRabbit/GitHub API 에러 메시지 기준
- `changelog_manager.py`는 수정하지 않음. 기존 `markdown_failed` 경로가 임의 텍스트도 `raw_summary`로 저장하도록 이미 구현되어 있어 fallback 텍스트도 그대로 처리 가능
- `gh pr comment`는 `pull-requests: write` 권한으로 동작 (워크플로우에 이미 설정됨, 추가 권한 불필요)
