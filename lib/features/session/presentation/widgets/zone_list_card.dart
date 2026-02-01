import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/cards/info_card.dart';
import '../../domain/entities/zone_info.dart';

/// 구역 목록 카드
///
/// 플레이그라운드, 감옥 등 구역 정보를 표시하고,
/// 각 항목 클릭 시 해당 구역 설정 화면으로 이동합니다.
///
/// 사용 예시:
/// ```dart
/// ZoneListCard(
///   zones: [
///     ZoneInfo(id: '1', name: '플레이그라운드', radiusMeters: 400),
///     ZoneInfo(id: '2', name: '감옥', radiusMeters: 200),
///   ],
///   onZoneTap: (zoneId) => navigateToZoneSetting(zoneId),
/// )
/// ```
class ZoneListCard extends StatelessWidget {
  const ZoneListCard({super.key, required this.zones, this.onZoneTap});

  /// 구역 정보 리스트
  final List<ZoneInfo> zones;

  /// 구역 클릭 콜백
  final void Function(String zoneId)? onZoneTap;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      title: '구역',
      titleStyle: AppTextStyles.label_16.copyWith(color: AppColors.black),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.horizontal24,
        vertical: AppSpacing.vertical20,
      ),
      child: Column(
        children: [
          for (int i = 0; i < zones.length; i++) ...[
            if (i > 0) SizedBox(height: AppSpacing.vertical12),
            _ZoneItem(
              zone: zones[i],
              onTap: onZoneTap != null ? () => onZoneTap!(zones[i].id) : null,
            ),
          ],
        ],
      ),
    );
  }
}

/// 구역 아이템 (내부 위젯)
class _ZoneItem extends StatelessWidget {
  const _ZoneItem({required this.zone, this.onTap});

  final ZoneInfo zone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.medium,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            zone.name,
            style: AppTextStyles.paragraph_14_100.copyWith(
              color: AppColors.black800,
            ),
          ),
          Row(
            children: [
              Text(
                zone.displayDistance,
                style: AppTextStyles.paragraph14Semibold.copyWith(
                  color: AppColors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
