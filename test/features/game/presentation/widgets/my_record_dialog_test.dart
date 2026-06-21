import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:cops_and_robbers/features/game/presentation/providers/player_game_record_provider.dart';
import 'package:cops_and_robbers/features/game/presentation/widgets/my_record_dialog.dart';

Widget _host({required Widget child, required List<Override> overrides}) {
  return ProviderScope(
    overrides: overrides,
    child: ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, _) => MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ko'), Locale('en'), Locale('ja')],
        locale: const Locale('ko'),
        home: Scaffold(body: child),
      ),
    ),
  );
}

void main() {
  testWidgets('police_record_shows_arrest_count_and_distance', (tester) async {
    await tester.pumpWidget(
      _host(
        overrides: [
          playerGameRecordNotifierProvider.overrideWith(
            () => _FakeRecord(
              const PlayerGameRecord(distanceMeters: 2543, myArrestCount: 3),
            ),
          ),
        ],
        child: const MyRecordCard(
          isDarkMode: false,
          myTeam: 'POLICE',
          winnerTeam: 'POLICE',
          durationSeconds: 754,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('2.54 km'), findsOneWidget);
    expect(find.text('내가 잡은 도둑'), findsOneWidget);
    expect(find.text('내 탈옥 횟수'), findsNothing); // 경찰은 탈옥 숨김
  });

  testWidgets('robber_record_shows_escape_count', (tester) async {
    await tester.pumpWidget(
      _host(
        overrides: [
          playerGameRecordNotifierProvider.overrideWith(
            () => _FakeRecord(
              const PlayerGameRecord(distanceMeters: 540, myEscapeCount: 2),
            ),
          ),
        ],
        child: const MyRecordCard(
          isDarkMode: true,
          myTeam: 'ROBBER',
          winnerTeam: 'POLICE',
          durationSeconds: 600,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('540 m'), findsOneWidget);
    expect(find.text('내 탈옥 횟수'), findsOneWidget);
    expect(find.text('내가 잡은 도둑'), findsNothing);
  });
}

class _FakeRecord extends PlayerGameRecordNotifier {
  _FakeRecord(this._initial);
  final PlayerGameRecord _initial;
  @override
  PlayerGameRecord build() => _initial;
}
