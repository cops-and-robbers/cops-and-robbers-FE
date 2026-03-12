import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/network/api_error_response.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/buttons/previous_button.dart';
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

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isSaving = true);

    try {
      final gameId = int.tryParse(widget.sessionId) ?? 0;
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
      context.pop();
    } on DioException catch (e) {
      if (!mounted) return;
      final errorMsg =
          ApiErrorResponse.tryParse(e.response?.data)?.detail ??
          '설정 저장에 실패했습니다.';
      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(
          content: Text(errorMsg, style: AppTextStyles.paragraph_14),
          backgroundColor: AppColors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: PreviousButton(onPressed: () => context.pop()),
        centerTitle: true,
        title: Text(
          '설정 수정',
          style: AppTextStyles.heading_20.copyWith(color: AppColors.black),
        ),
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
                      ),

                      SizedBox(height: AppSpacing.vertical8),

                      // Step 2: 게임 규칙 설정
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
                backgroundColor: AppColors.blue,
                showBorder: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
