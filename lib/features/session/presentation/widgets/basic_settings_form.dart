import 'package:flutter/material.dart';

import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/widgets/buttons/keypad_cta_button.dart';
import '../../../../core/widgets/inputs/number_pad.dart';
import '../../../../core/services/vibration_service.dart';
import '../../../../l10n/app_localizations.dart';
import 'game_setting_values_editor.dart';
import 'setting_field_card.dart';

/// 최종 확인 화면에서 설정 한 항목을 고치는 폼
///
/// 네 항목이 모두 펼쳐진 채 [editTarget]만 키패드가 겨냥하고, 확인 버튼 한 번으로
/// 되돌아간다. 다른 카드를 탭하면 그 항목으로 과녁을 옮긴다. 키패드는 화면에
/// 고정되어 닫히지 않는다.
class BasicSettingsForm extends StatefulWidget {
  const BasicSettingsForm({
    super.key,
    required this.initialParticipants,
    required this.initialRoundDuration,
    required this.initialLocationShare,
    required this.initialPoliceWait,
    required this.editTarget,
    required this.onSubmit,
  });

  final int initialParticipants;
  final int initialRoundDuration;
  final int initialLocationShare;
  final int initialPoliceWait;

  /// 최종 확인 화면에서 고치러 들어온 항목
  final GameSettingField editTarget;

  /// 확인 버튼을 눌렀을 때
  final ValueChanged<GameSettingValues> onSubmit;

  @override
  State<BasicSettingsForm> createState() => _BasicSettingsFormState();
}

class _BasicSettingsFormState extends State<BasicSettingsForm> {
  late final GameSettingValues _values;

  @override
  void initState() {
    super.initState();
    _values = GameSettingValues(
      participants: widget.initialParticipants,
      roundDuration: widget.initialRoundDuration,
      locationShare: widget.initialLocationShare,
      policeWait: widget.initialPoliceWait,
      // 고치러 들어온 값은 제안값이 아니라 이미 정한 값이다
      touched: true,
    )..activate(widget.editTarget);
  }

  /// 숫자 입력. 상한에 막히면 안내 힌트와 함께 더 무거운 진동으로 알린다.
  void _onDigit(int digit) {
    setState(() => _values.inputDigit(digit));
    if (_values.lastInputExceededMax) VibrationService.instance().longPress();
  }

  void _onQuickAdd(int amount) {
    setState(() => _values.quickAdd(amount));
    if (_values.lastInputExceededMax) VibrationService.instance().longPress();
  }

  // ============================================
  // Build
  // ============================================

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final active = _values.active;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.horizontal20,
              vertical: AppSpacing.vertical4,
            ),
            child: Column(
              children: [
                // 입력 순서의 역순 (마지막 항목이 맨 위)
                for (final field in GameSettingField.values.reversed) ...[
                  _buildCard(l10n, field),
                  SizedBox(height: AppSpacing.vertical8),
                ],
              ],
            ),
          ),
        ),
        KeypadCtaButton(
          label: l10n.buttonConfirm,
          onPressed: _values.allValid ? () => widget.onSubmit(_values) : null,
        ),
        NumberPad(
          quickAmounts: active.quickAmounts,
          unit: settingFieldUnit(l10n, active),
          onDigit: _onDigit,
          onQuickAdd: _onQuickAdd,
          onBackspace: () => setState(_values.backspace),
        ),
      ],
    );
  }

  Widget _buildCard(AppLocalizations l10n, GameSettingField field) {
    final isActive = field == _values.active;
    final hint = settingFieldHint(l10n, _values, field);
    final isPolice = field == GameSettingField.policeWait;

    return SettingFieldCard(
      label: settingFieldLabel(l10n, field),
      value: '${_values[field]}${settingFieldUnit(l10n, field)}',
      valuePrefix: isPolice ? l10n.gameSettingPoliceStartPrefix : null,
      valueSuffix: isPolice ? l10n.gameSettingPoliceStartSuffix : null,
      hint: hint?.$1,
      isHintWarning: hint?.$2 ?? false,
      isActive: isActive,
      isValueDimmed: isActive && !_values.isTouched(field),
      onTap: isActive ? null : () => setState(() => _values.activate(field)),
    );
  }
}
