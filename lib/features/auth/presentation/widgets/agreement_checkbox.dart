import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';

/// 약관 동의 화면 전용 체크박스 (기본 20x20)
///
/// - 체크: 배경 [AppColors.black], 흰색 체크 마크
/// - 미체크: 배경 [AppColors.white], 테두리 [AppColors.black300]
/// - `readOnly=true`: 탭 무시 + 배경색 `AppColors.black400`로 흐리게 (설정 화면에서
///   필수 약관을 해제 불가능함을 시각적으로 전달)
class AgreementCheckbox extends StatelessWidget {
  const AgreementCheckbox({
    super.key,
    required this.checked,
    required this.onTap,
    this.size = 20,
    this.readOnly = false,
  });

  final bool checked;
  final VoidCallback onTap;
  final double size;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final Color fillColor;
    if (checked) {
      fillColor = readOnly ? AppColors.black400 : AppColors.black;
    } else {
      fillColor = AppColors.white;
    }

    return GestureDetector(
      onTap: readOnly ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: size.w,
        height: size.w,
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(6.r),
          border: checked
              ? null
              : Border.all(color: AppColors.black300, width: 1.5),
        ),
        child: checked
            ? Icon(Icons.check, color: AppColors.white, size: (size - 4).w)
            : null,
      ),
    );
  }
}
