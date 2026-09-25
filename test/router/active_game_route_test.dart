import 'package:cops_and_robbers/router/active_game_route.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_app_router.dart';

void main() {
  group('isInGameFlow', () {
    testWidgets('detects_game_flow_when_only_game_screen_is_open', (
      tester,
    ) async {
      final router = await pumpFakeAppRouter(tester);
      router.go('/game/1');
      await tester.pumpAndSettle();

      expect(isInGameFlow(stackOf(router)), isTrue);
    });

    testWidgets('detects_game_flow_when_another_screen_is_pushed_over_game', (
      tester,
    ) async {
      final router = await pumpFakeAppRouter(tester);
      router.go('/game/1');
      await tester.pumpAndSettle();
      // 게임에서 신고 화면 등을 띄우면 맨 위는 게임이 아니다 — 아래에 게임이
      // 살아 있으면 여전히 게임 중이다.
      router.push('/report');
      await tester.pumpAndSettle();

      expect(isInGameFlow(stackOf(router)), isTrue);
    });

    testWidgets('detects_game_flow_when_waiting_room_sub_screen_is_open', (
      tester,
    ) async {
      final router = await pumpFakeAppRouter(tester);
      router.go('/waiting-room/1/game-settings');
      await tester.pumpAndSettle();

      expect(isInGameFlow(stackOf(router)), isTrue);
    });

    testWidgets('does_not_detect_game_flow_when_only_main_screens_are_open', (
      tester,
    ) async {
      final router = await pumpFakeAppRouter(tester);
      router.push('/community/2');
      await tester.pumpAndSettle();

      expect(isInGameFlow(stackOf(router)), isFalse);
    });
  });
}
