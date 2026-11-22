import 'package:cops_and_robbers/features/session/presentation/widgets/radio_toggle_card.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import '../pages/creation_flow_fakes.dart';

Future<AppLocalizations> _pump(
  WidgetTester tester, {
  required bool enabled,
  ValueChanged<bool>? onChanged,
  String locale = 'ko',
}) async {
  tester.view.physicalSize = const Size(375, 812);
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
            child: RadioToggleCard(enabled: enabled, onChanged: onChanged),
          ),
        ),
      ),
    ),
  );
  return AppLocalizations.of(tester.element(find.byType(RadioToggleCard)));
}

void main() {
  setUpAll(loadAppFonts);

  // 방장이 방 설정에서 무전 카드를 본다 — 제목 "무전" 바로 오른쪽에 Beta 칩이 붙는다
  testWidgets('radio_card_shows_beta_chip_right_of_title_when_shown_to_host', (
    tester,
  ) async {
    await _pump(tester, enabled: false, onChanged: (_) {});

    final title = tester.getRect(find.text('무전'));
    final chip = tester.getRect(find.text('Beta'));
    expect(chip.left, greaterThan(title.right));
    expect(chip.center.dy, closeTo(title.center.dy, 2));
    expect(find.text('버튼을 길게 누르는 동안 말해요'), findsOneWidget);
  });

  // 방장이 꺼져 있는 무전 스위치를 누른다
  testWidgets('radio_card_reports_on_when_host_taps_switch_that_is_off', (
    tester,
  ) async {
    bool? changed;
    await _pump(tester, enabled: false, onChanged: (v) => changed = v);
    expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);

    await tester.tap(find.byType(Switch));

    expect(changed, isTrue);
  });

  // 방장이 무전을 켠 대기방의 참가자 — 켜진 스위치가 흐리게 보이고 눌러도 바뀌지 않는다
  testWidgets('guest_sees_radio_switch_dimmed_and_cannot_toggle', (
    tester,
  ) async {
    await _pump(tester, enabled: true);

    final toggle = tester.widget<Switch>(find.byType(Switch));
    expect(toggle.value, isTrue);
    expect(toggle.onChanged, isNull);
    expect(
      tester
          .widget<Opacity>(
            find.ancestor(
              of: find.byType(Switch),
              matching: find.byType(Opacity),
            ),
          )
          .opacity,
      0.4,
    );
  });

  // 방장에게는 스위치를 흐리게 하지 않는다
  testWidgets('host_sees_radio_switch_at_full_strength', (tester) async {
    await _pump(tester, enabled: true, onChanged: (_) {});

    expect(
      find.ancestor(of: find.byType(Switch), matching: find.byType(Opacity)),
      findsNothing,
    );
  });

  // 375pt 폰에서 제목·칩 줄과 설명이 잘리지 않는다
  for (final locale in ['ko', 'en', 'ja']) {
    testWidgets('radio_card_texts_fit_one_line_without_ellipsis_$locale', (
      tester,
    ) async {
      final l10n = await _pump(
        tester,
        enabled: false,
        onChanged: (_) {},
        locale: locale,
      );

      for (final text in [l10n.radioPttLabel, l10n.radioCardDesc]) {
        final paragraph = tester.renderObject<RenderParagraph>(find.text(text));
        expect(paragraph.didExceedMaxLines, isFalse, reason: text);
        expect(
          paragraph.size.height,
          lessThan(paragraph.text.style!.fontSize! * 2),
          reason: text,
        );
      }
      expect(find.text(l10n.radioBetaChip), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
