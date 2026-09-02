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
        margin: EdgeInsets.symmetric(vertical: 6.h),
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
