import 'dart:async';

import 'package:cops_and_robbers/core/services/remote_config/maintenance_gate.dart';
import 'package:cops_and_robbers/router/route_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('maintenanceRedirect', () {
    String? on(List<String> stack) =>
        maintenanceRedirect(stack: stack, underMaintenance: true);
    String? off(List<String> stack) =>
        maintenanceRedirect(stack: stack, underMaintenance: false);

    test('sends_other_screens_to_the_maintenance_page', () {
      expect(on([RoutePaths.home]), RoutePaths.maintenance);
      expect(on([RoutePaths.login]), RoutePaths.maintenance);
      expect(on([RoutePaths.forceUpdate]), RoutePaths.maintenance);
      expect(on(['/waiting-room/abc']), RoutePaths.maintenance);
      expect(on(['/community/12']), RoutePaths.maintenance);
      expect(on(['/community/12/chat']), RoutePaths.maintenance);
      expect(on([RoutePaths.home, '/community/12']), RoutePaths.maintenance);
    });

    test('leaves_splash_game_and_maintenance_alone', () {
      expect(on([RoutePaths.splash]), isNull);
      expect(on([RoutePaths.maintenance]), isNull);
      expect(on([RoutePaths.gameWithId('abc')]), isNull);
    });

    test('leaves_writing_screens_alone', () {
      expect(on([RoutePaths.communityCreate]), isNull);
      expect(on(['/community/12/edit']), isNull);
      expect(on(['/community/12/chat/notice/edit']), isNull);
      expect(on([RoutePaths.bugReport]), isNull);
      expect(on([RoutePaths.reportReason]), isNull);
    });

    test('a_screen_on_top_of_a_game_or_writing_keeps_them_alive', () {
      expect(on([RoutePaths.gameWithId('abc'), RoutePaths.report]), isNull);
      expect(on([RoutePaths.communityCreate, '/community/12']), isNull);
    });

    test('a_path_only_starting_with_game_is_not_a_game', () {
      expect(on(['/game-history']), RoutePaths.maintenance);
    });

    test('returns_to_splash_only_from_the_maintenance_page', () {
      expect(off([RoutePaths.maintenance]), RoutePaths.splash);
      expect(off([RoutePaths.home]), isNull);
      expect(off([RoutePaths.splash]), isNull);
      expect(off([RoutePaths.gameWithId('abc')]), isNull);
    });
  });

  group('MaintenanceGuard', () {
    late StreamController<void> updates;
    late GoRouter router;
    late bool maintenance;
    late int writingNotices;

    Future<void> publish(WidgetTester tester, {required bool on}) async {
      maintenance = on;
      updates.add(null);
      await tester.pumpAndSettle();
    }

    Future<void> pumpRouter(
      WidgetTester tester,
      String initial, {
      bool startUnderMaintenance = false,
    }) async {
      maintenance = startUnderMaintenance;
      writingNotices = 0;
      updates = StreamController<void>();
      Widget page(String name) => Scaffold(body: Text(name));
      router = GoRouter(
        initialLocation: initial,
        routes: [
          GoRoute(path: RoutePaths.splash, builder: (_, _) => page('splash')),
          GoRoute(
            path: RoutePaths.maintenance,
            builder: (_, _) => page('maintenance'),
          ),
          GoRoute(path: RoutePaths.game, builder: (_, _) => page('game')),
          GoRoute(
            path: RoutePaths.report,
            builder: (_, state) => page('report:${state.extra}'),
          ),
          StatefulShellRoute.indexedStack(
            builder: (_, _, shell) => shell,
            branches: [
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: RoutePaths.home,
                    builder: (_, _) => page('home'),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: RoutePaths.community,
                    builder: (_, _) => page('community'),
                    routes: [
                      GoRoute(
                        path: 'create',
                        builder: (_, _) => page('create'),
                      ),
                      GoRoute(
                        path: ':postId',
                        builder: (_, state) => page('detail:${state.extra}'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      );
      final guard = MaintenanceGuard(
        router: router,
        updates: updates.stream,
        isUnderMaintenance: () => maintenance,
        onWritingInterrupted: () => writingNotices++,
      );
      addTearDown(() async {
        guard.dispose();
        router.dispose();
        await updates.close();
      });
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
    }

    testWidgets('moves_a_running_app_to_maintenance_and_back_to_splash', (
      tester,
    ) async {
      await pumpRouter(tester, RoutePaths.home);
      expect(find.text('home'), findsOneWidget);

      await publish(tester, on: true);
      expect(find.text('maintenance'), findsOneWidget);

      await publish(tester, on: false);
      expect(find.text('splash'), findsOneWidget);
    });

    testWidgets('releases_a_user_who_entered_maintenance_from_saved_values', (
      tester,
    ) async {
      await pumpRouter(tester, RoutePaths.splash, startUnderMaintenance: true);
      router.go(RoutePaths.maintenance);
      await tester.pumpAndSettle();
      expect(find.text('maintenance'), findsOneWidget);

      await publish(tester, on: false);
      expect(find.text('splash'), findsOneWidget);
    });

    testWidgets('a_pushed_screen_leaves_no_way_back_past_maintenance', (
      tester,
    ) async {
      await pumpRouter(tester, RoutePaths.home);
      unawaited(router.push('/community/12'));
      await tester.pumpAndSettle();

      await publish(tester, on: true);

      expect(find.text('maintenance'), findsOneWidget);
      expect(router.canPop(), isFalse);
    });

    testWidgets('an_update_without_maintenance_keeps_extra_and_results', (
      tester,
    ) async {
      await pumpRouter(tester, RoutePaths.home);
      final result = router.push<String>('/community/12', extra: Object());
      await tester.pumpAndSettle();
      expect(find.text('detail:Instance of \'Object\''), findsOneWidget);

      await publish(tester, on: false);
      await publish(tester, on: false);

      expect(find.text('detail:Instance of \'Object\''), findsOneWidget);
      router.pop('done');
      await tester.pumpAndSettle();
      expect(await result, 'done');
    });

    testWidgets('does_not_interrupt_a_game_but_blocks_when_leaving_it', (
      tester,
    ) async {
      await pumpRouter(tester, RoutePaths.gameWithId('abc'));

      await publish(tester, on: true);
      expect(find.text('game'), findsOneWidget);
      expect(writingNotices, 0);

      router.go(RoutePaths.home);
      await tester.pumpAndSettle();
      expect(find.text('maintenance'), findsOneWidget);
    });

    testWidgets('a_report_opened_during_a_game_keeps_the_game_and_its_extra', (
      tester,
    ) async {
      await pumpRouter(tester, RoutePaths.gameWithId('abc'));
      await publish(tester, on: true);

      final result = router.push<String>(RoutePaths.report, extra: 'args');
      await tester.pumpAndSettle();
      expect(find.text('report:args'), findsOneWidget);

      await publish(tester, on: true);
      expect(find.text('report:args'), findsOneWidget);

      router.pop('sent');
      await tester.pumpAndSettle();
      expect(await result, 'sent');
      expect(find.text('game'), findsOneWidget);
    });

    testWidgets('keeps_a_writer_on_the_page_and_tells_them_once', (
      tester,
    ) async {
      await pumpRouter(tester, RoutePaths.home);
      unawaited(router.push(RoutePaths.communityCreate));
      await tester.pumpAndSettle();

      await publish(tester, on: true);
      expect(find.text('create'), findsOneWidget);
      expect(writingNotices, 1);

      await publish(tester, on: true);
      expect(writingNotices, 1);
    });

    testWidgets('blocks_a_writer_when_they_go_back', (tester) async {
      await pumpRouter(tester, RoutePaths.home);
      unawaited(router.push(RoutePaths.communityCreate));
      await tester.pumpAndSettle();
      await publish(tester, on: true);

      router.pop();
      await tester.pumpAndSettle();

      expect(find.text('maintenance'), findsOneWidget);
      expect(router.canPop(), isFalse);
    });

    testWidgets('a_writer_who_opens_during_maintenance_is_told', (
      tester,
    ) async {
      await pumpRouter(tester, RoutePaths.gameWithId('abc'));
      await publish(tester, on: true);

      router.go(RoutePaths.communityCreate);
      await tester.pumpAndSettle();

      expect(find.text('create'), findsOneWidget);
      expect(writingNotices, 1);
    });

    testWidgets('nothing_moves_after_maintenance_ends_mid_writing', (
      tester,
    ) async {
      await pumpRouter(tester, RoutePaths.home);
      unawaited(router.push(RoutePaths.communityCreate));
      await tester.pumpAndSettle();
      await publish(tester, on: true);

      await publish(tester, on: false);
      expect(find.text('create'), findsOneWidget);

      router.pop();
      await tester.pumpAndSettle();
      expect(find.text('home'), findsOneWidget);
    });
  });
}
