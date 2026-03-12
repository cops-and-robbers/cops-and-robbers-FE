import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text_styles.dart';

/// 도둑팀 전용 경찰 시작 카운트다운 위젯
///
/// 경찰 대기 시간이 끝날 때까지 "경찰 시작까지 MM:SS"를 표시합니다.
/// 1분 미만 시 빨간색으로 전환, 0 이하 도달 시 자동 숨김.
/// DateTime 기반 계산으로 백그라운드 복귀 시에도 정확한 시간 표시.
class PoliceStartCountdown extends StatefulWidget {
  const PoliceStartCountdown({super.key, required this.policeStartTime});

  /// 경찰이 움직이기 시작하는 시각 (gameStartTime + policeWaitMinutes)
  final DateTime policeStartTime;

  @override
  State<PoliceStartCountdown> createState() => _PoliceStartCountdownState();
}

class _PoliceStartCountdownState extends State<PoliceStartCountdown>
    with WidgetsBindingObserver {
  late Timer _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _update();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _update());
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

  @override
  void didUpdateWidget(PoliceStartCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.policeStartTime != widget.policeStartTime) {
      _update();
    }
  }

  void _update() {
    if (!mounted) return;
    setState(() {
      final diff = widget.policeStartTime.difference(DateTime.now());
      _remaining = diff.isNegative ? Duration.zero : diff;
    });
  }

  String get _formatted {
    final m = _remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = _remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    if (_remaining <= Duration.zero) return const SizedBox.shrink();

    final isUrgent = _remaining.inSeconds < 60;

    return Text(
      '경찰 시작까지 $_formatted',
      style: AppTextStyles.robber_label.copyWith(
        color: isUrgent ? AppColors.red : AppColors.green,
      ),
    );
  }
}
