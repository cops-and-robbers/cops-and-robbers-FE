import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';

/// 플레이그라운드 이탈 시 상단 슬림 배너
///
/// 디자인 톤은 게임 내 표준 알림인 [MarqueeAlertBanner]와 통일:
/// - 빨간 배경(`AppColors.red`) + `AppRadius.large` (12r)
/// - 외부 padding `AppPadding.horizontal20`, 내부 padding `h 16 / v 12`
/// - 텍스트 스타일 `paragraph14Semibold`(라이트) / `robberParagraph`(다크)
/// - 아이콘: SVG 에셋 + `ColorFilter.mode(srcIn)` 패턴 (MarqueeAlertBanner와 동일)
///
/// 차이점:
/// - 자동 닫기 없음 — 구역 복귀까지 표시 유지(상위에서 표시 토글)
/// - 마퀴 효과 없음 — 짧은 메시지라 불필요
///
/// 애니메이션 정책:
/// - 슬라이드 in/out은 본 위젯이 책임지지 않는다. 부모(`GamePage`)에서
///   `AnimatedSwitcher` + `SlideTransition`으로 enter/exit를 처리하므로
///   본 위젯은 정적인 시각 표현만 담는다.
class ZoneExitBanner extends StatelessWidget {
  const ZoneExitBanner({super.key, required this.isDarkMode});

  /// 도둑(다크) 테마 여부
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final textStyle =
        (isDarkMode
                ? AppTextStyles.robberParagraph
                : AppTextStyles.paragraph14Semibold)
            .copyWith(color: AppColors.white);

    return Padding(
      padding: AppPadding.horizontal20,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.red,
          borderRadius: AppRadius.large,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.horizontal16,
          vertical: AppSpacing.vertical12,
        ),
        child: Row(
          children: [
            // 아이콘 — SVG 원본 색상은 ColorFilter(srcIn)로 흰색 덮어쓰기.
            // 가로/세로 동일 사이즈라 .r 권장 (디자인 시스템 일관성).
            SvgPicture.asset(
              'assets/icons/icon_zone_exit.svg',
              width: 20.r,
              height: 20.r,
              colorFilter: const ColorFilter.mode(
                AppColors.white,
                BlendMode.srcIn,
              ),
            ),
            SizedBox(width: AppSpacing.horizontal8),
            Expanded(
              child: Text(
                AppLocalizations.of(context).game_zoneExitBanner_L66,
                style: textStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
