import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/loading/custom_progress_bar.dart';
import '../../../../core/widgets/navigation/app_top_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/ar_capture_state.dart';

/// AR 포착 화면 (#655). 게임 화면처럼 상단바 아래에 게이지를 둔다.
///
/// 낮의 밝은 카메라 위에서도 읽히도록 문구는 상단바 안에 넣고,
/// 주변을 볼 수 있게 카메라 화면은 어둡게 하지 않는다.
class ArCaptureScene extends StatelessWidget {
  const ArCaptureScene({
    super.key,
    required this.camera,
    required this.state,
    required this.flipPicture,
    required this.missionCurrent,
    required this.missionTotal,
    required this.onClose,
    required this.onRetry,
  });

  /// 실기기에서 조정할 값: 화면 가로폭이 담는 각도 (라디안, 약 50도)
  static const double screenWidthRadians = 0.9;

  final Widget camera;
  final ArCaptureState state;
  final bool flipPicture;

  /// 포착 후 보여 줄 판 전체 미션 진행도
  final int missionCurrent;
  final int missionTotal;

  final VoidCallback onClose;
  final VoidCallback onRetry;

  double get _pictureSize => 110.w;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppTopBar(
        isDarkMode: true,
        leading: IconButton(
          onPressed: onClose,
          icon: Icon(Icons.close, color: AppColors.white, size: 28.w),
        ),
        titleWidget: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _message(l10n),
              style: AppTextStyles.subHeading_18.copyWith(
                color: AppColors.white,
              ),
            ),
            if (state.isCaptured)
              Text(
                l10n.arCaptureMissionProgress(missionCurrent, missionTotal),
                style: AppTextStyles.tag_12.copyWith(
                  color: AppColors.black400,
                ),
              ),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          final pxPerRadian = size.width / screenWidthRadians;
          // 그림이 판정 반경 안에 있을 때 틀 안에 들어와 보이는 크기
          final frameSize =
              _pictureSize + 2 * ArCaptureState.frameRadius * pxPerRadian;

          return Stack(
            fit: StackFit.expand,
            children: [
              camera,
              Center(
                child: Container(
                  width: frameSize,
                  height: frameSize,
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.xlarge,
                    border: Border.all(
                      color: state.inFrame || state.isCaptured
                          ? AppColors.green
                          : AppColors.white,
                      width: 3.w,
                    ),
                  ),
                ),
              ),
              _buildPicture(size, pxPerRadian),
              Align(
                alignment: Alignment.topCenter,
                child: CustomProgressBar(
                  width: size.width,
                  borderRadius: BorderRadius.zero,
                  // 포착하면 유지 게이지가 판 전체 미션 게이지로 바뀐다.
                  progress: state.isCaptured
                      ? missionCurrent / missionTotal
                      : state.heldSeconds / ArCaptureState.holdDuration,
                  fillColor: AppColors.green,
                  backgroundColor: AppColors.black800,
                  animationDuration: state.isCaptured
                      ? const Duration(milliseconds: 300)
                      : const Duration(milliseconds: 80),
                ),
              ),
              // 시험 화면에서 반복하려는 버튼. 게임에서는 잠시 후 지도로 돌아간다.
              if (state.isCaptured) _buildRetryButton(l10n),
            ],
          );
        },
      ),
    );
  }

  String _message(AppLocalizations l10n) {
    if (state.isCaptured) return l10n.arCaptureDone;
    if (state.inFrame) {
      final remaining = (ArCaptureState.holdDuration - state.heldSeconds)
          .ceil();
      return l10n.arCaptureHold(remaining);
    }
    if (state.isPhoneLowered) return l10n.arCaptureRaisePhone;
    return state.heldSeconds > 0 ? l10n.arCaptureRealign : l10n.arCaptureTitle;
  }

  /// 디자인 전 임시 그림. 화면 밖으로 나가면 가장자리에 붙어 방향을 알려 준다.
  Widget _buildPicture(Size size, double pxPerRadian) {
    final maxX = size.width / 2 - _pictureSize / 2;
    final maxY = size.height / 2 - _pictureSize / 2;
    final scale = state.isCaptured ? 1.25 : (state.inFrame ? 1.1 : 1.0);

    return Center(
      child: Transform.translate(
        offset: Offset(
          (state.yawOffset * pxPerRadian).clamp(-maxX, maxX),
          (state.pitchOffset * pxPerRadian).clamp(-maxY, maxY),
        ),
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 150),
          // 원본 그림은 오른쪽을 본다. 왼쪽으로 갈 때 뒤집는다.
          child: Transform.flip(
            flipX: flipPicture,
            child: SvgPicture.asset(
              'assets/characters/robber/start/default/ar_capture_example.svg',
              width: _pictureSize,
              height: _pictureSize,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRetryButton(AppLocalizations l10n) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.horizontal20,
          0,
          AppSpacing.horizontal20,
          AppSpacing.vertical40,
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: AppButton(text: l10n.buttonRetry, onPressed: onRetry),
        ),
      ),
    );
  }
}
