import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/cards/info_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/zone_info.dart';

/// 구역 목록 카드
///
/// 플레이그라운드, 감옥 등 구역 정보를 표시합니다.
/// [onTap]이 제공되면 카드 전체를 탭하여 구역 설정 화면으로 이동할 수 있습니다.
///
/// 사용 예시:
/// ```dart
/// ZoneListCard(
///   zones: [
///     ZoneInfo(id: '1', name: '플레이그라운드', radiusMeters: 400),
///     ZoneInfo(id: '2', name: '감옥', radiusMeters: 200),
///   ],
///   onTap: () => navigateToZoneSetting(),
/// )
/// ```
class ZoneListCard extends StatelessWidget {
  const ZoneListCard({
    super.key,
    required this.zones,
    this.onTap,
    this.isDarkMode = false,
  });

  /// 구역 정보 리스트
  final List<ZoneInfo> zones;

  /// 카드 전체 탭 콜백 (호스트 전용 — 구역 수정 페이지 이동)
  final VoidCallback? onTap;

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
            for (int i = 0; i < zones.length; i++) ...[
              if (i > 0) SizedBox(height: AppSpacing.vertical12),
              _ZoneItem(zone: zones[i], isDarkMode: isDarkMode),
            ],
          ],
        ),
      ),
    );
  }
}

/// 구역 아이템 (내부 위젯)
class _ZoneItem extends StatelessWidget {
  const _ZoneItem({required this.zone, this.isDarkMode = false});

  final ZoneInfo zone;
  final bool isDarkMode;

  /// 화면 표시용 거리 문자열을 l10n 기반으로 생성
  ///
  /// 1000m 이상: "반경 1.50km"
  /// 미만: "반경 400m"
  String _displayDistance(AppLocalizations l10n) {
    if (zone.radiusMeters >= 1000) {
      final km = (zone.radiusMeters / 1000).toStringAsFixed(2);
      return l10n.zoneRadiusKm(km);
    }
    return l10n.zoneRadiusMeters(zone.radiusMeters.toString());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          zone.name,
          style: AppTextStyles.paragraph_14_100.copyWith(
            color: isDarkMode ? AppColors.black200 : AppColors.black800,
          ),
        ),
        Text(
          _displayDistance(l10n),
          style: AppTextStyles.paragraph14Semibold.copyWith(
            color: isDarkMode ? AppColors.white : AppColors.black,
          ),
        ),
      ],
    );
  }
}
