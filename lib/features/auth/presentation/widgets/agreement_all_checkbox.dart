import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import 'agreement_checkbox.dart';

/// 약관 동의 화면의 "전체 동의" 카드
///
/// 4개 약관(필수 3종 + 선택 1종)을 일괄 토글합니다.
/// [checked]는 4개 모두 체크된 상태일 때만 true입니다.
class AgreementAllCheckbox extends StatelessWidget {
  const AgreementAllCheckbox({
    super.key,
    required this.checked,
    required this.onToggle,
  });

  final bool checked;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Row(
          children: [
            AgreementCheckbox(checked: checked, onTap: onToggle, size: 20),
            SizedBox(width: AppSpacing.horizontal8),
            Text(
              '전체 동의',
              style: AppTextStyles.label_16.copyWith(color: AppColors.black),
            ),
          ],
        ),
      ),
    );
  }
}
