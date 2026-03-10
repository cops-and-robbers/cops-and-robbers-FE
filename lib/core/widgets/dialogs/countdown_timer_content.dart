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
///   content: CountdownTimerContent(
///     duration: Duration(minutes: 5),
///     subtitle: '도둑이 도망치는 중이에요!',
///     onComplete: () => debugPrint('카운트다운 종료'),
///   ),
/// );
/// ```
class CountdownTimerContent extends StatefulWidget {
  const CountdownTimerContent({
    super.key,
    required this.duration,
    this.subtitle,
    this.urgentThreshold = const Duration(minutes: 1),
    this.onComplete,
  });

  /// 카운트다운 시작 시간
  final Duration duration;

  /// 타이머 아래 표시할 자막 (선택)
  final String? subtitle;

  /// 긴급 색상(빨간색)으로 전환되는 임계값 (기본: 1분)
  final Duration urgentThreshold;

  /// 카운트다운 종료 시 호출되는 콜백 (선택)
  final VoidCallback? onComplete;

  @override
  State<CountdownTimerContent> createState() => _CountdownTimerContentState();
}

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
