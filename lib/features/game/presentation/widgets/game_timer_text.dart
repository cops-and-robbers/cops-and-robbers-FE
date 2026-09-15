import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import 'location_reveal_countdown.dart';

/// 게임 제한 시간과 다음 위치 공개까지 남은 시간을 함께 표시한다.
///
/// 두 표시 모두 [startTime] 기준 경과 시간과 하나의 갱신 타이머를 사용한다.
/// 위치 공개 예정은 이벤트 수신 시각이 아닌 게임 설정으로 계산한다.
class GameTimerText extends StatefulWidget {
  const GameTimerText({
    super.key,
    required this.startTime,
    required this.totalDuration,
    this.policeWaitMinutes,
    this.locationRevealIntervalMinutes,
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
       totalDuration = remainingTime,
       policeWaitMinutes = null,
       locationRevealIntervalMinutes = null;

  /// 게임 시작 시각
  final DateTime? startTime;

  /// 게임 총 제한 시간
  final Duration? totalDuration;

  /// 게임 시작 후 경찰 대기 시간 (분).
  final int? policeWaitMinutes;

  /// 경찰 이동 시작 후 위치 공개 간격 (분).
  final int? locationRevealIntervalMinutes;

  /// 다크 모드 여부
  final bool isDarkMode;

  @override
  State<GameTimerText> createState() => _GameTimerTextState();
}

class _GameTimerTextState extends State<GameTimerText>
    with WidgetsBindingObserver {
  late Timer _timer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _now = clock.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _update());
  }

  @override
  void didUpdateWidget(GameTimerText oldWidget) {
    super.didUpdateWidget(oldWidget);
    _now = clock.now();
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
      _update();
    }
  }

  void _update() {
    if (!mounted) return;
    setState(() => _now = clock.now());
  }

  String _formatted(Duration? remaining) {
    if (remaining == null) return '--:--';
    if (remaining.isNegative) remaining = Duration.zero;
    final m = remaining.inMinutes.toString().padLeft(2, '0');
    final s = remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final startTime = widget.startTime;
    final elapsed = startTime == null ? null : _now.difference(startTime);
    final totalDuration = widget.totalDuration;
    final remaining = elapsed != null && totalDuration != null
        ? totalDuration - elapsed
        : null;

    final interval = widget.locationRevealIntervalMinutes;
    final wait = widget.policeWaitMinutes;
    Duration? revealRemaining;
    if (elapsed != null && interval != null && interval > 0 && wait != null) {
      final period = Duration(minutes: interval);
      var untilReveal = Duration(minutes: wait) + period - elapsed;
      while (untilReveal.isNegative) {
        untilReveal += period;
      }
      revealRemaining = untilReveal;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _formatted(remaining),
          style: widget.isDarkMode
              ? AppTextStyles.robberHeading.copyWith(color: AppColors.white)
              : AppTextStyles.heading_20.copyWith(color: AppColors.black),
        ),
        SizedBox(height: AppSpacing.vertical6),
        LocationRevealCountdown(
          remainingTime: revealRemaining,
          intervalMinutes: interval,
          isDarkMode: widget.isDarkMode,
        ),
      ],
    );
  }
}
