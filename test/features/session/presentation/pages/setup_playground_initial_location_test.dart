import 'dart:async';
import 'dart:convert';

import 'package:cops_and_robbers/core/widgets/buttons/my_location_button.dart';
import 'package:cops_and_robbers/features/game/domain/entities/area_shape.dart';
import 'package:cops_and_robbers/features/session/presentation/pages/session_creation_flow_page.dart';
import 'package:cops_and_robbers/features/session/presentation/pages/setup_playground_page.dart';
import 'package:cops_and_robbers/features/session/presentation/pages/setup_prison_page.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// 네이티브 지도 경계만 대체한다. 구역 설정과 저장소 로직은 실제 객체를 사용한다.
// ignore: depend_on_referenced_packages
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'creation_flow_fakes.dart';

const _gps = fakeGps;
const _meeting = LatLng(35, 129);
const _edited = LatLng(36, 128);
const _circle = AreaShape.circle(
  center: GeoPoint(latitude: 36, longitude: 128),
  radiusInMeters: 300,
);
const _polygon = AreaShape.polygon(
  points: [
    GeoPoint(latitude: 35.999, longitude: 127.999),
    GeoPoint(latitude: 36.001, longitude: 127.999),
    GeoPoint(latitude: 36, longitude: 128.002),
  ],
);

Future<void> _pumpPage(WidgetTester tester, Widget page) => pumpCreationApp(
  tester,
  MaterialApp(
    locale: const Locale('ko'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: page,
  ),
);

LatLng _visibleCenter(WidgetTester tester) => tester
    .widget<GoogleMap>(find.byType(GoogleMap))
    .initialCameraPosition
    .target;

void main() {
  late FakeLocation location;
  late FakeMap maps;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    final oldLocation = GeolocatorPlatform.instance;
    final oldMap = GoogleMapsFlutterPlatform.instance;
    GeolocatorPlatform.instance = location = FakeLocation();
    GoogleMapsFlutterPlatform.instance = maps = FakeMap();
    addTearDown(() {
      GeolocatorPlatform.instance = oldLocation;
      GoogleMapsFlutterPlatform.instance = oldMap;
    });
  });

  testWidgets(
    'community_entry_opens_the_meeting_map_and_keeps_the_invite_post',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'session_creation_draft': jsonEncode({
          'playgroundCenter': {'latitude': 36, 'longitude': 128},
          'playgroundRadiusInMeters': 250,
        }),
      });
      await pumpCreationFlow(
        tester,
        communityPostId: 42,
        initialCenter: _meeting,
      );
      await tester.tap(find.text('start'));
      await tester.pumpAndSettle();

      expect(_visibleCenter(tester), _meeting);
      expect(
        tester
            .widget<SessionCreationFlowPage>(
              find.byType(SessionCreationFlowPage, skipOffstage: false),
            )
            .communityPostId,
        42,
      );
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('session_creation_draft'), isNull);
    },
  );

  testWidgets('new_polygon_starts_at_the_edited_circle_when_switching_modes', (
    tester,
  ) async {
    await _pumpPage(
      tester,
      const SetupPlaygroundPage(
        editInitialShape: _circle,
        initialCenter: _meeting,
      ),
    );
    expect(_visibleCenter(tester), _edited);

    await tester.tap(find.text('핀으로 설정'));
    await tester.pumpAndSettle();
    expect(_visibleCenter(tester), _edited);

    await tester.tap(find.text('거리로 설정'));
    await tester.pumpAndSettle();
    expect(_visibleCenter(tester), _edited);
    expect(
      tester.widget<GoogleMap>(find.byType(GoogleMap)).circles.single.radius,
      300,
    );
  });

  testWidgets(
    'new_circle_starts_at_the_restored_polygon_when_switching_modes',
    (tester) async {
      await _pumpPage(
        tester,
        const SetupPlaygroundPage(
          editInitialShape: _polygon,
          initialCenter: _meeting,
        ),
      );
      expect(_visibleCenter(tester), _edited);

      await tester.tap(find.text('거리로 설정'));
      await tester.pumpAndSettle();

      expect(_visibleCenter(tester), _edited);
    },
  );

  for (final mode in ['CIRCLE', 'POLYGON']) {
    testWidgets(
      'meeting_location_is_ready_before_gps_and_survives_mode_changes_from_$mode',
      (tester) async {
        SharedPreferences.setMockInitialValues({
          'session_creation_draft': jsonEncode({'areaType': mode}),
        });
        final pending = Completer<Position>();
        location.pending = pending.future;
        await _pumpPage(
          tester,
          const SetupPlaygroundPage(initialCenter: _meeting),
        );
        expect(_visibleCenter(tester), _meeting);

        await tester.tap(find.text(mode == 'CIRCLE' ? '핀으로 설정' : '거리로 설정'));
        await tester.pumpAndSettle();
        expect(_visibleCenter(tester), _meeting);
        pending.complete(location.position);
        await tester.pumpAndSettle();
        expect(_visibleCenter(tester), _meeting);
      },
    );

    testWidgets('my_location_moves_${mode}_to_actual_gps_on_request', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'session_creation_draft': jsonEncode({'areaType': mode}),
      });
      await _pumpPage(
        tester,
        const SetupPlaygroundPage(initialCenter: _meeting),
      );
      expect(maps.centers.values.single, _meeting);
      await tester.tap(find.byType(MyLocationButton));
      await tester.pumpAndSettle();
      expect(maps.centers.values.single, _gps);
    });
  }

  testWidgets('home_without_a_meeting_location_starts_at_gps', (tester) async {
    await _pumpPage(tester, const SetupPlaygroundPage());
    expect(_visibleCenter(tester), _gps);
  });

  testWidgets('saved_draft_wins_over_the_meeting_location_on_reentry', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'session_creation_draft': jsonEncode({
        'playgroundCenter': {'latitude': 36, 'longitude': 128},
        'playgroundRadiusInMeters': 250,
      }),
    });
    await _pumpPage(tester, const SetupPlaygroundPage(initialCenter: _meeting));
    final map = tester.widget<GoogleMap>(find.byType(GoogleMap));
    expect(
      (map.initialCameraPosition.target, map.circles.single.radius),
      (_edited, 250),
    );
  });

  testWidgets(
    'switching_to_polygon_keeps_the_center_after_moving_the_circle_map',
    (tester) async {
      await _pumpPage(
        tester,
        const SetupPlaygroundPage(initialCenter: _meeting),
      );
      maps.centers[maps.centers.keys.single] = _edited;
      tester.widget<GoogleMap>(find.byType(GoogleMap)).onCameraIdle!();
      await tester.pumpAndSettle();
      expect(
        tester.widget<GoogleMap>(find.byType(GoogleMap)).circles.single.center,
        _edited,
      );

      await tester.tap(find.text('핀으로 설정'));
      await tester.pumpAndSettle();
      expect(_visibleCenter(tester), _edited);
    },
  );

  // 새 감옥은 진입 경로와 무관하게 플레이그라운드 가운데에서 시작한다
  for (final playground in [_circle, _polygon]) {
    final mode = playground is CircleShape ? 'circle' : 'polygon';

    testWidgets('new_${mode}_prison_starts_at_the_playground_middle', (
      tester,
    ) async {
      await _pumpPage(
        tester,
        SetupPrisonPage(editArgs: PrisonEditArgs(playground: playground)),
      );
      final center = _visibleCenter(tester);
      expect(center.latitude, closeTo(_edited.latitude, .001));
      expect(center.longitude, closeTo(_edited.longitude, .001));
    });
  }

  testWidgets('existing_prison_wins_over_the_playground_middle', (
    tester,
  ) async {
    const jail = AreaShape.circle(
      center: GeoPoint(latitude: 35, longitude: 129),
      radiusInMeters: 50,
    );
    await _pumpPage(
      tester,
      const SetupPrisonPage(
        editArgs: PrisonEditArgs(playground: _circle, initialJail: jail),
      ),
    );
    expect(_visibleCenter(tester), _meeting);
  });
}
