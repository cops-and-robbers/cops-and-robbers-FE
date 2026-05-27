import 'package:flutter/material.dart';

import 'svg_icon_button.dart';

/// 현재 위치로 이동하는 지도 버튼
///
/// [isFocused]에 따라 아이콘 색상이 전환됨:
/// - focused: [focusedColor] (현재 위치에 포커싱된 상태)
/// - unfocused: [unfocusedColor] (지도를 드래그하여 포커싱 해제)
class MyLocationButton extends StatelessWidget {
  const MyLocationButton({
    super.key,
    required this.onPressed,
    required this.isFocused,
    this.containerSize = 56,
    this.iconSize = 32,
    this.focusedColor,
    this.unfocusedColor,
    this.backgroundColor,
    this.isDarkMode = false,
  });

  /// 버튼 클릭 시 실행될 콜백 (현재 위치로 카메라 이동)
  final VoidCallback onPressed;

  /// 현재 위치에 포커싱된 상태 여부
  final bool isFocused;

  /// 컨테이너 크기 (기본값: 56)
  final double containerSize;

  /// 아이콘 크기 (기본값: 32 )
  final double iconSize;

  /// 포커싱 시 아이콘 색상 (null이면 SVG 원본 색상 사용)
  final Color? focusedColor;

  /// 포커싱 해제 시 아이콘 색상 (null이면 SVG 원본 색상 사용)
  final Color? unfocusedColor;

  /// 컨테이너 배경색 (null이면 SvgIconButton 기본값 사용)
  final Color? backgroundColor;

  /// 다크 모드 여부 (그림자 색상 전환)
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return SvgIconButton(
      assetPath: 'assets/icons/mage_location-fill.svg',
      onPressed: onPressed,
      containerSize: containerSize,
      iconSize: iconSize,
      iconColor: isFocused ? focusedColor : unfocusedColor,
      backgroundColor: backgroundColor,
      isDarkMode: isDarkMode,
    );
  }
}
