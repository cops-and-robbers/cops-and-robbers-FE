import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';

/// "OO님이 참여했어요" — 가운데 pill (spec 3-1: radius 24, blueVer2_70, tag_14 black700)
class CommunityChatSystemPill extends StatelessWidget {
  const CommunityChatSystemPill({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        // 앞 항목 bottom 2 + 이 top 12 = 14 — 말풍선 경계 간격과 같다.
        margin: EdgeInsets.only(top: 12.h, bottom: 2.h),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.horizontal12,
          vertical: 6.h,
        ),
        decoration: BoxDecoration(
          color: AppColors.blueVer2_70,
          borderRadius: AppRadius.xxlarge,
        ),
        child: Text(
          text,
          style: AppTextStyles.tag_14.copyWith(color: AppColors.black700),
        ),
      ),
    );
  }
}
