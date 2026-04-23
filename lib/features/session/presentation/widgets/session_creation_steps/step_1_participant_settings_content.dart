import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/inputs/app_slider.dart';

/// 세션 생성 Step 1: 인원 설정 컨텐츠
///
/// 게임 세션의 최대 참가자 수를 설정합니다.
/// AppSlider를 통해 2명부터 50명까지 설정 가능하며,
/// 값 변경 시 콜백으로 전달합니다.
class Step1ParticipantSettingsContent extends StatelessWidget {
  const Step1ParticipantSettingsContent({
    super.key,
    required this.maxParticipants,
    required this.onChanged,
    this.isDarkMode = false,
    this.valueTextStyle,
    this.maxParticipantsKey,
  });

  // ============================================
  // Properties
  // ============================================

  /// 최대 참가자 수 (2~50명)
  final int maxParticipants;

  /// 값 변경 콜백
  final ValueChanged<int> onChanged;

  /// 다크 모드 여부
  final bool isDarkMode;

  /// 값 텍스트 스타일 (null이면 기본 스타일)
  final TextStyle? valueTextStyle;

  /// 튜토리얼 하이라이트용 — 최대 참가자 슬라이더
  final GlobalKey? maxParticipantsKey;

  // ============================================
  // Build Methods
  // ============================================

  @override
  Widget build(BuildContext context) {
    return AppSlider(
      key: maxParticipantsKey,
      label: '최대 참가자',
      value: maxParticipants.toDouble(),
      min: 2,
      max: 50,
      unit: '명',
      divisions: 48, // 2~50, 1명 단위
      onChanged: (value) => onChanged(value.toInt()),
      isDarkMode: isDarkMode,
      valueColor: isDarkMode ? AppColors.white : null,
      valueTextStyle: valueTextStyle,
      editable: true,
    );
  }
}
