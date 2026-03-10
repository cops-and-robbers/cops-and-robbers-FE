# 카운트업 타이머 — 로직 & 알고리즘 레퍼런스

> 프레임워크/라이브러리에 독립적인 로직 설명. 다른 프로젝트에서 동일 패턴 적용 시 참고용.

---

## 1. 핵심 알고리즘: DateTime 기반 경과 시간 계산

### 문제

틱 카운팅(`_seconds++`)은 타이머 콜백 지연, 앱 백그라운드 전환, UI 스레드 블로킹 등으로 누적 오차가 발생한다.

### 해결: 시작 시각 저장 + 현재 시각 차이 계산

```
elapsed = accumulatedBeforePause + (now - startTime)
```

- `startTime`: 타이머가 시작(또는 재개)된 시점의 시스템 시각
- `accumulatedBeforePause`: 이전 일시정지까지 누적된 경과 시간
- `now`: 현재 시스템 시각

이 방식은 **읽는 시점에 매번 재계산**하므로, UI 갱신 주기와 무관하게 항상 정확하다.

### 의사코드

```
class TimerState:
    status: idle | running | paused
    startTime: DateTime?            // running일 때만 non-null
    accumulatedBeforePause: Duration // 이전 pause까지 누적된 시간

    get elapsed():
        if status == running AND startTime != null:
            return accumulatedBeforePause + (DateTime.now() - startTime)
        return accumulatedBeforePause
```

### 상태별 값 변화표

| 상태    | startTime      | accumulatedBeforePause | elapsed 반환값           |
| ------- | -------------- | ---------------------- | ------------------------ |
| idle    | null           | 0                      | 0                        |
| running | 시작/재개 시각 | 이전 누적              | 누적 + (now - startTime) |
| paused  | null           | 일시정지 시점까지 누적 | 누적값 그대로            |

---

## 2. 상태 전이 (FSM)

```
          start()         pause()
  idle ──────────→ running ──────────→ paused
                    ↑                     │
                    └─────────────────────┘
                         resume()

  running ──→ stop() ──→ idle
  paused  ──→ stop() ──→ idle
```

### 각 전이에서 일어나는 연산

| 액션       | startTime | accumulatedBeforePause     | 부수 효과               |
| ---------- | --------- | -------------------------- | ----------------------- |
| `start()`  | `now`     | `0`                        | UI 갱신 시작            |
| `pause()`  | `null`    | `elapsed` (현재값 스냅샷)  | UI 갱신 중지            |
| `resume()` | `now`     | 변경 없음 (이전 누적 유지) | UI 갱신 시작            |
| `stop()`   | `null`    | `0`                        | UI 갱신 중지, 세션 저장 |

### 일시정지/재개 시퀀스 예시

```
[start at 10:00]   startTime=10:00, accumulated=0
  → 10:25 시점에 elapsed 조회 = 0 + (10:25 - 10:00) = 25분

[pause at 10:30]   startTime=null, accumulated=30분
  → elapsed = 30분 (고정)

[resume at 10:45]  startTime=10:45, accumulated=30분
  → 11:00 시점에 elapsed 조회 = 30분 + (11:00 - 10:45) = 45분

[stop at 11:15]    elapsed = 30분 + (11:15 - 10:45) = 60분
  → 세션 기록: 60분 (일시정지 15분 제외)
```

핵심: **일시정지 중 흐른 시간(10:30~10:45)은 자동으로 제외**된다. resume 시 `startTime`만 현재 시각으로 갱신하고 `accumulated`는 건드리지 않기 때문.

---

## 3. UI 갱신과 시간 계산의 분리

### 설계 원칙

```
┌──────────────────────────────────────────────┐
│              시간 계산 레이어                    │
│  elapsed = accumulated + (now - startTime)    │
│  → 순수 함수, 부수효과 없음, 호출 시점에 계산     │
└──────────────────────────────────────────────┘
                    ↑ 읽기만 함
┌──────────────────────────────────────────────┐
│              UI 갱신 레이어                     │
│  Timer.periodic(1초) → 리빌드 트리거            │
│  → 시간을 세는 게 아니라, "다시 그려라" 신호만     │
└──────────────────────────────────────────────┘
```

- **Timer.periodic(1초)**: 시간을 세는 것이 아님. UI에 "다시 그리세요" 신호를 보내는 역할만 수행
- **elapsed getter**: UI가 리빌드될 때 호출되어 `DateTime.now()` 기반으로 정확한 값 계산
- 이 분리 덕분에 Timer.periodic이 정확히 1초마다 호출되지 않아도 시간 오차가 없음

### 왜 Timer.periodic이 필요한가?

elapsed가 순수 계산이라 상태 객체 자체는 변하지 않는다. 상태 관리 프레임워크(Riverpod, Bloc, Provider 등)는 상태가 변해야 리빌드하므로, 1초마다 "리빌드하라"는 수동 알림이 필요하다.

```
Timer.periodic(1초) → notifyListeners() → UI 리빌드 → elapsed getter 호출 → 정확한 시간 표시
```

---

## 4. 앱 생명주기 처리 알고리즘

### 백그라운드/포그라운드 전환

```
앱 → 백그라운드 (paused):
    UI 갱신 타이머 cancel (배터리 절약)
    startTime, accumulated 변경 없음 → 시간 계산 영향 없음

앱 ← 포그라운드 (resumed):
    if status == running:
        UI 갱신 타이머 재시작
    → elapsed getter가 DateTime.now()로 재계산하므로 즉시 정확한 시간 표시
```

| 시나리오                 | 동작                                 | 시간 정확성          |
| ------------------------ | ------------------------------------ | -------------------- |
| 백그라운드 5분 후 복귀   | UI 타이머 재시작, elapsed 재계산     | 정확                 |
| 백그라운드 5시간 후 복귀 | 동일                                 | 정확                 |
| 화면 이동 (앱 내)        | 상태 영속(keepAlive), elapsed 재계산 | 정확                 |
| 기기 시계 수동 변경      | `DateTime.now()`가 변경된 시계 반영  | 부정확 가능 (한계점) |

### 한계점: 시스템 시계 의존

`DateTime.now()` 기반이므로 사용자가 기기 시계를 수동 변경하면 경과 시간이 틀어질 수 있다. 이를 방지하려면:

- `Stopwatch` 클래스 사용 (monotonic clock 기반, 시계 변경 영향 없음)
- 서버 시간 동기화
- `SystemClock` 패키지 등 활용

현재 구현은 학습 타이머 특성상 시계 조작 방지까지는 불필요하다고 판단하여 `DateTime.now()`를 사용한다.

---

## 5. 상태 영속 전략

### 인메모리 영속 (화면 이동 대응)

```
┌─────────────────────────────────┐
│  전역 싱글턴 상태 관리자           │
│  (Riverpod keepAlive,           │
│   Bloc 전역 인스턴스,             │
│   GetX permanent 등)            │
│                                 │
│  TimerState {                   │
│    status, startTime,           │
│    accumulatedBeforePause       │
│  }                              │
│  → 화면 이동해도 dispose 안 됨    │
└─────────────────────────────────┘
        ↑              ↑
   화면 A에서       화면 B에서
   watch/listen    watch/listen
```

상태 관리자를 앱 전역 스코프로 유지하면, 어떤 화면에서든 동일 상태를 읽을 수 있다. 별도 "동기화 로직"이 필요 없다.

### 디스크 영속 (세션 기록)

타이머 진행 중 상태는 인메모리에만 존재한다. **세션 종료(`stop()`) 시에만** 디스크에 기록한다.

```
stop() 호출
  │
  ├─ 최소 시간 미달? → 저장 안 함 (노이즈 방지)
  │
  └─ 최소 시간 충족?
       ├─ 세션 엔티티 생성 (시작시각, 종료시각, 경과분)
       ├─ 로컬 저장소에 기록
       └─ 상태 초기화 (idle)
```

앱 강제 종료 시 진행 중 세션은 유실된다. 이를 방지하려면:

- 주기적 자동 저장 (5분마다 등)
- `didChangeAppLifecycleState`의 `detached`에서 저장
- 앱 재시작 시 미완료 세션 복구 로직

---

## 6. 통계 계산 알고리즘

### 일별/주별/월별 합산

```
todayMinutes = sessions
    .filter(s => normalize(s.startedAt) == normalize(now))
    .sum(s => s.durationMinutes)

weeklyMinutes = sessions
    .filter(s => normalize(s.startedAt) >= normalize(now - 6일))
    .sum(s => s.durationMinutes)

monthlyMinutes = sessions
    .filter(s => s.startedAt >= 이번달 1일)
    .sum(s => s.durationMinutes)
```

### 연속 일수 (Streak) 알고리즘

```
function calculateStreak(sessions):
    if sessions is empty: return 0

    // 1. 공부한 날짜 집합 추출 (중복 제거)
    studyDates = sessions
        .map(s => normalize(s.startedAt))
        .toUniqueSet()
        .sortDescending()  // 최신순

    today = normalize(now)
    yesterday = today - 1일

    // 2. 오늘 또는 어제 공부하지 않았으면 streak 끊김
    if studyDates[0] != today AND studyDates[0] != yesterday:
        return 0

    // 3. 연속 날짜 카운팅
    streak = 1
    for i = 1 to studyDates.length:
        diff = studyDates[i-1] - studyDates[i]  // 일수 차이
        if diff == 1:
            streak++
        else:
            break  // 연속 끊김

    return streak
```

**설계 포인트:**

- `오늘 OR 어제` 조건: 오늘 아직 공부 안 해도 어제까지의 streak 유지
- 날짜 정규화(`normalize`): 시/분/초 제거하여 같은 날 여러 세션을 하나의 날로 인식
- 최신순 정렬 후 역방향 탐색: 가장 최근부터 연속 여부 확인

---

## 7. 전체 흐름 요약

```
[사용자 액션]          [인메모리 상태]              [디스크]

  start() ──→ status=running
              startTime=now
              accumulated=0
                 │
                 │  Timer.periodic(1초)
                 │  → UI 리빌드
                 │  → elapsed = accumulated + (now - startTime)
                 │
  pause() ──→ status=paused
              startTime=null
              accumulated=elapsed (스냅샷)
                 │
  resume() ──→ status=running
              startTime=now
              accumulated=유지
                 │
  stop()  ──→ status=idle          ──→ 세션 JSON 저장
              startTime=null            (startedAt, endedAt,
              accumulated=0              durationMinutes)
                                         │
                                    통계 재계산
                                    (일별/주별/streak)
```

---

## 8. 다른 프레임워크 적용 가이드

| 개념           | Flutter/Riverpod              | React/Zustand                    | Swift/Combine                | Android/ViewModel              |
| -------------- | ----------------------------- | -------------------------------- | ---------------------------- | ------------------------------ |
| 전역 상태 영속 | `keepAlive: true`             | store (기본 전역)                | `@Published` in singleton    | `SavedStateHandle`             |
| UI 갱신 트리거 | `ref.notifyListeners()`       | `setState()` / `set()`           | `objectWillChange.send()`    | `LiveData.postValue()`         |
| 생명주기 감지  | `WidgetsBindingObserver`      | `useEffect` + `visibilitychange` | `scenePhase`                 | `Lifecycle.Event`              |
| 주기적 UI 갱신 | `Timer.periodic`              | `setInterval`                    | `Timer.publish`              | `Handler.postDelayed`          |
| 경과 시간 계산 | `DateTime.now().difference()` | `Date.now() -`                   | `Date().timeIntervalSince()` | `System.currentTimeMillis() -` |

### 최소 구현 (프레임워크 무관 의사코드)

```
class StopwatchTimer:
    state = { status: idle, startTime: null, accumulated: 0 }
    uiTimer = null

    start():
        state = { status: running, startTime: now(), accumulated: 0 }
        uiTimer = setInterval(1초, () => notifyUI())

    pause():
        clearInterval(uiTimer)
        state = { status: paused, startTime: null, accumulated: getElapsed() }

    resume():
        state = { ...state, status: running, startTime: now() }
        uiTimer = setInterval(1초, () => notifyUI())

    stop():
        clearInterval(uiTimer)
        elapsed = getElapsed()
        state = { status: idle, startTime: null, accumulated: 0 }
        return elapsed  // 세션 기록용

    getElapsed():
        if state.status == running AND state.startTime != null:
            return state.accumulated + (now() - state.startTime)
        return state.accumulated
```
