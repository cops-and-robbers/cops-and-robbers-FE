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
    this.shrinkRemaining,
    this.isDarkMode = false,
  });

  /// 다음 위치 공개까지 남은 시간.
  final Duration? remainingTime;

  /// 위치 공개 간격 (분). 시작 시각을 모를 때 표시한다.
  final int? intervalMinutes;

  /// 구역 축소를 켠 게임의 다음 축소까지 남은 시간 (#668). 있으면 위치 공개와 한 줄로 보인다.
  final Duration? shrinkRemaining;

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

  static String _mmss(Duration d) {
    final v = d.isNegative ? Duration.zero : d;
    final m = v.inMinutes.toString().padLeft(2, '0');
    final s = v.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final shrink = shrinkRemaining;
    return Text(
      // 앱바가 두 줄로 높아지지 않게 축소 시간은 같은 줄에 붙인다
      shrink == null
          ? l10n.gameLocationRevealCountdown(_formatted)
          : l10n.gameRevealShrinkCountdown(_formatted, _mmss(shrink)),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppTextStyles.tag_12.copyWith(
        color: isDarkMode ? AppColors.black400 : AppColors.red,
      ),
    );
  }
}
