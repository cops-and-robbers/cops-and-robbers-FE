import 'package:cops_and_robbers/features/game/domain/shrink_schedule.dart';
import 'package:cops_and_robbers/features/session/presentation/widgets/shrink_toggle_card.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:cops_and_robbers/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import '../pages/creation_flow_fakes.dart';

Future<void> _pump(
  WidgetTester tester, {
  required bool enabled,
  ShrinkLock lock = ShrinkLock.none,
  int startRadius = 500,
  int? finalRadius = 200,
  ValueChanged<bool>? onChanged,
  String locale = 'ko',
  bool isDarkMode = false,
}) async {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      locale: Locale(locale),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, _) => Scaffold(
          body: Padding(
            // 확인 화면과 같은 좌우 여백
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ShrinkToggleCard(
              enabled: enabled,
              lock: lock,
              startRadius: startRadius,
              finalRadius: finalRadius,
              onChanged: onChanged,
              isDarkMode: isDarkMode,
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('off_card_says_the_area_shrinks_over_time', (tester) async {
    await _pump(tester, enabled: false, onChanged: (_) {});
    expect(find.text('구역 축소'), findsOneWidget);
    expect(find.text('구역이 점점 줄어들어요'), findsOneWidget);
  });

  testWidgets('host_turning_it_on_in_500m_room_sees_500_to_200', (
    tester,
  ) async {
    bool? changed;
    await _pump(tester, enabled: false, onChanged: (v) => changed = v);
    await tester.tap(find.byType(Switch));
    expect(changed, isTrue);

    await _pump(tester, enabled: true, onChanged: (_) {});
    expect(find.text('500m → 200m까지 줄어요'), findsOneWidget);
  });

  testWidgets('small_area_locks_the_switch_and_explains_why', (tester) async {
    await _pump(
      tester,
      enabled: false,
      lock: ShrinkLock.tooSmall,
      startRadius: 200,
      finalRadius: null,
      onChanged: (_) {},
    );
    expect(find.text('구역이 작아서 쓸 수 없어요'), findsOneWidget);
    expect(tester.widget<Switch>(find.byType(Switch)).onChanged, isNull);
  });

  testWidgets('pin_area_says_circle_only', (tester) async {
    await _pump(
      tester,
      enabled: false,
      lock: ShrinkLock.notCircle,
      onChanged: (_) {},
    );
    expect(find.text('원형 구역에서만 쓸 수 있어요'), findsOneWidget);
  });

  testWidgets(
    'guest_sees_disabled_switch_and_plain_description_even_if_locked',
    (tester) async {
      // 대기방 참가자는 고칠 수 없으니 "넓혀 보세요" 같은 안내를 보여 주지 않는다
      await _pump(tester, enabled: false, lock: ShrinkLock.tooSmall);
      expect(tester.widget<Switch>(find.byType(Switch)).onChanged, isNull);
      expect(find.text('구역이 점점 줄어들어요'), findsOneWidget);
    },
  );

  testWidgets('japanese_on_description_fits_one_line', (tester) async {
    await _pump(tester, enabled: true, onChanged: (_) {}, locale: 'ja');
    final text = find.text('500m → 200mまで縮小');
    expect(text, findsOneWidget);
    final style = tester.widget<Text>(text).style!;
    expect(tester.getSize(text).height, lessThan(style.fontSize! * 2));
  });

  Color? trackOf(WidgetTester tester, Set<WidgetState> states) =>
      tester.widget<Switch>(find.byType(Switch)).trackColor?.resolve(states);

  // 도둑 다크 화면도 라이트 시안과 같은 토글 색 (사용자 결정 2026-11-08)
  testWidgets('robber_dark_screen_uses_same_toggle_colors_as_light', (
    tester,
  ) async {
    await _pump(tester, enabled: true, onChanged: (_) {}, isDarkMode: true);
    expect(trackOf(tester, {WidgetState.selected}), AppColors.blueVer2Basic);
    expect(trackOf(tester, {}), AppColors.black200);
  });

  testWidgets('police_light_screen_uses_blue_when_on_and_black200_when_off', (
    tester,
  ) async {
    await _pump(tester, enabled: true, onChanged: (_) {});
    expect(trackOf(tester, {WidgetState.selected}), AppColors.blueVer2Basic);
    expect(trackOf(tester, {}), AppColors.black200);
  });

  testWidgets('disabled_switch_keeps_token_colors_instead_of_material_grey', (
    tester,
  ) async {
    await _pump(tester, enabled: true, isDarkMode: true);
    expect(
      trackOf(tester, {WidgetState.selected, WidgetState.disabled}),
      AppColors.blueVer2Basic,
    );
  });

  testWidgets('guest_switch_is_dimmed_with_opacity', (tester) async {
    await _pump(tester, enabled: true);
    final dim = find.ancestor(
      of: find.byType(Switch),
      matching: find.byType(Opacity),
    );
    expect(tester.widget<Opacity>(dim).opacity, 0.4);
  });

  testWidgets('host_switch_is_not_dimmed', (tester) async {
    await _pump(tester, enabled: true, onChanged: (_) {});
    expect(
      find.ancestor(of: find.byType(Switch), matching: find.byType(Opacity)),
      findsNothing,
    );
  });

  // 손잡이는 팀과 상관없이 흰색 (사용자 결정 2026-11-08 — 검정 손잡이 안은 버림)
  testWidgets('switch_thumb_stays_white_on_both_teams', (tester) async {
    Color? thumb() => tester
        .widget<Switch>(find.byType(Switch))
        .thumbColor
        ?.resolve({WidgetState.selected});
    await _pump(tester, enabled: true, onChanged: (_) {}, isDarkMode: true);
    expect(thumb(), AppColors.white);
    await _pump(tester, enabled: true, onChanged: (_) {});
    expect(thumb(), AppColors.white);
  });
}
