# CountdownTimerContent 위젯 구현 계획

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** AppPopup 안에서 실시간으로 카운트다운되는 타이머 콘텐츠 위젯을 만든다.

**Architecture:** `CountdownTimerContent`는 `AppPopup.show(content: ...)`에 전달되는 독립 StatefulWidget. 내부에서 `Timer.periodic`으로 매초 갱신하며, 1분 미만일 때 색상이 red로 변경된다. `AppPopup`의 `autoCloseDuration`과 동일한 Duration을 전달하여 타이머 종료 = 팝업 닫힘이 동기화된다.

**Tech Stack:** Flutter, flutter_screenutil, AppTextStyles, AppColors

---

### Task 1: CountdownTimerContent 위젯 생성

**Files:**
- Create: `lib/core/widgets/dialogs/countdown_timer_content.dart`

**Step 1: 위젯 파일 생성**

```dart
import 'dart:async';

import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/spacing_and_radius.dart';
import '../../constants/text_styles.dart';

/// AppPopup 내부에서 사용하는 카운트다운 타이머 콘텐츠
///
/// 매초 갱신되며 MM:SS 형식으로 남은 시간을 표시합니다.
/// 1분 미만이 되면 숫자와 자막 색상이 빨간색으로 변경됩니다.
///
/// **사용 예시**:
/// ```dart
/// AppPopup.show(
///   context: context,
///   autoCloseDuration: Duration(minutes: 5),
///   barrierDismissible: false,
///   content: CountdownTimerContent(
///     duration: Duration(minutes: 5),
///     subtitle: '도둑이 도망치는 중이에요!',
///   ),
/// );
/// ```
class CountdownTimerContent extends StatefulWidget {
  const CountdownTimerContent({
    super.key,
    required this.duration,
    this.subtitle,
    this.urgentThreshold = const Duration(minutes: 1),
  });

  /// 카운트다운 시작 시간
  final Duration duration;

  /// 타이머 아래 표시할 자막 (선택)
  final String? subtitle;

  /// 긴급 색상(빨간색)으로 전환되는 임계값 (기본: 1분)
  final Duration urgentThreshold;

  @override
  State<CountdownTimerContent> createState() => _CountdownTimerContentState();
}

class _CountdownTimerContentState extends State<CountdownTimerContent> {
  late int _remainingSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.duration.inSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool get _isUrgent => _remainingSeconds < widget.urgentThreshold.inSeconds;

  String get _formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final timerColor = _isUrgent ? AppColors.red : AppColors.black;
    final subtitleColor = _isUrgent ? AppColors.red800 : AppColors.black600;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _formattedTime,
          style: AppTextStyles.semibold_44.copyWith(color: timerColor),
          textAlign: TextAlign.center,
        ),
        if (widget.subtitle != null) ...[
          SizedBox(height: AppSpacing.vertical12),
          Text(
            widget.subtitle!,
            style: AppTextStyles.paragraph_14_100.copyWith(
              color: subtitleColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
```

**Step 2: 분석 실행**

Run: `flutter analyze lib/core/widgets/dialogs/countdown_timer_content.dart`
Expected: No issues found

**Step 3: 커밋**

```bash
git add lib/core/widgets/dialogs/countdown_timer_content.dart
git commit -m "feat: CountdownTimerContent 카운트다운 위젯 추가"
```

---

### Task 2: 테스트 페이지에 카운트다운 위젯 연동

**Files:**
- Modify: `lib/test_widget_page.dart`

**Step 1: import 추가**

파일 상단에 추가:
```dart
import 'core/widgets/dialogs/countdown_timer_content.dart';
```

**Step 2: 타이머 팝업 (여유) 수정** (약 944-976행)

기존 정적 Column → `CountdownTimerContent` 교체:

```dart
// 기존:
content: Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    Text('04:59', style: AppTextStyles.semibold_44.copyWith(color: AppColors.black), ...),
    ...
    Text('도둑이 도망치는 중이에요!', ...),
  ],
),

// 변경:
content: CountdownTimerContent(
  duration: const Duration(minutes: 1),
  subtitle: '도둑이 도망치는 중이에요!',
),
```

**Step 3: 타이머 팝업 (1분 미만) 수정** (약 979-1011행)

기존 정적 Column → `CountdownTimerContent` 교체 (30초로 설정하여 즉시 빨간색 확인):

```dart
// 변경:
content: CountdownTimerContent(
  duration: const Duration(seconds: 30),
  subtitle: '도둑 잡을 준비 되셨나요?',
),
```

버튼 텍스트도 업데이트:
- `'타이머 팝업 (1분 미만) - 1분 자동닫힘'` → `'타이머 팝업 (30초) - 빨간색'`
- `autoCloseDuration`도 `Duration(seconds: 30)`으로 동기화

**Step 4: 분석 실행**

Run: `flutter analyze lib/test_widget_page.dart`
Expected: No issues found

**Step 5: 커밋**

```bash
git add lib/test_widget_page.dart
git commit -m "feat: 테스트 페이지 타이머 팝업에 CountdownTimerContent 연동"
```
