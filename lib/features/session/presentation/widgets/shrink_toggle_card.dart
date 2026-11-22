import 'package:flutter/material.dart';

import '../../../../core/utils/zone_metric_formatter.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../game/domain/shrink_schedule.dart';
import 'setting_switch_card.dart';

/// 구역 축소 켜고 끄기 카드 (#668)
///
/// 방 생성 확인 화면과 대기방 게임 설정이 같이 쓴다. [onChanged]가 null이면
/// 참가자용 읽기 전용이다 — 같은 스위치를 누를 수 없게 보여 주고, 고칠 수 없는
/// 사람에게 잠금 안내("구역이 작아서…")는 띄우지 않는다.
class ShrinkToggleCard extends StatelessWidget {
  const ShrinkToggleCard({
    super.key,
    required this.enabled,
    required this.lock,
    required this.startRadius,
    required this.finalRadius,
    this.onChanged,
    this.isDarkMode = false,
  });

  final bool enabled;
  final ShrinkLock lock;
  final int startRadius;

  /// 켰을 때 줄어드는 최종 반경. 잠겼으면 null이어도 된다.
  final int? finalRadius;
  final ValueChanged<bool>? onChanged;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final canEdit = onChanged != null;
    final locked = canEdit && lock != ShrinkLock.none;
    final on = enabled && lock == ShrinkLock.none;

    final description = switch ((locked, on)) {
      (true, _) when lock == ShrinkLock.notCircle => l10n.shrinkLockNotCircle,
      (true, _) => l10n.shrinkLockTooSmall,
      (false, true) when finalRadius != null => l10n.shrinkDescOn(
        formatRadiusValue(startRadius.toDouble()),
        formatRadiusValue(finalRadius!.toDouble()),
      ),
      _ => l10n.shrinkDescOff,
    };

    return SettingSwitchCard(
      title: l10n.shrinkTitle,
      description: description,
      value: on,
      onChanged: canEdit && !locked ? onChanged : null,
      muted: locked,
      isDarkMode: isDarkMode,
    );
  }
}
