import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 복사 아이콘 버튼 컴포넌트
///
/// SVG 아이콘과 탭 액션을 제공합니다.
///
/// 사용 예시:
/// ```dart
/// CopyIconButton(
///   iconPath: 'assets/icons/icon_copy.svg',
///   size: 24,
///   color: Colors.white,
///   onTap: () => copyToClipboard(),
/// )
/// ```
class CopyIconButton extends StatelessWidget {
  const CopyIconButton({
    super.key,
    required this.iconPath,
    this.size = 24.0,
    this.color,
    required this.onTap,
  });

  /// SVG 아이콘 경로
  final String iconPath;

  /// 아이콘 크기
  final double size;

  /// 아이콘 색상
  final Color? color;

  /// 탭 콜백
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(size / 2),
      child: SizedBox(
        width: size,
        height: size,
        child: SvgPicture.asset(
          iconPath,
          width: size,
          height: size,
          colorFilter: color != null
              ? ColorFilter.mode(color!, BlendMode.srcIn)
              : null,
        ),
      ),
    );
  }
}
