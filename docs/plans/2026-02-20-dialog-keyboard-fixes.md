# AppDialog 키보드/Shake/문서 수정 계획

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** CodeRabbit 리뷰 4건 반영 — 키보드가 다이얼로그를 가리는 Major 이슈 해결 + shake ScreenUtil 스케일링 + 계획 문서 정리

**Architecture:** `showGeneralDialog` 내부에서 Flutter 내장 `Dialog` 위젯과 동일한 `AnimatedPadding(MediaQuery.viewInsetsOf)` 패턴을 적용하여 키보드 인셋 대응. `SingleChildScrollView`로 오버플로우 방지. Shake 오프셋은 `.w` 스케일링 적용.

**Tech Stack:** Flutter (AnimatedPadding, MediaQuery.viewInsetsOf, SingleChildScrollView, ScreenUtil)

---

## Task 1: 키보드 인셋 대응 — AnimatedPadding + SingleChildScrollView 적용

> **CodeRabbit #4 (Major)**: customContent에 TextField가 있을 때 소프트 키보드가 다이얼로그를 가림

**Files:**
- Modify: `lib/core/widgets/dialogs/app_dialog.dart:320-398` (build 메서드)

**문제 분석:**
- 현재 `Center` 위젯만 사용 → `MediaQuery.viewInsets`(키보드 높이)를 소비하지 않음
- 키보드가 올라와도 다이얼로그가 화면 정중앙에 고정 → TextField와 버튼이 키보드 뒤에 숨김
- Flutter 내장 `Dialog` 위젯은 `AnimatedPadding(padding: MediaQuery.viewInsetsOf(context))` 으로 처리

**Step 1: build 메서드 수정**

기존:
```dart
@override
Widget build(BuildContext context) {
  return Center(
    child: AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) => Transform.translate(
        offset: Offset(_shakeAnimation.value, 0),
        child: child,
      ),
      child: Container(
        width: double.infinity,
        margin: AppPadding.horizontal36,
        // ...
      ),
    ),
  );
}
```

변경 후:
```dart
@override
Widget build(BuildContext context) {
  return AnimatedPadding(
    padding: MediaQuery.viewInsetsOf(context),
    duration: const Duration(milliseconds: 100),
    curve: Curves.decelerate,
    child: Center(
      child: AnimatedBuilder(
        animation: _shakeAnimation,
        builder: (context, child) => Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: child,
        ),
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            margin: AppPadding.horizontal36,
            padding: EdgeInsets.only(
              top: 24.w,
              left: 16.w,
              right: 16.w,
              bottom: 16.w,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: AppRadius.xxlarge,
            ),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ... 기존 children 그대로
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
```

**동작 원리:**
- `AnimatedPadding`: 키보드가 올라오면 하단 패딩이 키보드 높이만큼 증가 → 다이얼로그가 위로 밀림
- `Center`: 남은 공간에서 다이얼로그를 중앙 배치
- `SingleChildScrollView`: 키보드 + 다이얼로그 높이가 화면을 초과하면 스크롤 허용 → 오버플로우 방지
- `duration: 100ms, curve: decelerate`: 키보드 올라올 때 부드러운 애니메이션

**Step 2: flutter analyze 확인**

Run: `flutter analyze lib/core/widgets/dialogs/app_dialog.dart`
Expected: No issues found

**Step 3: Commit**

```bash
git add lib/core/widgets/dialogs/app_dialog.dart
git commit -m "fix: 키보드가 다이얼로그를 가리는 문제 수정 (AnimatedPadding + SingleChildScrollView) #99"
```

---

## Task 2: Shake 오프셋에 ScreenUtil 스케일링 적용

> **CodeRabbit #3 (Minor)**: TweenSequence의 픽셀 값(±8, ±6, 4)이 ScreenUtil 스케일링을 거치지 않음

**Files:**
- Modify: `lib/core/widgets/dialogs/app_dialog.dart:280-289` (initState 내 TweenSequence)

**Step 1: Tween 값에 `.w` 적용**

기존:
```dart
_shakeAnimation =
    TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: -6), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -6, end: 4), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 4, end: 0), weight: 1),
    ]).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
    );
```

변경 후:
```dart
_shakeAnimation =
    TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -8.w), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8.w, end: 8.w), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.w, end: -6.w), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -6.w, end: 4.w), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 4.w, end: 0), weight: 1),
    ]).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
    );
```

**Note:** `.w`는 `initState`에서 한 번 평가됨. 화면 회전 시 재계산은 불필요 (모바일 게임이므로 세로 고정).

**Step 2: flutter analyze 확인**

Run: `flutter analyze lib/core/widgets/dialogs/app_dialog.dart`
Expected: No issues found

**Step 3: Commit**

```bash
git add lib/core/widgets/dialogs/app_dialog.dart
git commit -m "style: shake 오프셋에 ScreenUtil .w 스케일링 적용 #99"
```

---

## Task 3: 계획 문서 정리

> **CodeRabbit #1 (Minor)**: AI 지시문이 문서에 커밋됨
> **CodeRabbit #2 (Minor)**: 마크다운 헤딩 레벨이 h1→h3로 건너뜀 (MD001)

**Files:**
- Modify: `docs/plans/2026-02-20-dialog-shake-validation.md:3` (AI directive 제거)
- Modify: `docs/plans/2026-02-20-dialog-shake-validation.md:13,139,187` (### → ## 변경)

**Step 1: AI 지시문 제거**

line 3 삭제:
```markdown
> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.
```

**Step 2: 헤딩 레벨 수정**

```markdown
# (기존) → 그대로
### Task 1 → ## Task 1
### Task 2 → ## Task 2
### Task 3 → ## Task 3
```

**Step 3: Commit**

```bash
git add docs/plans/2026-02-20-dialog-shake-validation.md
git commit -m "docs: 계획 문서에서 AI 지시문 제거 및 헤딩 레벨 수정 #99"
```

---

## 완료 후 검증

```bash
flutter analyze
```
Expected: No issues found

## UX 동작 정리 (키보드 관련)

| 상태 | 키보드 없음 | 키보드 올라옴 |
|------|------------|-------------|
| 다이얼로그 위치 | 화면 정중앙 | 키보드 위로 밀려 올라감 |
| 오버플로우 | 없음 | SingleChildScrollView로 스크롤 가능 |
| shake 애니메이션 | 좌우 흔들림 | 동일하게 동작 |
| 키보드 닫힘 | - | 부드럽게 원래 위치로 복귀 (100ms) |
