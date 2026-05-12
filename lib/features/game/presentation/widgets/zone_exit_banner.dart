import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';

/// 플레이그라운드 이탈 시 상단 슬림 배너
///
/// 디자인 톤은 게임 내 표준 알림인 [MarqueeAlertBanner]와 통일:
/// - 빨간 배경(`AppColors.red`) + `AppRadius.large` (12r)
/// - 외부 padding `AppPadding.horizontal20`, 내부 padding `h 16 / v 12`
/// - 텍스트 스타일 `paragraph14Semibold`(라이트) / `robberParagraph`(다크)
///
/// 차이점:
/// - 자동 닫기 없음 — 구역 복귀까지 표시 유지(상위에서 표시 토글)
/// - 마퀴 효과 없음 — 짧은 메시지라 불필요
///
/// 애니메이션 정책:
/// - 슬라이드 in/out은 본 위젯이 책임지지 않는다. 부모(`GamePage`)에서
///   `AnimatedSwitcher` + `SlideTransition`으로 enter/exit를 처리하므로
///   본 위젯은 정적인 시각 표현만 담는다.
///
/// UX 의도:
/// - 화면 가시성 최우선. 지도/내 위치/구역 경계는 절대 가리지 않는다.
/// - "구역 밖" 사실만 짧게 알리고, 복귀 유도는 펄스 보더·진동·지도 시각 정보가 담당.
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
            Icon(
              Icons.report_gmailerrorred_rounded,
              color: AppColors.white,
              size: 20.r,
            ),
            SizedBox(width: AppSpacing.horizontal8),
            Expanded(
              child: Text(
                '플레이그라운드를 벗어났어요',
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
