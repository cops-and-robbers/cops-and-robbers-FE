import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text_styles.dart';

/// 다음 도둑 위치 공개까지 남은 시간을 MM:SS로 표시하는 위젯
///
/// [remainingTime]이 null이면 [intervalMinutes]가 유효할 경우 '{interval}:00' 표시,
/// 그렇지 않으면 '--:--' 표시.
/// 시간 계산과 갱신은 게임 타이머에서 함께 처리한다.
class LocationRevealCountdown extends StatelessWidget {
  const LocationRevealCountdown({
    super.key,
    this.remainingTime,
    this.intervalMinutes,
    this.isDarkMode = false,
  });

  /// 다음 위치 공개까지 남은 시간.
  final Duration? remainingTime;

  /// 위치 공개 간격 (분). 시작 시각을 모를 때 표시한다.
  final int? intervalMinutes;

  /// 다크 모드 여부
  final bool isDarkMode;

  String get _formatted {
    final remaining = remainingTime;
    if (remaining == null) {
      final interval = intervalMinutes;
      if (interval == null || interval <= 0) return '--:--';
      return '${interval.toString().padLeft(2, '0')}:00';
    }
    final m = remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      AppLocalizations.of(context).gameLocationRevealCountdown(_formatted),
      style: AppTextStyles.tag_12.copyWith(
        color: isDarkMode ? AppColors.black400 : AppColors.red,
      ),
    );
  }
}
