import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/role_theme_provider.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/network/api_error_response.dart';
import '../../../../core/widgets/dialogs/app_popup.dart';
import '../../../../core/services/loading_message_service.dart';
import '../../../../core/widgets/snackbars/app_snackbar.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/buttons/previous_button.dart';
import '../../../../core/widgets/inputs/app_slider.dart';
import '../../data/models/game_create_request_model.dart';
import '../../data/models/game_settings_response.dart';
import '../providers/session_provider.dart';
import '../widgets/session_creation_steps/step_1_participant_settings_content.dart';

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
      final errorMsg =
          ApiErrorResponse.tryParse(e.response?.data)?.detail ??
          '설정 저장에 실패했습니다.';
      AppSnackbar.show(
        context,
        message: errorMsg,
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

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: PreviousButton(
          onPressed: () => context.pop(),
          color: isDark ? AppColors.black200 : AppColors.black800,
        ),
        centerTitle: true,
        title: Text('설정 수정', style: titleStyle),
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

                      // Step 2: 게임 규칙 설정 (인라인)
                      AppSlider(
                        label: '라운드 제한 시간',
                        value: _roundDurationMinutes.toDouble(),
                        min: 10,
                        max: 180,
                        unit: '분',
                        divisions: 170,
                        onChanged: (v) =>
                            setState(() => _roundDurationMinutes = v.toInt()),
                        isDarkMode: isDark,
                        backgroundColor: isDark
                            ? AppColors.black900
                            : AppColors.white,
                        activeTrackColor: isDark
                            ? AppColors.green800
                            : AppColors.black800,
                        thumbColor: isDark ? AppColors.green : AppColors.black,
                        inactiveTrackColor: isDark
                            ? AppColors.black800
                            : AppColors.black100,
                        valueColor: isDark ? AppColors.white : null,
                        valueTextStyle: isDark
                            ? AppTextStyles.robberLabel
                            : null,
                      ),

                      SizedBox(height: AppSpacing.vertical8),

                      AppSlider(
                        label: '위치 공유 간격',
                        value: _locationShareMinutes.toDouble(),
                        min: 5,
                        max: 30,
                        unit: '분',
                        divisions: 25,
                        onChanged: (v) =>
                            setState(() => _locationShareMinutes = v.toInt()),
                        isDarkMode: isDark,
                        backgroundColor: isDark
                            ? AppColors.black900
                            : AppColors.white,
                        activeTrackColor: isDark
                            ? AppColors.green800
                            : AppColors.black800,
                        thumbColor: isDark ? AppColors.green : AppColors.black,
                        inactiveTrackColor: isDark
                            ? AppColors.black800
                            : AppColors.black100,
                        valueColor: isDark ? AppColors.white : null,
                        valueTextStyle: isDark
                            ? AppTextStyles.robberLabel
                            : null,
                      ),

                      SizedBox(height: AppSpacing.vertical8),

                      AppSlider(
                        label: '경찰 시작 시간',
                        value: _policeWaitMinutes.toDouble(),
                        min: 1,
                        max: 10,
                        unit: '분',
                        divisions: 9,
                        displayPrefix: '도둑 시작 후 ',
                        displaySuffix: ' 뒤',
                        onChanged: (v) =>
                            setState(() => _policeWaitMinutes = v.toInt()),
                        isDarkMode: isDark,
                        backgroundColor: isDark
                            ? AppColors.black900
                            : AppColors.white,
                        activeTrackColor: isDark
                            ? AppColors.green800
                            : AppColors.black800,
                        thumbColor: isDark ? AppColors.green : AppColors.black,
                        inactiveTrackColor: isDark
                            ? AppColors.black800
                            : AppColors.black100,
                        valueColor: isDark ? AppColors.white : null,
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
                text: _isSaving ? '저장 중...' : '저장',
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
