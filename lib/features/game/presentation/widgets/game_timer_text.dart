import 'dart:async';

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
  });

  /// 게임 시작 시각
  final DateTime startTime;

  /// 게임 총 제한 시간
  final Duration totalDuration;

  @override
  State<GameTimerText> createState() => _GameTimerTextState();
}

class _GameTimerTextState extends State<GameTimerText> {
  late Timer _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = _calcRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final r = _calcRemaining();
      setState(() => _remaining = r);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Duration _calcRemaining() {
    final elapsed = DateTime.now().difference(widget.startTime);
    final remaining = widget.totalDuration - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  String get _formatted {
    final m = _remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = _remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _formatted,
      style: AppTextStyles.heading_20.copyWith(color: AppColors.black),
    );
  }
}
