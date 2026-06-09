# Pre-Deploy Review — 배포 전 종합 점검 (12차원 + 적대적 검증)

현재 구현된 앱을 **최종 배포 전 관점**에서 전문가 수준으로 점검한다. "코드가 동작하는가"를 넘어 유지보수성·중복·병목·UX·예외처리·보안·반응형·확장성·치명적 결함·기술부채 10개 기준을 12개 리뷰 레인으로 펼쳐 검사하고, **모든 발견을 코드 재확인으로 적대적 검증**한 뒤 정해진 형식으로 종합한다.

> **이 커맨드의 핵심 가치 = 적대적 검증.** 리뷰어는 위험을 과장하는 경향이 있다(가드/게이팅된 코드를 CRITICAL로 보고). 검증 단계가 이를 걸러내지 않으면 신뢰할 수 없는 공포 리스트가 된다. 검증을 절대 생략하지 말 것.

`$ARGUMENTS` — 선택 인자:
- `ko` (기본): 국내 우선 출시 관점 / `global`: en·ja 동시 출시 관점(i18n 결함을 must_fix로 승격)
- 경로(예: `lib/features/game`): 해당 영역만 집중 점검

---

## 실행 지시자 (먼저 읽을 것)

1. **확인 없이 즉시 실행** — "진행할까요?" 묻지 않고 바로 스카우팅부터 시작한다.
2. **근거 없는 발견 금지** — 모든 발견은 실제로 Read/Grep으로 읽은 코드에 근거하고 `파일:줄번호`를 명시한다. 일반론·추측 금지.
3. **검증 필수** — 리뷰어가 CRITICAL/HIGH로 보고한 항목은 100% 코드를 다시 열어 검증한다. 이미 `kDebugMode`/`mounted`/`_isDisposed`/가드/트리셰이킹으로 방어된 것은 강등하거나 기각한다.
4. **정직 우선** — 블로커가 없으면 "없다"고 분명히 말한다. 형식을 채우려고 MEDIUM을 must_fix로 부풀리지 않는다.
5. **프로젝트 컨벤션 기준** — `CLAUDE.md`와 `.claude/rules/`를 판단 기준으로 삼는다(try-catch+Custom Exception, AppColors/AppTextStyles 상수, ARB i18n, isDarkMode prop, ScreenUtil 등). 일반 베스트프랙티스가 아니라 이 프로젝트 규칙으로 본다.

---

## 1단계: 스카우팅 (코드베이스 구조·규모 파악)

다음을 한 번에 실행해 리뷰 입력을 만든다. 결과(거대 파일 top, feature 목록, 테스트 수, 디버그 스캐폴딩, 시크릿 처리, debugPrint 수)를 워크플로우 레인에 주입한다.

```bash
# 손코딩 규모(생성/l10n 제외) + 거대 파일 top
find lib -name "*.dart" ! -name "*.g.dart" ! -name "*.freezed.dart" ! -path "lib/l10n/*" -exec wc -l {} + | sort -rn | head -26
# feature 목록
ls -1 lib/features/
# 테스트 수
find test -name "*_test.dart" | wc -l
# 디버그 스캐폴딩 / 디버그 라우트
grep -rn "kDebugMode" lib/router/ ; ls lib/test_widget_page.dart lib/features/*test* 2>/dev/null
# 민감정보 로깅 표본 (token/secret/위치)
grep -rniE "(api[_-]?key|secret|password|token)\s*=\s*['\"]" lib --include="*.dart" | grep -v ".g.dart" | head
grep -rn "debugPrint" lib --include="*.dart" | wc -l
# 시크릿 격리
grep -iE "\.env|secret|keystore|\.p8|\.p12|google-service" .gitignore
```

스카우팅 요약을 사용자에게 한 블록으로 출력한 뒤 2단계로 넘어간다.

---

## 2단계: 12차원 리뷰 + 적대적 검증 (Workflow 우선)

**Workflow 도구를 사용할 수 있으면(이 슬래시 커맨드 실행 자체가 opt-in) Workflow로 실행한다.** 불가하면 3단계의 Task 폴백을 사용한다.

워크플로우는 `pipeline(DIMENSIONS, 리뷰단계, 검증단계)` 구조로:
- **리뷰 단계**: 12개 레인을 `Explore` 에이전트로 병렬 실행. 각 레인은 담당 코드를 직접 읽고 발견 수집.
- **검증 단계**: 각 발견(LOW 제외)을 회의적 검증자에게 보내 코드를 재확인 → `isReal`/`confirmedSeverity`/`note` 판정. 오탐·과장 강등.

### 10개 기준 → 12개 레인 매핑

| # | 레인 | 담당 기준 | 주 점검 대상 |
|---|------|-----------|-------------|
| 1 | `pre-deploy-blockers` | 9 | 디버그 스캐폴딩/라우트, main 초기화, .env 폴백, 민감정보 로깅 |
| 2 | `security` | 6 | 토큰 저장(secure_storage 옵션), 401 재발급 Lock, 딥링크 검증, WebSocket 인증, PII 로깅, LogInterceptor 게이팅 |
| 3 | `perf-game` | 3 | 위치 스트림/주기, 지도 마커 재생성·diff, 거대 위젯 리빌드, 스트림/타이머 dispose |
| 4 | `perf-chat-net` | 3 | 채팅 리스트 누적·복제, 재연결 백오프, broadcast 누수, Dio 타임아웃/재시도 |
| 5 | `arch-god-files` | 1,8 | 800줄 초과 파일, God State 클래스, 계층 위반, 책임 혼합 |
| 6 | `duplication` | 2,10 | 다이얼로그/스낵바/버튼 복붙, isDarkMode 분기 중복, 과도한 추상화 |
| 7 | `error-loading` | 5 | DioExceptionHandler 일관성, AsyncValue.error UI 처리, 친화적 오류 메시지, 로딩/빈 상태, 더블탭 방지 |
| 8 | `ux-ui` | 4 | 네비게이션/뒤로가기, 비가역 액션 확인, 권한 거부 안내, 상태 전이 피드백 |
| 9 | `responsive` | 7 | ScreenUtil 누락 고정 픽셀, 작은/큰 화면 overflow, SafeArea, 텍스트 스케일 |
| 10 | `i18n` | 4,9 | 한국어 하드코딩(주석/debugPrint 제외), ko/en/ja 키 완결성, error_message_mapper 누락 |
| 11 | `state-realtime-lifecycle` | 1,3,10 | autoDispose 경합, 백/포그라운드 재연결, 구독/타이머 dispose, GAME_OVER 정리 |
| 12 | `testing` | 1,10 | 핵심 로직(체포/탈옥/승패/재연결/토큰재발급) 커버리지, Agents.md Classist 위반 |

### 각 레인 에이전트 프롬프트에 반드시 포함할 공통 전제(PREAMBLE)

- 프로젝트: 위치 기반 실시간 멀티플레이어 게임(Flutter). Feature-First + Clean Architecture, Riverpod/Freezed/Retrofit, STOMP WebSocket, go_router, Firebase, Google Maps, geolocator, QR 체포.
- 컨벤션(판단 기준): try-catch+Custom Exception(Either 금지), AppColors/AppTextStyles 상수만(Theme.of/Color(0xFF)/withOpacity 금지), ARB i18n(한국어 하드코딩 금지·debugPrint/주석/assert는 허용, ko/en/ja), roleThemeProvider+isDarkMode prop, ScreenUtil(.w/.h/.r/.sp)+AppSpacing/AppPadding/AppRadius, @riverpod 기본 autoDispose.
- 규칙: 실제 파일을 읽고 근거 있는 발견만; `파일:줄번호` 명시; severity(CRITICAL/HIGH/MEDIUM/LOW), category(must_fix/should_fix/keep_as_is/refactor); 같은 위반 N곳은 대표 1~2곳+"총 N곳"으로 묶기; 한국어로 작성.

### 발견 스키마 (FINDINGS_SCHEMA)

```
findings[]: { title, severity, category, location("파일:줄번호"), evidence(본 코드/사실), impact, recommendation }
summary: 차원 총평 1~2문장
```

### 검증 스키마 (VERDICT_SCHEMA) — LOW 제외 전 발견에 적용

```
{ isReal: bool(불확실하면 false로 기울임), confirmedSeverity: CRITICAL|HIGH|MEDIUM|LOW|FALSE_POSITIVE, note: 한 줄 한국어 }
```

검증자 프롬프트 핵심: "이 발견이 실재하는지 location을 Read로 직접 확인하라. 이미 가드/게이팅(kDebugMode·mounted·_isDisposed·트리셰이킹·diff 등)으로 방어된 거짓양성이면 FALSE_POSITIVE. 심각도 과장/축소도 교정하라. 불확실하면 isReal=false."

### 워크플로우 스크립트 골격 (참고 — 스카우팅 결과로 거대 파일 경로 등을 채워 사용)

```javascript
export const meta = {
  name: 'predeploy-review',
  description: '배포 전 12차원 리뷰 + 적대적 검증',
  phases: [{ title: 'Review' }, { title: 'Verify' }],
}
// DIMENSIONS = 위 12개 레인 {key, prompt}. prompt = PREAMBLE + 레인별 점검 지시 + 스카우팅으로 찾은 대상 파일.
const results = await pipeline(
  DIMENSIONS,
  (d) => agent(PREAMBLE + d.prompt, { label: `review:${d.key}`, phase: 'Review', schema: FINDINGS_SCHEMA, agentType: 'Explore' }),
  (review, d) => {
    if (!review?.findings) return { dimension: d.key, findings: [], summary: review?.summary ?? '실패' }
    const toVerify = review.findings.filter((f) => f.severity !== 'LOW')
    const lows = review.findings.filter((f) => f.severity === 'LOW').map((f) => ({ ...f, verdict: { isReal: true, confirmedSeverity: 'LOW', note: 'LOW: 검증 생략' } }))
    return parallel(toVerify.map((f) => () =>
      agent(PREAMBLE + `회의적 검증자. 다음 발견을 코드로 검증하라.\n제목:${f.title}\n위치:${f.location}\n근거:${f.evidence}\n영향:${f.impact}\nlocation을 Read로 직접 확인. 이미 가드된 거짓양성이면 FALSE_POSITIVE. 불확실하면 isReal=false.`,
        { label: `verify:${d.key}`, phase: 'Verify', schema: VERDICT_SCHEMA })
        .then((v) => ({ ...f, verdict: v ?? { isReal: false, confirmedSeverity: 'FALSE_POSITIVE', note: '검증 실패' } }))
    )).then((verified) => ({ dimension: d.key, findings: [...verified.filter(Boolean), ...lows], summary: review.summary }))
  },
)
// confirmed = verdict.isReal && confirmedSeverity !== 'FALSE_POSITIVE'. 심각도순 정렬 후 반환.
```

워크플로우 결과(확정/기각/통계)를 받아 3단계 형식으로 합성한다. **반드시 검증을 통과한 `confirmedSeverity` 기준으로 분류한다(리뷰어 원본 severity 아님).**

---

## 3단계: Task 폴백 (Workflow 불가 시)

12개 레인을 **한 메시지에서 Task 서브에이전트로 병렬 발사**(`subagent_type: "Explore"` 또는 `general-purpose`). 각 프롬프트에 위 PREAMBLE + 레인 지시 + 스카우팅 결과 포함, FINDINGS_SCHEMA 형식 JSON 반환 요청.
완료 후 **CRITICAL/HIGH 발견만 모아 두 번째 검증 라운드**를 병렬 발사(각 발견의 location을 Read로 확인, VERDICT 반환). 검증 결과로 강등·기각한 뒤 합성한다. (검증 라운드는 생략 불가)

---

## 4단계: 최종 종합 (출력 형식 — 정확히 이 6개 섹션)

먼저 **검증 요약 표**를 제시한다(신뢰도의 근거):

```markdown
## 검증 요약
| 구분 | 결과 |
|---|---|
| 확정 결함 | N건 (CRITICAL a · HIGH b · MEDIUM c · LOW d) |
| 오탐 기각 | M건 (이미 가드/게이팅 존재) |
| 결론 | (배포 가능 여부 한 줄) |

검증에서 "이미 안전함"으로 확인된 대표 사례: [기각된 주요 항목 3~5개 — 무엇이 이미 방어돼 있었는지]
```

이어서 6개 섹션:

```markdown
## 1. 반드시 수정해야 할 항목
검증 통과한 CRITICAL/HIGH(must_fix)만. 없으면 "배포를 막는 결함 없음"을 분명히 명시하고, 출시 범위(ko/global)에 따라 조건부 필수가 되는 항목을 별도 표기.

## 2. 수정하면 좋은 항목
검증 통과 MEDIUM + 의미 있는 LOW(should_fix). `파일:줄번호` + 권장 조치.

## 3. 현재 상태로 유지해도 되는 항목
keep_as_is + **검증에서 오탐으로 밝혀진 "이미 잘 된" 항목**(엔지니어링 품질 증거).

## 4. 리팩토링 추천 항목
refactor 카테고리. God 파일 분해, 콜백 분리, 공통화 등.

## 5. 최종 배포 가능 여부
✅/⚠️/❌ + 근거(검증된 블로커 수) + 출시 직전 권장 게이트(있다면).

## 6. 최종적으로 제안하는 개선 우선순위
P0(출시 전)/P1(직후)/P2~P3 표. 컬럼: 순위 | 작업 | 근거 | 노력(S/M/L). 한 줄 결론으로 마무리.
```

---

## 규칙 요약

1. 스카우팅 → 12레인 병렬 리뷰 → **적대적 검증(필수)** → 6섹션 합성. 검증 생략 절대 금지.
2. 분류는 검증된 `confirmedSeverity` 기준. 리뷰어 원본 severity로 분류하지 않는다.
3. 모든 발견에 `파일:줄번호`. 근거 없는 일반론 금지.
4. 블로커 없으면 정직하게 "없음" 선언. 형식 채우기용 과장 금지.
5. `$ARGUMENTS`가 `global`이면 i18n(en/ja) 결함을 must_fix로 승격, 경로 인자면 해당 영역 집중.
