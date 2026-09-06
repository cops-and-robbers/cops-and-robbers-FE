import 'dart:async';

import 'package:cops_and_robbers/core/services/lifecycle/app_lifecycle_service.dart';
import 'package:cops_and_robbers/core/widgets/dialogs/reconnect_modal.dart';
import 'package:cops_and_robbers/features/auth/presentation/providers/token_provider.dart';
import 'package:cops_and_robbers/features/chat/data/datasources/chat_stomp_datasource.dart';
import 'package:cops_and_robbers/features/chat/presentation/providers/chat_provider.dart';
import 'package:cops_and_robbers/features/game/data/datasources/game_event_stomp_datasource.dart';
import 'package:cops_and_robbers/features/game/data/datasources/game_system_api_datasource.dart';
import 'package:cops_and_robbers/features/game/data/models/game_area_model.dart';
import 'package:cops_and_robbers/features/game/presentation/pages/game_page.dart';
import 'package:cops_and_robbers/features/game/presentation/providers/game_event_provider.dart';
import 'package:cops_and_robbers/features/session/data/datasources/session_remote_datasource.dart';
import 'package:cops_and_robbers/features/session/data/models/in_game_participants_response.dart';
import 'package:cops_and_robbers/features/session/data/models/user_game_status_model.dart';
import 'package:cops_and_robbers/features/session/presentation/providers/game_participant_provider.dart';
import 'package:cops_and_robbers/features/session/presentation/providers/session_provider.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
// 지도 플러그인의 네이티브 경계만 교체한다 (앱 로직은 실제 객체 사용).
// ignore: depend_on_referenced_packages
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Location extends GeolocatorPlatform {
  final positions = StreamController<Position>.broadcast();
  @override
  Future<bool> isLocationServiceEnabled() async => true;
  @override
  Future<LocationPermission> checkPermission() async =>
      LocationPermission.always;
  @override
  Future<Position> getCurrentPosition({
    LocationSettings? locationSettings,
  }) async => position(true);
  @override
  Stream<Position> getPositionStream({LocationSettings? locationSettings}) =>
      positions.stream;

  Position position(bool inside) => Position(
    latitude: inside ? 37.5665 : 37.5668,
    longitude: 126.9780,
    timestamp: DateTime.now(),
    accuracy: 3,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 0,
    headingAccuracy: 0,
    speed: 0,
    speedAccuracy: 0,
  );
}

class _Map extends GoogleMapsFlutterPlatform {
  @override
  Widget buildViewWithConfiguration(
    int creationId,
    PlatformViewCreatedCallback onPlatformViewCreated, {
    required MapWidgetConfiguration widgetConfiguration,
    MapConfiguration mapConfiguration = const MapConfiguration(),
    MapObjects mapObjects = const MapObjects(),
  }) => const SizedBox.expand();
}

class _Socket extends GameEventStompDatasource {
  final connections = StreamController<StompConnectionState>.broadcast();
  StompConnectionState connection = StompConnectionState.disconnected;
  @override
  StompConnectionState get currentState => connection;
  @override
  Stream<StompConnectionState> get onConnectionState => connections.stream;
  void emit(StompConnectionState value) {
    connection = value;
    connections.add(value);
  }

  @override
  void connect(String wsUrl, String accessToken) =>
      emit(StompConnectionState.connected);
  @override
  void subscribeEvents(int gameId, {required String team}) {}
}

class _Chat extends ChatStompDatasource {
  @override
  void connect(String wsUrl, String accessToken) {}
}

class _Token implements TokenProvider {
  @override
  Future<String?> getAccessToken() async => 'test';
  @override
  Future<String?> refreshAccessTokenIfNeeded() async => 'test';
}

class _GameApi implements GameSystemApi {
  int escapes = 0;
  @override
  Future<void> escape(int gameId) async {
    escapes++;
  }

  @override
  Future<GameAreaModel> getArea(int gameId) async => const GameAreaModel(
    areaType: GameAreaType.circle,
    circle: CircleAreaModel(
      playgroundCenter: LatLngModel(latitude: 37.5665, longitude: 126.9780),
      playgroundRadiusInMeters: 500,
      jailCenter: LatLngModel(latitude: 37.5665, longitude: 126.9780),
      jailRadiusInMeters: 20,
    ),
  );
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _SessionApi implements SessionRemoteDataSource {
  int requests = 0;
  int failures = 0;
  @override
  Future<InGameParticipantsResponse> fetchGameParticipants(int gameId) async {
    requests++;
    if (failures-- > 0) throw Exception('temporary HTTP failure');
    return const InGameParticipantsResponse(
      police: [],
      robbers: [
        InGameParticipant(participantId: 5, nickname: '도둑', status: 'JAILED'),
      ],
    );
  }

  @override
  Future<UserGameStatusModel> getMyActiveGame() async =>
      const UserGameStatusModel(
        isParticipating: true,
        participationInfo: UserGameParticipationModel(
          gameId: 1,
          participantId: 5,
          gameStatus: 'IN_PROGRESS',
          team: 'ROBBER',
        ),
      );
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _Location location;
  late _Socket socket;
  late _GameApi game;
  late _SessionApi session;
  late ProviderContainer container;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    dotenv.loadFromString(envString: 'API_BASE_URL=http://localhost:8080');
    location = _Location();
    socket = _Socket();
    game = _GameApi();
    session = _SessionApi();
    final oldLocation = GeolocatorPlatform.instance;
    final oldMap = GoogleMapsFlutterPlatform.instance;
    GeolocatorPlatform.instance = location;
    GoogleMapsFlutterPlatform.instance = _Map();
    addTearDown(() {
      GeolocatorPlatform.instance = oldLocation;
      GoogleMapsFlutterPlatform.instance = oldMap;
      location.positions.close();
      socket.connections.close();
      socket.dispose();
    });
    container = ProviderContainer(
      overrides: [
        gameEventStompDatasourceProvider.overrideWithValue(socket),
        chatStompDatasourceProvider.overrideWithValue(_Chat()),
        gameSystemApiProvider.overrideWithValue(game),
        sessionRemoteDataSourceProvider.overrideWithValue(session),
        tokenProviderProvider.overrideWithValue(_Token()),
      ],
    );
    container.read(gameParticipantNotifierProvider.notifier)
      ..setGameInfo(gameId: 1, participantId: 5, nickname: '도둑', team: 'ROBBER')
      ..initFromLobby(participantId: 5, roundTimeMinutes: 30)
      ..setGameStartTime(
        DateTime.now().subtract(const Duration(minutes: 1)).toIso8601String(),
      );
    addTearDown(container.dispose);
  });

  Future<void> mount(WidgetTester tester) async {
    addTearDown(() async {
      if (tester.binding.lifecycleState == AppLifecycleState.paused) {
        for (final state in [
          AppLifecycleState.hidden,
          AppLifecycleState.inactive,
          AppLifecycleState.resumed,
        ]) {
          tester.binding.handleAppLifecycleStateChanged(state);
        }
      }
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    });
    tester.view.physicalSize = const Size(393, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: ScreenUtilInit(
          designSize: const Size(393, 852),
          builder: (_, _) => const MaterialApp(
            locale: Locale('ko'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: GamePage(sessionId: '1', team: 'ROBBER', participantId: 5),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  testWidgets('paused_reconnect_retries_sync_and_escapes_without_a_frame', (
    tester,
  ) async {
    await mount(tester);
    expect(session.requests, 1);
    socket.emit(StompConnectionState.disconnected);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(ReconnectModal), findsOneWidget);
    for (final state in [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(state);
    }
    // pause 직전에 예약된 마지막 프레임을 소비한 뒤, 실제 프레임 수를 감시한다.
    await tester.pump();
    var frames = 0;
    tester.binding.addPersistentFrameCallback((_) {
      frames++;
    });
    expect(tester.binding.framesEnabled, isFalse);
    session.failures = 1;
    socket.emit(StompConnectionState.connected);
    await tester.idle();
    // 프레임 예약이 없는 paused 상태: 가상 시계/마이크로태스크만 진행한다.
    expect(tester.binding.hasScheduledFrame, isFalse);
    await tester.pump(const Duration(seconds: 2));
    expect(session.requests, 3); // 초기 1 + 재연결 실패 1 + 자동 재시도 1
    for (final inside in [true, true, false, false]) {
      location.positions.add(location.position(inside));
      await tester.idle();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 2100)),
      );
    }
    expect(frames, 0);
    expect(game.escapes, 1);
    expect(container.read(gameEventNotifierProvider).escapedParticipantIds, {
      5,
    });
  });

  testWidgets('sync_retries_are_bounded_and_resume_recovers', (tester) async {
    session.failures = 3;
    await mount(tester);
    expect(session.requests, 1);
    await tester.pump(const Duration(seconds: 2));
    expect(session.requests, 2);
    await tester.pump(const Duration(seconds: 4));
    expect(session.requests, 3);
    await tester.pump(const Duration(seconds: 20));
    expect(session.requests, 3);
    AppLifecycleService.instance().didChangeAppLifecycleState(
      AppLifecycleState.paused,
    );
    await tester.pump();
    AppLifecycleService.instance().didChangeAppLifecycleState(
      AppLifecycleState.resumed,
    );
    await tester.pump();
    expect(session.requests, 4);
    expect(container.read(gameEventNotifierProvider).arrestedParticipantIds, {
      5,
    });
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets('connection_revision_does_not_dismiss_reconnect_modal', (
    tester,
  ) async {
    await mount(tester);
    socket.emit(StompConnectionState.error);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(ReconnectModal), findsOneWidget);
    socket.emit(StompConnectionState.disconnected);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(ReconnectModal), findsOneWidget);
    container.read(gameEventNotifierProvider.notifier).disconnect();
  });

  testWidgets('pending_sync_retry_stops_on_disconnect_and_dispose', (
    tester,
  ) async {
    session.failures = 10;
    await mount(tester);
    expect(session.requests, 1);
    final notifier = container.read(gameEventNotifierProvider.notifier);
    notifier.disconnect();
    await tester.pump();
    await tester.pump(const Duration(seconds: 10));
    expect(session.requests, 1);

    socket.connection = StompConnectionState.disconnected;
    await notifier.connectAndSubscribe(1, team: 'robber');
    await tester.pump();
    expect(session.requests, 2);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 10));
    expect(session.requests, 2);
  });
}
