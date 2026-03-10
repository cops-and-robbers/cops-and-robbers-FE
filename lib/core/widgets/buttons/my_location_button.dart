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
    this.containerSize = 48,
    this.iconSize = 24,
    this.focusedColor = const Color(0xFF3F63D9),
    this.unfocusedColor = const Color(0xFF9FB1EC),
  });

  /// 버튼 클릭 시 실행될 콜백 (현재 위치로 카메라 이동)
  final VoidCallback onPressed;

  /// 현재 위치에 포커싱된 상태 여부
  final bool isFocused;

  /// 컨테이너 크기 (기본값: 48)
  final double containerSize;

  /// 아이콘 크기 (기본값: 24)
  final double iconSize;

  /// 포커싱 시 아이콘 색상 (기본: AppColors.blue)
  final Color focusedColor;

  /// 포커싱 해제 시 아이콘 색상 (기본: AppColors.blue500)
  final Color unfocusedColor;

  @override
  Widget build(BuildContext context) {
    return SvgIconButton(
      assetPath: 'assets/icons/mage_location-fill.svg',
      onPressed: onPressed,
      containerSize: containerSize,
      iconSize: iconSize,
      iconColor: isFocused ? focusedColor : unfocusedColor,
    );
  }
}
