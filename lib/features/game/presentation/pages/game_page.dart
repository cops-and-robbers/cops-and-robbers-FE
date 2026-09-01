import 'dart:async';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/network/api_error_response.dart';
import '../../../../core/utils/iso_timestamp_parser.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/services/ads/ad_service.dart';
import '../../../../core/services/analytics/analytics_service.dart';
import '../../../../core/services/background/background_service.dart';
import '../../../../core/services/background/background_service_provider.dart';
import '../../../../core/services/lifecycle/app_lifecycle_service.dart';
import '../../../../core/services/lifecycle/lifecycle_provider.dart';
import '../../../../core/services/location/device_location_service.dart';
import '../../../../core/services/permission/location_permission_messages.dart';
import '../../../../core/services/permission/location_permission_service.dart';
import '../../../../core/services/vibration_service.dart';
import '../../../../core/widgets/buttons/flat_icon_button.dart';
import '../../../../core/widgets/buttons/svg_icon_button.dart';
import '../../../../core/widgets/dialogs/app_dialog.dart';
import '../../../../core/widgets/dialogs/app_popup.dart';
import '../../../../core/widgets/dialogs/reconnect_modal.dart';
import '../../../../core/widgets/dialogs/countdown_timer_content.dart';
import '../../../../router/route_paths.dart';
import '../../../chat/presentation/providers/chat_notification_provider.dart';
import '../../../chat/presentation/providers/chat_provider.dart';
import '../../../chat/presentation/widgets/chat_overlay.dart';
import '../../../session/presentation/providers/game_participant_provider.dart';
import '../../../session/presentation/providers/session_provider.dart';
import '../../../session/presentation/widgets/game_rules_content.dart';
import '../../data/datasources/game_event_stomp_datasource.dart';
import '../../data/models/game_area_model.dart';
import '../../domain/entities/area_shape.dart';
import '../../domain/arrest_lock_visibility.dart';
import '../../domain/location_send_policy.dart';
import '../../domain/qr_payload.dart';
import '../../domain/zone_exit_detector.dart';
import '../helpers/game_over_guard.dart';
import '../helpers/zone_exit_reconnect_policy.dart';
import '../providers/game_area_provider.dart';
import '../providers/game_event_provider.dart';
import '../providers/game_result_provider.dart';
import '../../../../core/widgets/buttons/my_location_button.dart';
import '../../../../core/widgets/snackbars/app_snackbar.dart';
import '../widgets/arrest_lock_overlay.dart';
import '../widgets/game_over_result_dialog.dart';
import '../widgets/qr_display_dialog.dart';
import '../widgets/qr_scanner_page.dart';
import '../widgets/game_timer_text.dart';
import '../widgets/location_reveal_countdown.dart';
import '../../domain/entities/ping.dart';
import '../providers/ping_provider.dart';
import '../providers/player_game_record_provider.dart';
import '../widgets/google_map_view.dart';
import '../widgets/participant_overlay.dart';
import '../widgets/ping_selection_card.dart';
import '../widgets/marquee_alert_banner.dart';
import '../widgets/police_start_countdown.dart';
import '../widgets/zone_exit_banner.dart';
import '../widgets/zone_exit_vignette.dart';
import 'package:cops_and_robbers/core/constants/game_config.dart';
import 'package:cops_and_robbers/core/constants/game_status.dart';
import 'package:cops_and_robbers/core/constants/game_team.dart';
import 'package:cops_and_robbers/core/constants/game_result_reason.dart';
import 'package:cops_and_robbers/core/constants/participant_status.dart';
import '../../../../core/constants/dev_flags.dart';
import '../widgets/event_arrest_success_dialog.dart';
import '../widgets/event_result_board.dart';

/// 인게임 지도 화면
///
/// 게임 진행 중 사용되는 메인 화면
class GamePage extends ConsumerStatefulWidget {
  const GamePage({
    required this.sessionId,
    required this.team,
    required this.participantId,
    this.isDummy = false,
    super.key,
  });

  /// 게임 세션 ID
  final String sessionId;

  /// 플레이어 팀 ('POLICE' 또는 'ROBBER')
  final String team;

  /// 플레이어 참가자 ID
  final int participantId;

  /// 더미 모드 (서버 미연동 시 UI 테스트용)
  final bool isDummy;

  @override
  ConsumerState<GamePage> createState() => _GamePageState();
}

class _GamePageState extends ConsumerState<GamePage>
    with WidgetsBindingObserver {
  final _googleMapKey = GlobalKey<GoogleMapViewState>();

  /// 채팅 시트 collapsed 상단과 우측 액션 버튼 하단 사이의 **고정 시각 여백** (논리 dp).
  ///
  /// 시스템 네비 inset(`MediaQuery.viewPadding.bottom`)에 따라 변하지 않는 고정값이다.
  /// inset은 별도로 더해지며 이 상수에는 포함되지 않는다.
  static const double _kActionButtonChatGap = 45.0;

  bool _showParticipants = false;
  bool _gameOverDialogShown = false;
  // 결과 다이얼로그 버튼 연타 가드 — 라우팅·Analytics 중복 기록 방지
  bool _exitTriggered = false;

  /// 능동 중도 퇴장 진행 중 — 자기 몰수 GAME_OVER 모달/resume 라우팅 차단 + 연타 방지
  bool _isLeaving = false;

  // 핑 선택 카드 위치(logical px). null이면 카드 미표시.
  Offset? _pingCardOffset;
  // 카드에서 선택 시 사용할 롱프레스 좌표
  LatLng? _pendingPingLatLng;
  bool _isCheckingGameStatus = false;
  bool _isLocationPermissionDenied = false;
  bool _isLocationFocused = true;
  bool _isProgrammaticMove = true; // 초기 카메라 이동(onMapCreated) 보호

  /// dispose()에서 ref 사용 불가이므로 사전에 저장
  ChatNotifier? _chatNotifier;
  GameEventNotifier? _gameEventNotifier;
  GameEventStompDatasource? _gameEventDatasource;

  /// dispose() + 재진입 가드에서 사용하기 위해 사전에 저장
  /// keepAlive provider이므로 게임 화면 dispose 이후에도 인스턴스 유효.
  /// initState에서 동기 할당 (post-frame 이전 dispose 시 LateInitializationError 방지)
  late final BackgroundService _backgroundService;

  /// dispose 이후 ref 무효화 대비, 사전에 저장한 내 기록 notifier.
  late final PlayerGameRecordNotifier _recordNotifier;

  StreamSubscription<Position>? _locationSubscription;
  Position? _lastSentPosition;
  DateTime? _lastSentTime;

  // 재연결 시 시스템 메시지 중복 방지용 last-handled 값
  DateTime? _lastHandledPoliceMove;
  DateTime? _lastHandledLocationReveal;
  int _lastHandledArrestCount = 0;
  int _lastHandledEscapeCount = 0;
  int _lastHandledMyArrestSeq = 0;

  /// 더미 모드 전용 타이머 시작 시각
  DateTime? _dummyStartTime;

  /// 구역 이탈/복귀 상태 전환 감지기
  late final ZoneExitDetector _zoneExitDetector = ZoneExitDetector(
    onExitZone: () {
      if (_isReconnectModalShown) {
        // 재연결 모달 중 이탈 → 모달 닫힘 후 재평가(_processPendingZoneExit)
        _pendingZoneExit = true;
        return;
      }
      _onZoneExited();
    },
    onEnterZone: () {
      // 구역 복귀 시 보류 플래그도 함께 초기화
      _pendingZoneExit = false;
      _onZoneEntered();
    },
  );

  /// 이탈 경고(배너·펄스·보더·반복 진동) 노출 중 여부
  ///
  /// 의미: "구역 밖에 있어 시각·진동 신호가 노출 중".
  /// `_zoneExitDetector.isOutside`와 동기화되며, build 트리거를 위해 별도 보유.
  bool _isZoneExitWarningActive = false;

  /// 구역 밖 체류 중 반복 진동 Timer (5초 주기)
  Timer? _zoneExitVibrationTimer;

  /// 재연결 모달 표시 중 여부 (중복 표시 방지)
  bool _isReconnectModalShown = false;

  /// 재연결 모달 종료 후 구역 이탈 팝업을 복구해야 함을 표시하는 보류 플래그.
  ///
  /// 다음 두 경로에서 `true` 로 세팅된다:
  /// 1) 재연결 모달 표시 중 새로 구역을 벗어난 경우 (`_zoneExitDetector.onExitZone`)
  /// 2) 재연결 모달 진입 시점에 이미 구역 밖이거나 이탈 팝업이 떠 있던 경우
  ///    (`_showReconnectModalIfNeeded` → `shouldMarkZoneExitAsPendingOnReconnect`)
  ///
  /// 모달이 닫히면 `_processPendingZoneExit()` 이 `_zoneExitDetector.isOutside`
  /// 를 재확인한 뒤 이탈 팝업과 진동을 복구한다. 구역으로 복귀하면
  /// `onEnterZone` 에서 `false` 로 리셋된다.
  bool _pendingZoneExit = false;

  /// 게임 이벤트 STOMP 최초 연결 성공 여부
  /// (초기 연결 실패는 모달 대신 기존 에러 처리에 위임)
  bool _hasGameEventConnectedOnce = false;

  /// 재연결 모달에 전달하는 현재 연결 상태 Notifier
  ValueNotifier<StompConnectionState>? _reconnectStateNotifier;

  int get _gameId => int.tryParse(widget.sessionId) ?? 0;
  bool get _isDarkMode => GameTeam.isRobber(widget.team);

  @override
  void initState() {
    super.initState();
    if (widget.isDummy) _dummyStartTime = DateTime.now();
    WidgetsBinding.instance.addObserver(this);
    // keepAlive 서비스 — 동기 할당해서 첫 프레임 전 dispose에도 안전.
    // ref.read는 initState에서 합법 (ref.watch만 금지).
    _backgroundService = ref.read(backgroundServiceProvider);
    _recordNotifier = ref.read(playerGameRecordNotifierProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 새 게임 진입마다 이전 기록 초기화(앱 resume 시에는 initState 미실행 → 보존).
      // initState 본문에서 직접 호출하면 build 중 provider 수정 에러(Riverpod) —
      // 위치 스트림 시작(_ensureLocationAndInit)보다 먼저라 순서는 동일하다.
      if (!widget.isDummy) _recordNotifier.reset();
      // 위치 권한 + STOMP 초기화 + participantInfo 로드를 끝까지 기다린 뒤
      // 재진입 가드를 호출해야 콜드 재시작 케이스에서 participantInfo.gameStartTime
      // 이 채워진 상태로 가드가 판정 가능.
      await _ensureLocationAndInit();
      if (!mounted) return;
      // 재진입 가드: 게임 도중 앱을 닫았다 다시 들어온 경우
      // GAME_START 이벤트를 못 받았어도 백그라운드 인프라를 강제 시작
      _ensureBackgroundInfrastructureForOngoingGame();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkLocationPermissionOnResume();
    }
  }

  /// 위치 권한 확인 후 게임 초기화
  ///
  /// 위치 권한이 없으면 권한 요청 다이얼로그를 표시하고,
  /// 허용될 때까지 게임 초기화(위치 스트림, STOMP 연결 등)를 보류합니다.
  Future<void> _ensureLocationAndInit() async {
    final canAccess = await LocationPermissionService.canAccessLocation();
    if (!mounted) return;

    if (canAccess) {
      await _initGameConnections();
      return;
    }

    // 권한 없음 → 상태 업데이트 + 다이얼로그 표시
    setState(() => _isLocationPermissionDenied = true);
    await _showLocationPermissionDialog();
  }

  /// 위치 권한 요청 다이얼로그
  ///
  /// 설정에서 권한을 허용하고 돌아오면 재확인 후 게임 초기화를 진행합니다.
  Future<void> _showLocationPermissionDialog() async {
    final serviceEnabled = await LocationPermissionService.isServiceEnabled();
    if (!mounted) return;

    final text = LocationPermissionMessages.getText(
      context: context,
      isServiceDisabled: !serviceEnabled,
      locationContext: LocationPermissionContext.game,
    );

    // 게임 중에는 나갈 수 없으므로 설정 이동 버튼만 제공
    AppDialog.show(
      context: context,
      title: text.title,
      message: text.message,
      confirmText: AppLocalizations.of(context).buttonGoToSettings,
      barrierDismissible: false,
      isDarkMode: _isDarkMode,
      onConfirm: () async {
        if (!serviceEnabled) {
          await LocationPermissionService.openLocationSettings();
        } else {
          await LocationPermissionService.openAppSettings();
        }
        if (mounted) await _ensureLocationAndInit();
      },
    );
  }

  /// 게임 연결 및 초기화 (위치 권한 확보 후 실행)
  ///
  /// STOMP 연결 시 `_fetchLastRobberLocations` 가드가 `participantInfo`의
  /// gameStartTime/policeWaitMinutes에 의존하므로, 반드시 설정 로드 후에
  /// STOMP 연결을 시작한다. 로비 경유 진입에서는 이미 설정이 있어 지연 없음.
  /// splash 재진입 시에만 settings API 1회 호출 비용이 발생한다.
  Future<void> _initGameConnections() async {
    if (_isLocationPermissionDenied) {
      setState(() => _isLocationPermissionDenied = false);
    }
    _connectChat();

    await _initSettingsFromApiIfNeeded();
    if (!mounted) return;

    // 이벤트 모드: 로컬 검거 집합 복원이 끝나야 재체포 차단/카운트/증거 인덱스가 정확하다.
    // 반드시 await — unawaited면 복원 전 QR 체포가 가능해 재체포/유실 위험(코드리뷰 P1).
    // (loadMyArrests는 union 병합이라 만약의 겹침에도 신규 검거를 잃지 않는다.)
    // 복원 실패(저장소 I/O 예외)가 게임 초기화 전체를 막지 않도록 비치명 처리한다.
    // 빈 집합으로 시작 — _persistMyArrests의 영속화 실패 비치명 처리와 동일 철학.
    if (ref.read(gameParticipantNotifierProvider)?.isEventGame ?? false) {
      try {
        await ref
            .read(gameEventNotifierProvider.notifier)
            .loadMyArrests(_gameId);
        if (!mounted) return;
      } catch (e) {
        debugPrint('[GamePage] ⚠️ 이벤트 검거 복원 실패(무시): $e');
      }
    }

    _connectGameEvents();
    _loadGameArea();
    _showPoliceTimerIfNeeded();
    _sendGameStartSystemMessages();
  }

  /// 앱 포그라운드 복귀 시 위치 권한 재확인
  ///
  /// 게임 중 설정에서 위치 권한을 끄고 돌아온 경우,
  /// 위치 스트림을 중단하고 권한 요청 다이얼로그를 표시합니다.
  /// 권한 허용 후에는 앱 재시작이 필요합니다.
  Future<void> _checkLocationPermissionOnResume() async {
    if (_isLeaving) return;
    if (_isLocationPermissionDenied) return;

    final canAccess = await LocationPermissionService.canAccessLocation();
    if (!mounted || canAccess) return;

    // 위치 스트림 중단
    _locationSubscription?.cancel();
    _locationSubscription = null;

    setState(() => _isLocationPermissionDenied = true);
    await _showLocationPermissionDialog();
  }

  /// 진행 중인 게임이면 백그라운드 인프라를 활성화 (멱등)
  ///
  /// 이미 GAME_START 이벤트를 통해 활성화된 상태라면 멱등성 덕에 no-op.
  ///
  /// 사용 케이스 1: 사용자가 게임 도중 앱을 닫았다 다시 들어왔을 때
  /// GAME_START 이벤트는 이미 발생한 후라 못 받음. 이 가드가 그 케이스 방어.
  ///
  /// 사용 케이스 2: LobbyStomp가 GAME_START을 먼저 가로채 화면을 전환한 뒤
  /// GameEventStomp가 늦게 구독하는 race condition. GameEventNotifier의
  /// gameStartTime은 영원히 null이므로 participantInfo로 폴백 판단.
  void _ensureBackgroundInfrastructureForOngoingGame() {
    if (!mounted) return;
    final gameEvent = ref.read(gameEventNotifierProvider);
    if (gameEvent.isGameOver) return;

    // gameStartTime 우선순위:
    //   1) GameEventNotifier.gameStartTime (GAME_START 수신 시 세팅)
    //   2) participantInfo.gameStartTime (lobby/API 응답에 포함된 ISO 문자열)
    final participantInfo = ref.read(gameParticipantNotifierProvider);
    final participantStartTimeStr = participantInfo?.gameStartTime;
    final effectiveStartTime =
        gameEvent.gameStartTime ??
        IsoTimestampParser.parse(participantStartTimeStr);

    if (effectiveStartTime == null) return;

    _backgroundService.start(gameId: _gameId);
    AppLifecycleService.instance().enableKeepAlive();
    debugPrint('[GamePage] ✅ 재진입 가드: 백그라운드 인프라 활성화');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _locationSubscription?.cancel();
    _zoneExitVibrationTimer?.cancel();
    // dispose() 중 provider 상태 수정은 Riverpod이 차단하므로 다음 프레임으로 지연.
    // gameEventNotifier.disconnect()는 내부에서 ref.read()를 호출하므로
    // provider가 dispose된 후 호출 시 에러 가능. datasource를 직접 참조해 우회.
    _reconnectStateNotifier?.dispose();
    _reconnectStateNotifier = null;
    final chatNotifier = _chatNotifier;
    final gameEventDatasource = _gameEventDatasource;
    final isDummy = widget.isDummy;
    final backgroundService = _backgroundService;
    Future.microtask(() {
      chatNotifier?.disconnectChat();
      if (!isDummy) gameEventDatasource?.disconnect();
      // 게임 화면 이탈 시 백그라운드 인프라 정리
      // GAME_OVER 이벤트로 이미 정리된 경우는 멱등성으로 no-op
      backgroundService.stop();
      AppLifecycleService.instance().disableKeepAlive();
    });
    super.dispose();
  }

  /// 경찰 대기 타이머 팝업 (경찰 팀만, 서버 startTime 기준 남은 시간)
  void _showPoliceTimerIfNeeded() {
    if (widget.isDummy || !GameTeam.isPolice(widget.team)) return;

    final info = ref.read(gameParticipantNotifierProvider);
    final startTimeStr = info?.gameStartTime;
    final waitMinutes = info?.policeWaitMinutes;
    if (startTimeStr == null || waitMinutes == null || waitMinutes <= 0) return;

    final startTime = IsoTimestampParser.parse(startTimeStr);
    if (startTime == null) return;

    final waitEndTime = startTime.add(Duration(minutes: waitMinutes));
    final remaining = waitEndTime.difference(DateTime.now());
    if (remaining <= Duration.zero) return;

    AppPopup.show(
      context: context,
      autoCloseDuration: remaining,
      content: CountdownTimerContent(
        duration: remaining,
        subtitle: AppLocalizations.of(context).gameRobberOnTheRunBanner,
      ),
    );
  }

  /// 게임 설정 API 보완 초기화
  ///
  /// splash 재접속 등으로 [gameParticipantNotifierProvider] 상태가 없거나
  /// 설정값이 누락된 경우 `GET /api/games/{gameId}` API로 보완합니다.
  /// 로비를 거친 정상 진입 경로에서는 이미 설정값이 있으므로 early return됩니다.
  Future<void> _initSettingsFromApiIfNeeded() async {
    if (widget.isDummy) return;

    final info = ref.read(gameParticipantNotifierProvider);
    if (info?.roundTimeMinutes != null) return; // 이미 초기화됨

    try {
      final settings = await ref.read(
        fetchGameSettingsProvider(_gameId).future,
      );
      if (!mounted) return;

      final isEvent = settings.isEventGame || kEventGameDevOverride;

      // state가 null이면 (splash 재접속) 기본값으로 초기화
      if (ref.read(gameParticipantNotifierProvider) == null) {
        ref
            .read(gameParticipantNotifierProvider.notifier)
            .setGameInfo(
              gameId: _gameId,
              nickname: '',
              team: widget.team,
              participantId: widget.participantId,
              isEventGame: isEvent,
            );
      }

      ref
          .read(gameParticipantNotifierProvider.notifier)
          .initFromLobby(
            participantId: widget.participantId,
            maxParticipants: settings.maxParticipants,
            locationRevealIntervalMinutes:
                settings.locationRevealIntervalMinutes,
            policeWaitMinutes: settings.policeWaitMinutes,
            roundTimeMinutes: settings.roundDurationMinutes,
            isEventGame: isEvent,
          );

      if (!mounted) return;

      if (settings.gameStartTime != null) {
        ref
            .read(gameParticipantNotifierProvider.notifier)
            .setGameStartTime(settings.gameStartTime!);
      }

      // 설정 로드 후 경찰 타이머 재확인 (첫 호출 시 설정 없어 early return됐을 수 있음)
      if (mounted) _showPoliceTimerIfNeeded();
    } catch (_) {
      // 실패해도 게임 진행에는 영향 없음 (타이머만 미표시)
    }
  }

  /// 도둑팀 전용: 경찰 시작 시각 계산
  ///
  /// gameStartTime + policeWaitMinutes. 경찰팀이거나 대기 시간이 없으면 null.
  DateTime? _computePoliceStartTime() {
    if (!GameTeam.isRobber(widget.team)) return null;

    final info = ref.read(gameParticipantNotifierProvider);
    final waitMinutes = info?.policeWaitMinutes;
    if (waitMinutes == null || waitMinutes <= 0) return null;

    final startTimeStr = info?.gameStartTime;
    final startTime = IsoTimestampParser.parse(startTimeStr);
    // 더미 모드 시 _dummyStartTime 사용
    final effectiveStartTime = _dummyStartTime ?? startTime;
    if (effectiveStartTime == null) return null;

    return effectiveStartTime.add(Duration(minutes: waitMinutes));
  }

  /// 채팅 연결 및 구독
  void _connectChat() {
    final team = GameTeam.toLowerKey(widget.team);
    _chatNotifier = ref.read(chatNotifierProvider.notifier);

    if (widget.isDummy) {
      _chatNotifier!.enableDummyMode(
        participantId: widget.participantId,
        team: team,
      );
    } else {
      _chatNotifier!.connectAndSubscribe(gameId: _gameId, team: team);
    }
  }

  /// 게임 이벤트 STOMP 연결
  void _connectGameEvents() {
    if (widget.isDummy) return;
    _gameEventNotifier = ref.read(gameEventNotifierProvider.notifier);
    _gameEventNotifier!.setLocalParticipantId(widget.participantId);
    _gameEventDatasource = ref.read(gameEventStompDatasourceProvider);
    _gameEventNotifier!.connectAndSubscribe(
      _gameId,
      team: GameTeam.toLowerKey(widget.team),
    );
    // 단일 GPS 스트림 시작(양 팀): 구역 이탈 감지 + (도둑) 위치 전송 통합.
    _startLocationStream();
    // 도둑: STOMP 연결 후 초기 위치 1회 전송.
    if (GameTeam.isRobber(widget.team)) _sendInitialLocation();

    // 게임 시작 시스템 채팅 4단계 시퀀스는 _initSettingsFromApiIfNeeded 완료 후 호출
    // (START 이벤트는 로비 STOMP에서 수신되므로 게임 이벤트 STOMP로는 오지 않음.
    //  terminate 재접속 시 participantInfo가 아직 null이므로 설정 로드 후 판단해야 함)
  }

  /// 게임 시작 시 전체채팅에 4단계 시스템 메시지를 10초 간격으로 순차 주입
  ///
  /// 한번에 보내면 배너에 마지막 메시지만 보이므로 텀을 둔다.
  /// 재입장 시에는 이미 시스템 메시지가 존재하므로 중복 발송하지 않는다.
  void _sendGameStartSystemMessages() {
    // 재입장 감지: 게임 시작 후 20초 이상 경과했으면 스킵
    // (앱 재시작 시 인메모리 채팅 state가 초기화되므로 경과 시간으로 판단)
    final participantInfo = ref.read(gameParticipantNotifierProvider);
    final startTimeStr = participantInfo?.gameStartTime;
    if (startTimeStr != null) {
      final startTime = IsoTimestampParser.parse(startTimeStr);
      if (startTime != null &&
          DateTime.now().difference(startTime).inSeconds > 20) {
        return;
      }
    }

    final gameDuration = participantInfo?.roundTimeMinutes;
    final l10n = AppLocalizations.of(context);

    final messages = <String>[
      if (gameDuration != null) l10n.gameEventStartTime(gameDuration),
      l10n.gameEventStartReady,
      l10n.gameEventStartReportTip,
      l10n.gameEventStartGo,
    ];

    for (var i = 0; i < messages.length; i++) {
      final message = messages[i];
      if (i == 0) {
        // 첫 메시지는 즉시 발송 (채팅 + 배너)
        ref
            .read(chatNotifierProvider.notifier)
            .addSystemMessage(gameId: _gameId, message: message);
        _gameEventNotifier?.setBannerMessage(message);
      } else {
        // 이후 메시지는 5초 간격으로 발송
        Timer(Duration(milliseconds: 10000 * i), () {
          if (!mounted) return;
          ref
              .read(chatNotifierProvider.notifier)
              .addSystemMessage(gameId: _gameId, message: message);
          _gameEventNotifier?.setBannerMessage(message);
        });
      }
    }
  }

  /// 게임 맵 영역 로드 (FutureProvider 트리거)
  void _loadGameArea() {
    if (widget.isDummy) return;
    ref.read(gameAreaProvider(_gameId));
  }

  /// WebSocket 재연결 성공 후 게임 상태 동기화
  ///
  /// STOMP는 끊김 구간의 이벤트를 재전송하지 않으므로,
  /// 재연결 시 서버 참가자 목록을 직접 조회해 체포 현황과 남은 도둑 수를 보정합니다.
  Future<void> _syncGameStateOnReconnect() async {
    if (widget.isDummy || !mounted) return;
    // GAME_OVER 후엔 서버가 400 "게임 진행 중 아님"을 응답하므로 호출 자체를 스킵.
    if (GameOverGuard.shouldSkipSync(
      gameOverDialogShown: _gameOverDialogShown,
    )) {
      debugPrint('[GamePage] GameOver 표시 중 → sync 스킵');
      return;
    }

    try {
      // sync 요청 직전 상태 snapshot — sync 창에 STOMP가 추가한 변화 추적용
      final before = ref.read(gameEventNotifierProvider);
      final arrestedBefore = before.arrestedParticipantIds;
      final escapedBefore = before.escapedParticipantIds;

      // autoDispose provider이므로 ref.refresh로 최신 데이터 보장
      final result = await ref.refresh(
        fetchGameParticipantsProvider(_gameId).future,
      );

      if (!mounted) return;

      // sync 요청~응답 사이에 STOMP가 반영한 ID delta 계산
      // HTTP 응답(서버 snapshot)은 요청 시점 기준이라, 그 동안 STOMP로 들어온
      // 신규 체포/탈옥을 덮어쓰지 않도록 delta를 별도로 추출해 layer한다.
      final after = ref.read(gameEventNotifierProvider);
      final stompNewArrests = after.arrestedParticipantIds.difference(
        arrestedBefore,
      );
      final stompNewEscapes = after.escapedParticipantIds.difference(
        escapedBefore,
      );

      // 서버 snapshot 기반 수감자 집합
      final serverArrested = result.robbers
          .where((p) => p.status == ParticipantStatus.jailed)
          .map((p) => p.participantId)
          .toSet();

      // 서버 snapshot 위에 sync 창 delta layer:
      //   - STOMP가 새로 체포한 사람은 추가
      //   - STOMP가 새로 탈옥시킨 사람은 제외
      final finalArrested = serverArrested
          .union(stompNewArrests)
          .difference(stompNewEscapes);

      // 서버 기준 생존 수에 sync 창 delta를 반영 (0 ~ 전체 도둑 수 범위로 clamp)
      final serverAlive = result.robbers
          .where((p) => p.status == ParticipantStatus.alive)
          .length;
      final remainingThieves =
          (serverAlive - stompNewArrests.length + stompNewEscapes.length).clamp(
            0,
            result.robbers.length,
          );

      ref
          .read(gameEventNotifierProvider.notifier)
          .syncFromParticipants(
            arrestedIds: finalArrested,
            remainingThieves: remainingThieves,
          );
    } on DioException catch (e) {
      final apiError = ApiErrorResponse.tryParse(e.response?.data);
      if (GameOverGuard.isGameNotInProgressError(
        statusCode: e.response?.statusCode,
        errorCode: apiError?.errorCode,
      )) {
        debugPrint('[GamePage] GAME_OVER 유실 의심 — 상태 동기화 API가 게임 종료 응답');
        await _showMissedGameOverFallbackDialog();
        return;
      }
      // 동기화 실패 시 게임 진행에 지장을 주지 않도록 예외를 삼킴
      debugPrint('[GamePage] ⚠️ 재연결 후 상태 동기화 실패 (무시): $e');
    } catch (e) {
      // 동기화 실패 시 게임 진행에 지장을 주지 않도록 예외를 삼킴
      debugPrint('[GamePage] ⚠️ 재연결 후 상태 동기화 실패 (무시): $e');
    }
  }

  /// 도둑 초기 위치 1회 전송 (STOMP 연결 대기 후, best-effort)
  ///
  /// 이후의 주기적 전송과 구역 이탈 감지는 [_startLocationStream]의 단일 스트림이 담당한다.
  Future<void> _sendInitialLocation() async {
    // GPS 조회 (STOMP 연결 대기와 병렬 수행)
    Position? initial;
    try {
      initial = await DeviceLocationService.getCurrentPosition();
    } catch (e) {
      debugPrint('[위치] 초기 위치 조회 실패: $e');
    }
    if (!mounted) return;

    // STOMP가 아직 connecting 중이면 connected 될 때까지 대기 (최대 15초)
    const maxWait = Duration(seconds: 15);
    final deadline = DateTime.now().add(maxWait);
    while (mounted && DateTime.now().isBefore(deadline)) {
      final connState = ref.read(gameEventNotifierProvider).connectionState;
      if (connState == StompConnectionState.connected) break;
      if (connState == StompConnectionState.error) return;
      await Future.delayed(const Duration(milliseconds: 300));
    }
    if (!mounted) return;

    // 최초 위치 전송 (best-effort: 초기 조회 실패 시 스킵)
    if (initial != null) {
      _gameEventDatasource?.publishLocation(
        _gameId,
        initial.latitude,
        initial.longitude,
      );
      _lastSentPosition = initial;
      _lastSentTime = DateTime.now();
    }
  }

  /// 단일 GPS 스트림(양 팀): 구역 이탈 감지 + (도둑·연결됨) 위치 전송
  ///
  /// 기존 전송용(distanceFilter 10m)·구역감지용(0) 두 스트림을 하나로 통합하여
  /// 도둑 팀의 GPS 구독을 2개→1개로 줄인다(배터리 절감).
  /// - 구역 이탈 감지: 양 팀, 매 틱 ([_checkZoneExit])
  /// - 위치 전송: 도둑 팀, STOMP 연결 상태에서 [shouldSendLocation] 게이트
  ///   (체포·5초 throttle·10m 이동)를 통과할 때만. OS 10m 필터를 코드 레벨 거리로 대체.
  void _startLocationStream() {
    if (widget.isDummy) return;
    _locationSubscription =
        DeviceLocationService.getPositionStream(distanceFilter: 0).listen(
          (pos) {
            if (!mounted) return;

            // 1) 구역 이탈 감지 — 양 팀, 매 틱
            _checkZoneExit(pos);

            // 내 이동 경로 누적(양 팀, 휘발성). 잡힌 도둑도 로컬 수신은 계속된다.
            _recordNotifier.addPoint(
              LatLngModel(latitude: pos.latitude, longitude: pos.longitude),
            );

            // 2) 위치 전송 — 도둑 팀, STOMP 연결 상태에서만
            if (!GameTeam.isRobber(widget.team)) return;
            final gameState = ref.read(gameEventNotifierProvider);
            if (gameState.connectionState != StompConnectionState.connected) {
              return;
            }
            // 'escaped > arrested' 우선순위(_effectiveRobberStatus·isArrestedNow와 동일 정의).
            // 이벤트 핸들러가 두 집합을 disjoint하게 유지하지만, 표준 정의로 통일해
            // 향후 불변식이 깨져도 탈옥자가 전송 차단되지 않도록 한다.
            final isArrested =
                gameState.arrestedParticipantIds.contains(
                  widget.participantId,
                ) &&
                !gameState.escapedParticipantIds.contains(widget.participantId);
            if (!shouldSendLocation(
              lastSentTime: _lastSentTime,
              now: DateTime.now(),
              lastLat: _lastSentPosition?.latitude,
              lastLng: _lastSentPosition?.longitude,
              newLat: pos.latitude,
              newLng: pos.longitude,
              isArrested: isArrested,
            )) {
              return;
            }
            _gameEventDatasource?.publishLocation(
              _gameId,
              pos.latitude,
              pos.longitude,
            );
            _lastSentPosition = pos;
            _lastSentTime = DateTime.now();
          },
          // 스트림 에러/종료 시 구독을 null로 리셋한다.
          // 누락 시 _locationSubscription이 non-null로 남아 포그라운드 복귀 시
          // 재시작 가드(_locationSubscription == null)가 막혀 위치 전송·구역
          // 감지가 영구 중단된다.
          onError: (e) {
            debugPrint('[위치] 위치 스트림 에러: $e');
            _locationSubscription = null;
          },
          onDone: () {
            _locationSubscription = null;
          },
        );
  }

  /// 플레이그라운드 영역 이탈 여부 판단 → 이탈 시 진동 + 경고 배너
  ///
  /// 매 위치 업데이트마다 호출되어 구역 안/밖 전환을 감지한다.
  /// 구역 밖이면 경계까지의 거리를 setState로 갱신하여 배너에 실시간 반영한다.
  void _checkZoneExit(Position pos) {
    // 게임 종료 또는 체포 상태에서는 불필요
    if (_gameOverDialogShown) return;
    final gameState = ref.read(gameEventNotifierProvider);
    if (gameState.arrestedParticipantIds.contains(widget.participantId)) return;

    final area = ref.read(gameAreaProvider(_gameId)).valueOrNull;
    if (area == null) return;

    // 원형/폴리곤 무관하게 shape.contains로 판정 (분기는 AreaShape 내부에 은닉)
    final isOutside = !area.playground.contains(
      GeoPoint(latitude: pos.latitude, longitude: pos.longitude),
    );
    _zoneExitDetector.update(isOutside: isOutside);
  }

  /// 구역 이탈 진입 처리: 진동(즉시 + 5초 주기 반복) + 배너 표시 + 지도 리다이렉트
  ///
  /// 참가자 화면이 떠있을 때 이탈하면 지도가 가려져 복귀 경로를 파악할 수 없으므로,
  /// 이탈 진입 시점에 지도 화면으로 강제 리다이렉트한다.
  void _onZoneExited() {
    if (!mounted) return;
    VibrationService.instance().zoneExit();
    _zoneExitVibrationTimer?.cancel();
    _zoneExitVibrationTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_zoneExitDetector.isOutside) return;
      VibrationService.instance().zoneExit();
    });
    setState(() {
      _isZoneExitWarningActive = true;
      _showParticipants = false;
    });
  }

  /// 구역 복귀 처리: 진동 Timer 정리 + 배너 숨김
  void _onZoneEntered() {
    _clearZoneExitWarning();
  }

  /// 외부 사유(체포·게임 종료·재연결 모달)로 이탈 경고 신호를 강제 정리
  ///
  /// `_onZoneEntered`와 달리 ZoneExitDetector 상태(isOutside)와 무관하게 호출되며,
  /// 진동 타이머만 cancel하고 시각 신호 플래그도 false로 내린다. ZoneExitDetector
  /// 자체 상태는 건드리지 않으므로, 외부 사유가 해제되면 다음 위치 업데이트에서
  /// 정상적으로 이탈 콜백이 다시 발화한다.
  void _clearZoneExitWarning() {
    _zoneExitVibrationTimer?.cancel();
    _zoneExitVibrationTimer = null;
    if (!mounted || !_isZoneExitWarningActive) return;
    setState(() => _isZoneExitWarningActive = false);
  }

  /// 재연결 모달 닫힘 후 보류된 구역 이탈 처리
  ///
  /// 모달 중 발생한 이탈(_pendingZoneExit)이 있고
  /// 여전히 구역 밖(_zoneExitDetector.isOutside)이면 진동·배너를 복구한다.
  /// 복귀했다면 플래그만 초기화하고 아무것도 하지 않는다.
  void _processPendingZoneExit() {
    if (!_pendingZoneExit) return;
    _pendingZoneExit = false;
    if (_zoneExitDetector.isOutside && mounted) {
      _onZoneExited();
    }
  }

  /// 재연결 모달 표시 헬퍼 — 중복 표시 방지 및 N회 연속 끊김 재귀 처리
  ///
  /// 모달 .then() 콜백에서 재귀 호출하므로, 닫힘 애니메이션(~250ms) 중
  /// 발생한 끊김도 놓치지 않고 다시 표시할 수 있습니다.
  void _showReconnectModalIfNeeded() {
    // 게임 종료 다이얼로그 시퀀스 시작 후에는 재연결 모달 표시 금지
    // (_gameOverDialogShown은 disconnect()보다 먼저 세팅되므로 isGameOver 리셋 영향 없음)
    // 능동 퇴장 중에는 disconnect()가 동기 발화시키는 재연결 모달을 막는다
    if (!mounted ||
        _isReconnectModalShown ||
        _gameOverDialogShown ||
        _isLeaving) {
      return;
    }

    final currentState = ref.read(gameEventNotifierProvider);
    if (currentState.isGameOver ||
        (currentState.connectionState != StompConnectionState.disconnected &&
            currentState.connectionState != StompConnectionState.error)) {
      _processPendingZoneExit();
      return;
    }

    // 이탈 팝업이 떠 있거나 현재 구역 밖이라면, 재연결 모달이 닫힌 뒤
    // 팝업을 복구해야 함을 보류 플래그로 기록한다.
    // (ZoneExitDetector 는 상태 전환에만 콜백이 발화하므로 모달 종료 후
    //  위치 업데이트만으로는 자동 복구되지 않음)
    if (shouldMarkZoneExitAsPendingOnReconnect(
      isPopupShown: _isZoneExitWarningActive,
      isDetectorOutside: _zoneExitDetector.isOutside,
    )) {
      _pendingZoneExit = true;
    }

    // 재연결 모달 진입 시 진동·시각 신호를 모두 정리 (모달 위에 펄스/배너가 겹치는 것 방지)
    // 모달 닫힘 후 _processPendingZoneExit이 _pendingZoneExit 플래그를 보고 복구한다.
    _clearZoneExitWarning();
    _reconnectStateNotifier = ValueNotifier(currentState.connectionState);
    _isReconnectModalShown = true;
    ReconnectModal.show(
      context: context,
      isDarkMode: _isDarkMode,
      stateNotifier: _reconnectStateNotifier!,
      onReconnect: () {
        // dispose 후 모달이 화면에 남은 경우 ref 접근 크래시 방지
        if (!mounted) return;
        ref.read(gameEventNotifierProvider.notifier).manualReconnect();
        // 두 채널 모두 사용자 한 번 탭으로 복구되도록 Chat도 같이 재연결
        ref.read(chatNotifierProvider.notifier).manualReconnect();
      },
    ).then((_) {
      _isReconnectModalShown = false;
      _reconnectStateNotifier?.dispose();
      _reconnectStateNotifier = null;
      _showReconnectModalIfNeeded();
    });
  }

  /// 현재 위치를 거리 무관하게 즉시 1회 전송
  Future<void> _sendPositionNow() async {
    if (ref
        .read(gameEventNotifierProvider)
        .arrestedParticipantIds
        .contains(widget.participantId)) {
      return;
    }
    final Position? pos;
    try {
      pos = await DeviceLocationService.getCurrentPosition();
    } catch (e) {
      debugPrint('[위치] 즉시 전송 위치 조회 실패: $e');
      return;
    }
    if (!mounted || pos == null) return;
    _gameEventDatasource?.publishLocation(_gameId, pos.latitude, pos.longitude);
    _lastSentPosition = pos;
  }

  void _moveToCurrentLocation() {
    _isProgrammaticMove = true;
    setState(() => _isLocationFocused = true);
    _googleMapKey.currentState?.moveCameraToCurrentLocation();
  }

  void _onMapCameraMoved() {
    _closePingCard();
    if (_isProgrammaticMove) {
      _isProgrammaticMove = false;
      return;
    }
    if (_isLocationFocused) {
      setState(() => _isLocationFocused = false);
    }
  }

  /// 맵 롱프레스 → 화면 좌표 변환 후 선택 카드 표시
  Future<void> _onMapLongPress(LatLng latLng) async {
    // 롱프레스 인식 즉시 1회 — offset/mounted 분기와 무관하게 발생(= "인식 시")
    VibrationService.instance().longPress();
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final offset = await _googleMapKey.currentState?.latLngToScreenOffset(
      latLng,
      dpr,
    );
    if (!mounted || offset == null) return;

    final size = MediaQuery.of(context).size;
    final clamped = Offset(
      offset.dx.clamp(60.w, size.width - 60.w),
      offset.dy.clamp(80.h, size.height - 80.h),
    );

    setState(() {
      _pendingPingLatLng = latLng;
      _pingCardOffset = clamped;
    });
  }

  void _closePingCard() {
    if (_pingCardOffset == null) return;
    setState(() {
      _pingCardOffset = null;
      _pendingPingLatLng = null;
    });
  }

  /// 발견/의심 선택 → addPing(rate-limit) → 카드 닫기
  void _onSelectPing(PingType type) {
    final latLng = _pendingPingLatLng;
    if (latLng == null) return;
    final ok = ref
        .read(pingNotifierProvider.notifier)
        .addPing(
          type: type,
          latitude: latLng.latitude,
          longitude: latLng.longitude,
          gameId: _gameId,
        );
    _closePingCard();
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).pingCooldownNotice),
        ),
      );
    }
  }

  /// 게임 규칙 다이얼로그 (앱바 우측 info 버튼)
  ///
  /// 대기실과 동일한 GameRulesContent를 표시합니다.
  void _showGameRulesDialog() {
    // 다이얼로그 열기 전 포커스 해제 — 다이얼로그 닫힘 시
    // 채팅 입력 TextField로 포커스가 복원되어 시트가 올라오는 현상 방지
    FocusScope.of(context).unfocus();
    final interval = ref
        .read(gameParticipantNotifierProvider)
        ?.locationRevealIntervalMinutes;
    GameRulesContent.showAsDialog(
      context,
      isDarkMode: _isDarkMode,
      locationRevealIntervalMinutes: interval,
    );
  }

  /// 구역 경계 Circle 오버레이 (원형 구역만 해당)
  ///
  /// 폴리곤 구역은 [_buildAreaBorderPolygons]가 담당한다.
  Set<Circle> _buildAreaCircles(GameAreaEntity area) {
    final circles = <Circle>{};
    final playground = area.playground;
    if (playground is CircleShape) {
      circles.add(
        Circle(
          circleId: const CircleId('playground'),
          center: LatLng(
            playground.center.latitude,
            playground.center.longitude,
          ),
          radius: playground.radiusInMeters,
          fillColor: AppColors.transparent,
          strokeColor: AppColors.blue800,
          strokeWidth: 2,
          consumeTapEvents: false,
        ),
      );
    }
    final jail = area.jail;
    if (jail is CircleShape) {
      circles.add(
        Circle(
          circleId: const CircleId('jail'),
          center: LatLng(jail.center.latitude, jail.center.longitude),
          radius: jail.radiusInMeters,
          fillColor: AppColors.transparent,
          strokeColor: AppColors.red500,
          strokeWidth: 2,
          consumeTapEvents: false,
        ),
      );
    }
    return circles;
  }

  /// 구역 경계 Polygon 오버레이 (다각형 구역만 해당)
  Set<Polygon> _buildAreaBorderPolygons(GameAreaEntity area) {
    final polygons = <Polygon>{};
    final playground = area.playground;
    if (playground is PolygonShape) {
      polygons.add(
        Polygon(
          polygonId: const PolygonId('playground_border'),
          points: [
            for (final p in playground.points) LatLng(p.latitude, p.longitude),
          ],
          fillColor: AppColors.transparent,
          strokeColor: AppColors.blue800,
          strokeWidth: 2,
          consumeTapEvents: false,
        ),
      );
    }
    final jail = area.jail;
    if (jail is PolygonShape) {
      polygons.add(
        Polygon(
          polygonId: const PolygonId('jail_border'),
          points: [
            for (final p in jail.points) LatLng(p.latitude, p.longitude),
          ],
          fillColor: AppColors.transparent,
          strokeColor: AppColors.red500,
          strokeWidth: 2,
          consumeTapEvents: false,
        ),
      );
    }
    return polygons;
  }

  /// 위경도 원을 [points]개 꼭짓점 다각형으로 근사
  List<LatLng> _approximateCircle(
    LatLng center,
    double radiusMeters, {
    int points = 64,
  }) {
    const earthRadius = 6371000.0;
    return List.generate(points, (i) {
      final angle = i * 2 * math.pi / points;
      final latOffset = (radiusMeters / earthRadius) * (180 / math.pi);
      final lngOffset =
          (radiusMeters / earthRadius) *
          (180 / math.pi) /
          math.cos(center.latitude * math.pi / 180);
      return LatLng(
        center.latitude + latOffset * math.cos(angle),
        center.longitude + lngOffset * math.sin(angle),
      );
    });
  }

  /// 플레이그라운드 외부 영역 반투명 오버레이 폴리곤 생성
  Set<Polygon> _buildOutsideOverlay(GameAreaEntity area) {
    final c = area.playground.centroid;
    const delta = 2.0;
    final outerBounds = [
      LatLng(c.latitude + delta, c.longitude - delta),
      LatLng(c.latitude + delta, c.longitude + delta),
      LatLng(c.latitude - delta, c.longitude + delta),
      LatLng(c.latitude - delta, c.longitude - delta),
    ];

    // hole은 outer와 반대 방향 감김이 필요 — 원 근사·폴리곤 모두 reversed 적용
    final hole = area.playground.when(
      circle: (center, radius) => _approximateCircle(
        LatLng(center.latitude, center.longitude),
        radius,
      ).reversed.toList(),
      polygon: (points) => [
        for (final p in points) LatLng(p.latitude, p.longitude),
      ].reversed.toList(),
    );

    return {
      Polygon(
        polygonId: const PolygonId('outside_overlay'),
        points: outerBounds,
        holes: [hole],
        fillColor: AppColors.black.withValues(alpha: 0.4),
        strokeWidth: 0,
        consumeTapEvents: false,
      ),
    };
  }

  /// LOCATION_REVEAL 수신 시 도둑 위치 마커 갱신
  ///
  /// 경찰팀에게는 빨간 dot, 도둑팀에게는 초록 dot으로 표시한다.
  void _updateRobberMarkers(Map<int, LatLngModel> locations) {
    final latLngs = locations.map(
      (id, model) => MapEntry(id, LatLng(model.latitude, model.longitude)),
    );
    _googleMapKey.currentState?.updateRobberMarkers(
      latLngs,
      isPolice: GameTeam.isPolice(widget.team),
    );
  }

  /// 게임 종료 다이얼로그를 띄우기 전 화면/소켓/위치 리소스를 정리한다.
  void _prepareGameOverPresentation() {
    // 종료 시점에 구역 밖이었다면 진동 타이머·시각 신호가 살아있을 수 있다.
    // 결과 다이얼로그 위에 펄스/배너가 깜빡이고 진동이 폭주하지 않도록 정리한다.
    _clearZoneExitWarning();

    // 위치 스트림 종료 전에 누적 경로/거리의 종료 시각을 확정한다.
    if (!widget.isDummy) _recordNotifier.markEnd(DateTime.now());

    // iOS 파란 위치 인디케이터 즉시 해제: 게임 종료 이후 위치 수집 불필요.
    // dispose()까지 미루면 결과 다이얼로그 표시 시간 내내 인디케이터가 유지된다.
    _locationSubscription?.cancel();
    _locationSubscription = null;

    // 채팅 알림 상태 초기화 (다음 게임에서 기본값 ON으로 시작)
    ref.invalidate(chatNotificationEnabledProvider);
    // STOMP 구독 즉시 해제 (늦게 도달하는 이벤트 차단).
    // disconnect()는 시각 상태(arrestedParticipantIds 등)를 보존하므로,
    // 참가자 목록 오버레이는 마지막 체포 스냅샷을 유지한다.
    ref.read(chatNotifierProvider.notifier).disconnectChat();
    ref.read(gameEventNotifierProvider.notifier).disconnect();
    // 혹시 열려있는 다른 팝업/다이얼로그 모두 닫기
    if (mounted) {
      Navigator.of(context).popUntil((route) => route is! PopupRoute);
    }
  }

  /// GAME_OVER 이벤트를 놓쳤지만 REST 상태로 종료가 감지된 경우의 중립 fallback.
  Future<void> _showMissedGameOverFallbackDialog() async {
    if (_gameOverDialogShown) return;
    _gameOverDialogShown = true;

    debugPrint('[GamePage] GAME_OVER 유실 fallback 다이얼로그 표시');
    _prepareGameOverPresentation();

    // 유실 fallback 경로도 이탈 시 광고 노출 대상 (더미 모드 제외)
    if (!widget.isDummy) {
      unawaited(ref.read(adServiceProvider).preloadGameEndInterstitial());
    }

    if (!mounted) return;

    final gameId = int.tryParse(widget.sessionId);
    await _showFallbackResultDialog(null, gameId);
  }

  /// 게임 종료 후 "홈으로" 선택 시 홈 목적지.
  ///
  /// fromGameExit: 방금 퇴장 요청을 보냈으므로 홈의 활성 게임 안전망이
  /// (leave 완료 전의) stale WAITING 참가 상태를 보고 대기방으로 되돌리는
  /// 레이스를 1회 차단한다.
  static const String _homeAfterGameExit =
      '${RoutePaths.home}?fromGameExit=true';

  /// 게임 중 나가기 진입점 — AppBar 나가기 버튼 / 시스템 뒤로가기 공통.
  ///
  /// 단순 확인 다이얼로그(대기방 톤) → 확인 시 [_leaveGameActively].
  Future<void> _confirmLeaveGame() async {
    // 이미 나가는 중이거나 게임 종료 다이얼로그가 떠 있으면 무시(중복/충돌 방지)
    if (_isLeaving || _gameOverDialogShown) return;

    // 더미 모드는 서버 호출 없이 즉시 홈
    if (widget.isDummy) {
      if (mounted) context.go(RoutePaths.home);
      return;
    }

    // 확인 다이얼로그를 읽는 동안 종료 광고를 미리 로드(표시 성공률 ↑)
    unawaited(ref.read(adServiceProvider).preloadGameEndInterstitial());

    final l10n = AppLocalizations.of(context);
    final confirmed = await AppDialog.confirm(
      context: context,
      title: l10n.gameLeaveConfirmTitle,
      message: l10n.gameLeaveConfirmMessage,
      confirmText: l10n.buttonLeave,
      cancelText: l10n.buttonCancel,
      isDestructive: true,
      confirmTextColor: AppColors.white,
      isDarkMode: _isDarkMode,
      backgroundColor: _isDarkMode ? AppColors.black : null,
    );
    if (confirmed != true || !mounted) return;
    await _leaveGameActively();
  }

  /// 능동 퇴장 실행 — API 우선 await. 실패 시 잔류, 성공 시에만 소켓 정리 + 홈 이동.
  ///
  /// [_isLeaving] 가드를 먼저 세워, await 동안 서버가 브로드캐스트한 내 몰수
  /// GAME_OVER가 결과 다이얼로그로 뜨는 것을 막는다(B-3 타이밍).
  Future<void> _leaveGameActively() async {
    if (_isLeaving) return; // 중복 진입 방지
    _isLeaving = true; // GAME_OVER 리스너 / resume 가드 ON

    final l10n = AppLocalizations.of(context);
    try {
      // ① 서버 퇴장 먼저 await
      await ref.read(leaveGameProvider(_gameId).future);
    } catch (e) {
      debugPrint('[GamePage] ⚠️ 퇴장 API 실패: $e');
      _isLeaving = false;
      if (!mounted) return;
      // 클라이언트 실패 사이 서버가 (마지막 플레이어 몰수 등으로) 게임을 종료했을 수 있다.
      // await 창에서 도착한 GAME_OVER를 _isLeaving 가드가 한 번 삼켰으므로,
      // 이미 종료 상태면 정상 결과창으로 복구한다(소켓 정리는 _showGameOverDialog가 수행).
      final eventState = ref.read(gameEventNotifierProvider);
      if (eventState.isGameOver) {
        _showGameOverDialog(eventState.winnerTeam, eventState.gameOverReason);
        return;
      }
      // 게임이 계속됨 → 잔류(소켓 유지) + 안내
      AppSnackbar.show(
        context,
        message: l10n.gameLeaveFailedMessage,
        backgroundColor: AppColors.red,
        isDarkMode: _isDarkMode,
      );
      return;
    }

    if (!mounted) return;

    // ② 로컬 참가자 상태 clear (게임 종료 홈경로와 동일)
    ref.read(gameParticipantNotifierProvider.notifier).clear();

    // ③ 소켓/위치/채팅 정리 — 게임 종료와 동일 cleanup 재사용
    _prepareGameOverPresentation();

    // ④ 홈 이동 + 종료 광고(이동 먼저, 광고는 전환 위)
    _exitGameAfterAd(choice: 'leave_mid_game', destination: _homeAfterGameExit);
  }

  /// 서버 퇴장 요청 (fire-and-forget) — 실패해도 이탈 흐름을 막지 않는다.
  ///
  /// 실패 시 서버엔 WAITING 참가 상태가 남지만, 이후 콜드 스타트 복구 등
  /// 안전망이 서버 상태에 수렴하므로 재시도하지 않는다.
  void _requestLeaveGameSilently(int gameId) {
    unawaited(
      ref
          .read(leaveGameProvider(gameId).future)
          .then<void>(
            (_) => debugPrint('[GamePage] ✅ 게임 종료 후 퇴장 완료'),
            onError: (Object e, StackTrace st) {
              debugPrint('[GamePage] ⚠️ 게임 종료 후 퇴장 실패(무시): $e');
            },
          ),
    );
  }

  /// 결과 다이얼로그 이탈 선택 처리 — 먼저 목적지로 이동하고 전면 광고를 그 위에 덮는다.
  ///
  /// 라우팅을 광고 닫힘 콜백에 의존시키면 안 된다:
  /// - 콜백 유실/가드 차단 시 PopScope(canPop:false) 다이얼로그에 사용자가 갇히고,
  /// - 이동이 광고 닫힘 직후(paused→resumed 전환 중)에 일어나 목적지 화면의
  ///   초기화(API/STOMP)가 누락되어 stale UI가 보이는 문제가 실기기에서 재현됐다.
  /// 먼저 이동하면 목적지 화면이 앱 active 상태에서 즉시 초기화되고,
  /// 광고는 전환 위에 떴다가 사라질 뿐이라 두 문제 모두 구조적으로 사라진다.
  void _exitGameAfterAd({required String choice, required String destination}) {
    // 라우트 전환 완료 전 프레임의 두 번째 탭이 이벤트 중복 기록을 만들지 않도록
    if (_exitTriggered) return;
    _exitTriggered = true;

    // context.go 이후 GamePage가 dispose되면 ref를 쓸 수 없으므로 미리 확보
    // (둘 다 keepAlive 싱글턴이라 dispose 이후 사용해도 안전)
    final analytics = ref.read(analyticsServiceProvider);
    final adService = ref.read(adServiceProvider);

    unawaited(analytics.logGameExitChoice(choice: choice));

    // 1. 이동 먼저 — 광고 성공/실패와 무관하게 항상 실행된다
    context.go(destination);

    // 2. 광고를 전환 위에 표시 — 닫힘 시 할 일 없음 (이동은 이미 끝남)
    final result = adService.showGameEndInterstitial(onComplete: () {});

    unawaited(analytics.logAdInterstitialResult(status: result.analyticsValue));
  }

  /// 게임 종료 → 결과 팝업 2단계 시퀀스
  ///
  /// 1단계: "게임 종료" 알림 팝업 (3초 자동 닫힘)
  /// 2단계: GameOverResultDialog — 캐릭터 오버레이 + 통계 + 홈으로/한 번 더
  ///
  /// 1단계 진입 직전에 [gameResultProvider]를 사전 트리거하여,
  /// 2단계 다이얼로그가 뜰 때 API 응답이 이미 준비되도록 한다.
  Future<void> _showGameOverDialog(String? winnerTeam, String? reason) async {
    if (_gameOverDialogShown) return;
    _gameOverDialogShown = true;

    // GAME_OVER 이벤트 state에서 gameResultId 캡처.
    final gameResultId = ref.read(gameEventNotifierProvider).gameResultId;

    _prepareGameOverPresentation();

    // 전면 광고 사전 로드 — 결과 확인 후 이탈(홈으로/한 번 더) 시점에 1회 노출.
    // 더미 모드 제외, 로드 실패해도 무시 (fail-open)
    if (!widget.isDummy) {
      unawaited(ref.read(adServiceProvider).preloadGameEndInterstitial());
    }

    // game_over 퍼널 이벤트 (_gameOverDialogShown 가드 직후라 게임당 1회 보장)
    // winnerTeam이 null이면 승패 미상이므로 lose로 오기록하지 않고 unknown으로 분류
    final gameStartTime = ref.read(gameEventNotifierProvider).gameStartTime;
    final gameOverResult = winnerTeam == null
        ? 'unknown'
        : (winnerTeam == widget.team ? 'win' : 'lose');
    unawaited(
      ref
          .read(analyticsServiceProvider)
          .logGameOver(
            result: gameOverResult,
            team: widget.team,
            reason: reason ?? 'unknown',
            durationMinutes: gameStartTime == null
                ? 0
                : DateTime.now().difference(gameStartTime).inMinutes,
          ),
    );

    // 결과 API 사전 트리거 (1단계 3초 동안 백그라운드에서 로딩)
    if (gameResultId != null) {
      // fire-and-forget — 다이얼로그에서 ref.watch로 같은 Provider를 구독한다.
      // 에러는 Provider에 캐시되어 결과 다이얼로그의 AsyncValue.error 분기로 표시된다.
      // 여기서는 미소비 Future 에러가 전역 에러로 번지지 않도록 소비만 한다.
      unawaited(
        ref
            .read(gameResultProvider(gameResultId).future)
            .then<void>(
              (_) {},
              onError: (Object e, StackTrace st) {
                debugPrint('[GamePage] ⚠️ 게임 결과 사전 조회 실패: $e');
              },
            ),
      );
    }

    // 1단계: 게임 종료 알림 팝업 (3초 자동 닫힘)
    final l10n = AppLocalizations.of(context);
    await AppPopup.show(
      context: context,
      autoCloseDuration: const Duration(seconds: 3),
      backgroundColor: _isDarkMode ? AppColors.black : null,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.gameOverBannerTitle,
            style: _isDarkMode
                ? AppTextStyles.robberHeading.copyWith(color: AppColors.green)
                : AppTextStyles.heading_20.copyWith(color: AppColors.black),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.vertical8),
          Text(
            gameOverReasonMessage(l10n, reason),
            style: _isDarkMode
                ? AppTextStyles.paragraph_14_100.copyWith(
                    color: AppColors.black400,
                  )
                : AppTextStyles.paragraph_14.copyWith(
                    color: AppColors.black600,
                  ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

    if (!mounted) return;

    // 2단계: 결과 다이얼로그 (캐릭터 오버레이 + 통계)
    final gameId = int.tryParse(widget.sessionId);

    // 이벤트 모드: 서버 통계 대신 로컬 검거 카운트 + 증거 보드.
    if (ref.read(gameParticipantNotifierProvider)?.isEventGame ?? false) {
      final arrestCount = ref
          .read(gameEventNotifierProvider)
          .myArrestedRobberIds
          .length;
      await EventResultBoard.show(
        context: context,
        arrestCount: arrestCount,
        onGoHome: () {
          if (GameOverGuard.shouldSkipDialogCallback(isMounted: mounted)) {
            return;
          }
          if (GameOverGuard.shouldRequestLeaveGameAfterGameOver() &&
              gameId != null) {
            _requestLeaveGameSilently(gameId);
          }
          ref.read(gameParticipantNotifierProvider.notifier).clear();
          _exitGameAfterAd(choice: 'home', destination: _homeAfterGameExit);
        },
      );
      if (!mounted) return;
      return;
    }

    // gameResultId가 null인 경우 기존 방식으로 fallback (AppDialog 최소 정보만)
    if (gameResultId == null || winnerTeam == null) {
      await _showFallbackResultDialog(winnerTeam, gameId);
      return;
    }

    await GameOverResultDialog.show(
      context: context,
      isDarkMode: _isDarkMode,
      myTeam: widget.team,
      winnerTeam: winnerTeam,
      gameResultId: gameResultId,
      onGoHome: () {
        // GamePage가 외부 사유로 이미 dispose된 경우 ref/context 사용 금지 (안전망)
        if (GameOverGuard.shouldSkipDialogCallback(isMounted: mounted)) return;
        if (GameOverGuard.shouldRequestLeaveGameAfterGameOver() &&
            gameId != null) {
          _requestLeaveGameSilently(gameId);
        }
        ref.read(gameParticipantNotifierProvider.notifier).clear();
        _exitGameAfterAd(choice: 'home', destination: _homeAfterGameExit);
      },
      onRematch: () {
        if (GameOverGuard.shouldSkipDialogCallback(isMounted: mounted)) return;
        ref.read(gameParticipantNotifierProvider.notifier).clear();
        _exitGameAfterAd(
          choice: 'rematch',
          destination: RoutePaths.waitingRoomWithId(widget.sessionId),
        );
      },
    );
  }

  /// `gameResultId`가 없을 때 기존 AppDialog 기반 최소 결과 다이얼로그 표시 (방어 로직)
  Future<void> _showFallbackResultDialog(
    String? winnerTeam,
    int? gameId,
  ) async {
    final l10n = AppLocalizations.of(context);
    final hasWinnerTeam =
        GameTeam.isPolice(winnerTeam) || GameTeam.isRobber(winnerTeam);
    final isWin = hasWinnerTeam && winnerTeam == widget.team;
    final winnerTeamLabel = GameTeam.isPolice(winnerTeam)
        ? l10n.gameTeamCop
        : l10n.gameTeamRobber;

    await AppDialog.show(
      context: context,
      title: hasWinnerTeam
          ? (isWin ? l10n.gameResultWin : l10n.gameResultLose)
          : l10n.gameOverBannerTitle,
      message: hasWinnerTeam
          ? l10n.messageGameOverWinner(winnerTeamLabel)
          : l10n.gameOverFallbackMessage,
      titleStyle:
          (_isDarkMode
                  ? AppTextStyles.robberHeading24
                  : AppTextStyles.heading_20)
              .copyWith(
                color: _isDarkMode
                    ? AppColors.green
                    : hasWinnerTeam
                    ? (isWin ? AppColors.blue : AppColors.red)
                    : AppColors.black,
              ),
      cancelText: l10n.buttonGoHome,
      confirmText: l10n.buttonPlayAgain,
      isDarkMode: _isDarkMode,
      backgroundColor: _isDarkMode ? AppColors.black : null,
      barrierDismissible: false,
      onCancel: () {
        if (GameOverGuard.shouldSkipDialogCallback(isMounted: mounted)) return;
        // GAME_OVER 유실 fallback(승패 미상)도 서버상 WAITING 참가자로 남으므로
        // 동일하게 퇴장한다 — hasWinnerTeam 여부와 무관
        if (GameOverGuard.shouldRequestLeaveGameAfterGameOver() &&
            gameId != null) {
          _requestLeaveGameSilently(gameId);
        }
        ref.read(gameParticipantNotifierProvider.notifier).clear();
        _exitGameAfterAd(choice: 'home', destination: _homeAfterGameExit);
      },
      onConfirm: () {
        if (GameOverGuard.shouldSkipDialogCallback(isMounted: mounted)) return;
        ref.read(gameParticipantNotifierProvider.notifier).clear();
        _exitGameAfterAd(
          choice: 'rematch',
          destination: RoutePaths.waitingRoomWithId(widget.sessionId),
        );
      },
    );
  }

  /// resumed 복귀 시 소켓 재연결 (필요한 경우에만)
  ///
  /// OS가 백그라운드에서 WebSocket을 끊거나, 지수 백오프 5회 소진 후
  /// dead 상태로 방치된 경우를 복구합니다.
  void _reconnectSocketsIfNeeded() {
    if (widget.isDummy) return;
    // 능동 퇴장 중 백그라운드→포그라운드 복귀 시 소켓 재연결 금지(끊는 흐름과 충돌)
    if (_isLeaving) return;
    if (GameOverGuard.shouldSkipResume(
      gameOverDialogShown: _gameOverDialogShown,
    )) {
      debugPrint('[GamePage] GameOver 모달 표시 중 → 소켓 재연결 스킵');
      return;
    }

    final chatState = ref.read(chatNotifierProvider).connectionState;
    if (chatState != StompConnectionState.connected &&
        chatState != StompConnectionState.connecting) {
      final team = GameTeam.toLowerKey(widget.team);
      _chatNotifier?.connectAndSubscribe(gameId: _gameId, team: team);
    }

    final gameEventState = ref.read(gameEventNotifierProvider).connectionState;
    if (gameEventState != StompConnectionState.connected &&
        gameEventState != StompConnectionState.connecting) {
      _gameEventNotifier?.connectAndSubscribe(
        _gameId,
        team: GameTeam.toLowerKey(widget.team),
      );
    }

    // 양 팀: 위치/구역 감지 스트림이 끊겼으면 재시작 (백그라운드 복귀 시 복구).
    // 도둑 위치 즉시 재전송은 STOMP connected 핸들러(_sendPositionNow)가 담당한다.
    if (_locationSubscription == null) {
      _startLocationStream();
    }
  }

  /// resumed 복귀 시 게임 종료 여부 확인
  ///
  /// 백그라운드 중 게임이 끝났을 경우 홈으로 이동,
  /// 대기실로 돌아간 경우 로비로 이동합니다.
  Future<void> _checkGameStatusOnResume() async {
    if (_isLeaving) return;
    // GameOver 모달 표시 중에는 lifecycle resume의 자동 라우팅을 스킵한다.
    // 사용자가 모달의 '홈으로'/'한 번 더'를 명시 선택하면 그 콜백에서 라우팅된다.
    // 가드가 없으면 백그라운드 중 GAME_OVER 후 포그라운드 복귀 시 GamePage가 dispose되어
    // 모달 콜백의 ref/context 사용이 실패한다(ref disposed 에러).
    if (GameOverGuard.shouldSkipResume(
      gameOverDialogShown: _gameOverDialogShown,
    )) {
      debugPrint('[GamePage] GameOver 모달 표시 중 → resume 자동 라우팅 스킵');
      return;
    }

    debugPrint(
      '[GamePage] _checkGameStatusOnResume 호출 '
      '(isChecking=$_isCheckingGameStatus, isDummy=${widget.isDummy})',
    );
    if (_isCheckingGameStatus || widget.isDummy) return;
    _isCheckingGameStatus = true;
    try {
      final status = await ref.read(getMyActiveGameUsecaseProvider).execute();
      debugPrint(
        '[GamePage] API 응답: isParticipating=${status.isParticipating}, '
        'gameStatus=${status.participationInfo?.gameStatus}',
      );
      if (!mounted) {
        debugPrint('[GamePage] mounted=false, return');
        return;
      }

      final info = status.participationInfo;

      if (info == null ||
          GameOverGuard.shouldShowMissedGameOverFallback(
            isParticipating: status.isParticipating,
            gameStatus: info.gameStatus,
          )) {
        debugPrint(
          '[GamePage] GAME_OVER 유실 의심 — resume 상태: '
          'isParticipating=${status.isParticipating}, '
          'gameStatus=${info?.gameStatus}',
        );
        await _showMissedGameOverFallbackDialog();
      } else if (info.gameStatus == GameStatus.waiting) {
        // 대기실 상태 → 로비로 복귀
        debugPrint('[GamePage] WAITING 감지 → 로비 이동');
        context.go(RoutePaths.waitingRoomWithId(info.gameId.toString()));
      } else {
        debugPrint('[GamePage] IN_PROGRESS → 현재 화면 유지');
      }
    } catch (e) {
      // API 실패 시 현재 화면 유지
      debugPrint('[GamePage] _checkGameStatusOnResume 에러: $e');
    } finally {
      _isCheckingGameStatus = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // resumed 복귀 시 게임 종료 여부 확인
    ref.listen(lifecycleStateProvider, (_, next) {
      if (next.valueOrNull == AppLifecycleState.resumed) {
        _checkGameStatusOnResume();
        _reconnectSocketsIfNeeded();
      }
    });

    // 체포 이벤트 감지 → 열려있는 다이얼로그(QR 등) 닫기 + 이탈 경고 정리
    // 본인이 체포되면 _checkZoneExit가 가드되어 더 이상 호출되지 않지만,
    // 이미 켜진 진동 타이머와 시각 신호 플래그는 ArrestLockOverlay 위에 잔존하므로
    // 여기서 명시적으로 정리한다.
    ref.listen(
      gameEventNotifierProvider.select((s) => s.arrestedParticipantIds),
      (prev, next) {
        if (prev == null) return;
        final newlyArrested = next.difference(prev);
        if (newlyArrested.contains(widget.participantId) && mounted) {
          _clearZoneExitWarning();
          Navigator.of(context).popUntil((route) => route is! PopupRoute);
        }
      },
    );

    // 게임 이벤트 감지 → 게임 종료 다이얼로그
    ref.listen(gameEventNotifierProvider, (prev, next) {
      if (_isLeaving) return;
      if (!(prev?.isGameOver ?? false) && next.isGameOver) {
        _showGameOverDialog(next.winnerTeam, next.gameOverReason);
      }
    });

    // 게임 이벤트 → 전체채팅 시스템 메시지 주입 (chat feature와 game feature를 중재)
    ref.listen(gameEventNotifierProvider.select((s) => s.policeMoveStartTime), (
      prev,
      next,
    ) {
      if (next != null && next != _lastHandledPoliceMove) {
        _lastHandledPoliceMove = next;
        ref
            .read(chatNotifierProvider.notifier)
            .addSystemMessage(
              gameId: _gameId,
              message: AppLocalizations.of(context).gameEventPoliceMove,
            );
      }
    });

    ref.listen(
      gameEventNotifierProvider.select((s) => s.lastLocationRevealTime),
      (prev, next) {
        if (next != null && next != _lastHandledLocationReveal) {
          _lastHandledLocationReveal = next;
          ref
              .read(chatNotifierProvider.notifier)
              .addSystemMessage(
                gameId: _gameId,
                message: AppLocalizations.of(context).gameEventLocationReveal,
              );
        }
      },
    );

    // 체포 이벤트 → 전체채팅 시스템 메시지 (닉네임을 selector에 포함하여 atomic 보장)
    ref.listen(
      gameEventNotifierProvider.select(
        (s) => (
          s.arrestEventCount,
          s.lastArrestNickname,
          s.lastArrestPoliceNickname,
        ),
      ),
      (prev, next) {
        final (count, robberNick, policeNick) = next;
        if (count > _lastHandledArrestCount) {
          _lastHandledArrestCount = count;
          final l10n = AppLocalizations.of(context);
          ref
              .read(chatNotifierProvider.notifier)
              .addSystemMessage(
                gameId: _gameId,
                message: l10n.gameEventArrestNotice(
                  policeNick ?? l10n.gameRoleCopLabel,
                  robberNick ?? l10n.gameRoleRobberLabel,
                ),
              );
        }
      },
    );

    // 이벤트 모드 — 내 검거 성공(STOMP ARREST 수신, 스펙 §3) 시 증거 공개 다이얼로그.
    // HTTP 응답이 아니라 ARREST 수신을 트리거로 삼아 네트워크 불안정에도 정확히 노출.
    ref.listen(gameEventNotifierProvider.select((s) => s.myArrestSeq), (
      prev,
      next,
    ) {
      if (next > _lastHandledMyArrestSeq && mounted) {
        _lastHandledMyArrestSeq = next;
        final s = ref.read(gameEventNotifierProvider);
        EventArrestSuccessDialog.show(
          context: context,
          evidenceIndex: s.myArrestedRobberIds.length,
          robberNickname:
              s.lastMyArrestNickname ??
              AppLocalizations.of(context).gameRoleRobberLabel,
        );
      }
    });

    // 탈옥 이벤트 → 전체채팅 시스템 메시지 (STOMP 확정 카운터 기반 dedup)
    ref.listen(gameEventNotifierProvider.select((s) => s.escapeEventCount), (
      prev,
      next,
    ) {
      if (next > _lastHandledEscapeCount) {
        _lastHandledEscapeCount = next;
        ref
            .read(chatNotifierProvider.notifier)
            .addSystemMessage(
              gameId: _gameId,
              message: AppLocalizations.of(context).gameEventEscapeNotice,
            );
      }
    });

    final bannerMessage = ref.watch(
      gameEventNotifierProvider.select((s) => s.bannerMessage),
    );

    final isEventGame = ref.watch(
      gameParticipantNotifierProvider.select((p) => p?.isEventGame ?? false),
    );
    final l10n = AppLocalizations.of(context);
    final isArrested = ref.watch(
      gameEventNotifierProvider.select(
        (s) => s.arrestedParticipantIds.contains(widget.participantId),
      ),
    );
    final isEscaped = ref.watch(
      gameEventNotifierProvider.select(
        (s) => s.escapedParticipantIds.contains(widget.participantId),
      ),
    );
    final isArrestedNow = shouldShowArrestLock(
      isRobber: GameTeam.isRobber(widget.team),
      isEventGame: isEventGame,
      isArrested: isArrested,
      isEscaped: isEscaped,
    );

    // 도둑팀 경찰 시작 카운트다운용 시각 계산
    final policeStartTime = _computePoliceStartTime();

    // 연결 성공 시 게임 상태 동기화 + 도둑 팀 위치 즉시 재전송 / 끊김 시 재연결 모달 처리
    ref.listen(gameEventNotifierProvider.select((s) => s.connectionState), (
      prev,
      next,
    ) {
      // 연결 성공 → 게임 상태 동기화 + 도둑 팀 위치 즉시 재전송
      if (next == StompConnectionState.connected &&
          prev != StompConnectionState.connected) {
        // 끊김 구간 + 앱 재시작 후 첫 진입에서 누락된 체포·탈옥 상태를 서버 조회로 보정.
        // 최초 connected에서도 호출해, 재실행 시 JAILED 상태가 ArrestLockOverlay에 반영되도록 한다.
        // 의도적으로 await하지 않음 — 아래 도둑 팀 위치 즉시 재전송이
        // HTTP 응답을 기다리다 지연되지 않도록. 에러는 메서드 내부 try-catch에서 처리.
        unawaited(_syncGameStateOnReconnect());

        if (GameTeam.isRobber(widget.team) && !widget.isDummy) {
          if (_lastSentPosition != null) {
            _sendPositionNow();
          } else if (_locationSubscription == null) {
            _startLocationStream();
          }
        }
      }

      // 최초 연결 성공 추적 (초기 연결 실패 시엔 모달 미표시)
      if (next == StompConnectionState.connected) {
        _hasGameEventConnectedOnce = true;
      }

      if (!_hasGameEventConnectedOnce || widget.isDummy) return;

      // 모달이 이미 떠 있을 때: 상태 업데이트 → ReconnectModal이 스스로 닫힘
      if (_isReconnectModalShown) {
        _reconnectStateNotifier?.value = next;
        return;
      }

      // 끊김/에러 발생 → 모달 신규 표시 (게임 종료 후는 제외)
      if (next == StompConnectionState.disconnected ||
          next == StompConnectionState.error) {
        _showReconnectModalIfNeeded();
      }
    });

    ref.listen(gameEventNotifierProvider.select((s) => s.robberLocations), (
      prev,
      next,
    ) {
      _updateRobberMarkers(next);
    });

    // 게임 맵 영역 로드 완료 시 지도에 구역 경계·외부 딤 추가
    ref.listen(gameAreaProvider(_gameId), (prev, next) {
      next.whenData((area) {
        _googleMapKey.currentState?.updateMinZoom(
          area.playground.boundingRadiusInMeters,
        );
        // 카메라 이동을 플레이그라운드 주변(반경 비례 여유)으로 제한 (#486)
        final box = area.playground.boundingBox(
          marginRatio: GameConfig.cameraPanMarginRatio,
        );
        _googleMapKey.currentState?.updateCameraBounds(
          LatLngBounds(
            southwest: LatLng(box.southWest.latitude, box.southWest.longitude),
            northeast: LatLng(box.northEast.latitude, box.northEast.longitude),
          ),
        );
        _googleMapKey.currentState?.updateAreaCircles(_buildAreaCircles(area));
        _googleMapKey.currentState?.updateAreaPolygons({
          ..._buildAreaBorderPolygons(area),
          ..._buildOutsideOverlay(area),
        });
      });
    });

    // 핑 provider 생존 유지(autoDispose) — 2.5초 타이머 도중 dispose 방지
    ref.watch(pingNotifierProvider);
    ref.listen(pingNotifierProvider, (prev, next) {
      _googleMapKey.currentState?.updatePingMarkers(next, isDark: _isDarkMode);
    });

    // 위치 권한 미허용 → 다이얼로그가 표시되는 동안 빈 화면
    if (_isLocationPermissionDenied) {
      return Scaffold(
        backgroundColor: _isDarkMode ? AppColors.black800 : AppColors.white,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // 우측 액션 버튼(및 개발용 디버그 FAB)이 채팅 시트와 겹치지 않게 정렬할 bottom.
    //
    // = 채팅 시트 collapsed 고정 부분([kChatOverlayCollapsedFixedHeight])
    // + 시각 여백([_kActionButtonChatGap])
    // + 시스템 네비 inset(`MediaQuery.viewPadding.bottom`, 안드로이드 3-button 등)
    //
    // ChatOverlay 측이 inset을 자동 흡수하므로 액션 버튼도 같은 inset을 더해 정렬한다.
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
    final actionButtonBottom =
        kChatOverlayCollapsedFixedHeight.h +
        _kActionButtonChatGap.h +
        bottomInset;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _confirmLeaveGame();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            /// index 0: 지도 (항상 존재)
            Positioned.fill(
              child: GoogleMapView(
                key: _googleMapKey,
                onCameraMoveStarted: _onMapCameraMoved,
                onLongPress: _onMapLongPress,
                isDarkMode: _isDarkMode,
              ),
            ),

            /// index 1: 참가자 목록 오버레이 (if/else로 개수 고정)
            if (_showParticipants)
              Positioned.fill(
                child: Container(
                  color: _isDarkMode ? AppColors.black900 : AppColors.white,
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      children: [
                        _buildAppBar(),
                        Expanded(
                          child: ParticipantOverlay(
                            onClose: () =>
                                setState(() => _showParticipants = false),
                            gameId: _gameId,
                            myTeam: widget.team,
                            myParticipantId: widget.participantId,
                            isDarkMode: _isDarkMode,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              const SizedBox.shrink(),

            /// index 2: 상단 앱바 (if/else로 개수 고정, 지도 모드일 때만 표시)
            if (!_showParticipants)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: _isDarkMode ? AppColors.black900 : AppColors.white,
                  child: SafeArea(bottom: false, child: _buildAppBar()),
                ),
              )
            else
              const SizedBox.shrink(),

            /// index 3: 도둑팀 경찰 시작 카운트다운 (if/else로 개수 고정)
            if (!_showParticipants && policeStartTime != null)
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.only(top: 64.h + 24.h),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: PoliceStartCountdown(
                      policeStartTime: policeStartTime,
                    ),
                  ),
                ),
              )
            else
              const SizedBox.shrink(),

            /// index 4: 알림 배너 (if/else로 개수 고정, 카운트다운보다 위에 표시)
            /// 구역 이탈 중에는 ZoneExitBanner가 같은 자리를 점유하므로 표시 차단.
            /// (어차피 가려지는 정보를 띄워봐야 손실되므로 표시 자체를 막는다)
            if (!_showParticipants &&
                bannerMessage != null &&
                !_isZoneExitWarningActive)
              SafeArea(
                bottom: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 64.h + 8.h),
                    MarqueeAlertBanner(
                      message: bannerMessage,
                      isDarkMode: _isDarkMode,
                    ),
                  ],
                ),
              )
            else
              const SizedBox.shrink(),

            /// index 5: 우측 버튼 (if/else로 개수 고정)
            if (_showParticipants)
              Positioned(
                right: 20.w,
                bottom: actionButtonBottom,
                child: Column(
                  children: [
                    SvgIconButton(
                      assetPath: AppIcons.map,
                      onPressed: () =>
                          setState(() => _showParticipants = false),
                      iconColor: _isDarkMode ? AppColors.green : AppColors.blue,
                      backgroundColor: _isDarkMode ? AppColors.black : null,
                      isDarkMode: _isDarkMode,
                    ),
                    SizedBox(height: AppSpacing.vertical8),
                    _buildQrButton(),
                  ],
                ),
              )
            else
              Positioned(
                right: 20.w,
                bottom: actionButtonBottom,
                child: Column(
                  children: [
                    // 증거보드: 읽기 전용 검거 현황 조회 → 이탈 경고 중에도 항상 노출(가드 밖).
                    // 이벤트 모드 경찰 전용(도둑/일반 게임은 검거 카운트 의미 없음).
                    if (isEventGame && GameTeam.isPolice(widget.team)) ...[
                      SvgIconButton(
                        assetPath: 'assets/characters/robber/default/home.svg',
                        onPressed: () => EventResultBoard.show(
                          context: context,
                          arrestCount: ref
                              .read(gameEventNotifierProvider)
                              .myArrestedRobberIds
                              .length,
                          title: l10n.gameEventProgressTitle,
                          buttonText: l10n.buttonClose,
                          onGoHome: () => Navigator.of(context).pop(),
                        ),
                        backgroundColor: _isDarkMode ? AppColors.black : null,
                        isDarkMode: _isDarkMode,
                      ),
                      SizedBox(height: AppSpacing.vertical8),
                    ],
                    // 참가자·QR 모두 이탈 중에는 숨김.
                    // 구역 밖에선 체포/QR 액션 자체가 무의미 + 외적으로도 차단 필요.
                    // 복귀 경로는 좌측 하단 내 위치 버튼이 담당.
                    if (!_isZoneExitWarningActive) ...[
                      SvgIconButton(
                        assetPath: AppIcons.person,
                        onPressed: () =>
                            setState(() => _showParticipants = true),
                        iconColor: _isDarkMode
                            ? AppColors.green
                            : AppColors.blue,
                        backgroundColor: _isDarkMode ? AppColors.black : null,
                        isDarkMode: _isDarkMode,
                      ),
                      SizedBox(height: AppSpacing.vertical8),
                      _buildQrButton(),
                    ],
                  ],
                ),
              ),

            /// index 5b: 좌측 하단 내 위치 버튼 (지도 모드 한정, if/else로 개수 고정)
            ///
            /// 이탈 중에도 활성화 유지 — 복귀 경로 파악에 필수적이라 차단하면 UX 저해.
            /// 참가자 모드에서는 지도가 안 보이므로 의미 없음 → 숨김.
            if (!_showParticipants)
              Positioned(
                left: 20.w,
                bottom: actionButtonBottom,
                child: MyLocationButton(
                  onPressed: _moveToCurrentLocation,
                  isFocused: _isLocationFocused,
                  focusedColor: _isDarkMode ? AppColors.green : AppColors.blue,
                  unfocusedColor: _isDarkMode
                      ? AppColors.green500
                      : AppColors.blue500,
                  backgroundColor: _isDarkMode ? AppColors.black : null,
                  isDarkMode: _isDarkMode,
                ),
              )
            else
              const SizedBox.shrink(),

            /// index 6: 체포 잠금 오버레이 (if/else로 개수 고정, 도둑팀 체포 시 표시)
            if (isArrestedNow)
              ArrestLockOverlay(
                gameId: _gameId,
                myParticipantId: widget.participantId,
              )
            else
              const SizedBox.shrink(),

            /// index 6b: 핑 선택 카드 (if/else로 개수 고정 — ChatOverlay State 보존)
            if (_pingCardOffset != null)
              Positioned.fill(
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: _closePingCard,
                      behavior: HitTestBehavior.opaque,
                      child: const SizedBox.expand(),
                    ),
                    Positioned(
                      left: _pingCardOffset!.dx,
                      top: _pingCardOffset!.dy,
                      child: FractionalTranslation(
                        translation: const Offset(-0.5, -1.0),
                        child: PingSelectionCard(
                          isDarkMode: _isDarkMode,
                          onFound: () => _onSelectPing(PingType.found),
                          onSuspect: () => _onSelectPing(PingType.suspect),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              const SizedBox.shrink(),

            /// index 7: 하단 채팅 오버레이 (항상 마지막 고정)
            ///
            /// Stack children 개수가 변하면 ChatOverlay의 index가 바뀌어
            /// Flutter가 기존 State를 dispose하고 새로 생성해버린다.
            /// 위의 if/else 구조로 항상 index 7에 고정해 State를 보존한다.
            ChatOverlay(
              gameId: _gameId,
              myParticipantId: widget.participantId,
              myTeam: widget.team,
              isDarkMode: _isDarkMode,
            ),

            /// index 8: [DEBUG] 개발자 도구 버튼 (if/else로 개수 고정)
            ///
            /// 홈 페이지 FloatingActionButton 패턴과 동일하게 단일 버그 아이콘으로 진입.
            /// release 빌드에서는 kDebugMode = false로 dead-code 제거됨.
            if (kDebugMode)
              Positioned(
                right: 12.w,
                top: 0,
                child: SafeArea(
                  bottom: false,
                  // 64.h: 상단 타이머 HUD Container 높이와 동일.
                  // HUD 아래로 살짝 띄워 디버그 버튼이 타이머/서브타이머와 겹치지 않게.
                  child: Padding(
                    padding: EdgeInsets.only(top: 64.h + AppSpacing.vertical8),
                    child: FloatingActionButton(
                      heroTag: 'game_debug',
                      mini: true,
                      backgroundColor: AppColors.black.withValues(alpha: 0.7),
                      foregroundColor: AppColors.white,
                      onPressed: widget.isDummy ? null : () => _showDebugMenu(),
                      child: const Icon(Icons.bug_report),
                    ),
                  ),
                ),
              )
            else
              const SizedBox.shrink(),

            /// index 9: 구역 이탈 슬림 배너 (지도 모드 + 구역 밖)
            ///
            /// 화면 가시성 우선 정책: 큰 모달/dim 없이 상단 슬림 배너로만 알림.
            /// MarqueeAlertBanner와 동일 톤(빨강 + BR large + 외부 horizontal 20).
            /// 잠금/페널티 의미는 펄스 보더(index 11), 반복 진동(Timer),
            /// 우측 액션 버튼 IgnorePointer 가드(index 5)가 담당한다.
            ///
            /// AnimatedSwitcher + SlideTransition으로 enter/exit 모두 슬라이드 처리한다
            /// (자식 위젯이 unmount되며 펑 사라지는 잘림 현상 방지).
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  // 64.h: 상단 HUD(타이머·서브타이머) Container 높이와 동일.
                  // HUD 아래에 배너가 겹쳐 들어가지 않도록 같은 값을 패딩으로 둔다.
                  padding: EdgeInsets.only(top: 64.h + AppSpacing.vertical8),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    reverseDuration: const Duration(milliseconds: 200),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, anim) => SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, -1),
                        end: Offset.zero,
                      ).animate(anim),
                      child: FadeTransition(opacity: anim, child: child),
                    ),
                    child: (_isZoneExitWarningActive && !_showParticipants)
                        ? ZoneExitBanner(
                            key: const ValueKey('zone-exit-banner'),
                            isDarkMode: _isDarkMode,
                          )
                        : const SizedBox.shrink(
                            key: ValueKey('zone-exit-banner-empty'),
                          ),
                  ),
                ),
              ),
            ),

            /// index 10: 구역 이탈 비네트 (가장 위, 터치 차단 없음)
            /// 화면 가장자리에 부드러운 빨강 그라데이션을 깔아 이탈 상태를 알린다.
            /// 중앙은 투명하게 유지되어 지도·플레이그라운드 원·내 위치를 가리지 않음.
            /// 팀 테마 분기는 위젯 내부에서 처리.
            if (_isZoneExitWarningActive)
              Positioned.fill(child: ZoneExitVignette(isDarkMode: _isDarkMode))
            else
              const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  /// [DEBUG 전용] 개발자 도구 메뉴 표시
  ///
  /// 홈 페이지 _showDevMenu와 동일한 패턴 — AppDialog + ListTile 구조.
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
            subtitle: Text('모달 잠깐 뜨다 닫힘', style: AppTextStyles.tag_12),
            onTap: () {
              Navigator.pop(context);
              debugPrint('[GamePage][DEBUG] 🔌 끊김 시뮬레이션 (자동 재연결)');
              ref.read(gameEventStompDatasourceProvider).disconnect();
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
              debugPrint('[GamePage][DEBUG] ❌ 재연결 실패 시뮬레이션 (error 상태)');
              ref
                  .read(gameEventNotifierProvider.notifier)
                  .debugForceReconnectExhausted();
            },
          ),
        ],
      ),
    );
  }

  /// QR 버튼 (경찰: 스캔, 도둑: QR 표시)
  Widget _buildQrButton() {
    return SvgIconButton(
      assetPath: GameTeam.isPolice(widget.team)
          ? AppIcons.qrScan
          : AppIcons.qrCode,
      onPressed: GameTeam.isPolice(widget.team)
          ? _openQrScanner
          : _showMyQrCode,
      backgroundColor: _isDarkMode ? AppColors.black : null,
      isDarkMode: _isDarkMode,
    );
  }

  /// 경찰: QR 스캐너를 열어 도둑을 체포
  Future<void> _openQrScanner() async {
    final gameEventState = ref.read(gameEventNotifierProvider);
    final participantInfo = ref.read(gameParticipantNotifierProvider);

    // 경찰 대기 시간 가드
    if (!gameEventState.canPoliceArrest(participantInfo: participantInfo)) {
      AppSnackbar.show(
        context,
        message: AppLocalizations.of(context).errorCannotArrestDuringWait,
      );
      return;
    }

    // 스캐너는 파싱만 담당. 만료 여부는 호출측에서 검증하여 사용자에게 원인을 명확히 안내한다.
    final payload = await Navigator.push<QrPayload>(
      context,
      MaterialPageRoute(
        builder: (_) => QrScannerPage<QrPayload>(
          title: AppLocalizations.of(context).qrScannerWantedRobberTitle,
          onParse: QrPayload.tryParse,
        ),
      ),
    );
    if (payload == null || !mounted) return;

    // 만료된 QR (스크린샷 저장 후 재사용 시나리오 등) 차단
    if (payload.isExpiredAt(DateTime.now())) {
      AppSnackbar.show(
        context,
        message: AppLocalizations.of(context).errorExpiredQr,
      );
      return;
    }

    final participantId = payload.participantId;

    final isEvent =
        ref.read(gameParticipantNotifierProvider)?.isEventGame ?? false;
    if (isEvent) {
      // 이벤트 모드: 내가 이미 검거한 운영진이면 차단
      if (ref
          .read(gameEventNotifierProvider)
          .myArrestedRobberIds
          .contains(participantId)) {
        AppSnackbar.show(
          context,
          message: AppLocalizations.of(context).errorAlreadyArrested,
        );
        return;
      }
      // 체포 요청만 전송. 카운트·증거 다이얼로그는 STOMP ARREST 수신 시 처리(스펙 §3).
      final ok = await ref
          .read(gameEventNotifierProvider.notifier)
          .requestEventArrest(_gameId, participantId);
      if (!ok && mounted) {
        AppSnackbar.show(
          context,
          message: AppLocalizations.of(context).errorEventArrestRequestFailed,
        );
      }
      return;
    }

    // --- 이하 기존 일반 모드 로직(전역 arrestedParticipantIds 기반) ---

    // 이미 체포된 도둑 체크
    final arrestedIds = ref
        .read(gameEventNotifierProvider)
        .arrestedParticipantIds;
    final escapedIds = ref
        .read(gameEventNotifierProvider)
        .escapedParticipantIds;
    if (arrestedIds.contains(participantId) &&
        !escapedIds.contains(participantId)) {
      AppSnackbar.show(
        context,
        message: AppLocalizations.of(context).errorAlreadyArrested,
      );
      return;
    }

    // QR 스캔 = 대면 확인 완료 → 즉시 체포
    ref
        .read(gameEventNotifierProvider.notifier)
        .arrestRobber(_gameId, participantId);
  }

  /// 도둑: 자신의 QR 코드 표시
  void _showMyQrCode() {
    QrDisplayDialog.show(context: context, participantId: widget.participantId);
  }

  /// 상단 앱바 (흰색 배경, 높이 64px)
  ///
  /// 대기실 등 다른 페이지 앱바 스타일과 동일.
  Widget _buildAppBar() {
    // ref.watch는 항상 무조건 호출해야 Riverpod 구독이 올바르게 등록됨
    final stompGameStartTime = ref.watch(
      gameEventNotifierProvider.select((s) => s.gameStartTime),
    );
    final participantInfo = ref.watch(gameParticipantNotifierProvider);
    final participantStartTime = IsoTimestampParser.parse(
      participantInfo?.gameStartTime,
    );
    // 우선순위: 더미 시작 시각 → STOMP START 이벤트 시각 → 대기실 게임 시작 시각
    final gameStartTime =
        _dummyStartTime ?? stompGameStartTime ?? participantStartTime;
    final roundMinutes = participantInfo?.roundTimeMinutes;
    final totalDuration = roundMinutes != null
        ? Duration(minutes: roundMinutes)
        : null;
    final lastReveal = ref.watch(
      gameEventNotifierProvider.select((s) => s.lastLocationRevealTime),
    );
    final interval = participantInfo?.locationRevealIntervalMinutes;

    final policeMoveStartTime = ref.watch(
      gameEventNotifierProvider.select((s) => s.policeMoveStartTime),
    );

    DateTime? nextRevealTime;
    if (interval != null && interval > 0) {
      // 경찰 이동 시작 시각 fallback 우선순위:
      // 1. STOMP POLICE_MOVE_START 이벤트 시각
      // 2. gameStartTime + policeWaitMinutes (재접속 시 STOMP 미수신 대비)
      // 3. policeWaitMinutes == 0이면 gameStartTime 직접 사용
      final policeWaitMinutes = participantInfo?.policeWaitMinutes;
      final effectiveMoveStartTime =
          policeMoveStartTime ??
          (policeWaitMinutes != null &&
                  policeWaitMinutes > 0 &&
                  gameStartTime != null
              ? gameStartTime.add(Duration(minutes: policeWaitMinutes))
              : (policeWaitMinutes == 0 ? gameStartTime : null));
      final base = lastReveal ?? effectiveMoveStartTime;
      if (base != null) nextRevealTime = base.add(Duration(minutes: interval));
    }

    return Container(
      height: 64.h,
      color: _isDarkMode ? AppColors.black900 : AppColors.white,
      // 좌우 인셋은 각 버튼의 Padding으로 부여(나가기 18.w / info 12.w) —
      // 일괄 패딩을 두면 대기방 leading의 18.w 값을 그대로 못 쓰기 때문.
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 중앙: 타이머 + 서브 타이머
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // START 이벤트 수신 후 경과 시간 표시
              gameStartTime != null && totalDuration != null
                  ? GameTimerText(
                      startTime: gameStartTime,
                      totalDuration: totalDuration,
                      isDarkMode: _isDarkMode,
                    )
                  : Text(
                      '--:--',
                      style: _isDarkMode
                          ? AppTextStyles.robberHeading.copyWith(
                              color: AppColors.white,
                            )
                          : AppTextStyles.heading_20.copyWith(
                              color: AppColors.black,
                            ),
                    ),
              SizedBox(height: 6.h),
              LocationRevealCountdown(
                nextRevealTime: nextRevealTime,
                intervalMinutes: interval,
                isDarkMode: _isDarkMode,
              ),
            ],
          ),
          // 좌측: 나가기 버튼 (대기방 leading과 동일 — 화면 좌측에서 18.w)
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 18.w),
              child: FlatIconButton(
                assetPath: AppIcons.exit,
                iconColor: _isDarkMode
                    ? AppColors.black200
                    : AppColors.black800,
                onPressed: _confirmLeaveGame,
              ),
            ),
          ),
          // 우측: info 버튼 (화면 우측에서 12.w)
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(right: AppSpacing.horizontal12),
              child: FlatIconButton(
                assetPath: AppIcons.info,
                iconColor: _isDarkMode
                    ? AppColors.black200
                    : AppColors.black800,
                onPressed: _showGameRulesDialog,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
