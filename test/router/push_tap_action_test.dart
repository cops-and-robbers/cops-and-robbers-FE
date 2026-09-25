import 'package:cops_and_robbers/core/services/fcm/push_navigation_event.dart';
import 'package:cops_and_robbers/router/push_tap_action.dart';
import 'package:cops_and_robbers/router/route_paths.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_app_router.dart';

const _chatPush = PushNavigationEvent.communityChat(postId: 7);
const _commentPush = PushNavigationEvent.communityPost(postId: 7);
const _gameChatPush = PushNavigationEvent.gameChat(gameId: 3, scope: 'ALL');

void main() {
  group('resolvePushTap', () {
    testWidgets(
      'opens_chat_room_when_community_chat_push_is_tapped_outside_game',
      (tester) async {
        final router = await pumpFakeAppRouter(tester);

        expect(
          resolvePushTap(_chatPush, stackOf(router)),
          isA<OpenPushRoute>().having(
            (action) => action.location,
            'location',
            RoutePaths.communityChatWithId(7),
          ),
        );
      },
    );

    testWidgets('opens_post_detail_when_comment_push_is_tapped_outside_game', (
      tester,
    ) async {
      final router = await pumpFakeAppRouter(tester);

      expect(
        resolvePushTap(_commentPush, stackOf(router)),
        isA<OpenPushRoute>().having(
          (action) => action.location,
          'location',
          RoutePaths.communityDetailWithId(7),
        ),
      );
    });

    testWidgets('blocks_community_pushes_when_tapped_during_game', (
      tester,
    ) async {
      final router = await pumpFakeAppRouter(tester);
      router.go('/game/1');
      await tester.pumpAndSettle();

      // 게임 위에 커뮤니티 화면을 얹으면 그 화면의 `go`가 GamePage를 날린다.
      for (final event in [_chatPush, _commentPush]) {
        expect(
          resolvePushTap(event, stackOf(router)),
          isA<BlockPushDuringGame>(),
          reason: '$event',
        );
      }
    });

    testWidgets('hands_game_chat_push_to_game_even_during_game', (
      tester,
    ) async {
      final router = await pumpFakeAppRouter(tester);
      router.go('/game/1');
      await tester.pumpAndSettle();

      // 인게임 채팅은 게임 안에서 여는 것이라 막지 않고 GameChatPushListener로 넘긴다.
      expect(
        resolvePushTap(_gameChatPush, stackOf(router)),
        isA<HandOffGameChatPush>().having(
          (action) => action.event,
          'event',
          _gameChatPush,
        ),
      );
    });
  });

  group('pushDestination', () {
    test('returns_screen_path_for_community_pushes', () {
      // 콜드 스타트(스플래시)도 이 경로로 간다.
      expect(pushDestination(_chatPush), RoutePaths.communityChatWithId(7));
      expect(
        pushDestination(_commentPush),
        RoutePaths.communityDetailWithId(7),
      );
    });

    test('returns_null_for_game_chat_push', () {
      // 인게임 채팅은 게임 복구 뒤 GameChatPushListener가 연다 — 경로가 없다.
      expect(pushDestination(_gameChatPush), isNull);
    });
  });
}
