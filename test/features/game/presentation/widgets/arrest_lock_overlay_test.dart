import 'package:cops_and_robbers/core/constants/game_mode.dart';
import 'package:cops_and_robbers/features/game/presentation/widgets/arrest_lock_overlay.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

Future<AppLocalizations> pumpOverlay(WidgetTester tester, GameMode mode) async {
  tester.view.physicalSize = const Size(393, 852) * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      child: ScreenUtilInit(
        designSize: const Size(393, 852),
        builder: (_, _) => MaterialApp(
          locale: const Locale('ko'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Stack(
              children: [
                ArrestLockOverlay(
                  gameId: 1,
                  myParticipantId: 5,
                  gameMode: mode,
                  onClose: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  return AppLocalizations.of(tester.element(find.byType(ArrestLockOverlay)));
}

bool _hasAsset(WidgetTester tester, String name) => tester
    .widgetList<SvgPicture>(find.byType(SvgPicture))
    .any(
      (w) =>
          w.bytesLoader is SvgAssetLoader &&
          (w.bytesLoader as SvgAssetLoader).assetName == name,
    );

void main() {
  testWidgets(
    'caught_hider_sees_spectating_without_escape_button_when_playing_hide_and_seek',
    (tester) async {
      final l10n = await pumpOverlay(tester, GameMode.hideAndSeek);
      expect(find.text(l10n.gameArrestOverlayTitleTag), findsOneWidget);
      expect(find.text(l10n.gameArrestOverlayMessageTag), findsOneWidget);
      expect(
        find.text(l10n.gameArrestOverlayEscapeCompleteButton),
        findsNothing,
      );
      expect(find.text(l10n.gameArrestOverlayTitle), findsNothing);
    },
  );

  testWidgets(
    'jailed_robber_sees_escape_button_when_playing_cops_and_robbers',
    (tester) async {
      final l10n = await pumpOverlay(tester, GameMode.copsAndRobbers);
      expect(find.text(l10n.gameArrestOverlayTitle), findsOneWidget);
      expect(
        _hasAsset(tester, 'assets/characters/robber/default/jailed.svg'),
        isTrue,
      );
      expect(
        find.text(l10n.gameArrestOverlayEscapeCompleteButton),
        findsOneWidget,
      );
    },
  );
}
