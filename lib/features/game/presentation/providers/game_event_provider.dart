import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/utils/iso_timestamp_parser.dart';
import '../../../../core/services/vibration_service.dart';
import '../../../../core/services/lifecycle/app_lifecycle_service.dart';
import '../../../../core/services/background/background_service_provider.dart';
import '../../../../core/services/fcm/firebase_messaging_service.dart';
import '../../../../core/constants/game_event_messages.dart';
import '../../../../core/network/dio_client.dart';
import '../../../auth/presentation/providers/token_provider.dart';
import '../../data/datasources/game_event_stomp_datasource.dart';
import '../../data/datasources/game_system_api_datasource.dart';
import '../../data/models/arrest_request_model.dart';
import '../../data/models/game_area_model.dart';
import '../../data/models/game_event_model.dart';
import '../../../session/presentation/providers/game_participant_provider.dart';

export '../../data/datasources/game_event_stomp_datasource.dart'
    show StompConnectionState;

part 'game_event_provider.g.dart';

/// copyWith에서 "값을 전달하지 않음"과 "명시적 null"을 구분하기 위한 sentinel 객체
const _sentinel = Object();

/// GameEventStompDatasource Provider (싱글톤)
@riverpod
GameEventStompDatasource gameEventStompDatasource(Ref ref) {
  final datasource = GameEventStompDatasource();
  ref.onDispose(() => datasource.dispose());
  return datasource;
}

/// GameSystemApi Provider
@riverpod
GameSystemApi gameSystemApi(Ref ref) {
  final dio = ref.watch(dioProvider);
  return GameSystemApi(dio);
}

/// 게임 이벤트 상태
class GameEventState {
  /// STOMP 연결 상태
  final StompConnectionState connectionState;

  /// 에러 메시지
  final String? errorMessage;

  /// 체포된 참가자 ID 집합 (ARREST 이벤트 누적)
  final Set<int> arrestedParticipantIds;

  /// 탈옥한 참가자 ID 집합 (ESCAPE 이벤트 누적)
  final Set<int> escapedParticipantIds;

  /// 경찰 이동 시작 여부 (POLICE_MOVE_START 이후 true)
  final bool isPoliceMoving;

  /// 마지막 ARREST 기준 남은 도둑 수
  final int? remainingThieves;

  /// 가장 최근 체포된 도둑 닉네임 (ARREST 이벤트 다이얼로그용)
  final String? lastArrestNickname;

  /// 가장 최근 체포한 경찰 닉네임 (ARREST 이벤트 공지용)
  final String? lastArrestPoliceNickname;

  /// STOMP 확정 체포 이벤트 카운터 (시스템 채팅 dedup용, optimistic 미포함)
  final int arrestEventCount;

  /// STOMP 확정 탈옥 이벤트 카운터 (시스템 채팅 dedup용, optimistic 미포함)
  final int escapeEventCount;

  /// 가장 최근 탈옥한 도둑 닉네임 (ESCAPE 이벤트 다이얼로그용, 복수 탈옥 시 첫 번째)
  final String? lastEscapeNickname;

  /// 게임 종료 여부
  final bool isGameOver;

  /// 승리 팀 ("POLICE" | "ROBBER")
  final String? winnerTeam;

  /// 게임 종료 이유 ("TIME_OVER" | "ALL_ARRESTED")
  final String? gameOverReason;

  /// 게임 결과 ID
  final int? gameResultId;

  /// 게임 시작 시각 (START 이벤트 수신 시 설정, AppBar 타이머용)
  final DateTime? gameStartTime;

  /// 경찰 이동 시작 시각 (POLICE_MOVE_START 이벤트 timestamp 기준)
  final DateTime? policeMoveStartTime;

  /// 마지막 도둑 위치 공개 시각 (LOCATION_REVEAL 이벤트 수신 시 설정)
  final DateTime? lastLocationRevealTime;

  /// 배너 메시지 (null이면 숨김, 5초 후 자동 해제)
  final String? bannerMessage;

  /// arrest/escape API 호출 중 여부
  final bool isApiLoading;

  /// LOCATION_REVEAL 수신 시 갱신되는 도둑 위치 목록 (participantId → 위치)
  final Map<int, LatLngModel> robberLocations;

  /// 경찰이 현재 체포 가능한 상태인지 판단
  ///
  /// STOMP `POLICE_MOVE_START` 수신 여부, 게임 시작 시각 + 경찰 대기 시간 비교,
  /// 대기 시간 0분인 경우를 종합적으로 판단한다.
  bool canPoliceArrest({required GameParticipantInfo? participantInfo}) {
    if (isPoliceMoving) return true;
    final policeWaitMinutes = participantInfo?.policeWaitMinutes;
    if (policeWaitMinutes == 0) return true;

    final gameStartTimeStr = participantInfo?.gameStartTime;
    final effectiveStartTime =
        gameStartTime ?? IsoTimestampParser.parse(gameStartTimeStr);

    return policeWaitMinutes != null &&
        effectiveStartTime != null &&
        !DateTime.now().isBefore(
          effectiveStartTime.add(Duration(minutes: policeWaitMinutes)),
        );
  }

  const GameEventState({
    this.connectionState = StompConnectionState.disconnected,
    this.errorMessage,
    this.arrestedParticipantIds = const {},
    this.escapedParticipantIds = const {},
    this.isPoliceMoving = false,
    this.remainingThieves,
    this.lastArrestNickname,
    this.lastArrestPoliceNickname,
    this.arrestEventCount = 0,
    this.escapeEventCount = 0,
    this.lastEscapeNickname,
    this.isGameOver = false,
    this.winnerTeam,
    this.gameOverReason,
    this.gameResultId,
    this.gameStartTime,
    this.policeMoveStartTime,
    this.lastLocationRevealTime,
    this.bannerMessage,
    this.isApiLoading = false,
    this.robberLocations = const {},
  });

  GameEventState copyWith({
    StompConnectionState? connectionState,
    Object? errorMessage = _sentinel,
    Set<int>? arrestedParticipantIds,
    Set<int>? escapedParticipantIds,
    bool? isPoliceMoving,
    Object? remainingThieves = _sentinel,
    Object? lastArrestNickname = _sentinel,
    Object? lastArrestPoliceNickname = _sentinel,
    int? arrestEventCount,
    int? escapeEventCount,
    Object? lastEscapeNickname = _sentinel,
    bool? isGameOver,
    Object? winnerTeam = _sentinel,
    Object? gameOverReason = _sentinel,
    Object? gameResultId = _sentinel,
    Object? gameStartTime = _sentinel,
    Object? policeMoveStartTime = _sentinel,
    Object? lastLocationRevealTime = _sentinel,
    Object? bannerMessage = _sentinel,
    bool? isApiLoading,
    Map<int, LatLngModel>? robberLocations,
  }) {
    return GameEventState(
      connectionState: connectionState ?? this.connectionState,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
      arrestedParticipantIds:
          arrestedParticipantIds ?? this.arrestedParticipantIds,
      escapedParticipantIds:
          escapedParticipantIds ?? this.escapedParticipantIds,
      isPoliceMoving: isPoliceMoving ?? this.isPoliceMoving,
      remainingThieves: remainingThieves == _sentinel
          ? this.remainingThieves
          : remainingThieves as int?,
      lastArrestNickname: lastArrestNickname == _sentinel
          ? this.lastArrestNickname
          : lastArrestNickname as String?,
      lastArrestPoliceNickname: lastArrestPoliceNickname == _sentinel
          ? this.lastArrestPoliceNickname
          : lastArrestPoliceNickname as String?,
      arrestEventCount: arrestEventCount ?? this.arrestEventCount,
      escapeEventCount: escapeEventCount ?? this.escapeEventCount,
      lastEscapeNickname: lastEscapeNickname == _sentinel
          ? this.lastEscapeNickname
          : lastEscapeNickname as String?,
      isGameOver: isGameOver ?? this.isGameOver,
      winnerTeam: winnerTeam == _sentinel
          ? this.winnerTeam
          : winnerTeam as String?,
      gameOverReason: gameOverReason == _sentinel
          ? this.gameOverReason
          : gameOverReason as String?,
      gameResultId: gameResultId == _sentinel
          ? this.gameResultId
          : gameResultId as int?,
      gameStartTime: gameStartTime == _sentinel
          ? this.gameStartTime
          : gameStartTime as DateTime?,
      policeMoveStartTime: policeMoveStartTime == _sentinel
          ? this.policeMoveStartTime
          : policeMoveStartTime as DateTime?,
      lastLocationRevealTime: lastLocationRevealTime == _sentinel
          ? this.lastLocationRevealTime
          : lastLocationRevealTime as DateTime?,
      bannerMessage: bannerMessage == _sentinel
          ? this.bannerMessage
          : bannerMessage as String?,
      isApiLoading: isApiLoading ?? this.isApiLoading,
      robberLocations: robberLocations ?? this.robberLocations,
    );
  }
}

/// 게임 이벤트 상태 관리 Notifier
///
/// STOMP 연결/구독/이벤트 처리 및 체포·탈옥 API 호출을 관리합니다.
/// GamePage 진입 시 [connectAndSubscribe]를 호출합니다.
@riverpod
class GameEventNotifier extends _$GameEventNotifier {
  StreamSubscription<GameEventModel>? _eventSub;
  StreamSubscription<StompConnectionState>? _connectionSub;
  StreamSubscription<StompErrorInfo>? _errorSub;
  StreamSubscription<String>? _fcmEventSub;

  int _authRetryCount = 0;
  static const _maxAuthRetries = 1;

  int _reconnectCount = 0;
  static const _maxReconnectRetries = 5;

  /// 현재 API 호출 중인 체포 대상 ID (race condition 방어)
  int? _pendingArrestId;

  Timer? _reconnectTimer;
  Timer? _locationRevealBannerTimer;
  bool _intentionalDisconnect = false;
  bool _isHandlingError = false;
  bool _isDisposed = false;
  bool _isManualReconnecting = false; // 수동 재연결 중복 호출 방지
  int? _gameId;

  @override
  GameEventState build() {
    ref.watch(gameEventStompDatasourceProvider);

    // FCM 게임 시스템 이벤트(BE PR #84) 수신 시 STOMP 좀비 연결 자동 복구.
    // 백오프 5회 소진 후 사용자가 재연결 모달을 방치한 케이스를
    // FCM 도착 신호(=네트워크 살아있음)로 자동 복구한다.
    _fcmEventSub = FirebaseMessagingService.gameSystemEventStream.listen(
      _handleFcmGameEvent,
    );

    ref.onDispose(() {
      _isDisposed = true;
      _eventSub?.cancel();
      _connectionSub?.cancel();
      _errorSub?.cancel();
      _fcmEventSub?.cancel();
      _reconnectTimer?.cancel();
      _locationRevealBannerTimer?.cancel();
    });
    return const GameEventState();
  }

  /// FCM 게임 시스템 이벤트 도착 → STOMP 좀비 연결 자동 복구
  ///
  /// FCM이 도착했다는 것은 디바이스 푸시 채널이 살아있다 = 네트워크가 살아있다는
  /// 신호다. 같은 시점에 STOMP가 dead 상태(`error`/`disconnected`)라면
  /// `manualReconnect()`로 자동 복구한다. `connecting`/`connected` 상태이면
  /// 정상 동작 중이므로 흔들지 않는다.
  ///
  /// `manualReconnect()` 내부의 토큰 조회/재연결에서 예외가 던져질 수 있으므로
  /// await + try-catch로 unhandled async error를 차단한다. 자동 복구 경로라
  /// state는 흔들지 않고 로그만 남긴다(STOMP는 이미 error/disconnected 상태).
  Future<void> _handleFcmGameEvent(String eventType) async {
    if (_isDisposed || _intentionalDisconnect || _gameId == null) return;

    final connState = state.connectionState;
    if (connState != StompConnectionState.error &&
        connState != StompConnectionState.disconnected) {
      return;
    }

    debugPrint(
      '[GameEventNotifier] 📨 FCM($eventType) 수신 + STOMP $connState '
      '→ 자동 재연결 시도',
    );
    try {
      await manualReconnect();
    } catch (e, stack) {
      debugPrint('[GameEventNotifier] ❌ FCM 트리거 자동 재연결 실패: $e');
      debugPrint('$stack');
    }
  }

  /// STOMP 연결 후 게임 이벤트 구독
  ///
  /// [gameId] 게임 ID
  Future<void> connectAndSubscribe(int gameId) async {
    final datasource = ref.read(gameEventStompDatasourceProvider);

    if (datasource.currentState == StompConnectionState.connecting ||
        datasource.currentState == StompConnectionState.connected) {
      return;
    }

    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _gameId = gameId;
    _intentionalDisconnect = false;
    _isHandlingError = false;
    _reconnectCount = 0;
    _authRetryCount = 0;

    final tokenProvider = ref.read(tokenProviderProvider);
    final accessToken = await tokenProvider.getAccessToken();
    if (accessToken == null) {
      debugPrint('[GameEventNotifier] ❌ 토큰 획득 실패');
      state = state.copyWith(
        connectionState: StompConnectionState.error,
        errorMessage: '인증 토큰을 가져올 수 없습니다. 재로그인이 필요합니다.',
      );
      return;
    }

    _setupStreams();
    datasource.subscribeEvents(gameId);

    final wsUrl = ApiEndpoints.gameConnectionUrl;
    debugPrint('[GameEventNotifier] 🔗 STOMP 연결 시도: $wsUrl (gameId: $gameId)');
    datasource.connect(wsUrl, accessToken);
  }

  /// 수동 재연결 — 재시도 카운터를 초기화하고 즉시 연결 시도
  ///
  /// 사용자가 재연결 버튼을 탭했을 때 호출합니다.
  /// 기존 자동 재연결 백오프와 달리 딜레이 없이 즉시 시도합니다.
  Future<void> manualReconnect() async {
    // UI의 isConnecting 비활성화 외에 메서드 레벨에서도 중복 호출 차단
    if (_isManualReconnecting || _gameId == null) return;
    _isManualReconnecting = true;
    try {
      _reconnectCount = 0; // 재시도 카운터 초기화 → 이후 자동 재연결 5회 재활성화
      _intentionalDisconnect = false;
      _isHandlingError = false;
      _reconnectTimer?.cancel();
      _reconnectTimer = null;
      await _attemptReconnect();
    } finally {
      _isManualReconnecting = false;
    }
  }

  /// 의도적 연결 해제
  ///
  /// STOMP 구독과 내부 타이머만 정리하고 시각 상태
  /// ([arrestedParticipantIds]·[escapedParticipantIds]·[robberLocations] 등)는
  /// 보존한다. 게임 종료 시퀀스에서 참가자 목록 오버레이가 마지막 체포 스냅샷을
  /// 그대로 유지하도록 하기 위함.
  ///
  /// 전체 상태 초기화는 provider autoDispose 에 맡긴다 (페이지 dispose 시 자동 정리).
  void disconnect() {
    _deactivateBackgroundInfrastructure();
    _intentionalDisconnect = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _locationRevealBannerTimer?.cancel();
    _locationRevealBannerTimer = null;
    _eventSub?.cancel();
    _connectionSub?.cancel();
    _errorSub?.cancel();
    _eventSub = null;
    _connectionSub = null;
    _errorSub = null;
    _authRetryCount = 0;
    _reconnectCount = 0;
    _isHandlingError = false;
    _gameId = null;

    ref.read(gameEventStompDatasourceProvider).disconnect();
    state = state.copyWith(
      connectionState: StompConnectionState.disconnected,
      errorMessage: null,
    );
  }

  /// 도둑 체포 API 호출 (경찰 전용)
  ///
  /// STOMP ARREST 이벤트 도착 전 낙관적으로 [arrestedParticipantIds]에 즉시 추가.
  /// API 실패 시 rollback.
  Future<void> arrestRobber(int gameId, int robberParticipantId) async {
    // 재진입 방어: 이전 체포 요청 처리 중이면 무시
    if (_pendingArrestId != null) {
      debugPrint(
        '[GameEventNotifier] ⚠️ 체포 요청 무시 — '
        '이미 $_pendingArrestId 처리 중',
      );
      return;
    }

    // race condition 방어: API 호출 중인 체포 대상 추적
    _pendingArrestId = robberParticipantId;

    // 낙관적 업데이트: STOMP 이벤트 도착 전 즉시 UI 반영
    state = state.copyWith(
      arrestedParticipantIds: {
        ...state.arrestedParticipantIds,
        robberParticipantId,
      },
      isApiLoading: true,
    );
    try {
      await ref
          .read(gameSystemApiProvider)
          .arrest(
            gameId,
            ArrestRequestModel(robberParticipantId: robberParticipantId),
          );
      // API 성공 → 로딩 해제 (STOMP 이벤트에서 최종 상태 확정)
      _pendingArrestId = null;
      state = state.copyWith(isApiLoading: false);
    } catch (e) {
      debugPrint('[GameEventNotifier] ❌ 체포 요청 실패: $e');
      if (_pendingArrestId == null) {
        // STOMP ARREST 이벤트가 이미 도착하여 체포 확정 → rollback 하지 않음
        debugPrint('[GameEventNotifier] ℹ️ STOMP에서 이미 체포 확정됨 → rollback 생략');
        state = state.copyWith(isApiLoading: false);
      } else {
        // STOMP 확인 없음 → 낙관적 업데이트 rollback
        _pendingArrestId = null;
        state = state.copyWith(
          arrestedParticipantIds: state.arrestedParticipantIds.difference({
            robberParticipantId,
          }),
          isApiLoading: false,
          errorMessage: '체포 요청 실패',
        );
      }
    }
  }

  /// 탈옥 API 호출 (수감된 도둑 전용)
  ///
  /// STOMP ESCAPE 이벤트 도착 전 낙관적으로 [escapedParticipantIds]에 즉시 추가하고,
  /// 동시에 [arrestedParticipantIds]에서는 제거하여 두 집합을 상호 배타적으로 유지한다
  /// (STOMP `_handleEscape` 와 동일한 패턴). 같은 ID가 두 집합에 동시에 남아 있으면
  /// `_effectiveRobberStatus` 우선순위(isEscaped > isArrested)로 인해 다른 참가자 화면에서
  /// jailed SVG 가 잠깐 ALIVE 로 잘못 표시된다.
  ///
  /// API 실패 시 rollback (수감 상태 복원).
  Future<void> escape(int gameId, int myParticipantId) async {
    // 낙관적 업데이트: STOMP 이벤트 도착 전 즉시 UI 반영
    state = state.copyWith(
      arrestedParticipantIds: state.arrestedParticipantIds.difference({
        myParticipantId,
      }),
      escapedParticipantIds: {...state.escapedParticipantIds, myParticipantId},
      isApiLoading: true,
    );
    try {
      await ref.read(gameSystemApiProvider).escape(gameId);
      // API 성공 → 로딩 해제 (STOMP 이벤트에서 최종 상태 확정)
      state = state.copyWith(isApiLoading: false);
    } catch (e) {
      debugPrint('[GameEventNotifier] ❌ 탈옥 요청 실패: $e');
      // 낙관적 업데이트 rollback: 수감 상태 복원
      state = state.copyWith(
        arrestedParticipantIds: {
          ...state.arrestedParticipantIds,
          myParticipantId,
        },
        escapedParticipantIds: state.escapedParticipantIds.difference({
          myParticipantId,
        }),
        isApiLoading: false,
        errorMessage: '탈옥 요청 실패',
      );
    }
  }

  /// [DEBUG 전용] 자동 재연결 횟수 소진 상태 강제 시뮬레이션
  ///
  /// 실기기에서 화면을 끈 채로 재연결 5회 실패하는 상황을 재현합니다.
  /// 수동 재연결 버튼 및 장시간 모달 유지 흐름을 테스트할 때 사용합니다.
  ///
  /// broadcast stream은 add() 호출 시 동기 전달되므로, disconnect()가 유발하는
  /// disconnected 이벤트가 stream listener를 통해 state를 덮어쓰기 전에
  /// _intentionalDisconnect로 _scheduleReconnect를 막고, 이후 마이크로태스크에서
  /// error 상태로 최종 설정합니다.
  Future<void> debugForceReconnectExhausted() async {
    assert(kDebugMode, 'debugForceReconnectExhausted는 debug 빌드 전용입니다');
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _reconnectCount = _maxReconnectRetries + 1; // 자동 재연결 차단
    _deactivateBackgroundInfrastructure();
    _intentionalDisconnect = true; // 스트림 콜백의 _scheduleReconnect 호출 억제
    ref.read(gameEventStompDatasourceProvider).disconnect();
    // disconnect() → stream listener → state = disconnected (동기) 이후
    // 마이크로태스크에서 error로 덮어씌워 최종 상태를 error로 확정
    await Future.microtask(() {
      if (_isDisposed) return;
      state = state.copyWith(
        connectionState: StompConnectionState.error,
        errorMessage: '서버에 연결할 수 없습니다. 잠시 후 다시 시도해주세요.',
      );
      _intentionalDisconnect = false; // 수동 재연결(manualReconnect)은 허용
    });
  }

  /// WebSocket 재연결 후 서버 참가자 상태로 게임 상태를 동기화
  ///
  /// STOMP는 끊김 구간의 이벤트를 재전송하지 않으므로, 재연결 시
  /// GET /api/games/{gameId}/participants 응답으로 누락된 체포·탈옥 상태를 보정합니다.
  ///
  /// [arrestedIds] - 서버 응답 기준 현재 수감 중인 도둑 participantId 집합
  /// [remainingThieves] - 서버 응답 기준 현재 생존(ALIVE) 도둑 수
  void syncFromParticipants({
    required Set<int> arrestedIds,
    required int remainingThieves,
  }) {
    if (_isDisposed) return;

    debugPrint(
      '[GameEventNotifier] 🔄 재연결 후 상태 동기화 — '
      '수감: $arrestedIds, 남은 도둑: $remainingThieves',
    );

    // 서버가 진실의 원천. 끊김 구간에 탈옥→재체포가 발생해도
    // 서버의 JAILED 목록을 그대로 반영하고, escaped 집합은 현재 수감자와 겹치지 않게 정리한다.
    state = state.copyWith(
      arrestedParticipantIds: arrestedIds,
      escapedParticipantIds: state.escapedParticipantIds.difference(
        arrestedIds,
      ),
      remainingThieves: remainingThieves,
    );
  }

  /// 외부에서 배너 메시지를 설정 (게임 시작 시퀀스 등 STOMP 외 이벤트용)
  void setBannerMessage(String message) {
    state = state.copyWith(bannerMessage: message);
    _startBannerTimer();
  }

  /// 배너를 5초 후 자동 해제하는 타이머 시작
  void _startBannerTimer() {
    _locationRevealBannerTimer?.cancel();
    // 배너 위젯의 displayDuration(8초) + fadeOutDuration(800ms) 이후 제거
    _locationRevealBannerTimer = Timer(const Duration(milliseconds: 8800), () {
      if (!_isDisposed) state = state.copyWith(bannerMessage: null);
    });
  }

  // ============================================================
  // 이벤트 처리
  // ============================================================

  void _handleEvent(GameEventModel event) {
    switch (event.type) {
      case GameEventType.arrest:
        _handleArrest(event.data);
      case GameEventType.escape:
        _handleEscape(event.data);
      case GameEventType.gameOver:
        _handleGameOver(event.data);
      case GameEventType.start:
        _handleStart(event.data);
      case GameEventType.policeMoveStart:
        final moveStartTime =
            IsoTimestampParser.parse(event.timestamp) ?? DateTime.now();
        state = state.copyWith(
          isPoliceMoving: true,
          policeMoveStartTime: moveStartTime,
          bannerMessage: GameEventMessages.policeMove,
        );
        _startBannerTimer();
      case GameEventType.locationReveal:
      case GameEventType.robberLocationReveal:
        _handleLocationReveal(event.data, event.timestamp);
      default:
        debugPrint('[GameEventNotifier] ⚠️ 알 수 없는 이벤트: ${event.type}');
    }
  }

  void _handleStart(Map<String, dynamic> data) {
    final startTimeStr = data['startTime'] as String?;
    final startTime = IsoTimestampParser.parse(startTimeStr);
    state = state.copyWith(
      gameStartTime: startTime ?? DateTime.now(),
      bannerMessage: GameEventMessages.gameStartGo,
    );
    _startBannerTimer();
    debugPrint(
      '[GameEventNotifier] ✅ START 이벤트 → 게임 시작 시각: ${state.gameStartTime}',
    );
    // 백그라운드 위치 추적/STOMP 유지 인프라 활성화
    _activateBackgroundInfrastructure();
  }

  /// 백그라운드 인프라 활성화 (Service start + keep-alive timer ON)
  ///
  /// 멱등: 이미 활성화되어 있으면 no-op (재진입 가드와 함께 호출 가능).
  void _activateBackgroundInfrastructure() {
    final gameId = _gameId;
    if (gameId == null) {
      debugPrint('[GameEventNotifier] ⚠️ gameId 없음 - background 활성화 스킵');
      return;
    }
    final service = ref.read(backgroundServiceProvider);
    service.start(gameId: gameId);
    AppLifecycleService.instance().enableKeepAlive();
    debugPrint('[GameEventNotifier] ✅ 백그라운드 인프라 ON');
  }

  /// 백그라운드 인프라 비활성화 (Service stop + keep-alive timer OFF)
  void _deactivateBackgroundInfrastructure() {
    final service = ref.read(backgroundServiceProvider);
    service.stop();
    AppLifecycleService.instance().disableKeepAlive();
    debugPrint('[GameEventNotifier] ✅ 백그라운드 인프라 OFF');
  }

  void _handleLocationReveal(Map<String, dynamic> data, String timestamp) {
    final locationsList = (data['locations'] as List<dynamic>?) ?? [];
    Map<int, LatLngModel>? newLocations;
    if (locationsList.isNotEmpty) {
      final entries = <int, LatLngModel>{};
      for (final loc in locationsList) {
        final pid = (loc['participantId'] as num?)?.toInt();
        final lat = (loc['latitude'] as num?)?.toDouble();
        final lng = (loc['longitude'] as num?)?.toDouble();
        if (pid != null && lat != null && lng != null) {
          entries[pid] = LatLngModel(latitude: lat, longitude: lng);
        }
      }
      if (entries.isNotEmpty) {
        newLocations = entries;
      }
    }

    final revealTime = IsoTimestampParser.parse(timestamp) ?? DateTime.now();
    state = state.copyWith(
      lastLocationRevealTime: revealTime,
      bannerMessage: GameEventMessages.locationReveal,
      robberLocations: newLocations ?? state.robberLocations,
    );
    _startBannerTimer();
    VibrationService.instance().locationRevealed();
    debugPrint(
      '[GameEventNotifier] ✅ LOCATION_REVEAL 이벤트 수신 '
      '(도둑 ${newLocations?.length ?? 0}명)',
    );
  }

  void _handleArrest(Map<String, dynamic> data) {
    final robber = data['robber'] as Map<String, dynamic>?;
    final robberPid = (robber?['participantId'] as num?)?.toInt();
    final robberNickname = robber?['nickname'] as String?;
    final remaining = (data['remainingThieves'] as num?)?.toInt();
    if (robberPid == null) return;

    // 경찰 정보 파싱
    final police = data['police'] as Map<String, dynamic>?;
    final policeNickname = police?['nickname'] as String?;

    // race condition 방어: STOMP가 API 응답보다 먼저 도착한 경우 pending 해제
    if (robberPid == _pendingArrestId) {
      _pendingArrestId = null;
    }

    state = state.copyWith(
      arrestedParticipantIds: {...state.arrestedParticipantIds, robberPid},
      escapedParticipantIds: state.escapedParticipantIds.difference({
        robberPid,
      }),
      remainingThieves: remaining,
      lastArrestNickname: robberNickname,
      lastArrestPoliceNickname: policeNickname,
      // 닉네임이 있을 때만 카운터 증가 (시스템 채팅 dedup용)
      arrestEventCount: (robberNickname != null && policeNickname != null)
          ? state.arrestEventCount + 1
          : state.arrestEventCount,
      isApiLoading: false,
      // 배너는 plain Text이므로 아이콘 마커를 strip
      bannerMessage: GameEventMessages.arrestNotice(
        policeNickname ?? '경찰',
        robberNickname ?? '도둑',
      ).replaceAll(RegExp(r'@icon_(police|robber)\s*'), ''),
    );
    _startBannerTimer();
    VibrationService.instance().arrested();
    debugPrint(
      '[GameEventNotifier] ✅ ARREST 이벤트 → robberPid: $robberPid, 남은: $remaining',
    );
  }

  void _handleEscape(Map<String, dynamic> data) {
    final escapedThief = data['escapedThief'] as Map<String, dynamic>?;
    if (escapedThief == null) return;
    final escapedId = (escapedThief['participantId'] as num?)?.toInt();
    if (escapedId == null) return;
    final firstNickname = escapedThief['nickname'] as String?;

    state = state.copyWith(
      arrestedParticipantIds: state.arrestedParticipantIds.difference({
        escapedId,
      }),
      escapedParticipantIds: {...state.escapedParticipantIds, escapedId},
      lastEscapeNickname: firstNickname,
      escapeEventCount: state.escapeEventCount + 1,
      isApiLoading: false,
      bannerMessage: GameEventMessages.escapeNotice,
    );
    _startBannerTimer();
    VibrationService.instance().escaped();
    debugPrint('[GameEventNotifier] ✅ ESCAPE 이벤트 → escaped: $escapedId');
  }

  void _handleGameOver(Map<String, dynamic> data) {
    state = state.copyWith(
      isGameOver: true,
      winnerTeam: data['winnerTeam'] as String?,
      gameOverReason: data['reason'] as String?,
      gameResultId: (data['gameResultId'] as num?)?.toInt(),
    );
    VibrationService.instance().gameEnd();
    debugPrint(
      '[GameEventNotifier] ✅ GAME_OVER 이벤트 → winner: ${state.winnerTeam}',
    );
    // 게임 종료 시점에 백그라운드 인프라 정리
    _deactivateBackgroundInfrastructure();
  }

  // ============================================================
  // 스트림 설정 및 재연결 정책
  // ============================================================

  void _setupStreams() {
    final datasource = ref.read(gameEventStompDatasourceProvider);

    _eventSub?.cancel();
    _connectionSub?.cancel();
    _errorSub?.cancel();

    _connectionSub = datasource.onConnectionState.listen((connState) {
      state = state.copyWith(connectionState: connState);

      if (connState == StompConnectionState.connected) {
        _authRetryCount = 0;
        _reconnectCount = 0;
        _isHandlingError = false;
        _reconnectTimer?.cancel();
        _reconnectTimer = null;
        state = state.copyWith(errorMessage: null);
        // STOMP 유실 구간에서 놓친 LOCATION_REVEAL 복구.
        // 실제 호출 여부 판단(경찰 대기 중 skip 등)은 메서드 내부 가드에서 수행.
        if (_gameId != null) _fetchLastRobberLocations(_gameId!);
      } else if (connState == StompConnectionState.disconnected) {
        if (!_intentionalDisconnect && !_isHandlingError) {
          _scheduleReconnect();
        }
      }
    });

    _eventSub = datasource.onEvent.listen(_handleEvent);

    _errorSub = datasource.onError.listen((errorInfo) {
      _isHandlingError = true;
      _handleStompError(errorInfo);
    });
  }

  /// 마지막으로 공개된 도둑 위치를 조회하여 발자국 복구
  ///
  /// STOMP 연결 유실(네트워크 끊김, 앱 백그라운드/종료 후 재진입) 구간에서
  /// 놓친 LOCATION_REVEAL 이벤트를 서버 조회로 보정한다.
  ///
  /// 가드: 경찰 이동 시작 시각(= `gameStartTime + policeWaitMinutes`) 이전에는
  /// reveal이 발생할 수 없으므로 호출 자체를 skip한다. 그 이전에 호출하면
  /// 서버가 이전 게임 잔존/스테일 데이터를 반환해도 초기 UI에 노출될 위험이 있다.
  /// `participantInfo`는 `game_page.dart`에서 STOMP 연결 전에 로드되도록 보장한다.
  ///
  /// 빈 배열이면 상태 변경 없이 무시. await 중 dispose되거나 새 LOCATION_REVEAL이
  /// 도착한 경우 덮어쓰지 않음.
  Future<void> _fetchLastRobberLocations(int gameId) async {
    // 경찰 이동 시작 전에는 reveal 발생 불가 → API 호출 자체를 skip.
    final participantInfo = ref.read(gameParticipantNotifierProvider);
    final gameStartTimeStr = participantInfo?.gameStartTime;
    final policeWaitMinutes = participantInfo?.policeWaitMinutes;
    if (gameStartTimeStr == null || policeWaitMinutes == null) {
      debugPrint('[GameEventNotifier] ⏭️ 발자국 복구 skip (게임 설정 미로드)');
      return;
    }
    final startTime = IsoTimestampParser.parse(gameStartTimeStr);
    if (startTime == null) {
      debugPrint('[GameEventNotifier] ⏭️ 발자국 복구 skip (startTime 파싱 실패)');
      return;
    }
    final policeMoveTime = startTime.add(Duration(minutes: policeWaitMinutes));
    if (DateTime.now().isBefore(policeMoveTime)) {
      debugPrint('[GameEventNotifier] ⏭️ 발자국 복구 skip (경찰 대기 중)');
      return;
    }

    // fetch 시작 시점의 reveal 타임스탬프 캡처 (race condition 방지)
    final preRevealTime = state.lastLocationRevealTime;
    try {
      final locations = await ref
          .read(gameSystemApiProvider)
          .getRobberLastLocations(gameId);

      // dispose 후 state 접근 방지
      if (_isDisposed) return;
      if (locations.isEmpty) return;

      // await 중 새 LOCATION_REVEAL 이벤트가 도착했으면 fetch 결과를 무시
      if (state.lastLocationRevealTime != preRevealTime) {
        debugPrint(
          '[GameEventNotifier] ⏭️ 도둑 위치 복구 생략 (새 LOCATION_REVEAL 수신됨)',
        );
        return;
      }

      final entries = {
        for (final loc in locations)
          loc.participantId: LatLngModel(
            latitude: loc.latitude,
            longitude: loc.longitude,
          ),
      };
      state = state.copyWith(robberLocations: entries);
      debugPrint('[GameEventNotifier] 📍 재연결 후 도둑 위치 복구: ${entries.length}명');
    } catch (e) {
      // 위치 복구 실패는 치명적이지 않으므로 조용히 처리
      debugPrint('[GameEventNotifier] ⚠️ 마지막 위치 조회 실패: $e');
    }
  }

  void _scheduleReconnect() {
    if (_intentionalDisconnect || _gameId == null) return;

    _reconnectCount++;
    if (_reconnectCount > _maxReconnectRetries) {
      debugPrint('[GameEventNotifier] ❌ 최대 재연결 횟수 초과 ($_maxReconnectRetries)');
      state = state.copyWith(
        connectionState: StompConnectionState.error,
        errorMessage: '서버에 연결할 수 없습니다. 잠시 후 다시 시도해주세요.',
      );
      return;
    }

    final delaySeconds = _calculateBackoffDelay(_reconnectCount);
    debugPrint(
      '[GameEventNotifier] 🔄 재연결 예약: $delaySeconds초 후 '
      '($_reconnectCount/$_maxReconnectRetries)',
    );

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: delaySeconds), _attemptReconnect);
  }

  /// 재연결 백오프 지연 (초)
  ///
  /// 라이프사이클 인지 정책:
  /// - 백그라운드: 0s → 1s → 2s → 5s → 5s (총 13초 내 재연결 시도)
  ///   iOS background wake 시간이 짧을 수 있어 첫 시도를 즉시 진행
  /// - 포그라운드: 1s → 2s → 4s → 8s → 10s (기존)
  int _calculateBackoffDelay(int attempt) {
    final isBackground = AppLifecycleService.instance().isInBackground;

    if (isBackground) {
      // attempt 1=0s, 2=1s, 3=2s, 4=5s, 5+=5s
      const backgroundDelays = [0, 1, 2, 5, 5];
      final index = (attempt - 1).clamp(0, backgroundDelays.length - 1);
      return backgroundDelays[index];
    }

    // 포그라운드: 기존 지수 백오프 (1, 2, 4, 8, 10 clamp)
    final delay = 1 << (attempt - 1);
    return delay.clamp(1, 10);
  }

  Future<void> _attemptReconnect() async {
    if (_intentionalDisconnect || _gameId == null) return;

    final datasource = ref.read(gameEventStompDatasourceProvider);
    if (datasource.currentState == StompConnectionState.connecting ||
        datasource.currentState == StompConnectionState.connected) {
      return;
    }

    debugPrint(
      '[GameEventNotifier] 🔄 재연결 시도 ($_reconnectCount/$_maxReconnectRetries)',
    );

    final tokenProvider = ref.read(tokenProviderProvider);
    final accessToken = await tokenProvider.getAccessToken();

    if (_intentionalDisconnect || _gameId == null) return;

    if (accessToken == null) {
      _scheduleReconnect();
      return;
    }

    datasource.subscribeEvents(_gameId!);
    datasource.connect(ApiEndpoints.gameConnectionUrl, accessToken);
  }

  Future<void> _handleStompError(StompErrorInfo errorInfo) async {
    if (errorInfo.isAuthExpired) {
      _authRetryCount++;

      if (_authRetryCount > _maxAuthRetries) {
        debugPrint('[GameEventNotifier] ❌ 인증 만료 - 최대 재시도 횟수 초과');
        state = state.copyWith(
          connectionState: StompConnectionState.error,
          errorMessage: '인증이 만료되었습니다. 재로그인이 필요합니다.',
        );
        return;
      }

      final tokenProvider = ref.read(tokenProviderProvider);
      final datasource = ref.read(gameEventStompDatasourceProvider);
      final newToken = await tokenProvider.refreshAccessTokenIfNeeded();

      if (_intentionalDisconnect || _gameId == null) return;

      if (newToken == null) {
        state = state.copyWith(
          connectionState: StompConnectionState.error,
          errorMessage: '인증이 만료되었습니다. 재로그인이 필요합니다.',
        );
        return;
      }

      debugPrint('[GameEventNotifier] ✅ 토큰 갱신 성공 - 재연결 시도');
      datasource.subscribeEvents(_gameId!);
      datasource.connect(ApiEndpoints.gameConnectionUrl, newToken);
      _isHandlingError = false;
    } else {
      state = state.copyWith(
        connectionState: StompConnectionState.error,
        errorMessage: errorInfo.detail.isNotEmpty
            ? errorInfo.detail
            : 'STOMP 에러가 발생했습니다.',
      );
      _isHandlingError = false; // 비-인증 에러: WebSocket 종료 후 재연결 허용
    }
  }
}
