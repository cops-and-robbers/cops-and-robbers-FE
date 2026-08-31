import 'dart:async';

import 'package:cops_and_robbers/core/services/lifecycle/lifecycle_provider.dart';
import 'package:cops_and_robbers/features/auth/presentation/providers/auth_provider.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_chat_event.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_chat_message_entity.dart';
import 'package:cops_and_robbers/features/community/presentation/providers/community_chat_rooms_provider.dart';
import 'package:cops_and_robbers/features/community/presentation/providers/community_chat_socket_provider.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../community_chat_fakes.dart';

/// 로그인 상태를 테스트가 바꾼다 — 로그인·로그아웃·계정 전환.
final _userIdProvider = StateProvider<int?>((_) => 1);

int _connects(FakeCommunityChatRepository repo) =>
    repo.calls.where((x) => x.startsWith('connect:')).length;

({ProviderContainer container, StreamController<AppLifecycleState> lifecycle})
_harness(FakeCommunityChatRepository repo) {
  final lifecycle = StreamController<AppLifecycleState>.broadcast();
  final c = ProviderContainer(
    overrides: [
      communityChatRepositoryProvider.overrideWithValue(repo),
      currentUserIdProvider.overrideWith((ref) => ref.watch(_userIdProvider)),
      lifecycleStateProvider.overrideWith((ref) => lifecycle.stream),
    ],
  );
  addTearDown(() {
    c.dispose();
    lifecycle.close();
  });
  return (container: c, lifecycle: lifecycle);
}

CommunityChatSocketState _state(ProviderContainer c) =>
    c.read(communityChatSocketProvider);

// listen을 한 번 걸어 둬야 currentUserIdProvider 변화가 예약(스케줄)된 리빌드로
// 실제 반영된다 — main.dart의 ref.listen(communityChatSocketProvider, ...)과
// 같은 이유(keepAlive Notifier는 리스너가 없으면 리빌드가 지연된다).
CommunityChatSocket _notifier(ProviderContainer c) {
  c.listen(communityChatSocketProvider, (_, _) {});
  return c.read(communityChatSocketProvider.notifier);
}

void main() {
  group('CommunityChatSocket', () {
    test('opens_the_socket_for_the_logged_in_user', () {
      fakeAsync((async) {
        final repo = FakeCommunityChatRepository();
        final (:container, :lifecycle) = _harness(repo);

        _notifier(container);
        async.flushMicrotasks();

        expect(repo.calls, contains('connect:1'));
        expect(
          _state(container).connection,
          CommunityChatConnectionState.connected,
        );
      });
    });

    test('closes_the_socket_and_stops_reconnecting_when_the_user_logs_out', () {
      fakeAsync((async) {
        final repo = FakeCommunityChatRepository();
        final (:container, :lifecycle) = _harness(repo);
        _notifier(container);
        async.flushMicrotasks();

        container.read(_userIdProvider.notifier).state = null;
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 30));

        expect(repo.calls, contains('disconnect'));
        expect(_connects(repo), 1);
        expect(
          _state(container).connection,
          CommunityChatConnectionState.disconnected,
        );
      });
    });

    test('reconnects_as_the_new_user_when_the_account_changes', () {
      fakeAsync((async) {
        final repo = FakeCommunityChatRepository();
        final (:container, :lifecycle) = _harness(repo);
        _notifier(container);
        async.flushMicrotasks();

        container.read(_userIdProvider.notifier).state = 2;
        async.flushMicrotasks();
        // 리빌드가 Riverpod 스케줄러에 예약된 상태다 — 타이머 기반이라
        // flushMicrotasks만으로는 안 돈다. Duration.zero로 그 예약을 태운다.
        async.elapse(Duration.zero);

        expect(repo.calls.sublist(1), ['disconnect', 'connect:2']);
        expect(
          _state(container).connection,
          CommunityChatConnectionState.connected,
        );
      });
    });

    test('does_not_open_a_socket_without_a_user', () {
      fakeAsync((async) {
        final repo = FakeCommunityChatRepository();
        final (:container, :lifecycle) = _harness(repo);
        container.read(_userIdProvider.notifier).state = null;

        _notifier(container);
        async.flushMicrotasks();

        expect(_connects(repo), 0);
      });
    });

    test('forwards_every_socket_event_to_listeners', () {
      fakeAsync((async) {
        final repo = FakeCommunityChatRepository();
        final (:container, :lifecycle) = _harness(repo);
        final seen = <CommunityChatEvent>[];
        _notifier(container).events.listen(seen.add);
        async.flushMicrotasks();

        repo.emitMessage(
          CommunityChatMessageEntity(
            id: 5,
            messageKey: 'k5',
            senderId: 7,
            senderNickname: 'n7',
            body: const CommunityChatMessageBody.text('hi'),
            createdAt: DateTime(2026, 8, 31),
          ),
          postId: 99,
        );
        async.flushMicrotasks();

        expect(seen.whereType<CommunityChatMessageEvent>().single.postId, 99);
      });
    });

    test(
      'marks_disconnected_and_reconnects_when_stream_closes_without_event',
      () {
        fakeAsync((async) {
          final repo = FakeCommunityChatRepository();
          final (:container, :lifecycle) = _harness(repo);
          _notifier(container);
          async.flushMicrotasks();

          repo.controller!.close();
          async.flushMicrotasks();
          expect(
            _state(container).connection,
            CommunityChatConnectionState.disconnected,
          );

          async.elapse(const Duration(seconds: 1)); // 첫 재연결 백오프
          async.flushMicrotasks();
          expect(_connects(repo), 2);
          expect(
            _state(container).connection,
            CommunityChatConnectionState.connected,
          );
        });
      },
    );

    test('stops_reconnecting_after_five_failed_attempts', () {
      fakeAsync((async) {
        final repo = FakeCommunityChatRepository()
          ..connectEmitsDisconnected = true;
        final (:container, :lifecycle) = _harness(repo);
        _notifier(container);
        async.flushMicrotasks();

        // 1+2+4+8+10초 — 다섯 번째 시도까지 끝나고도 남는 시간
        async.elapse(const Duration(seconds: 30));

        expect(_connects(repo), 6);
        expect(_state(container).reconnectExhausted, isTrue);
        expect(
          _state(container).connection,
          CommunityChatConnectionState.disconnected,
        );
      });
    });

    test('ignores_reconnect_requests_while_a_connection_is_in_flight', () {
      fakeAsync((async) {
        final repo = FakeCommunityChatRepository()
          ..connectEmitsDisconnected = true;
        final (:container, :lifecycle) = _harness(repo);
        _notifier(container);
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 30));
        final before = _connects(repo);

        _notifier(container)
          ..reconnectNow()
          ..reconnectNow()
          ..reconnectNow();
        async.flushMicrotasks();

        expect(_connects(repo), before + 1);
      });
    });

    test('refetches_over_rest_before_reconnecting_when_the_token_expired', () {
      // 소켓만 다시 붙으면 만료된 토큰으로 계속 거절당한다. REST를 한 번 태워야
      // AuthInterceptor가 재발급하고, 그 다음 연결이 새 토큰으로 붙는다.
      fakeAsync((async) {
        final repo = FakeCommunityChatRepository();
        final (:container, :lifecycle) = _harness(repo);
        _notifier(container);
        async.flushMicrotasks();
        repo.calls.clear();

        repo.emit(const CommunityChatEvent.error('ACCESS_TOKEN_EXPIRED'));
        repo.emit(
          const CommunityChatEvent.connection(
            CommunityChatConnectionState.disconnected,
          ),
        );
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 2));

        expect(repo.calls.first, 'getRooms');
        expect(_connects(repo), 1);
      });
    });

    test('reconnects_when_the_app_returns_to_the_foreground', () {
      fakeAsync((async) {
        final repo = FakeCommunityChatRepository()
          ..connectEmitsDisconnected = true;
        final (:container, :lifecycle) = _harness(repo);
        _notifier(container);
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 30)); // 소진
        repo.connectEmitsDisconnected = false;
        final before = _connects(repo);

        lifecycle.add(AppLifecycleState.resumed);
        async.flushMicrotasks();

        expect(_connects(repo), before + 1);
        expect(_state(container).reconnectExhausted, isFalse);
        expect(
          _state(container).connection,
          CommunityChatConnectionState.connected,
        );
      });
    });

    test('treats_a_stalled_connect_as_dropped_and_retries', () {
      // BaseStompDatasource가 connectionTimeout을 안 걸어 CONNECTED가 끝내 안
      // 오면 connecting에 영구 정지한다 — 워치독이 그 정체를 끊김으로 접어야
      // _scheduleReconnect가 다시 돈다(I-1).
      fakeAsync((async) {
        final repo = FakeCommunityChatRepository()..connectEmitsNothing = true;
        final (:container, :lifecycle) = _harness(repo);
        _notifier(container);
        async.flushMicrotasks();
        expect(
          _state(container).connection,
          CommunityChatConnectionState.connecting,
        );

        async.elapse(CommunityChatSocket.connectingTimeout);

        expect(
          _state(container).connection,
          CommunityChatConnectionState.disconnected,
        );

        // 이제 진짜로 붙을 수 있다 — reconnectNow()가 막히지 않고 끝까지 간다.
        repo.connectEmitsNothing = false;
        _notifier(container).reconnectNow();
        async.flushMicrotasks();

        expect(
          _state(container).connection,
          CommunityChatConnectionState.connected,
        );
        expect(_connects(repo), greaterThanOrEqualTo(2));
      });
    });
  });

  group('backoffDelay', () {
    test('doubles_each_attempt_and_caps_at_ten_seconds', () {
      expect(CommunityChatSocket.backoffDelay(1), const Duration(seconds: 1));
      expect(CommunityChatSocket.backoffDelay(2), const Duration(seconds: 2));
      expect(CommunityChatSocket.backoffDelay(3), const Duration(seconds: 4));
      expect(CommunityChatSocket.backoffDelay(4), const Duration(seconds: 8));
      expect(CommunityChatSocket.backoffDelay(5), const Duration(seconds: 10));
    });
  });
}
