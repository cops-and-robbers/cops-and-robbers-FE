// test/features/community/domain/community_chat_message_grouping_test.dart
import 'package:cops_and_robbers/features/community/domain/community_chat_message_grouping.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_chat_message_entity.dart';
import 'package:flutter_test/flutter_test.dart';

CommunityChatMessageEntity _text(int id, int sender, {int minute = 0}) =>
    CommunityChatMessageEntity(
      id: id,
      messageKey: 'k$id',
      senderId: sender,
      senderNickname: 'n$sender',
      body: const CommunityChatMessageBody.text('t'),
      createdAt: DateTime(2026, 8, 24, 10, minute),
    );

CommunityChatMessageEntity _system(int id) => CommunityChatMessageEntity(
  id: id,
  messageKey: 'k$id',
  senderId: 99,
  senderNickname: 'sys',
  body: const CommunityChatMessageBody.system(CommunityChatSystemEvent.join),
  createdAt: DateTime(2026, 8, 24, 10, 0),
);

void main() {
  group('groupFlagsAt', () {
    // 최신순: index 0이 화면 맨 아래
    test(
      'shows_nickname_only_on_first_and_time_only_on_last_when_same_sender',
      () {
        final list = [_text(3, 7), _text(2, 7), _text(1, 7)];

        expect(groupFlagsAt(list, 2), (showNickname: true, showTime: false));
        expect(groupFlagsAt(list, 1), (showNickname: false, showTime: false));
        expect(groupFlagsAt(list, 0), (showNickname: false, showTime: true));
      },
    );

    test('breaks_group_when_sender_changes', () {
      final list = [_text(2, 8), _text(1, 7)];

      expect(groupFlagsAt(list, 1), (showNickname: true, showTime: true));
      expect(groupFlagsAt(list, 0), (showNickname: true, showTime: true));
    });

    test('shows_time_when_minute_changes_within_same_sender', () {
      final list = [_text(2, 7, minute: 1), _text(1, 7, minute: 0)];

      expect(groupFlagsAt(list, 1).showTime, isTrue);
      expect(groupFlagsAt(list, 1).showNickname, isTrue);
      expect(groupFlagsAt(list, 0).showNickname, isFalse);
    });

    test('breaks_group_when_system_message_sits_between', () {
      final list = [_text(3, 7), _system(2), _text(1, 7)];

      expect(groupFlagsAt(list, 2).showTime, isTrue);
      expect(groupFlagsAt(list, 0).showNickname, isTrue);
    });
  });
}
