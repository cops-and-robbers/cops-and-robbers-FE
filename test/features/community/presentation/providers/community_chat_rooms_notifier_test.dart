import 'dart:async';

import 'package:cops_and_robbers/core/services/lifecycle/lifecycle_provider.dart';
import 'package:cops_and_robbers/features/auth/presentation/providers/auth_provider.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_chat_event.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_chat_message_entity.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_chat_room_entity.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_post_status.dart';
import 'package:cops_and_robbers/features/community/presentation/providers/community_chat_rooms_provider.dart';
import 'package:flutter/widgets.dart' show AppLifecycleState;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../community_chat_fakes.dart';

int _fetches(FakeCommunityChatRepository repo) =>
    repo.calls.where((x) => x == 'getRooms').length;

CommunityChatRoomEntity _room(int id, {int unread = 0, int? lastId}) =>
    CommunityChatRoomEntity(
      postId: id,
      title: '방 $id',
      status: CommunityPostStatus.recruiting,
      meetingAt: DateTime(2026, 9, 1),
      memberCount: 5,
      unreadCount: unread,
      lastMessage: lastId == null
          ? null
          : CommunityChatLastMessageEntity(
              id: lastId,
              body: const CommunityChatMessageBody.text('이전 말'),
              createdAt: DateTime(2026, 8, 30),
            ),
    );

CommunityChatMessageEntity _msg(
  int id, {
  int sender = 7,
  CommunityChatMessageBody body = const CommunityChatMessageBody.text('새 말'),
  bool isSystem = false,
}) => CommunityChatMessageEntity(
  id: id,
  messageKey: 'k$id',
  senderId: sender,
  senderNickname: 'n$sender',
  body: body,
  createdAt: DateTime(2026, 8, 31, 10, id),
  isSystem: isSystem,
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

List<CommunityChatRoomEntity> _rooms(ProviderContainer c) =>
    c.read(communityChatRoomsProvider).requireValue;

Future<ProviderContainer> _loaded(FakeCommunityChatRepository repo) async {
  final c = _container(repo);
  await c.read(communityChatRoomsProvider.future);
  await Future<void>.delayed(Duration.zero); // 소켓 connected 이벤트 소화
  repo.calls.clear();
  return c;
}

void main() {
  group('CommunityChatRooms unread', () {
    test('increments_unread_when_someone_else_talks_in_another_room', () async {
      final repo = FakeCommunityChatRepository()
        ..rooms = [_room(1, unread: 2, lastId: 10), _room(2)];
      final c = await _loaded(repo);

      repo.emitMessage(_msg(11), postId: 1);
      await Future<void>.delayed(Duration.zero);

      expect(_rooms(c).first.postId, 1);
      expect(_rooms(c).first.unreadCount, 3);
      expect(_rooms(c).first.lastMessage?.id, 11);
    });

    test('moves_the_room_to_the_top_when_a_message_arrives', () async {
      final repo = FakeCommunityChatRepository()
        ..rooms = [_room(1, lastId: 10), _room(2, lastId: 9)];
      final c = await _loaded(repo);

      repo.emitMessage(_msg(11), postId: 2);
      await Future<void>.delayed(Duration.zero);

      expect(_rooms(c).map((r) => r.postId), [2, 1]);
    });

    test('does_not_count_my_own_message', () async {
      // 개인 채널은 발신자 본인에게도 온다 — 안 거르면 내가 보낼 때마다 내 배지가 오른다.
      final repo = FakeCommunityChatRepository()
        ..rooms = [_room(1, lastId: 10)];
      final c = await _loaded(repo);

      repo.emitMessage(_msg(11, sender: 1), postId: 1);
      await Future<void>.delayed(Duration.zero);

      expect(_rooms(c).single.unreadCount, 0);
      expect(_rooms(c).single.lastMessage?.id, 11); // 미리보기는 바뀐다
    });

    test('does_not_count_system_messages', () async {
      final repo = FakeCommunityChatRepository()
        ..rooms = [_room(1, lastId: 10)];
      final c = await _loaded(repo);

      repo.emitMessage(
        _msg(
          11,
          body: const CommunityChatMessageBody.system(
            CommunityChatSystemEvent.join,
          ),
          isSystem: true,
        ),
        postId: 1,
      );
      // 모르는 시스템 이벤트는 unknown 본문으로 접히지만 와이어 타입은 SYSTEM이다
      repo.emitMessage(
        _msg(
          12,
          body: const CommunityChatMessageBody.unknown(),
          isSystem: true,
        ),
        postId: 1,
      );
      await Future<void>.delayed(Duration.zero);

      expect(_rooms(c).single.unreadCount, 0);
    });

    test('counts_game_invites', () async {
      final repo = FakeCommunityChatRepository()
        ..rooms = [_room(1, lastId: 10)];
      final c = await _loaded(repo);

      repo.emitMessage(
        _msg(11, body: const CommunityChatMessageBody.gameInvite('ABC123')),
        postId: 1,
      );
      await Future<void>.delayed(Duration.zero);

      expect(_rooms(c).single.unreadCount, 1);
    });

    test(
      'counts_the_same_message_once_when_both_channels_deliver_it',
      () async {
        // 방 화면에 있는 동안 방 채널과 개인 채널이 같은 메시지를 두 번 보낸다.
        final repo = FakeCommunityChatRepository()
          ..rooms = [_room(1, lastId: 10)];
        final c = await _loaded(repo);

        repo.emitMessage(_msg(11), postId: 1);
        repo.emitMessage(_msg(11), postId: 1);
        await Future<void>.delayed(Duration.zero);

        expect(_rooms(c).single.unreadCount, 1);
      },
    );

    test('ignores_a_message_older_than_the_baseline', () async {
      // 기준선(refresh)에 이미 반영된 메시지가 소켓으로 뒤늦게 오는 경우
      final repo = FakeCommunityChatRepository()
        ..rooms = [_room(1, unread: 1, lastId: 10)];
      final c = await _loaded(repo);

      repo.emitMessage(_msg(10), postId: 1);
      await Future<void>.delayed(Duration.zero);

      expect(_rooms(c).single.unreadCount, 1);
    });

    test('leaves_the_list_alone_when_the_room_is_not_cached_yet', () async {
      final repo = FakeCommunityChatRepository()..rooms = [_room(1)];
      final c = await _loaded(repo);

      repo.emitMessage(_msg(11), postId: 99);
      await Future<void>.delayed(Duration.zero);

      expect(_rooms(c).map((r) => r.postId), [1]);
    });

    test('clears_unread_for_a_room', () async {
      final repo = FakeCommunityChatRepository()..rooms = [_room(1, unread: 4)];
      final c = await _loaded(repo);

      c.read(communityChatRoomsProvider.notifier).clearUnread(1);

      expect(_rooms(c).single.unreadCount, 0);
    });
  });

  group('CommunityChatRooms baseline', () {
    test('refetches_the_baseline_when_the_socket_reconnects', () async {
      // 끊긴 동안 소켓으로 못 받은 +1은 서버 집계가 메운다.
      final repo = FakeCommunityChatRepository()..rooms = [_room(1)];
      final c = await _loaded(repo);

      repo.emit(
        const CommunityChatEvent.connection(
          CommunityChatConnectionState.disconnected,
        ),
      );
      repo.emit(
        const CommunityChatEvent.connection(
          CommunityChatConnectionState.connected,
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(_fetches(repo), 1);
      expect(_rooms(c).single.postId, 1);
    });

    test(
      'resyncs_once_when_the_baseline_was_fetched_before_the_first_connect',
      () async {
        // 소켓이 아직 안 붙은 채로(connecting) build()가 시작되므로 _needResync는
        // true로 출발한다. 가짜 저장소 구조상(연결 스트림 → 소켓 Notifier의
        // events, 2홉) 첫 connected는 getRooms() 응답보다 항상 늦게 도착한다
        // (구현 중 실측·재현) — 그래서 도착 시점엔 이미 첫 로드가 끝나 있고,
        // "다음 connected에서 한 번 맞춘다" 규칙대로 재조회가 한 번 더 나간다.
        final repo = FakeCommunityChatRepository();
        final c = _container(repo);
        await c.read(communityChatRoomsProvider.future);
        await Future<void>.delayed(Duration.zero);

        expect(_fetches(repo), 2);
      },
    );

    test(
      'resyncs_after_reconnect_even_when_the_provider_was_rebuilt',
      () async {
        // REST 에러 재시도(ref.invalidate) 같은 재빌드는 재연결이 아니다 —
        // 소켓이 이미 붙어 있으면 재빌드가 이중 조회를 만들면 안 되고, 그 뒤에
        // 진짜 재연결이 오면 기준선을 다시 받아야 한다.
        final repo = FakeCommunityChatRepository()..rooms = [_room(1)];
        final c = await _loaded(repo); // 소켓 connected 상태, calls 비움

        c.invalidate(communityChatRoomsProvider);
        await c.read(communityChatRoomsProvider.future);
        await Future<void>.delayed(Duration.zero);
        expect(_fetches(repo), 1); // 재빌드 자체의 조회 1건뿐 — 이중 fetch 없음
        repo.calls.clear();

        repo.emit(
          const CommunityChatEvent.connection(
            CommunityChatConnectionState.disconnected,
          ),
        );
        repo.emit(
          const CommunityChatEvent.connection(
            CommunityChatConnectionState.connected,
          ),
        );
        await Future<void>.delayed(Duration.zero);

        expect(_fetches(repo), 1); // 진짜 재연결이니 기준선을 다시 받는다
      },
    );

    test(
      'resyncs_after_the_first_load_when_connected_arrives_mid_load',
      () async {
        // 첫 로드(GET)가 개인 채널 구독 확립보다 먼저 나간 경우(로그인 직후
        // 탭 진입) connected가 로드 도중에 온다 — 버리지 않고 로드가 끝난
        // 뒤로 미뤄 다시 받아야 그 창의 +1이 영구 누락되지 않는다(스펙 §3-5 ③).
        final gate = Completer<void>();
        final repo = FakeCommunityChatRepository()
          ..rooms = [_room(1)]
          ..roomsGate = gate.future;
        final c = _container(repo);

        final future = c.read(communityChatRoomsProvider.future);
        await Future<void>.delayed(Duration.zero); // 소켓 connected가 로드 도중 도착

        gate.complete();
        await future;
        await Future<void>.delayed(Duration.zero); // 미뤄둔 재동기화 완료

        expect(_fetches(repo), 2); // 기준선 1 + 미뤄진 재동기화 1
      },
    );
  });

  group('CommunityChatRooms account switch', () {
    // 소켓 Notifier가 유저 전환 시 이전 구독을 먼저 끊어 disconnected 이벤트가
    // 이 목록에 도달하지 않는다 — 목록 자신이 currentUserIdProvider를 watch해
    // 다시 판다(최종 리뷰 C-1). 로그인 상태를 테스트가 바꿔야 하므로 이 그룹만
    // StateProvider 경유 하네스를 쓴다(소켓 테스트의 `_userIdProvider` 패턴).
    ({ProviderContainer container, StateProvider<int?> userId}) switchable(
      FakeCommunityChatRepository repo,
    ) {
      final userIdProvider = StateProvider<int?>((_) => 1);
      final c = ProviderContainer(
        overrides: [
          communityChatRepositoryProvider.overrideWithValue(repo),
          currentUserIdProvider.overrideWith(
            (ref) => ref.watch(userIdProvider),
          ),
          lifecycleStateProvider.overrideWith(
            (ref) => const Stream<AppLifecycleState>.empty(),
          ),
        ],
      );
      addTearDown(c.dispose);
      return (container: c, userId: userIdProvider);
    }

    test(
      'reloads_the_list_for_the_new_user_when_the_account_switches',
      () async {
        final repo = FakeCommunityChatRepository()..rooms = [_room(1)];
        final (:container, :userId) = switchable(repo);
        container.listen(communityChatRoomsProvider, (_, _) {});
        await container.read(communityChatRoomsProvider.future);
        await Future<void>.delayed(Duration.zero);
        repo.calls.clear();

        repo.rooms = [_room(2)];
        container.read(userId.notifier).state = 2;
        await Future<void>.delayed(Duration.zero);
        final rooms = await container.read(communityChatRoomsProvider.future);

        expect(repo.calls, contains('getRooms'));
        expect(rooms.single.postId, 2);
      },
    );

    test('empties_the_list_when_the_user_logs_out', () async {
      final repo = FakeCommunityChatRepository()..rooms = [_room(1)];
      final (:container, :userId) = switchable(repo);
      container.listen(communityChatRoomsProvider, (_, _) {});
      await container.read(communityChatRoomsProvider.future);
      await Future<void>.delayed(Duration.zero);

      container.read(userId.notifier).state = null;
      await Future<void>.delayed(Duration.zero);
      final rooms = await container.read(communityChatRoomsProvider.future);

      expect(rooms, isEmpty);
    });
  });
}
