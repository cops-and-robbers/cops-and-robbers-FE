import 'package:flutter/material.dart';

import '../../../../../core/widgets/inputs/app_slider.dart';

/// 세션 생성 Step 1: 인원 설정 컨텐츠
///
/// 게임 세션의 최대 참가자 수를 설정합니다.
/// AppSlider를 통해 5명부터 50명까지 설정 가능하며,
/// 값 변경 시 콜백으로 전달합니다.
class Step1ParticipantSettingsContent extends StatelessWidget {
  const Step1ParticipantSettingsContent({
    super.key,
    required this.maxParticipants,
    required this.onChanged,
  });

  // ============================================
  // Properties
  // ============================================

  /// 최대 참가자 수 (5~50명)
  final int maxParticipants;

  /// 값 변경 콜백
  final ValueChanged<int> onChanged;

  // ============================================
  // Build Methods
  // ============================================

  @override
  Widget build(BuildContext context) {
    return AppSlider(
      label: '최대 참가자',
      value: maxParticipants.toDouble(),
      min: 5,
      max: 50,
      unit: '명',
      divisions: 45, // 5~50, 1명 단위
      onChanged: (value) => onChanged(value.toInt()),
    );
  }
}
