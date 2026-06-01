import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/presentation/providers/token_provider.dart';
import '../../../session/presentation/providers/game_participant_provider.dart';
import '../../../session/presentation/providers/session_provider.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/i18n/error_message_mapper.dart';
import '../../../../core/i18n/locale_provider.dart';
import '../../../../core/services/vibration_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/datasources/lobby_stomp_datasource.dart';
import '../../data/models/lobby_event_dto.dart';

part 'lobby_provider.g.dart';

/// copyWith에서 "값을 전달하지 않음"과 "명시적 null"을 구분하기 위한 sentinel 객체
const _sentinel = Object();

/// LobbyStompDatasource Provider (싱글톤)
@riverpod
LobbyStompDatasource lobbyStompDatasource(Ref ref) {
  final datasource = LobbyStompDatasource();
  ref.onDispose(() => datasource.dispose());
  return datasource;
}

/// 로비 상태
class LobbyState {
  final StompConnectionState connectionState;

  /// 사용자 노출 메시지 (i18n 미적용 폴백 — 한국어).
  ///
  /// UI 레이어에서는 [errorMessageKey]가 있으면 우선 사용하고,
  /// 없거나 알 수 없는 키이면 이 값을 표시한다.
  final String? errorMessage;

  /// i18n 메시지 키 — UI 레이어에서 [AppLocalizations]로 변환.
  ///
  /// Notifier는 BuildContext를 갖지 않으므로 키만 노출한다.
  final String? errorMessageKey;

  /// 마지막으로 수신한 이벤트 (UI 업데이트용)
  final LobbyEventDto? lastEvent;

  const LobbyState({
    this.connectionState = StompConnectionState.disconnected,
    this.errorMessage,
    this.errorMessageKey,
    this.lastEvent,
  });

  LobbyState copyWith({
    StompConnectionState? connectionState,
    Object? errorMessage = _sentinel,
    Object? errorMessageKey = _sentinel,
    Object? lastEvent = _sentinel,
  }) {
    return LobbyState(
      connectionState: connectionState ?? this.connectionState,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
      errorMessageKey: errorMessageKey == _sentinel
          ? this.errorMessageKey
          : errorMessageKey as String?,
      lastEvent: lastEvent == _sentinel
          ? this.lastEvent
          : lastEvent as LobbyEventDto?,
    );
  }
}

/// 로비 상태 관리 Notifier
///
/// STOMP 연결/구독/이벤트 처리를 관리합니다.
/// WaitingRoomPage 진입 시 [connectAndSubscribe]를 호출하고,
/// 이탈 시 [disconnectLobby]를 호출합니다.
@riverpod
class LobbyNotifier extends _$LobbyNotifier {
  StreamSubscription<LobbyEventDto>? _eventSub;
  StreamSubscription<StompConnectionState>? _connectionSub;
  StreamSubscription<StompErrorInfo>? _errorSub;

  /// 401 에러 재연결 시도 횟수 (무한 루프 방지)
  int _authRetryCount = 0;
  static const _maxAuthRetries = 1;

  /// 네트워크 재연결 시도 횟수
  int _reconnectCount = 0;
  static const _maxReconnectRetries = 5;

  /// 재연결 타이머
  Timer? _reconnectTimer;

  /// 의도적 연결 해제 여부
  bool _intentionalDisconnect = false;

  /// STOMP 에러 처리 중 여부
  bool _isHandlingError = false;

  /// 현재 게임 ID (재연결용)
  int? _gameId;

  /// 게임 시작 콜백
  void Function(LobbyEventDto event)? _onGameStart;

  @override
  LobbyState build() {
    ref.watch(lobbyStompDatasourceProvider);

    ref.onDispose(() {
      _eventSub?.cancel();
      _connectionSub?.cancel();
      _errorSub?.cancel();
      _reconnectTimer?.cancel();
    });
    return const LobbyState();
  }

  /// STOMP 연결 후 로비 이벤트 구독
  ///
  /// [gameId] 게임 ID
  /// [onGameStart] 게임 시작 이벤트 수신 시 호출되는 콜백
  Future<void> connectAndSubscribe({
    required int gameId,
    void Function(LobbyEventDto event)? onGameStart,
  }) async {
    final datasource = ref.read(lobbyStompDatasourceProvider);

    // 이미 연결 중이거나 연결된 상태면 무시
    if (datasource.currentState == StompConnectionState.connecting ||
        datasource.currentState == StompConnectionState.connected) {
      return;
    }

    // 상태 초기화
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _gameId = gameId;
    _onGameStart = onGameStart;
    _intentionalDisconnect = false;
    _isHandlingError = false;
    _reconnectCount = 0;
    _authRetryCount = 0;

    // Access Token 획득
    final tokenProvider = ref.read(tokenProviderProvider);
    final accessToken = await tokenProvider.getAccessToken();
    if (accessToken == null) {
      debugPrint('[LobbyNotifier] ❌ 토큰 획득 실패');
      final l10n = lookupAppLocalizations(ref.read(appLocaleProvider).locale);
      state = state.copyWith(
        connectionState: StompConnectionState.error,
        errorMessage: l10n.errorByCode('ACCESS_TOKEN_EXPIRED'),
        errorMessageKey: 'errorAuthTokenMissing',
      );
      return;
    }

    // 스트림 구독 설정
    _setupStreams();

    // 구독 예약 (connected 시 자동 구독)
    datasource.subscribeLobby(gameId);

    // STOMP 연결
    final wsUrl = ApiEndpoints.gameConnectionUrl;
    debugPrint('[LobbyNotifier] 🔗 STOMP 연결 시도: $wsUrl');
    debugPrint('[LobbyNotifier] 📍 gameId: $gameId');
    datasource.connect(wsUrl, accessToken);
  }

  /// 수동 재연결 — 재시도 카운터를 초기화하고 즉시 연결 시도
  ///
  /// 사용자가 재연결 버튼을 탭했을 때 호출합니다.
  /// 기존 자동 재연결 백오프와 달리 딜레이 없이 즉시 시도합니다.
  Future<void> manualReconnect() async {
    if (_gameId == null) return;
    _reconnectCount = 0; // 재시도 카운터 초기화 → 이후 자동 재연결 5회 재활성화
    _intentionalDisconnect = false;
    _isHandlingError = false;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    await _attemptReconnect();
  }

  /// [DEBUG 전용] 재연결 횟수를 소진한 것처럼 강제로 error 상태로 전환
  ///
  /// 재연결 모달이 떠있을 때 수동 재연결만 가능한 상황을 테스트합니다.
  Future<void> debugForceReconnectExhausted() async {
    assert(kDebugMode, 'debugForceReconnectExhausted는 debug 빌드 전용입니다');
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _reconnectCount = _maxReconnectRetries + 1; // 자동 재연결 차단
    _intentionalDisconnect = true; // 스트림 콜백의 _scheduleReconnect 억제
    ref.read(lobbyStompDatasourceProvider).disconnect();
    // disconnect() → stream listener → state = disconnected (동기) 이후
    // 마이크로태스크에서 error로 덮어씌워 최종 상태를 error로 확정
    await Future.microtask(() {
      try {
        final l10n = lookupAppLocalizations(ref.read(appLocaleProvider).locale);
        state = state.copyWith(
          connectionState: StompConnectionState.error,
          errorMessage: l10n.errorServerUnreachable,
          errorMessageKey: 'errorServerUnreachable',
        );
        _intentionalDisconnect = false; // 수동 재연결(manualReconnect)은 허용
      } catch (_) {
        // notifier가 이미 dispose된 경우 무시
      }
    });
  }

  /// 로비 연결 해제
  void disconnectLobby() {
    _intentionalDisconnect = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

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
    _onGameStart = null;

    final datasource = ref.read(lobbyStompDatasourceProvider);
    datasource.disconnect();

    state = const LobbyState();
  }

  // ============================================
  // 내부 메서드
  // ============================================

  void _setupStreams() {
    final datasource = ref.read(lobbyStompDatasourceProvider);

    // 기존 구독 정리
    _eventSub?.cancel();
    _connectionSub?.cancel();
    _errorSub?.cancel();

    // 연결 상태 구독
    _connectionSub = datasource.onConnectionState.listen((connState) {
      state = state.copyWith(connectionState: connState);

      if (connState == StompConnectionState.connected) {
        // 연결 성공 → 상태 초기화 (구독은 onConnected()에서 자동 처리)
        _authRetryCount = 0;
        _reconnectCount = 0;
        _isHandlingError = false;
        _reconnectTimer?.cancel();
        _reconnectTimer = null;
        state = state.copyWith(errorMessage: null, errorMessageKey: null);
      } else if (connState == StompConnectionState.disconnected) {
        // 예기치 않은 연결 종료 → 재연결 시도
        if (!_intentionalDisconnect && !_isHandlingError) {
          _scheduleReconnect();
        }
      }
    });

    // 이벤트 수신 구독
    _eventSub = datasource.onEvent.listen(_handleLobbyEvent);

    // STOMP 에러 구독
    _errorSub = datasource.onError.listen((errorInfo) {
      _isHandlingError = true;
      _handleStompError(errorInfo);
    });
  }

  /// 로비 이벤트 처리
  void _handleLobbyEvent(LobbyEventDto event) {
    debugPrint('[LobbyNotifier] 📩 로비 이벤트 수신: ${event.type}');

    // 상태 업데이트
    state = state.copyWith(lastEvent: event);

    // GAME_START 이벤트 처리
    if (event.type == LobbyEventType.gameStart) {
      VibrationService.instance().gameStart();
      debugPrint('[LobbyNotifier] 🎮 게임 시작 이벤트 수신!');
      _onGameStart?.call(event);
    }

    // SETTINGS_UPDATED 이벤트 → 설정 캐시 무효화 + 참가자 정보 갱신
    if (event.type == LobbyEventType.settingsUpdated) {
      debugPrint('[LobbyNotifier] ⚙️ 게임 설정 변경 이벤트 수신');
      ref.invalidate(fetchGameSettingsProvider(event.gameId));

      // 최신 설정을 fetch하여 gameParticipantNotifier도 동기화
      ref
          .read(fetchGameSettingsProvider(event.gameId).future)
          .then((settings) {
            ref
                .read(gameParticipantNotifierProvider.notifier)
                .updateSettings(
                  maxParticipants: settings.maxParticipants,
                  locationRevealIntervalMinutes:
                      settings.locationRevealIntervalMinutes,
                  policeWaitMinutes: settings.policeWaitMinutes,
                  roundTimeMinutes: settings.roundDurationMinutes,
                );
          })
          .catchError((e) {
            debugPrint('[LobbyNotifier] ⚠️ 설정 동기화 실패: $e');
          });
    }

    // AREA_UPDATED 이벤트 → 영역 캐시 무효화
    if (event.type == LobbyEventType.areaUpdated) {
      debugPrint('[LobbyNotifier] 📍 게임 영역 변경 이벤트 수신');
      ref.invalidate(fetchGameAreaProvider(event.gameId));
    }
  }

  // ============================================
  // 재연결 정책
  // ============================================

  void _scheduleReconnect() {
    if (_intentionalDisconnect || _gameId == null) return;

    _reconnectCount++;
    if (_reconnectCount > _maxReconnectRetries) {
      debugPrint('[LobbyNotifier] ❌ 최대 재연결 횟수 초과 ($_maxReconnectRetries)');
      final l10n = lookupAppLocalizations(ref.read(appLocaleProvider).locale);
      state = state.copyWith(
        connectionState: StompConnectionState.error,
        errorMessage: l10n.errorServerUnreachable,
        errorMessageKey: 'errorServerUnreachable',
      );
      return;
    }

    final delaySeconds = _calculateBackoffDelay(_reconnectCount);
    debugPrint(
      '[LobbyNotifier] 🔄 재연결 예약: $delaySeconds초 후 '
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

    final datasource = ref.read(lobbyStompDatasourceProvider);

    if (datasource.currentState == StompConnectionState.connecting ||
        datasource.currentState == StompConnectionState.connected) {
      return;
    }

    debugPrint(
      '[LobbyNotifier] 🔄 재연결 시도 ($_reconnectCount/$_maxReconnectRetries)',
    );

    final tokenProvider = ref.read(tokenProviderProvider);
    final accessToken = await tokenProvider.getAccessToken();

    if (_intentionalDisconnect || _gameId == null) return;

    if (accessToken == null) {
      debugPrint('[LobbyNotifier] ❌ 재연결 토큰 획득 실패');
      _scheduleReconnect();
      return;
    }

    datasource.subscribeLobby(_gameId!);
    final wsUrl = ApiEndpoints.gameConnectionUrl;
    datasource.connect(wsUrl, accessToken);
  }

  // ============================================
  // STOMP 에러 처리
  // ============================================

  Future<void> _handleStompError(StompErrorInfo errorInfo) async {
    if (errorInfo.isAuthExpired) {
      _authRetryCount++;

      if (_authRetryCount > _maxAuthRetries) {
        debugPrint('[LobbyNotifier] ❌ 인증 만료 - 최대 재시도 횟수 초과');
        final l10n = lookupAppLocalizations(ref.read(appLocaleProvider).locale);
        state = state.copyWith(
          connectionState: StompConnectionState.error,
          errorMessage: l10n.errorByCode('ACCESS_TOKEN_EXPIRED'),
          errorMessageKey: 'errorAuthExpired',
        );
        return;
      }

      debugPrint('[LobbyNotifier] 🔄 인증 만료 - 토큰 갱신 시도');

      final tokenProvider = ref.read(tokenProviderProvider);
      // await 전에 datasource 캡처 (await 후 ref 접근 방지)
      final datasource = ref.read(lobbyStompDatasourceProvider);
      final newToken = await tokenProvider.refreshAccessTokenIfNeeded();

      if (_intentionalDisconnect || _gameId == null) return;

      if (newToken == null) {
        debugPrint('[LobbyNotifier] ❌ 토큰 갱신 실패');
        final l10n = lookupAppLocalizations(ref.read(appLocaleProvider).locale);
        state = state.copyWith(
          connectionState: StompConnectionState.error,
          errorMessage: l10n.errorByCode('ACCESS_TOKEN_EXPIRED'),
          errorMessageKey: 'errorAuthExpired',
        );
        return;
      }

      // 재연결 시작 후 이 연결이 실패하면 일반 재연결 정책이 이어받을 수 있도록 플래그 해제
      debugPrint('[LobbyNotifier] ✅ 토큰 갱신 성공 - 재연결 시도');
      datasource.subscribeLobby(_gameId!);
      final wsUrl = ApiEndpoints.gameConnectionUrl;
      datasource.connect(wsUrl, newToken);
      _isHandlingError = false;
    } else {
      // 비-401 STOMP 에러: errorCode 기반 i18n 메시지 표시
      final l10n = lookupAppLocalizations(ref.read(appLocaleProvider).locale);
      state = state.copyWith(
        connectionState: StompConnectionState.error,
        errorMessage: errorInfo.errorCode != null
            ? l10n.errorByCode(errorInfo.errorCode!)
            : l10n.errorTemporaryRetry,
      );
      _isHandlingError = false; // 비-인증 에러: WebSocket 종료 후 재연결 허용
    }
  }
}
