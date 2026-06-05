import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';

/// 맵 롱프레스 시 좌표 위에 뜨는 핑 종류 선택 카드
///
/// 발견/의심을 개별 [GestureDetector]로 받는다(맵 Marker가 아닌 Flutter 오버레이).
/// 팀 테마는 [isDarkMode] prop으로 전파(UI_Design_System 표준).
class PingSelectionCard extends StatelessWidget {
  const PingSelectionCard({
    super.key,
    required this.isDarkMode,
    required this.onFound,
    required this.onSuspect,
  });

  final bool isDarkMode;
  final VoidCallback onFound;
  final VoidCallback onSuspect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = isDarkMode ? 'darkmode' : 'lightmode';
    final cardColor = isDarkMode ? AppColors.black : AppColors.blue;
    final dividerColor = isDarkMode ? AppColors.black800 : AppColors.blue800;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          // 카드 padding은 각 셀(_cell)의 Padding으로 옮겨 탭 영역을 넓힌다.
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: AppRadius.medium,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _cell(
                iconAsset: 'assets/icons/icon_ping_found_select_$theme.svg',
                label: l10n.pingFound,
                onTap: onFound,
              ),
              // divider는 좌우 셀의 Padding이 간격을 만들어 주므로 margin 불필요.
              Container(
                width: 2.w,
                height: AppSpacing.vertical40,
                decoration: BoxDecoration(
                  color: dividerColor,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              _cell(
                iconAsset: 'assets/icons/icon_ping_suspect_select_$theme.svg',
                label: l10n.pingSuspect,
                onTap: onSuspect,
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.vertical4),
        SvgPicture.asset(
          'assets/icons/icon_ping_pin_$theme.svg',
          width: 20.w,
          height: 32.h,
        ),
      ],
    );
  }

  Widget _cell({
    required String iconAsset,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        // 기존 카드 padding(좌우16/상하8) + divider margin(16)을 셀로 흡수.
        // → 아이콘/텍스트 주변 여백과 divider 경계까지 탭 영역이 확장된다.
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.horizontal16,
          vertical: AppSpacing.vertical8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(iconAsset, width: 24.w, height: 24.w),
            SizedBox(height: AppSpacing.vertical4),
            Text(
              label,
              style: AppTextStyles.tag_12.copyWith(
                color: isDarkMode ? AppColors.green : AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
