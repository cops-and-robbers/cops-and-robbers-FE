import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/game_status.dart';
import '../../../../core/constants/game_team.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/services/analytics/analytics_service.dart';
import '../../../../core/utils/agreement_error_handler.dart';
import '../../../../core/services/loading_message_service.dart';
import '../../../../core/widgets/loading/app_loading.dart';
import '../../../../core/widgets/snackbars/app_snackbar.dart';
import '../../../game/domain/shrink_schedule.dart';
import '../widgets/shrink_toggle_card.dart';
import '../../../../core/services/storage/session_draft_storage_service.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/navigation/app_top_bar.dart';
import '../../../../core/widgets/indicators/step_indicator.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../router/route_paths.dart';
import '../../../../core/constants/game_config.dart';
import '../../../game/data/models/game_area_model.dart';
import '../../../game/domain/entities/area_shape.dart';
import '../../../game/domain/polygon_geometry.dart';
import '../../domain/entities/create_session_result.dart';
import '../../data/models/session_creation_draft_model.dart';
import '../../domain/entities/session_settings.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../community/presentation/providers/community_chat_rooms_provider.dart';
import '../providers/game_participant_provider.dart';
import '../providers/session_provider.dart';
import '../widgets/basic_settings_form.dart';
import '../widgets/game_setting_values_editor.dart';
import '../widgets/setting_list_card.dart';
import '../widgets/zone_list_card.dart';
import 'setup_playground_page.dart';
import 'setup_prison_page.dart';

/// 방 생성 흐름의 단계. 상단 바(뒤로·단계 표시)는 흐름이 하나만 그리고
/// 본문만 단계에 따라 바뀐다(#658 전환 B안).
enum _CreationPhase {
  /// 플레이그라운드 지도 (1/3)
  playground,

  /// 감옥 지도 (2/3)
  jail,

  /// 최종 확인 (3/3, 행을 탭하면 해당 화면으로 되돌아가 수정)
  confirm,

  /// 최종 확인에서 설정 한 항목을 고치는 중 (3/3)
  edit,
}

/// 본문이 바뀔 때의 움직임
enum _Motion {
  /// 처음 그릴 때 — 움직이지 않는다 (페이지 자체가 밀려 들어온다)
  none,

  /// 다음 단계 — 새 본문이 오른쪽에서 들어온다
  forward,

  /// 이전 단계 — 새 본문이 왼쪽에서 들어온다
  back,

  /// 항목 고치기 열기 — 키패드와 함께 아래에서 올라온다
  up,

  /// 항목 고치기 닫기 — 아래로 내려간다
  down,
}

/// 세션 생성 플로우 페이지
///
/// 생성을 누르면 바로 플레이그라운드 지도로 들어가고, 감옥 지도를 마치면
/// 추천값이 채워진 최종 확인으로 간다(#658 B안). 설정은 묻지 않고, 바꿀
/// 항목만 확인 화면에서 탭해 고친다.
///
/// 임시 저장(SessionDraftStorageService)은 숫자 값을 조용히 복원하고, 구역은
/// 지도를 열 때 이전 도형이 그려진 채로 연다.
class SessionCreationFlowPage extends ConsumerStatefulWidget {
  const SessionCreationFlowPage({
    this.communityPostId,
    this.initialCenter,
    super.key,
  });

  /// 아직 설정한 구역이 없을 때 지도가 처음 표시할 모임 장소.
  final LatLng? initialCenter;

  /// 커뮤니티 채팅방에서 진입한 생성이면 그 방의 postId — 생성 성공 직후
  /// 발급된 초대 코드를 GAME_INVITE로 그 방에 쏜다(#516). 홈 진입은 null.
  final int? communityPostId;

  @override
  ConsumerState<SessionCreationFlowPage> createState() =>
      _SessionCreationFlowPageState();
}

class _SessionCreationFlowPageState
    extends ConsumerState<SessionCreationFlowPage> {
  late final SessionDraftStorageService _storageService;

  _CreationPhase _phase = _CreationPhase.playground;
  _Motion _motion = _Motion.none;

  /// 플레이그라운드에서 뒤로 나가면 최종 확인으로 돌아가는지
  /// (확인 화면의 플레이그라운드 행을 눌러 들어온 경우). 아니면 흐름을 끝낸다.
  bool _playgroundExitsToConfirm = false;

  /// 감옥에서 뒤로 나가면 최종 확인으로 돌아가는지
  /// (확인 화면의 감옥 행을 눌러 들어온 경우). 아니면 플레이그라운드로 간다.
  bool _jailExitsToConfirm = false;

  /// 최종 확인에서 고치러 들어간 항목
  GameSettingField? _editTarget;

  bool _isLoading = false;

  // 구역
  LatLng? _playgroundCenter;
  double? _playgroundRadiusMeters;
  LatLng? _prisonCenter;
  double? _prisonRadiusMeters;

  /// 구역 설정 방식 (거리=원형 / 핀=폴리곤)
  GameAreaType _areaType = GameAreaType.circle;

  /// 폴리곤 핀 목록 (정렬된 경계 순서)
  List<LatLng>? _playgroundPinPoints;
  List<LatLng>? _prisonPinPoints;

  // 설정 값
  int _maxParticipants = GameSettingValues.recommendedParticipants;
  int _roundDurationMinutes = GameSettingValues.recommendedRoundDuration;
  int _locationShareMinutes = GameSettingValues.recommendedLocationShare;
  int _policeWaitMinutes = GameSettingValues.recommendedPoliceWait;

  /// 구역 축소 (#668). 기본 꺼짐.
  bool _shrinkEnabled = false;

  // ============================================
  // Lifecycle
  // ============================================

  @override
  void initState() {
    super.initState();
    _storageService = SessionDraftStorageService();
    // 생성 진입 즉시 플레이그라운드 지도를 그린다
    unawaited(_loadDraftData());
  }

  // ============================================
  // Data Management
  // ============================================

  /// 임시 저장된 데이터 불러오기
  Future<void> _loadDraftData() async {
    final draft = await _storageService.loadDraft();
    if (draft != null && mounted) {
      setState(() {
        _areaType = draft.areaType;
        _playgroundPinPoints = draft.playgroundPinPoints == null
            ? null
            : List.of(draft.playgroundPinPoints!);
        _prisonPinPoints = draft.jailPinPoints == null
            ? null
            : List.of(draft.jailPinPoints!);
        _playgroundCenter = draft.playgroundCenter;
        _playgroundRadiusMeters = draft.playgroundRadiusInMeters;
        _prisonCenter = draft.jailCenter;
        _prisonRadiusMeters = draft.jailRadiusInMeters;
        _maxParticipants =
            draft.maxParticipants ?? GameSettingValues.recommendedParticipants;
        _roundDurationMinutes =
            draft.roundDurationMinutes ??
            GameSettingValues.recommendedRoundDuration;
        _locationShareMinutes =
            draft.locationShareMinutes ??
            GameSettingValues.recommendedLocationShare;
        _policeWaitMinutes =
            (draft.policeWaitMinutes ?? GameSettingValues.recommendedPoliceWait)
                .clamp(1, 10);
        _shrinkEnabled = draft.shrinkEnabled;
      });
    }
  }

  /// 임시 저장
  Future<void> _saveDraft() async {
    final draft = SessionCreationDraftModel(
      areaType: _areaType,
      playgroundPinPoints: _playgroundPinPoints,
      jailPinPoints: _prisonPinPoints,
      playgroundCenter: _playgroundCenter,
      playgroundRadiusInMeters: _playgroundRadiusMeters,
      jailCenter: _prisonCenter,
      jailRadiusInMeters: _prisonRadiusMeters,
      maxParticipants: _maxParticipants,
      roundDurationMinutes: _roundDurationMinutes,
      locationShareMinutes: _locationShareMinutes,
      policeWaitMinutes: _policeWaitMinutes,
      shrinkEnabled: _shrinkEnabled,
    );
    await _storageService.saveDraft(draft);
  }

  // ============================================
  // Zone Setup Navigation
  // ============================================

  void _show(_CreationPhase phase, _Motion motion) => setState(() {
    _phase = phase;
    _motion = motion;
  });

  /// 플레이그라운드 완료 → 감옥 (이전에 그린 도형은 지도에 그려진 채로 열린다)
  void _onPlaygroundDone(AreaShape shape) {
    _onPlaygroundResult(shape);
    unawaited(_saveDraft());
    _jailExitsToConfirm = false;
    _show(_CreationPhase.jail, _Motion.forward);
  }

  void _onPlaygroundExit() {
    if (_playgroundExitsToConfirm) {
      _show(_CreationPhase.confirm, _Motion.forward);
    } else {
      context.pop();
    }
  }

  void _onJailDone(AreaShape shape) {
    _onPrisonResult(shape);
    _turnShrinkOffIfLocked();
    unawaited(_saveDraft());
    _show(_CreationPhase.confirm, _Motion.forward);
  }

  /// 구역을 고쳐 축소 조건이 깨지면 끄고 알린다. 다시 가능해져도 켜는 건 방장 몫이다 (#668).
  void _turnShrinkOffIfLocked() {
    final area = _buildAreaEntity();
    if (!_shrinkEnabled || area == null) return;
    if (shrinkLockFor(area) == ShrinkLock.none) return;
    _shrinkEnabled = false;
    AppSnackbar.show(
      context,
      message: AppLocalizations.of(context).shrinkAutoOffSnackbar,
    );
  }

  /// 이 구역에서 켰을 때의 최종 반경. 잠겼으면 null.
  int? _shrinkFinalRadius(GameAreaEntity area) {
    if (shrinkLockFor(area) != ShrinkLock.none) return null;
    final playground = area.playground as CircleShape;
    final jail = area.jail;
    return computeShrinkFinalRadius(
      startRadius: playground.radiusInMeters.round(),
      jailRadius: jail is CircleShape ? jail.radiusInMeters.round() : 0,
    );
  }

  void _onJailExit() {
    if (_jailExitsToConfirm) {
      _show(_CreationPhase.confirm, _Motion.forward);
    } else {
      _show(_CreationPhase.playground, _Motion.back);
    }
  }

  /// 최종 확인의 플레이그라운드 행 — 다시 그린 뒤 감옥을 거쳐 확인으로 돌아온다
  void _editPlaygroundFromConfirm() {
    _playgroundExitsToConfirm = true;
    _show(_CreationPhase.playground, _Motion.back);
  }

  /// 최종 확인의 감옥 행 — 감옥만 고치고 돌아온다
  void _editJailFromConfirm() {
    _jailExitsToConfirm = true;
    _show(_CreationPhase.jail, _Motion.back);
  }

  // ============================================
  // Back Handling
  // ============================================

  /// 시스템 뒤로와 상단 바 뒤로
  ///
  /// 지도 단계는 지도 페이지가 자기 PopScope로 받는다(핀 이탈 확인 포함).
  /// 같은 라우트의 PopScope는 모두 호출되므로 여기서는 건너뛴다.
  void _handleBack() {
    switch (_phase) {
      case _CreationPhase.playground:
      case _CreationPhase.jail:
        return;
      case _CreationPhase.edit:
        // 확인을 누르지 않고 나가면 고친 값은 버린다
        _editTarget = null;
        _show(_CreationPhase.confirm, _Motion.down);
      case _CreationPhase.confirm:
        // 뒤로 계속 누르면 감옥 → 플레이그라운드 → 흐름 종료로 되짚는다
        _playgroundExitsToConfirm = false;
        _jailExitsToConfirm = false;
        _show(_CreationPhase.jail, _Motion.back);
    }
  }

  // ============================================
  // Session Creation
  // ============================================

  /// 세션 생성 API 호출 후 대기실로 이동
  Future<void> _createSessionAndNavigate() async {
    final area = _buildAreaEntity();
    if (area == null) {
      if (kDebugMode) {
        debugPrint('❌ [SessionCreationFlow] 구역 정보가 없습니다');
      }
      return;
    }

    setState(() => _isLoading = true);

    final loading = AppLoading.show(context, LoadingCategory.createRoom);

    try {
      await ref
          .read(sessionCreationNotifierProvider.notifier)
          .createGame(
            area: area,
            roundDurationMinutes: _roundDurationMinutes,
            locationRevealIntervalMinutes: _locationShareMinutes,
            policeWaitMinutes: _policeWaitMinutes,
            maxParticipants: _maxParticipants,
            shrinkFinalRadiusInMeters: _shrinkEnabled
                ? _shrinkFinalRadius(area)
                : null,
          );
    } finally {
      // 성공/실패 무관하게 로딩 종료 보장 (최소 표시 시간은 핸들이 처리)
      await loading.close();
    }

    if (!mounted) return;

    final sessionState = ref.read(sessionCreationNotifierProvider);

    if (sessionState is AsyncData<CreateSessionResult?> &&
        sessionState.value != null) {
      final result = sessionState.value!;
      if (kDebugMode) {
        debugPrint(
          '✅ [SessionCreationFlow] 세션 생성 완료: '
          'gameId=${result.gameId}, inviteCode=${result.inviteCode}',
        );
      }

      // 세션 생성 성공 → Draft 삭제
      try {
        await _storageService.clearDraft();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️ [SessionCreationFlow] Draft 삭제 실패 (무시): $e');
        }
      }

      if (!mounted) return;

      // 방 생성 퍼널 이벤트
      unawaited(
        ref
            .read(analyticsServiceProvider)
            .logGameCreate(
              participantLimit: _maxParticipants,
              roundMinutes: _roundDurationMinutes,
            ),
      );

      // 게임 참가 정보 설정 (방장은 기본적으로 POLICE 팀)
      // authNotifierProvider는 signInWithGoogle/Apple 직후 서버 닉네임으로 설정되므로
      // 이 시점에 읽으면 정확한 게임 닉네임을 가져올 수 있음
      final myNickname = ref.read(authNotifierProvider).value?.nickname ?? '';
      ref
          .read(gameParticipantNotifierProvider.notifier)
          .setGameInfo(
            gameId: result.gameId,
            nickname: myNickname,
            team: GameTeam.police,
            maxParticipants: result.maxParticipants,
            locationRevealIntervalMinutes: result.locationRevealIntervalMinutes,
            isHost: true,
          );

      // 채팅방에서 온 생성이면 초대 코드를 그 방에 쏜다(#516).
      // 소켓은 로그인 수명이라 보통 붙어 있다 — 끊겼으면 초대만 조용히
      // 사라지는 게 최악이라 스낵바로 알린다. 화면 이탈 전 동기 호출(LSN-0021).
      if (widget.communityPostId != null) {
        final sent = ref
            .read(communityChatRepositoryProvider)
            .sendGameInvite(
              widget.communityPostId!,
              messageKey: const Uuid().v4(),
              inviteCode: result.inviteCode,
            );
        if (!sent) {
          AppSnackbar.show(
            context,
            message: AppLocalizations.of(context).communityChatInviteSendFailed,
          );
        }
      }

      context.go(
        '${RoutePaths.waitingRoomWithId('${result.gameId}')}?inviteCode=${result.inviteCode}&showInvite=true',
      );
      return; // 네비게이션 후 setState 불필요
    } else if (sessionState is AsyncError) {
      if (kDebugMode) {
        debugPrint('❌ [SessionCreationFlow] 세션 생성 실패: ${sessionState.error}');
      }

      // 필수 약관 미동의는 전역 인터셉터가 안내 + /agreement 리디렉트까지 처리한다.
      // 여기서는 일반 에러 스낵바가 겹치지 않도록 건너뛰기만 한다.
      if (isRequiredTermsMissingError(sessionState.error)) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      // 409: 이미 참가 중인 게임 → 해당 게임으로 자동 이동 시도
      if (_is409Conflict(sessionState.error) && mounted) {
        await _redirectToActiveGame();
        return;
      }

      if (mounted) {
        final l10n = AppLocalizations.of(context);
        final errorMessage = _getErrorMessage(l10n, sessionState.error!);
        AppSnackbar.show(
          context,
          message: errorMessage,
          backgroundColor: AppColors.red,
        );
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  /// 에러 타입별 사용자 메시지 반환
  ///
  /// [AppException]인 경우 백엔드의 RFC 7807 `detail` 메시지를 그대로 보여준다.
  /// (예: 409 → "이미 게임에 참가하고 있습니다.")
  String _getErrorMessage(AppLocalizations l10n, Object error) {
    if (error is AppException) {
      return error.message;
    }
    return l10n.errorCreateRoomFailed;
  }

  /// 에러가 409 Conflict인지 확인
  ///
  /// DioExceptionHandler가 변환한 AppException의 originalException에서
  /// HTTP 상태 코드를 꺼낸다.
  bool _is409Conflict(Object? error) {
    if (error is AppException && error.originalException is DioException) {
      final dioError = error.originalException as DioException;
      return dioError.response?.statusCode == 409;
    }
    return false;
  }

  /// 409 에러 시 활성 게임으로 자동 이동
  ///
  /// `/api/user/me/game` 조회 → 게임 상태에 따라 대기실/게임 화면 이동.
  /// 조회에 실패하면 fallback 스낵바를 띄우고 로딩 상태를 되돌린다.
  Future<void> _redirectToActiveGame() async {
    try {
      final status = await ref.read(getMyActiveGameUsecaseProvider).execute();
      if (!mounted) return;

      if (!status.isParticipating || status.participationInfo == null) {
        final l10n = AppLocalizations.of(context);
        AppSnackbar.show(
          context,
          message: l10n.errorAlreadyInGame,
          backgroundColor: AppColors.red,
        );
        setState(() => _isLoading = false);
        return;
      }

      final info = status.participationInfo!;

      if (info.gameStatus == GameStatus.waiting) {
        context.go(RoutePaths.waitingRoomWithId(info.gameId.toString()));
      } else if (info.gameStatus == GameStatus.inProgress) {
        context.go(
          '${RoutePaths.gameWithId(info.gameId.toString())}'
          '?team=${info.team}&pid=${info.participantId}',
        );
      } else {
        debugPrint(
          '⚠️ 알 수 없는 게임 상태: ${info.gameStatus} (gameId=${info.gameId})',
        );
        final l10n = AppLocalizations.of(context);
        AppSnackbar.show(
          context,
          message: l10n.errorUnknownGameState,
          backgroundColor: AppColors.red,
        );
        setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        AppSnackbar.show(
          context,
          message: l10n.errorAlreadyInGame,
          backgroundColor: AppColors.red,
        );
        setState(() => _isLoading = false);
      }
    }
  }

  // ============================================
  // Zone Result Handling
  // ============================================

  /// 플레이그라운드 설정 결과 처리
  void _onPlaygroundResult(AreaShape result) {
    setState(() {
      if (result is PolygonShape) {
        _areaType = GameAreaType.polygon;
        _playgroundPinPoints = [
          for (final point in result.points)
            LatLng(point.latitude, point.longitude),
        ];
        _playgroundCenter = null;
        _playgroundRadiusMeters = null;
      } else if (result is CircleShape) {
        _areaType = GameAreaType.circle;
        _playgroundCenter = LatLng(
          result.center.latitude,
          result.center.longitude,
        );
        _playgroundRadiusMeters = result.radiusInMeters;
        _playgroundPinPoints = null;
      }
      // 플레이그라운드 변경 시 감옥 초기화 (새 범위 내에서 재설정 필요)
      _prisonCenter = null;
      _prisonRadiusMeters = null;
      _prisonPinPoints = null;
    });
  }

  /// 감옥 설정 결과 처리
  void _onPrisonResult(AreaShape result) {
    setState(() {
      if (result is PolygonShape) {
        _prisonPinPoints = [
          for (final point in result.points)
            LatLng(point.latitude, point.longitude),
        ];
        _prisonCenter = null;
        _prisonRadiusMeters = null;
      } else if (result is CircleShape) {
        _prisonCenter = LatLng(result.center.latitude, result.center.longitude);
        _prisonRadiusMeters = result.radiusInMeters;
        _prisonPinPoints = null;
      }
    });
  }

  /// 플레이그라운드 도형 — 현재 모드 입력이 유효할 때만 non-null
  ///
  /// 원형/폴리곤 분기를 이 게터 안에 가두어, 완료 판정·버튼 표시·엔티티 조립이
  /// 같은 판단을 각자 반복하지 않게 한다.
  AreaShape? get _playgroundShape => _areaType == GameAreaType.polygon
      ? (_isValidPolygonPoints(_playgroundPinPoints)
            ? AreaShape.polygon(points: _toGeoPoints(_playgroundPinPoints!))
            : null)
      : (_playgroundCenter != null && _playgroundRadiusMeters != null
            ? AreaShape.circle(
                center: GeoPoint(
                  latitude: _playgroundCenter!.latitude,
                  longitude: _playgroundCenter!.longitude,
                ),
                radiusInMeters: _playgroundRadiusMeters!,
              )
            : null);

  /// 감옥 도형 — 현재 모드 입력이 유효할 때만 non-null
  AreaShape? get _prisonShape => _areaType == GameAreaType.polygon
      ? (_isValidPolygonPoints(_prisonPinPoints)
            ? AreaShape.polygon(points: _toGeoPoints(_prisonPinPoints!))
            : null)
      : (_prisonCenter != null && _prisonRadiusMeters != null
            ? AreaShape.circle(
                center: GeoPoint(
                  latitude: _prisonCenter!.latitude,
                  longitude: _prisonCenter!.longitude,
                ),
                radiusInMeters: _prisonRadiusMeters!,
              )
            : null);

  bool _isValidPolygonPoints(List<LatLng>? points) {
    if (points == null || points.length < GameConfig.minPolygonVertexCount) {
      return false;
    }
    return isValidPolygon(_toGeoPoints(points));
  }

  List<GeoPoint> _toGeoPoints(List<LatLng> points) => [
    for (final point in points)
      GeoPoint(latitude: point.latitude, longitude: point.longitude),
  ];

  /// 현재 입력이 유효하면 도메인 구역 엔티티로 조립한다.
  ///
  /// 도형 조립은 [_playgroundShape]·[_prisonShape]가 담당하고, 여기서는 두 구역의
  /// 포함 관계만 검증한다.
  GameAreaEntity? _buildAreaEntity() {
    final playground = _playgroundShape;
    final jail = _prisonShape;
    if (playground == null || jail == null) return null;

    if (playground is PolygonShape && jail is PolygonShape) {
      if (!isPolygonInsidePolygon(jail.points, playground.points)) return null;
      return GameAreaEntity(playground: playground, jail: jail);
    }

    if (playground is CircleShape && jail is CircleShape) {
      final centerDistance = Geolocator.distanceBetween(
        playground.center.latitude,
        playground.center.longitude,
        jail.center.latitude,
        jail.center.longitude,
      );
      if (centerDistance + jail.radiusInMeters >
          playground.radiusInMeters +
              GameConfig.zoneContainmentToleranceInMeters) {
        return null;
      }
      return GameAreaEntity(playground: playground, jail: jail);
    }

    // 타입 혼합은 서버 제약상 불가 — 도달 시 미완성으로 취급한다
    return null;
  }

  // ============================================
  // Basic Settings
  // ============================================

  void _applyValues(GameSettingValues values) {
    _maxParticipants = values[GameSettingField.participants];
    _roundDurationMinutes = values[GameSettingField.roundDuration];
    _locationShareMinutes = values[GameSettingField.locationShare];
    _policeWaitMinutes = values[GameSettingField.policeWait];
  }

  void _onBasicSubmit(GameSettingValues values) {
    _applyValues(values);
    _editTarget = null;
    _show(_CreationPhase.confirm, _Motion.down);
    unawaited(_saveDraft());
  }

  void _onSettingRowTap(GameSettingField field) {
    _editTarget = field;
    _show(_CreationPhase.edit, _Motion.up);
  }

  // ============================================
  // Build
  // ============================================

  @override
  Widget build(BuildContext context) {
    // autoDispose provider를 유지하기 위해 watch (401 토큰 재발급 중 dispose 방지)
    ref.watch(sessionCreationNotifierProvider);
    final l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleBack();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        // 상단 바는 단계가 바뀌어도 제자리에 하나만 있고, 단계 표시만 다음 칸이 차오른다
        appBar: AppTopBar(
          titleWidget: StepIndicator(
            totalSteps: 3,
            currentStep: switch (_phase) {
              _CreationPhase.playground => 0,
              _CreationPhase.jail => 1,
              _CreationPhase.confirm || _CreationPhase.edit => 2,
            },
            activeColor: AppColors.blue,
          ),
          centerTitle: false,
          titleSpacing: 0,
          // 지도 단계의 PopScope까지 거치도록 라우트 뒤로 가기로 보낸다
          onBack: () => Navigator.of(context).maybePop(),
          actions: [SizedBox(width: AppSpacing.horizontal20)],
        ),
        body: ClipRect(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            layoutBuilder: _layoutBodies,
            // 매 빌드 새 함수를 넘겨야 나가는 본문의 움직임도 이번 방향으로 다시 만든다.
            // 메서드를 그대로 넘기면 같은 함수로 보고, 들어올 때 만든 움직임을 거꾸로
            // 재생해 처음 감옥 → 확인에서 감옥이 오른쪽으로 빠졌다.
            transitionBuilder: (child, animation) =>
                _transitionBody(child, animation),
            child: KeyedSubtree(key: ValueKey(_phase), child: _buildBody(l10n)),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    final playground = _playgroundShape;
    return switch (_phase) {
      _CreationPhase.playground => SetupPlaygroundPage(
        editInitialShape: playground,
        initialCenter: widget.initialCenter,
        onDone: _onPlaygroundDone,
        onExit: _onPlaygroundExit,
      ),
      // 감옥은 플레이그라운드를 마친 뒤에만 오므로 playground가 있다
      _CreationPhase.jail => SetupPrisonPage(
        editArgs: PrisonEditArgs(
          playground: playground!,
          initialJail: _prisonShape,
        ),
        onDone: _onJailDone,
        onExit: _onJailExit,
      ),
      _CreationPhase.confirm => SafeArea(child: _buildConfirmPhase(l10n)),
      // 키패드가 하단 인셋까지 배경으로 채우므로 하단 세이프 에어리어를 푼다 (#539)
      _CreationPhase.edit => SafeArea(
        bottom: false,
        child: _buildEditPhase(l10n, _editTarget!),
      ),
    };
  }

  /// 닫히는 고치기 화면은 확인 화면 위에서 내려가야 하므로 맨 위에 둔다
  Widget _layoutBodies(Widget? current, List<Widget> previous) => Stack(
    fit: StackFit.expand,
    children: _motion == _Motion.down
        ? [?current, ...previous]
        : [...previous, ?current],
  );

  /// 들어오는 본문과 나가는 본문의 움직임 (#658 전환 B안)
  ///
  /// 나가는 본문은 컨트롤러가 1→0으로 거꾸로 돌므로, Tween(begin: 나간 자리,
  /// end: 제자리)로 두면 제자리에서 나간 자리로 움직인다.
  Widget _transitionBody(Widget child, Animation<double> animation) {
    final isIncoming = child.key == ValueKey(_phase);
    final (Offset inFrom, Offset outTo) = switch (_motion) {
      _Motion.none => (Offset.zero, Offset.zero),
      _Motion.forward => (const Offset(1, 0), const Offset(-0.3, 0)),
      _Motion.back => (const Offset(-1, 0), const Offset(0.3, 0)),
      _Motion.up => (const Offset(0, 1), Offset.zero),
      _Motion.down => (Offset.zero, const Offset(0, 1)),
    };
    final tween = Tween(
      begin: isIncoming ? inFrom : outTo,
      end: Offset.zero,
    ).chain(CurveTween(curve: Curves.easeInOut));
    // 확인·고치기 본문은 바탕이 없어, 덮지 않으면 나가는 지도가 비쳐 지나간다
    return SlideTransition(
      position: animation.drive(tween),
      child: ColoredBox(color: AppColors.white, child: child),
    );
  }

  /// 화면 제목 영역 (시안: 상단 바에서 28, 제목 20px, 간격 10, 보조 14px)
  Widget _buildHeader(AppLocalizations l10n, String title, String description) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.horizontal24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: AppSpacing.vertical28),
          Text(
            title,
            style: AppTextStyles.heading_20.copyWith(color: AppColors.black),
          ),
          SizedBox(height: 10.h),
          Text(
            description,
            style: AppTextStyles.paragraph_14_100.copyWith(
              color: AppColors.black600,
            ),
          ),
          SizedBox(height: AppSpacing.vertical20),
        ],
      ),
    );
  }

  // 고치는 화면은 확인 화면에 들어갈 때마다 빠졌다가 새로 만들어지므로
  // 폼 상태가 이전 수정에서 이어지지 않는다
  Widget _buildEditPhase(AppLocalizations l10n, GameSettingField target) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(
          l10n,
          l10n.sessionCreationStepBasicTitle,
          l10n.sessionCreationStepBasicHint,
        ),
        Expanded(
          child: BasicSettingsForm(
            initialParticipants: _maxParticipants,
            initialRoundDuration: _roundDurationMinutes,
            initialLocationShare: _locationShareMinutes,
            initialPoliceWait: _policeWaitMinutes,
            editTarget: target,
            onSubmit: _onBasicSubmit,
          ),
        ),
      ],
    );
  }

  /// 확인 화면 맨 위 구역 축소 카드 (#668 시안 위치)
  Widget _buildShrinkCard(GameAreaEntity area) {
    final playground = area.playground;
    return ShrinkToggleCard(
      enabled: _shrinkEnabled,
      lock: shrinkLockFor(area),
      startRadius: playground is CircleShape
          ? playground.radiusInMeters.round()
          : 0,
      finalRadius: _shrinkFinalRadius(area),
      onChanged: (value) {
        setState(() => _shrinkEnabled = value);
        unawaited(_saveDraft());
      },
    );
  }

  Widget _buildConfirmPhase(AppLocalizations l10n) {
    final area = _buildAreaEntity();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(
          l10n,
          l10n.sessionCreationStepReviewTitle,
          l10n.sessionCreationStepReviewHint,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.horizontal20),
            child: area == null
                ? Center(child: Text(l10n.errorZoneNotConfigured))
                : Column(
                    children: [
                      _buildShrinkCard(area),
                      SizedBox(height: AppSpacing.vertical8),
                      ZoneListCard(
                        area: area,
                        onTapPlayground: _editPlaygroundFromConfirm,
                        onTapJail: _editJailFromConfirm,
                      ),
                      SizedBox(height: AppSpacing.vertical8),
                      SettingListCard(
                        settings: SessionSettings(
                          maxPlayers: _maxParticipants,
                          roundTimeMinutes: _roundDurationMinutes,
                          locationShareMinutes: _locationShareMinutes,
                          policeStartDelayMinutes: _policeWaitMinutes,
                        ),
                        onTapField: _onSettingRowTap,
                      ),
                    ],
                  ),
          ),
        ),
        Padding(
          padding: AppPadding.all20,
          child: AppButton(
            text: l10n.buttonCreateRoom,
            onPressed: area != null && !_isLoading
                ? _createSessionAndNavigate
                : null,
            isLoading: _isLoading,
          ),
        ),
      ],
    );
  }
}
