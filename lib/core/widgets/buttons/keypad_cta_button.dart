import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/text_styles.dart';

/// 숫자 키패드 바로 위에 붙는 전폭 버튼
///
/// 라운드와 여백 없이 키패드와 한 몸으로 보이는 것이 의도다 (시안: 394x56).
/// 방 생성의 다음·완료하기와 설정 수정의 저장이 같은 모양을 쓴다.
class KeypadCtaButton extends StatelessWidget {
  const KeypadCtaButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isDarkMode = false,
  });

  final String label;

  /// null 이면 비활성 상태로 그려진다
  final VoidCallback? onPressed;

  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final backgroundColor = enabled
        ? (isDarkMode ? AppColors.green : AppColors.blue)
        : (isDarkMode ? AppColors.black800 : AppColors.black200);
    // 비활성 다크는 대기실 시작 버튼과 같은 문법 (black800 면 + green 텍스트)
    final foregroundColor = enabled
        ? (isDarkMode ? AppColors.black : AppColors.white)
        : (isDarkMode ? AppColors.green : AppColors.black400);

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: 56.h,
        color: backgroundColor,
        alignment: Alignment.center,
        child: Text(
          label,
          style:
              (isDarkMode ? AppTextStyles.robberLabel : AppTextStyles.label_16)
                  .copyWith(color: foregroundColor),
        ),
      ),
    );
  }
}
