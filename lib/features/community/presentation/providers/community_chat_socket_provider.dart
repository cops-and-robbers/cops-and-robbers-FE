import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show AppLifecycleState;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/services/lifecycle/lifecycle_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/community_chat_event.dart';
import '../../domain/repositories/community_chat_repository.dart';
import 'community_chat_rooms_provider.dart';

part 'community_chat_socket_provider.freezed.dart';
part 'community_chat_socket_provider.g.dart';

/// 커뮤니티 소켓의 지금 상태 — 방 화면의 연결 띠와 전송 가드가 본다
@freezed
class CommunityChatSocketState with _$CommunityChatSocketState {
  const factory CommunityChatSocketState({
    @Default(CommunityChatConnectionState.disconnected)
    CommunityChatConnectionState connection,

    /// 자동 재연결 5회 실패 — 띠에 "다시 연결" 버튼을 준다.
    @Default(false) bool reconnectExhausted,
  }) = _CommunityChatSocketState;
}

/// 커뮤니티 소켓의 수명 — 로그인~로그아웃
///
/// 방 화면이 아니라 여기가 소켓을 연다. 유저당 알림 채널(DEC-0045)은 목록 화면에
/// 있든 다른 탭에 있든 계속 받아야 하기 때문이다. 재연결 정책(1·2·4·8·10초, 5회,
/// 인증 에러면 REST 한 번으로 토큰 갱신)은 방 Notifier에서 그대로 옮겨 왔다 —
/// 방이 안 열려 있을 때도 재연결할 주체가 있어야 한다.
///
/// 메시지·연결 상태·에러는 [events]로 그대로 흘려보낸다. 방 Notifier는 제 방 것만,
/// 목록 Notifier는 전부 받는다.
@Riverpod(keepAlive: true)
class CommunityChatSocket extends _$CommunityChatSocket {
  static const maxReconnectRetries = 5;

  /// STOMP CONNECTED 프레임이 이 시간 안에 안 오면 끊긴 것으로 접는다.
  ///
  /// `BaseStompDatasource`가 connectionTimeout을 안 걸어(패키지 기본값 없음)
  /// CONNECTED가 영영 안 오면 connecting에서 상태 전이가 멈추고, 그러면
  /// `_attemptReconnect`·`reconnectNow`의 "connected||connecting이면
  /// 무동작" 가드가 모든 복구 경로를 막는다 — 워치독이 connecting을 끊김으로
  /// 접어 재연결 루프에 태운다.
  static const connectingTimeout = Duration(seconds: 15);
  Timer? _connectingWatchdog;

  final _events = StreamController<CommunityChatEvent>.broadcast();
  StreamSubscription<CommunityChatEvent>? _sub;
  Timer? _reconnectTimer;
  int _reconnectCount = 0;
  int? _userId;

  /// 소켓에서 오는 것 전부. 소켓이 다시 붙어도 스트림은 같은 것이다.
  Stream<CommunityChatEvent> get events => _events.stream;

  CommunityChatRepository get _repo =>
      ref.read(communityChatRepositoryProvider);

  @override
  CommunityChatSocketState build() {
    // 로그인·로그아웃·강제 로그아웃·계정 전환이 전부 이 값 하나로 온다. 값이
    // 바뀌면 build가 다시 돌고, 아래에서 이전 연결을 정리한 뒤 새로 붙는다.
    final userId = ref.watch(currentUserIdProvider);

    // 게임 밖에서는 백그라운드 하트비트를 살려 둘 수단이 없다(ISS-0137) —
    // 돌아오면 바로 다시 붙인다. 붙어 있으면 아무것도 안 한다.
    // observer 등록(activate)은 MainScaffold.initState가 켠다.
    ref.listen(lifecycleStateProvider, (_, next) {
      if (next.valueOrNull == AppLifecycleState.resumed) reconnectNow();
    });

    ref.onDispose(() {
      _reconnectTimer?.cancel();
      _connectingWatchdog?.cancel();
      _sub?.cancel();
    });

    _reconnectTimer?.cancel();
    _connectingWatchdog?.cancel();
    _sub?.cancel();
    _reconnectCount = 0;
    final previous = _userId;
    _userId = userId;

    // 이전 사용자의 소켓이 있으면 먼저 내린다 — 로그아웃, 그리고 null을 거치지
    // 않는 계정 전환. 첫 빌드(previous == null)에는 내릴 것이 없다.
    if (previous != null) unawaited(_repo.disconnect());
    if (userId == null) return const CommunityChatSocketState();
    _listen(_repo.connect(userId));
    _armConnectingWatchdog();
    return const CommunityChatSocketState(
      connection: CommunityChatConnectionState.connecting,
    );
  }

  /// 띠의 "다시 연결"과 앱 복귀. 이미 붙었거나 붙는 중이면 아무것도 안 한다.
  void reconnectNow() {
    if (_userId == null) return;
    _reconnectTimer?.cancel();
    _reconnectCount = 0;
    state = state.copyWith(reconnectExhausted: false);
    _attemptReconnect();
  }

  /// 1·2·4·8초, 최대 10초 — 게임 `ChatNotifier`와 같은 정책
  static Duration backoffDelay(int attempt) =>
      Duration(seconds: (1 << (attempt - 1)).clamp(1, 10));

  void _listen(Stream<CommunityChatEvent> stream) {
    _sub?.cancel();
    _sub = stream.listen(
      _onEvent,
      onError: (Object e) {
        debugPrint('[CommunityChatSocket] ⚠️ 스트림 에러: $e');
        _onEvent(
          const CommunityChatEvent.connection(
            CommunityChatConnectionState.disconnected,
          ),
        );
      },
      // 끊김 이벤트 없이 스트림만 닫혀도 끊긴 것으로 본다 — 안 그러면 "연결됨"으로 굳는다.
      onDone: () => _onEvent(
        const CommunityChatEvent.connection(
          CommunityChatConnectionState.disconnected,
        ),
      ),
    );
  }

  void _onEvent(CommunityChatEvent e) {
    // _events는 의도적으로 닫지 않는다 — onDispose는 keepAlive 재빌드마다 돌아,
    // 닫으면 계정 전환 후 스트림이 영구 침묵한다. 가드는 방어용.
    if (_events.isClosed) return;
    _events.add(e);
    switch (e) {
      case CommunityChatConnectionEvent(
        state: CommunityChatConnectionState.connected,
      ):
        _connectingWatchdog?.cancel();
        _reconnectCount = 0;
        state = state.copyWith(
          connection: CommunityChatConnectionState.connected,
          reconnectExhausted: false,
        );
      case CommunityChatConnectionEvent(
        state: CommunityChatConnectionState.disconnected,
      ):
        _connectingWatchdog?.cancel();
        state = state.copyWith(
          connection: CommunityChatConnectionState.disconnected,
        );
        _scheduleReconnect();
      case CommunityChatConnectionEvent():
        state = state.copyWith(
          connection: CommunityChatConnectionState.connecting,
        );
        _armConnectingWatchdog();
      case CommunityChatErrorEvent(:final errorCode)
          when _authErrorCodes.contains(errorCode):
        unawaited(_refreshTokenThenReconnect());
      default:
        break;
    }
  }

  static const _authErrorCodes = {
    'ACCESS_TOKEN_EXPIRED',
    'INVALID_TOKEN',
    'UNAUTHENTICATED_REQUEST',
  };

  /// 만료된 토큰으로는 소켓만 다시 붙어봐야 계속 거절당한다. REST를 한 번 태우면
  /// `AuthInterceptor`가 401을 받아 재발급하고, 그 다음 연결이 새 토큰으로 붙는다.
  Future<void> _refreshTokenThenReconnect() async {
    try {
      await _repo.getRooms();
    } on AppException catch (e) {
      debugPrint('[CommunityChatSocket] ⚠️ 토큰 갱신용 REST 실패: ${e.message}');
    }
    if (_userId == null) return;
    // 서버 인증 에러는 대개 disconnected 이벤트가 뒤따라 스케줄을 이미 건다 —
    // 둘 다 걸면 5회 예산이 실질 4회가 된다(최종 리뷰 M-2).
    if (_reconnectTimer?.isActive != true) _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_userId == null) return;
    if (_reconnectCount >= maxReconnectRetries) {
      state = state.copyWith(reconnectExhausted: true);
      return;
    }
    _reconnectCount++;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(backoffDelay(_reconnectCount), _attemptReconnect);
  }

  /// 붙었거나 붙는 중이면 아무것도 안 한다.
  ///
  /// 이 한 줄이 둘을 동시에 막는다 — 띠의 "다시 연결" 연타, 그리고 STOMP
  /// ERROR 하나가 (에러 경로 + 뒤따르는 끊김 이벤트) 재연결을 두 번 거는 것.
  void _attemptReconnect() {
    final userId = _userId;
    if (userId == null) return;
    if (state.connection == CommunityChatConnectionState.connected ||
        state.connection == CommunityChatConnectionState.connecting) {
      return;
    }
    state = state.copyWith(connection: CommunityChatConnectionState.connecting);
    _armConnectingWatchdog();
    _listen(_repo.connect(userId));
  }

  /// connecting에 들어갈 때마다 다시 건다 — CONNECTED가 끝내 안 오면 끊김으로
  /// 접어 `_onEvent`를 태운다(위 [connectingTimeout] 참고).
  void _armConnectingWatchdog() {
    _connectingWatchdog?.cancel();
    _connectingWatchdog = Timer(connectingTimeout, () {
      if (state.connection == CommunityChatConnectionState.connecting) {
        _onEvent(
          const CommunityChatEvent.connection(
            CommunityChatConnectionState.disconnected,
          ),
        );
      }
    });
  }
}
