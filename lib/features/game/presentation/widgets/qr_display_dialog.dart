import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/buttons/app_button.dart';

/// 도둑 QR 코드 표시 다이얼로그
///
/// 도둑의 `participantId`를 QR 코드로 인코딩하여 화면에 표시한다.
/// 경찰이 이 QR을 스캔하여 체포를 수행한다.
///
/// QR 데이터 형식: `{"pid": <participantId>}`
class QrDisplayDialog extends StatelessWidget {
  const QrDisplayDialog({required this.participantId, super.key});

  /// 도둑의 참가자 ID
  final int participantId;

  /// 다이얼로그 표시
  static void show({
    required BuildContext context,
    required int participantId,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => QrDisplayDialog(participantId: participantId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final qrData = jsonEncode({'pid': participantId});

    return Dialog(
      backgroundColor: AppColors.black,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.xxlarge),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.horizontal24,
          vertical: AppSpacing.vertical28,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '수배 번호',
              style: AppTextStyles.robberHeading.copyWith(
                color: AppColors.green,
              ),
            ),
            SizedBox(height: AppSpacing.vertical20),

            // QR 코드
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: AppRadius.xlarge,
              ),
              child: QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 200.w,
                backgroundColor: AppColors.white,
              ),
            ),
            SizedBox(height: AppSpacing.vertical20),

            Text(
              '경찰에게 QR코드를 보여주세요',
              style: AppTextStyles.paragraph_14.copyWith(
                color: AppColors.black300,
              ),
            ),
            SizedBox(height: AppSpacing.vertical20),

            // 닫기 버튼
            SizedBox(
              width: double.infinity,
              child: AppButton(
                text: '닫기',
                onPressed: () => Navigator.of(context).pop(),
                backgroundColor: AppColors.green,
                foregroundColor: AppColors.black,
                showBorder: false,
                borderRadius: AppRadius.medium,
                textStyle: AppTextStyles.robberLabel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
