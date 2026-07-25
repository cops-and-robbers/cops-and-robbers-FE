import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
import '../../../../router/route_paths.dart';
import '../../../game/domain/entities/area_shape.dart';
import '../../data/models/game_settings_response.dart';
import '../../domain/entities/session_settings.dart';
import '../../../../core/theme/role_theme_provider.dart';
import '../providers/game_participant_provider.dart';
import '../providers/session_provider.dart';
import 'setup_prison_page.dart';
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
    final router = GoRouter.of(context);

    final playground = await router.pushNamed<AreaShape>(
      RoutePaths.gameSettingsPlaygroundName,
      pathParameters: {'sessionId': widget.sessionId},
      extra: currentArea.playground,
    );
    if (playground == null || !mounted) return;

    final currentJail = currentArea.jail;
    final initialJail =
        (playground is CircleShape && currentJail is CircleShape) ||
            (playground is PolygonShape && currentJail is PolygonShape)
        ? currentJail
        : null;

    final jail = await router.pushNamed<AreaShape>(
      RoutePaths.gameSettingsPrisonName,
      pathParameters: {'sessionId': widget.sessionId},
      extra: PrisonEditArgs(playground: playground, initialJail: initialJail),
    );
    if (jail == null || !mounted) return;

    await _updateArea(GameAreaEntity(playground: playground, jail: jail));
  }

  /// PUT /api/games/{gameId}/area 호출
  Future<void> _updateArea(GameAreaEntity area) async {
    final gameId = _gameId;
    if (gameId == null) return;

    final loading = AppLoading.show(context, LoadingCategory.updateArea);

    try {
      await ref.read(updateGameAreaProvider(gameId, area: area).future);
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
        surfaceTintColor: AppColors.transparent,
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
                data: (area) =>
                    _buildZoneSection(area, isHost: isHost, isDark: isDark),
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
  }) {
    return ZoneListCard(
      area: area,
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
