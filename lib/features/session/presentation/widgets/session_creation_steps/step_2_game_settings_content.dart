import 'package:flutter/material.dart';

import '../../../../../core/constants/spacing_and_radius.dart';
import '../../../../../core/widgets/inputs/app_slider.dart';

/// 세션 생성 Step 2: 게임 설정 컨텐츠
///
/// 게임 규칙을 설정합니다:
/// - 라운드 제한 시간 (10~180분)
/// - 위치 공유 간격 (0~30분)
/// - 경찰 시작 시간 (도둑 시작 후 0~10분 뒤)
class Step2GameSettingsContent extends StatelessWidget {
  const Step2GameSettingsContent({
    super.key,
    required this.roundDurationMinutes,
    required this.locationShareMinutes,
    required this.policeWaitMinutes,
    required this.onRoundDurationChanged,
    required this.onLocationShareChanged,
    required this.onPoliceWaitChanged,
    this.isDarkMode = false,
    this.roundDurationKey,
    this.locationShareKey,
    this.policeWaitKey,
  });

  // ============================================
  // Properties
  // ============================================

  /// 라운드 제한 시간 (분)
  final int roundDurationMinutes;

  /// 위치 공유 간격 (분)
  final int locationShareMinutes;

  /// 경찰 시작 시간 (분, 도둑 시작 후)
  final int policeWaitMinutes;

  /// 라운드 시간 변경 콜백
  final ValueChanged<int> onRoundDurationChanged;

  /// 위치 공유 간격 변경 콜백
  final ValueChanged<int> onLocationShareChanged;

  /// 경찰 대기 시간 변경 콜백
  final ValueChanged<int> onPoliceWaitChanged;

  /// 다크 모드 여부
  final bool isDarkMode;

  /// 튜토리얼 하이라이트용 — 라운드 제한 시간 슬라이더
  final GlobalKey? roundDurationKey;

  /// 튜토리얼 하이라이트용 — 위치 공유 간격 슬라이더
  final GlobalKey? locationShareKey;

  /// 튜토리얼 하이라이트용 — 경찰 시작 시간 슬라이더
  final GlobalKey? policeWaitKey;

  // ============================================
  // Build Methods
  // ============================================

  @override
  Widget build(BuildContext context) {
    debugPrint('🔍 Step2 isDarkMode: $isDarkMode');
    return Column(
      children: [
        // 라운드 제한 시간
        AppSlider(
          key: roundDurationKey,
          label: '라운드 제한 시간',
          value: roundDurationMinutes.toDouble(),
          min: 10,
          max: 180,
          unit: '분',
          divisions: 170, // 10~180, 1분 단위
          onChanged: (value) => onRoundDurationChanged(value.toInt()),
          isDarkMode: isDarkMode,
          editable: true,
        ),

        SizedBox(height: AppSpacing.vertical8),

        // 위치 공유 간격
        AppSlider(
          key: locationShareKey,
          label: '위치 공유 간격',
          value: locationShareMinutes.toDouble(),
          min: 0,
          max: 30,
          unit: '분',
          divisions: 30, // 0~30, 1분 단위
          onChanged: (value) => onLocationShareChanged(value.toInt()),
          isDarkMode: isDarkMode,
          editable: true,
        ),

        SizedBox(height: AppSpacing.vertical8),

        // 경찰 시작 시간 (도둑 시작 후)
        AppSlider(
          key: policeWaitKey,
          label: '경찰 시작 시간',
          value: policeWaitMinutes.toDouble(),
          min: 1,
          max: 10,
          unit: '분',
          divisions: 9, // 1~10, 1분 단위
          displayPrefix: "도둑 시작 후 ",
          displaySuffix: " 뒤",
          onChanged: (value) => onPoliceWaitChanged(value.toInt()),
          isDarkMode: isDarkMode,
          editable: true,
        ),
      ],
    );
  }
}
