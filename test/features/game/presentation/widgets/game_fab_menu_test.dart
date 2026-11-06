import 'package:cops_and_robbers/core/constants/app_icons.dart';
import 'package:cops_and_robbers/features/game/presentation/widgets/game_fab_menu.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpMenu(WidgetTester tester, VoidCallback onArrest) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ko'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, _) => Scaffold(
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: GameFabMenu(
              isDarkMode: false,
              items: [
                const GameFabMenuItem(label: '좌표', icon: AppIcons.grid),
                const GameFabMenuItem(label: '참가자', icon: AppIcons.person),
                GameFabMenuItem(
                  label: '체포',
                  icon: AppIcons.qrScan,
                  onTap: onArrest,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('items_are_hidden_until_police_opens_the_menu', (tester) async {
    await pumpMenu(tester, () {});

    expect(find.text('체포'), findsNothing);
  });

  testWidgets('arrest_runs_and_menu_closes_when_police_taps_arrest', (
    tester,
  ) async {
    var arrests = 0;
    await pumpMenu(tester, () => arrests++);

    await tester.tap(find.byType(GameFabMenu));
    await tester.pumpAndSettle();
    expect(find.text('참가자'), findsOneWidget);

    await tester.tap(find.text('체포'));
    await tester.pumpAndSettle();

    expect(arrests, 1);
    expect(find.text('체포'), findsNothing);
  });

  testWidgets('menu_closes_without_action_when_police_taps_close_button', (
    tester,
  ) async {
    var arrests = 0;
    await pumpMenu(tester, () => arrests++);

    await tester.tap(find.byType(GameFabMenu));
    await tester.pumpAndSettle();
    await tester.tap(
      find
          .byWidgetPredicate(
            (w) =>
                w is SvgPicture &&
                w.bytesLoader is SvgAssetLoader &&
                (w.bytesLoader as SvgAssetLoader).assetName == AppIcons.plus,
          )
          .last,
    );
    await tester.pumpAndSettle();

    expect(arrests, 0);
    expect(find.text('체포'), findsNothing);
  });

  testWidgets('screen_reader_hears_open_and_close_labels_on_menu_button', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpMenu(tester, () {});

    expect(find.bySemanticsLabel('메뉴 열기'), findsOneWidget);

    await tester.tap(find.byType(GameFabMenu));
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('메뉴 닫기'), findsOneWidget);
    semantics.dispose();
  });

  // 시작 장면은 오른쪽 아래 버튼에서 위로 쌓인다 — 위에서부터 QR, 참가자, 채팅이고 모두 버튼 위에 있다
  testWidgets('scene_menu_stacks_items_above_button_in_order_when_opened', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ko'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ScreenUtilInit(
          designSize: const Size(393, 852),
          builder: (context, _) => const Scaffold(
            floatingActionButton: GameFabMenu(
              isDarkMode: false,
              stacksUp: true,
              items: [
                GameFabMenuItem(label: '체포', icon: AppIcons.qrScan),
                GameFabMenuItem(label: '참가자', icon: AppIcons.person),
                GameFabMenuItem(label: '채팅', icon: AppIcons.comment),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final button = tester.getRect(find.byType(GameFabMenu));

    await tester.tap(find.byType(GameFabMenu));
    await tester.pumpAndSettle();

    final ys = [
      for (final label in ['체포', '참가자', '채팅'])
        tester.getCenter(find.text(label)).dy,
    ];
    expect(ys[0], lessThan(ys[1]));
    expect(ys[1], lessThan(ys[2]));
    expect(ys[2], lessThan(button.top));
    // 라벨은 원 왼쪽에 붙어 화면 오른쪽 밖으로 나가지 않는다
    for (final label in ['체포', '참가자', '채팅']) {
      expect(tester.getRect(find.text(label)).right, lessThan(button.left));
    }
  });

  // 시안 간격: 버튼과 첫 항목 사이 16, 항목(48 원)끼리 8. 라벨은 원 가운데에 맞춰 있다.
  testWidgets('scene_menu_keeps_design_gaps_when_opened', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ko'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ScreenUtilInit(
          designSize: const Size(393, 852),
          builder: (context, _) => const Scaffold(
            floatingActionButton: GameFabMenu(
              isDarkMode: false,
              stacksUp: true,
              items: [
                GameFabMenuItem(label: '체포', icon: AppIcons.scan),
                GameFabMenuItem(label: '참가자', icon: AppIcons.headcount),
                GameFabMenuItem(label: '채팅', icon: AppIcons.comment),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final button = tester.getRect(find.byType(GameFabMenu));

    await tester.tap(find.byType(GameFabMenu));
    await tester.pumpAndSettle();

    final ys = [
      for (final label in ['체포', '참가자', '채팅'])
        tester.getCenter(find.text(label)).dy,
    ];
    expect(button.size, const Size(56, 56));
    expect(ys[1] - ys[0], moreOrLessEquals(48 + 8));
    expect(ys[2] - ys[1], moreOrLessEquals(48 + 8));
    expect(button.top - (ys[2] + 48 / 2), moreOrLessEquals(16));
  });

  // 지도 메뉴는 기본 원 64 · 아이콘 32이고, 항목이 늘면 하나당 8씩 줄어 원 48 · 아이콘 24에서 멈춘다
  for (final (count, circle, icon) in [
    (3, 64.0, 32.0),
    (4, 56.0, 28.0),
    (6, 48.0, 24.0),
  ]) {
    testWidgets(
      'map_menu_items_are_${circle.toInt()}_when_menu_has_${count}_items',
      (tester) async {
        tester.view.physicalSize = const Size(393, 852);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('ko'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ScreenUtilInit(
              designSize: const Size(393, 852),
              builder: (context, _) => Scaffold(
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerFloat,
                floatingActionButton: GameFabMenu(
                  isDarkMode: false,
                  items: [
                    for (var i = 0; i < count; i++)
                      GameFabMenuItem(label: '항목$i', icon: AppIcons.grid),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.byType(GameFabMenu));
        await tester.pumpAndSettle();

        final svg = find
            .byWidgetPredicate(
              (w) =>
                  w is SvgPicture &&
                  w.bytesLoader is SvgAssetLoader &&
                  (w.bytesLoader as SvgAssetLoader).assetName == AppIcons.grid,
            )
            .first;
        final circleBox = find
            .ancestor(of: svg, matching: find.byType(Container))
            .first;
        expect(tester.getSize(svg).width, moreOrLessEquals(icon));
        expect(tester.getSize(circleBox).width, moreOrLessEquals(circle));
      },
    );
  }
}
