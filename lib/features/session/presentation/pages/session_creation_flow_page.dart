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
import 'setup_prison_page.dart';

/// 방 생성 흐름의 단계
enum _CreationPhase {
  /// 지도에서 구역을 그리는 중 (플레이그라운드·감옥 페이지가 위에 떠 있다)
  zone,

  /// 기본 정보 입력 (한 항목씩 묻고 쌓기)
  basic,

  /// 최종 확인 (행을 탭하면 해당 화면으로 되돌아가 수정)
  confirm,
}

/// 세션 생성 플로우 페이지
///
/// 생성을 누르면 바로 플레이그라운드 지도로 들어가고, 감옥 지도와 기본 정보
/// 입력을 거쳐 최종 확인에서 방을 만든다. 최종 확인의 각 행을 탭하면 해당
/// 화면으로 이동해 고칠 수 있다.
///
/// 임시 저장(SessionDraftStorageService)은 숫자 값을 조용히 복원하고, 구역은
/// 지도를 열 때 이전 도형이 그려진 채로 연다.
class SessionCreationFlowPage extends ConsumerStatefulWidget {
  const SessionCreationFlowPage({this.communityPostId, super.key});

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

  _CreationPhase _phase = _CreationPhase.zone;

  /// 최종 확인에서 항목 하나를 고치러 기본 정보로 들어왔을 때의 대상
  GameSettingField? _editTarget;

  /// 최종 확인에서 뒤로 와서 네 항목이 펼쳐진 채 시작하는지
  bool _revealAllOnBasic = false;

  /// 기본 정보 폼 상태 접근용. 폼을 새로 시작할 때마다 새 키로 갈아 상태를 재생성한다.
  GlobalKey<BasicSettingsFormState> _formKey =
      GlobalKey<BasicSettingsFormState>();

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
  int _maxParticipants = 10;
  int _roundDurationMinutes = 30;
  int _locationShareMinutes = 5;
  int _policeWaitMinutes = 5;

  // ============================================
  // Lifecycle
  // ============================================

  @override
  void initState() {
    super.initState();
    _storageService = SessionDraftStorageService();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadDraftData();
      if (!mounted) return;
      // 생성 진입 즉시 구역 설정(지도)으로 들어간다
      await _runZoneSetup(returnToConfirm: false);
    });
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
        _maxParticipants = draft.maxParticipants ?? 10;
        _roundDurationMinutes = draft.roundDurationMinutes ?? 30;
        _locationShareMinutes = draft.locationShareMinutes ?? 5;
        _policeWaitMinutes = (draft.policeWaitMinutes ?? 5).clamp(1, 10);
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
    );
    await _storageService.saveDraft(draft);
  }

  // ============================================
  // Zone Setup Navigation
  // ============================================

  /// 플레이그라운드 → 감옥 순서로 지도를 연다.
  ///
  /// 감옥에서 뒤로 가면 플레이그라운드로 되돌아가고, 플레이그라운드에서 뒤로
  /// 가면 흐름을 끝낸다([returnToConfirm] 이면 최종 확인으로 복귀).
  /// 이전에 그린 도형은 초기값으로 넘겨 지도에 그려진 채로 열린다.
  Future<void> _runZoneSetup({required bool returnToConfirm}) async {
    while (true) {
      if (!mounted) return;
      final playground = await context.pushNamed<AreaShape>(
        RoutePaths.setupPlaygroundFromFlowName,
        extra: _playgroundShape,
      );
      if (!mounted) return;
      if (playground == null) {
        if (returnToConfirm) {
          setState(() => _phase = _CreationPhase.confirm);
        } else {
          context.pop();
        }
        return;
      }
      _onPlaygroundResult(playground);
      await _saveDraft();
      if (!mounted) return;

      final prison = await context.pushNamed<AreaShape>(
        RoutePaths.setupPrisonFromFlowName,
        extra: PrisonEditArgs(playground: playground),
      );
      if (!mounted) return;
      if (prison == null) continue; // 감옥에서 뒤로 → 플레이그라운드부터 다시
      _onPrisonResult(prison);
      await _saveDraft();
      break;
    }
    if (!mounted) return;
    setState(() {
      _formKey = GlobalKey<BasicSettingsFormState>();
      _revealAllOnBasic = false;
      _phase = returnToConfirm ? _CreationPhase.confirm : _CreationPhase.basic;
    });
  }

  /// 최종 확인에서 감옥만 고치러 들어간다
  Future<void> _editPrisonOnly() async {
    final playground = _playgroundShape;
    if (playground == null) return;
    final prison = await context.pushNamed<AreaShape>(
      RoutePaths.setupPrisonFromFlowName,
      extra: PrisonEditArgs(playground: playground, initialJail: _prisonShape),
    );
    if (!mounted || prison == null) return;
    _onPrisonResult(prison);
    await _saveDraft();
    if (mounted) setState(() {});
  }

  /// 기본 정보 첫 항목에서 뒤로 → 감옥 지도로 되돌아간다
  Future<void> _reenterZoneFromBasic() async {
    final playground = _playgroundShape;
    if (playground == null) {
      await _runZoneSetup(returnToConfirm: false);
      return;
    }
    final prison = await context.pushNamed<AreaShape>(
      RoutePaths.setupPrisonFromFlowName,
      extra: PrisonEditArgs(playground: playground, initialJail: _prisonShape),
    );
    if (!mounted) return;
    if (prison == null) {
      // 감옥에서 또 뒤로 → 플레이그라운드부터
      await _runZoneSetup(returnToConfirm: false);
      return;
    }
    _onPrisonResult(prison);
    await _saveDraft();
    if (mounted) {
      setState(() {
        _formKey = GlobalKey<BasicSettingsFormState>();
        _revealAllOnBasic = false;
        _phase = _CreationPhase.basic;
      });
    }
  }

  // ============================================
  // Back Handling
  // ============================================

  void _handleBack() {
    switch (_phase) {
      case _CreationPhase.zone:
        // 지도가 떠 있는 동안 이 페이지가 직접 받을 일은 없지만, 혹시 받으면 홈으로
        context.pop();
      case _CreationPhase.basic:
        if (_formKey.currentState?.handleBack() ?? false) return;
        if (_editTarget != null) {
          // 고치러 들어온 경우 → 반영하지 않고 최종 확인으로
          setState(() {
            _editTarget = null;
            _phase = _CreationPhase.confirm;
          });
          return;
        }
        unawaited(_reenterZoneFromBasic());
      case _CreationPhase.confirm:
        // 전 항목이 펼쳐진 기본 정보로 되돌아간다. 항목 수정 모드가 아니라
        // 생성 흐름의 뒤로가기 규칙을 따라 계속 되짚을 수 있는 상태다.
        setState(() {
          _editTarget = null;
          _revealAllOnBasic = true;
          _formKey = GlobalKey<BasicSettingsFormState>();
          _phase = _CreationPhase.basic;
        });
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
    setState(() {
      _applyValues(values);
      _editTarget = null;
      _phase = _CreationPhase.confirm;
    });
    unawaited(_saveDraft());
  }

  void _onBasicValuesChanged(GameSettingValues values) {
    // 항목 하나를 고치는 모드에서는 확인을 눌러야 반영된다.
    // 여기서도 반영하면 뒤로 가기(취소)가 취소가 아니게 된다.
    if (_editTarget != null) return;
    _applyValues(values);
    unawaited(_saveDraft());
  }

  void _onSettingRowTap(GameSettingField field) {
    setState(() {
      _editTarget = field;
      _revealAllOnBasic = false;
      _formKey = GlobalKey<BasicSettingsFormState>();
      _phase = _CreationPhase.basic;
    });
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
        appBar: AppTopBar(
          titleWidget: StepIndicator(
            totalSteps: 3,
            currentStep: switch (_phase) {
              _CreationPhase.zone => 0,
              _CreationPhase.basic => 1,
              _CreationPhase.confirm => 2,
            },
            activeColor: AppColors.blue,
          ),
          centerTitle: false,
          titleSpacing: 0,
          onBack: _handleBack,
          actions: [SizedBox(width: AppSpacing.horizontal20)],
        ),
        body: SafeArea(
          // 기본 정보 단계는 키패드가 하단 인셋까지 배경으로 채우므로
          // 하단 세이프 에어리어를 풀어 흰 띠가 생기지 않게 한다 (#539)
          bottom: _phase != _CreationPhase.basic,
          child: switch (_phase) {
            _CreationPhase.zone => const SizedBox.shrink(),
            _CreationPhase.basic => _buildBasicPhase(l10n),
            _CreationPhase.confirm => _buildConfirmPhase(l10n),
          },
        ),
      ),
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

  Widget _buildBasicPhase(AppLocalizations l10n) {
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
            key: _formKey,
            initialParticipants: _maxParticipants,
            initialRoundDuration: _roundDurationMinutes,
            initialLocationShare: _locationShareMinutes,
            initialPoliceWait: _policeWaitMinutes,
            editTarget: _editTarget,
            revealAll: _revealAllOnBasic,
            onSubmit: _onBasicSubmit,
            onValuesChanged: _onBasicValuesChanged,
          ),
        ),
      ],
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
                      ZoneListCard(
                        area: area,
                        onTapPlayground: () =>
                            unawaited(_runZoneSetup(returnToConfirm: true)),
                        onTapJail: () => unawaited(_editPrisonOnly()),
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
