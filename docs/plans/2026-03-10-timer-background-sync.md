# 타이머 백그라운드 동기화 구현 계획

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development to implement this plan task-by-task.

**Goal:** 3개 타이머 위젯을 `DateTime.now()` 기반 재계산 방식으로 통일하여, 백그라운드 전환 후 복귀 시에도 정확한 시간을 표시한다.

**Architecture:** `docs/08_TIMER_ARCHITECTURE.md` 패턴 적용 — `endTime` 고정 앵커 + 매 틱마다 `remaining = endTime - DateTime.now()` 재계산 + `WidgetsBindingObserver`로 포그라운드 복귀 시 즉시 보정

**Tech Stack:** Flutter, Timer.periodic, WidgetsBindingObserver

---

## 변경 대상 파일

| # | 파일 | 변경 유형 | 현재 문제 |
|---|------|-----------|-----------|
| 1 | `lib/core/widgets/dialogs/countdown_timer_content.dart` | Modify | 틱 카운팅(`_remainingSeconds--`) → 백그라운드 시 오차 누적 |
| 2 | `lib/core/widgets/dialogs/app_popup.dart` | Modify | `Timer(duration, pop)` 단발 타이머 → 백그라운드 시 지연 |
| 3 | `lib/features/game/presentation/widgets/game_timer_text.dart` | Modify | DateTime 기반이지만 `WidgetsBindingObserver` 미적용 → 복귀 시 최대 1초 지연 |

---

## Task 1: CountdownTimerContent — DateTime 기반 재계산 + 백그라운드 보정

**심각도:** Critical — 경찰 대기 타이머가 백그라운드 복귀 시 서버와 불일치

**Files:**
- Modify: `lib/core/widgets/dialogs/countdown_timer_content.dart:51-73`

**Step 1: State 클래스에 WidgetsBindingObserver 믹스인 + endTime 필드 추가**

`_CountdownTimerContentState` 전체를 다음으로 교체:

```dart
class _CountdownTimerContentState extends State<CountdownTimerContent>
    with WidgetsBindingObserver {
  late final DateTime _endTime;
  late int _remainingSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _endTime = DateTime.now().add(widget.duration);
    _remainingSeconds = widget.duration.inSeconds;
    _startTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _recalculate();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _recalculate();
    });
  }

  void _recalculate() {
    final remaining = _endTime.difference(DateTime.now()).inSeconds;
    final clamped = remaining < 0 ? 0 : remaining;
    if (clamped != _remainingSeconds) {
      setState(() => _remainingSeconds = clamped);
    }
    if (clamped == 0) {
      _timer?.cancel();
      widget.onComplete?.call();
    }
  }
```

**핵심 변경:**
- `_endTime = DateTime.now().add(widget.duration)` — 고정 앵커
- 매 틱 + resumed 시 `_endTime - now` 재계산
- 백그라운드 5분 후 복귀해도 즉시 정확한 남은 시간 표시

**Step 2: flutter analyze 실행**

Run: `flutter analyze lib/core/widgets/dialogs/countdown_timer_content.dart`
Expected: No issues

**Step 3: 커밋**

```bash
git add lib/core/widgets/dialogs/countdown_timer_content.dart
git commit -m "fix : CountdownTimerContent DateTime 기반 재계산 + 백그라운드 보정 #108"
```

---

## Task 2: AppPopup — 자동 닫힘 타이머 백그라운드 보정

**심각도:** Major — 팝업이 백그라운드 시간만큼 늦게 닫힘

**Files:**
- Modify: `lib/core/widgets/dialogs/app_popup.dart:74-93`

**Step 1: State 클래스에 WidgetsBindingObserver + closeTime 필드 추가**

`_AppPopupState` 전체를 다음으로 교체:

```dart
class _AppPopupState extends State<AppPopup> with WidgetsBindingObserver {
  Timer? _autoCloseTimer;
  DateTime? _closeTime;

  @override
  void initState() {
    super.initState();
    if (widget.autoCloseDuration != null) {
      WidgetsBinding.instance.addObserver(this);
      _closeTime = DateTime.now().add(widget.autoCloseDuration!);
      _scheduleClose();
    }
  }

  @override
  void dispose() {
    if (widget.autoCloseDuration != null) {
      WidgetsBinding.instance.removeObserver(this);
    }
    _autoCloseTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _scheduleClose();
    }
  }

  void _scheduleClose() {
    _autoCloseTimer?.cancel();
    final remaining = _closeTime!.difference(DateTime.now());
    if (remaining <= Duration.zero) {
      _popIfCurrent();
    } else {
      _autoCloseTimer = Timer(remaining, _popIfCurrent);
    }
  }

  void _popIfCurrent() {
    if (mounted && ModalRoute.of(context)?.isCurrent == true) {
      Navigator.of(context).pop();
    }
  }
```

**핵심 변경:**
- `_closeTime = DateTime.now().add(autoCloseDuration)` — 고정 닫힘 시각
- 포그라운드 복귀 시 `_scheduleClose()` 재계산: 이미 지났으면 즉시 pop, 남았으면 남은 시간으로 새 Timer
- Observer 등록/해제는 `autoCloseDuration != null`인 경우에만

**Step 2: flutter analyze 실행**

Run: `flutter analyze lib/core/widgets/dialogs/app_popup.dart`
Expected: No issues

**Step 3: 커밋**

```bash
git add lib/core/widgets/dialogs/app_popup.dart
git commit -m "fix : AppPopup 자동 닫힘 타이머 백그라운드 보정 #108"
```

---

## Task 3: GameTimerText — WidgetsBindingObserver 추가

**심각도:** Minor — 이미 DateTime 기반이지만, 복귀 시 최대 1초 지연

**Files:**
- Modify: `lib/features/game/presentation/widgets/game_timer_text.dart:30-49`

**Step 1: State 클래스에 WidgetsBindingObserver 믹스인 추가**

`_GameTimerTextState` 전체를 다음으로 교체:

```dart
class _GameTimerTextState extends State<GameTimerText>
    with WidgetsBindingObserver {
  late Timer _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _remaining = _calcRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final r = _calcRemaining();
      setState(() => _remaining = r);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final r = _calcRemaining();
      if (r != _remaining) {
        setState(() => _remaining = r);
      }
    }
  }
```

**핵심 변경:**
- `WidgetsBindingObserver` 추가로 포그라운드 복귀 즉시 재계산
- 기존 `_calcRemaining()` 로직(DateTime 기반)은 그대로 유지

**Step 2: flutter analyze 실행**

Run: `flutter analyze lib/features/game/presentation/widgets/game_timer_text.dart`
Expected: No issues

**Step 3: 커밋**

```bash
git add lib/features/game/presentation/widgets/game_timer_text.dart
git commit -m "fix : GameTimerText 백그라운드 복귀 시 즉시 재계산 #108"
```

---

## 요약

| # | Task | 심각도 | 변경 내용 |
|---|------|--------|-----------|
| 1 | CountdownTimerContent | Critical | 틱 카운팅 → DateTime 재계산 + WidgetsBindingObserver |
| 2 | AppPopup | Major | 단발 Timer → closeTime 앵커 + resumed 시 재스케줄 |
| 3 | GameTimerText | Minor | WidgetsBindingObserver 추가 (기존 DateTime 로직 유지) |
