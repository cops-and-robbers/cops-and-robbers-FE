import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cops_and_robbers/core/constants/game_mode.dart';
import 'package:cops_and_robbers/features/session/presentation/widgets/mode_select_step.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';

Future<void> _pump(
  WidgetTester tester, {
  GameMode selected = GameMode.copsAndRobbers,
  ValueChanged<GameMode>? onSelected,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('ko'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ScreenUtilInit(
        designSize: const Size(393, 852),
        builder: (context, _) => Scaffold(
          body: ModeSelectStep(
            selected: selected,
            onSelected: onSelected ?? (_) {},
            onNext: () {},
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

/// 카드 안에 그려진 SVG 에셋 경로
String? _assetIn(WidgetTester tester, String cardTitle) {
  final card = find.ancestor(
    of: find.text(cardTitle),
    matching: find.byType(Row),
  );
  final svg = tester.widget<SvgPicture>(
    find.descendant(of: card.first, matching: find.byType(SvgPicture)),
  );
  final loader = svg.bytesLoader;
  return loader is SvgAssetLoader ? loader.assetName : null;
}

void main() {
  group('ModeSelectStep', () {
    testWidgets('shows_character_matching_each_mode_when_rendered', (
      tester,
    ) async {
      await _pump(tester);

      expect(
        _assetIn(tester, '경찰과 도둑'),
        'assets/characters/robber/default/jailed.svg',
      );
      expect(
        _assetIn(tester, '술래잡기'),
        'assets/characters/robber/start/default/chase.svg',
      );
    });

    testWidgets('reports_hide_and_seek_when_its_card_is_tapped', (
      tester,
    ) async {
      GameMode? picked;
      await _pump(tester, onSelected: (mode) => picked = mode);

      await tester.tap(find.text('술래잡기'));

      expect(picked, GameMode.hideAndSeek);
    });
  });
}
