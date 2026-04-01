import 'dart:convert';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/dialogs/app_dialog.dart';

/// 경찰용 QR 코드 스캐너 페이지
///
/// 카메라로 도둑의 QR 코드를 스캔하여 `participantId`를 추출한다.
/// 스캔 성공 시 `Navigator.pop(context, participantId)`로 결과를 반환한다.
class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
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

      final participantId = _parseQrData(rawValue);
      if (participantId != null) {
        _hasScanned = true;
        _controller.stop();
        Navigator.of(context).pop(participantId);
        return;
      }
    }
  }

  /// QR 데이터에서 participantId 추출
  ///
  /// 예상 형식: `{"pid": 505}`
  int? _parseQrData(String rawValue) {
    try {
      final json = jsonDecode(rawValue) as Map<String, dynamic>;
      final pid = json['pid'];
      if (pid is int) return pid;
      if (pid is num) return pid.toInt();
      return null;
    } catch (_) {
      return null;
    }
  }

  void _showPermissionDeniedDialog() {
    AppDialog.show(
      context: context,
      title: '카메라 권한 필요',
      message: 'QR코드를 스캔하려면 카메라 권한이 필요합니다.\n설정에서 카메라 권한을 허용해주세요.',
      confirmText: '설정으로 이동',
      cancelText: '닫기',
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
                  '카메라를 사용할 수 없습니다',
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
                  '도둑의 수배 QR을 스캔하세요',
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
