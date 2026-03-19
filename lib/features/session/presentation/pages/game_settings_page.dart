import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/network/api_error_response.dart';
import '../../../../core/widgets/snackbars/app_snackbar.dart';
import '../../../../core/widgets/buttons/previous_button.dart';
import '../../../game/data/models/game_area_model.dart';
import '../../data/models/game_create_request_model.dart';
import '../../data/models/game_settings_response.dart';
import '../../domain/entities/session_settings.dart';
import '../../domain/entities/zone_info.dart';
import '../providers/game_participant_provider.dart';
import '../providers/session_provider.dart';
import '../widgets/setting_list_card.dart';
import '../widgets/zone_list_card.dart';

/// 게임 설정 확인/수정 페이지
///
/// 대기실의 설정 아이콘(icon_settiing_2)을 통해 접근합니다.
/// Step 3 "최종 설정 확인" UI(ZoneListCard + SettingListCard)를 재사용합니다.
/// 호스트는 각 카드를 탭하여 수정할 수 있고,
/// 비호스트는 동일한 UI를 읽기 전용으로 확인만 가능합니다.
class GameSettingsPage extends ConsumerStatefulWidget {
  const GameSettingsPage({super.key, required this.sessionId});

  /// 게임 세션 ID
  final String sessionId;

  @override
  ConsumerState<GameSettingsPage> createState() => _GameSettingsPageState();
}

class _GameSettingsPageState extends ConsumerState<GameSettingsPage> {
  int? get _gameId => int.tryParse(widget.sessionId);

  /// 플레이그라운드 수정 → 감옥 재설정 → area PUT API 호출
  ///
  /// 생성 플로우와 동일하게, 플레이그라운드 변경 시 감옥 구역을
  /// 초기화하고 다시 설정하도록 합니다 (감옥이 새 플레이그라운드 밖에
  /// 위치할 수 있으므로).
  Future<void> _navigateToEditPlayground(GameAreaModel currentArea) async {
    final router = GoRouter.of(context);

    // 1. 플레이그라운드 수정
    final playgroundResult = await router.push<Map<String, dynamic>>(
      '/waiting-room/${widget.sessionId}/game-settings/edit-playground',
      extra: {
        'center': LatLng(
          currentArea.playgroundCenter.latitude,
          currentArea.playgroundCenter.longitude,
        ),
        'radius': currentArea.playgroundRadiusInMeters,
      },
    );

    if (playgroundResult == null || !mounted) return;

    final newPlaygroundCenter = playgroundResult['center'] as LatLng;
    final newPlaygroundRadius = playgroundResult['radius'] as double;

    // 2. 감옥 재설정 (새 플레이그라운드 기준, 기존 감옥 위치를 초기값으로 표시)
    //    기존 감옥이 새 플레이그라운드 밖이면 _isJailInsidePlayground 검증에서 차단됨
    final prisonResult = await router.push<Map<String, dynamic>>(
      '/waiting-room/${widget.sessionId}/game-settings/edit-prison',
      extra: {
        'center': LatLng(
          currentArea.jailCenter.latitude,
          currentArea.jailCenter.longitude,
        ),
        'radius': currentArea.jailRadiusInMeters,
        'playgroundCenter': newPlaygroundCenter,
        'playgroundRadius': newPlaygroundRadius,
      },
    );

    if (prisonResult == null || !mounted) return;

    // 3. 둘 다 완료 → PUT /area 호출
    await _updateArea(
      playgroundCenter: newPlaygroundCenter,
      playgroundRadius: newPlaygroundRadius,
      jailCenter: prisonResult['center'] as LatLng,
      jailRadius: prisonResult['radius'] as double,
    );
  }

  /// PUT /api/games/{gameId}/area 호출
  Future<void> _updateArea({
    required LatLng playgroundCenter,
    required double playgroundRadius,
    required LatLng jailCenter,
    required double jailRadius,
  }) async {
    final gameId = _gameId;
    if (gameId == null) return;
    try {
      await ref.read(
        updateGameAreaProvider(
          gameId,
          request: AreaRequestModel(
            playgroundCenter: CoordinatesRequestModel(
              latitude: playgroundCenter.latitude,
              longitude: playgroundCenter.longitude,
            ),
            playgroundRadiusInMeters: playgroundRadius.toInt(),
            jailCenter: CoordinatesRequestModel(
              latitude: jailCenter.latitude,
              longitude: jailCenter.longitude,
            ),
            jailRadiusInMeters: jailRadius.toInt(),
          ),
        ).future,
      );
      debugPrint('[GameSettingsPage] ✅ 영역 수정 성공');
    } on DioException catch (e) {
      if (!mounted) return;
      final errorMsg =
          ApiErrorResponse.tryParse(e.response?.data)?.detail ??
          '영역 저장에 실패했습니다.';
      AppSnackbar.show(
        context,
        message: errorMsg,
        backgroundColor: AppColors.red,
      );
    }
  }

  /// 설정 수정 페이지로 이동
  void _navigateToEditSettings(GameSettingsResponse settings) {
    context.push(
      '/waiting-room/${widget.sessionId}/game-settings/edit-settings',
      extra: settings,
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameId = _gameId;
    if (gameId == null) {
      // sessionId 파싱 실패 → 이전 화면으로
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.pop();
      });
      return const Scaffold(body: SizedBox.shrink());
    }

    final participantInfo = ref.watch(gameParticipantNotifierProvider);
    final isHost = participantInfo?.isHost ?? false;

    final settingsAsync = ref.watch(fetchGameSettingsProvider(gameId));
    final areaAsync = ref.watch(fetchGameAreaProvider(gameId));

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: PreviousButton(onPressed: () => context.pop()),
        centerTitle: true,
        title: Text(
          '게임 설정',
          style: AppTextStyles.heading_20.copyWith(color: AppColors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: AppPadding.horizontal20,
          child: Column(
            children: [
              SizedBox(height: AppSpacing.vertical20),

              // ── 구역 섹션 ──
              areaAsync.when(
                data: (area) => _buildZoneSection(area, isHost: isHost),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text(
                  '구역 정보를 불러올 수 없습니다.',
                  style: AppTextStyles.paragraph_14.copyWith(
                    color: AppColors.red,
                  ),
                ),
              ),

              SizedBox(height: AppSpacing.vertical8),

              // ── 설정 섹션 ──
              settingsAsync.when(
                data: (settings) =>
                    _buildSettingsSection(settings, isHost: isHost),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text(
                  '설정 정보를 불러올 수 없습니다.',
                  style: AppTextStyles.paragraph_14.copyWith(
                    color: AppColors.red,
                  ),
                ),
              ),

              SizedBox(height: AppSpacing.vertical20),
            ],
          ),
        ),
      ),
    );
  }

  /// 구역 카드 빌드 (Step 3 UI 재사용)
  ///
  /// 호스트: 구역 탭 → 수정 페이지로 이동
  /// 비호스트: 읽기 전용
  Widget _buildZoneSection(GameAreaModel area, {required bool isHost}) {
    final zones = [
      ZoneInfo(
        id: 'playground',
        name: '플레이그라운드',
        radiusMeters: area.playgroundRadiusInMeters.toInt(),
      ),
      ZoneInfo(
        id: 'prison',
        name: '감옥',
        radiusMeters: area.jailRadiusInMeters.toInt(),
      ),
    ];

    return ZoneListCard(
      zones: zones,
      onTap: isHost ? () => _navigateToEditPlayground(area) : null,
    );
  }

  /// 설정 카드 빌드 (Step 3 UI 재사용)
  ///
  /// 호스트: 탭 → 설정 수정 페이지로 이동
  /// 비호스트: 읽기 전용
  Widget _buildSettingsSection(
    GameSettingsResponse settings, {
    required bool isHost,
  }) {
    final sessionSettings = SessionSettings(
      maxPlayers: settings.maxParticipants,
      roundTimeMinutes: settings.roundDurationMinutes,
      locationShareMinutes: settings.locationRevealIntervalMinutes,
      policeStartDelayMinutes: settings.policeWaitMinutes,
    );

    return SettingListCard(
      settings: sessionSettings,
      onTap: isHost ? () => _navigateToEditSettings(settings) : null,
    );
  }
}
