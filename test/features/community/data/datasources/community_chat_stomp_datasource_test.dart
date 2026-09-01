import 'package:cops_and_robbers/features/community/data/datasources/community_chat_stomp_datasource.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

/// 시스템 경계(실 소켓)만 대역으로 세운다 — 구독 목록을 기록하고, 콜백을
/// 들고 있다가 [deliver]로 프레임을 흘려 넣는다.
class _FakeStompClient implements StompClient {
  final subscriptions = <String>[];
  final unsubscribed = <String>[];
  final _callbacks = <String, void Function(StompFrame)>{};

  @override
  StompUnsubscribe subscribe({
    required String destination,
    required void Function(StompFrame) callback,
    Map<String, String>? headers,
  }) {
    subscriptions.add(destination);
    _callbacks[destination] = callback;
    return ({Map<String, String>? unsubscribeHeaders}) =>
        unsubscribed.add(destination);
  }

  /// 서버가 그 채널로 프레임을 보낸 상황.
  void deliver(String destination, String body) =>
      _callbacks[destination]!(StompFrame(command: 'MESSAGE', body: body));

  @override
  dynamic noSuchMethod(Invocation invocation) => null; // 나머지는 안 쓴다
}

/// 실 소켓을 열지 않는 시임 — `connect()`를 no-op으로 바꾸고 `onConnected()`를
/// 손으로 불러 구독 로직만 검증한다.
///
/// `currentState`는 `fireConnected()` 호출 여부를 그대로 반영한다 — 상수로
/// 고정하면(항상 connected) `subscribeRoom()`이 `onConnected()` 전에 즉시
/// 구독해 버려 "연결되면 개인 채널 다음 방 채널" 순서 검증이 깨진다.
class _TestDatasource extends CommunityChatStompDatasource {
  final client = _FakeStompClient();
  bool _connected = false;

  @override
  void connect(String wsUrl, String accessToken) {} // 실소켓을 열지 않는다

  @override
  StompClient? get stompClient => client;

  @override
  StompConnectionState get currentState => _connected
      ? StompConnectionState.connected
      : StompConnectionState.disconnected;

  void fireConnected() {
    _connected = true;
    onConnected();
  }
}

void main() {
  group('CommunityChatStompDatasource destinations', () {
    test('user_channel_uses_slashes_not_hyphens', () {
      // 기존 채널 11개가 전부 슬래시 구분이다 — 하이픈(community-chat)이면
      // 서버 라우팅이 게임 인터셉터로 흘러 INVALID_DESTINATION이 된다 (DEC-0045).
      expect(
        CommunityChatStompDatasource.userChannel(7),
        '/subscribe/user/7/community/chat',
      );
    });

    test('room_channel_keeps_the_existing_shape', () {
      expect(
        CommunityChatStompDatasource.roomChannel(42),
        '/subscribe/community/42/chat',
      );
    });

    test('pin_channel_hangs_under_the_room_path', () {
      // 방 채널과 같은 `/subscribe/community/**` 패턴이어야 서버의 멤버 검증
      // 인터셉터를 그대로 탄다 — 벗어나면 INVALID_DESTINATION이다.
      expect(
        CommunityChatStompDatasource.pinChannel(42),
        '/subscribe/community/42/chat/pin',
      );
    });
  });

  group('CommunityChatStompDatasource subscriptions', () {
    test('subscribes_user_channel_then_pending_room_when_connected', () {
      final ds = _TestDatasource();
      ds.connectAs('ws', 't', userId: 7); // 우리 override라 no-op
      ds.subscribeRoom(42);

      ds.fireConnected();

      expect(ds.client.subscriptions, [
        '/subscribe/user/7/community/chat',
        '/subscribe/community/42/chat',
        // 공지 배너는 대화와 채널이 갈린다(DEC-0055) — 방을 구독하면 같이 붙는다.
        '/subscribe/community/42/chat/pin',
      ]);
    });

    test('resubscribes_both_channels_on_reconnect', () {
      final ds = _TestDatasource();
      ds.connectAs('ws', 't', userId: 7);
      ds.subscribeRoom(42);
      ds.fireConnected();

      ds.fireConnected(); // 예약된 방이 재연결에 살아남는다

      expect(ds.client.subscriptions.length, 6);
      expect(ds.client.subscriptions.sublist(3), [
        '/subscribe/user/7/community/chat',
        '/subscribe/community/42/chat',
        '/subscribe/community/42/chat/pin',
      ]);
    });

    test('reports_the_subscribed_room_when_a_pin_frame_arrives', () async {
      // 공지 채널 payload는 api-docs가 담지 않는 계약이다 — 필드 이름에 기대는
      // 대신 구독한 방 번호를 흘린다. 그래서 본문이 무엇이든 방 번호가 나온다.
      final ds = _TestDatasource();
      ds.connectAs('ws', 't', userId: 7);
      ds.subscribeRoom(42);
      ds.fireConnected();

      final received = <int>[];
      ds.onPinChanged.listen(received.add);
      ds.client.deliver(
        CommunityChatStompDatasource.pinChannel(42),
        '{"action":"PIN_DELETED","content":null}',
      );
      await Future<void>.delayed(Duration.zero);

      expect(received, [42]);
    });

    test('stops_reporting_pins_after_the_room_is_left', () async {
      // 구독을 풀고도 계속 흘리면 나간 방의 배너가 갱신된다.
      final ds = _TestDatasource();
      ds.connectAs('ws', 't', userId: 7);
      ds.subscribeRoom(42);
      ds.fireConnected();
      ds.unsubscribeRoom(42);

      final received = <int>[];
      ds.onPinChanged.listen(received.add);
      await Future<void>.delayed(Duration.zero);

      expect(
        ds.client.unsubscribed,
        contains('/subscribe/community/42/chat/pin'),
      );
      expect(received, isEmpty);
    });

    test('unsubscribes_only_the_room_it_still_owns', () {
      final ds = _TestDatasource();
      ds.connectAs('ws', 't', userId: 7);
      ds.subscribeRoom(42);
      ds.fireConnected();

      ds.unsubscribeRoom(43); // 다른 방 번호 — 아무것도 안 한다
      expect(ds.client.unsubscribed, isEmpty);

      ds.unsubscribeRoom(42);
      // 방을 떠나면 공지 채널도 함께 풀린다 — 남기면 나간 방의 배너가 계속 온다.
      expect(ds.client.unsubscribed, [
        '/subscribe/community/42/chat',
        '/subscribe/community/42/chat/pin',
      ]);

      ds.fireConnected(); // 방 채널은 더 이상 재구독되지 않는다 — 개인 채널만 추가
      expect(ds.client.subscriptions.length, 4);
      expect(ds.client.subscriptions.last, '/subscribe/user/7/community/chat');
    });
  });
}
