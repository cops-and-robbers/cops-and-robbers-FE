import 'package:cops_and_robbers/features/game/presentation/widgets/google_map_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
// ignore: depend_on_referenced_packages
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import '../../../session/presentation/pages/creation_flow_fakes.dart';

/// 지도에 넘어간 폴리라인을 기록한다 (구역 축소 다음 경계 점선, #668).
class _RecordingMap extends FakeMap {
  final added = <Polyline>[];

  @override
  Future<void> updatePolylines(
    PolylineUpdates polylineUpdates, {
    required int mapId,
  }) async {
    added.addAll(polylineUpdates.polylinesToAdd);
  }
}

void main() {
  testWidgets('next_shrink_boundary_line_reaches_the_map', (tester) async {
    final oldLocation = GeolocatorPlatform.instance;
    final oldMap = GoogleMapsFlutterPlatform.instance;
    final map = _RecordingMap();
    GeolocatorPlatform.instance = FakeLocation();
    GoogleMapsFlutterPlatform.instance = map;
    addTearDown(() {
      GeolocatorPlatform.instance = oldLocation;
      GoogleMapsFlutterPlatform.instance = oldMap;
    });

    final key = GlobalKey<GoogleMapViewState>();
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, _) => MaterialApp(
          home: GoogleMapView(
            key: key,
            initialTarget: const LatLng(37.55, 127.07),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    key.currentState!.updateBoundaryPolylines({
      const Polyline(
        polylineId: PolylineId('shrink_next'),
        points: [LatLng(37.55, 127.07), LatLng(37.56, 127.07)],
      ),
    });
    await tester.pumpAndSettle();

    expect(map.added.map((p) => p.polylineId.value), contains('shrink_next'));
  });
}
