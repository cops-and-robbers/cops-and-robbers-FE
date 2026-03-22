import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text_styles.dart';

/// 다음 도둑 위치 공개까지 남은 시간을 MM:SS로 표시하는 위젯
///
/// [nextRevealTime]이 null이면 [intervalMinutes]가 유효할 경우 '{interval}:00' 표시,
/// 그렇지 않으면 '--:--' 표시.
/// [intervalMinutes]가 지정되면 카운트다운이 0에 도달 시
/// 자동으로 다음 주기로 순환한다.
class LocationRevealCountdown extends StatefulWidget {
  const LocationRevealCountdown({
    super.key,
    this.nextRevealTime,
    this.intervalMinutes,
    this.isDarkMode = false,
  });

  /// 다음 위치 공개 예정 시각
  final DateTime? nextRevealTime;

  /// 위치 공개 간격 (분). 카운트다운 자동 순환에 사용.
  final int? intervalMinutes;

  /// 다크 모드 여부
  final bool isDarkMode;

  @override
  State<LocationRevealCountdown> createState() =>
      _LocationRevealCountdownState();
}

class _LocationRevealCountdownState extends State<LocationRevealCountdown>
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
  void didUpdateWidget(LocationRevealCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.nextRevealTime != widget.nextRevealTime) {
      _update();
    }
  }

  void _update() {
    if (!mounted) return;
    setState(() {
      if (widget.nextRevealTime == null) {
        _remaining = Duration.zero;
        return;
      }

      var target = widget.nextRevealTime!;

      // intervalMinutes가 있으면 target이 과거일 때 다음 주기로 자동 순환
      final interval = widget.intervalMinutes;
      if (interval != null && interval > 0) {
        final intervalDuration = Duration(minutes: interval);
        while (target.isBefore(DateTime.now())) {
          target = target.add(intervalDuration);
        }
      }

      final diff = target.difference(DateTime.now());
      _remaining = diff.isNegative ? Duration.zero : diff;
    });
  }

  String get _formatted {
    if (widget.nextRevealTime == null) {
      final interval = widget.intervalMinutes;
      if (interval == null || interval <= 0) return '--:--';
      return '${interval.toString().padLeft(2, '0')}:00';
    }
    final m = _remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = _remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '다음 도둑 위치 공개까지 $_formatted',
      style: AppTextStyles.tag_12.copyWith(
        color: widget.isDarkMode ? AppColors.black400 : AppColors.red,
      ),
    );
  }
}
