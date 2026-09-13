import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text_styles.dart';

/// 게임 제한 시간 카운트다운 타이머 위젯
///
/// [startTime] 기준으로 [totalDuration]에서 경과 시간을 빼
/// 남은 시간을 MM:SS 형식으로 표시합니다.
/// START 이벤트 수신 시 앱바 중앙에 표시됩니다.
class GameTimerText extends StatefulWidget {
  const GameTimerText({
    super.key,
    required this.startTime,
    required this.totalDuration,
    this.isDarkMode = false,
  });

  /// 서버 남은 시간은 수신 시각과 함께 전달한다. 재수신하면 즉시 보정된다.
  /// [receivedAt]은 매 build가 아니라 해당 응답을 받은 시각이어야 한다.
  const GameTimerText.remaining({
    super.key,
    required Duration remainingTime,
    required DateTime receivedAt,
    this.isDarkMode = false,
  }) : startTime = receivedAt,
       totalDuration = remainingTime;

  /// 게임 시작 시각
  final DateTime startTime;

  /// 게임 총 제한 시간
  final Duration totalDuration;

  /// 다크 모드 여부
  final bool isDarkMode;

  @override
  State<GameTimerText> createState() => _GameTimerTextState();
}

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
  void didUpdateWidget(GameTimerText oldWidget) {
    super.didUpdateWidget(oldWidget);
    _remaining = _calcRemaining();
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

  Duration _calcRemaining() {
    final elapsed = clock.now().difference(widget.startTime);
    final remaining = widget.totalDuration - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  String get _formatted {
    final m = _remaining.inMinutes.toString().padLeft(2, '0');
    final s = _remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _formatted,
      style: widget.isDarkMode
          ? AppTextStyles.robberHeading.copyWith(color: AppColors.white)
          : AppTextStyles.heading_20.copyWith(color: AppColors.black),
    );
  }
}
