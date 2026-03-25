import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 뒤로가기 버튼 위젯
///
/// SVG 아이콘을 사용한 통일된 뒤로가기 버튼.
/// 세션 생성 플로우 및 설정 페이지에서 사용됨.
///
/// **사용 예시**:
/// ```dart
/// PreviousButton(
///   onPressed: () => context.pop(),
///   size: 24,
/// )
/// ```
class PreviousButton extends StatelessWidget {
  const PreviousButton({
    super.key,
    required this.onPressed,
    this.size = 24,
    this.color,
  });

  /// 버튼 클릭 시 실행될 콜백
  final VoidCallback onPressed;

  /// 아이콘 크기 (기본값: 24)
  final double size;

  /// 아이콘 색상 (null이면 SVG 원본 색상 사용)
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: SvgPicture.asset(
        'assets/icons/icon_previous.svg',
        width: size,
        height: size,
        colorFilter: color != null
            ? ColorFilter.mode(color!, BlendMode.srcIn)
            : null,
      ),
      onPressed: onPressed,
    );
  }
}
