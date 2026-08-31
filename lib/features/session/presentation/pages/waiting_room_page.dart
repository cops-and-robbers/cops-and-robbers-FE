import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/loading/app_loading.dart';
import '../../../../core/widgets/loading/shimmer_participant_skeleton.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/i18n/error_message_mapper.dart';
import '../../../../core/network/dio_exception_handler.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/dev_flags.dart';
import '../../../../core/constants/game_status.dart';
import '../../../../core/constants/game_team.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/utils/share_util.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/buttons/flat_icon_button.dart';
import '../../../../core/widgets/dialogs/app_dialog.dart';
import '../../../../core/widgets/dialogs/reconnect_modal.dart';
import '../../../../core/widgets/dividers/solid_divider.dart';
import '../../../../core/services/analytics/analytics_service.dart';
import '../../../../core/services/loading_message_service.dart';
import '../../../../core/services/vibration_service.dart';
import '../../../../core/widgets/snackbars/app_snackbar.dart';
import '../../../../core/theme/role_theme_provider.dart';
import '../../../../core/services/permission/location_permission_messages.dart';
import '../../../../core/services/permission/location_permission_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../router/route_paths.dart';
import '../../../lobby/data/datasources/lobby_stomp_datasource.dart'
    show StompConnectionState;
import '../../../lobby/data/models/lobby_event_dto.dart';
import '../../../lobby/presentation/providers/lobby_provider.dart';
import '../../data/models/game_settings_response.dart';
import '../../data/models/lobby_info_response.dart';
import '../providers/game_participant_provider.dart';
import '../providers/session_provider.dart';
import '../providers/waiting_room_participants_provider.dart';
import '../../../../core/services/tutorial/tutorial_keys.dart';
import '../../../../core/services/tutorial/tutorial_service.dart';
import '../../../../core/tutorial/app_tutorial_style.dart';
import '../widgets/game_rules_content.dart';
import '../widgets/team_section.dart';

/// 대기실 화면
///
/// 게임 시작 전 참가자들이 팀을 선택하고 준비 완료를 표시합니다.
class WaitingRoomPage extends ConsumerStatefulWidget {
  const WaitingRoomPage({
    required this.sessionId,
    this.inviteCode,
    this.showInviteDialog = false,
    super.key,
  });

  /// 게임 세션 ID
  final String sessionId;

  /// 초대 코드 (앱바 표시용, 예: "HJRVBD")
  final String? inviteCode;

  /// 방 생성 직후 초대코드 모달 표시 여부
  final bool showInviteDialog;

  @override
  ConsumerState<WaitingRoomPage> createState() => _WaitingRoomPageState();
}

class _WaitingRoomPageState extends ConsumerState<WaitingRoomPage>
    with WidgetsBindingObserver {
  /// 초대 코드 (API 응답 후 업데이트 가능)
  String? _inviteCode;

  /// 팀 섹션 펼침 상태
  bool _isPoliceExpanded = true;
  bool _isRobberExpanded = true;

  /// 준비 상태
  bool _isReady = false;
  bool _isUpdatingReady = false;

  /// 참가자 초기화 중복 실행 방지
  bool _isFetchingParticipants = false;

  /// resumed 시 게임 상태 확인 중복 실행 방지
  bool _isCheckingGameStatus = false;

  /// 초대코드 다이얼로그 대기 여부 (API 응답 후 1회 표시)
  bool _pendingInviteDialog = false;

  /// 더미 모드 여부
  bool get _isDummyMode => int.tryParse(widget.sessionId) == null;

  /// 위치 권한 미허용 상태
  bool _isLocationPermissionDenied = false;

  /// 더미 모드에서 "나"의 participantId
  static const _dummyMyId = 3;

  /// 로비 이벤트 구독 (dispose 시 명시적 해제)
  ProviderSubscription<LobbyState>? _lobbyEventSub;

  /// dispose 여부 (microtask 큐에 남은 이벤트가 dispose 후 처리되는 것을 방지)
  bool _isDisposed = false;

  /// 재연결 모달 표시 중 여부 (중복 표시 방지)
  bool _isReconnectModalShown = false;

  /// 강퇴/게임 삭제로 not-participating 처리 중 여부.
  /// true일 때는 _showReconnectModal이 막혀 재표시되지 않는다.
  /// ReconnectModal.then()의 재귀 호출이 우리 안내 다이얼로그를 우회하지 못하도록.
  bool _isHandlingNotParticipating = false;

  /// 로비 STOMP 최초 연결 성공 여부
  bool _hasLobbyConnectedOnce = false;

  // ── 튜토리얼용 GlobalKey ──────────────────────────────────────────────────
  /// 팀 변경 버튼 (경찰팀 AddSlotCard)
  final _tutorialKeyAddSlotPolice = GlobalKey();

  /// 팀 변경 버튼 (도둑팀 AddSlotCard)
  final _tutorialKeyAddSlotRobber = GlobalKey();

  /// 준비 완료 / 게임 시작 버튼
  final _tutorialKeyReadyButton = GlobalKey();

  /// 앱바 초대 코드 영역
  final _tutorialKeyInviteCode = GlobalKey();

  /// 앱바 게임 규칙 버튼
  final _tutorialKeyGameRules = GlobalKey();

  /// 현재 표시 중인 튜토리얼 컨트롤러
  ///
  /// 참가자 변경으로 레이아웃이 밀렸을 때 `refresh()`로 타겟 좌표를 다시
  /// 계산하기 위해 보관한다. 튜토리얼 종료 시 null 처리.
  AppTutorialController? _tutorialController;

  /// 튜토리얼 표시 상태
  ///
  /// STOMP 재연결로 `_fetchAndInitParticipants()`가 여러 번 호출될 때
  /// `TutorialService.markCompleted()` 기록 이전이라도 중복 오버레이가
  /// 쌓이지 않도록 로컬 플래그로 차단한다.
  bool _isTutorialShowing = false;

  /// 초대코드 다이얼로그가 화면에 떠 있는 동안 true.
  ///
  /// 방장 플로우에서 [_showInviteCodeDialog] 실행 중 STOMP 이벤트로
  /// 트리거된 [_showTutorialIfNeeded] 가 다이얼로그 위에 튜토리얼을
  /// 오버레이하는 경쟁 상태를 막기 위한 가드.
  bool _isInviteDialogOpen = false;
  // ─────────────────────────────────────────────────────────────────────────

  /// 재연결 모달에 전달하는 현재 연결 상태 Notifier
  ValueNotifier<StompConnectionState>? _reconnectStateNotifier;

  @override
  void initState() {
    super.initState();
    _inviteCode = widget.inviteCode;
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureLocationAndInit();
    });
  }

  /// 위치 권한 확인 후 대기방 초기화
  ///
  /// 위치 권한이 없으면 권한 요청 다이얼로그를 표시하고,
  /// 허용될 때까지 로비 연결을 보류합니다.
  Future<void> _ensureLocationAndInit() async {
    final canAccess = await LocationPermissionService.canAccessLocation();
    if (!mounted) return;

    if (canAccess) {
      _initWaitingRoom();
      return;
    }

    setState(() => _isLocationPermissionDenied = true);
    await _showLocationPermissionDialog();
  }

  /// 위치 권한 요청 다이얼로그
  Future<void> _showLocationPermissionDialog() async {
    final serviceEnabled = await LocationPermissionService.isServiceEnabled();
    if (!mounted) return;

    final text = LocationPermissionMessages.getText(
      context: context,
      isServiceDisabled: !serviceEnabled,
      locationContext: LocationPermissionContext.waitingRoom,
    );

    final isDark = ref.read(roleThemeProvider);

    final l10n = AppLocalizations.of(context);
    AppDialog.show(
      context: context,
      title: text.title,
      message: text.message,
      confirmText: l10n.buttonGoToSettings,
      cancelText: l10n.buttonLeave,
      barrierDismissible: false,
      isDarkMode: isDark,
      onConfirm: () async {
        if (!serviceEnabled) {
          await LocationPermissionService.openLocationSettings();
        } else {
          await LocationPermissionService.openAppSettings();
        }
        if (mounted) await _ensureLocationAndInit();
      },
      onCancel: () {
        if (mounted) _leaveRoom();
      },
    );
  }

  /// 앱 포그라운드 복귀 시 위치 권한 재확인
  ///
  /// 대기방에서 설정으로 이동해 위치 권한을 끄고 돌아온 경우,
  /// 권한 요청 다이얼로그를 표시합니다.
  /// 권한 허용 후에는 앱 재시작이 필요합니다.
  Future<void> _checkLocationPermissionOnResume() async {
    if (_isLocationPermissionDenied) return;

    final canAccess = await LocationPermissionService.canAccessLocation();
    if (!mounted || canAccess) return;

    setState(() => _isLocationPermissionDenied = true);
    await _showLocationPermissionDialog();
  }

  /// 대기방 초기화 (위치 권한 확보 후 실행)
  void _initWaitingRoom() {
    if (_isLocationPermissionDenied) {
      setState(() => _isLocationPermissionDenied = false);
    }

    // 초대코드 다이얼로그는 API 응답 후 팀 정보가 확정된 시점에 표시
    _pendingInviteDialog = widget.showInviteDialog && _inviteCode != null;

    _listenLobbyEvents();
    _connectLobby();
  }

  @override
  void dispose() {
    _isDisposed = true;
    // 페이지 사라질 때 떠 있는 튜토리얼 오버레이를 정리
    if (_tutorialController?.isShowing == true) {
      _tutorialController!.finish();
    }
    _tutorialController = null;
    _isTutorialShowing = false;
    _isInviteDialogOpen = false;
    _reconnectStateNotifier?.dispose();
    _reconnectStateNotifier = null;
    _lobbyEventSub?.close();
    _lobbyEventSub = null;
    WidgetsBinding.instance.removeObserver(this);
    // ref.read()는 ConsumerStatefulElement.unmount() 이후 호출 불가.
    // lobbyNotifierProvider / waitingRoomParticipantsProvider 모두 @riverpod
    // (autoDispose)이므로 WaitingRoomPage가 사라지면 자동으로 정리됨.
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkLocationPermissionOnResume();
      _checkStatusOnResume();
    } else if (state == AppLifecycleState.detached) {
      // 앱 종료 시 best-effort로 퇴장 시도
      final gameId = int.tryParse(widget.sessionId);
      if (gameId != null) {
        ref.read(leaveGameProvider(gameId).future);
      }
    }
  }

  /// resumed 복귀 시 게임 상태 확인 후 화면 분기 또는 소켓 재연결
  ///
  /// - 게임 시작됨 → 게임 화면으로 이동
  /// - 강퇴/게임 종료 → 홈으로 이동
  /// - 여전히 대기 중 → 소켓이 끊겼으면 재연결
  Future<void> _checkStatusOnResume() async {
    if (_isCheckingGameStatus || _isDummyMode) return;
    _isCheckingGameStatus = true;
    try {
      final status = await ref.read(getMyActiveGameUsecaseProvider).execute();
      if (_isDisposed || !mounted) return;

      final info = status.participationInfo;

      if (!status.isParticipating || info == null) {
        // 강퇴 또는 게임 종료 → 홈
        ref.read(gameParticipantNotifierProvider.notifier).clear();
        ref.read(waitingRoomParticipantsProvider.notifier).clear();
        context.go(RoutePaths.home);
      } else if (info.gameStatus == GameStatus.inProgress) {
        // 게임 시작됨 → 게임 설정 재조회로 gameStartTime 확보 후 게임 화면으로 이동
        final gameId = int.tryParse(widget.sessionId);
        if (gameId != null) {
          try {
            ref.invalidate(fetchGameSettingsProvider(gameId));
            final settings = await ref.read(
              fetchGameSettingsProvider(gameId).future,
            );
            if (!_isDisposed && mounted && settings.gameStartTime != null) {
              ref
                  .read(gameParticipantNotifierProvider.notifier)
                  .setGameStartTime(settings.gameStartTime!);
            }
          } catch (_) {
            // 실패해도 게임 화면으로 이동은 계속 진행
          }
        }
        if (_isDisposed || !mounted) return;
        final team = info.team;
        final participantId = info.participantId;
        context.go(
          '${RoutePaths.gameWithId(info.gameId.toString())}?team=$team&pid=$participantId',
        );
      } else {
        // WAITING → 로비 소켓 재연결 (필요한 경우에만)
        _reconnectLobbyIfNeeded();
      }
    } catch (_) {
      // API 실패 시 현재 화면 유지 (무시)
    } finally {
      _isCheckingGameStatus = false;
    }
  }

  /// resumed 복귀 시 로비 소켓 재연결 (필요한 경우에만)
  void _reconnectLobbyIfNeeded() {
    final gameId = int.tryParse(widget.sessionId);
    if (gameId == null) return;

    final connState = ref.read(lobbyNotifierProvider).connectionState;
    if (connState != StompConnectionState.connected &&
        connState != StompConnectionState.connecting) {
      ref
          .read(lobbyNotifierProvider.notifier)
          .connectAndSubscribe(gameId: gameId, onGameStart: _onGameStartEvent);
    }
  }

  /// Lobby STOMP 연결
  Future<void> _connectLobby() async {
    final gameId = int.tryParse(widget.sessionId);
    if (gameId == null) {
      // 숫자가 아닌 sessionId (임시 UI 확인용) → 더미 데이터 + 방장으로 세팅
      ref.read(waitingRoomParticipantsProvider.notifier).loadDummyData();
      // 더미 닉네임은 매핑된 l10n 키를 사용해 다국어 출력을 일관되게 유지한다.
      final l10n = AppLocalizations.of(context);
      ref
          .read(gameParticipantNotifierProvider.notifier)
          .setGameInfo(
            gameId: 0,
            nickname: l10n.dummyNicknameBear,
            participantId: _dummyMyId,
            isHost: true,
          );
      // 더미 모드에서도 초대코드 다이얼로그 표시
      if (_pendingInviteDialog && mounted) {
        _pendingInviteDialog = false;
        await _showInviteCodeDialog();
      }
      return;
    }

    // STOMP 연결 시작 (초기 참가자 목록은 connected 이벤트 시 로드)
    await ref
        .read(lobbyNotifierProvider.notifier)
        .connectAndSubscribe(gameId: gameId, onGameStart: _onGameStartEvent);
  }

  /// REST API로 초기 참가자 목록 및 게임 설정 로드
  ///
  /// STOMP connected 이벤트 발생 시 호출하여 서버의 최신 상태를 가져옵니다.
  /// 로비 조회와 게임 설정 조회를 병렬로 실행하며, 각각 독립적으로 에러를 처리합니다.
  /// fetchGameSettings가 실패해도 참가자 목록은 정상 표시됩니다.
  /// 재연결 루프에서 동시에 여러 번 호출되는 것을 방지하기 위해
  /// [_isFetchingParticipants] 가드를 사용합니다.
  Future<void> _fetchAndInitParticipants() async {
    if (_isFetchingParticipants || _isDisposed) return;

    final gameId = int.tryParse(widget.sessionId);
    if (gameId == null) return;

    _isFetchingParticipants = true;
    try {
      // 두 API를 병렬로 시작
      final lobbyFuture = ref.read(fetchLobbyInfoProvider(gameId).future);
      final settingsFuture = ref.read(fetchGameSettingsProvider(gameId).future);

      // 각 API 독립 에러 처리 (한쪽 실패가 다른 쪽을 막지 않음)
      LobbyInfoResponse? lobbyInfo;
      GameSettingsResponse? settings;

      try {
        lobbyInfo = await lobbyFuture;
      } on DioException catch (e) {
        // 404 "참가자 아님" — 강퇴/게임 삭제/세션 만료 등으로 더 이상 참가자가 아닌 경우.
        // 무한 로딩과 STOMP 재연결 루프를 막고 사용자를 홈으로 안내한다.
        if (e.response?.statusCode == 404 && mounted && !_isDisposed) {
          await _handleNotParticipating(DioExceptionHandler.handle(e));
          return;
        }
        debugPrint('[WaitingRoomPage] 로비 조회 실패: $e');
      } catch (e) {
        debugPrint('[WaitingRoomPage] 로비 조회 실패: $e');
      }
      try {
        settings = await settingsFuture;
      } catch (e) {
        debugPrint('[WaitingRoomPage] 게임 설정 조회 실패: $e');
      }

      // await 후 위젯이 dispose됐을 수 있으므로 mounted로 이중 확인
      if (_isDisposed || !mounted || lobbyInfo == null) return;

      // 재접속 시 inviteCode를 API에서 가져와 AppBar에 표시
      final fetchedCode = lobbyInfo.inviteCode;
      if (_inviteCode == null && fetchedCode != null) {
        setState(() => _inviteCode = fetchedCode);
      }

      // 로비 참가자 목록에서 내 정보 추출
      final myPid = lobbyInfo.myParticipantId;
      final isHost = myPid == lobbyInfo.hostParticipantId;
      final myTeam = lobbyInfo.participants
          .where((p) => p.participantId == myPid)
          .map((p) => p.team)
          .firstOrNull;

      ref
          .read(waitingRoomParticipantsProvider.notifier)
          .initFromApi(
            participants: lobbyInfo.participants,
            hostParticipantId: lobbyInfo.hostParticipantId,
          );

      if (_isDisposed || !mounted) return;

      // 다시하기로 재진입 시 clear()로 state가 null이면 initFromLobby()가 early return함.
      // 먼저 setGameInfo()로 state를 초기화하여 이후 initFromLobby()가 정상 동작하도록 보장.
      if (ref.read(gameParticipantNotifierProvider) == null) {
        final myNickname =
            lobbyInfo.participants
                .where((p) => p.participantId == myPid)
                .map((p) => p.nickname)
                .firstOrNull ??
            '';
        ref
            .read(gameParticipantNotifierProvider.notifier)
            .setGameInfo(gameId: gameId, nickname: myNickname, isHost: isHost);
      }

      ref
          .read(gameParticipantNotifierProvider.notifier)
          .initFromLobby(
            participantId: myPid,
            team: myTeam,
            maxParticipants: settings?.maxParticipants,
            locationRevealIntervalMinutes:
                settings?.locationRevealIntervalMinutes,
            policeWaitMinutes: settings?.policeWaitMinutes,
            roundTimeMinutes: settings?.roundDurationMinutes,
            hostParticipantId: lobbyInfo.hostParticipantId,
            // 이벤트방 여부를 participant에 주입 — 시작 버튼 게이팅 완화에 필요.
            // GET /games/{id} settings의 isEventGame(DB 필드) 기준. 미포함 시 false.
            isEventGame:
                (settings?.isEventGame ?? false) || kEventGameDevOverride,
          );

      // isHost는 initFromLobby()에서 갱신되지 않으므로 항상 서버 기준으로 명시적 설정
      ref.read(gameParticipantNotifierProvider.notifier).setIsHost(isHost);

      // 방 생성 직후 초대코드 다이얼로그 표시 (팀 확정 후)
      // 다이얼로그 닫힌 후 튜토리얼 트리거 (겹침 방지)
      if (_pendingInviteDialog && mounted) {
        _pendingInviteDialog = false;
        await _showInviteCodeDialog();
      }

      // 튜토리얼 트리거 단일 진입점.
      // 단일 키 정책으로 팀 변경 재트리거 리스너가 제거되었으므로, 본 호출이
      // 유일한 진입 경로다. STOMP 재연결 등으로 _fetchAndInitParticipants 가
      // 여러 번 호출되어도 _isTutorialShowing 가드와 isCompleted 가드로
      // 중복 노출이 차단된다.
      if (mounted && myTeam != null) {
        _showTutorialIfNeeded(myTeam);
      }
    } finally {
      _isFetchingParticipants = false;
    }
  }

  /// 강퇴/게임 삭제/세션 만료 등으로 더 이상 게임 참가자가 아닐 때:
  ///   1) LobbyNotifier의 STOMP 재연결 루프를 명시적으로 끊고
  ///   2) i18n 메시지(errorCode 기반)를 안내하고
  ///   3) 확인 시 홈으로 이동시킨다.
  ///
  /// 클라이언트는 KICKED 이벤트를 직접 받지 않아 강퇴 단정은 위험하므로,
  /// "강퇴" 단어 대신 "방에 참여할 수 없어요"로 톤을 부드럽게 한다.
  Future<void> _handleNotParticipating(AppException? appException) async {
    if (_isDisposed || !mounted) return;

    // 진행 플래그 셋팅 — _showReconnectModal.then() 재귀 호출과 외부 listener가
    // 이 흐름 도중 ReconnectModal을 다시 표시하지 못하도록 차단한다.
    _isHandlingNotParticipating = true;

    // Lobby listener 사전 정리 — disconnectLobby가 state를 초기 disconnected 로
    // 되돌리면서 _lobbyEventSub 콜백이 한 번 더 fire되어 _showReconnectModal /
    // _fetchAndInitParticipants 가 dead path로 진입하는 것을 차단한다.
    // (홈 라우팅 후 dead ref/notifier 사용으로 인한 폭발 방지)
    _lobbyEventSub?.close();
    _lobbyEventSub = null;

    // STOMP 재연결 백오프 차단 (intentionalDisconnect 신호).
    // 이 호출 없으면 서버가 lobby 구독을 권한 없음으로 거절하는 동안
    // LobbyNotifier가 일반 disconnect로 인식해 무한 재시도한다.
    ref.read(lobbyNotifierProvider.notifier).disconnectLobby();

    // STOMP ERROR가 HTTP 404보다 먼저 도착해 ReconnectModal이 이미 떠있을 수 있다.
    // 같이 두면 사용자가 우리 안내 다이얼로그에서 홈으로 가도 ReconnectModal이 남아
    // dead ref 호출로 폭발한다. 우리 안내 표시 전에 명시적으로 닫는다.
    if (_isReconnectModalShown && mounted) {
      // ReconnectModal은 showGeneralDialog 기본값(useRootNavigator: true)으로 root에 push되므로
      // 동일하게 root navigator로 pop해야 ReconnectModal이 닫힌다.
      Navigator.of(context, rootNavigator: true).pop();
      _isReconnectModalShown = false;
      _reconnectStateNotifier?.dispose();
      _reconnectStateNotifier = null;
    }

    final l10n = AppLocalizations.of(context);
    // 백엔드 한국어 detail 대신 i18n 메시지 사용 (errorCode 기반)
    final dialogMessage = appException != null
        ? l10n.errorByException(appException)
        : l10n.errorNotInGame;
    await AppDialog.show(
      context: context,
      title: l10n.errorCannotJoinRoom,
      message: dialogMessage,
      confirmText: l10n.buttonConfirm,
      barrierDismissible: false,
      // 도둑팀 사용자의 다크 화면 위에 라이트 다이얼로그가 뜨는 부조화 방지
      isDarkMode: ref.read(roleThemeProvider),
      onConfirm: () {
        if (mounted) context.go(RoutePaths.home);
      },
    );
  }

  /// 사용자 액션 catch 공통 처리: 404 "참가자 아님" 이면 [_handleNotParticipating]
  /// 흐름으로, 그 외에는 errorCode 기반 i18n 메시지(errorByException)로 스낵바 표시.
  ///
  /// 호출자는 결과를 분기할 필요 없이 await만 하면 된다. 404 흐름은 내부에서
  /// 다이얼로그 → 홈 라우팅까지 완료한다.
  Future<void> _handleApiErrorOrNotParticipating(DioException e) async {
    if (_isDisposed) return;
    // DioException → AppException 변환 (i18n 메시지 해석에 사용)
    final ex = DioExceptionHandler.handle(e);
    if (e.response?.statusCode == 404 && mounted) {
      await _handleNotParticipating(ex);
      return;
    }
    if (mounted && !_isDisposed) {
      // 백엔드 한국어 detail 대신 i18n 메시지 사용 (errorCode 기반)
      final l10n = AppLocalizations.of(context);
      AppSnackbar.show(
        context,
        message: l10n.errorByException(ex),
        backgroundColor: AppColors.red,
      );
    }
  }

  /// 대기실 튜토리얼 (사용자당 1회)
  ///
  /// 참가자 데이터가 로딩된 이후 호출되며, 전달된 [team] 값 기준으로
  /// 반대 팀 `AddSlotCard` 를 가리키는 팀 변경 카드 스텝을 포함한다.
  /// 반대 팀 정원이 꽉 차서 `AddSlotCard` 가 렌더링되지 않은 경우 해당
  /// 스텝은 스킵된다. 완료 상태는 단일 키 [TutorialKeys.waitingRoom] 에
  /// 저장되며, 한 번 본 사용자는 팀을 바꾸거나 재입장해도 다시 노출되지
  /// 않는다(설정의 "튜토리얼 초기화"로만 재노출).
  Future<void> _showTutorialIfNeeded(String team) async {
    // 이미 표시 중이면 STOMP 재연결 등에 의한 중복 호출을 무시한다.
    if (_isTutorialShowing) return;

    // 초대코드 다이얼로그가 화면에 떠 있는 동안에는 튜토리얼을 띄우지
    // 않는다. 다이얼로그 닫힘 후 _fetchAndInitParticipants 의 명시적
    // 호출이 fallback 튜토리얼을 트리거하므로 누락 없음.
    if (_pendingInviteDialog || _isInviteDialogOpen) return;

    const key = TutorialKeys.waitingRoom;

    final completed = await TutorialService.isCompleted(key);
    if (completed || !mounted || _isTutorialShowing) return;

    _isTutorialShowing = true;

    // 오버레이 삽입 직후 바로 타겟 좌표가 잡히도록 레이아웃 반영을 한 프레임 대기.
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted || !_isTutorialShowing) {
      _isTutorialShowing = false;
      return;
    }

    // endOfFrame 대기 사이에 TEAM_UPDATE 가 들어와 팀이 바뀌었다면 이 경로는
    // 낡은 값이므로 표시하지 않는다. 단일 키 정책으로 재트리거 리스너가
    // 제거되었으므로 새 호출은 _fetchAndInitParticipants() 의 명시 경로에서만
    // 발생한다. 낡은 값에서는 _isTutorialShowing 플래그를 해제하지 않고 조용히
    // 종료한다 — 새 경로가 진행 중일 수 있다.
    final currentTeam = ref.read(gameParticipantNotifierProvider)?.team;
    if (currentTeam != team) return;

    // 1번 스텝 타겟: 현재 팀 기준 반대 팀의 첫 빈 AddSlotCard.
    final isPolice = GameTeam.isPolice(team);
    final opponentKey = isPolice
        ? _tutorialKeyAddSlotRobber
        : _tutorialKeyAddSlotPolice;

    final l10n = AppLocalizations.of(context);
    final targets = <TutorialTarget>[
      // 팀 변경 카드 (반대 팀 AddSlotCard 가 렌더링된 경우에만)
      if (opponentKey.currentContext != null)
        AppTutorialStyle.target(
          keyTarget: opponentKey,
          description: l10n.waitingRoomTutorialTeamSwitch,
          align: TutorialAlign.bottom,
        ),
      // 초대 코드 공유
      AppTutorialStyle.target(
        keyTarget: _tutorialKeyInviteCode,
        description: l10n.waitingRoomTutorialInvite,
      ),
      // 게임 설정 확인
      AppTutorialStyle.target(
        keyTarget: _tutorialKeyGameRules,
        description: l10n.waitingRoomTutorialSettings,
      ),
      // 준비 완료
      AppTutorialStyle.target(
        keyTarget: _tutorialKeyReadyButton,
        description: l10n.waitingRoomTutorialReady,
        align: TutorialAlign.top,
      ),
    ];

    _tutorialController = AppTutorialStyle.show(
      context: context,
      targets: targets,
      onFinish: () async {
        await TutorialService.markCompleted(key);
        _tutorialController = null;
        _isTutorialShowing = false;
        if (!mounted) return;
        await _showInGameTutorialPromptIfNeeded();
      },
    );
  }

  /// 대기방 코치마크가 처음 끝난 직후 1회 노출되는 인게임 튜토리얼 안내.
  ///
  /// 키가 이미 mark되어 있으면 아무 동작도 하지 않는다.
  /// 다이얼로그 표시 **전에** mark를 수행해 어떤 이유로 다이얼로그가
  /// 중단되더라도 영구 재노출을 방지한다.
  Future<void> _showInGameTutorialPromptIfNeeded() async {
    final shown = await TutorialService.isCompleted(TutorialKeys.inGamePrompt);
    if (shown || !mounted) return;

    await TutorialService.markCompleted(TutorialKeys.inGamePrompt);
    if (!mounted) return;

    final l10n = AppLocalizations.of(context);
    await AppDialog.show<void>(
      context: context,
      title: l10n.dialogInGamePreviewTitle,
      message: l10n.dialogTutorialPromptMessage,
      confirmText: l10n.buttonViewInGamePreview,
      barrierDismissible: false,
      // 도둑팀 사용자의 다크 화면 위에 라이트 다이얼로그가 뜨는 부조화 방지
      isDarkMode: ref.read(roleThemeProvider),
      onConfirm: () => context.push('/tutorial/in-game'),
    );
  }

  /// 재연결 모달 표시
  ///
  /// 이미 표시 중이거나 끊김/에러 상태가 아니면 스킵.
  /// 모달 닫힘 후 여전히 끊겨 있으면 자신을 재귀 호출하여 재표시.
  /// [DEBUG 전용] 개발자 도구 메뉴 — 로비 연결 끊김 시뮬레이션
  void _showDebugMenu() {
    AppDialog.show(
      context: context,
      title: '개발자 도구',
      showButtons: false,
      customContent: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.wifi_off),
            title: Text('끊김 시뮬레이션 (자동 재연결)', style: AppTextStyles.paragraph_14),
            subtitle: Text('재연결 모달 잠깐 뜨다 닫힘', style: AppTextStyles.tag_12),
            onTap: () {
              Navigator.pop(context);
              debugPrint('[WaitingRoom][DEBUG] 🔌 끊김 시뮬레이션 (자동 재연결)');
              ref.read(lobbyStompDatasourceProvider).disconnect();
            },
          ),
          ListTile(
            leading: const Icon(Icons.signal_wifi_off),
            title: Text('재연결 실패 시뮬레이션', style: AppTextStyles.paragraph_14),
            subtitle: Text(
              '5회 소진 → 모달 유지 + 수동 재연결',
              style: AppTextStyles.tag_12,
            ),
            onTap: () {
              Navigator.pop(context);
              debugPrint('[WaitingRoom][DEBUG] ❌ 재연결 실패 시뮬레이션 (error 상태)');
              ref
                  .read(lobbyNotifierProvider.notifier)
                  .debugForceReconnectExhausted();
            },
          ),
        ],
      ),
    );
  }

  void _showReconnectModal(StompConnectionState connState) {
    if (_isDisposed ||
        _isReconnectModalShown ||
        _isHandlingNotParticipating ||
        !mounted ||
        (connState != StompConnectionState.disconnected &&
            connState != StompConnectionState.error)) {
      return;
    }

    final isDark = ref.read(roleThemeProvider);
    _reconnectStateNotifier = ValueNotifier(connState);
    _isReconnectModalShown = true;
    ReconnectModal.show(
      context: context,
      isDarkMode: isDark,
      stateNotifier: _reconnectStateNotifier!,
      onReconnect: () {
        // GamePage가 외부 사유로 이미 dispose된 경우 ref/context 사용 금지 (안전망)
        if (!mounted) return;
        ref.read(lobbyNotifierProvider.notifier).manualReconnect();
      },
    ).then((_) {
      if (_isDisposed) return;
      _isReconnectModalShown = false;
      _reconnectStateNotifier?.dispose();
      _reconnectStateNotifier = null;

      // 닫힘 애니메이션 중 새로운 끊김이 발생했을 때 재표시
      // (닫힘 ~250ms 동안 disconnected 이벤트가 소비되어 리스너가 놓치는 케이스 대응)
      if (!mounted) return;
      _showReconnectModal(ref.read(lobbyNotifierProvider).connectionState);
    });
  }

  /// 강퇴 확인 다이얼로그 → API 호출
  Future<void> _showKickDialog(LobbyParticipantInfo member) async {
    final isDark = ref.read(roleThemeProvider);
    final l10n = AppLocalizations.of(context);
    final confirmed = await AppDialog.confirm(
      context: context,
      title: l10n.dialogKickConfirmTitle(member.nickname),
      message: l10n.dialogKickConfirmMessage,
      cancelText: l10n.buttonCancel,
      confirmText: l10n.buttonKick,
      isDestructive: true,
      confirmTextColor: AppColors.white,
      isDarkMode: isDark,
    );
    if (confirmed != true || !mounted) return;

    final gameId = ref.read(gameParticipantNotifierProvider)?.gameId;
    if (gameId == null) return;

    try {
      await ref.read(
        kickMemberProvider(
          gameId: gameId,
          participantId: member.participantId,
        ).future,
      );
    } on DioException catch (e) {
      if (!mounted) return;
      // 백엔드 영문 message 대신 errorCode 기반 i18n 메시지 사용
      final message = l10n.errorByException(DioExceptionHandler.handle(e));
      AppSnackbar.show(
        context,
        message: message,
        backgroundColor: AppColors.red,
      );
    } catch (_) {
      if (!mounted) return;
      AppSnackbar.show(
        context,
        message: l10n.errorKickFailed,
        backgroundColor: AppColors.red,
      );
    }
  }

  void _listenLobbyEvents() {
    _lobbyEventSub = ref.listenManual(lobbyNotifierProvider, (prev, next) {
      // dispose 후 microtask 큐에 남은 이벤트 방어
      if (_isDisposed) return;

      // STOMP 연결 완료 시 REST API로 초기 참가자 목록 로드
      // connectAndSubscribe()는 연결 시작만 하므로, 실제 connected 시점에 호출해야 함
      if (next.connectionState == StompConnectionState.connected &&
          prev?.connectionState != StompConnectionState.connected) {
        _fetchAndInitParticipants();
      }

      // 최초 연결 성공 추적 (초기 연결 실패 시엔 모달 미표시)
      if (next.connectionState == StompConnectionState.connected) {
        _hasLobbyConnectedOnce = true;
      }

      // 연결 끊김/에러 → 재연결 모달 표시
      // 재연결 성공 → stateNotifier 업데이트 → ReconnectModal이 스스로 닫힘
      if (_hasLobbyConnectedOnce) {
        if (_isReconnectModalShown) {
          _reconnectStateNotifier?.value = next.connectionState;
        } else {
          _showReconnectModal(next.connectionState);
        }
      }

      final event = next.lastEvent;
      if (event != null && event != prev?.lastEvent) {
        // 방장 participantId 보완 (로비 조회 API 응답 전 STOMP 이벤트가 먼저 도착할 때 방어)
        // initFromLobby() 호출 후에는 participantId != null이므로 자동 스킵됨.
        final pInfo = ref.read(gameParticipantNotifierProvider);
        if (pInfo?.isHost == true && pInfo?.participantId == null) {
          if (event.type == LobbyEventType.teamUpdate ||
              event.type == LobbyEventType.readyUpdate) {
            final participant = _extractEventParticipant(event.data);
            final eventPid = participant['participantId'] as int?;
            if (eventPid != null) {
              final alreadyKnown = ref
                  .read(waitingRoomParticipantsProvider)
                  .participants
                  .any((p) => p.participantId == eventPid);
              if (!alreadyKnown) {
                ref
                    .read(gameParticipantNotifierProvider.notifier)
                    .setParticipantId(eventPid);
                ref
                    .read(waitingRoomParticipantsProvider.notifier)
                    .setHost(eventPid);
              }
            }
          }
        }

        // 이벤트 처리 (참가자 목록 업데이트)
        ref
            .read(waitingRoomParticipantsProvider.notifier)
            .handleLobbyEvent(event);

        final myPid = ref.read(gameParticipantNotifierProvider)?.participantId;

        // 팀 변경 이벤트 시 gameParticipantNotifier 동기화
        if (event.type == LobbyEventType.teamUpdate) {
          final participant = _extractEventParticipant(event.data);
          final changedPid = participant['participantId'] as int?;
          if (myPid != null && myPid == changedPid) {
            final newTeam = participant['team'] as String?;
            if (newTeam != null) {
              ref
                  .read(gameParticipantNotifierProvider.notifier)
                  .setTeam(newTeam);
            }
          }
        }

        // 방장 변경 이벤트 시 isHost 동기화
        if (event.type == LobbyEventType.hostChanged) {
          final participant = _extractEventParticipant(event.data);
          final newHostId = participant['participantId'] as int?;
          if (newHostId != null && myPid != null) {
            final iAmNewHost = myPid == newHostId;
            ref
                .read(gameParticipantNotifierProvider.notifier)
                .setIsHost(iAmNewHost);
            ref
                .read(gameParticipantNotifierProvider.notifier)
                .setHostParticipantId(newHostId);
            // hostParticipantId도 동기화
            ref
                .read(waitingRoomParticipantsProvider.notifier)
                .setHost(newHostId);
            // 내가 방장이 되면 레디 상태 해제 — 레디 중에는 팀 변경 UI가 숨겨지기 때문
            if (iAmNewHost && _isReady) {
              setState(() => _isReady = false);
            }
          }
        }

        // 강퇴 이벤트 — 본인이면 다이얼로그 + 홈 이동, 타인이면 스낵바
        if (event.type == LobbyEventType.kicked) {
          _handleKickedEvent(event.data, myPid);
        }
      }
    });
  }

  /// KICKED 이벤트 처리 — 본인 강퇴 시 다이얼로그, 타인 강퇴 시 스낵바
  Future<void> _handleKickedEvent(Map<String, dynamic> data, int? myPid) async {
    final kickedPid = data['kickedParticipantId'] as int?;
    final kickedNickname = data['nickname'] as String? ?? '';

    // null == null 오인식 방어
    if (kickedPid == null || myPid == null) return;

    if (kickedPid == myPid) {
      // 강퇴당한 본인 → 다이얼로그 + 홈 이동
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      await AppDialog.show(
        context: context,
        title: l10n.dialogKickedFromRoomTitle,
        message: l10n.dialogKickedFromRoomMessage,
        isDarkMode: ref.read(roleThemeProvider),
      );
      if (!mounted) return;
      ref.read(gameParticipantNotifierProvider.notifier).clear();
      GoRouter.of(context).go(RoutePaths.home);
    } else {
      // 다른 유저 강퇴 → 스낵바
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      AppSnackbar.show(
        context,
        message: l10n.messageMemberKicked(kickedNickname),
      );
    }
  }

  /// 이벤트 data에서 participant 정보 추출
  ///
  /// 서버 이벤트별 키: newParticipant(ENTER), newHost(HOST_CHANGED), participant(기타)
  Map<String, dynamic> _extractEventParticipant(Map<String, dynamic> data) {
    for (final key in ['newParticipant', 'newHost', 'participant']) {
      if (data.containsKey(key) && data[key] is Map) {
        return data[key] as Map<String, dynamic>;
      }
    }
    return data;
  }

  /// GAME_START 이벤트 재시도 최대 횟수 (300ms × 10 = 3초)
  static const int _maxGameStartRetries = 10;
  int _gameStartRetryCount = 0;

  /// GAME_START 이벤트 수신 시 호출
  void _onGameStartEvent(LobbyEventDto event) {
    final participantInfo = ref.read(gameParticipantNotifierProvider);
    if (participantInfo == null || participantInfo.participantId == null) {
      _gameStartRetryCount++;
      if (_gameStartRetryCount > _maxGameStartRetries) {
        debugPrint('[WaitingRoom] ❌ participantInfo 준비 실패 - 최대 재시도 초과');
        return;
      }
      debugPrint(
        '[WaitingRoom] ⚠️ participantInfo 미준비 - 라우팅 지연 ($_gameStartRetryCount/$_maxGameStartRetries)',
      );
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!_isDisposed && mounted) _onGameStartEvent(event);
      });
      return;
    }
    _gameStartRetryCount = 0;
    final team = participantInfo.team;
    final participantId = participantInfo.participantId!;

    // 게임 시작 퍼널 이벤트
    unawaited(
      ref
          .read(analyticsServiceProvider)
          .logGameStart(
            team: team,
            participantCount: ref
                .read(waitingRoomParticipantsProvider)
                .participants
                .length,
          ),
    );

    // startTime을 직접 추출 (GameStartData.fromJson은 message 필드 누락 시 예외 발생 가능)
    final startTimeStr = event.data['startTime'] as String?;
    if (startTimeStr != null) {
      ref
          .read(gameParticipantNotifierProvider.notifier)
          .setGameStartTime(startTimeStr);
    }

    final route =
        '${RoutePaths.gameWithId(widget.sessionId)}?team=$team&pid=$participantId';

    if (mounted) {
      context.go(route);
    }
  }

  /// 팀 변경
  Future<void> _changeTeam(String targetTeam) async {
    // 이미 같은 팀이면 무시
    final currentTeam = ref.read(gameParticipantNotifierProvider)?.team;
    if (currentTeam == targetTeam) return;

    // 더미 모드
    if (_isDummyMode) {
      ref
          .read(waitingRoomParticipantsProvider.notifier)
          .changeDummyTeam(_dummyMyId, targetTeam);
      return;
    }

    final gameId = int.tryParse(widget.sessionId);
    if (gameId == null) return;

    final loading = AppLoading.show(context, LoadingCategory.changeTeam);

    try {
      await ref.read(changeTeamProvider(gameId, targetTeam: targetTeam).future);
      await loading.close();
      // close()의 최소 표시 대기 동안 대기실이 dispose될 수 있어(KICKED/GAME_START 등
      // 웹소켓 이벤트가 화면을 날림) ref 사용 전 mounted 확인
      if (!mounted) return;
      // 서버 TEAM_CHANGED 이벤트를 기다리지 않고 먼저 반영한다(도착 시 같은 값으로 덮음).
      // 역할 테마는 이 참가 정보에서 파생되므로 여기만 갱신하면 따라온다.
      ref.read(gameParticipantNotifierProvider.notifier).setTeam(targetTeam);
    } on DioException catch (e) {
      await loading.close();
      if (!mounted) return;
      await _handleApiErrorOrNotParticipating(e);
    } finally {
      // 안전망: 위에서 처리하지 못한 예외 타입으로 인해 close()가 호출되지
      // 않는 경로를 막는다. close()는 멱등이므로 정상 경로에는 영향 없음.
      await loading.close();
    }
  }

  /// 준비 상태 토글
  Future<void> _toggleReady() async {
    // 더미 모드: 로컬에서 즉시 토글
    if (_isDummyMode) {
      ref
          .read(waitingRoomParticipantsProvider.notifier)
          .toggleDummyReady(_dummyMyId);
      setState(() => _isReady = !_isReady);
      return;
    }

    final gameId = int.tryParse(widget.sessionId);
    if (gameId == null) return;

    setState(() => _isUpdatingReady = true);

    final newReadyState = !_isReady;
    try {
      await ref.read(
        updateReadyProvider(gameId, isReady: newReadyState).future,
      );
      if (!mounted) return;
      setState(() => _isReady = newReadyState);
    } on DioException catch (e) {
      if (!mounted) return;
      await _handleApiErrorOrNotParticipating(e);
    } finally {
      if (mounted) {
        setState(() => _isUpdatingReady = false);
      }
    }
  }

  /// 게임 시작 (방장 전용)
  Future<void> _startGame() async {
    if (_isDummyMode) {
      if (mounted) {
        context.go(
          '${RoutePaths.gameWithId('1')}?team=POLICE&pid=$_dummyMyId&dummy=true',
        );
      }
      return;
    }

    final gameId = int.tryParse(widget.sessionId);
    if (gameId == null) return;

    final loading = AppLoading.show(context, LoadingCategory.startGame);

    try {
      await ref.read(startGameProvider(gameId).future);
      await loading.close();
    } on DioException catch (e) {
      await loading.close();
      if (!mounted) return;
      await _handleApiErrorOrNotParticipating(e);
    } finally {
      // 안전망: 위에서 처리하지 못한 예외 타입으로 인해 close()가 호출되지
      // 않는 경로를 막는다. close()는 멱등이므로 정상 경로에는 영향 없음.
      await loading.close();
    }
  }

  /// 방 나가기 확인 다이얼로그
  Future<void> _confirmLeaveRoom() async {
    final isDark = ref.read(roleThemeProvider);
    final l10n = AppLocalizations.of(context);
    final confirmed = await AppDialog.confirm(
      context: context,
      isDarkMode: isDark,
      title: l10n.dialogLeaveRoomTitle,
      message: l10n.dialogLeaveRoomMessage,
      confirmText: l10n.buttonLeave,
      isDestructive: true,
      confirmTextColor: AppColors.white,
    );
    if (confirmed != true || !mounted) return;
    await _leaveRoom();
  }

  /// 방 나가기
  Future<void> _leaveRoom() async {
    // ① REST API 퇴장 먼저 시도
    final gameId = int.tryParse(widget.sessionId);
    if (gameId != null) {
      try {
        await ref.read(leaveGameProvider(gameId).future);
      } on DioException catch (e) {
        if (!mounted) return;
        final l10n = AppLocalizations.of(context);
        // 백엔드 한국어 detail 대신 i18n 메시지 사용 (errorCode 기반)
        final ex = DioExceptionHandler.handle(e);
        AppSnackbar.show(
          context,
          message: l10n.errorByException(ex),
          backgroundColor: AppColors.red,
        );
        return;
      }
    }

    // ② API 성공 후 STOMP 끊기 + 상태 초기화 + 홈 이동
    if (!mounted) return;
    _lobbyEventSub?.close();
    _lobbyEventSub = null;
    ref.read(lobbyNotifierProvider.notifier).disconnectLobby();
    ref.read(gameParticipantNotifierProvider.notifier).clear();
    ref.read(waitingRoomParticipantsProvider.notifier).clear();
    context.go(RoutePaths.home);
  }

  /// 게임 규칙 다이얼로그
  void _showGameRulesDialog() {
    final interval = ref
        .read(gameParticipantNotifierProvider)
        ?.locationRevealIntervalMinutes;
    final isDark = ref.read(roleThemeProvider);
    GameRulesContent.showAsDialog(
      context,
      isDarkMode: isDark,
      locationRevealIntervalMinutes: interval,
    );
  }

  /// 초대코드 모달 (방 생성 직후 표시)
  Future<void> _showInviteCodeDialog() async {
    // 다이얼로그가 열려 있는 동안 리스너/STOMP 경로가 튜토리얼을 띄우지
    // 못하도록 가드 플래그를 올린다. pop/예외 어느 경로든 반드시 내려야
    // 하므로 try/finally 사용.
    _isInviteDialogOpen = true;
    try {
      final code = _inviteCode!;
      final isDark = ref.read(roleThemeProvider);
      final l10n = AppLocalizations.of(context);

      await AppDialog.show<void>(
        context: context,
        isDarkMode: isDark,
        title: l10n.dialogInviteCodeCreatedTitle,
        message: l10n.dialogInviteCodeShareMessage,
        customContent: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // QR 코드 이미지
            // 딥링크 URL 인코딩 (share_util 의 공유 버튼과 동일 형식).
            // 앱 내 QR 스캐너는 URL 뒤 초대코드를 파싱해 입장하고, 일반 카메라로
            // 촬영하면 딥링크로 앱이 실행돼 자동 참가한다.
            ClipRRect(
              borderRadius: AppRadius.xxlarge,
              child: QrImageView(
                data: buildInviteDeeplink(code),
                version: QrVersions.auto,
                size: 220.w,
                backgroundColor: isDark ? AppColors.white : AppColors.black100,
              ),
            ),
            SizedBox(height: AppSpacing.vertical12),
            // 초대코드 + 복사 아이콘
            GestureDetector(
              onTap: () async {
                VibrationService.instance().buttonTap();
                await Clipboard.setData(ClipboardData(text: code));
                if (!mounted) return;
                AppSnackbar.show(
                  context,
                  message: l10n.messageCodeCopied,
                  iconPath: 'assets/icons/icon_copy.svg',
                );
              },
              behavior: HitTestBehavior.opaque,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    code,
                    style: isDark
                        ? AppTextStyles.robberLabel.copyWith(
                            color: AppColors.white,
                          )
                        : AppTextStyles.label_16.copyWith(
                            color: AppColors.black,
                          ),
                  ),
                  SizedBox(width: AppSpacing.horizontal4),
                  SvgPicture.asset(
                    'assets/icons/icon_copy.svg',
                    width: 20.w,
                    height: 20.w,
                    colorFilter: ColorFilter.mode(
                      isDark ? AppColors.black500 : AppColors.black300,
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        cancelText: l10n.buttonClose,
        confirmText: l10n.buttonShare,
        onConfirm: () {
          shareInviteCode(code, l10n.shareInviteMessage(code));
        },
      );
    } finally {
      _isInviteDialogOpen = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 참가자 목록이 바뀌면 팀 섹션 Wrap의 높이가 달라져 아래쪽 타겟 좌표가 밀림.
    // 튜토리얼 패키지는 타겟 활성화 시점의 좌표를 캐시하므로, 변경 프레임 직후
    // refresh()를 호출해 현재 타겟 위치를 다시 잡아준다.
    ref.listen(waitingRoomParticipantsProvider, (prev, next) {
      final controller = _tutorialController;
      if (controller == null || !controller.isShowing) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        controller.refresh();
      });
    });

    final participantsState = ref.watch(waitingRoomParticipantsProvider);
    final participantInfo = ref.watch(gameParticipantNotifierProvider);
    final isHost = participantInfo?.isHost ?? false;
    final isDark = ref.watch(roleThemeProvider);

    final policeMembers = participantsState.byTeam(GameTeam.police);
    final robberMembers = participantsState.byTeam(GameTeam.robber);

    // 위치 권한 미허용 → 다이얼로그가 표시되는 동안 빈 화면
    if (_isLocationPermissionDenied) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.black900 : AppColors.white,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.black900 : AppColors.white,
      appBar: _buildAppBar(isDark),
      // [DEBUG] 개발자 도구 버튼 — release에서는 kDebugMode=false로 dead-code 제거
      floatingActionButton: kDebugMode
          ? FloatingActionButton(
              heroTag: 'waiting_room_debug',
              mini: true,
              backgroundColor: AppColors.black.withValues(alpha: 0.7),
              foregroundColor: AppColors.white,
              onPressed: _showDebugMenu,
              child: const Icon(Icons.bug_report),
            )
          : null,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // 팀 섹션 (스크롤 가능)
            Expanded(
              child: participantsState.participants.isEmpty
                  ? ShimmerParticipantSkeleton(isDarkMode: isDark)
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          // 경찰팀
                          TeamSection(
                            team: GameTeam.police,
                            members: policeMembers,
                            isExpanded: _isPoliceExpanded,
                            onToggle: () => setState(
                              () => _isPoliceExpanded = !_isPoliceExpanded,
                            ),
                            hostParticipantId:
                                participantsState.hostParticipantId,
                            myParticipantId: participantInfo?.participantId,
                            currentUserTeam: participantInfo?.team,
                            onAddSlotTap: !_isReady
                                ? () => _changeTeam(GameTeam.police)
                                : null,
                            addSlotKey: _tutorialKeyAddSlotPolice,
                            // 방장만 다른 참가자 탭 시 강퇴 다이얼로그 표시
                            onMemberTap: isHost
                                ? (member) {
                                    final myPid =
                                        participantInfo?.participantId;
                                    if (member.participantId == myPid) return;
                                    _showKickDialog(member);
                                  }
                                : null,
                            isDarkMode: isDark,
                          ),
                          // 구분선
                          Padding(
                            padding: AppPadding.horizontal20,
                            child: SolidDivider(
                              color: isDark
                                  ? AppColors.black800
                                  : AppColors.black100,
                            ),
                          ),
                          // 도둑팀
                          TeamSection(
                            team: GameTeam.robber,
                            members: robberMembers,
                            isExpanded: _isRobberExpanded,
                            onToggle: () => setState(
                              () => _isRobberExpanded = !_isRobberExpanded,
                            ),
                            hostParticipantId:
                                participantsState.hostParticipantId,
                            myParticipantId: participantInfo?.participantId,
                            currentUserTeam: participantInfo?.team,
                            onAddSlotTap: !_isReady
                                ? () => _changeTeam(GameTeam.robber)
                                : null,
                            addSlotKey: _tutorialKeyAddSlotRobber,
                            // 방장만 다른 참가자 탭 시 강퇴 다이얼로그 표시
                            onMemberTap: isHost
                                ? (member) {
                                    final myPid =
                                        participantInfo?.participantId;
                                    if (member.participantId == myPid) return;
                                    _showKickDialog(member);
                                  }
                                : null,
                            isDarkMode: isDark,
                          ),
                        ],
                      ),
                    ),
            ),

            // 하단 버튼 (준비 / 게임 시작) — 튜토리얼 하이라이트 대상
            SafeArea(
              top: false,
              child: Padding(
                key: _tutorialKeyReadyButton,
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.horizontal20,
                  AppSpacing.vertical12,
                  AppSpacing.horizontal20,
                  AppSpacing.vertical20,
                ),
                child: _buildBottomButton(isHost, isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      leadingWidth: 62.w,
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: Padding(
        padding: EdgeInsets.only(left: 18.w),
        child: FlatIconButton(
          assetPath: 'assets/icons/icon_exit.svg',
          iconColor: isDark ? AppColors.black200 : AppColors.black800,
          onPressed: _confirmLeaveRoom,
        ),
      ),
      title: _inviteCode != null
          ? GestureDetector(
              // 초대 코드 영역 — 튜토리얼 하이라이트 대상
              key: _tutorialKeyInviteCode,
              onTap: _showInviteCodeDialog,
              child: IntrinsicWidth(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _inviteCode!,
                      style: isDark
                          ? AppTextStyles.robberHeading.copyWith(
                              color: AppColors.white,
                            )
                          : AppTextStyles.heading_20.copyWith(
                              color: AppColors.black,
                            ),
                    ),
                    SizedBox(height: 2.h),
                    Container(
                      width: double.infinity,
                      height: 2.h,
                      color: isDark ? AppColors.white : AppColors.black,
                    ),
                  ],
                ),
              ),
            )
          : null,
      actions: [
        FlatIconButton(
          assetPath: 'assets/icons/icon_info.svg',
          alignment: Alignment.centerRight,
          iconColor: isDark ? AppColors.black200 : AppColors.black800,
          onPressed: _showGameRulesDialog,
        ),
        FlatIconButton(
          // 게임 설정 버튼 — 튜토리얼 하이라이트 대상
          key: _tutorialKeyGameRules,
          assetPath: 'assets/icons/icon_settiing_2.svg',
          iconColor: isDark ? AppColors.black200 : AppColors.black800,
          onPressed: () =>
              context.push(RoutePaths.gameSettingsWithId(widget.sessionId)),
        ),
        SizedBox(width: 12.w),
      ],
    );
  }

  Widget _buildBottomButton(bool isHost, bool isDark) {
    final l10n = AppLocalizations.of(context);
    if (isHost) {
      final participantsState = ref.watch(waitingRoomParticipantsProvider);
      final hostPid = participantsState.hostParticipantId;
      // 방장 제외 참가자 중 전원 레디 여부 확인
      final nonHostParticipants = participantsState.participants
          .where((p) => p.participantId != hostPid)
          .toList();
      // 이벤트방은 운영진(도둑)만 있고 경찰은 코드로 중간 참여하므로,
      // 레디/인원 조건 없이 방장이 바로 시작 가능. 실제 시작 가부는 백엔드가 판단.
      final isEvent =
          ref.watch(gameParticipantNotifierProvider)?.isEventGame ?? false;
      final allReady =
          isEvent ||
          (nonHostParticipants.isNotEmpty &&
              nonHostParticipants.every((p) => p.isReady));

      return AppButton(
        text: l10n.buttonStartGame,
        onPressed: allReady ? _startGame : null,
        backgroundColor: isDark ? AppColors.green : AppColors.blue,
        foregroundColor: isDark ? AppColors.black : AppColors.white,
        disabledBackgroundColor: isDark
            ? AppColors.black800
            : AppColors.black200,
        disabledForegroundColor: isDark ? AppColors.green : AppColors.black400,
        textStyle: isDark ? AppTextStyles.robberLabel : null,
      );
    }

    if (_isReady) {
      return AppButton(
        text: l10n.buttonReadyDone,
        onPressed: _isUpdatingReady ? null : _toggleReady,
        backgroundColor: isDark ? AppColors.black800 : AppColors.blue100,
        foregroundColor: isDark ? AppColors.green : AppColors.blue,
        textStyle: isDark ? AppTextStyles.robberLabel : null,
        isLoading: _isUpdatingReady,
      );
    }

    return AppButton(
      text: l10n.buttonReady,
      onPressed: _isUpdatingReady ? null : _toggleReady,
      backgroundColor: isDark ? AppColors.green : AppColors.blue,
      foregroundColor: isDark ? AppColors.black : AppColors.white,
      textStyle: isDark ? AppTextStyles.robberLabel : null,
      isLoading: _isUpdatingReady,
    );
  }
}
