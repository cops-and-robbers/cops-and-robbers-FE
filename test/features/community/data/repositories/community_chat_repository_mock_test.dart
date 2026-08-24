import 'package:cops_and_robbers/features/community/data/repositories/community_chat_repository_mock.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_chat_event.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_chat_message_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const postId = CommunityChatRepositoryMock.seededPostId;

  CommunityChatRepositoryMock mock() => CommunityChatRepositoryMock(
    myUserId: 1,
    latency: Duration.zero,
    echoDelay: Duration.zero,
  );

  group('CommunityChatRepositoryMock', () {
    test('echoes_sent_message_with_same_key_and_server_id', () async {
      final repo = mock();
      final events = <CommunityChatEvent>[];
      final sub = repo.connect(postId).listen(events.add);

      await repo.send(postId, messageKey: 'key-1', text: '안녕');
      await Future<void>.delayed(Duration.zero);

      final echoed = events
          .whereType<CommunityChatMessageEvent>()
          .map((e) => e.message)
          .firstWhere((m) => m.messageKey == 'key-1');
      expect(echoed.id, isNotNull);
      expect(echoed.senderId, 1);
      expect(echoed.status, CommunityChatMessageStatus.sent);
      await sub.cancel();
    });

    test('removes_room_from_list_when_left', () async {
      final repo = mock();
      expect((await repo.getRooms()).map((r) => r.postId), contains(postId));

      await repo.leave(postId);

      expect(
        (await repo.getRooms()).map((r) => r.postId),
        isNot(contains(postId)),
      );
    });

    test('creates_room_for_unknown_post_when_joined', () async {
      final repo = mock();

      await repo.join(777);

      final room = (await repo.getRooms()).firstWhere((r) => r.postId == 777);
      expect(room.memberCount, 2); // 작성자 + 나
    });

    test('pages_backwards_with_cursor_until_has_next_is_false', () async {
      final repo = mock();
      final first = await repo.getMessages(postId, size: 30);
      expect(first.hasNext, isTrue);

      final second = await repo.getMessages(
        postId,
        cursor: first.nextCursor,
        size: 30,
      );
      expect(second.messages.first.id, lessThan(first.messages.last.id!));
      expect(second.hasNext, isFalse);
    });
  });
}
