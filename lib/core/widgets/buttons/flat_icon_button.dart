import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../services/vibration_service.dart';

/// 배경·그림자 없는 플랫 SVG 아이콘 버튼
///
/// 상단바·툴바의 단순 탭 아이콘에 사용한다.
/// 흰색 배경 + 라운드 + 그림자가 필요한 경우는 [SvgIconButton]을 사용할 것.
///
/// **사용 예시**:
/// ```dart
/// // 다색 SVG라 iconColor는 지정하지 않고 원본 색상을 유지한다
/// FlatIconButton(
///   assetPath: 'assets/icons/icon_noti_off.svg',
///   onPressed: () => context.push(RoutePaths.notices),
/// )
/// ```
class FlatIconButton extends StatelessWidget {
  const FlatIconButton({
    super.key,
    required this.assetPath,
    required this.onPressed,
    this.iconSize = 24,
    this.tapSize = 42,
    this.iconColor,
    this.alignment = Alignment.center,
  });

  /// SVG 에셋 경로
  final String assetPath;

  /// 탭 시 실행될 콜백
  final VoidCallback onPressed;

  /// 아이콘 크기 (기본값: 24)
  final double iconSize;

  /// 정사각 탭 영역 크기 (기본값: 42, 최소 터치 영역 확보)
  final double tapSize;

  /// 아이콘 색상 (null이면 SVG 원본 색상 사용)
  final Color? iconColor;

  /// 탭 영역 내 아이콘 정렬 (기본값: 중앙)
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        VibrationService.instance().buttonTap();
        onPressed();
      },
      // 아이콘 주변 여백까지 탭 영역으로 잡아 터치 실패 방지
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: tapSize.w,
        height: tapSize.w,
        child: Align(
          alignment: alignment,
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
