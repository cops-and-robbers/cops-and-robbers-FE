import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/services/vibration_service.dart';
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
        gameStartTime ??
        (gameStartTimeStr != null ? DateTime.tryParse(gameStartTimeStr) : null);

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
  int? _gameId;

  @override
  GameEventState build() {
    ref.watch(gameEventStompDatasourceProvider);
    ref.onDispose(() {
      _isDisposed = true;
      _eventSub?.cancel();
      _connectionSub?.cancel();
      _errorSub?.cancel();
      _reconnectTimer?.cancel();
      _locationRevealBannerTimer?.cancel();
    });
    return const GameEventState();
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

  /// 의도적 연결 해제
  void disconnect() {
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
    state = const GameEventState();
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
  /// STOMP ESCAPE 이벤트 도착 전 낙관적으로 [escapedParticipantIds]에 즉시 추가.
  /// API 실패 시 rollback.
  Future<void> escape(int gameId, int myParticipantId) async {
    // 낙관적 업데이트: STOMP 이벤트 도착 전 즉시 UI 반영
    state = state.copyWith(
      escapedParticipantIds: {...state.escapedParticipantIds, myParticipantId},
      isApiLoading: true,
    );
    try {
      await ref.read(gameSystemApiProvider).escape(gameId);
      // API 성공 → 로딩 해제 (STOMP 이벤트에서 최종 상태 확정)
      state = state.copyWith(isApiLoading: false);
    } catch (e) {
      debugPrint('[GameEventNotifier] ❌ 탈옥 요청 실패: $e');
      // 실패 시 낙관적 업데이트 rollback
      state = state.copyWith(
        escapedParticipantIds: state.escapedParticipantIds.difference({
          myParticipantId,
        }),
        isApiLoading: false,
        errorMessage: '탈옥 요청 실패',
      );
    }
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
            _parseTimestamp(event.timestamp) ?? DateTime.now();
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
    final startTime = _parseTimestamp(startTimeStr);
    state = state.copyWith(
      gameStartTime: startTime ?? DateTime.now(),
      bannerMessage: GameEventMessages.gameStartGo,
    );
    _startBannerTimer();
    debugPrint(
      '[GameEventNotifier] ✅ START 이벤트 → 게임 시작 시각: ${state.gameStartTime}',
    );
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

    final revealTime = _parseTimestamp(timestamp) ?? DateTime.now();
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
  }

  // ============================================================
  // 유틸리티
  // ============================================================

  static DateTime? _parseTimestamp(String? raw) {
    if (raw == null) return null;
    final normalized = raw.replaceFirstMapped(
      RegExp(r'(\.\d{1,6})\d*'),
      (m) => m.group(1)!,
    );
    return DateTime.tryParse(normalized);
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

  int _calculateBackoffDelay(int attempt) {
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
