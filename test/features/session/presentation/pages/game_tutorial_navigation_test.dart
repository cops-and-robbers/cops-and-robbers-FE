import 'package:cops_and_robbers/core/services/storage/tutorial_prefs.dart';
import 'package:cops_and_robbers/core/widgets/tutorial/tutorial_script.dart';
import 'package:cops_and_robbers/features/session/presentation/pages/game_tutorial_page.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 대기방과 같은 구조: 튜토리얼은 대기방 위에 push 되고, 대기방 이벤트는 context.go 로 나간다.
GoRouter _router() => GoRouter(
  initialLocation: '/room',
  routes: [
    GoRoute(
      path: '/room',
      builder: (context, state) => const Scaffold(body: Text('대기방')),
      routes: [
        GoRoute(
          path: 'tutorial',
          builder: (context, state) => const GameTutorialPage(
            mode: TutorialMode.classic,
            tiltStream: _noTilt,
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/game',
      builder: (context, state) => const Scaffold(body: Text('게임')),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const Scaffold(body: Text('홈')),
    ),
  ],
);

Stream<Offset> _noTilt() => const Stream.empty();

Future<GoRouter> _openTutorial(WidgetTester tester) async {
  tester.view.physicalSize = const Size(393, 852) * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final router = _router();
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(393, 852),
      builder: (context, _) => MaterialApp.router(
        routerConfig: router,
        locale: const Locale('ko'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  await tester.pump();
  router.push('/room/tutorial');
  for (var i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 32));
  }
  expect(find.byType(GameTutorialPage), findsOneWidget);
  return router;
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 30; i++) {
    await tester.pump(const Duration(milliseconds: 32));
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets(
    'tutorial_disappears_and_stays_closed_next_entry_when_host_starts_game_while_watching',
    (tester) async {
      final router = await _openTutorial(tester);

      router.go('/game');
      await _settle(tester);

      expect(find.text('게임'), findsOneWidget);
      expect(find.byType(GameTutorialPage), findsNothing);
      expect(await TutorialPrefs.seen(TutorialMode.classic), isTrue);
    },
  );

  testWidgets(
    'tutorial_disappears_and_stays_closed_next_entry_when_player_is_kicked_while_watching',
    (tester) async {
      final router = await _openTutorial(tester);

      router.go('/home');
      await _settle(tester);

      expect(find.text('홈'), findsOneWidget);
      expect(await TutorialPrefs.seen(TutorialMode.classic), isTrue);
    },
  );

  testWidgets('tutorial_hides_skip_when_player_watches_it_for_the_first_time', (
    tester,
  ) async {
    await _openTutorial(tester);

    expect(find.text('건너뛰기'), findsNothing);
  });

  testWidgets('tutorial_offers_skip_when_player_reopens_it_after_finishing', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'tutorial_seen_classic': true});
    await _openTutorial(tester);

    await tester.tap(find.text('건너뛰기'));
    await _settle(tester);

    expect(find.text('대기방'), findsOneWidget);
    expect(find.byType(GameTutorialPage), findsNothing);
  });

  testWidgets(
    'tutorial_stays_closed_next_entry_when_first_viewing_is_left_by_back',
    (tester) async {
      await _openTutorial(tester);

      await tester.binding.handlePopRoute();
      await _settle(tester);

      expect(find.text('대기방'), findsOneWidget);
      expect(await TutorialPrefs.seen(TutorialMode.classic), isTrue);
    },
  );

  testWidgets(
    'tutorial_invites_to_start_when_player_already_in_room_reaches_end',
    (tester) async {
      await _openTutorial(tester);

      for (var i = 0; i < 9; i++) {
        for (var t = 0; t < 7000; t += 32) {
          await tester.pump(const Duration(milliseconds: 32));
        }
        await tester.tap(find.text('다음').last, warnIfMissed: false);
      }
      await _settle(tester);

      expect(find.text('이제 시작하러 가볼까요?'), findsOneWidget);
      expect(find.text('같이 할 사람도 여기서 구해요'), findsNothing);
      // 눌러도 게임이 시작되지 않고 대기방으로 돌아가므로 시작하기라고 쓰지 않는다
      expect(find.text('확인'), findsOneWidget);
      expect(find.text('시작하기'), findsNothing);
    },
  );

  group('TutorialAutoOpen', () {
    test(
      'tutorial_does_not_open_twice_when_info_button_was_pressed_first',
      () async {
        final gate = TutorialAutoOpen();

        gate.markOpened();

        expect(
          await gate.shouldOpen(
            TutorialMode.classic,
            isEventGame: false,
            isTopRoute: () => true,
          ),
          isFalse,
        );
      },
    );

    test(
      'tutorial_does_not_cover_settings_when_another_screen_is_on_top',
      () async {
        expect(
          await TutorialAutoOpen().shouldOpen(
            TutorialMode.classic,
            isEventGame: false,
            isTopRoute: () => false,
          ),
          isFalse,
        );
      },
    );

    test(
      'tutorial_is_judged_once_when_participants_are_fetched_again',
      () async {
        final gate = TutorialAutoOpen();
        Future<bool> check() => gate.shouldOpen(
          TutorialMode.classic,
          isEventGame: false,
          isTopRoute: () => true,
        );

        expect(await check(), isTrue);
        expect(await check(), isFalse);
      },
    );
  });

  group('shouldAutoOpen', () {
    test('tutorial_opens_when_entering_room_first_time', () async {
      expect(
        await TutorialPrefs.shouldAutoOpen(
          TutorialMode.classic,
          isEventGame: false,
        ),
        isTrue,
      );
    });

    test('tutorial_stays_closed_when_already_seen_on_this_device', () async {
      await TutorialPrefs.markSeen(TutorialMode.classic);

      expect(
        await TutorialPrefs.shouldAutoOpen(
          TutorialMode.classic,
          isEventGame: false,
        ),
        isFalse,
      );
    });

    test('tutorial_stays_closed_when_event_game', () async {
      expect(
        await TutorialPrefs.shouldAutoOpen(
          TutorialMode.classic,
          isEventGame: true,
        ),
        isFalse,
      );
    });

    test('tag_tutorial_still_opens_when_classic_was_seen', () async {
      await TutorialPrefs.markSeen(TutorialMode.classic);

      expect(
        await TutorialPrefs.shouldAutoOpen(
          TutorialMode.tag,
          isEventGame: false,
        ),
        isTrue,
      );
    });
  });
}
