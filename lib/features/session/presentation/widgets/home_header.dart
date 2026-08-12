import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/i18n/locale_brand_assets.dart';
import '../../../../core/widgets/buttons/flat_icon_button.dart';

/// 홈 상단 헤더 — 로고 + 공지 아이콘
///
/// 높이 124는 상태바를 포함한 값이라 [SafeArea] 밖에 두고, 내부에서 상태바
/// 높이를 흡수한 뒤 남은 영역에 내용을 세로 중앙 정렬한다.
/// 배경이 흰색이라 스캐폴드 배경([AppColors.background])과 구분된다.
class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key, required this.onNoticePressed});

  /// 공지 아이콘 탭 콜백
  final VoidCallback onNoticePressed;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);

    return Container(
      height: 125.h,
      color: AppColors.white,
      padding: EdgeInsets.only(
        left: AppSpacing.horizontal16,
        right: AppSpacing.horizontal18,
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 로케일별 워드마크 로고 — en은 세로 비중이 커 36, ko/ja는 18
            SvgPicture.asset(
              localizedAppLogo(locale),
              height: locale.languageCode == 'en'
                  ? 36.h
                  : AppSpacing.vertical18,
            ),
            // 공지 아이콘 — 다색 SVG라 iconColor를 주지 않는다(원본 색 유지).
            // centerRight로 정렬해 42 탭 영역 안에서 아이콘이 우측 패딩에 붙는다.
            FlatIconButton(
              assetPath: 'assets/icons/icon_noti_off.svg',
              iconSize: 24,
              onPressed: onNoticePressed,
              alignment: Alignment.centerRight,
            ),
          ],
        ),
      ),
    );
  }
}
