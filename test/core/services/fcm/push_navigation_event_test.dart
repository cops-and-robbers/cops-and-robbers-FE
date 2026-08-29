import 'package:cops_and_robbers/core/services/fcm/push_navigation_event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PushNavigationEvent.fromData', () {
    test('returns_community_post_when_comment_push_has_post_id', () {
      // FCM data 값은 항상 문자열로 온다 — 정수 파싱이 여기서 일어나야 한다.
      final event = PushNavigationEvent.fromData({
        'type': 'COMMENT',
        'postId': '8',
      });

      expect(event, const PushNavigationEvent.communityPost(postId: 8));
    });

    test('returns_community_post_when_reply_push_has_post_id', () {
      final event = PushNavigationEvent.fromData({
        'type': 'REPLY',
        'postId': '12',
      });

      expect(event, const PushNavigationEvent.communityPost(postId: 12));
    });

    test('returns_null_when_push_type_has_no_destination', () {
      // 게임 이벤트·콘텐츠 완료 등은 이동 목적지가 없다 — 무시돼야 한다.
      expect(PushNavigationEvent.fromData({'type': 'ARREST'}), isNull);
      expect(
        PushNavigationEvent.fromData({'type': 'content_completed', 'id': 'x'}),
        isNull,
      );
      expect(PushNavigationEvent.fromData({}), isNull);
    });

    test('returns_null_when_post_id_is_missing_or_not_a_number', () {
      expect(PushNavigationEvent.fromData({'type': 'COMMENT'}), isNull);
      expect(
        PushNavigationEvent.fromData({'type': 'COMMENT', 'postId': 'abc'}),
        isNull,
      );
    });
  });
}
