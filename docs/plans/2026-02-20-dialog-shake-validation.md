# AppDialog Shake Validation Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** AppDialog에 validator 파라미터 추가 — 유효성 검증 실패 시 다이얼로그를 닫지 않고 흔들림 애니메이션으로 피드백

**Architecture:** `AppDialog.show()`에 `bool Function()? validator` 파라미터 추가. validator가 false 반환하면 pop() 하지 않고 다이얼로그 컨테이너에 수평 흔들림(shake) 애니메이션 실행. 기존 AppDialog를 StatelessWidget에서 StatefulWidget으로 변환하여 AnimationController 관리.

**Tech Stack:** Flutter, Dart (AnimationController, TweenSequence)

---

### Task 1: AppDialog에 shake 애니메이션 + validator 지원 추가

**Files:**
- Modify: `lib/core/widgets/dialogs/app_dialog.dart`

**Step 1: AppDialog를 StatefulWidget으로 변환 + shake 구현**

AppDialog 클래스 변경사항:

1. `StatelessWidget` → `StatefulWidget` 변환
2. `_AppDialogState`에 `AnimationController` + shake 로직 추가
3. `shake()` 메서드: 수평 좌우 흔들림 (±8px, 400ms)
4. build()에서 Container를 `AnimatedBuilder` + `Transform.translate`로 감싸기

```dart
class AppDialog extends StatefulWidget {
  // ... (기존 필드 그대로 유지)

  @override
  State<AppDialog> createState() => _AppDialogState();
}

class _AppDialogState extends State<AppDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    // 좌 → 우 → 좌 → 우 → 중앙 (4회 진동)
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: -6), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -6, end: 4), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 4, end: 0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void shake() {
    _shakeController.forward(from: 0);
  }

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
          // ... 기존 Container 내용 그대로
        ),
      ),
    );
  }
}
```

5. `AppDialog.show()`에 `validator` 파라미터 추가:

```dart
static Future<T?> show<T>({
  // ... 기존 파라미터 ...
  bool Function()? validator,  // 추가
}) {
  final dialogKey = GlobalKey<_AppDialogState>();  // 추가

  return showGeneralDialog<T>(
    // ...
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return AppDialog(
        key: dialogKey,  // 추가
        // ... 기존 파라미터 ...
        onConfirm: () {
          // validator가 있고, 실패하면 shake + return (pop 안 함)
          if (validator != null && !validator()) {
            dialogKey.currentState?.shake();
            return;
          }
          Navigator.of(dialogContext).pop();
          onConfirm?.call();
        },
        onCancel: onCancel != null
            ? () {
                Navigator.of(dialogContext).pop();
                onCancel.call();
              }
            : () => Navigator.of(dialogContext).pop(),
      );
    },
    // ...
  );
}
```

**Step 2: flutter analyze 확인**

Run: `flutter analyze lib/core/widgets/dialogs/app_dialog.dart`
Expected: No issues found

**Step 3: Commit**

```bash
git add lib/core/widgets/dialogs/app_dialog.dart
git commit -m "feat: AppDialog에 validator + shake 애니메이션 추가 #99"
```

---

### Task 2: 방 참여 다이얼로그에 6자리 검증 적용

**Files:**
- Modify: `lib/features/session/presentation/pages/home_page.dart:36-56`

**Step 1: validator 추가**

```dart
void _showJoinRoomDialog(BuildContext context) {
  final codeController = TextEditingController();

  AppDialog.show(
    context: context,
    title: '방 참여하기',
    customContent: AppTextField(
      controller: codeController,
      hintText: '초대 코드를 입력하세요',
      maxLength: 6,
    ),
    cancelText: '취소',
    confirmText: '참여',
    validator: () => codeController.text.trim().length == 6,
    onConfirm: () {
      final code = codeController.text.trim();
      context.go(RoutePaths.waitingRoomWithId(code));
    },
  );
}
```

변경 포인트:
- `validator: () => codeController.text.trim().length == 6` — 6자리가 아니면 shake
- `onConfirm` 내부에서 `isEmpty` 체크 제거 — validator가 이미 보장

**Step 2: flutter analyze 확인**

Run: `flutter analyze lib/features/session/presentation/pages/home_page.dart`
Expected: No issues found

**Step 3: Commit**

```bash
git add lib/features/session/presentation/pages/home_page.dart
git commit -m "feat: 방 참여 다이얼로그에 6자리 코드 검증 적용 #99"
```

---

### Task 3: 테스트 위젯 페이지에서 shake 동작 확인 케이스 추가 (선택)

이 태스크는 필요 시에만 진행.

---

## 완료 후 검증

```bash
flutter analyze
```
Expected: No issues found

## UX 동작 정리

| 입력 상태 | 확인 버튼 탭 시 |
|----------|---------------|
| 빈 입력 | 다이얼로그 shake (닫히지 않음) |
| 1~5자리 | 다이얼로그 shake (닫히지 않음) |
| 6자리 | 다이얼로그 닫힘 → 대기실 이동 |
