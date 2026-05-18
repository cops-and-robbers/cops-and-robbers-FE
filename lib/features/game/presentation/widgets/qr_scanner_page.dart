import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/dialogs/app_dialog.dart';

/// 제네릭 QR 코드 스캐너 페이지
///
/// [T] 타입의 결과를 반환하는 범용 QR 스캐너.
/// [onParse] 콜백으로 QR 원본 문자열을 파싱하고,
/// non-null 결과 시 `Navigator.pop(context, result)`로 반환한다.
class QrScannerPage<T> extends StatefulWidget {
  const QrScannerPage({super.key, required this.title, required this.onParse});

  /// 상단에 표시할 안내 텍스트
  final String title;

  /// QR 원본 문자열 → 파싱 결과 콜백 (null 반환 시 무시)
  final T? Function(String rawValue) onParse;

  @override
  State<QrScannerPage<T>> createState() => _QrScannerPageState<T>();
}

class _QrScannerPageState<T> extends State<QrScannerPage<T>> {
  final MobileScannerController _controller = MobileScannerController();
  bool _hasScanned = false;
  bool _hasShownPermissionDialog = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;

    for (final barcode in capture.barcodes) {
      final rawValue = barcode.rawValue;
      if (rawValue == null) continue;

      final result = widget.onParse(rawValue);
      if (result != null) {
        _hasScanned = true;
        _controller.stop();
        Navigator.of(context).pop(result);
        return;
      }
    }
  }

  void _showPermissionDeniedDialog() {
    final l10n = AppLocalizations.of(context);
    AppDialog.show(
      context: context,
      title: l10n.dialogqrScannerPageTitle,
      message: l10n.dialogqrScannerPageMessage,
      confirmText: l10n.dialogqrScannerPageConfirm,
      cancelText: l10n.dialogqrScannerPageCancel,
      onConfirm: () => AppSettings.openAppSettings(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        children: [
          // 카메라 뷰파인더
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error) {
              // 카메라 권한 거부 시
              if (error.errorCode == MobileScannerErrorCode.permissionDenied) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && !_hasShownPermissionDialog) {
                    _hasShownPermissionDialog = true;
                    _showPermissionDeniedDialog();
                  }
                });
              }
              return Center(
                child: Text(
                  AppLocalizations.of(context).game_qrScannerPage_L90,
                  style: AppTextStyles.paragraph_14.copyWith(
                    color: AppColors.white,
                  ),
                ),
              );
            },
          ),

          // 스캔 가이드 오버레이
          _buildScanOverlay(),

          // 상단 안내 텍스트
          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(top: 80.h),
              child: Align(
                alignment: Alignment.topCenter,
                child: Text(
                  widget.title,
                  style: AppTextStyles.heading_20.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ),

          // 닫기 버튼 (좌상단)
          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.horizontal16,
                top: AppSpacing.vertical16,
              ),
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.close, color: AppColors.white, size: 28.w),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 스캔 영역 가이드 오버레이
  Widget _buildScanOverlay() {
    final scanAreaSize = 250.w;
    return Center(
      child: Container(
        width: scanAreaSize,
        height: scanAreaSize,
        decoration: BoxDecoration(
          borderRadius: AppRadius.xlarge,
          border: Border.all(color: AppColors.blue, width: 2.w),
        ),
      ),
    );
  }
}
