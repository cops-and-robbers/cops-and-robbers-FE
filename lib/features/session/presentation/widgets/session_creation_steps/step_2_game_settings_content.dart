import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/spacing_and_radius.dart';
import '../../../../../core/widgets/inputs/app_slider.dart';
import '../../../../../l10n/app_localizations.dart';

/// 세션 생성 Step 2: 게임 설정 컨텐츠
///
/// 게임 규칙을 설정합니다:
/// - 라운드 제한 시간 (10~180분)
/// - 위치 공유 간격 (0~30분)
/// - 경찰 출동 시간 (도둑 도망 후 0~10분 뒤)
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
    this.valueTextStyle,
    this.settingsKey,
  });

  // ============================================
  // Properties
  // ============================================

  /// 라운드 제한 시간 (분)
  final int roundDurationMinutes;

  /// 위치 공유 간격 (분)
  final int locationShareMinutes;

  /// 경찰 출동 시간 (분, 도둑 도망 후)
  final int policeWaitMinutes;

  /// 라운드 시간 변경 콜백
  final ValueChanged<int> onRoundDurationChanged;

  /// 위치 공유 간격 변경 콜백
  final ValueChanged<int> onLocationShareChanged;

  /// 경찰 대기 시간 변경 콜백
  final ValueChanged<int> onPoliceWaitChanged;

  /// 다크 모드 여부
  final bool isDarkMode;

  /// 값 텍스트 스타일 오버라이드 (null이면 AppSlider 기본값 사용)
  ///
  /// 다크모드(도둑 팀)에서 Moneygraphy 글꼴을 적용하기 위한 prop.
  /// Step 1과 동일한 시그니처를 유지한다.
  final TextStyle? valueTextStyle;

  /// 튜토리얼 하이라이트용 — 슬라이더 3개를 묶은 컨테이너 키
  ///
  /// 세 슬라이더 UI가 동일하므로 각각 하이라이트하지 않고 하나로 묶어 안내한다.
  final GlobalKey? settingsKey;

  // ============================================
  // Build Methods
  // ============================================

  @override
  Widget build(BuildContext context) {
    debugPrint('🔍 Step2 isDarkMode: $isDarkMode');
    final l10n = AppLocalizations.of(context);
    return Column(
      key: settingsKey,
      children: [
        // 라운드 제한 시간
        AppSlider(
          label: l10n.fieldstep2GameSettingsContentLabel,
          value: roundDurationMinutes.toDouble(),
          min: 10,
          max: 180,
          unit: l10n.session_step2GameSettingsContent_L79,
          divisions: 170, // 10~180, 1분 단위
          onChanged: (value) => onRoundDurationChanged(value.toInt()),
          isDarkMode: isDarkMode,
          valueColor: isDarkMode ? AppColors.white : null,
          valueTextStyle: valueTextStyle,
          editable: true,
        ),

        SizedBox(height: AppSpacing.vertical8),

        // 위치 공유 간격
        AppSlider(
          label: l10n.fieldstep2GameSettingsContentLabel5ab2,
          value: locationShareMinutes.toDouble(),

          min: 0,
          max: 30,
          unit: l10n.session_step2GameSettingsContent_L97,
          divisions: 30, // 1~30, 1분 단위
          onChanged: (value) => onLocationShareChanged(value.toInt()),
          isDarkMode: isDarkMode,
          valueColor: isDarkMode ? AppColors.white : null,
          valueTextStyle: valueTextStyle,
          editable: true,
          warningText: locationShareMinutes == 0
              ? l10n.session_step2GameSettingsContent_L104
              : null,
        ),

        SizedBox(height: AppSpacing.vertical8),

        // 경찰 출동 시간 (도둑 도망 후)
        AppSlider(
          label: l10n.fieldstep2GameSettingsContentLabelCe3b,
          value: policeWaitMinutes.toDouble(),
          min: 1,
          max: 10,
          unit: l10n.session_step2GameSettingsContent_L115,
          divisions: 9, // 1~10, 1분 단위
          // ARB는 양 끝 공백 없음 → 표시 시 공백 보강 (원본 UI 유지)
          displayPrefix: '${l10n.session_step2GameSettingsContent_L117} ',
          displaySuffix: ' ${l10n.session_step2GameSettingsContent_L118}',
          onChanged: (value) => onPoliceWaitChanged(value.toInt()),
          isDarkMode: isDarkMode,
          valueColor: isDarkMode ? AppColors.white : null,
          valueTextStyle: valueTextStyle,
          editable: true,
        ),
      ],
    );
  }
}
