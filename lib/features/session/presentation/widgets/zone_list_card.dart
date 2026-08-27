import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/utils/zone_metric_formatter.dart';
import '../../../../core/widgets/cards/info_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../game/domain/entities/area_shape.dart';

/// 구역 목록 카드
///
/// 플레이그라운드, 감옥의 크기를 도형에 맞게 표시합니다.
/// 원형은 반경, 폴리곤은 면적으로 표시됩니다.
/// [onTap]이 제공되면 카드 전체를 탭하여 구역 설정 화면으로 이동할 수 있습니다.
///
/// 사용 예시:
/// ```dart
/// ZoneListCard(
///   area: gameArea,
///   onTap: () => navigateToZoneSetting(),
/// )
/// ```
class ZoneListCard extends StatelessWidget {
  const ZoneListCard({
    super.key,
    required this.area,
    this.onTap,
    this.onTapPlayground,
    this.onTapJail,
    this.isDarkMode = false,
  });

  /// 게임 구역 (플레이그라운드 + 감옥)
  final GameAreaEntity area;

  /// 카드 전체 탭 콜백 (호스트 전용 — 구역 수정 페이지 이동)
  final VoidCallback? onTap;

  /// 플레이그라운드 행 탭 콜백 (최종 확인 화면 — 해당 지도로 이동)
  final VoidCallback? onTapPlayground;

  /// 감옥 행 탭 콜백 (최종 확인 화면 — 해당 지도로 이동)
  final VoidCallback? onTapJail;

  /// 다크 모드 여부 (도둑팀)
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: InfoCard(
        title: l10n.sectionTitleZone,
        titleStyle: AppTextStyles.label_16.copyWith(
          color: isDarkMode ? AppColors.white : AppColors.black,
        ),
        titleTrailing: onTap != null
            ? Transform.rotate(
                angle: math.pi,
                child: SvgPicture.asset(
                  'assets/icons/icon_previous.svg',
                  width: 16.w,
                  height: 16.w,
                  colorFilter: ColorFilter.mode(
                    isDarkMode ? AppColors.black400 : AppColors.black300,
                    BlendMode.srcIn,
                  ),
                ),
              )
            : null,
        backgroundColor: isDarkMode ? AppColors.black900 : null,
        borderColor: isDarkMode ? AppColors.black800 : null,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.horizontal24,
          vertical: AppSpacing.vertical20,
        ),
        child: Column(
          children: [
            _ZoneItem(
              name: l10n.zonePlayground,
              shape: area.playground,
              isDarkMode: isDarkMode,
              onTap: onTapPlayground,
            ),
            SizedBox(height: AppSpacing.vertical12),
            _ZoneItem(
              name: l10n.zoneJail,
              shape: area.jail,
              isDarkMode: isDarkMode,
              onTap: onTapJail,
            ),
          ],
        ),
      ),
    );
  }
}

/// 구역 아이템 (내부 위젯)
class _ZoneItem extends StatelessWidget {
  const _ZoneItem({
    required this.name,
    required this.shape,
    this.isDarkMode = false,
    this.onTap,
  });

  final String name;
  final AreaShape shape;
  final bool isDarkMode;

  /// 행 탭 콜백. 주어지면 값 옆에 이동 표시가 붙는다.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: AppTextStyles.paragraph_14_100.copyWith(
              color: isDarkMode ? AppColors.black200 : AppColors.black800,
            ),
          ),
          Row(
            children: [
              Text(
                shape.metricText(l10n),
                style: AppTextStyles.paragraph14Semibold.copyWith(
                  color: isDarkMode ? AppColors.white : AppColors.black,
                ),
              ),
              if (onTap != null) ...[
                SizedBox(width: AppSpacing.horizontal8),
                Transform.rotate(
                  angle: math.pi,
                  child: SvgPicture.asset(
                    'assets/icons/icon_previous.svg',
                    width: 14.w,
                    height: 14.w,
                    colorFilter: ColorFilter.mode(
                      isDarkMode ? AppColors.black400 : AppColors.black300,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
