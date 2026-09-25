import 'dart:async';

import 'package:cops_and_robbers/features/game/presentation/widgets/google_map_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// ignore: depend_on_referenced_packages
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
// ignore: depend_on_referenced_packages
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class _Location extends GeolocatorPlatform {
  final requests = <Completer<Position>>[];
  Position? immediatePosition;

  @override
  Future<Position> getCurrentPosition({LocationSettings? locationSettings}) {
    final request = Completer<Position>();
    if (immediatePosition case final position?) request.complete(position);
    requests.add(request);
    return request.future;
  }

  @override
  Future<Position?> getLastKnownPosition({
    bool forceLocationManager = false,
  }) async => null;
}

// Only the native map boundary is replaced; the widget/controller remain real.
class _Map extends Fake
    with MockPlatformInterfaceMixin
    implements GoogleMapsFlutterPlatform {
  final initialCameras = <CameraPosition>[];
  final cameraTargets = <LatLng>[];
  final createdIds = <int>{};
  bool disposed = false;
  Completer<void>? creationGate;
  final cameraMoves = StreamController<CameraMoveStartedEvent>.broadcast();

  @override
  Stream<CameraMoveStartedEvent> onCameraMoveStarted({required int mapId}) =>
      cameraMoves.stream;

  @override
  Widget buildViewWithConfiguration(
    int creationId,
    PlatformViewCreatedCallback onPlatformViewCreated, {
    required MapWidgetConfiguration widgetConfiguration,
    MapConfiguration mapConfiguration = const MapConfiguration(),
    MapObjects mapObjects = const MapObjects(),
  }) {
    if (createdIds.add(creationId)) {
      initialCameras.add(widgetConfiguration.initialCameraPosition);
      cameraTargets.add(widgetConfiguration.initialCameraPosition.target);
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await creationGate?.future;
        onPlatformViewCreated(creationId);
      });
    }
    return const SizedBox.expand();
  }

  @override
  Future<void> init(int mapId) async {}

  @override
  Future<void> animateCameraWithConfiguration(
    CameraUpdate cameraUpdate,
    CameraUpdateAnimationConfiguration configuration, {
    required int mapId,
  }) async {
    final update = cameraUpdate.toJson() as List<dynamic>;
    final position = update[1] as Map<String, dynamic>;
    final target = position['target'] as List<dynamic>;
    cameraTargets.add(LatLng(target[0] as double, target[1] as double));
  }

  @override
  void dispose({required int mapId}) {
    disposed = true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName.toString().startsWith('Symbol("on')) {
      return const Stream<Never>.empty();
    }
    return Future<void>.value();
  }
}

Position _position(double latitude, double longitude) => Position(
  latitude: latitude,
  longitude: longitude,
  timestamp: DateTime(2026, 9, 25),
  accuracy: 3,
  altitude: 0,
  altitudeAccuracy: 0,
  heading: 0,
  headingAccuracy: 0,
  speed: 0,
  speedAccuracy: 0,
);

void main() {
  late _Location location;
  late _Map map;

  setUp(() {
    final previousLocation = GeolocatorPlatform.instance;
    final previousMap = GoogleMapsFlutterPlatform.instance;
    location = _Location();
    map = _Map();
    GeolocatorPlatform.instance = location;
    GoogleMapsFlutterPlatform.instance = map;
    addTearDown(() {
      map.cameraMoves.close();
      GeolocatorPlatform.instance = previousLocation;
      GoogleMapsFlutterPlatform.instance = previousMap;
    });
  });

  testWidgets('waits_for_a_real_location_before_creating_the_first_map', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: GoogleMapView()));
    await tester.pump();
    expect(find.byType(GoogleMap), findsNothing);
    expect(map.initialCameras, isEmpty);

    location.requests.single.complete(_position(37.5665, 126.9780));
    await tester.pump();
    await tester.pump();
    expect(map.initialCameras.single.target, const LatLng(37.5665, 126.9780));
    expect(map.cameraTargets, [const LatLng(37.5665, 126.9780)]);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  Future<void> mount(
    WidgetTester tester, {
    LatLng? center,
    GlobalKey<GoogleMapViewState>? key,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: GoogleMapView(
          key: key,
          initialTarget: center,
          onCameraMoveStarted: () {},
        ),
      ),
    );
    await tester.pump();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    });
  }

  testWidgets('immediate_gps_creates_the_map_at_the_current_location', (
    tester,
  ) async {
    location.immediatePosition = _position(35.1796, 129.0756);
    await mount(tester);
    expect(map.initialCameras.single.target, const LatLng(35.1796, 129.0756));
    expect(map.cameraTargets, [const LatLng(35.1796, 129.0756)]);
  });

  testWidgets(
    'late_startup_gps_keeps_the_game_area_and_manual_camera_position',
    (tester) async {
      await mount(tester, center: const LatLng(37.5665, 126.9780));
      expect(map.initialCameras.single.target, const LatLng(37.5665, 126.9780));
      // Native gesture has moved the viewport while the initial GPS is pending.
      map.cameraTargets.add(const LatLng(37.567, 126.979));
      map.cameraMoves.add(CameraMoveStartedEvent(map.createdIds.single));
      await tester.pump();
      location.requests.single.complete(_position(35.1796, 129.0756));
      await tester.pump();
      expect(map.cameraTargets.last, const LatLng(37.567, 126.979));
      expect(map.initialCameras, hasLength(1));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('failed_gps_keeps_the_game_area_and_current_location_can_retry', (
    tester,
  ) async {
    final key = GlobalKey<GoogleMapViewState>();
    await mount(tester, key: key, center: const LatLng(37.5665, 126.9780));
    location.requests.single.completeError(
      const PermissionDeniedException('denied'),
    );
    await tester.pump();
    expect(map.cameraTargets, [const LatLng(37.5665, 126.9780)]);
    final retry = key.currentState!.moveCameraToCurrentLocation();
    location.requests.last.complete(_position(37.5668, 126.9785));
    await tester.pump();
    await retry;
    expect(map.cameraTargets.last, const LatLng(37.5668, 126.9785));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'current_location_retry_initializes_map_when_both_sources_are_unavailable',
    (tester) async {
      final key = GlobalKey<GoogleMapViewState>();
      await mount(tester, key: key);
      location.requests.single.completeError(
        const LocationServiceDisabledException(),
      );
      await tester.pump();
      expect(find.byType(GoogleMap), findsNothing);
      final retry = key.currentState!.moveCameraToCurrentLocation();
      location.requests.last.complete(_position(37.5668, 126.9785));
      await tester.pump();
      await tester.pump();
      await retry;
      expect(map.initialCameras.single.target, const LatLng(37.5668, 126.9785));
      expect(tester.takeException(), isNull);
    },
  );

  for (final initialCompletesFirst in [true, false]) {
    testWidgets(
      'manual_location_supersedes_pending_startup_request_initialFirst_$initialCompletesFirst',
      (tester) async {
        final key = GlobalKey<GoogleMapViewState>();
        await mount(tester, key: key);
        final initial = location.requests.single;
        final retry = key.currentState!.moveCameraToCurrentLocation();
        if (initialCompletesFirst) {
          initial.complete(_position(35.1796, 129.0756));
          await tester.pump();
          expect(find.byType(GoogleMap), findsNothing);
        }
        location.requests.last.complete(_position(37.5668, 126.9785));
        await tester.pump();
        await tester.pump();
        await retry;
        if (!initialCompletesFirst) {
          initial.complete(_position(35.1796, 129.0756));
          await tester.pump();
        }
        expect(
          map.initialCameras.single.target,
          const LatLng(37.5668, 126.9785),
        );
        expect(map.cameraTargets, [const LatLng(37.5668, 126.9785)]);
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final fails in [false, true]) {
    testWidgets(
      'removed_map_ignores_pending_location_${fails ? "failure" : "success"}',
      (tester) async {
        await mount(tester);
        await tester.pumpWidget(const SizedBox());
        if (fails) {
          location.requests.single.completeError(
            const LocationServiceDisabledException(),
          );
        } else {
          location.requests.single.complete(_position(35.1796, 129.0756));
        }
        await tester.pump();
        expect(map.initialCameras, isEmpty);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('current_location_waits_for_native_map_creation', (tester) async {
    map.creationGate = Completer<void>();
    final key = GlobalKey<GoogleMapViewState>();
    await mount(tester, key: key, center: const LatLng(37.5665, 126.9780));
    final retry = key.currentState!.moveCameraToCurrentLocation();
    location.requests.last.complete(_position(37.5668, 126.9785));
    await tester.pump();
    await retry;
    expect(map.cameraTargets, [const LatLng(37.5665, 126.9780)]);

    map.creationGate!.complete();
    await tester.pump();
    location.requests.first.complete(_position(35.1796, 129.0756));
    await tester.pump();
    expect(map.cameraTargets.last, const LatLng(37.5668, 126.9785));
    expect(tester.takeException(), isNull);
  });
}
