import 'package:cops_and_robbers/core/services/fcm/push_navigation_event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PushNavigationEvent.fromData', () {
    test('returns_game_chat_destination_for_both_scopes', () {
      for (final scope in ['ALL', 'TEAM']) {
        expect(
          PushNavigationEvent.fromData({
            'type': 'CHAT',
            'gameId': '42',
            'scope': scope,
          }),
          PushNavigationEvent.gameChat(gameId: 42, scope: scope),
        );
      }
    });

    test('rejects_invalid_game_ids_and_scopes', () {
      for (final id in [null, '', 'abc', '0', '-1', '1.5']) {
        expect(
          PushNavigationEvent.fromData({
            'type': 'CHAT',
            'gameId': id,
            'scope': 'ALL',
          }),
          isNull,
        );
      }
      for (final scope in [null, '', 'all', 'POLICE']) {
        expect(
          PushNavigationEvent.fromData({
            'type': 'CHAT',
            'gameId': '42',
            'scope': scope,
          }),
          isNull,
        );
      }
    });

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

    test('returns_community_chat_when_community_chat_push_has_post_id', () {
      // BE CommunityChatFcmNotifier: 채팅 메시지(TEXT·GAME_INVITE)와 고정 채팅
      // 변경(PIN_*)은 모두 {type, postId}로 온다 — 전부 그 글의 채팅방이 목적지다.
      for (final type in [
        'TEXT',
        'GAME_INVITE',
        'PIN_REGISTERED',
        'PIN_UPDATED',
        'PIN_DELETED',
      ]) {
        expect(
          PushNavigationEvent.fromData({'type': type, 'postId': '7'}),
          const PushNavigationEvent.communityChat(postId: 7),
          reason: type,
        );
      }
    });

    test('returns_null_when_community_chat_push_has_no_valid_post_id', () {
      expect(PushNavigationEvent.fromData({'type': 'TEXT'}), isNull);
      expect(
        PushNavigationEvent.fromData({'type': 'GAME_INVITE', 'postId': 'x'}),
        isNull,
      );
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
