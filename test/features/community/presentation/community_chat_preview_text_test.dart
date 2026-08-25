import 'package:cops_and_robbers/features/community/domain/entities/community_chat_message_entity.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_chat_room_entity.dart';
import 'package:cops_and_robbers/features/community/presentation/community_chat_preview_text.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';

CommunityChatLastMessageEntity _last(
  CommunityChatMessageBody body, {
  String? nickname,
}) => CommunityChatLastMessageEntity(
  id: 1,
  body: body,
  createdAt: DateTime(2026, 8, 24),
  senderNickname: nickname,
);

void main() {
  final l10n = lookupAppLocalizations(const Locale('ko'));

  group('chatPreviewText', () {
    test('returns_text_when_text_message', () {
      expect(
        chatPreviewText(l10n, _last(const CommunityChatMessageBody.text('안녕'))),
        '안녕',
      );
    });

    test('names_member_when_system_join_has_nickname', () {
      expect(
        chatPreviewText(
          l10n,
          _last(
            const CommunityChatMessageBody.system(
              CommunityChatSystemEvent.join,
            ),
            nickname: '도둑쥐',
          ),
        ),
        '도둑쥐님이 참여했어요',
      );
    });

    test('falls_back_to_generic_when_system_leave_has_no_nickname', () {
      expect(
        chatPreviewText(
          l10n,
          _last(
            const CommunityChatMessageBody.system(
              CommunityChatSystemEvent.leave,
            ),
          ),
        ),
        '멤버가 나갔어요',
      );
    });

    test('returns_invite_label_when_game_invite', () {
      expect(
        chatPreviewText(
          l10n,
          _last(const CommunityChatMessageBody.gameInvite('X')),
        ),
        '게임 초대',
      );
    });

    test('returns_generic_label_when_unknown', () {
      expect(
        chatPreviewText(l10n, _last(const CommunityChatMessageBody.unknown())),
        '새 메시지',
      );
    });
  });
}
