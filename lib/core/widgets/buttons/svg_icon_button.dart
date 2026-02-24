import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../constants/app_colors.dart';

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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: containerSize.w,
        height: containerSize.w,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(borderRadius.r),
          boxShadow: [
            BoxShadow(
              offset: const Offset(1, 1),
              blurRadius: 8,
              spreadRadius: 0,
              color: Colors.black.withValues(alpha: 0.1),
            ),
          ],
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
