import 'package:flutter/material.dart';

import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/widgets/buttons/keypad_cta_button.dart';
import '../../../../core/widgets/inputs/number_pad.dart';
import '../../../../core/services/vibration_service.dart';
import '../../../../l10n/app_localizations.dart';
import 'game_setting_values_editor.dart';
import 'setting_field_card.dart';

/// 기본 정보 입력 폼 (한 항목씩 묻고 아래로 쌓기)
///
/// 새 질문이 위에 나타나고 답한 항목이 아래로 밀린다. 키패드는 화면에 고정되어
/// 닫히지 않으며, 답한 카드를 탭하면 키패드가 그 항목을 다시 겨냥한다.
///
/// [editTarget] 을 주면 최종 확인 화면에서 항목 하나를 고치러 들어온 모드가 된다.
/// 네 항목이 모두 펼쳐진 채 그 항목만 활성화되고, 버튼 한 번으로 되돌아간다.
class BasicSettingsForm extends StatefulWidget {
  const BasicSettingsForm({
    super.key,
    required this.initialParticipants,
    required this.initialRoundDuration,
    required this.initialLocationShare,
    required this.initialPoliceWait,
    required this.onSubmit,
    this.onValuesChanged,
    this.editTarget,
    this.revealAll = false,
  });

  final int initialParticipants;
  final int initialRoundDuration;
  final int initialLocationShare;
  final int initialPoliceWait;

  /// 마지막 버튼(완료하기 / 확인)을 눌렀을 때
  final ValueChanged<GameSettingValues> onSubmit;

  /// 값이 바뀔 때마다 (임시 저장용)
  final ValueChanged<GameSettingValues>? onValuesChanged;

  /// 최종 확인 화면에서 고치러 들어온 항목 (null 이면 처음부터 차례로 묻는다)
  final GameSettingField? editTarget;

  /// 네 항목이 모두 펼쳐진 채 시작할지 (최종 확인에서 뒤로 왔을 때)
  ///
  /// [editTarget] 과 달리 생성 흐름의 뒤로가기 규칙을 그대로 따른다 —
  /// 뒤로 갈수록 질문이 접히고, 첫 항목에서 더 뒤로 가면 지도로 나간다.
  final bool revealAll;

  @override
  State<BasicSettingsForm> createState() => BasicSettingsFormState();
}

class BasicSettingsFormState extends State<BasicSettingsForm> {
  late final GameSettingValues _values;

  /// 지금까지 펼쳐진 항목 수 (1이면 첫 항목만 보임)
  late int _revealed;

  bool get _isEditMode => widget.editTarget != null;

  @override
  void initState() {
    super.initState();
    _values = GameSettingValues(
      participants: widget.initialParticipants,
      roundDuration: widget.initialRoundDuration,
      locationShare: widget.initialLocationShare,
      policeWait: widget.initialPoliceWait,
      // 고치러 들어오거나 전체 펼침으로 시작하는 값은 제안값이 아니라 이미 정한 값이다
      touched: _isEditMode || widget.revealAll,
    );
    if (_isEditMode) {
      _revealed = GameSettingField.values.length;
      _values.activate(widget.editTarget!);
    } else if (widget.revealAll) {
      _revealed = GameSettingField.values.length;
      _values.activate(GameSettingField.policeWait);
    } else {
      _revealed = 1;
      _values.activate(GameSettingField.participants);
    }
  }

  /// 숫자 입력. 상한에 막히면 안내 힌트와 함께 더 무거운 진동으로 알린다.
  void _onDigit(int digit) {
    _mutate(() => _values.inputDigit(digit));
    if (_values.lastInputExceededMax) VibrationService.instance().longPress();
  }

  void _onQuickAdd(int amount) {
    _mutate(() => _values.quickAdd(amount));
    if (_values.lastInputExceededMax) VibrationService.instance().longPress();
  }

  void _mutate(void Function() action) {
    setState(action);
    widget.onValuesChanged?.call(_values);
  }

  /// 뒤로 가기 처리. 폼 안에서 소화했으면 true, 폼 밖으로 나가야 하면 false.
  ///
  /// 답한 카드를 고치러 내려간 상태라면 원래 진행 위치로 복귀한다(수정 취소).
  /// 진행의 맨 앞이라면 맨 위 질문을 접고 이전 항목으로 되돌아간다 — 카드 탭이
  /// 제자리 수정이라면 뒤로 가기는 흐름 한 단계 취소다. 접힌 항목의 입력값은
  /// 남아 있어 다시 나아가면 그대로 복원된다.
  bool handleBack() {
    if (_isEditMode) return false;
    if (_isRevisiting) {
      _mutate(() => _values.activate(_furthest));
      return true;
    }
    if (_revealed > 1) {
      _mutate(() {
        _revealed--;
        _values.activate(_furthest);
      });
      return true;
    }
    return false;
  }

  /// 마지막으로 펼쳐진 항목 (진행의 맨 앞)
  GameSettingField get _furthest => GameSettingField.values[_revealed - 1];

  bool get _isRevisiting => !_isEditMode && _values.active != _furthest;

  String _ctaLabel(AppLocalizations l10n) {
    if (_isEditMode) return l10n.buttonConfirm;
    if (_isRevisiting) return l10n.buttonNext;
    return _revealed < GameSettingField.values.length
        ? l10n.buttonNext
        : l10n.buttonCompleteSetup;
  }

  bool get _isCtaEnabled {
    if (_isEditMode) return _values.allValid;
    if (!_values.isValid(_values.active)) return false;
    if (_revealed == GameSettingField.values.length) {
      // 마지막 항목까지 왔으면 앞서 답한 값도 전부 유효해야 한다
      // (게임 시간을 고쳐 다른 항목이 어긋난 경우를 여기서 잡는다)
      return _values.allValid;
    }
    return true;
  }

  void _onCtaPressed() {
    if (_isEditMode) {
      widget.onSubmit(_values);
      return;
    }
    if (_isRevisiting) {
      _mutate(() => _values.activate(_furthest));
      return;
    }
    if (_revealed < GameSettingField.values.length) {
      _mutate(() {
        _revealed++;
        _values.activate(_furthest);
      });
      return;
    }
    widget.onSubmit(_values);
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
            child: AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  // 새 항목이 위, 답한 항목이 아래 (탭 순서의 역순)
                  for (final field
                      in GameSettingField.values
                          .take(_revealed)
                          .toList()
                          .reversed) ...[
                    _buildCard(l10n, field),
                    SizedBox(height: AppSpacing.vertical8),
                  ],
                ],
              ),
            ),
          ),
        ),
        _buildCta(l10n),
        NumberPad(
          quickAmounts: active.quickAmounts,
          unit: settingFieldUnit(l10n, active),
          onDigit: _onDigit,
          onQuickAdd: _onQuickAdd,
          onBackspace: () => _mutate(_values.backspace),
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
      onTap: isActive ? null : () => _mutate(() => _values.activate(field)),
    );
  }

  Widget _buildCta(AppLocalizations l10n) {
    return KeypadCtaButton(
      label: _ctaLabel(l10n),
      onPressed: _isCtaEnabled ? _onCtaPressed : null,
    );
  }
}
