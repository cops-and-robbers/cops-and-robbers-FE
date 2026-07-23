import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/i18n/error_message_mapper.dart';
import '../../../../core/network/dio_exception_handler.dart';
import '../../../../core/services/loading_message_service.dart';
import '../../../../core/widgets/snackbars/app_snackbar.dart';
import '../../../../core/widgets/buttons/previous_button.dart';
import '../../../../core/widgets/loading/app_loading.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../game/data/models/game_area_model.dart';
import '../../../game/domain/entities/area_shape.dart';
import '../../data/models/game_create_request_model.dart';
import '../../data/models/game_settings_response.dart';
import '../../domain/entities/session_settings.dart';
import '../../../../core/theme/role_theme_provider.dart';
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
  Future<void> _navigateToEditPlayground(GameAreaEntity currentArea) async {
    final playground = currentArea.playground;
    final jail = currentArea.jail;

    if (playground is PolygonShape && jail is PolygonShape) {
      await _editPolygonArea(playground, jail);
    } else if (playground is CircleShape && jail is CircleShape) {
      await _editCircleArea(playground, jail);
    }
  }

  /// 원형 구역 수정: 플레이그라운드 → 감옥 순으로 재설정 후 PUT
  Future<void> _editCircleArea(CircleShape playground, CircleShape jail) async {
    final router = GoRouter.of(context);

    final playgroundResult = await router.push<Map<String, dynamic>>(
      '/waiting-room/${widget.sessionId}/game-settings/edit-playground',
      extra: {
        'lat': playground.center.latitude,
        'lng': playground.center.longitude,
        'radius': playground.radiusInMeters,
      },
    );

    if (playgroundResult == null || !mounted) return;

    final newPlaygroundCenter = LatLng(
      playgroundResult['lat'] as double,
      playgroundResult['lng'] as double,
    );
    final newPlaygroundRadius = playgroundResult['radius'] as double;

    final prisonResult = await router.push<Map<String, dynamic>>(
      '/waiting-room/${widget.sessionId}/game-settings/edit-prison',
      extra: {
        'lat': jail.center.latitude,
        'lng': jail.center.longitude,
        'radius': jail.radiusInMeters,
        'playgroundLat': newPlaygroundCenter.latitude,
        'playgroundLng': newPlaygroundCenter.longitude,
        'playgroundRadius': newPlaygroundRadius,
      },
    );

    if (prisonResult == null || !mounted) return;

    await _updateArea(
      GameAreaRequestModel(
        areaType: GameAreaType.circle,
        circle: CircleAreaRequestModel(
          playgroundCenter: CoordinatesRequestModel(
            latitude: newPlaygroundCenter.latitude,
            longitude: newPlaygroundCenter.longitude,
          ),
          playgroundRadiusInMeters: newPlaygroundRadius.toInt(),
          jailCenter: CoordinatesRequestModel(
            latitude: prisonResult['lat'] as double,
            longitude: prisonResult['lng'] as double,
          ),
          jailRadiusInMeters: (prisonResult['radius'] as double).toInt(),
        ),
      ),
    );
  }

  /// 폴리곤 구역 수정: 플레이그라운드 핀 → 감옥 핀 순으로 재설정 후 PUT
  Future<void> _editPolygonArea(
    PolygonShape playground,
    PolygonShape jail,
  ) async {
    final router = GoRouter.of(context);

    final playgroundResult = await router.push<Map<String, dynamic>>(
      '/waiting-room/${widget.sessionId}/game-settings/edit-playground',
      extra: {'points': _toLatLngList(playground.points)},
    );

    if (playgroundResult == null || !mounted) return;
    final newPlaygroundPoints = playgroundResult['points'] as List<LatLng>;

    final prisonResult = await router.push<Map<String, dynamic>>(
      '/waiting-room/${widget.sessionId}/game-settings/edit-prison',
      extra: {
        'points': _toLatLngList(jail.points),
        'playgroundPoints': newPlaygroundPoints,
      },
    );

    if (prisonResult == null || !mounted) return;
    final newJailPoints = prisonResult['points'] as List<LatLng>;

    await _updateArea(
      GameAreaRequestModel(
        areaType: GameAreaType.polygon,
        polygon: PolygonAreaRequestModel(
          playgroundPolygon: _toCoordinatesList(newPlaygroundPoints),
          jailPolygon: _toCoordinatesList(newJailPoints),
        ),
      ),
    );
  }

  List<LatLng> _toLatLngList(List<GeoPoint> points) => [
    for (final p in points) LatLng(p.latitude, p.longitude),
  ];

  List<CoordinatesRequestModel> _toCoordinatesList(List<LatLng> points) => [
    for (final p in points)
      CoordinatesRequestModel(latitude: p.latitude, longitude: p.longitude),
  ];

  /// PUT /api/games/{gameId}/area 호출
  Future<void> _updateArea(GameAreaRequestModel request) async {
    final gameId = _gameId;
    if (gameId == null) return;

    final loading = AppLoading.show(context, LoadingCategory.updateArea);

    try {
      await ref.read(updateGameAreaProvider(gameId, request: request).future);
      await loading.close();
      debugPrint('[GameSettingsPage] ✅ 영역 수정 성공');
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
    final isDark = ref.watch(roleThemeProvider);
    final l10n = AppLocalizations.of(context);

    final settingsAsync = ref.watch(fetchGameSettingsProvider(gameId));
    final areaAsync = ref.watch(fetchGameAreaProvider(gameId));

    final bgColor = isDark ? AppColors.black900 : AppColors.white;
    final textColor = isDark ? AppColors.white : AppColors.black;

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
        title: Text(
          l10n.pageGameSettingsTitle,
          style: AppTextStyles.heading_20.copyWith(color: textColor),
        ),
        iconTheme: IconThemeData(
          color: isDark ? AppColors.white : AppColors.black800,
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
                data: (area) => _buildZoneSection(
                  area,
                  isHost: isHost,
                  isDark: isDark,
                  l10n: l10n,
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text(
                  l10n.errorZoneInfoLoadFailed,
                  style: AppTextStyles.paragraph_14.copyWith(
                    color: AppColors.red,
                  ),
                ),
              ),

              SizedBox(height: AppSpacing.vertical8),

              // ── 설정 섹션 ──
              settingsAsync.when(
                data: (settings) => _buildSettingsSection(
                  settings,
                  isHost: isHost,
                  isDark: isDark,
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text(
                  l10n.errorSettingsLoadFailed,
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

  /// 구역 프리뷰 페이지로 이동 (비방장용) — 엔티티를 그대로 전달
  void _navigateToZonePreview(GameAreaEntity area) {
    context.push(
      '/waiting-room/${widget.sessionId}/game-settings/zone-preview',
      extra: area,
    );
  }

  /// 구역 카드 빌드 (Step 3 UI 재사용)
  ///
  /// 호스트: 구역 탭 → 수정 페이지로 이동
  /// 비호스트: 구역 탭 → 읽기전용 프리뷰 페이지로 이동
  Widget _buildZoneSection(
    GameAreaEntity area, {
    required bool isHost,
    required bool isDark,
    required AppLocalizations l10n,
  }) {
    // 원형은 반경, 폴리곤은 외접 반경으로 대략적 크기를 표시한다.
    final zones = [
      ZoneInfo(
        id: 'playground',
        name: l10n.zonePlayground,
        radiusMeters: area.playground.boundingRadiusInMeters.toInt(),
      ),
      ZoneInfo(
        id: 'prison',
        name: l10n.zoneJail,
        radiusMeters: area.jail.boundingRadiusInMeters.toInt(),
      ),
    ];

    return ZoneListCard(
      zones: zones,
      onTap: isHost
          ? () => _navigateToEditPlayground(area)
          : () => _navigateToZonePreview(area),
      isDarkMode: isDark,
    );
  }

  /// 설정 카드 빌드 (Step 3 UI 재사용)
  ///
  /// 호스트: 탭 → 설정 수정 페이지로 이동
  /// 비호스트: 읽기 전용
  Widget _buildSettingsSection(
    GameSettingsResponse settings, {
    required bool isHost,
    required bool isDark,
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
      isDarkMode: isDark,
    );
  }
}
