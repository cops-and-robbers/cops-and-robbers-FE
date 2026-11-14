import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/game_mode.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/i18n/error_message_mapper.dart';
import '../../../../core/network/dio_exception_handler.dart';
import '../../../../core/services/loading_message_service.dart';
import '../../../../core/widgets/snackbars/app_snackbar.dart';
import '../../../../core/widgets/navigation/app_top_bar.dart';
import '../../../../core/widgets/loading/app_loading.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../router/route_paths.dart';
import '../../../game/domain/entities/area_shape.dart';
import '../../data/models/game_create_request_model.dart';
import '../../data/models/game_settings_response.dart';
import '../../domain/mode_change.dart';
import '../../domain/shrink_area_save_plan.dart';
import '../../domain/entities/session_settings.dart';
import '../../../../core/theme/role_theme_provider.dart';
import '../providers/game_participant_provider.dart';
import '../providers/session_provider.dart';
import 'setup_prison_page.dart';
import '../widgets/mode_row_card.dart';
import '../widgets/mode_select_step.dart';
import '../widgets/setting_list_card.dart';
import '../widgets/shrink_toggle_card.dart';
import '../../../game/domain/shrink_schedule.dart';
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

    // 술래잡기는 감옥이 없으니 플레이그라운드만 바꾼다
    if (!_currentMode.usesJail) {
      await _updateArea(currentArea, GameAreaEntity(playground: playground));
      return;
    }

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

    await _updateArea(
      currentArea,
      GameAreaEntity(playground: playground, jail: jail),
    );
  }

  GameMode get _currentMode =>
      ref.read(gameParticipantNotifierProvider)?.gameMode ??
      GameMode.copsAndRobbers;

  /// 모드 행 탭 → 모드 선택 → (경찰과 도둑이면 감옥 그리기) → 저장
  Future<void> _changeMode(GameAreaEntity currentArea) async {
    final current = _currentMode;
    final target = await showModalBottomSheet<GameMode>(
      context: context,
      backgroundColor: AppColors.white,
      builder: (sheetContext) {
        var selected = current;
        return StatefulBuilder(
          builder: (_, setSheetState) => SizedBox(
            height: MediaQuery.sizeOf(sheetContext).height * 0.5,
            child: ModeSelectStep(
              selected: selected,
              onSelected: (m) => setSheetState(() => selected = m),
              onNext: () => Navigator.of(sheetContext).pop(selected),
            ),
          ),
        );
      },
    );
    if (target == null || target == current || !mounted) return;

    AreaShape? newJail;
    if (target.usesJail) {
      // 감옥 지도에서 뒤로 가면 변경을 취소한다
      newJail = await GoRouter.of(context).pushNamed<AreaShape>(
        RoutePaths.gameSettingsPrisonName,
        pathParameters: {'sessionId': widget.sessionId},
        extra: PrisonEditArgs(
          playground: currentArea.playground,
          initialJail: null,
        ),
      );
      if (newJail == null || !mounted) return;
    }
    await _updateArea(
      currentArea,
      areaForMode(currentArea, target, newJail: newJail),
      newMode: target,
    );
  }

  /// PUT /api/games/{gameId}/area (모드 변경이면 PUT /mode) 호출
  ///
  /// 구역 축소가 켜져 있으면 서버가 각 요청을 저장된 다른 쪽 값과 대조하므로
  /// [planShrinkAreaSave]가 정한 순서로 설정과 구역을 함께 보낸다 (#668).
  Future<void> _updateArea(
    GameAreaEntity oldArea,
    GameAreaEntity area, {
    GameMode? newMode,
  }) async {
    final gameId = _gameId;
    if (gameId == null) return;

    final oldMode = _currentMode;
    final loading = AppLoading.show(context, LoadingCategory.updateArea);

    try {
      final settings = await ref.read(fetchGameSettingsProvider(gameId).future);
      final plan = planShrinkAreaSave(
        oldArea: oldArea,
        newArea: area,
        currentFinalRadius: settings.shrinkFinalRadiusInMeters,
      );
      await runShrinkAreaSave(
        plan,
        putSettings: (radius) => ref.read(
          updateGameSettingsProvider(
            gameId,
            request: settings.toRequest(shrinkFinalRadiusInMeters: radius),
          ).future,
        ),
        putArea: () => newMode == null
            ? ref.read(updateGameAreaProvider(gameId, area: area).future)
            : ref.read(
                updateGameModeProvider(
                  gameId,
                  mode: newMode,
                  area: area,
                ).future,
              ),
        previousFinalRadius: settings.shrinkFinalRadiusInMeters,
        putPreviousArea: () => newMode == null
            ? ref.read(updateGameAreaProvider(gameId, area: oldArea).future)
            : ref.read(
                updateGameModeProvider(
                  gameId,
                  mode: oldMode,
                  area: oldArea,
                ).future,
              ),
      );
      // 로비 MODE_UPDATED 에코를 기다리지 않고 방장 화면을 바로 바꾼다
      if (newMode != null) {
        ref.read(gameParticipantNotifierProvider.notifier).setGameMode(newMode);
      }
      await loading.close();
      debugPrint('[GameSettingsPage] ✅ 영역 수정 성공');
      if (plan.turnedOff && mounted) {
        AppSnackbar.show(
          context,
          message: AppLocalizations.of(context).shrinkAutoOffSnackbar,
        );
      }
    } on Object catch (e) {
      // 모드 변경은 리포지토리가 DioException을 AppException으로 바꿔 던지고
      // 영역·설정 provider는 raw DioException을 던진다. 둘 다 같은 경로로 처리한다.
      if (e is! DioException && e is! AppException) rethrow;
      await loading.close();
      // 되돌리기까지 실패했을 수 있으니 서버 값을 다시 읽는다
      ref.invalidate(fetchGameSettingsProvider(gameId));
      ref.invalidate(fetchGameAreaProvider(gameId));
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      // 백엔드 한국어 detail 대신 i18n 메시지 사용 (errorCode 기반)
      final ex = e is AppException
          ? e
          : DioExceptionHandler.handle(e as DioException);
      final message = l10n.errorByException(ex, mode: _currentMode);
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

  /// 구역 축소 카드. 방장은 바로 켜고 끄고(PUT /settings), 참가자는 볼 수만 있다.
  Widget _buildShrinkCard(
    int gameId,
    GameSettingsResponse settings,
    GameAreaEntity area, {
    required bool isHost,
    required bool isDark,
  }) {
    final playground = area.playground;
    final jail = area.jail;
    final lock = shrinkLockFor(area);
    final finalRadius = lock == ShrinkLock.none
        ? computeShrinkFinalRadius(
            startRadius: (playground as CircleShape).radiusInMeters.round(),
            jailRadius: jail is CircleShape ? jail.radiusInMeters.round() : 0,
          )
        : null;
    return ShrinkToggleCard(
      enabled: settings.shrinkFinalRadiusInMeters != null,
      lock: lock,
      startRadius: playground is CircleShape
          ? playground.radiusInMeters.round()
          : 0,
      finalRadius: finalRadius,
      isDarkMode: isDark,
      onChanged: isHost
          ? (on) => _saveShrink(gameId, settings, on ? finalRadius : null)
          : null,
    );
  }

  Future<void> _saveShrink(
    int gameId,
    GameSettingsResponse settings,
    int? finalRadius,
  ) async {
    try {
      await ref.read(
        updateGameSettingsProvider(
          gameId,
          request: settings.toRequest(shrinkFinalRadiusInMeters: finalRadius),
        ).future,
      );
    } on DioException catch (e) {
      if (!mounted) return;
      AppSnackbar.show(
        context,
        message: AppLocalizations.of(
          context,
        ).errorByException(DioExceptionHandler.handle(e), mode: _currentMode),
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
    final isDark = ref.watch(roleThemeProvider);
    final l10n = AppLocalizations.of(context);

    final settingsAsync = ref.watch(fetchGameSettingsProvider(gameId));
    final areaAsync = ref.watch(fetchGameAreaProvider(gameId));

    final bgColor = isDark ? AppColors.black900 : AppColors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppTopBar(
        title: l10n.pageGameSettingsTitle,
        isDarkMode: isDark,
        // 도둑 모드에서도 Pretendard를 유지하는 의도된 예외 (구역 미리보기와 한 쌍).
        useRobberFont: false,
        onBack: () => context.pop(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: AppPadding.horizontal20,
          child: Column(
            children: [
              SizedBox(height: AppSpacing.vertical20),

              // ── 구역 축소 (#668) — 방 생성 확인 화면과 같은 맨 위 ──
              if ((settingsAsync.valueOrNull, areaAsync.valueOrNull) case (
                final settings?,
                final area?,
              )) ...[
                ModeRowCard(
                  mode: participantInfo?.gameMode ?? GameMode.copsAndRobbers,
                  // 이벤트 게임은 술래잡기로 바꿀 수 없어 고를 것이 없다
                  onTap: isHost && !(participantInfo?.isEventGame ?? false)
                      ? () => _changeMode(area)
                      : null,
                ),
                SizedBox(height: AppSpacing.vertical8),
                _buildShrinkCard(
                  gameId,
                  settings,
                  area,
                  isHost: isHost,
                  isDark: isDark,
                ),
                SizedBox(height: AppSpacing.vertical8),
              ],

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
      gameMode: settings.gameMode,
    );
  }
}
