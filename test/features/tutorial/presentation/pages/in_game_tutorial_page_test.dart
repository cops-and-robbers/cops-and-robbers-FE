import 'package:cops_and_robbers/core/widgets/buttons/svg_icon_button.dart';
import 'package:cops_and_robbers/features/game/presentation/widgets/ping_selection_card.dart';
import 'package:cops_and_robbers/features/tutorial/presentation/pages/in_game_tutorial_page.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

GoRouter _testRouter() {
  return GoRouter(
    initialLocation: '/tutorial/in-game',
    routes: [
      GoRoute(
        path: '/tutorial/in-game',
        builder: (_, _) => const InGameTutorialPage(),
      ),
      GoRoute(
        path: '/tutorial',
        builder: (_, _) => const Scaffold(body: Text('BACK')),
      ),
    ],
  );
}

/// 디자인 기준(375×812)으로 ScreenUtil 초기화 후 페이지를 띄운다.
///
/// `_pulseController`가 무한 반복 애니메이션을 사용하므로 pumpAndSettle은
/// 타임아웃이 발생한다. pump()로 프레임만 한 번 올려 초기 레이아웃을 완성한다.
Future<void> pumpPage(WidgetTester tester) async {
  // iPhone X 크기로 설정 — overflow 방지 및 ScreenUtil 정확도 향상
  tester.view.physicalSize = const Size(1125, 2436);
  tester.view.devicePixelRatio = 3.0;

  await tester.pumpWidget(
    ProviderScope(
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, _) => MaterialApp.router(
          routerConfig: _testRouter(),
          locale: const Locale('ko'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    ),
  );
  // 라우터 초기화 + 첫 프레임
  await tester.pump();
  await tester.pump();
}

AppLocalizations l10nOf(WidgetTester tester) =>
    AppLocalizations.of(tester.element(find.byType(InGameTutorialPage)));

void main() {
  testWidgets('mission_banner_shows_first_qr_mission_when_tutorial_starts', (
    tester,
  ) async {
    await pumpPage(tester);
    final l10n = l10nOf(tester);

    expect(find.text(l10n.tutorialMissionProgress('1')), findsOneWidget);
    expect(find.text(l10n.tutorialMissionQrButton), findsOneWidget);
    // 시작 시 완료 다이얼로그가 떠선 안 됨(완료 조건 off-by-one 역방향 가드)
    expect(find.text(l10n.titleTutorialComplete), findsNothing);
  });

  testWidgets('completion_dialog_appears_when_pin_dropped_on_final_mission', (
    tester,
  ) async {
    await pumpPage(tester);
    final l10n = l10nOf(tester);

    // step 0(QR) — 지도 모드 SvgIconButton = [참가자(0), QR(1)]
    // QR 탭 시 스낵바(3초 타이머)가 등장하므로 타이머를 소진한다.
    await tester.tap(find.byType(SvgIconButton).at(1));
    await tester.pump();
    await tester.pump(const Duration(seconds: 4)); // 스낵바 3s 타이머 소진

    // step 1(참가자) — 참가자 버튼 탭 → 참가자 모드 전환
    await tester.tap(find.byType(SvgIconButton).at(0));
    await tester.pump();

    // step 2(지도복귀) — 참가자 모드 SvgIconButton = [지도복귀(0), QR(1)]
    await tester.tap(find.byType(SvgIconButton).at(0));
    await tester.pump();

    // step 3 배너가 "미션 4/4" + 핀 찍기 안내를 표시
    expect(find.text(l10n.tutorialMissionProgress('4')), findsOneWidget);
    expect(find.text(l10n.tutorialMissionDropPing), findsOneWidget);

    // 지도 placeholder 롱프레스 → 선택 카드 등장
    await tester.longPress(find.text(l10n.tutorialMapPreviewLabel));
    await tester.pump();
    expect(find.byType(PingSelectionCard), findsOneWidget);

    // 발견 선택 → 미션 완료 → 500ms 후 완료 다이얼로그
    await tester.tap(find.text(l10n.pingFound));
    await tester.pump(); // setState 반영
    await tester.pump(const Duration(milliseconds: 600)); // Future.delayed(500)

    expect(find.text(l10n.titleTutorialComplete), findsOneWidget);
  });
}
