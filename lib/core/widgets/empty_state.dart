import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/app_colors.dart';
import '../constants/app_icons.dart';
import '../constants/spacing_and_radius.dart';
import '../constants/text_styles.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(AppIcons.notFound, width: 80.w),
        SizedBox(height: AppSpacing.vertical16),
        Text(
          message,
          style: AppTextStyles.paragraph_14.copyWith(color: AppColors.black600),
        ),
      ],
    );
  }
}
