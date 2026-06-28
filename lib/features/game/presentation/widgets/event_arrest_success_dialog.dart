import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/dialogs/dialog_animation.dart';

/// 이벤트 모드 — 운영진 체포 성공 피드백 다이얼로그(증거 공개).
///
/// 체포 순서(=누적 검거 수)로 `assets/events/evidence{N}.png`를 공개한다.
/// 에셋은 evidence1~3 고정이라 인덱스를 3으로 cap. 경찰 화면 전용(라이트 테마).
class EventArrestSuccessDialog extends StatelessWidget {
  const EventArrestSuccessDialog({
    required this.evidenceIndex,
    required this.robberNickname,
    super.key,
  });

  /// 공개할 증거 인덱스 (1부터 시작, 3 초과 시 3으로 clamp).
  final int evidenceIndex;

  /// 체포된 운영진 닉네임.
  final String robberNickname;

  /// 다이얼로그 호출 헬퍼.
  ///
  /// [evidenceIndex]와 [robberNickname]을 받아 스케일+페이드 애니메이션으로 표시.
  /// 배리어 탭 시 닫힘(barrierDismissible: true).
  static Future<void> show({
    required BuildContext context,
    required int evidenceIndex,
    required String robberNickname,
  }) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: DialogAnimation.barrierColor,
      transitionDuration: DialogAnimation.duration,
      pageBuilder: (_, _, _) => EventArrestSuccessDialog(
        evidenceIndex: evidenceIndex,
        robberNickname: robberNickname,
      ),
      transitionBuilder: DialogAnimation.buildTransition,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // 에셋은 evidence1~3만 존재하므로 범위 밖 값을 안전하게 처리
    final slot = evidenceIndex.clamp(1, 3);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: AppPadding.horizontal36,
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.xxlarge,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 타이틀: "운영진 검거"
            Text(
              l10n.gameEventArrestSuccessTitle,
              style: AppTextStyles.heading_20.copyWith(color: AppColors.black),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.vertical12),
            // 증거 이미지 슬롯 — ValueKey로 테스트에서 slot 값 검증
            SizedBox(
              key: ValueKey('event_evidence_$slot'),
              // 증거3은 그림이 작아 다이얼로그에서도 더 크게 표시
              width: slot == 3 ? 210.w : 160.w,
              height: slot == 3 ? 210.w : 160.w,
              child: Image.asset(
                'assets/events/evidence$slot.png',
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: AppSpacing.vertical12),
            // 체포 성공 메시지: "{nickname} 검거 성공"
            Text(
              l10n.gameEventArrestSuccessMessage(robberNickname),
              style: AppTextStyles.paragraph_14.copyWith(
                color: AppColors.black600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.vertical20),
            // 확인 버튼
            AppButton(
              text: l10n.gameEventArrestSuccessConfirm,
              onPressed: () => Navigator.of(context).pop(),
              backgroundColor: AppColors.blue,
              foregroundColor: AppColors.white,
              borderRadius: AppRadius.medium,
              showBorder: false,
              height: 48.h,
            ),
          ],
        ),
      ),
    );
  }
}
