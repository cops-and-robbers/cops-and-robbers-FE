import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:cops_and_robbers/features/tutorial/presentation/pages/tutorial_catalog_page.dart';

GoRouter _testRouter() {
  return GoRouter(
    initialLocation: '/tutorial',
    routes: [
      GoRoute(
        path: '/tutorial',
        builder: (_, _) => const TutorialCatalogPage(),
      ),
      GoRoute(
        path: '/tutorial/in-game',
        builder: (_, _) => const Scaffold(body: Text('IN_GAME_LANDED')),
      ),
    ],
  );
}

Widget _wrap(WidgetTester tester, GoRouter router) {
  // iPhone X 크기로 설정 — overflow 방지 및 ScreenUtil 정확도 향상
  tester.view.physicalSize = const Size(1125, 2436);
  tester.view.devicePixelRatio = 3.0;

  return ProviderScope(
    child: ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, _) => MaterialApp.router(routerConfig: router),
    ),
  );
}

void main() {
  group('TutorialCatalogPage', () {
    testWidgets('renders_4_cards_with_titles_when_built', (tester) async {
      await tester.pumpWidget(_wrap(tester, _testRouter()));
      await tester.pumpAndSettle();

      expect(find.text('방 만들기'), findsOneWidget);
      expect(find.text('방 참여하기'), findsOneWidget);
      expect(find.text('대기방'), findsOneWidget);
      expect(find.text('인게임'), findsOneWidget);
      expect(find.text('QR 체포·탈옥'), findsNothing);
    });

    testWidgets('shows_준비_중_badge_for_3_disabled_cards_when_built', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(tester, _testRouter()));
      await tester.pumpAndSettle();

      expect(find.text('준비 중'), findsNWidgets(3));
    });

    testWidgets('inGame_card_navigates_to_in_game_route_when_tapped', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(tester, _testRouter()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('인게임'));
      await tester.pumpAndSettle();

      expect(find.text('IN_GAME_LANDED'), findsOneWidget);
    });

    testWidgets('disabled_card_does_not_navigate_when_tapped', (tester) async {
      await tester.pumpWidget(_wrap(tester, _testRouter()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('방 만들기'));
      await tester.pumpAndSettle();

      expect(find.text('IN_GAME_LANDED'), findsNothing);
      expect(find.text('방 만들기'), findsOneWidget);
    });
  });
}
