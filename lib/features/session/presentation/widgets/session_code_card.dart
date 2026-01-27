import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/buttons/copy_icon_button.dart';

/// 세션 코드 표시 및 복사 카드
///
/// 검은 배경에 흰색 텍스트로 세션 코드를 표시하고,
/// 복사 버튼을 제공합니다.
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('코드가 복사되었습니다'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
            style: AppTextStyles.semibold28.copyWith(color: AppColors.white),
          ),
          SizedBox(width: AppSpacing.horizontal8),
          CopyIconButton(
            iconPath: 'assets/icons/icon_copy.svg',
            size: 24.w,
            onTap: () => _copyToClipboard(context),
          ),
        ],
      ),
    );
  }
}
