import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/utils/zone_metric_formatter.dart';
import '../../../../core/widgets/cards/info_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../game/domain/shrink_schedule.dart';

/// 구역 축소 켜고 끄기 카드 (#668)
///
/// 방 생성 확인 화면과 대기방 게임 설정이 같이 쓴다. [onChanged]가 null이면
/// 참가자용 읽기 전용이다 — 같은 스위치를 누를 수 없게 보여 주고, 고칠 수 없는
/// 사람에게 잠금 안내("구역이 작아서…")는 띄우지 않는다.
class ShrinkToggleCard extends StatelessWidget {
  /// 누를 수 없는 스위치를 흐리게 보이는 정도 (#668 시안 2-waiting-settings-v3)
  static const double _disabledOpacity = 0.4;

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

    final titleColor = locked
        ? AppColors.black400
        : (isDarkMode ? AppColors.white : AppColors.black);
    final descColor = locked
        ? AppColors.black400
        : (isDarkMode ? AppColors.black400 : AppColors.black600);

    return InfoCard(
      backgroundColor: isDarkMode ? AppColors.black900 : null,
      borderColor: isDarkMode ? AppColors.black800 : null,
      padding: EdgeInsets.symmetric(
        vertical: AppSpacing.vertical20,
        horizontal: AppSpacing.horizontal24,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.shrinkTitle,
                  style: AppTextStyles.label_16.copyWith(color: titleColor),
                ),
                SizedBox(height: AppSpacing.vertical8),
                Text(
                  description,
                  style: AppTextStyles.tag_12.copyWith(color: descColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.horizontal12),
          // 누를 수 없을 때(참가자·잠금)는 토큰 색 그대로 위젯째 흐리게 한다 — 색 투명도 금지(ui-design-system)
          _dimUnlessEditable(
            editable: canEdit && !locked,
            Switch(
              value: on,
              onChanged: canEdit && !locked ? onChanged : null,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              // 팀과 상관없이 라이트 시안과 같은 색(마이페이지 토글과 동일, 사용자 결정 2026-11-08).
              // 비활성이어도 머티리얼 회색이 아니라 이 토큰으로 그린다
              trackColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? AppColors.blueVer2Basic
                    : AppColors.black200,
              ),
              thumbColor: const WidgetStatePropertyAll(AppColors.white),
              trackOutlineColor: const WidgetStatePropertyAll(
                AppColors.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dimUnlessEditable(Widget child, {required bool editable}) =>
      editable ? child : Opacity(opacity: _disabledOpacity, child: child);
}
