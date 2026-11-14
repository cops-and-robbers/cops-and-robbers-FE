import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/game_mode.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/i18n/role_names.dart';
import '../../../../core/widgets/cards/info_card.dart';
import '../../../../l10n/app_localizations.dart';

/// 최종 확인 맨 위 "모드 · 술래잡기 >" 행. 탭하면 모드 선택으로 돌아간다.
class ModeRowCard extends StatelessWidget {
  const ModeRowCard({super.key, required this.mode, this.onTap});

  final GameMode mode;

  /// null이면 읽기 전용 — 화살표를 감춘다.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: InfoCard(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.horizontal24,
          vertical: AppSpacing.vertical20,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.confirmRowMode,
              style: AppTextStyles.paragraph_14_100.copyWith(
                color: AppColors.black800,
              ),
            ),
            Row(
              children: [
                Text(
                  modeName(l10n, mode),
                  style: AppTextStyles.paragraph14Semibold.copyWith(
                    color: AppColors.black,
                  ),
                ),
                if (onTap != null) ...[
                  SizedBox(width: AppSpacing.horizontal8),
                  Transform.rotate(
                    angle: math.pi,
                    child: SvgPicture.asset(
                      AppIcons.previous,
                      width: 14.w,
                      height: 14.w,
                      colorFilter: const ColorFilter.mode(
                        AppColors.black300,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
