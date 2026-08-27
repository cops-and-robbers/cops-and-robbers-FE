// test/features/community/domain/community_chat_timeline_test.dart
import 'package:cops_and_robbers/features/community/domain/community_chat_timeline.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_chat_message_entity.dart';
import 'package:flutter_test/flutter_test.dart';

CommunityChatMessageEntity _msg({
  int? id,
  String key = 'k',
  int senderId = 7,
  CommunityChatMessageBody body = const CommunityChatMessageBody.text('hi'),
  CommunityChatMessageStatus status = CommunityChatMessageStatus.sent,
}) => CommunityChatMessageEntity(
  id: id,
  messageKey: key,
  senderId: senderId,
  senderNickname: 'n$senderId',
  body: body,
  createdAt: DateTime(2026, 8, 24, 10, 0),
  status: status,
);

void main() {
  group('CommunityChatTimeline', () {
    test('prepends_incoming_message_when_new', () {
      final t = const CommunityChatTimeline.empty()
          .receive(_msg(id: 1, key: 'a'))
          .receive(_msg(id: 2, key: 'b'));

      expect(t.messages.map((m) => m.id), [2, 1]);
    });

    test('drops_incoming_message_when_same_id_already_present', () {
      final t = CommunityChatTimeline([
        _msg(id: 1, key: 'a'),
      ]).receive(_msg(id: 1, key: 'a'));

      expect(t.messages.length, 1);
    });

    test('confirms_pending_message_when_echo_has_same_key', () {
      final pending = _msg(
        key: 'mine',
        senderId: 1,
        status: CommunityChatMessageStatus.pending,
      );
      final t = const CommunityChatTimeline.empty()
          .addPending(pending)
          .receive(_msg(id: 9, key: 'mine', senderId: 1));

      expect(t.messages.length, 1);
      expect(t.messages.single.id, 9);
      expect(t.messages.single.status, CommunityChatMessageStatus.sent);
    });

    test('appends_older_page_after_existing_without_duplicates', () {
      final t = CommunityChatTimeline([
        _msg(id: 5, key: 'e'),
        _msg(id: 4, key: 'd'),
      ]).appendOlder([_msg(id: 4, key: 'd'), _msg(id: 3, key: 'c')]);

      expect(t.messages.map((m) => m.id), [5, 4, 3]);
    });

    test('merges_latest_page_keeping_newest_first_when_reconnected', () {
      final t = CommunityChatTimeline([_msg(id: 3, key: 'c')]).mergeLatest([
        _msg(id: 5, key: 'e'),
        _msg(id: 4, key: 'd'),
        _msg(id: 3, key: 'c'),
      ]);

      expect(t.messages.map((m) => m.id), [5, 4, 3]);
    });

    test('marks_every_pending_message_failed_when_connection_drops', () {
      final t = const CommunityChatTimeline.empty()
          .addPending(
            _msg(key: 'p1', status: CommunityChatMessageStatus.pending),
          )
          .receive(_msg(id: 1, key: 'x'))
          .failAllPending();

      expect(
        t.messages.firstWhere((m) => m.messageKey == 'p1').status,
        CommunityChatMessageStatus.failed,
      );
      expect(
        t.messages.firstWhere((m) => m.id == 1).status,
        CommunityChatMessageStatus.sent,
      );
    });

    test('restores_pending_status_when_failed_message_is_retried', () {
      final t = const CommunityChatTimeline.empty()
          .addPending(
            _msg(key: 'p1', status: CommunityChatMessageStatus.failed),
          )
          .setStatus('p1', CommunityChatMessageStatus.pending);

      expect(t.messages.single.status, CommunityChatMessageStatus.pending);
    });
  });

  group('memberDelta', () {
    test('returns_plus_one_when_system_join', () {
      expect(
        memberDelta(
          _msg(
            body: const CommunityChatMessageBody.system(
              CommunityChatSystemEvent.join,
            ),
          ),
        ),
        1,
      );
    });
    test('returns_minus_one_when_system_leave', () {
      expect(
        memberDelta(
          _msg(
            body: const CommunityChatMessageBody.system(
              CommunityChatSystemEvent.leave,
            ),
          ),
        ),
        -1,
      );
    });
    test('returns_minus_one_when_system_kick', () {
      // 강퇴도 사람이 줄어든다 — 0으로 두면 헤더 인원수가 실제와 어긋난다.
      expect(
        memberDelta(
          _msg(
            body: const CommunityChatMessageBody.system(
              CommunityChatSystemEvent.kick,
            ),
          ),
        ),
        -1,
      );
    });
    test('returns_zero_when_text', () {
      expect(memberDelta(_msg()), 0);
    });
  });
}
