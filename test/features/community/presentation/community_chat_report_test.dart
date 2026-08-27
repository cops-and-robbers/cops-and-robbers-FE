import 'package:cops_and_robbers/features/community/domain/entities/community_chat_message_entity.dart';
import 'package:cops_and_robbers/features/community/presentation/widgets/community_chat_message_menu.dart';
import 'package:flutter_test/flutter_test.dart';

CommunityChatMessageEntity _message({
  int? id = 1234,
  int senderId = 7,
  CommunityChatMessageBody body = const CommunityChatMessageBody.text('안녕하세요'),
  CommunityChatMessageStatus status = CommunityChatMessageStatus.sent,
}) => CommunityChatMessageEntity(
  id: id,
  messageKey: 'k1',
  senderId: senderId,
  senderNickname: '홍길동',
  body: body,
  createdAt: DateTime(2026, 8, 28, 10),
  status: status,
);

const _me = 1;

/// 어떤 말풍선을 길게 눌렀을 때 신고를 열어 줄지 — 화면이 서버 거절을 미리
/// 막는 자리다.
void main() {
  group('canReportChatMessage', () {
    test('allows_reporting_someone_elses_delivered_text', () {
      expect(canReportChatMessage(_message(), myUserId: _me), isTrue);
    });

    test('blocks_reporting_my_own_message', () {
      // 서버가 400(SELF_REPORT)으로 막는다 — 메뉴에 띄우지 않는다.
      expect(
        canReportChatMessage(_message(senderId: _me), myUserId: _me),
        isFalse,
      );
    });

    test('blocks_reporting_while_the_message_is_still_in_flight', () {
      // 아직 서버 id가 없다. 앱이 만든 messageKey를 보내면 서버가 못 찾는다
      // (404 CHAT_MESSAGE_NOT_FOUND).
      expect(
        canReportChatMessage(
          _message(id: null, status: CommunityChatMessageStatus.pending),
          myUserId: _me,
        ),
        isFalse,
      );
    });

    test('blocks_reporting_a_system_message', () {
      // 사람이 쓴 글이 아니다 — 신고할 대상이 없다.
      expect(
        canReportChatMessage(
          _message(
            body: const CommunityChatMessageBody.system(
              CommunityChatSystemEvent.join,
            ),
          ),
          myUserId: _me,
        ),
        isFalse,
      );
    });

    test('blocks_reporting_a_game_invite_card', () {
      expect(
        canReportChatMessage(
          _message(body: const CommunityChatMessageBody.gameInvite('ABC123')),
          myUserId: _me,
        ),
        isFalse,
      );
    });

    test('blocks_reporting_when_the_viewer_is_logged_out', () {
      // 로그인 없이는 내 메시지인지 가릴 수 없다 — 신고도 401이다.
      expect(canReportChatMessage(_message(), myUserId: null), isFalse);
    });
  });
}
