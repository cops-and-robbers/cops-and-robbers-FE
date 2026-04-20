import 'package:flutter/material.dart';

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
      child: Container(
        padding: AppPadding.all16,
        decoration: BoxDecoration(
          color: AppColors.black100,
          borderRadius: AppRadius.large,
        ),
        child: Row(
          children: [
            AgreementCheckbox(checked: checked, onTap: onToggle, size: 22),
            SizedBox(width: AppSpacing.horizontal12),
            Text(
              '전체 동의하기',
              style: AppTextStyles.label_16.copyWith(color: AppColors.black),
            ),
          ],
        ),
      ),
    );
  }
}
