import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:cops_and_robbers/features/auth/presentation/pages/onboarding_page.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:cops_and_robbers/router/route_paths.dart';

/// 온보딩의 진행과 나가는 길 검증.
///
/// 틀어지면 "다음"만 계속 눌리거나 로그인으로 못 가서, 설치 후 첫 화면에서 사용자가 갇힌다.
Future<GoRouter> _pump(WidgetTester tester, {bool fromMyPage = false}) async {
  // 테스트 기본 화면은 800x600이라 좁은 폰에서만 나는 오버플로우를 놓친다.
  tester.view.physicalSize = const Size(375 * 3, 812 * 3);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);

  final router = GoRouter(
    initialLocation: fromMyPage ? '/mypage' : RoutePaths.onboarding,
    routes: [
      GoRoute(
        path: RoutePaths.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: RoutePaths.login,
        builder: (context, state) => const Scaffold(body: Text('로그인')),
      ),
      GoRoute(
        path: '/mypage',
        builder: (context, state) => const Scaffold(body: Text('마이페이지')),
      ),
    ],
  );
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, _) => MaterialApp.router(
        routerConfig: router,
        locale: const Locale('ko'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  if (fromMyPage) {
    await tester.pump();
    router.push(RoutePaths.onboarding);
  }
  await _advance(tester, 300);
  return router;
}

Future<void> _advance(WidgetTester tester, int ms) async {
  for (var t = 0; t < ms; t += 32) {
    await tester.pump(const Duration(milliseconds: 32));
  }
}

/// 연출을 기다렸다가 5번 넘겨 마지막 장면으로 간다.
Future<void> _goToLastScene(WidgetTester tester) async {
  await _advance(tester, 1600);
  for (var i = 0; i < 5; i++) {
    await tester.tap(find.text('다음'));
    await _advance(tester, 4500);
  }
}

void main() {
  testWidgets('onboarding_shows_the_next_button_when_scenes_remain', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.text('밖에서 진짜로 뛰는 게임이에요'), findsOneWidget);
    expect(find.text('다음'), findsOneWidget);
    expect(find.text('시작하기'), findsNothing);
  });

  testWidgets('onboarding_swaps_the_primary_button_on_the_last_scene', (
    tester,
  ) async {
    await _pump(tester);
    await _goToLastScene(tester);

    expect(find.text('같이 할 사람도 여기서 구해요'), findsOneWidget);
    expect(find.text('시작하기'), findsOneWidget);
    expect(find.text('다음'), findsNothing);
  });

  testWidgets('onboarding_hides_skip_when_on_the_last_scene', (tester) async {
    double skipOpacity() => tester
        .widget<Opacity>(
          find
              .ancestor(of: find.text('건너뛰기'), matching: find.byType(Opacity))
              .first,
        )
        .opacity;

    await _pump(tester);
    expect(skipOpacity(), 1);

    await _goToLastScene(tester);
    expect(skipOpacity(), 0);
  });

  testWidgets(
    'onboarding_shows_invite_dialog_contents_when_friends_scene_plays',
    (tester) async {
      await _pump(tester);
      await _advance(tester, 1600);
      await tester.tap(find.text('다음'));
      await _advance(tester, 2500);
      await tester.tap(find.text('다음'));
      await _advance(tester, 1000);

      expect(find.text('초대코드를 생성했어요'), findsOneWidget);
      expect(find.text('A3F9K2'), findsOneWidget);
    },
  );

  testWidgets('onboarding_goes_to_login_when_first_run_is_skipped', (
    tester,
  ) async {
    await _pump(tester);

    await tester.tap(find.text('건너뛰기'));
    await _advance(tester, 300);

    expect(find.text('로그인'), findsOneWidget);
  });

  testWidgets('onboarding_returns_to_mypage_when_opened_from_replay', (
    tester,
  ) async {
    await _pump(tester, fromMyPage: true);

    await tester.tap(find.text('건너뛰기'));
    await _advance(tester, 300);

    expect(find.text('마이페이지'), findsOneWidget);
  });
}
