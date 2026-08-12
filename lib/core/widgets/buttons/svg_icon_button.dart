import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_shadows.dart';
import '../../services/vibration_service.dart';

/// SVG 아이콘을 감싼 컨테이너 버튼
///
/// 흰색 배경 + 라운드 + 그림자가 적용된 SVG 아이콘 버튼.
/// 홈 화면 아이콘 버튼 등에서 사용됨.
///
/// **사용 예시**:
/// ```dart
/// SvgIconButton(
///   assetPath: 'assets/icons/Loudspeaker.svg',
///   onPressed: () => context.push('/notices'),
/// )
/// ```
class SvgIconButton extends StatelessWidget {
  const SvgIconButton({
    super.key,
    required this.assetPath,
    required this.onPressed,
    this.containerSize = 56,
    this.iconSize = 32,
    this.borderRadius = 16,
    this.iconColor,
    this.backgroundColor,
    this.isDarkMode = false,
  });

  /// SVG 에셋 경로
  final String assetPath;

  /// 버튼 클릭 시 실행될 콜백
  final VoidCallback onPressed;

  /// 컨테이너 크기 (기본값: 56)
  final double containerSize;

  /// 아이콘 크기 (기본값: 32)
  final double iconSize;

  /// 모서리 반경 (기본값: 16)
  final double borderRadius;

  /// 아이콘 색상 (null이면 SVG 원본 색상 사용)
  final Color? iconColor;

  /// 컨테이너 배경색 (null이면 AppColors.white)
  final Color? backgroundColor;

  /// 다크 모드 여부 (그림자 색상 전환)
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        VibrationService.instance().buttonTap();
        onPressed();
      },
      child: Container(
        width: containerSize.w,
        height: containerSize.w,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.white,
          borderRadius: BorderRadius.circular(borderRadius.r),
          boxShadow: AppShadows.softThemed(isDarkMode),
        ),
        child: Center(
          child: SvgPicture.asset(
            assetPath,
            width: iconSize.w,
            height: iconSize.w,
            colorFilter: iconColor != null
                ? ColorFilter.mode(iconColor!, BlendMode.srcIn)
                : null,
          ),
        ),
      ),
    );
  }
}
