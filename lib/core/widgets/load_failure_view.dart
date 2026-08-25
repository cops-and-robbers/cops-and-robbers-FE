import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/spacing_and_radius.dart';
import '../constants/text_styles.dart';
import 'buttons/app_button.dart';

/// 무언가를 불러오지 못했을 때 보여주는 화면
///
/// 아이콘, 사유, 다시 시도 버튼으로 이루어집니다. 약관 화면과 약관 설정 화면이 같은
/// 모양을 각자 그리고 있어서 하나로 모았습니다.
///
/// 불러오기가 실패한 경우에만 씁니다. 불러오기는 됐는데 값이 비어 있는 경우는
/// [EmptyState] 입니다.
class LoadFailureView extends StatelessWidget {
  const LoadFailureView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  /// 왜 못 불러왔는지
  final String message;

  /// 다시 시도 버튼을 눌렀을 때
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppPadding.all20,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 40, color: AppColors.black400),
          SizedBox(height: AppSpacing.vertical16),
          Text(
            message,
            style: AppTextStyles.paragraph_14.copyWith(
              color: AppColors.black600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.vertical16),
          AppButton(
            text: AppLocalizations.of(context).buttonRetry,
            onPressed: onRetry,
            showBorder: false,
          ),
        ],
      ),
    );
  }
}
