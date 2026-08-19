import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';

/// 앱 전역에서 사용하는 실선 구분선
class SolidDivider extends StatelessWidget {
  const SolidDivider({
    super.key,
    this.color = AppColors.black100,
    this.indent,
    this.endIndent,
  });

  final Color color;
  final double? indent;
  final double? endIndent;

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: color,
      height: 1.h,
      indent: indent,
      endIndent: endIndent,
    );
  }
}
