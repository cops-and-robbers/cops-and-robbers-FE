import 'package:cops_and_robbers/features/auth/presentation/providers/auth_provider.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_chat_event.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_chat_message_entity.dart';
import 'package:cops_and_robbers/features/community/presentation/providers/community_chat_room_provider.dart';
import 'package:cops_and_robbers/features/community/presentation/providers/community_chat_rooms_provider.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../community_chat_fakes.dart';

const _postId = 42;

CommunityChatMessageEntity _text(int id, {int sender = 7}) =>
    CommunityChatMessageEntity(
      id: id,
      messageKey: 'k$id',
      senderId: sender,
      senderNickname: 'n$sender',
      body: CommunityChatMessageBody.text('m$id'),
      createdAt: DateTime(2026, 8, 24, 10, id),
    );

CommunityChatMessageEntity _system(int id, CommunityChatSystemEvent event) =>
    CommunityChatMessageEntity(
      id: id,
      messageKey: 'k$id',
      senderId: 3,
      senderNickname: 'n3',
      body: CommunityChatMessageBody.system(event),
      createdAt: DateTime(2026, 8, 24, 10, id),
    );

ProviderContainer _container(FakeCommunityChatRepository repo) {
  final c = ProviderContainer(
    overrides: [
      communityChatRepositoryProvider.overrideWithValue(repo),
      currentUserIdProvider.overrideWithValue(1),
    ],
  );
  addTearDown(c.dispose);
  return c;
}

/// 방을 열고 첫 로드까지 끝낸 컨테이너
ProviderContainer _opened(FakeAsync async, FakeCommunityChatRepository repo) {
  final c = _container(repo);
  c.listen(communityChatRoomNotifierProvider(_postId), (_, _) {});
  async.flushMicrotasks();
  return c;
}

CommunityChatRoomState _state(ProviderContainer c) =>
    c.read(communityChatRoomNotifierProvider(_postId)).requireValue;

CommunityChatRoomNotifier _notifier(ProviderContainer c) =>
    c.read(communityChatRoomNotifierProvider(_postId).notifier);

void main() {
  group('CommunityChatRoomNotifier', () {
    test('loads_first_page_and_member_count_when_opened', () {
      fakeAsync((async) {
        final repo = FakeCommunityChatRepository()
          ..firstPage = [_text(2), _text(1)];
        final c = _opened(async, repo);

        expect(_state(c).timeline.messages.map((m) => m.id), [2, 1]);
        expect(_state(c).memberCount, 8);
        expect(_state(c).connection, CommunityChatConnectionState.connected);
      });
    });

    test('marks_message_pending_then_sent_when_echo_arrives', () {
      fakeAsync((async) {
        final repo = FakeCommunityChatRepository();
        final c = _opened(async, repo);

        _notifier(c).send('안녕');
        async.flushMicrotasks();
        final pending = _state(c).timeline.messages.single;
        expect(pending.status, CommunityChatMessageStatus.pending);
        expect(pending.senderId, 1);

        repo.emit(
          CommunityChatEvent.message(
            pending.copyWith(id: 9, status: CommunityChatMessageStatus.sent),
          ),
        );
        async.flushMicrotasks();

        final sent = _state(c).timeline.messages.single;
        expect(sent.status, CommunityChatMessageStatus.sent);
        expect(sent.id, 9);
      });
    });

    test('marks_pending_message_failed_when_connection_drops', () {
      fakeAsync((async) {
        final repo = FakeCommunityChatRepository();
        final c = _opened(async, repo);
        _notifier(c).send('안녕');
        async.flushMicrotasks();

        repo.emit(
          const CommunityChatEvent.connection(
            CommunityChatConnectionState.disconnected,
          ),
        );
        async.flushMicrotasks();

        expect(
          _state(c).timeline.messages.single.status,
          CommunityChatMessageStatus.failed,
        );
      });
    });

    test('resends_with_same_key_when_failed_message_is_retried', () {
      fakeAsync((async) {
        final repo = FakeCommunityChatRepository();
        final c = _opened(async, repo);
        _notifier(c).send('안녕');
        async.flushMicrotasks();
        final key = _state(c).timeline.messages.single.messageKey;
        repo.emit(
          const CommunityChatEvent.connection(
            CommunityChatConnectionState.disconnected,
          ),
        );
        async.flushMicrotasks();

        _notifier(c).retry(key);
        async.flushMicrotasks();

        expect(repo.calls.where((x) => x == 'send:$key').length, 2);
        expect(
          _state(c).timeline.messages.single.status,
          CommunityChatMessageStatus.pending,
        );
      });
    });

    test('appends_older_page_when_load_older_called', () {
      fakeAsync((async) {
        final repo = FakeCommunityChatRepository()
          ..firstPage = [_text(3)]
          ..olderPage = [_text(2), _text(1)];
        final c = _opened(async, repo);
        expect(_state(c).hasNext, isTrue);

        _notifier(c).loadOlder();
        async.flushMicrotasks();

        expect(_state(c).timeline.messages.map((m) => m.id), [3, 2, 1]);
        expect(_state(c).hasNext, isFalse);
      });
    });

    test('adjusts_member_count_when_system_join_or_leave_arrives', () {
      fakeAsync((async) {
        final repo = FakeCommunityChatRepository();
        final c = _opened(async, repo);

        repo.emit(
          CommunityChatEvent.message(_system(5, CommunityChatSystemEvent.join)),
        );
        async.flushMicrotasks();
        expect(_state(c).memberCount, 9);

        repo.emit(
          CommunityChatEvent.message(
            _system(6, CommunityChatSystemEvent.leave),
          ),
        );
        async.flushMicrotasks();
        expect(_state(c).memberCount, 8);
      });
    });

    test('disconnects_only_after_leave_succeeds', () {
      fakeAsync((async) {
        final repo = FakeCommunityChatRepository();
        final c = _opened(async, repo);

        _notifier(c).leave();
        async.flushMicrotasks();

        expect(
          repo.calls.where((x) => x == 'leave' || x == 'disconnect').toList(),
          ['leave', 'disconnect'],
        );
      });
    });

    test('merges_latest_page_when_connection_is_restored', () {
      fakeAsync((async) {
        final repo = FakeCommunityChatRepository()..firstPage = [_text(1)];
        final c = _opened(async, repo);

        // 끊긴 사이 서버에 2번이 쌓였다
        repo.firstPage = [_text(2), _text(1)];
        repo.emit(
          const CommunityChatEvent.connection(
            CommunityChatConnectionState.disconnected,
          ),
        );
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 1)); // 첫 재연결 백오프
        async.flushMicrotasks();

        expect(_state(c).connection, CommunityChatConnectionState.connected);
        expect(_state(c).timeline.messages.map((m) => m.id), [2, 1]);
      });
    });

    test(
      'marks_disconnected_and_reconnects_when_stream_closes_without_event',
      () {
        fakeAsync((async) {
          final repo = FakeCommunityChatRepository();
          final c = _opened(async, repo);

          repo.controller!.close();
          async.flushMicrotasks();
          expect(
            _state(c).connection,
            CommunityChatConnectionState.disconnected,
          );

          async.elapse(const Duration(seconds: 1)); // 첫 재연결 백오프
          async.flushMicrotasks();
          expect(repo.calls.where((x) => x == 'connect').length, 2);
          expect(_state(c).connection, CommunityChatConnectionState.connected);
        });
      },
    );

    test('stops_reconnecting_after_five_failed_attempts', () {
      fakeAsync((async) {
        final repo = FakeCommunityChatRepository()
          ..connectEmitsDisconnected = true;
        final c = _opened(async, repo);

        // 1+2+4+8+10초 — 다섯 번째 시도까지 끝나고도 남는 시간
        async.elapse(const Duration(seconds: 30));

        expect(repo.calls.where((x) => x == 'connect').length, 6);
        expect(_state(c).reconnectExhausted, isTrue);
        expect(_state(c).connection, CommunityChatConnectionState.disconnected);
      });
    });

    test(
      'marks_evicted_and_stops_reconnecting_when_not_a_member_error_arrives',
      () {
        fakeAsync((async) {
          final repo = FakeCommunityChatRepository();
          final c = _opened(async, repo);

          repo.emit(const CommunityChatEvent.error('NOT_A_CHAT_MEMBER'));
          async.flushMicrotasks();
          async.elapse(const Duration(seconds: 30));

          expect(_state(c).evicted, isTrue);
          expect(repo.calls.where((x) => x == 'connect').length, 1);
        });
      },
    );

    test('keeps_receiving_messages_when_provider_is_rebuilt', () {
      fakeAsync((async) {
        final repo = FakeCommunityChatRepository();
        final c = _opened(async, repo);

        // invalidate 후에도 인스턴스는 살아남는다 — 지난 연결의 플래그를 들고
        // 가면 새 연결에서 오는 이벤트를 전부 무시하게 된다(재빌드 플래그 리셋 검증).
        // 리빌드 스케줄링은 Timer.run(Future() 생성자 내부 구현)을 타므로
        // flushMicrotasks만으로는 부족하다 — elapse(zero)로 타이머까지 흘려보낸다.
        c.invalidate(communityChatRoomNotifierProvider(_postId));
        async.elapse(Duration.zero);

        repo.emit(CommunityChatEvent.message(_text(5)));
        async.flushMicrotasks();

        expect(_state(c).timeline.messages.map((m) => m.id), [5]);
      });
    });

    test('ignores_reconnect_requests_while_a_connection_is_in_flight', () {
      // 띠의 "다시 연결"을 연타하면 붙는 중인 연결을 계속 죽이고 새로 만들어
      // 영영 못 붙는다. 게임 채널도 같은 가드를 둔다.
      fakeAsync((async) {
        final repo = FakeCommunityChatRepository()
          ..connectEmitsDisconnected = true;
        final c = _opened(async, repo);
        async.elapse(const Duration(seconds: 30));
        final before = repo.calls.where((x) => x == 'connect').length;

        _notifier(c)
          ..reconnectNow()
          ..reconnectNow()
          ..reconnectNow();
        async.flushMicrotasks();

        expect(repo.calls.where((x) => x == 'connect').length, before + 1);
      });
    });

    test('refetches_over_rest_before_reconnecting_when_the_token_expired', () {
      // 소켓만 다시 붙으면 만료된 토큰으로 계속 거절당한다. REST를 한 번 태워야
      // AuthInterceptor가 재발급하고, 그 다음 연결이 새 토큰으로 붙는다.
      fakeAsync((async) {
        final repo = FakeCommunityChatRepository();
        final c = _opened(async, repo);
        repo.calls.clear();

        repo.emit(const CommunityChatEvent.error('ACCESS_TOKEN_EXPIRED'));
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 2));

        expect(repo.calls, contains('getMessages'));
        expect(_state(c).evicted, isFalse);
      });
    });

    test('leaves_the_room_when_the_kick_system_message_names_me', () {
      // 서버는 강퇴당한 쪽 세션을 끊지 않는다(Swagger 명시) — 앱이 스스로
      // 구독을 끊지 않으면 나간 방 메시지를 계속 받는다.
      fakeAsync((async) {
        final repo = FakeCommunityChatRepository();
        final c = _opened(async, repo);
        repo.calls.clear();

        repo.emit(
          CommunityChatEvent.message(
            _system(99, CommunityChatSystemEvent.kick).copyWith(senderId: 1),
          ),
        );
        async.flushMicrotasks();

        expect(_state(c).evicted, isTrue);
        expect(repo.calls, contains('disconnect'));
      });
    });

    test('stays_in_the_room_when_someone_else_is_kicked', () {
      fakeAsync((async) {
        final repo = FakeCommunityChatRepository();
        final c = _opened(async, repo);
        repo.calls.clear();

        repo.emit(
          CommunityChatEvent.message(
            _system(99, CommunityChatSystemEvent.kick).copyWith(senderId: 7),
          ),
        );
        async.flushMicrotasks();

        expect(_state(c).evicted, isFalse);
        expect(repo.calls, isNot(contains('disconnect')));
      });
    });

    test('disconnects_when_provider_is_disposed_without_leaving', () {
      fakeAsync((async) {
        final repo = FakeCommunityChatRepository();
        // addTearDown(c.dispose)를 쓰는 _container를 그대로 쓰면 테스트 안에서
        // 또 dispose를 부를 때 이중 처리가 된다 — 이 테스트만 로컬로 만든다.
        final c = ProviderContainer(
          overrides: [
            communityChatRepositoryProvider.overrideWithValue(repo),
            currentUserIdProvider.overrideWithValue(1),
          ],
        );
        c.listen(communityChatRoomNotifierProvider(_postId), (_, _) {});
        async.flushMicrotasks();

        c.dispose();
        async.flushMicrotasks();

        expect(repo.calls, contains('disconnect'));
        expect(repo.calls, isNot(contains('leave')));
      });
    });
  });

  group('backoffDelay', () {
    test('doubles_each_attempt_and_caps_at_ten_seconds', () {
      expect(
        CommunityChatRoomNotifier.backoffDelay(1),
        const Duration(seconds: 1),
      );
      expect(
        CommunityChatRoomNotifier.backoffDelay(4),
        const Duration(seconds: 8),
      );
      expect(
        CommunityChatRoomNotifier.backoffDelay(5),
        const Duration(seconds: 10),
      );
    });
  });
}
