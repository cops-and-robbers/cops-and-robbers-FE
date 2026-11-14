import 'package:cops_and_robbers/core/constants/game_mode.dart';
import 'package:cops_and_robbers/features/session/presentation/widgets/team_section.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(WidgetTester tester, GameMode mode, String team) async {
  tester.view.physicalSize = const Size(375, 812);
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
          body: TeamSection(
            team: team,
            members: const [],
            isExpanded: false,
            onToggle: () {},
            gameMode: mode,
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('team_section_shows_seeker_team_when_room_is_hide_and_seek', (
    tester,
  ) async {
    await _pump(tester, GameMode.hideAndSeek, 'POLICE');
    final l10n = AppLocalizations.of(tester.element(find.byType(TeamSection)));
    expect(find.text(l10n.gameTeamSeeker), findsOneWidget);
    expect(find.text(l10n.gameTeamCop), findsNothing);
  });

  testWidgets('team_section_shows_hider_team_when_room_is_hide_and_seek', (
    tester,
  ) async {
    await _pump(tester, GameMode.hideAndSeek, 'ROBBER');
    final l10n = AppLocalizations.of(tester.element(find.byType(TeamSection)));
    expect(find.text(l10n.gameTeamHider), findsOneWidget);
  });
}
