# RP Mode - Report + PR Description 병렬 생성

`/report`와 `/pr-description`을 **병렬로 동시 실행**하여 한 번에 두 산출물을 생성한다.

- `.report/{YYYYMMDD}_{ISSUE#}_{설명}.md` — 구현 보고서
- `.pr/{YYYYMMDD}_{ISSUE#}_{설명}.md` — PR 본문

## 핵심 원칙

- **반드시 단일 메시지에서 두 Agent 호출을 동시에 디스패치** (병렬 tool use)
- Git 명령은 디스패치 전 1회만 실행 → 결과를 양쪽 Agent에 전달 (중복 호출 방지)
- ARGUMENTS로 들어온 이슈 본문/추가 컨텍스트가 있으면 양쪽 Agent 프롬프트에 그대로 포함
- 두 Agent는 서로의 결과를 기다리지 않고 독립 작성 (동일 git 컨텍스트 기반)
- 두 작업 완료 후 저장 경로만 짧게 요약하고 종료

## 실행 절차

### 1단계: 컨텍스트 수집 (디스패치 전 1회)

다음 명령을 병렬로 실행:

```bash
git status
git log main..HEAD --oneline
git diff main --name-only
```

브랜치명에서 `#숫자` 추출 → 이슈 번호 확정. 없으면 ARGUMENTS에서 추출.

### 2단계: 두 Agent 병렬 디스패치 (필수)

**한 메시지에 Agent 호출 2개**를 함께 보냄. 절대 순차 실행하지 않음.

#### Agent A — 보고서 생성

- `subagent_type`: `general-purpose`
- `description`: "Generate implementation report"
- `prompt`: 아래 템플릿
- 반드시 Skill 도구로 `report` 스킬 호출 또는 `.claude/commands/report.md`의 지침을 그대로 따라 `.report/`에 파일 생성

```
프로젝트: /Users/luca/workspace/greedy/quickness-game
브랜치: {브랜치명}
이슈 번호: #{N}

# Git 컨텍스트 (이미 수집됨 — 추가 git 명령 실행 금지)
## git status
{git status 결과}

## git log main..HEAD
{커밋 목록}

## 변경 파일 목록
{파일 목록}

# 이슈/추가 컨텍스트 (사용자 ARGUMENTS)
{ARGUMENTS}

# 작업
`.claude/commands/report.md`에 정의된 Report Mode 지침을 그대로 따라
`.report/{YYYYMMDD}_#{N}_{한글설명}.md` 파일을 생성하라.

- 위 git 컨텍스트만 사용. 추가 git 명령 실행 금지.
- 변경 파일을 직접 Read해서 분석.
- 작성자/작성일/AI 관련 표현 금지.
- 시크릿은 마스킹.
- 완료 시 저장된 파일 경로 한 줄로 보고.
```

#### Agent B — PR 본문 생성

- `subagent_type`: `general-purpose`
- `description`: "Generate PR description"
- `prompt`: 아래 템플릿

```
프로젝트: /Users/luca/workspace/greedy/quickness-game
브랜치: {브랜치명}
이슈 번호: #{N}

# Git 컨텍스트 (이미 수집됨 — 추가 git 명령 실행 금지)
## git status
{git status 결과}

## git log main..HEAD
{커밋 목록}

## 변경 파일 목록
{파일 목록}

# 이슈/추가 컨텍스트 (사용자 ARGUMENTS)
{ARGUMENTS}

# 기존 보고서 (있으면 우선 참조)
.report/ 디렉토리에 같은 이슈/날짜 매칭 보고서가 있으면 1차 소스로 활용.
없거나 본 세션에서 막 생성 중이라면 git 컨텍스트 + 변경 파일 직접 분석으로 작성.

# 작업
`.claude/commands/pr-description.md`에 정의된 PR Description Mode 지침을 따라
`.pr/{YYYYMMDD}_#{N}_{한글설명}.md` 파일을 생성하라.

- Summary / Changes / Behavior Change / Test Plan / Notes / Closes #N 구조.
- AI/작성자 메타 정보 금지. 시크릿 마스킹.
- 마지막 줄에 `Closes #{N}` 포함.
- 완료 시 저장된 파일 경로 + PR 제목 제안 한 줄로 보고.
```

### 3단계: 결과 요약

두 Agent 완료 후 다음 형식으로 한 번만 출력:

```
✅ 보고서: .report/{경로}.md
✅ PR 본문: .pr/{경로}.md

PR 생성:
gh pr create --title "{type} : {제목} #{N}" --body-file ".pr/{경로}.md"
```

## 절대 금지 사항

- 두 Agent를 순차 호출하지 말 것 (반드시 한 메시지에 병렬)
- 디스패치 전 git 명령 외에 본 커맨드가 추가 파일 분석을 하지 말 것 (Agent에게 위임)
- AI/작성자 메타 정보 삽입 금지
- 두 산출물 내용 차이를 임의로 줄이려고 하지 말 것 — 보고서는 "무엇을 했나", PR 본문은 "리뷰어용 요약"으로 역할이 다름

## 출력 후

저장 경로 2개 + `gh pr create` 안내 한 줄 출력 후 종료. 추가 질문 없음.
