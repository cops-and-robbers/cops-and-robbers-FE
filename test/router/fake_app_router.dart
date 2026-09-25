import 'package:cops_and_robbers/router/route_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// 앱 라우터(`app_router.dart`)와 같은 모양만 흉내 낸 라우터 — 화면은 판정과
/// 무관해 빈 위젯이다. 실제 라우터는 GamePage 등 무거운 페이지를 만들어 쓸 수 없다.
///
/// - 탭은 `StatefulShellRoute.indexedStack`, 커뮤니티 상세·채팅방은 셸 안에
///   정의되지만 루트 네비게이터에 뜬다(`parentNavigatorKey`).
/// - 게임·대기실·신고는 셸 밖 최상위 라우트이고, 앱은 게임·대기실에 항상
///   `go`로 들어간다.
Future<GoRouter> pumpFakeAppRouter(WidgetTester tester) async {
  final rootKey = GlobalKey<NavigatorState>();
  Widget page(BuildContext _, GoRouterState _) => const SizedBox();
  final router = GoRouter(
    navigatorKey: rootKey,
    initialLocation: RoutePaths.home,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (_, _, navigationShell) => navigationShell,
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: RoutePaths.home, builder: page)],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.community,
                builder: page,
                routes: [
                  GoRoute(
                    path: ':postId',
                    parentNavigatorKey: rootKey,
                    builder: page,
                    routes: [
                      GoRoute(
                        path: 'chat',
                        parentNavigatorKey: rootKey,
                        builder: page,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(path: RoutePaths.report, builder: page),
      GoRoute(path: RoutePaths.game, name: RoutePaths.gameName, builder: page),
      GoRoute(
        path: RoutePaths.waitingRoom,
        name: RoutePaths.waitingRoomName,
        builder: page,
        routes: [GoRoute(path: 'game-settings', builder: page)],
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  return router;
}

/// 라우터가 지금 들고 있는 화면 스택.
RouteMatchList stackOf(GoRouter router) =>
    router.routerDelegate.currentConfiguration;
