# Review Flutter — 종합 리뷰 오케스트레이터

Flutter 프로젝트 종합 코드 리뷰. **4개 리뷰를 병렬 서브에이전트로 동시 실행**하고 결과를 통합합니다.

---

## 실행 절차

### 1단계: 리뷰 범위 파악

먼저 다음을 실행하여 변경 파일과 커밋 히스토리를 확인:

```bash
git diff --name-only main...HEAD -- '*.dart'
git log --oneline main...HEAD
```

변경 파일이 없으면 `lib/features/` 전체를 대상으로 합니다.

리뷰 범위를 사용자에게 출력:
```markdown
### 📋 리뷰 대상
**프로젝트**: Flutter (Clean Architecture + Riverpod)
**변경 파일**: N개
**커밋 수**: M개
**주요 변경 영역**: [변경된 feature/폴더 목록]

4개 리뷰를 병렬 실행합니다...
```

---

### 2단계: 4개 서브에이전트를 **한 번의 메시지에서 동시에** 발사

**반드시 Task 도구 4개를 한 메시지에서 병렬로 호출하세요. 순차 실행 금지.**

#### 서브에이전트 1: Review-Safety (Dead Code & Runtime Safety)
```
subagent_type: "superpowers:code-reviewer"
description: "Review-Safety dead code runtime"
prompt: |
  현재 작업 디렉토리의 Flutter 프로젝트를 리뷰합니다.

  `.claude/commands/review-safety.md` 파일을 Read 도구로 읽고, 해당 지침을 정확히 따라 리뷰를 수행하세요.
  CLAUDE.md도 반드시 읽고 프로젝트 컨벤션을 참조하세요.

  리뷰 대상 파일: [1단계에서 파악한 변경 파일 목록 삽입]

  review-safety.md에 정의된 최종 출력 형식 그대로 반환하세요.
```

#### 서브에이전트 2: Review-Design-System (Constants & Design System)
```
subagent_type: "superpowers:code-reviewer"
description: "Review-Design-System constants"
prompt: |
  현재 작업 디렉토리의 Flutter 프로젝트를 리뷰합니다.

  `.claude/commands/review-design-system.md` 파일을 Read 도구로 읽고, 해당 지침을 정확히 따라 리뷰를 수행하세요.
  CLAUDE.md도 반드시 읽고 디자인 시스템 규칙을 참조하세요.

  리뷰 대상 파일: [1단계에서 파악한 변경 파일 목록 삽입]

  review-design-system.md에 정의된 최종 출력 형식 그대로 반환하세요.
```

#### 서브에이전트 3: Review-Architecture (Architecture & Structure)
```
subagent_type: "superpowers:code-reviewer"
description: "Review-Architecture structure"
prompt: |
  현재 작업 디렉토리의 Flutter 프로젝트를 리뷰합니다.

  `.claude/commands/review-architecture.md` 파일을 Read 도구로 읽고, 해당 지침을 정확히 따라 리뷰를 수행하세요.
  CLAUDE.md도 반드시 읽고 아키텍처 규칙을 참조하세요.

  리뷰 대상 파일: [1단계에서 파악한 변경 파일 목록 삽입]

  review-architecture.md에 정의된 최종 출력 형식 그대로 반환하세요.
```

#### 서브에이전트 4: Review-General (보안 / 성능 / 버그)
```
subagent_type: "superpowers:code-reviewer"
description: "Review-General security perf bugs"
prompt: |
  현재 작업 디렉토리의 Flutter 프로젝트를 리뷰합니다.

  `.claude/commands/review.md` 파일을 Read 도구로 읽고, 해당 지침 중 Flutter 관련 항목을 중심으로 리뷰를 수행하세요.
  CLAUDE.md도 반드시 읽고 프로젝트 컨벤션을 참조하세요.

  리뷰 대상 파일: [1단계에서 파악한 변경 파일 목록 삽입]

  특히 다음에 집중:
  - 보안: 민감 정보 하드코딩, 인증/인가 우회, 안전하지 않은 데이터 처리
  - 성능: 메모리 누수, 비효율 알고리즘, 불필요한 async 대기
  - 버그: Null safety, 예외 처리 누락, 엣지 케이스, 비즈니스 로직 오류

  review.md에 정의된 출력 형식(Critical/Major/Minor/Positive)으로 반환하세요.
```

---

### 3단계: 결과 종합 (4개 서브에이전트 완료 후)

모든 서브에이전트가 완료되면 결과를 다음 형식으로 통합:

```markdown
# 📊 Flutter 종합 코드 리뷰 결과

**리뷰 대상**: [변경 파일 목록]
**검사 일시**: YYYY-MM-DD

---

## 🚨 Critical Issues (즉시 수정 필요)
[4개 리뷰에서 발견된 Critical 이슈 통합 — 중복 제거]

## ⚠️ Major Issues (배포 전 수정 권장)
[4개 리뷰에서 발견된 Major 이슈 통합 — 중복 제거]

## 💡 Minor Issues (개선 권장)
[4개 리뷰에서 발견된 Minor 이슈 통합 — 중복 제거]

## ✅ Positive Feedback (잘한 점)
[각 리뷰에서 발견된 좋은 점]

---

## 📈 리뷰별 상세

### Review-Safety: Dead Code & Runtime Safety
[서브에이전트 1 결과]

### Review-Design-System: Constants & Design System
[서브에이전트 2 결과]

### Review-Architecture: Architecture & Structure
[서브에이전트 3 결과]

### Review-General: Security / Performance / Bugs
[서브에이전트 4 결과]

---

## 📊 통계
| 리뷰 | Critical | Major | Minor | 합계 |
|------|----------|-------|-------|------|
| Review-Safety | - | - | - | - |
| Review-Design-System | - | - | - | - |
| Review-Architecture | - | - | - | - |
| General  | - | - | - | - |
| **합계** | **-** | **-** | **-** | **-** |

## 🎯 핵심 개선 사항 (Top 5)
1. ...
2. ...
3. ...
4. ...
5. ...

## 전체 평가: [Approve / Request Changes / Comment]
```

---

## 실행 지시자

> **이 커맨드가 실행되면 아래 규칙을 반드시 준수하세요.**

1. **Thinking 비활성화** — 이 커맨드 실행 시 extended thinking을 사용하지 않는다. `thinking: disabled` 모드로 동작한다.
2. **확인 없이 즉시 실행** — "Do you want to proceed?", "리뷰를 시작할까요?" 등 사용자 확인을 묻지 않고 바로 실행한다.
3. **병렬 실행** — 독립적인 명령(git diff, git log 등)과 4개 서브에이전트는 반드시 한 번의 메시지에서 병렬로 실행한다.
4. **완료 후 복원 안내** — 리뷰 결과 출력 완료 후 마지막에 다음 안내를 출력한다:
   ```
   💡 thinking을 다시 활성화하세요: /config set --thinking true
   ```

---

## 규칙

1. **4개 서브에이전트는 반드시 한 메시지에서 동시 발사** — 순차 실행 금지 (실행 지시자 3번 참조)
2. **중복 제거** — 여러 리뷰에서 같은 이슈 발견 시 하나로 합침
3. **심각도 우선** — Critical → Major → Minor 순서
4. **실행 가능한 제안** — 각 이슈에 구체적 해결 방법 포함
5. **변경 파일 목록을 서브에이전트 prompt에 반드시 포함** — 서브에이전트가 범위를 알아야 함
