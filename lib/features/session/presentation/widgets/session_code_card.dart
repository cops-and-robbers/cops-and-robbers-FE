import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/services/vibration_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/snackbars/app_snackbar.dart';

/// 세션 코드 표시 및 복사 카드
///
/// 검은 배경에 흰색 텍스트로 세션 코드를 표시하고,
/// 카드 전체를 탭하면 진동과 함께 코드가 복사됩니다.
///
/// 사용 예시:
/// ```dart
/// SessionCodeCard(
///   code: 'A1B2C3',
///   onCopy: () => showSnackBar('복사되었습니다'),
/// )
/// ```
class SessionCodeCard extends StatelessWidget {
  const SessionCodeCard({super.key, required this.code, this.onCopy});

  /// 세션 코드
  final String code;

  /// 복사 성공 시 콜백
  final VoidCallback? onCopy;

  /// 클립보드에 코드 복사
  Future<void> _copyToClipboard(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: code));
    onCopy?.call();

    if (context.mounted) {
      AppSnackbar.show(
        context,
        message: '코드가 복사되었습니다',
        iconPath: 'assets/icons/icon_copy.svg',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        VibrationService.instance().buttonTap();
        _copyToClipboard(context);
      },
      borderRadius: AppRadius.xl20,
      child: Container(
        width: 353.w,
        height: 84.h,
        decoration: BoxDecoration(
          color: AppColors.black,
          borderRadius: AppRadius.xl20,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              code,
              style: AppTextStyles.semibold_28.copyWith(color: AppColors.white),
            ),
            SizedBox(width: AppSpacing.horizontal8),
            SvgPicture.asset(
              'assets/icons/icon_copy.svg',
              width: 24.w,
              height: 24.h,
              colorFilter: const ColorFilter.mode(
                AppColors.white,
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
