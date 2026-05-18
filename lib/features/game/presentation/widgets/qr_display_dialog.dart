import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/game_config.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../domain/qr_payload.dart';

/// 도둑 QR 코드 표시 다이얼로그
///
/// 도둑의 `participantId`를 QR 코드로 인코딩하여 화면에 표시한다.
/// 경찰이 이 QR을 스캔하여 체포를 수행한다.
///
/// 다이얼로그가 열리는 시점에 [GameConfig.qrPayloadTtl] 만큼 유효한
/// 페이로드를 생성한다. 스캔되기 전에 시간이 지나면 만료되므로 스크린샷
/// 저장 후 재사용하는 리플레이 공격을 차단한다.
///
/// QR 데이터 형식: `{"pid": <participantId>, "exp": <만료시각 ms>}`
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
    // 다이얼로그가 열릴 때마다 TTL 30초짜리 신선한 페이로드 발급.
    // 닫고 다시 열면 자동으로 새 만료시각이 부여되어 자연스럽게 복구된다.
    final qrData = QrPayload.freshFor(
      participantId: participantId,
      now: DateTime.now(),
      ttl: GameConfig.qrPayloadTtl,
    ).toRaw();
    final l10n = AppLocalizations.of(context);

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
              l10n.gameQrDisplayTitle,
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
              l10n.gameQrDisplayMessage,
              style: AppTextStyles.paragraph_14.copyWith(
                color: AppColors.black300,
              ),
            ),
            SizedBox(height: AppSpacing.vertical20),

            // 닫기 버튼
            SizedBox(
              width: double.infinity,
              child: AppButton(
                text: l10n.buttonClose,
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
