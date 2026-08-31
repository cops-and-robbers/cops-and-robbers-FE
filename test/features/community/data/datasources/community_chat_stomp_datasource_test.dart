import 'package:cops_and_robbers/features/community/data/datasources/community_chat_stomp_datasource.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

/// 시스템 경계(실 소켓)만 대역으로 세운다 — 구독 목록만 기록한다.
class _FakeStompClient implements StompClient {
  final subscriptions = <String>[];
  final unsubscribed = <String>[];

  @override
  StompUnsubscribe subscribe({
    required String destination,
    required void Function(StompFrame) callback,
    Map<String, String>? headers,
  }) {
    subscriptions.add(destination);
    return ({Map<String, String>? unsubscribeHeaders}) =>
        unsubscribed.add(destination);
  }

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
      ]);
    });

    test('resubscribes_both_channels_on_reconnect', () {
      final ds = _TestDatasource();
      ds.connectAs('ws', 't', userId: 7);
      ds.subscribeRoom(42);
      ds.fireConnected();

      ds.fireConnected(); // 예약된 방이 재연결에 살아남는다

      expect(ds.client.subscriptions.length, 4);
      expect(ds.client.subscriptions.sublist(2), [
        '/subscribe/user/7/community/chat',
        '/subscribe/community/42/chat',
      ]);
    });

    test('unsubscribes_only_the_room_it_still_owns', () {
      final ds = _TestDatasource();
      ds.connectAs('ws', 't', userId: 7);
      ds.subscribeRoom(42);
      ds.fireConnected();

      ds.unsubscribeRoom(43); // 다른 방 번호 — 아무것도 안 한다
      expect(ds.client.unsubscribed, isEmpty);

      ds.unsubscribeRoom(42);
      expect(ds.client.unsubscribed, ['/subscribe/community/42/chat']);

      ds.fireConnected(); // 방 채널은 더 이상 재구독되지 않는다 — 개인 채널만 추가
      expect(ds.client.subscriptions.length, 3);
      expect(ds.client.subscriptions.last, '/subscribe/user/7/community/chat');
    });
  });
}
