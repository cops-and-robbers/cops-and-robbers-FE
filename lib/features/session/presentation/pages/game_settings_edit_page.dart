import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/role_theme_provider.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/i18n/error_message_mapper.dart';
import '../../../../core/network/dio_exception_handler.dart';
import '../../../../core/widgets/dialogs/app_popup.dart';
import '../../../../core/services/loading_message_service.dart';
import '../../../../core/widgets/snackbars/app_snackbar.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/buttons/previous_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/game_create_request_model.dart';
import '../../data/models/game_settings_response.dart';
import '../providers/session_provider.dart';
import '../widgets/session_creation_steps/step_1_participant_settings_content.dart';
import '../widgets/session_creation_steps/step_2_game_settings_content.dart';

/// 게임 설정 수정 페이지
///
/// Step1(인원 설정) + Step2(게임 규칙 설정) 슬라이더를 하나의 페이지에 표시합니다.
/// 수정 완료 시 PUT /api/games/{gameId}/settings API를 호출합니다.
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
  late int _maxParticipants;
  late int _roundDurationMinutes;
  late int _locationShareMinutes;
  late int _policeWaitMinutes;

  /// API 호출 중 여부
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _maxParticipants = widget.initialSettings.maxParticipants;
    _roundDurationMinutes = widget.initialSettings.roundDurationMinutes;
    _locationShareMinutes =
        widget.initialSettings.locationRevealIntervalMinutes;
    _policeWaitMinutes = widget.initialSettings.policeWaitMinutes;
  }

  /// 변경 사항이 있는지 확인
  bool get _hasChanges {
    final s = widget.initialSettings;
    return _maxParticipants != s.maxParticipants ||
        _roundDurationMinutes != s.roundDurationMinutes ||
        _locationShareMinutes != s.locationRevealIntervalMinutes ||
        _policeWaitMinutes != s.policeWaitMinutes;
  }

  /// 설정 저장 API 호출
  Future<void> _saveSettings() async {
    if (!_hasChanges || _isSaving) return;

    // AppSlider 숫자 편집용 키패드 잔존 방지 (숫자 전용 키패드에 완료 키가 없음)
    FocusScope.of(context).unfocus();

    final gameId = int.tryParse(widget.sessionId);
    if (gameId == null) return;
    setState(() => _isSaving = true);
    final navigator = Navigator.of(context);

    await AppPopup.showRandomLoading(
      context: context,
      category: LoadingCategory.saveSettings,
    );

    try {
      await ref.read(
        updateGameSettingsProvider(
          gameId,
          request: GameSettingsRequestModel(
            roundDurationMinutes: _roundDurationMinutes,
            locationRevealIntervalMinutes: _locationShareMinutes,
            policeWaitMinutes: _policeWaitMinutes,
            maxParticipants: _maxParticipants,
          ),
        ).future,
      );

      if (!mounted) return;
      if (navigator.canPop()) navigator.pop(); // 로딩 팝업 닫기
      context.pop(); // 설정 수정 페이지 닫기
    } on DioException catch (e) {
      if (navigator.canPop()) navigator.pop(); // 로딩 팝업 닫기
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
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(roleThemeProvider);
    final bgColor = isDark ? AppColors.black900 : AppColors.white;
    final titleStyle = isDark
        ? AppTextStyles.robberHeading.copyWith(color: AppColors.white)
        : AppTextStyles.heading_20.copyWith(color: AppColors.black);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: PreviousButton(
          onPressed: () {
            // AppSlider 숫자 편집용 키패드 잔존 방지 (숫자 전용 키패드에 완료 키가 없음)
            FocusScope.of(context).unfocus();
            context.pop();
          },
          color: isDark ? AppColors.black200 : AppColors.black800,
        ),
        centerTitle: true,
        title: Text(l10n.pageGameSettingsEditTitle, style: titleStyle),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: AppPadding.horizontal24,
                  child: Column(
                    children: [
                      SizedBox(height: AppSpacing.vertical20),

                      // Step 1: 인원 설정
                      Step1ParticipantSettingsContent(
                        maxParticipants: _maxParticipants,
                        onChanged: (v) => setState(() => _maxParticipants = v),
                        isDarkMode: isDark,
                        valueTextStyle: isDark
                            ? AppTextStyles.robberLabel
                            : null,
                      ),

                      SizedBox(height: AppSpacing.vertical8),

                      // Step 2: 게임 규칙 설정 (공용 컴포넌트 재사용)
                      Step2GameSettingsContent(
                        roundDurationMinutes: _roundDurationMinutes,
                        locationShareMinutes: _locationShareMinutes,
                        policeWaitMinutes: _policeWaitMinutes,
                        onRoundDurationChanged: (v) =>
                            setState(() => _roundDurationMinutes = v),
                        onLocationShareChanged: (v) =>
                            setState(() => _locationShareMinutes = v),
                        onPoliceWaitChanged: (v) =>
                            setState(() => _policeWaitMinutes = v),
                        isDarkMode: isDark,
                        valueTextStyle: isDark
                            ? AppTextStyles.robberLabel
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 하단 저장 버튼
            Padding(
              padding: AppPadding.all20,
              child: AppButton(
                text: _isSaving ? l10n.buttonSaving : l10n.buttonSave,
                onPressed: _hasChanges && !_isSaving ? _saveSettings : null,
                backgroundColor: isDark ? AppColors.green : AppColors.blue,
                foregroundColor: isDark ? AppColors.black : AppColors.white,
                disabledBackgroundColor: isDark
                    ? AppColors.black800
                    : AppColors.black200,
                disabledForegroundColor: isDark
                    ? AppColors.green
                    : AppColors.black400,
                textStyle: isDark ? AppTextStyles.robberLabel : null,
                showBorder: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
