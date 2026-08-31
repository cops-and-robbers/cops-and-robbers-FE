import 'package:cops_and_robbers/core/errors/app_exception.dart';
import 'package:cops_and_robbers/core/services/lifecycle/lifecycle_provider.dart';
import 'package:cops_and_robbers/features/auth/presentation/providers/auth_provider.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_chat_event.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_chat_message_entity.dart';
import 'package:cops_and_robbers/features/community/presentation/providers/community_chat_room_provider.dart';
import 'package:cops_and_robbers/features/community/presentation/providers/community_chat_rooms_provider.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter/widgets.dart' show AppLifecycleState;
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
      lifecycleStateProvider.overrideWith(
        (ref) => const Stream<AppLifecycleState>.empty(),
      ),
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

        repo.emitMessage(
          pending.copyWith(id: 9, status: CommunityChatMessageStatus.sent),
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

        repo.emitMessage(_system(5, CommunityChatSystemEvent.join));
        async.flushMicrotasks();
        expect(_state(c).memberCount, 9);

        repo.emitMessage(_system(6, CommunityChatSystemEvent.leave));
        async.flushMicrotasks();
        expect(_state(c).memberCount, 8);
      });
    });

    test('unsubscribes_only_after_leave_succeeds', () {
      fakeAsync((async) {
        final repo = FakeCommunityChatRepository();
        final c = _opened(async, repo);

        _notifier(c).leave();
        async.flushMicrotasks();

        expect(
          repo.calls
              .where((x) => x == 'leave' || x.startsWith('unsubscribeRoom'))
              .toList(),
          ['leave', 'unsubscribeRoom:$_postId'],
        );
      });
    });

    test('merges_latest_page_when_connection_is_restored', () {
      // 재연결은 소켓 Notifier가 한다(1초 백오프) — 동작은 같다.
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

    test('marks_evicted_and_unsubscribes_when_not_a_member_error_arrives', () {
      fakeAsync((async) {
        final repo = FakeCommunityChatRepository();
        final c = _opened(async, repo);

        repo.emit(const CommunityChatEvent.error('NOT_A_CHAT_MEMBER'));
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 30));

        expect(_state(c).evicted, isTrue);
        expect(repo.calls, contains('unsubscribeRoom:$_postId'));
        expect(repo.calls, isNot(contains('disconnect')));
      });
    });

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

        repo.emitMessage(_text(5));
        async.flushMicrotasks();

        expect(_state(c).timeline.messages.map((m) => m.id), [5]);
      });
    });

    test('leaves_the_room_when_the_kick_system_message_names_me', () {
      // 서버는 강퇴당한 쪽 세션을 끊지 않는다(Swagger 명시) — 앱이 스스로
      // 구독을 끊지 않으면 나간 방 메시지를 계속 받는다.
      fakeAsync((async) {
        final repo = FakeCommunityChatRepository();
        final c = _opened(async, repo);
        repo.calls.clear();

        repo.emitMessage(
          _system(99, CommunityChatSystemEvent.kick).copyWith(senderId: 1),
        );
        async.flushMicrotasks();

        expect(_state(c).evicted, isTrue);
        expect(repo.calls, contains('unsubscribeRoom:$_postId'));

        // 강퇴로 밀려난 방이 배지를 단 채 목록에 남으면 안 된다 — leave()와
        // 축을 맞춰 목록도 다시 받아야 한다(최종 리뷰 I-3).
        final before = repo.calls.where((x) => x == 'getRooms').length;
        c.read(communityChatRoomsProvider.future);
        async.flushMicrotasks();
        final after = repo.calls.where((x) => x == 'getRooms').length;
        expect(after, before + 1);
      });
    });

    test('stays_in_the_room_when_someone_else_is_kicked', () {
      fakeAsync((async) {
        final repo = FakeCommunityChatRepository();
        final c = _opened(async, repo);
        repo.calls.clear();

        repo.emitMessage(
          _system(99, CommunityChatSystemEvent.kick).copyWith(senderId: 7),
        );
        async.flushMicrotasks();

        expect(_state(c).evicted, isFalse);
        expect(repo.calls, isNot(contains('disconnect')));
      });
    });

    test('unsubscribes_when_provider_is_disposed_without_leaving', () {
      fakeAsync((async) {
        final repo = FakeCommunityChatRepository();
        // addTearDown(c.dispose)를 쓰는 _container를 그대로 쓰면 테스트 안에서
        // 또 dispose를 부를 때 이중 처리가 된다 — 이 테스트만 로컬로 만든다.
        final c = ProviderContainer(
          overrides: [
            communityChatRepositoryProvider.overrideWithValue(repo),
            currentUserIdProvider.overrideWithValue(1),
            lifecycleStateProvider.overrideWith(
              (ref) => const Stream<AppLifecycleState>.empty(),
            ),
          ],
        );
        c.listen(communityChatRoomNotifierProvider(_postId), (_, _) {});
        async.flushMicrotasks();

        c.dispose();
        async.flushMicrotasks();

        expect(repo.calls, contains('unsubscribeRoom:$_postId'));
        expect(repo.calls, isNot(contains('leave')));
      });
    });

    test('subscribes_the_room_when_opened', () {
      // 해제는 기존 `unsubscribes_when_provider_is_disposed_without_leaving`가 본다.
      fakeAsync((async) {
        final repo = FakeCommunityChatRepository();
        _opened(async, repo);

        expect(repo.calls, contains('subscribeRoom:$_postId'));
        expect(repo.calls, isNot(contains('disconnect')));
      });
    });

    test('ignores_messages_addressed_to_other_rooms', () {
      // 개인 채널은 모든 방의 메시지를 한 구독으로 보낸다 — 제 방 것만 받는다.
      fakeAsync((async) {
        final repo = FakeCommunityChatRepository();
        final c = _opened(async, repo);

        repo.emitMessage(_text(9), postId: 77);
        async.flushMicrotasks();

        expect(_state(c).timeline.messages, isEmpty);
      });
    });

    test('starts_connected_when_the_socket_is_already_up', () {
      // 소켓은 로그인 때 이미 붙어 있다 — 방을 열 때 연결 이벤트가 다시 오지
      // 않으므로 소켓 상태를 씨앗으로 쓴다. 안 그러면 입력창이 영영 잠긴다.
      fakeAsync((async) {
        final repo = FakeCommunityChatRepository();
        final c = _opened(async, repo);

        expect(_state(c).connection, CommunityChatConnectionState.connected);
      });
    });

    test('marks_the_newest_message_read_when_opened', () {
      fakeAsync((async) {
        final repo = FakeCommunityChatRepository()
          ..firstPage = [_text(3), _text(2), _text(1)];
        _opened(async, repo);

        expect(repo.calls, contains('markRead:$_postId:3'));
      });
    });

    test('skips_the_read_receipt_when_the_room_is_empty', () {
      fakeAsync((async) {
        final repo = FakeCommunityChatRepository();
        _opened(async, repo);

        expect(repo.calls.where((x) => x.startsWith('markRead')), isEmpty);
      });
    });

    test('marks_read_on_exit_only_when_new_messages_arrived', () {
      fakeAsync((async) {
        final repo = FakeCommunityChatRepository()..firstPage = [_text(3)];
        final c = _opened(async, repo);

        // 아무것도 안 왔다 — 진입 때 보낸 3과 같으니 다시 보내지 않는다
        _notifier(c).markReadOnExit();
        async.flushMicrotasks();
        expect(repo.calls.where((x) => x.startsWith('markRead')).length, 1);

        repo.emitMessage(_text(4));
        async.flushMicrotasks();
        _notifier(c).markReadOnExit();
        async.flushMicrotasks();
        expect(repo.calls.last, 'markRead:$_postId:4');
      });
    });

    test('keeps_the_screen_alive_when_the_read_receipt_fails', () {
      fakeAsync((async) {
        final repo = FakeCommunityChatRepository()
          ..firstPage = [_text(3)]
          ..markReadError = const ServerException(
            message: 'read failed',
            messageKey: 'errorTemporaryRetry',
          );
        final c = _opened(async, repo);

        expect(_state(c).timeline.messages.map((m) => m.id), [3]);
      });
    });

    test(
      'clears_the_badge_as_soon_as_the_room_is_opened_regardless_of_the_read_receipt',
      () {
        // 사용자가 방을 실제로 열었다 — REST 성공 여부·dedupe와 무관하게
        // 로컬 배지부터 내린다. 서버 진실은 다음 기준선 조회가 맞춘다(최종
        // 리뷰 M-1).
        fakeAsync((async) {
          final repo = FakeCommunityChatRepository()
            ..firstPage = [_text(3)]
            ..markReadError = const ServerException(
              message: 'read failed',
              messageKey: 'errorTemporaryRetry',
            );
          repo.rooms = [repo.rooms.single.copyWith(unreadCount: 5)];
          final c = _opened(async, repo);

          expect(
            c.read(communityChatRoomsProvider).requireValue.single.unreadCount,
            0,
          );
        });
      },
    );

    test('retries_the_read_receipt_on_exit_when_the_entry_call_failed', () {
      // 진입 markRead가 실패했는데 _lastReadSent를 안 되돌리면, 이탈 때
      // 같은 id로 다시 보내는 재시도가 dedupe 가드에 막혀 서버 커서가 영영
      // 안 옮겨진다(I-3).
      fakeAsync((async) {
        final repo = FakeCommunityChatRepository()
          ..firstPage = [_text(3)]
          ..markReadError = const ServerException(
            message: 'read failed',
            messageKey: 'errorTemporaryRetry',
          );
        final c = _opened(async, repo);
        expect(repo.calls.where((x) => x == 'markRead:$_postId:3').length, 1);

        repo.markReadError = null;
        _notifier(c).markReadOnExit();
        async.flushMicrotasks();

        expect(repo.calls.where((x) => x == 'markRead:$_postId:3').length, 2);
      });
    });
  });
}
