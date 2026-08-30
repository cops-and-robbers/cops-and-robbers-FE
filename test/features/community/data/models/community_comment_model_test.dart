import 'package:cops_and_robbers/features/community/data/models/community_comment_model.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _serverJson() => {
  'id': 1,
  'parentId': null,
  'writerId': 7,
  'writerNickname': '날쌘도둑',
  'writerProfileIcon': 2,
  'content': '댓글',
  'deleted': false,
  'createdAt': '2026-08-27T01:00:00+09:00',
  'updatedAt': null,
  'replies': <Map<String, dynamic>>[],
};

void main() {
  group('CommunityCommentResponseModel', () {
    test('reads_reply_notifications_enabled_when_present', () {
      final model = CommunityCommentResponseModel.fromJson(
        _serverJson()..['replyNotificationsEnabled'] = false,
      );

      expect(model.replyNotificationsEnabled, isFalse);
    });

    // 서버 기본값이 받음(true)이다. 계약에 required가 없어 키가 빠져도 댓글
    // 목록 파싱이 통째로 멈추면 안 된다.
    test('defaults_reply_notifications_to_enabled_when_the_key_is_missing', () {
      final model = CommunityCommentResponseModel.fromJson(_serverJson());

      expect(model.replyNotificationsEnabled, isTrue);
    });
  });
}
