import 'dart:async';

import 'package:clock/clock.dart';
import 'package:cops_and_robbers/core/constants/app_colors.dart';
import 'package:cops_and_robbers/core/constants/app_icons.dart';
import 'package:cops_and_robbers/core/constants/map_styles.dart';
import 'package:cops_and_robbers/core/widgets/navigation/app_top_bar.dart';
import 'package:cops_and_robbers/core/widgets/buttons/previous_button.dart';
import 'package:cops_and_robbers/features/chat/presentation/providers/chat_notification_provider.dart';
import 'package:cops_and_robbers/core/widgets/buttons/svg_icon_button.dart';
import 'package:cops_and_robbers/core/widgets/buttons/my_location_button.dart';
import 'package:cops_and_robbers/core/widgets/chat/community_message_input.dart';
import 'package:cops_and_robbers/features/game/presentation/widgets/arrest_lock_overlay.dart';
import 'package:cops_and_robbers/features/game/presentation/widgets/google_map_view.dart';
import 'package:cops_and_robbers/features/game/presentation/widgets/jail_bars_overlay.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cops_and_robbers/features/game/data/models/game_event_model.dart';
import 'package:cops_and_robbers/core/services/lifecycle/app_lifecycle_service.dart';
import 'package:cops_and_robbers/core/widgets/dialogs/reconnect_modal.dart';
import 'package:cops_and_robbers/core/widgets/dialogs/app_popup.dart';
import 'package:cops_and_robbers/features/chat/data/datasources/chat_stomp_datasource.dart';
import 'package:cops_and_robbers/features/chat/data/models/chat_message_dto.dart';
import 'package:cops_and_robbers/features/chat/presentation/widgets/chat_preview_card.dart';
import 'package:cops_and_robbers/features/chat/presentation/providers/chat_provider.dart';
import 'package:cops_and_robbers/features/game/data/datasources/game_event_stomp_datasource.dart';
import 'package:cops_and_robbers/features/game/data/datasources/game_system_api_datasource.dart';
import 'package:cops_and_robbers/features/game/data/models/game_area_model.dart';
import 'package:cops_and_robbers/features/game/presentation/pages/game_page.dart';
import 'package:cops_and_robbers/features/game/presentation/providers/game_event_provider.dart';
import 'package:cops_and_robbers/features/session/data/datasources/session_remote_datasource.dart';
import 'package:cops_and_robbers/features/session/data/models/in_game_participants_response.dart';
import 'package:cops_and_robbers/features/session/data/models/game_settings_response.dart';
import 'package:cops_and_robbers/features/session/data/models/user_game_status_model.dart';
import 'package:cops_and_robbers/features/session/presentation/providers/game_participant_provider.dart';
import 'package:cops_and_robbers/features/session/presentation/providers/session_provider.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
// 지도 플러그인의 네이티브 경계만 교체한다 (앱 로직은 실제 객체 사용).
// ignore: depend_on_referenced_packages
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Location extends GeolocatorPlatform {
  final positions = StreamController<Position>.broadcast();
  bool inside = true;
  bool failCurrentPosition = false;
  @override
  Future<bool> isLocationServiceEnabled() async => true;
  @override
  Future<LocationPermission> checkPermission() async =>
      LocationPermission.always;
  @override
  Future<Position> getCurrentPosition({
    LocationSettings? locationSettings,
  }) async {
    if (failCurrentPosition) throw const LocationServiceDisabledException();
    return position(inside);
  }

  @override
  Future<Position?> getLastKnownPosition({
    bool forceLocationManager = false,
  }) async => null;
  @override
  Stream<Position> getPositionStream({LocationSettings? locationSettings}) =>
      positions.stream;

  Position position(bool inside) => Position(
    latitude: inside ? 37.5665 : 37.5668,
    longitude: 126.9780,
    timestamp: clock.now(),
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
  final events = StreamController<GameEventModel>.broadcast();
  @override
  Stream<GameEventModel> get onEvent => events.stream;
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

  /// false면 재연결 시도가 와도 연결하지 않는다 — 끊긴 상태를 유지하는 시나리오용.
  bool acceptConnect = true;

  @override
  void connect(String wsUrl, String accessToken) {
    if (acceptConnect) emit(StompConnectionState.connected);
  }

  @override
  void subscribeEvents(int gameId, {required String team}) {}
}

class _Chat extends ChatStompDatasource {
  final messages = StreamController<ChatMessageDto>.broadcast();
  @override
  Stream<ChatMessageDto> get onMessage => messages.stream;
  @override
  void connect(String wsUrl, String accessToken) {}
}

class _GameApi implements GameSystemApi {
  int escapes = 0;
  Completer<void>? escapeGate;

  /// 남은 횟수만큼 탈옥 요청을 실패시킨다. 요청 수(escapes)는 그대로 센다.
  int failures = 0;

  @override
  Future<void> escape(int gameId) async {
    escapes++;
    final gate = escapeGate;
    if (gate != null) await gate.future;
    if (failures-- > 0) throw Exception('temporary HTTP failure');
  }

  Completer<GameAreaModel>? areaGate;
  GameAreaModel area = const GameAreaModel(
    areaType: GameAreaType.circle,
    circle: CircleAreaModel(
      playgroundCenter: LatLngModel(latitude: 37.5665, longitude: 126.9780),
      playgroundRadiusInMeters: 500,
      jailCenter: LatLngModel(latitude: 37.5665, longitude: 126.9780),
      jailRadiusInMeters: 20,
    ),
  );
  @override
  Future<GameAreaModel> getArea(int gameId) =>
      areaGate?.future ?? Future.value(area);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _SessionApi implements SessionRemoteDataSource {
  int requests = 0;
  int failures = 0;
  late GameSettingsResponse settings;
  InGameParticipantsResponse participants = const InGameParticipantsResponse(
    police: [],
    robbers: [
      InGameParticipant(participantId: 5, nickname: '도둑', status: 'JAILED'),
    ],
  );

  @override
  Future<GameSettingsResponse> fetchGameSettings(int gameId) async => settings;

  @override
  Future<InGameParticipantsResponse> fetchGameParticipants(int gameId) async {
    requests++;
    if (failures-- > 0) throw Exception('temporary HTTP failure');
    return participants;
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
  late _Chat chat;
  late _GameApi game;
  late _SessionApi session;
  late ProviderContainer container;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({'access_token': 'test'});
    dotenv.loadFromString(envString: 'API_BASE_URL=http://localhost:8080');
    location = _Location();
    socket = _Socket();
    chat = _Chat();
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
      socket.events.close();
      chat.messages.close();
      socket.dispose();
    });
    container = ProviderContainer(
      overrides: [
        gameEventStompDatasourceProvider.overrideWithValue(socket),
        chatStompDatasourceProvider.overrideWithValue(chat),
        gameSystemApiProvider.overrideWithValue(game),
        sessionRemoteDataSourceProvider.overrideWithValue(session),
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

  Future<void> mount(
    WidgetTester tester, {
    Size size = const Size(393, 1200),
    String team = 'ROBBER',
    Locale locale = const Locale('ko'),
    double textScale = 1,
  }) async {
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
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: ScreenUtilInit(
          designSize: const Size(393, 852),
          builder: (_, _) => MaterialApp(
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(textScale)),
              child: child!,
            ),
            home: GamePage(sessionId: '1', team: team, participantId: 5),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  /// 위치 하나를 보내고 위치 콜백까지 처리한다.
  Future<void> sendPosition(WidgetTester tester, {required bool inside}) async {
    location.inside = inside;
    location.positions.add(location.position(inside));
    await tester.pump();
  }

  for (final isPolygon in [false, true]) {
    testWidgets(
      'initial_map_uses_delayed_game_area_with_bounds_when_gps_fails_polygon_$isPolygon',
      (tester) async {
        location.failCurrentPosition = true;
        game.areaGate = Completer<GameAreaModel>();
        if (isPolygon) {
          game.area = const GameAreaModel(
            areaType: GameAreaType.polygon,
            polygon: PolygonAreaModel(
              playgroundPolygon: [
                LatLngModel(latitude: 37.56, longitude: 126.97),
                LatLngModel(latitude: 37.57, longitude: 126.97),
                LatLngModel(latitude: 37.57, longitude: 126.98),
                LatLngModel(latitude: 37.56, longitude: 126.98),
              ],
              jailPolygon: [
                LatLngModel(latitude: 37.565, longitude: 126.975),
                LatLngModel(latitude: 37.566, longitude: 126.975),
                LatLngModel(latitude: 37.566, longitude: 126.976),
              ],
            ),
          );
        }
        await mount(tester);
        final mapState = tester.state<GoogleMapViewState>(
          find.byType(GoogleMapView),
        );
        expect(find.byType(GoogleMap), findsNothing);
        expect(
          tester
              .widget<MyLocationButton>(find.byType(MyLocationButton))
              .isFocused,
          isFalse,
        );

        game.areaGate!.complete(game.area);
        await tester.pump();
        await tester.pump();
        expect(
          tester.state<GoogleMapViewState>(find.byType(GoogleMapView)),
          same(mapState),
        );
        final map = tester.widget<GoogleMap>(find.byType(GoogleMap));
        final target = map.initialCameraPosition.target;
        expect(target.latitude, closeTo(isPolygon ? 37.565 : 37.5665, 1e-9));
        expect(target.longitude, closeTo(isPolygon ? 126.975 : 126.9780, 1e-9));
        expect(map.cameraTargetBounds.bounds!.contains(target), isTrue);
        expect(
          map.cameraTargetBounds.bounds!.contains(
            const LatLng(35.1796, 129.0756),
          ),
          isFalse,
        );
        expect(map.minMaxZoomPreference.minZoom, isPolygon ? 13 : 14);
        expect(map.myLocationEnabled, isTrue);
        expect(
          map.polygons.any((p) => p.polygonId.value == 'outside_overlay'),
          isTrue,
        );
        if (isPolygon) {
          expect(map.circles, isEmpty);
          expect(
            map.polygons
                .singleWhere((p) => p.polygonId.value == 'playground_border')
                .points,
            [
              const LatLng(37.56, 126.97),
              const LatLng(37.57, 126.97),
              const LatLng(37.57, 126.98),
              const LatLng(37.56, 126.98),
            ],
          );
        } else {
          expect(map.circles.map((c) => c.circleId.value).toSet(), {
            'playground',
            'jail',
          });
        }
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('경찰 재접속 시 설정을 불러와도 대기 팝업은 한 번만 열리고 만료되면 닫힌다', (tester) async {
    container
        .read(gameParticipantNotifierProvider.notifier)
        .setGameInfo(
          gameId: 1,
          participantId: 5,
          nickname: '경찰',
          team: 'POLICE',
        );
    session.settings = GameSettingsResponse(
      roundDurationMinutes: 30,
      locationRevealIntervalMinutes: 3,
      policeWaitMinutes: 1,
      maxParticipants: 10,
      gameStartTime: DateTime.now().toIso8601String(),
    );
    session.participants = const InGameParticipantsResponse(
      police: [
        InGameParticipant(
          participantId: 5,
          nickname: '경찰',
          status: 'POLICE_WAITING',
        ),
      ],
      robbers: [],
    );
    await mount(tester, team: 'POLICE');
    expect(find.byType(AppPopup, skipOffstage: false), findsOneWidget);

    await tester.pump(const Duration(seconds: 61));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(AppPopup, skipOffstage: false), findsNothing);
    expect(find.byType(GamePage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final variant in [
    (team: 'POLICE', locale: 'ko', width: 393.0, scale: 1.0),
    (team: 'ROBBER', locale: 'ko', width: 393.0, scale: 1.0),
    (team: 'POLICE', locale: 'en', width: 320.0, scale: 1.5),
    (team: 'ROBBER', locale: 'ja', width: 320.0, scale: 1.5),
  ]) {
    testWidgets(
      'chat_preview_anchors_beside_button_and_opens_channel_$variant',
      (tester) async {
        tester.view.padding = const FakeViewPadding(bottom: 34);
        tester.view.viewPadding = const FakeViewPadding(bottom: 34);
        addTearDown(tester.view.resetPadding);
        addTearDown(tester.view.resetViewPadding);
        await mount(
          tester,
          size: Size(variant.width, 852),
          team: variant.team,
          locale: Locale(variant.locale),
          textScale: variant.scale,
        );
        final l10n = AppLocalizations.of(tester.element(find.byType(GamePage)));
        final chatButton = find.byWidgetPredicate(
          (w) => w is SvgIconButton && w.assetPath == AppIcons.comment,
        );
        final message = ChatMessageDto(
          id: 'preview-1',
          gameId: 1,
          sender: const ChatSenderDto(
            participantId: 11,
            nickname: '아주 긴 닉네임의 참가자',
            team: 'POLICE',
          ),
          message: '정문 앞에서 만나서 같이 이동해요. 긴 메시지도 한 줄로 보여요.',
          timestamp: DateTime.now().toIso8601String(),
          scope: 'ALL',
        );
        chat.messages.add(message);
        await tester.pump();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));
        await tester.pump(const Duration(milliseconds: 350));
        final preview = find.byType(ChatPreviewCard);
        expect(
          tester
              .widget<FadeTransition>(
                find.descendant(
                  of: preview,
                  matching: find.byType(FadeTransition),
                ),
              )
              .opacity
              .value,
          1,
        );
        // 말풍선 본체가 채팅 버튼 왼쪽, 버튼 세로 중앙 높이에 바닥을 두고
        // 왼쪽 내 위치 버튼은 침범하지 않는다.
        final bubble = find.byKey(ChatPreviewCard.bubbleKey);
        final cardRect = tester.getRect(bubble);
        final buttonRect = tester.getRect(chatButton);
        expect(cardRect.right, lessThan(buttonRect.left));
        expect(buttonRect.left - cardRect.right, lessThanOrEqualTo(8.5));
        expect(
          cardRect.left,
          greaterThan(tester.getRect(find.byType(MyLocationButton)).right),
        );
        expect(cardRect.bottom, closeTo(buttonRect.center.dy, 0.5));
        expect(cardRect.height, greaterThanOrEqualTo(44));
        expect(
          find.descendant(of: preview, matching: find.text(message.message)),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: preview,
            matching: find.text(message.sender.nickname),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(of: preview, matching: find.text('+1')),
          findsNothing,
        );
        expect(container.read(chatNotifierProvider).unreadAllCount, 1);
        expect(tester.takeException(), isNull);

        await tester.pump(const Duration(seconds: 3));
        await tester.pump(const Duration(milliseconds: 250));
        await tester.pump();
        expect(preview, findsNothing);
        expect(container.read(chatNotifierProvider).unreadAllCount, 1);

        chat.messages.add(message.copyWith(id: 'preview-2'));
        await tester.pump();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));
        await tester.tap(preview);
        await tester.pump();
        expect(
          find.byWidgetPredicate(
            (w) =>
                w is Semantics &&
                w.properties.label == l10n.chatScopeAllTitle &&
                w.properties.selected == true,
          ),
          findsOneWidget,
        );
        expect(find.byType(CommunityMessageInput), findsOneWidget);
        expect(container.read(chatNotifierProvider).unreadAllCount, 0);
        expect(preview, findsNothing);
        await tester.tap(find.byTooltip(l10n.gameChatBackToMap));
        await tester.pump();

        chat.messages.add(message.copyWith(id: 'preview-3', scope: 'TEAM'));
        await tester.pump();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));
        await tester.tap(preview);
        await tester.pump();
        expect(container.read(chatNotifierProvider).unreadTeamCount, 0);
        expect(
          find.byWidgetPredicate(
            (w) =>
                w is Semantics &&
                w.properties.label == l10n.chatScopeTeamTitle &&
                w.properties.selected == true,
          ),
          findsOneWidget,
        );
        await tester.tap(find.byTooltip(l10n.communityMenuNotificationOff));
        await tester.pump();
        await tester.tap(find.byTooltip(l10n.gameChatBackToMap));
        await tester.pump();
        chat.messages.add(message.copyWith(id: 'preview-muted'));
        await tester.pump();
        expect(preview, findsNothing);
        expect(container.read(chatNotifierProvider).unreadAllCount, 1);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('chat_app_bar_restores_game_controls_when_returning_to_map', (
    tester,
  ) async {
    var now = DateTime.now();
    final start = now.subtract(const Duration(seconds: 64, milliseconds: 500));
    container.read(gameParticipantNotifierProvider.notifier)
      ..setGameStartTime(start.toIso8601String())
      ..updateSettings(policeWaitMinutes: 1, locationRevealIntervalMinutes: 3);
    await withClock(Clock(() => now), () async {
      await mount(tester, size: const Size(393, 852));
      final l10n = AppLocalizations.of(tester.element(find.byType(GamePage)));
      void expectCountdowns(String game, String reveal) {
        expect(find.text(game), findsOneWidget);
        expect(
          find.text(l10n.gameLocationRevealCountdown(reveal)),
          findsOneWidget,
        );
      }

      expectCountdowns('28:55', '02:55');
      final chatButton = find.byWidgetPredicate(
        (w) => w is SvgIconButton && w.assetPath == AppIcons.comment,
      );
      expect(find.byTooltip(l10n.buttonLeave), findsOneWidget);
      expect(find.byTooltip(l10n.titleGameRules), findsOneWidget);

      now = now.add(const Duration(seconds: 1));
      await tester.tap(chatButton);
      container
          .read(chatNotifierProvider.notifier)
          .enableDummyMode(participantId: 5, team: 'ROBBER');
      await tester.pump();
      expect(find.byTooltip(l10n.buttonLeave), findsNothing);
      expect(find.byTooltip(l10n.titleGameRules), findsNothing);
      expect(find.text(l10n.gameChatTitle), findsNothing);
      expect(
        find.descendant(
          of: find.byType(AppTopBar),
          matching: find.byType(PreviousButton),
        ),
        findsOneWidget,
      );
      for (final label in [
        l10n.gameChatBackToMap,
        l10n.communityMenuNotificationOff,
      ]) {
        expect(
          find.descendant(
            of: find.byType(AppTopBar),
            matching: find.byTooltip(label),
          ),
          findsOneWidget,
        );
      }
      expectCountdowns('28:54', '02:54');

      await tester.tap(find.byTooltip(l10n.communityMenuNotificationOff));
      await tester.pump();
      expect(container.read(chatNotificationEnabledProvider), isFalse);
      expect(container.read(chatNotifierProvider).lastPreviewMessage, isNull);
      expect(find.byTooltip(l10n.communityMenuNotificationOn), findsOneWidget);

      await tester.enterText(find.byType(TextField), '작성 중인 초안');
      final inputFocus = tester
          .widget<TextField>(find.byType(TextField))
          .focusNode!;
      expect(inputFocus.hasFocus, isTrue);
      now = now.add(const Duration(seconds: 1));
      await tester.tap(find.byTooltip(l10n.gameChatBackToMap));
      await tester.pump();
      expect(inputFocus.hasFocus, isFalse);
      expect(find.byType(CommunityMessageInput), findsNothing);
      expect(find.byTooltip(l10n.buttonLeave), findsOneWidget);
      expect(find.byTooltip(l10n.titleGameRules), findsOneWidget);
      expectCountdowns('28:53', '02:53');

      await tester.tap(chatButton);
      await tester.pump();
      expect(find.text('작성 중인 초안'), findsOneWidget);
      expect(find.byTooltip(l10n.communityMenuNotificationOn), findsOneWidget);
      await tester.tap(find.byTooltip(l10n.communityMenuNotificationOn));
      await tester.pump();
      expect(container.read(chatNotificationEnabledProvider), isTrue);
      expect(find.byTooltip(l10n.communityMenuNotificationOff), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pump();
      expect(find.byType(CommunityMessageInput), findsNothing);
      expect(find.byTooltip(l10n.buttonLeave), findsOneWidget);
      socket.events.add(
        GameEventModel(
          type: GameEventType.policeMoveStart,
          timestamp: start
              .add(const Duration(minutes: 1, milliseconds: 800))
              .toIso8601String(),
        ),
      );
      await tester.pump();
      expectCountdowns('28:53', '02:53');
      now = now.add(const Duration(milliseconds: 8800));
      await tester.pump(const Duration(milliseconds: 8800));
      expectCountdowns('28:44', '02:44');
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('chat_channels_preserve_drafts_and_send_to_the_selected_scope', (
    tester,
  ) async {
    await mount(tester);
    final chatButton = find.byWidgetPredicate(
      (w) => w is SvgIconButton && w.assetPath == AppIcons.comment,
    );
    await tester.tap(chatButton);
    container
        .read(chatNotifierProvider.notifier)
        .enableDummyMode(participantId: 5, team: 'ROBBER');
    await tester.pump();
    final l10n = AppLocalizations.of(
      tester.element(find.byType(CommunityMessageInput)),
    );
    await tester.enterText(find.byType(TextField), '팀 초안');
    expect(find.text(l10n.gameChatTeamInputHint), findsOneWidget);
    await tester.tap(find.textContaining(l10n.chatScopeAllTitle));
    await tester.pump(const Duration(milliseconds: 350));
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
    expect(find.text(l10n.gameChatAllInputHint), findsOneWidget);
    await tester.enterText(find.byType(TextField), '전체 초안');
    await tester.drag(find.byType(PageView), const Offset(350, 0));
    await tester.pump(const Duration(milliseconds: 350));
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '팀 초안',
    );
    expect(
      tester.widget<TextField>(find.byType(TextField)).focusNode!.hasFocus,
      isTrue,
    );
    await tester.tap(
      find.byWidgetPredicate(
        (w) =>
            w is SvgPicture &&
            w.bytesLoader is SvgAssetLoader &&
            (w.bytesLoader as SvgAssetLoader).assetName == AppIcons.sending,
      ),
    );
    await tester.pump();
    expect(
      container.read(chatNotifierProvider).teamScopeMessages.last.message,
      '팀 초안',
    );
    await tester.drag(find.byType(PageView), const Offset(-350, 0));
    await tester.pump(const Duration(milliseconds: 350));
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '전체 초안',
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.byTooltip(l10n.gameChatBackToMap));
    await tester.pump();
    await tester.tap(chatButton);
    await tester.pump();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '전체 초안',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('chat_channels_restore_independent_scroll_positions', (
    tester,
  ) async {
    await mount(tester);
    await tester.tap(
      find.byWidgetPredicate(
        (w) => w is SvgIconButton && w.assetPath == AppIcons.comment,
      ),
    );
    final notifier = container.read(chatNotifierProvider.notifier);
    notifier.enableDummyMode(participantId: 5, team: 'ROBBER');
    for (final scope in ['TEAM', 'ALL']) {
      for (var i = 0; i < 60; i++) {
        notifier.sendMessage(
          gameId: 1,
          message: '$scope message $i',
          scope: scope,
        );
      }
    }
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    final l10n = AppLocalizations.of(
      tester.element(find.byType(CommunityMessageInput)),
    );
    double offset(int page) => tester
        .widget<ListView>(
          find.descendant(
            of: find.byKey(PageStorageKey('game-chat-1-$page')),
            matching: find.byType(ListView),
          ),
        )
        .controller!
        .offset;
    await tester.drag(find.byType(PageView), const Offset(0, 400));
    await tester.pump(const Duration(seconds: 1));
    final teamOffset = offset(1);
    expect(teamOffset, greaterThan(200));
    await tester.tap(find.textContaining(l10n.chatScopeAllTitle));
    await tester.pump(const Duration(milliseconds: 350));
    expect(offset(0), 0);
    await tester.drag(find.byType(PageView), const Offset(0, 700));
    await tester.pump(const Duration(seconds: 1));
    final allOffset = offset(0);
    expect(allOffset, greaterThan(200));
    await tester.drag(find.byType(PageView), const Offset(350, 0));
    // 스크롤 위치 복원에 따른 레이아웃과 페이지 스냅을 프레임별로 진행한다.
    for (var frame = 0; frame < 60; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(
      tester.widget<PageView>(find.byType(PageView)).controller!.page,
      closeTo(0, 0.001),
    );
    expect(offset(1), closeTo(teamOffset, 1));
    await tester.tap(find.textContaining(l10n.chatScopeAllTitle));
    await tester.pump(const Duration(milliseconds: 350));
    expect(offset(0), closeTo(allOffset, 1));
    expect(tester.takeException(), isNull);
  });

  for (final variant in [
    (team: 'ROBBER', locale: 'ko', width: 393.0, scale: 1.0),
    (team: 'POLICE', locale: 'ko', width: 393.0, scale: 1.0),
    (team: 'ROBBER', locale: 'en', width: 320.0, scale: 1.5),
    (team: 'POLICE', locale: 'ja', width: 320.0, scale: 1.5),
  ]) {
    testWidgets('chat_stays_readable_and_sends_in_selected_scope_$variant', (
      tester,
    ) async {
      await mount(
        tester,
        size: Size(variant.width, 852),
        team: variant.team,
        locale: Locale(variant.locale),
        textScale: variant.scale,
      );
      await tester.tap(
        find.byWidgetPredicate(
          (w) => w is SvgIconButton && w.assetPath == AppIcons.comment,
        ),
      );
      await tester.pump();
      final l10n = AppLocalizations.of(
        tester.element(find.byType(CommunityMessageInput)),
      );
      expect(find.text(l10n.gameChatTeamHint), findsOneWidget);
      await tester.tap(find.text(l10n.chatScopeAllTitle));
      await tester.pump(const Duration(milliseconds: 350));
      expect(find.text(l10n.gameChatAllHint), findsOneWidget);
      container
          .read(chatNotifierProvider.notifier)
          .enableDummyMode(participantId: 5, team: variant.team);
      await tester.pump();
      await tester.enterText(find.byType(TextField), '여기서 만나요');
      await tester.pump();
      await tester.tap(
        find.byWidgetPredicate(
          (w) =>
              w is SvgPicture &&
              w.bytesLoader is SvgAssetLoader &&
              (w.bytesLoader as SvgAssetLoader).assetName == AppIcons.sending,
        ),
      );
      await tester.pump();
      expect(
        container.read(chatNotifierProvider).allScopeMessages.last.message,
        '여기서 만나요',
      );
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
      await tester.pump(const Duration(milliseconds: 350));
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);
      await tester.pump();
      expect(
        tester.getBottomLeft(find.byType(TextField)).dy,
        lessThanOrEqualTo(552),
      );
      expect(tester.takeException(), isNull);
      // 기존 더미 전송은 1초 뒤 상대 응답을 만든다.
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.byTooltip(l10n.gameChatBackToMap));
      await tester.pump();
      expect(find.byType(CommunityMessageInput), findsNothing);
    });
  }

  for (final size in [const Size(393, 852), const Size(320, 640)]) {
    testWidgets(
      'jailed_map_stays_visible_and_buttons_open_close_info_and_chat_$size',
      (tester) async {
        await mount(tester, size: size);
        expect(find.byType(ArrestLockOverlay), findsNothing);
        final map = tester.widget<GoogleMap>(find.byType(GoogleMap));
        expect(map.style, MapStyles.dark);
        expect(map.scrollGesturesEnabled, isTrue);
        expect(map.zoomGesturesEnabled, isTrue);
        final jail = map.circles.singleWhere((c) => c.circleId.value == 'jail');
        expect(jail.fillColor, AppColors.yellowAlpha20);
        expect(jail.radius, 20);
        final jailButton = find.byWidgetPredicate(
          (w) => w is SvgIconButton && w.assetPath.endsWith('/jailed.svg'),
        );
        final chatButton = find.byWidgetPredicate(
          (w) => w is SvgIconButton && w.assetPath == AppIcons.comment,
        );
        expect(
          tester.getCenter(jailButton).dx,
          tester.getCenter(chatButton).dx,
        );
        expect(
          tester.getBottomLeft(jailButton).dy,
          lessThan(tester.getTopLeft(chatButton).dy),
        );
        await tester.tap(jailButton);
        await tester.pump();
        expect(find.byType(ArrestLockOverlay), findsOneWidget);
        expect(find.widgetWithText(TextButton, '닫기'), findsNothing);
        expect(
          tester.getCenter(find.text('체포되었어요!')).dx,
          closeTo(size.width / 2, 0.1),
        );
        await tester.tapAt(const Offset(16, 100));
        await tester.pump();
        expect(find.byType(ArrestLockOverlay), findsNothing);

        await tester.tap(
          find.byWidgetPredicate(
            (w) => w is SvgIconButton && w.assetPath == AppIcons.comment,
          ),
        );
        await tester.pump();
        expect(find.text('팀원에게만 메시지가 보여요'), findsOneWidget);
        expect(find.byTooltip('지도 보기'), findsOneWidget);
        await tester.tap(find.byTooltip('지도 보기'));
        await tester.pump();

        container
            .read(chatNotifierProvider.notifier)
            .enableDummyMode(participantId: 5, team: 'ROBBER');
        await tester.pump();
        await tester.tap(
          find.byWidgetPredicate(
            (w) => w is SvgIconButton && w.assetPath == AppIcons.comment,
          ),
        );
        await tester.pump();
        expect(find.byType(CommunityMessageInput), findsOneWidget);
        await tester.enterText(find.byType(TextField), '작성 중인 메시지');
        await tester.tap(find.byTooltip('지도 보기'));
        await tester.pump();
        expect(find.byType(CommunityMessageInput), findsNothing);
        // 닫힌 동안 미리보기가 추가·제거되어도 작성 중 입력은 보존한다.
        container
            .read(chatNotifierProvider.notifier)
            .enableDummyMode(participantId: 5, team: 'ROBBER');
        await tester.pump();
        await tester.tap(
          find.byWidgetPredicate(
            (w) => w is SvgIconButton && w.assetPath == AppIcons.comment,
          ),
        );
        await tester.pump();
        expect(find.text('작성 중인 메시지'), findsOneWidget);
        await tester.tap(find.textContaining('전체 채팅').first);
        await tester.pump();
        expect(container.read(chatNotifierProvider).unreadAllCount, 0);
        tester.view.viewInsets = const FakeViewPadding(bottom: 260);
        addTearDown(tester.view.resetViewInsets);
        await tester.pump();
        expect(
          tester.getBottomLeft(find.byType(TextField)).dy,
          lessThanOrEqualTo(size.height - 260),
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('jailed_button_replaces_robber_qr_button_until_escape', (
    tester,
  ) async {
    await mount(tester, size: const Size(393, 852));
    final l10n = AppLocalizations.of(tester.element(find.byType(GamePage)));
    final jailButton = find.byWidgetPredicate(
      (w) => w is SvgIconButton && w.assetPath.endsWith('/jailed.svg'),
    );
    final qrButton = find.byWidgetPredicate(
      (w) => w is SvgIconButton && w.assetPath == AppIcons.qrCode,
    );
    expect(jailButton, findsOneWidget);
    expect(qrButton, findsNothing);

    // 참가자 화면의 오른쪽 버튼 줄에서도 QR 대신 수감 버튼이 보인다.
    await tester.tap(
      find.byWidgetPredicate(
        (w) => w is SvgIconButton && w.assetPath == AppIcons.person,
      ),
    );
    await tester.pump();
    expect(jailButton, findsOneWidget);
    expect(qrButton, findsNothing);
    await tester.tap(
      find.byWidgetPredicate(
        (w) => w is SvgIconButton && w.assetPath == AppIcons.map,
      ),
    );
    await tester.pump();

    // 누르면 기존 수감 안내 → "탈옥하기" → 확인
    await tester.tap(jailButton);
    await tester.pump();
    expect(find.byType(ArrestLockOverlay), findsOneWidget);
    await tester.tap(find.text(l10n.gameArrestOverlayEscapeCompleteButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text(l10n.buttonEscape).last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(game.escapes, 1);

    // 풀리면 QR 버튼이 돌아온다.
    expect(qrButton, findsOneWidget);
    expect(jailButton, findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('police_keeps_qr_scanner_button_when_a_robber_is_jailed', (
    tester,
  ) async {
    container.read(gameParticipantNotifierProvider.notifier)
      ..setGameInfo(gameId: 1, participantId: 5, nickname: '경찰', team: 'POLICE')
      ..initFromLobby(participantId: 5, roundTimeMinutes: 30)
      ..setGameStartTime(
        DateTime.now().subtract(const Duration(minutes: 1)).toIso8601String(),
      );
    session.settings = GameSettingsResponse(
      roundDurationMinutes: 30,
      locationRevealIntervalMinutes: 3,
      policeWaitMinutes: 0,
      maxParticipants: 10,
      gameStartTime: DateTime.now()
          .subtract(const Duration(minutes: 1))
          .toIso8601String(),
    );
    session.participants = const InGameParticipantsResponse(
      police: [
        InGameParticipant(participantId: 5, nickname: '경찰', status: 'ALIVE'),
      ],
      robbers: [
        InGameParticipant(participantId: 7, nickname: '도둑', status: 'JAILED'),
      ],
    );
    await mount(tester, team: 'POLICE');
    expect(
      find.byWidgetPredicate(
        (w) => w is SvgIconButton && w.assetPath == AppIcons.qrScan,
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (w) => w is SvgIconButton && w.assetPath.endsWith('/jailed.svg'),
      ),
      findsNothing,
    );
  });

  testWidgets(
    'jailed_button_stays_after_reconnect_when_robber_was_arrested_outside_playground',
    (tester) async {
      await withClock(Clock(() => tester.binding.clock.now()), () async {
        session.participants = const InGameParticipantsResponse(
          police: [],
          robbers: [
            InGameParticipant(
              participantId: 5,
              nickname: '도둑',
              status: 'ALIVE',
            ),
          ],
        );
        await mount(tester);
        // 플레이그라운드(반경 500m) 밖 600m에서 체포된다.
        location.positions.add(
          Position(
            latitude: 37.5665 + 600 / 111320,
            longitude: 126.9780,
            timestamp: clock.now(),
            accuracy: 3,
            altitude: 0,
            altitudeAccuracy: 0,
            heading: 0,
            headingAccuracy: 0,
            speed: 0,
            speedAccuracy: 0,
          ),
        );
        await tester.pump();
        session.participants = const InGameParticipantsResponse(
          police: [],
          robbers: [
            InGameParticipant(
              participantId: 5,
              nickname: '도둑',
              status: 'JAILED',
            ),
          ],
        );
        socket.events.add(
          GameEventModel(
            type: GameEventType.arrest,
            data: {
              'police': {
                'participantId': 2,
                'nickname': '경찰',
                'status': 'ALIVE',
              },
              'robber': {
                'participantId': 5,
                'nickname': '도둑',
                'status': 'JAILED',
              },
              'remainingThieves': 0,
            },
          ),
        );
        await tester.pump();
        await sendPosition(tester, inside: true);

        // 수감 중 재연결 — 체포 전의 구역 이탈 상태가 경고로 되살아나면
        // 오른쪽 버튼 줄이 숨어 그 자리의 수감 버튼까지 사라진다.
        socket.emit(StompConnectionState.disconnected);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        socket.emit(StompConnectionState.connected);
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        expect(find.byType(JailBarsOverlay), findsOneWidget);
        expect(
          find.byWidgetPredicate(
            (w) => w is SvgIconButton && w.assetPath.endsWith('/jailed.svg'),
          ),
          findsOneWidget,
        );
        // 체포 알림 배너 타이머를 끝내 종료 시 남는 타이머를 없앤다.
        await tester.pump(const Duration(seconds: 9));
      });
    },
  );

  testWidgets(
    'escape_confirmation_left_open_is_harmless_when_auto_escape_wins',
    (tester) async {
      await withClock(Clock(() => tester.binding.clock.now()), () async {
        await mount(tester);
        final l10n = AppLocalizations.of(tester.element(find.byType(GamePage)));
        await sendPosition(tester, inside: true);
        // 수동 탈옥 확인창을 열어 둔다.
        await tester.tap(
          find.byWidgetPredicate(
            (w) => w is SvgIconButton && w.assetPath.endsWith('/jailed.svg'),
          ),
        );
        await tester.pump();
        await tester.tap(find.text(l10n.gameArrestOverlayEscapeCompleteButton));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // 그 사이 감옥 밖으로 나가 자동 탈옥이 먼저 끝난다.
        await sendPosition(tester, inside: false);
        await tester.pump(const Duration(seconds: 3));
        await sendPosition(tester, inside: false);
        await tester.pump(const Duration(milliseconds: 300));
        expect(game.escapes, 1);
        expect(find.byType(ArrestLockOverlay), findsNothing);

        // 남아 있던 확인창을 눌러도 예외 없이 무시된다.
        await tester.tap(find.text(l10n.buttonEscape).last);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull);
        expect(game.escapes, 1);
      });
    },
  );

  testWidgets(
    'jailed_map_keeps_robber_style_and_is_covered_by_jail_bars_below_app_bar',
    (tester) async {
      await mount(tester, size: const Size(393, 852));
      // 지도 스타일은 교체하지 않는다 — 창살 오버레이가 수감 상태를 표현한다.
      expect(
        tester.widget<GoogleMap>(find.byType(GoogleMap)).style,
        MapStyles.dark,
      );
      expect(find.byType(JailBarsOverlay), findsOneWidget);
      final bars = find.descendant(
        of: find.byType(JailBarsOverlay),
        matching: find.byType(CustomPaint),
      );
      // 앱바(타이머) 바로 아래부터 화면 바닥까지 끊김 없이 덮는다.
      expect(
        tester.getTopLeft(bars).dy,
        closeTo(tester.getBottomLeft(find.byType(AppTopBar)).dy, 0.1),
      );
      expect(tester.getBottomLeft(bars).dy, closeTo(852, 0.1));
    },
  );

  testWidgets('jail_bars_disappear_when_robber_escapes', (tester) async {
    await mount(tester, size: const Size(393, 852));
    expect(find.byType(JailBarsOverlay), findsOneWidget);
    await container.read(gameEventNotifierProvider.notifier).escape(1, 5);
    await tester.pump();
    expect(find.byType(JailBarsOverlay), findsNothing);
  });

  testWidgets(
    'jail_highlight_pulses_and_restores_circle_and_polygon_geometry',
    (tester) async {
      await mount(tester);
      final mapState = tester.state<GoogleMapViewState>(
        find.byType(GoogleMapView),
      );
      const polygon = Polygon(
        polygonId: PolygonId('jail_border'),
        points: [
          LatLng(37.56, 126.97),
          LatLng(37.57, 126.97),
          LatLng(37.57, 126.98),
        ],
        strokeColor: AppColors.red500,
        strokeWidth: 2,
      );
      mapState.updateAreaPolygons({polygon});
      await tester.pump();
      final before = tester.widget<GoogleMap>(find.byType(GoogleMap));
      await tester.pump(const Duration(milliseconds: 1200));
      final after = tester.widget<GoogleMap>(find.byType(GoogleMap));
      expect(after.polygons.single.points, polygon.points);
      expect(
        after.polygons.single.strokeWidth,
        isNot(before.polygons.single.strokeWidth),
      );
      expect(
        after.circles.singleWhere((c) => c.circleId.value == 'jail').center,
        before.circles.singleWhere((c) => c.circleId.value == 'jail').center,
      );
      await container.read(gameEventNotifierProvider.notifier).escape(1, 5);
      await tester.pump();
      final restored = tester.widget<GoogleMap>(find.byType(GoogleMap));
      expect(restored.style, MapStyles.dark);
      expect(restored.polygons.single, polygon);
      expect(
        restored.circles
            .singleWhere((c) => c.circleId.value == 'jail')
            .strokeWidth,
        2,
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is SvgIconButton && w.assetPath.endsWith('/jailed.svg'),
        ),
        findsNothing,
      );
    },
  );

  testWidgets(
    'jailed_robber_escapes_automatically_when_leaving_jail_after_entry',
    (tester) async {
      await withClock(Clock(() => tester.binding.clock.now()), () async {
        await mount(tester);
        await sendPosition(tester, inside: true);
        await tester.pump(const Duration(seconds: 1));
        await sendPosition(tester, inside: false);
        await tester.pump(const Duration(seconds: 3));
        // 타이머 없이 다음 위치에서 판단한다 — 새 위치가 오기 전에는 요청하지 않는다.
        expect(game.escapes, 0);

        await sendPosition(tester, inside: false);
        await tester.pump(const Duration(milliseconds: 300));
        expect(game.escapes, 1);
        expect(
          container.read(gameEventNotifierProvider).escapedParticipantIds,
          {5},
        );
        expect(find.byType(JailBarsOverlay), findsNothing);

        // 풀린 뒤에는 밖 위치가 계속 와도 다시 요청하지 않는다.
        await tester.pump(const Duration(seconds: 6));
        await sendPosition(tester, inside: false);
        expect(game.escapes, 1);
        expect(tester.takeException(), isNull);
      });
    },
  );

  testWidgets(
    'auto_escape_keeps_entry_when_socket_reconnects_before_leaving_jail',
    (tester) async {
      await withClock(Clock(() => tester.binding.clock.now()), () async {
        await mount(tester);
        await sendPosition(tester, inside: true);
        socket.emit(StompConnectionState.disconnected);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        socket.emit(StompConnectionState.connected);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        await sendPosition(tester, inside: false);
        await tester.pump(const Duration(seconds: 3));
        await sendPosition(tester, inside: false);
        await tester.pump(const Duration(milliseconds: 300));
        expect(game.escapes, 1);
      });
    },
  );

  testWidgets('auto_escape_requests_when_socket_stays_disconnected', (
    tester,
  ) async {
    await withClock(Clock(() => tester.binding.clock.now()), () async {
      await mount(tester);
      await sendPosition(tester, inside: true);
      socket.acceptConnect = false;
      socket.emit(StompConnectionState.disconnected);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await sendPosition(tester, inside: false);
      await tester.pump(const Duration(seconds: 3));
      await sendPosition(tester, inside: false);
      await tester.pump(const Duration(milliseconds: 300));
      expect(socket.connection, StompConnectionState.disconnected);
      expect(game.escapes, 1);
      expect(container.read(gameEventNotifierProvider).escapedParticipantIds, {
        5,
      });
    });
  });

  testWidgets('auto_escape_retries_after_5s_when_escape_request_fails', (
    tester,
  ) async {
    await withClock(Clock(() => tester.binding.clock.now()), () async {
      game.failures = 1;
      await mount(tester);
      await sendPosition(tester, inside: true);
      await sendPosition(tester, inside: false);
      await tester.pump(const Duration(seconds: 3));
      final syncsBefore = session.requests;

      await sendPosition(tester, inside: false); // 요청 1 — 실패
      await tester.pump(const Duration(milliseconds: 300));
      expect(game.escapes, 1);
      expect(container.read(gameEventNotifierProvider).arrestedParticipantIds, {
        5,
      });
      expect(session.requests, syncsBefore + 1); // 실패 뒤 상태 동기화

      await tester.pump(const Duration(seconds: 2));
      await sendPosition(tester, inside: false); // 요청 후 약 2초 — 보내지 않음
      expect(game.escapes, 1);

      await tester.pump(const Duration(seconds: 3));
      await sendPosition(tester, inside: false); // 요청 후 5초 이상 — 다시 요청
      await tester.pump(const Duration(milliseconds: 300));
      expect(game.escapes, 2);
      expect(container.read(gameEventNotifierProvider).escapedParticipantIds, {
        5,
      });
    });
  });

  testWidgets(
    'auto_escape_retries_when_socket_disconnects_during_escape_request',
    (tester) async {
      await withClock(Clock(() => tester.binding.clock.now()), () async {
        final pendingEscape = Completer<void>();
        game.escapeGate = pendingEscape;
        await mount(tester);
        await sendPosition(tester, inside: true);
        await sendPosition(tester, inside: false);
        await tester.pump(const Duration(seconds: 3));
        await sendPosition(tester, inside: false);
        expect(game.escapes, 1);
        expect(
          container.read(gameEventNotifierProvider).isEscapeInFlight,
          isTrue,
        );
        expect(find.byType(JailBarsOverlay), findsOneWidget);

        // 요청 중 연결 단절로 이전 성공 응답은 stale이 된다.
        socket.acceptConnect = false;
        socket.emit(StompConnectionState.disconnected);
        await tester.pump();
        pendingEscape.complete();
        await tester.pump();
        expect(
          container.read(gameEventNotifierProvider).arrestedParticipantIds,
          {5},
        );
        expect(
          container.read(gameEventNotifierProvider).escapedParticipantIds,
          isEmpty,
        );
        expect(find.byType(JailBarsOverlay), findsOneWidget);

        // 다시 들어가지 않아도 입장 기록으로 재시도한다. 소켓은 계속 끊겨 있다.
        game.escapeGate = null;
        await tester.pump(const Duration(seconds: 4));
        await sendPosition(tester, inside: false);
        expect(game.escapes, 1);
        await tester.pump(const Duration(seconds: 1));
        await sendPosition(tester, inside: false);
        await tester.pump(const Duration(milliseconds: 300));
        expect(socket.connection, StompConnectionState.disconnected);
        expect(game.escapes, 2);
        expect(
          container.read(gameEventNotifierProvider).escapedParticipantIds,
          {5},
        );
        expect(find.byType(JailBarsOverlay), findsNothing);
        expect(tester.takeException(), isNull);
      });
    },
  );

  testWidgets('auto_escape_requires_new_entry_when_robber_is_rearrested', (
    tester,
  ) async {
    await withClock(Clock(() => tester.binding.clock.now()), () async {
      await mount(tester);
      await sendPosition(tester, inside: true);
      await sendPosition(tester, inside: false);
      await tester.pump(const Duration(seconds: 3));
      await sendPosition(tester, inside: false);
      await tester.pump(const Duration(milliseconds: 300));
      expect(game.escapes, 1);

      socket.events.add(
        GameEventModel(
          type: GameEventType.arrest,
          data: {
            'police': {'participantId': 2, 'nickname': '경찰', 'status': 'ALIVE'},
            'robber': {
              'participantId': 5,
              'nickname': '도둑',
              'status': 'JAILED',
            },
            'remainingThieves': 1,
          },
        ),
      );
      await tester.pump();
      expect(container.read(gameEventNotifierProvider).arrestedParticipantIds, {
        5,
      });

      // 이전 수감의 "들어감"은 이어지지 않는다 — 밖에 계속 있어도 요청하지 않는다.
      await sendPosition(tester, inside: false);
      await tester.pump(const Duration(seconds: 6));
      await sendPosition(tester, inside: false);
      await tester.pump(const Duration(milliseconds: 300));
      expect(game.escapes, 1);
      expect(find.byType(JailBarsOverlay), findsOneWidget);

      // 새 수감에서도 다시 들어갔다 나오면 두 번째 자동 탈옥이 가능해야 한다.
      await sendPosition(tester, inside: true);
      await sendPosition(tester, inside: false);
      await tester.pump(const Duration(seconds: 3));
      await sendPosition(tester, inside: false);
      await tester.pump(const Duration(milliseconds: 300));
      expect(game.escapes, 2);
      expect(container.read(gameEventNotifierProvider).escapedParticipantIds, {
        5,
      });
      expect(find.byType(JailBarsOverlay), findsNothing);
      expect(tester.takeException(), isNull);
      // 체포 이벤트가 켠 알림 배너 타이머(8.8초)를 끝내 종료 시 남는 타이머를 없앤다.
      await tester.pump(const Duration(seconds: 9));
    });
  });

  testWidgets('auto_escape_requests_without_a_frame_when_app_is_paused', (
    tester,
  ) async {
    await withClock(Clock(() => tester.binding.clock.now()), () async {
      await mount(tester);
      await sendPosition(tester, inside: true);
      for (final state in [
        AppLifecycleState.inactive,
        AppLifecycleState.hidden,
        AppLifecycleState.paused,
      ]) {
        tester.binding.handleAppLifecycleStateChanged(state);
      }
      // pause 직전에 예약된 마지막 프레임을 소비한 뒤 실제 프레임 수를 센다.
      await tester.pump();
      var frames = 0;
      tester.binding.addPersistentFrameCallback((_) {
        frames++;
      });
      expect(tester.binding.framesEnabled, isFalse);

      location.inside = false;
      location.positions.add(location.position(false));
      await tester.idle();
      await tester.pump(const Duration(seconds: 3));
      location.positions.add(location.position(false));
      await tester.idle();
      await tester.pump(const Duration(milliseconds: 300));

      expect(frames, 0);
      expect(game.escapes, 1);
      expect(container.read(gameEventNotifierProvider).escapedParticipantIds, {
        5,
      });
    });
  });

  for (final variant in [
    (team: 'POLICE', isEventGame: false),
    (team: 'ROBBER', isEventGame: true),
  ]) {
    testWidgets(
      'auto_escape_never_requests_when_player_is_not_a_jailed_robber_$variant',
      (tester) async {
        await withClock(Clock(() => tester.binding.clock.now()), () async {
          container.read(gameParticipantNotifierProvider.notifier)
            ..setGameInfo(
              gameId: 1,
              participantId: 5,
              nickname: '참가자',
              team: variant.team,
              isEventGame: variant.isEventGame,
            )
            ..initFromLobby(participantId: 5, roundTimeMinutes: 30)
            ..setGameStartTime(
              DateTime.now()
                  .subtract(const Duration(minutes: 1))
                  .toIso8601String(),
            );
          session.settings = GameSettingsResponse(
            roundDurationMinutes: 30,
            locationRevealIntervalMinutes: 3,
            policeWaitMinutes: 0,
            maxParticipants: 10,
            gameStartTime: DateTime.now()
                .subtract(const Duration(minutes: 1))
                .toIso8601String(),
          );
          await mount(tester, team: variant.team);
          await sendPosition(tester, inside: true);
          await tester.pump(const Duration(seconds: 1));
          await sendPosition(tester, inside: false);
          await tester.pump(const Duration(seconds: 3));
          await sendPosition(tester, inside: false);
          await tester.pump(const Duration(milliseconds: 300));
          expect(game.escapes, 0);
        });
      },
    );
  }

  testWidgets(
    'jailed_state_is_restored_when_paused_reconnect_retries_without_a_frame',
    (tester) async {
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
      for (final inside in [true, false]) {
        location.inside = inside;
        location.positions.add(location.position(inside));
        await tester.idle();
        await tester.pump(const Duration(milliseconds: 2100));
      }
      expect(frames, 0);
      expect(game.escapes, 0);
      expect(container.read(gameEventNotifierProvider).arrestedParticipantIds, {
        5,
      });
      expect(
        container.read(gameEventNotifierProvider).escapedParticipantIds,
        isEmpty,
      );
    },
  );

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
