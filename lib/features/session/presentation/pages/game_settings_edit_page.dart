import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/role_theme_provider.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/i18n/error_message_mapper.dart';
import '../../../../core/network/dio_exception_handler.dart';
import '../../../../core/services/loading_message_service.dart';
import '../../../../core/services/vibration_service.dart';
import '../../../../core/widgets/snackbars/app_snackbar.dart';
import '../../../../core/widgets/buttons/keypad_cta_button.dart';
import '../../../../core/widgets/inputs/number_pad.dart';
import '../../../../core/widgets/navigation/app_top_bar.dart';
import '../../../../core/widgets/loading/app_loading.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/game_create_request_model.dart';
import '../../data/models/game_settings_response.dart';
import '../providers/session_provider.dart';
import '../widgets/game_setting_values_editor.dart';
import '../widgets/setting_field_card.dart';

/// 게임 설정 수정 페이지 (대기실)
///
/// 네 항목 카드가 모두 펼쳐져 있고, 카드를 탭하면 하단 고정 키패드가 그 항목을
/// 겨냥한다. 방 생성의 기본 정보 화면과 같은 입력 방식이다.
/// 저장하면 PUT /api/games/{gameId}/settings 를 호출한다.
class GameSettingsEditPage extends ConsumerStatefulWidget {
  const GameSettingsEditPage({
    super.key,
    required this.sessionId,
    required this.initialSettings,
  });

  /// 게임 세션 ID
  final String sessionId;

  /// 현재 게임 설정 (초기값)
  final GameSettingsResponse initialSettings;

  @override
  ConsumerState<GameSettingsEditPage> createState() =>
      _GameSettingsEditPageState();
}

class _GameSettingsEditPageState extends ConsumerState<GameSettingsEditPage> {
  late final GameSettingValues _values;

  /// API 호출 중 여부
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _values = GameSettingValues(
      participants: widget.initialSettings.maxParticipants,
      roundDuration: widget.initialSettings.roundDurationMinutes,
      locationShare: widget.initialSettings.locationRevealIntervalMinutes,
      policeWait: widget.initialSettings.policeWaitMinutes,
      // 이미 정해진 값을 고치는 화면이라 제안값 표시가 없다
      touched: true,
    );
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

  /// 변경 사항이 있는지 확인
  bool get _hasChanges {
    final s = widget.initialSettings;
    return _values[GameSettingField.participants] != s.maxParticipants ||
        _values[GameSettingField.roundDuration] != s.roundDurationMinutes ||
        _values[GameSettingField.locationShare] !=
            s.locationRevealIntervalMinutes ||
        _values[GameSettingField.policeWait] != s.policeWaitMinutes;
  }

  /// 설정 저장
  ///
  /// 바뀐 것이 없으면 API 호출 없이 닫는다 (닉네임 설정 화면과 같은 방식).
  Future<void> _saveSettings() async {
    if (!_values.allValid || _isSaving) return;
    if (!_hasChanges) {
      context.pop();
      return;
    }

    final gameId = int.tryParse(widget.sessionId);
    if (gameId == null) return;
    setState(() => _isSaving = true);

    final loading = AppLoading.show(context, LoadingCategory.saveSettings);

    try {
      await ref.read(
        updateGameSettingsProvider(
          gameId,
          request: GameSettingsRequestModel(
            roundDurationMinutes: _values[GameSettingField.roundDuration],
            locationRevealIntervalMinutes:
                _values[GameSettingField.locationShare],
            policeWaitMinutes: _values[GameSettingField.policeWait],
            maxParticipants: _values[GameSettingField.participants],
          ),
        ).future,
      );

      await loading.close();
      if (!mounted) return;
      context.pop(); // 설정 수정 페이지 닫기
    } on DioException catch (e) {
      await loading.close();
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      // 백엔드 한국어 detail 대신 i18n 메시지 사용 (errorCode 기반)
      final ex = DioExceptionHandler.handle(e);
      final message = l10n.errorByException(ex);
      AppSnackbar.show(
        context,
        message: message,
        backgroundColor: AppColors.red,
      );
    } finally {
      // 안전망: 위에서 처리하지 못한 예외 타입으로 인해 close()가 호출되지
      // 않는 경로를 막는다. close()는 멱등이므로 정상 경로에는 영향 없음.
      await loading.close();
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(roleThemeProvider);
    final bgColor = isDark ? AppColors.black900 : AppColors.white;
    final l10n = AppLocalizations.of(context);
    final active = _values.active;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppTopBar(
        title: l10n.pageGameSettingsEditTitle,
        isDarkMode: isDark,
        onBack: () => context.pop(),
      ),
      body: SafeArea(
        // 키패드가 하단 인셋까지 배경으로 채우므로 하단은 풀어준다 (#539)
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.horizontal20,
                  vertical: AppSpacing.vertical20,
                ),
                child: Column(
                  children: [
                    for (final field in GameSettingField.values) ...[
                      _buildCard(l10n, field, isDark),
                      SizedBox(height: AppSpacing.vertical8),
                    ],
                  ],
                ),
              ),
            ),

            // 저장 버튼 — 방 생성 CTA 와 같은 전폭 형태로 키패드에 붙는다
            KeypadCtaButton(
              label: _isSaving ? l10n.buttonSaving : l10n.buttonSave,
              isDarkMode: isDark,
              onPressed: _values.allValid && !_isSaving ? _saveSettings : null,
            ),

            NumberPad(
              quickAmounts: active.quickAmounts,
              unit: settingFieldUnit(l10n, active),
              isDarkMode: isDark,
              onDigit: _onDigit,
              onQuickAdd: _onQuickAdd,
              onBackspace: () => setState(_values.backspace),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
    AppLocalizations l10n,
    GameSettingField field,
    bool isDark,
  ) {
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
      isDarkMode: isDark,
      onTap: isActive ? null : () => setState(() => _values.activate(field)),
    );
  }
}
