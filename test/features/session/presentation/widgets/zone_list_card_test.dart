import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cops_and_robbers/features/game/domain/entities/area_shape.dart';
import 'package:cops_and_robbers/features/session/presentation/widgets/zone_list_card.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';

const _origin = GeoPoint(latitude: 37.5665, longitude: 126.9780);

const _circleArea = GameAreaEntity(
  playground: AreaShape.circle(center: _origin, radiusInMeters: 523),
  jail: AreaShape.circle(center: _origin, radiusInMeters: 233),
);

const _polygonArea = GameAreaEntity(
  playground: AreaShape.polygon(
    points: [
      GeoPoint(latitude: 37.5665, longitude: 126.9780),
      GeoPoint(latitude: 37.5710, longitude: 126.9780),
      GeoPoint(latitude: 37.5710, longitude: 126.9835),
      GeoPoint(latitude: 37.5665, longitude: 126.9835),
    ],
  ),
  jail: AreaShape.polygon(
    points: [
      GeoPoint(latitude: 37.5670, longitude: 126.9785),
      GeoPoint(latitude: 37.5679, longitude: 126.9785),
      GeoPoint(latitude: 37.5679, longitude: 126.9796),
      GeoPoint(latitude: 37.5670, longitude: 126.9796),
    ],
  ),
);

Future<void> _pump(WidgetTester tester, GameAreaEntity area) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('ko'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, _) => Scaffold(body: ZoneListCard(area: area)),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('ZoneListCard', () {
    testWidgets('shows_radius_for_both_zones_when_area_is_circle', (
      tester,
    ) async {
      await _pump(tester, _circleArea);

      expect(find.text('반경 523m'), findsOneWidget);
      expect(find.text('반경 233m'), findsOneWidget);
    });

    testWidgets('shows_area_for_both_zones_when_area_is_polygon', (
      tester,
    ) async {
      await _pump(tester, _polygonArea);

      expect(find.textContaining('면적'), findsNWidgets(2));
      expect(find.textContaining('반경'), findsNothing);
    });

    testWidgets('shows_zone_names_from_localizations', (tester) async {
      await _pump(tester, _circleArea);

      expect(find.text('플레이그라운드'), findsOneWidget);
      expect(find.text('감옥'), findsOneWidget);
    });
  });
}
