// 방 생성 흐름 테스트가 같이 쓰는 시스템 경계 페이크.
// 네이티브 지도와 GPS만 대체한다. 구역 설정과 저장소 로직은 실제 객체를 사용한다.
import 'package:cops_and_robbers/core/constants/app_colors.dart';
import 'package:cops_and_robbers/core/widgets/map/zone_vertex_handle_icon.dart';
import 'package:cops_and_robbers/features/auth/data/datasources/firebase_auth_datasource.dart';
import 'package:cops_and_robbers/features/auth/presentation/providers/auth_provider.dart';
import 'package:cops_and_robbers/features/session/presentation/game_creation_entry.dart';
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
// ignore: depend_on_referenced_packages
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

const fakeGps = LatLng(37, 127);

class FakeLocation extends GeolocatorPlatform {
  Future<Position>? pending;
  final position = Position(
    latitude: fakeGps.latitude,
    longitude: fakeGps.longitude,
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

class FakeFirebaseAuth extends Fake implements FirebaseAuth {
  @override
  User? get currentUser => null;
}

class FakeMap extends MethodChannelGoogleMapsFlutter {
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

/// 앱 글꼴(Pretendard)을 불러온다.
///
/// 테스트 기본 글꼴(Ahem)은 글자마다 정사각형이라 한국어 문구가 실제보다 훨씬
/// 넓게 잡힌다. 확인 화면처럼 한 줄에 라벨과 값이 같이 있는 화면은 실제 글꼴로
/// 재야 오버플로가 진짜인지 알 수 있다.
Future<void> loadAppFonts() async {
  for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    final loader = FontLoader('Pretendard-$weight')
      ..addFont(rootBundle.load('assets/fonts/Pretendard-$weight.ttf'));
    await loader.load();
  }
}

/// 폰 크기(375x812 기준) 화면에 앱을 띄운다.
Future<void> pumpCreationApp(WidgetTester tester, Widget app) async {
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

/// 실제 앱의 생성·구역 route builder로 방 생성 흐름을 띄우고, 진입 버튼 'start'를 둔다.
///
/// 무관한 홈·인증 화면만 제외한다. 'start'를 누르면 생성 흐름이 열린다.
Future<ProviderContainer> pumpCreationFlow(
  WidgetTester tester, {
  int? communityPostId,
  LatLng? initialCenter,
}) async {
  final container = ProviderContainer(
    overrides: [
      firebaseAuthDataSourceProvider.overrideWithValue(
        FirebaseAuthDataSource(firebaseAuth: FakeFirebaseAuth()),
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
              communityPostId: communityPostId,
              initialCenter: initialCenter,
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
  await pumpCreationApp(
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
  return container;
}
