import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/config/env_config.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/tutorial/tutorial_keys.dart';
import '../../../../core/services/tutorial/tutorial_service.dart';
import '../../../../core/tutorial/app_tutorial_style.dart';
import '../../../../core/constants/game_event_messages.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/services/lifecycle/lifecycle_provider.dart';
import '../../../../core/services/location/device_location_service.dart';
import '../../../../core/services/permission/location_permission_messages.dart';
import '../../../../core/services/permission/location_permission_service.dart';
import '../../../../core/services/vibration_service.dart';
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
import '../../domain/zone_exit_detector.dart';
import '../helpers/zone_exit_reconnect_policy.dart';
import '../providers/game_area_provider.dart';
import '../providers/game_event_provider.dart';
import '../../../../core/widgets/buttons/my_location_button.dart';
import '../../../../core/widgets/snackbars/app_snackbar.dart';
import '../widgets/arrest_lock_overlay.dart';
import '../widgets/qr_display_dialog.dart';
import '../widgets/qr_scanner_page.dart';
import '../widgets/game_timer_text.dart';
import '../widgets/location_reveal_countdown.dart';
import '../widgets/google_map_view.dart';
import '../widgets/participant_overlay.dart';
import '../widgets/marquee_alert_banner.dart';
import '../widgets/police_start_countdown.dart';

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

  // 튜토리얼 하이라이트 대상 키
  final _tutorialKeyTimer = GlobalKey();
  final _tutorialKeyParticipants = GlobalKey();
  final _tutorialKeyMapReturn = GlobalKey();
  final _tutorialKeyQrButton = GlobalKey();

  bool _showParticipants = false;
  bool _gameOverDialogShown = false;
  bool _isCheckingGameStatus = false;
  bool _isLocationPermissionDenied = false;
  bool _isLocationFocused = true;
  bool _isProgrammaticMove = true; // 초기 카메라 이동(onMapCreated) 보호

  /// dispose()에서 ref 사용 불가이므로 사전에 저장
  ChatNotifier? _chatNotifier;
  GameEventNotifier? _gameEventNotifier;
  GameEventStompDatasource? _gameEventDatasource;

  StreamSubscription<Position>? _locationSubscription;
  StreamSubscription<Position>? _headingSubscription; // POLICE 전용 heading 스트림
  Position? _lastSentPosition;
  DateTime? _lastSentTime;

  // 재연결 시 시스템 메시지 중복 방지용 last-handled 값
  DateTime? _lastHandledPoliceMove;
  DateTime? _lastHandledLocationReveal;
  int _lastHandledArrestCount = 0;
  int _lastHandledEscapeCount = 0;

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
      VibrationService.instance().zoneExit();
      _showZoneExitPopup();
    },
    onEnterZone: () {
      // 구역 복귀 시 보류 플래그도 함께 초기화
      _pendingZoneExit = false;
      _dismissZoneExitPopup();
    },
  );

  /// 이탈 경고 팝업 표시 중 여부 (중복 팝업 방지)
  bool _isZoneExitPopupShown = false;

  /// 이탈 경고 팝업의 다이얼로그 context (removeRoute용)
  BuildContext? _zoneExitPopupContext;

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
  bool get _isDarkMode => widget.team == 'ROBBER';

  @override
  void initState() {
    super.initState();
    if (widget.isDummy) _dummyStartTime = DateTime.now();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureLocationAndInit();
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
      _initGameConnections();
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

    final text = await LocationPermissionMessages.getText(
      isServiceDisabled: !serviceEnabled,
      context: LocationPermissionContext.game,
    );
    if (!mounted) return;

    // 게임 중에는 나갈 수 없으므로 설정 이동 버튼만 제공
    AppDialog.show(
      context: context,
      title: text.title,
      message: text.message,
      confirmText: '설정으로 이동',
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
  void _initGameConnections() {
    if (_isLocationPermissionDenied) {
      setState(() => _isLocationPermissionDenied = false);
    }
    _connectChat();
    _connectGameEvents();
    _loadGameArea();
    _showPoliceTimerIfNeeded();
    _initSettingsAndStartMessages();

    // 게임 초기화 완료 후 튜토리얼 (첫 진입 시 1회만)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showTutorialIfNeeded();
    });
  }

  /// 게임 화면 튜토리얼 표시 (미완료 시 1회만 실행)
  Future<void> _showTutorialIfNeeded() async {
    final completed = await TutorialService.isCompleted(TutorialKeys.game);
    if (completed || !mounted) return;

    // 지도/UI 위젯 렌더링 완료 대기
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    AppTutorialStyle.show(
      context: context,
      targets: [
        AppTutorialStyle.target(
          keyTarget: _tutorialKeyTimer,
          description: '남은 게임 시간이에요',
        ),
        AppTutorialStyle.target(
          keyTarget: _tutorialKeyParticipants,
          description: '참가자 목록과 QR 체포/탈옥은 여기서 확인해요',
        ),
      ],
      onFinish: () => TutorialService.markCompleted(TutorialKeys.game),
    );
  }

  /// 참가자 목록 화면 튜토리얼 (지도 복귀 + QR 안내)
  Future<void> _showParticipantsTutorialIfNeeded() async {
    final completed = await TutorialService.isCompleted(
      TutorialKeys.gameParticipants,
    );
    if (completed || !mounted) return;

    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    final targets = [
      AppTutorialStyle.target(
        keyTarget: _tutorialKeyMapReturn,
        description: '지도 화면으로 돌아갈 수 있어요',
      ),
      AppTutorialStyle.target(
        keyTarget: _tutorialKeyQrButton,
        description: widget.team == 'POLICE'
            ? '도둑 참가자 카드를 누르거나 QR을 스캔해서 체포해요'
            : '잡히면 경찰에게 QR을 보여주고, 경찰이 스캔하면 체포돼요',
      ),
    ];

    AppTutorialStyle.show(
      context: context,
      targets: targets,
      onFinish: () =>
          TutorialService.markCompleted(TutorialKeys.gameParticipants),
    );
  }

  /// 게임 설정 로드 후 게임 시작 시스템 메시지 발송
  ///
  /// 정상 진입(로비 경유): participantInfo에 이미 설정이 있으므로 즉시 판단.
  /// terminate 재접속: API로 설정 로드 후 gameStartTime 기반으로 판단.
  Future<void> _initSettingsAndStartMessages() async {
    await _initSettingsFromApiIfNeeded();
    if (!mounted) return;
    _sendGameStartSystemMessages();
  }

  /// 앱 포그라운드 복귀 시 위치 권한 재확인
  ///
  /// 게임 중 설정에서 위치 권한을 끄고 돌아온 경우,
  /// 위치 스트림을 중단하고 권한 요청 다이얼로그를 표시합니다.
  /// 권한 허용 후에는 앱 재시작이 필요합니다.
  Future<void> _checkLocationPermissionOnResume() async {
    if (_isLocationPermissionDenied) return;

    final canAccess = await LocationPermissionService.canAccessLocation();
    if (!mounted || canAccess) return;

    // 위치 스트림 중단
    _locationSubscription?.cancel();
    _locationSubscription = null;
    _headingSubscription?.cancel();
    _headingSubscription = null;

    setState(() => _isLocationPermissionDenied = true);
    await _showLocationPermissionDialog();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _locationSubscription?.cancel();
    _headingSubscription?.cancel();
    // dispose() 중 provider 상태 수정은 Riverpod이 차단하므로 다음 프레임으로 지연.
    // gameEventNotifier.disconnect()는 내부에서 ref.read()를 호출하므로
    // provider가 dispose된 후 호출 시 에러 가능. datasource를 직접 참조해 우회.
    _reconnectStateNotifier?.dispose();
    _reconnectStateNotifier = null;
    final chatNotifier = _chatNotifier;
    final gameEventDatasource = _gameEventDatasource;
    final isDummy = widget.isDummy;
    Future.microtask(() {
      chatNotifier?.disconnectChat();
      if (!isDummy) gameEventDatasource?.disconnect();
    });
    super.dispose();
  }

  /// 경찰 대기 타이머 팝업 (경찰 팀만, 서버 startTime 기준 남은 시간)
  void _showPoliceTimerIfNeeded() {
    if (widget.isDummy || widget.team != 'POLICE') return;

    final info = ref.read(gameParticipantNotifierProvider);
    final startTimeStr = info?.gameStartTime;
    final waitMinutes = info?.policeWaitMinutes;
    if (startTimeStr == null || waitMinutes == null || waitMinutes <= 0) return;

    final startTime = DateTime.tryParse(startTimeStr);
    if (startTime == null) return;

    final waitEndTime = startTime.add(Duration(minutes: waitMinutes));
    final remaining = waitEndTime.difference(DateTime.now());
    if (remaining <= Duration.zero) return;

    AppPopup.show(
      context: context,
      autoCloseDuration: remaining,
      content: CountdownTimerContent(
        duration: remaining,
        subtitle: '도둑이 도망치는 중이에요!',
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

      // state가 null이면 (splash 재접속) 기본값으로 초기화
      if (ref.read(gameParticipantNotifierProvider) == null) {
        ref
            .read(gameParticipantNotifierProvider.notifier)
            .setGameInfo(
              gameId: _gameId,
              nickname: '',
              team: widget.team,
              participantId: widget.participantId,
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
    if (widget.team != 'ROBBER') return null;

    final info = ref.read(gameParticipantNotifierProvider);
    final waitMinutes = info?.policeWaitMinutes;
    if (waitMinutes == null || waitMinutes <= 0) return null;

    final startTimeStr = info?.gameStartTime;
    final startTime = startTimeStr != null
        ? DateTime.tryParse(startTimeStr)
        : null;
    // 더미 모드 시 _dummyStartTime 사용
    final effectiveStartTime = _dummyStartTime ?? startTime;
    if (effectiveStartTime == null) return null;

    return effectiveStartTime.add(Duration(minutes: waitMinutes));
  }

  /// 채팅 연결 및 구독
  void _connectChat() {
    final team = widget.team.toLowerCase();
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
    _gameEventDatasource = ref.read(gameEventStompDatasourceProvider);
    _gameEventNotifier!.connectAndSubscribe(_gameId);
    if (widget.team == 'ROBBER') _startLocationSending();
    _startHeadingTracking();

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
      final startTime = DateTime.tryParse(startTimeStr);
      if (startTime != null &&
          DateTime.now().difference(startTime).inSeconds > 20) {
        return;
      }
    }

    final gameDuration = participantInfo?.roundTimeMinutes;

    final messages = <String>[
      if (gameDuration != null) GameEventMessages.gameStartTime(gameDuration),
      GameEventMessages.gameStartReady,
      GameEventMessages.gameStartReportTip,
      GameEventMessages.gameStartGo,
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
          .where((p) => p.status == 'JAILED')
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
          .where((p) => p.status == 'ALIVE')
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
    } catch (e) {
      // 동기화 실패 시 게임 진행에 지장을 주지 않도록 예외를 삼킴
      debugPrint('[GamePage] ⚠️ 재연결 후 상태 동기화 실패 (무시): $e');
    }
  }

  /// 도둑 팀 GPS 위치 스트림 구독 및 서버 전송 시작
  ///
  /// distanceFilter 10m로 OS 레벨에서 필터링하고,
  /// 추가로 5초 throttle을 적용하여 서버 부하를 제한한다.
  /// 방향 갱신은 [_startHeadingTracking]의 별도 스트림이 담당한다.
  Future<void> _startLocationSending() async {
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

    // 위치 스트림 구독: 10m 이상 이동 시 이벤트 발생, 5초 throttle 적용
    _locationSubscription =
        DeviceLocationService.getPositionStream(distanceFilter: 10).listen(
          (pos) {
            if (!mounted) return;

            if (ref
                .read(gameEventNotifierProvider)
                .arrestedParticipantIds
                .contains(widget.participantId)) {
              return;
            }

            // 5초 미만이면 서버 전송 스킵 (서버 부하 제한)
            final now = DateTime.now();
            if (_lastSentTime != null &&
                now.difference(_lastSentTime!).inSeconds < 5) {
              return;
            }

            _gameEventDatasource?.publishLocation(
              _gameId,
              pos.latitude,
              pos.longitude,
            );
            _lastSentPosition = pos;
            _lastSentTime = now;
          },
          onError: (e) {
            debugPrint('[위치] 위치 스트림 에러: $e');
            _locationSubscription = null;
          },
          onDone: () {
            _locationSubscription = null;
          },
        );
  }

  /// 방향 인디케이터 실시간 갱신 스트림 시작 (양 팀 공통, 서버 전송 없음)
  /// 추가로 플레이그라운드 영역 이탈 감지 → 진동 피드백 제공
  void _startHeadingTracking() {
    if (widget.isDummy) return;
    _headingSubscription =
        DeviceLocationService.getPositionStream(distanceFilter: 0).listen((
          pos,
        ) {
          if (mounted) {
            _checkZoneExit(pos);
          }
        });
  }

  /// 플레이그라운드 영역 이탈 여부 판단 → 이탈 시 진동 + 경고 팝업
  void _checkZoneExit(Position pos) {
    // 게임 종료 또는 체포 상태에서는 불필요
    if (_gameOverDialogShown) return;
    final gameState = ref.read(gameEventNotifierProvider);
    if (gameState.arrestedParticipantIds.contains(widget.participantId)) return;

    final area = ref.read(gameAreaProvider(_gameId)).valueOrNull;
    if (area == null) return;

    final distance = Geolocator.distanceBetween(
      area.playgroundCenter.latitude,
      area.playgroundCenter.longitude,
      pos.latitude,
      pos.longitude,
    );

    _zoneExitDetector.update(
      isOutside: distance > area.playgroundRadiusInMeters,
    );
  }

  /// 구역 이탈 경고 팝업 표시
  void _showZoneExitPopup() {
    // 재연결 모달이 떠 있을 때는 구역 이탈 팝업 스킵
    // (연결 끊김 중에는 구역 판단이 무의미하고, 스택 충돌로 재연결 모달이 닫히지 않는 버그 방지)
    if (_isZoneExitPopupShown || _isReconnectModalShown || !mounted) return;
    _isZoneExitPopupShown = true;
    AppPopup.show(
      context: context,
      barrierDismissible: false,
      backgroundColor: _isDarkMode ? AppColors.black : null,
      content: Builder(
        builder: (popupContext) {
          // 다이얼로그 context를 캡처하여 removeRoute에 사용
          _zoneExitPopupContext = popupContext;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '플레이그라운드를 벗어났어요!',
                style:
                    (_isDarkMode
                            ? AppTextStyles.robberHeading
                            : AppTextStyles.heading_20)
                        .copyWith(color: AppColors.red),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.vertical12),
              Text(
                '구역 밖으로 나가면 화면이 잠겨요',
                style: AppTextStyles.paragraph_14_100.copyWith(
                  color: AppColors.red800,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          );
        },
      ),
    ).whenComplete(() {
      // 팝업이 닫히면 (어떤 경로든) 참조 정리
      _zoneExitPopupContext = null;
      _isZoneExitPopupShown = false;
    });
  }

  /// 구역 이탈 경고 팝업 닫기
  ///
  /// dialog context에서 직접 pop.
  /// removeRoute는 _history.firstWhere(!isComplete) 필터로 "Bad state: No element" 크래시 위험.
  /// GoRouter의 onPopPage는 GoRouter 비관리 route(dialog)를 통과시키므로 안전하다.
  void _dismissZoneExitPopup() {
    final popupCtx = _zoneExitPopupContext;
    if (!_isZoneExitPopupShown || popupCtx == null || !popupCtx.mounted) return;

    Navigator.of(popupCtx).pop();
  }

  /// 재연결 모달 닫힘 후 보류된 구역 이탈 처리
  ///
  /// 모달 중 발생한 이탈(_pendingZoneExit)이 있고
  /// 여전히 구역 밖(_zoneExitDetector.isOutside)이면 팝업·진동을 실행한다.
  /// 복귀했다면 플래그만 초기화하고 아무것도 하지 않는다.
  void _processPendingZoneExit() {
    if (!_pendingZoneExit) return;
    _pendingZoneExit = false;
    if (_zoneExitDetector.isOutside && mounted) {
      VibrationService.instance().zoneExit();
      _showZoneExitPopup();
    }
  }

  /// 재연결 모달 표시 헬퍼 — 중복 표시 방지 및 N회 연속 끊김 재귀 처리
  ///
  /// 모달 .then() 콜백에서 재귀 호출하므로, 닫힘 애니메이션(~250ms) 중
  /// 발생한 끊김도 놓치지 않고 다시 표시할 수 있습니다.
  void _showReconnectModalIfNeeded() {
    // 게임 종료 다이얼로그 시퀀스 시작 후에는 재연결 모달 표시 금지
    // (_gameOverDialogShown은 disconnect()보다 먼저 세팅되므로 isGameOver 리셋 영향 없음)
    if (!mounted || _isReconnectModalShown || _gameOverDialogShown) return;

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
      isPopupShown: _isZoneExitPopupShown,
      isDetectorOutside: _zoneExitDetector.isOutside,
    )) {
      _pendingZoneExit = true;
    }

    // 구역 이탈 팝업이 떠 있으면 먼저 닫음
    // (재연결 모달이 스택 하단에 깔리면 pop()이 잘못된 다이얼로그를 닫는 버그 방지)
    _dismissZoneExitPopup();
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
    if (_isProgrammaticMove) {
      _isProgrammaticMove = false;
      return;
    }
    if (_isLocationFocused) {
      setState(() => _isLocationFocused = false);
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

  /// 맵 영역 원 빌드 (Google Map용)
  Set<Circle> _buildGoogleCircles(GameAreaModel area) {
    return {
      Circle(
        circleId: const CircleId('playground'),
        center: LatLng(
          area.playgroundCenter.latitude,
          area.playgroundCenter.longitude,
        ),
        radius: area.playgroundRadiusInMeters,
        fillColor: Colors.transparent,
        strokeColor: AppColors.blue800,
        strokeWidth: 2,
        consumeTapEvents: false,
      ),
      Circle(
        circleId: const CircleId('jail'),
        center: LatLng(area.jailCenter.latitude, area.jailCenter.longitude),
        radius: area.jailRadiusInMeters,
        fillColor: Colors.transparent,
        strokeColor: AppColors.red500,
        strokeWidth: 2,
        consumeTapEvents: false,
      ),
    };
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
  Set<Polygon> _buildOutsideOverlay(GameAreaModel area) {
    final clat = area.playgroundCenter.latitude;
    final clng = area.playgroundCenter.longitude;
    const delta = 2.0;
    final outerBounds = [
      LatLng(clat + delta, clng - delta),
      LatLng(clat + delta, clng + delta),
      LatLng(clat - delta, clng + delta),
      LatLng(clat - delta, clng - delta),
    ];

    final center = LatLng(
      area.playgroundCenter.latitude,
      area.playgroundCenter.longitude,
    );
    final hole = _approximateCircle(
      center,
      area.playgroundRadiusInMeters,
    ).reversed.toList();

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
      isPolice: widget.team == 'POLICE',
    );
  }

  /// 게임 종료 → 결과 팝업 2단계 시퀀스
  ///
  /// 1단계: "게임 종료" 알림 팝업 (3초 자동 닫힘)
  /// 2단계: 결과 팝업 (커스텀 타이틀 스타일, "홈으로" 버튼)
  Future<void> _showGameOverDialog(String? winnerTeam, String? reason) async {
    if (_gameOverDialogShown) return;
    _gameOverDialogShown = true;
    // 채팅 알림 상태 초기화 (다음 게임에서 기본값 ON으로 시작)
    ref.invalidate(chatNotificationEnabledProvider);
    // STOMP 구독 즉시 해제 (늦게 도달하는 이벤트 차단)
    ref.read(gameEventNotifierProvider.notifier).disconnect();
    // 혹시 열려있는 다른 팝업/다이얼로그 모두 닫기
    if (mounted) {
      Navigator.of(context).popUntil((route) => route is! PopupRoute);
    }

    // 1단계: 게임 종료 알림 팝업 (3초 자동 닫힘)
    await AppPopup.show(
      context: context,
      autoCloseDuration: const Duration(seconds: 3),
      backgroundColor: _isDarkMode ? AppColors.black : null,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '게임 종료',
            style: _isDarkMode
                ? AppTextStyles.robberHeading.copyWith(color: AppColors.green)
                : AppTextStyles.heading_20.copyWith(color: AppColors.black),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.vertical8),
          Text(
            reason == 'ALL_ARRESTED' ? '도둑이 모두 체포되었습니다!' : '제한 시간이 종료되었습니다!',
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

    // 2단계: 게임 결과 팝업 (커스텀 타이틀 스타일, 2버튼)
    final isWin = winnerTeam == widget.team;
    final winnerTeamLabel = winnerTeam == 'POLICE' ? '경찰팀' : '도둑팀';
    final gameId = int.tryParse(widget.sessionId);

    AppDialog.show(
      context: context,
      title: isWin ? '승리' : '패배',
      message: '$winnerTeamLabel의 승리입니다!',
      titleStyle:
          (_isDarkMode
                  ? AppTextStyles.robberHeading24
                  : AppTextStyles.heading_20)
              .copyWith(
                color: _isDarkMode
                    ? AppColors.green
                    : (isWin ? AppColors.blue : AppColors.red),
              ),
      cancelText: '홈으로',
      confirmText: '한 번 더',
      isDarkMode: _isDarkMode,
      backgroundColor: _isDarkMode ? AppColors.black : null,
      confirmColor: _isDarkMode ? null : AppColors.blue,
      confirmTextColor: _isDarkMode ? null : AppColors.white,
      barrierDismissible: false,
      onCancel: () {
        // 방 나가기 API (fire-and-forget) + 상태 초기화 후 홈 이동
        if (gameId != null) ref.read(leaveGameProvider(gameId).future);
        ref.read(gameParticipantNotifierProvider.notifier).clear();
        context.go(RoutePaths.home);
      },
      onConfirm: () {
        // leave API 미호출 (서버에서 방 유지) + 상태 초기화 후 대기실 이동
        ref.read(gameParticipantNotifierProvider.notifier).clear();
        context.go(RoutePaths.waitingRoomWithId(widget.sessionId));
      },
    );
  }

  /// resumed 복귀 시 소켓 재연결 (필요한 경우에만)
  ///
  /// OS가 백그라운드에서 WebSocket을 끊거나, 지수 백오프 5회 소진 후
  /// dead 상태로 방치된 경우를 복구합니다.
  void _reconnectSocketsIfNeeded() {
    if (widget.isDummy) return;

    final chatState = ref.read(chatNotifierProvider).connectionState;
    if (chatState != StompConnectionState.connected &&
        chatState != StompConnectionState.connecting) {
      final team = widget.team.toLowerCase();
      _chatNotifier?.connectAndSubscribe(gameId: _gameId, team: team);
    }

    final gameEventState = ref.read(gameEventNotifierProvider).connectionState;
    if (gameEventState != StompConnectionState.connected &&
        gameEventState != StompConnectionState.connecting) {
      _gameEventNotifier?.connectAndSubscribe(_gameId);
    }

    // 도둑 팀: 위치 전송 스트림이 끊겼으면 재시작
    if (widget.team == 'ROBBER' && _locationSubscription == null) {
      _startLocationSending();
    }

    // 양 팀: heading 스트림이 끊겼으면 재시작 (백그라운드 복귀 시 복구)
    if (_headingSubscription == null) {
      _startHeadingTracking();
    }
  }

  /// resumed 복귀 시 게임 종료 여부 확인
  ///
  /// 백그라운드 중 게임이 끝났을 경우 홈으로 이동,
  /// 대기실로 돌아간 경우 로비로 이동합니다.
  Future<void> _checkGameStatusOnResume() async {
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

      if (!status.isParticipating || info == null) {
        // 게임 종료 → 홈
        debugPrint('[GamePage] 게임 종료 감지 → 홈 이동');
        context.go(RoutePaths.home);
      } else if (info.gameStatus == 'WAITING') {
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

    // 체포 이벤트 감지 → 열려있는 다이얼로그(QR 등) 닫기
    ref.listen(
      gameEventNotifierProvider.select((s) => s.arrestedParticipantIds),
      (prev, next) {
        if (prev == null) return;
        final newlyArrested = next.difference(prev);
        if (newlyArrested.contains(widget.participantId) && mounted) {
          Navigator.of(context).popUntil((route) => route is! PopupRoute);
        }
      },
    );

    // 게임 이벤트 감지 → 게임 종료 다이얼로그
    ref.listen(gameEventNotifierProvider, (prev, next) {
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
              message: GameEventMessages.policeMove,
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
                message: GameEventMessages.locationReveal,
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
          ref
              .read(chatNotifierProvider.notifier)
              .addSystemMessage(
                gameId: _gameId,
                message: GameEventMessages.arrestNotice(
                  policeNick ?? '경찰',
                  robberNick ?? '도둑',
                ),
              );
        }
      },
    );

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
              message: GameEventMessages.escapeNotice,
            );
      }
    });

    final bannerMessage = ref.watch(
      gameEventNotifierProvider.select((s) => s.bannerMessage),
    );

    final isArrestedNow =
        widget.team == 'ROBBER' &&
        ref.watch(
          gameEventNotifierProvider.select(
            (s) =>
                s.arrestedParticipantIds.contains(widget.participantId) &&
                !s.escapedParticipantIds.contains(widget.participantId),
          ),
        );

    // 도둑팀 경찰 시작 카운트다운용 시각 계산
    final policeStartTime = _computePoliceStartTime();

    // 재연결 감지 → 도둑 팀 위치 즉시 재전송 + 재연결 모달 표시/닫기
    ref.listen(gameEventNotifierProvider.select((s) => s.connectionState), (
      prev,
      next,
    ) {
      // 재연결 성공 → 게임 상태 동기화 + 도둑 팀 위치 즉시 재전송
      if (next == StompConnectionState.connected &&
          prev != StompConnectionState.connected) {
        // 끊김 구간 동안 누락된 체포·탈옥 이벤트를 서버 조회로 보정.
        // 의도적으로 await하지 않음 — 아래 도둑 팀 위치 즉시 재전송이
        // HTTP 응답을 기다리다 지연되지 않도록. 에러는 메서드 내부 try-catch에서 처리.
        if (_hasGameEventConnectedOnce) {
          unawaited(_syncGameStateOnReconnect());
        }

        if (widget.team == 'ROBBER' && !widget.isDummy) {
          if (_lastSentPosition != null) {
            _sendPositionNow();
          } else if (_locationSubscription == null) {
            _startLocationSending();
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

    // 게임 맵 영역 로드 완료 시 지도에 원 추가
    ref.listen(gameAreaProvider(_gameId), (prev, next) {
      next.whenData((area) {
        _googleMapKey.currentState?.updateMinZoom(
          area.playgroundRadiusInMeters,
        );
        _googleMapKey.currentState?.updateAreaCircles(
          _buildGoogleCircles(area),
        );
        _googleMapKey.currentState?.updateAreaPolygons(
          _buildOutsideOverlay(area),
        );
      });
    });

    // 위치 권한 미허용 → 다이얼로그가 표시되는 동안 빈 화면
    if (_isLocationPermissionDenied) {
      return Scaffold(
        backgroundColor: _isDarkMode ? AppColors.black800 : AppColors.white,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          /// index 0: 지도 (항상 존재)
          Positioned.fill(
            child: GoogleMapView(
              key: _googleMapKey,
              onCameraMoveStarted: _onMapCameraMoved,
              isDarkMode: _isDarkMode,
              mapId: _isDarkMode ? EnvConfig.googleMapsRobberMapId : null,
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
                  child: PoliceStartCountdown(policeStartTime: policeStartTime),
                ),
              ),
            )
          else
            const SizedBox.shrink(),

          /// index 4: 알림 배너 (if/else로 개수 고정, 카운트다운보다 위에 표시)
          if (!_showParticipants && bannerMessage != null)
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
              bottom: 157.h,
              child: Column(
                children: [
                  SvgIconButton(
                    key: _tutorialKeyMapReturn,
                    assetPath: 'assets/icons/icon_map.svg',
                    onPressed: () => setState(() => _showParticipants = false),
                    containerSize: 48,
                    iconSize: 24,
                    iconColor: _isDarkMode ? AppColors.green : AppColors.blue,
                    backgroundColor: _isDarkMode ? AppColors.black : null,
                  ),
                  SizedBox(height: AppSpacing.vertical8),
                  _buildQrButton(),
                ],
              ),
            )
          else
            Positioned(
              right: 20.w,
              bottom: 157.h,
              child: Column(
                children: [
                  SvgIconButton(
                    key: _tutorialKeyParticipants,
                    assetPath: 'assets/icons/icon_person.svg',
                    onPressed: () {
                      setState(() => _showParticipants = true);
                      _showParticipantsTutorialIfNeeded();
                    },
                    containerSize: 48,
                    iconSize: 24,
                    iconColor: _isDarkMode ? AppColors.green : AppColors.blue,
                    backgroundColor: _isDarkMode ? AppColors.black : null,
                  ),
                  SizedBox(height: AppSpacing.vertical8),
                  MyLocationButton(
                    onPressed: _moveToCurrentLocation,
                    isFocused: _isLocationFocused,
                    containerSize: 48,
                    iconSize: 24,
                    focusedColor: _isDarkMode ? AppColors.green : null,
                    unfocusedColor: _isDarkMode ? AppColors.green500 : null,
                    backgroundColor: _isDarkMode ? AppColors.black : null,
                  ),
                ],
              ),
            ),

          /// index 6: 체포 잠금 오버레이 (if/else로 개수 고정, 도둑팀 체포 시 표시)
          if (isArrestedNow)
            ArrestLockOverlay(
              gameId: _gameId,
              myParticipantId: widget.participantId,
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
              left: 12.w,
              bottom: 157.h,
              child: FloatingActionButton(
                heroTag: 'game_debug',
                mini: true,
                backgroundColor: AppColors.black.withValues(alpha: 0.7),
                foregroundColor: AppColors.white,
                onPressed: widget.isDummy ? null : () => _showDebugMenu(),
                child: const Icon(Icons.bug_report),
              ),
            )
          else
            const SizedBox.shrink(),
        ],
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
      key: _tutorialKeyQrButton,
      assetPath: widget.team == 'POLICE'
          ? 'assets/icons/icon_qr_scan.svg'
          : 'assets/icons/icon_qr_code.svg',
      onPressed: widget.team == 'POLICE' ? _openQrScanner : _showMyQrCode,
      containerSize: 48,
      iconSize: 24,
      iconColor: _isDarkMode ? AppColors.green : AppColors.blue,
      backgroundColor: _isDarkMode ? AppColors.black : null,
    );
  }

  /// 경찰: QR 스캐너를 열어 도둑을 체포
  Future<void> _openQrScanner() async {
    final gameEventState = ref.read(gameEventNotifierProvider);
    final participantInfo = ref.read(gameParticipantNotifierProvider);

    // 경찰 대기 시간 가드
    if (!gameEventState.canPoliceArrest(participantInfo: participantInfo)) {
      AppSnackbar.show(context, message: '경찰 대기 시간 중에는 도둑을 체포할 수 없습니다.');
      return;
    }

    final participantId = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder: (_) => QrScannerPage<int>(
          title: '도둑의 수배 QR을 스캔하세요',
          onParse: (rawValue) {
            try {
              final json = jsonDecode(rawValue) as Map<String, dynamic>;
              final pid = json['pid'];
              if (pid is int) return pid;
              if (pid is num) return pid.toInt();
              return null;
            } catch (_) {
              return null;
            }
          },
        ),
      ),
    );
    if (participantId == null || !mounted) return;

    // 이미 체포된 도둑 체크
    final arrestedIds = ref
        .read(gameEventNotifierProvider)
        .arrestedParticipantIds;
    final escapedIds = ref
        .read(gameEventNotifierProvider)
        .escapedParticipantIds;
    if (arrestedIds.contains(participantId) &&
        !escapedIds.contains(participantId)) {
      AppSnackbar.show(context, message: '이미 체포된 도둑입니다.');
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
    final participantStartTime = participantInfo?.gameStartTime != null
        ? DateTime.tryParse(participantInfo!.gameStartTime!)
        : null;
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
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.horizontal12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 중앙: 타이머 + 서브 타이머
          Column(
            key: _tutorialKeyTimer,
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
          // 우측: info 버튼 (터치 영역 48x48)
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: _showGameRulesDialog,
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: 48.w,
                height: 48.w,
                child: Center(
                  child: SvgPicture.asset(
                    'assets/icons/icon_info.svg',
                    width: 24.w,
                    height: 24.w,
                    colorFilter: ColorFilter.mode(
                      _isDarkMode ? AppColors.black200 : AppColors.black800,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
