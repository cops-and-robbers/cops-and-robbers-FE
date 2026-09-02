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

    test('says_kicked_not_left_when_system_kick', () {
      // 스스로 나간 것과 방장이 내보낸 것은 다른 사건이다 — 서버가 이벤트를
      // 따로 둔 이유이고, 같은 문구로 뭉개면 무슨 일이 있었는지 알 수 없다.
      expect(
        chatPreviewText(
          l10n,
          _last(
            const CommunityChatMessageBody.system(
              CommunityChatSystemEvent.kick,
            ),
            nickname: '도둑쥐',
          ),
        ),
        '도둑쥐님이 내보내졌어요',
      );
    });

    test('falls_back_to_generic_when_system_kick_has_no_nickname', () {
      expect(
        chatPreviewText(
          l10n,
          _last(
            const CommunityChatMessageBody.system(
              CommunityChatSystemEvent.kick,
            ),
          ),
        ),
        '멤버가 내보내졌어요',
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

    test('says_pin_registered_not_left_when_system_pin_registered', () {
      // 시스템 이벤트 폴백이 "나갔어요"라 새 이벤트가 조용히 퇴장으로 읽힌다 —
      // 아무도 나가지 않았는데 목록에 "나갔어요"가 뜬다.
      expect(
        chatPreviewText(
          l10n,
          _last(
            const CommunityChatMessageBody.system(
              CommunityChatSystemEvent.pinRegistered,
            ),
            nickname: '도둑쥐',
          ),
        ),
        '도둑쥐님이 공지를 등록했어요',
      );
    });

    test('falls_back_to_generic_when_system_pin_deleted_has_no_nickname', () {
      expect(
        chatPreviewText(
          l10n,
          _last(
            const CommunityChatMessageBody.system(
              CommunityChatSystemEvent.pinDeleted,
            ),
          ),
        ),
        '공지가 삭제됐어요',
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
