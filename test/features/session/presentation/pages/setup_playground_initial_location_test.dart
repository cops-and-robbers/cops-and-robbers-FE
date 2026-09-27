import 'dart:async';
import 'dart:convert';

import 'package:cops_and_robbers/core/constants/app_colors.dart';
import 'package:cops_and_robbers/core/widgets/buttons/my_location_button.dart';
import 'package:cops_and_robbers/core/widgets/map/zone_vertex_handle_icon.dart';
import 'package:cops_and_robbers/features/auth/data/datasources/firebase_auth_datasource.dart';
import 'package:cops_and_robbers/features/auth/presentation/providers/auth_provider.dart';
import 'package:cops_and_robbers/features/game/domain/entities/area_shape.dart';
import 'package:cops_and_robbers/features/session/presentation/game_creation_entry.dart';
import 'package:cops_and_robbers/features/session/presentation/pages/session_creation_flow_page.dart';
import 'package:cops_and_robbers/features/session/presentation/pages/setup_playground_page.dart';
import 'package:cops_and_robbers/features/session/presentation/pages/setup_prison_page.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:cops_and_robbers/router/app_router.dart';
import 'package:cops_and_robbers/router/route_paths.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// 네이티브 지도 경계만 대체한다. 구역 설정과 저장소 로직은 실제 객체를 사용한다.
// ignore: depend_on_referenced_packages
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _gps = LatLng(37, 127);
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

class _Location extends GeolocatorPlatform {
  Future<Position>? pending;
  final position = Position(
    latitude: _gps.latitude,
    longitude: _gps.longitude,
    timestamp: DateTime(2026),
    accuracy: 3,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 0,
    headingAccuracy: 0,
    speed: 0,
    speedAccuracy: 0,
  );

  @override
  Future<bool> isLocationServiceEnabled() async => true;
  @override
  Future<LocationPermission> checkPermission() async =>
      LocationPermission.always;
  @override
  Future<Position> getCurrentPosition({LocationSettings? locationSettings}) =>
      pending ?? Future.value(position);
}

class _FirebaseAuth extends Fake implements FirebaseAuth {
  @override
  User? get currentUser => null;
}

class _Map extends MethodChannelGoogleMapsFlutter {
  final centers = <int, LatLng>{};

  @override
  Future<void> updateGroundOverlays(
    GroundOverlayUpdates updates, {
    required int mapId,
  }) async {}

  @override
  Widget buildViewWithConfiguration(
    int creationId,
    PlatformViewCreatedCallback onPlatformViewCreated, {
    required MapWidgetConfiguration widgetConfiguration,
    MapConfiguration mapConfiguration = const MapConfiguration(),
    MapObjects mapObjects = const MapObjects(),
  }) {
    if (!centers.containsKey(creationId)) {
      centers[creationId] = widgetConfiguration.initialCameraPosition.target;
      final channel = ensureChannelInitialized(creationId);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'camera#animate') {
              final update = call.arguments['cameraUpdate'] as List<dynamic>;
              final coordinates = update[0] == 'newLatLng'
                  ? update[1] as List<dynamic>
                  : update[1]['target'] as List<dynamic>;
              centers[creationId] = LatLng(coordinates[0], coordinates[1]);
            }
            if (call.method == 'map#getScreenCoordinate') {
              return {'x': 100, 'y': 100};
            }
            if (call.method == 'map#getVisibleRegion') {
              final center = centers[creationId]!;
              return {
                'southwest': [center.latitude - .001, center.longitude - .001],
                'northeast': [center.latitude + .001, center.longitude + .001],
              };
            }
            return null;
          });
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null),
      );
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => onPlatformViewCreated(creationId),
      );
    }
    return const SizedBox.expand();
  }
}

Future<void> _pumpPage(WidgetTester tester, Widget page) => _pumpApp(
  tester,
  MaterialApp(
    locale: const Locale('ko'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: page,
  ),
);

Future<void> _pumpApp(WidgetTester tester, Widget app) async {
  tester.view.physicalSize = const Size(1125, 2436);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, _) => app,
      ),
    ),
  );
  // 실제 이미지 인코딩은 fake async 밖에서 끝낸다. GPS와 지도만 플랫폼 페이크다.
  // 플레이그라운드(파랑)·감옥(빨강) 핀 아이콘 모두 미리 캐시한다.
  await tester.runAsync(
    () => Future.wait([
      ZoneVertexHandleIcon.create(color: AppColors.blue),
      ZoneVertexHandleIcon.create(color: AppColors.red),
    ]),
  );
  await tester.pumpAndSettle();
}

LatLng _visibleCenter(WidgetTester tester) => tester
    .widget<GoogleMap>(find.byType(GoogleMap))
    .initialCameraPosition
    .target;

void main() {
  late _Location location;
  late _Map maps;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    final oldLocation = GeolocatorPlatform.instance;
    final oldMap = GoogleMapsFlutterPlatform.instance;
    GeolocatorPlatform.instance = location = _Location();
    GoogleMapsFlutterPlatform.instance = maps = _Map();
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
      final container = ProviderContainer(
        overrides: [
          firebaseAuthDataSourceProvider.overrideWithValue(
            FirebaseAuthDataSource(firebaseAuth: _FirebaseAuth()),
          ),
        ],
      );
      addTearDown(() {
        container.invalidate(routerProvider);
        container.invalidate(authNotifierProvider);
        container.dispose();
      });
      final appRouter = container.read(routerProvider);
      addTearDown(appRouter.dispose);
      // 실제 앱의 생성·구역 route builder를 그대로 사용한다. 무관한 홈/인증 화면만 제외한다.
      final creationRoute = appRouter.configuration.routes
          .whereType<StatefulShellRoute>()
          .single
          .branches
          .expand((branch) => branch.routes)
          .whereType<GoRoute>()
          .singleWhere((route) => route.path == RoutePaths.home)
          .routes
          .whereType<GoRoute>()
          .singleWhere((route) => route.path == 'create-session');
      final router = GoRouter(
        navigatorKey: rootNavigatorKey,
        initialLocation: '/entry',
        routes: [
          GoRoute(
            path: '/entry',
            builder: (context, _) => Consumer(
              builder: (context, ref, _) => TextButton(
                onPressed: () => startGameCreation(
                  context: context,
                  ref: ref,
                  communityPostId: 42,
                  initialCenter: _meeting,
                ),
                child: const Text('start'),
              ),
            ),
          ),
          GoRoute(
            path: RoutePaths.sessionCreationFlow,
            pageBuilder: creationRoute.pageBuilder,
            routes: creationRoute.routes,
          ),
        ],
      );
      addTearDown(router.dispose);
      await _pumpApp(
        tester,
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: router,
            locale: const Locale('ko'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          ),
        ),
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
