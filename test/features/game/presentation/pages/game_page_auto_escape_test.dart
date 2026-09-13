import 'dart:async';

import 'package:clock/clock.dart';
import 'package:cops_and_robbers/core/constants/app_colors.dart';
import 'package:cops_and_robbers/core/constants/app_icons.dart';
import 'package:cops_and_robbers/core/constants/map_styles.dart';
import 'package:cops_and_robbers/core/widgets/navigation/app_top_bar.dart';
import 'package:cops_and_robbers/core/widgets/buttons/previous_button.dart';
import 'package:cops_and_robbers/features/chat/presentation/providers/chat_notification_provider.dart';
import 'package:cops_and_robbers/features/game/presentation/widgets/game_timer_text.dart';
import 'package:cops_and_robbers/features/game/presentation/widgets/location_reveal_countdown.dart';
import 'package:cops_and_robbers/core/widgets/buttons/svg_icon_button.dart';
import 'package:cops_and_robbers/core/widgets/buttons/my_location_button.dart';
import 'package:cops_and_robbers/core/widgets/chat/community_message_input.dart';
import 'package:cops_and_robbers/features/game/presentation/widgets/arrest_lock_overlay.dart';
import 'package:cops_and_robbers/features/game/presentation/widgets/google_map_view.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cops_and_robbers/features/game/data/models/game_event_model.dart';
import 'package:cops_and_robbers/core/services/lifecycle/app_lifecycle_service.dart';
import 'package:cops_and_robbers/core/widgets/dialogs/reconnect_modal.dart';
import 'package:cops_and_robbers/features/auth/presentation/providers/token_provider.dart';
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
import 'package:cops_and_robbers/features/session/data/models/user_game_status_model.dart';
import 'package:cops_and_robbers/features/session/presentation/providers/game_participant_provider.dart';
import 'package:cops_and_robbers/features/session/presentation/providers/session_provider.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  Future<Position> Function()? currentPosition;
  @override
  Future<bool> isLocationServiceEnabled() async => true;
  @override
  Future<LocationPermission> checkPermission() async =>
      LocationPermission.always;
  @override
  Future<Position> getCurrentPosition({
    LocationSettings? locationSettings,
  }) async => currentPosition != null ? currentPosition!() : position(inside);
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

  @override
  void connect(String wsUrl, String accessToken) =>
      emit(StompConnectionState.connected);
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
  late _Chat chat;
  late _GameApi game;
  late _SessionApi session;
  late ProviderContainer container;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
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
          (w) => w is SvgIconButton && w.assetPath == AppIcons.speechBubble,
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
    await mount(tester, size: const Size(393, 852));
    final l10n = AppLocalizations.of(tester.element(find.byType(GamePage)));
    final timerState = tester.state(find.byType(GameTimerText));
    final revealState = tester.state(find.byType(LocationRevealCountdown));
    final chatButton = find.byWidgetPredicate(
      (w) => w is SvgIconButton && w.assetPath == AppIcons.speechBubble,
    );
    expect(find.byTooltip(l10n.buttonLeave), findsOneWidget);
    expect(find.byTooltip(l10n.titleGameRules), findsOneWidget);

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
    expect(tester.state(find.byType(GameTimerText)), same(timerState));
    expect(
      tester.state(find.byType(LocationRevealCountdown)),
      same(revealState),
    );

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
    await tester.tap(find.byTooltip(l10n.gameChatBackToMap));
    await tester.pump();
    expect(inputFocus.hasFocus, isFalse);
    expect(find.byType(CommunityMessageInput), findsNothing);
    expect(find.byTooltip(l10n.buttonLeave), findsOneWidget);
    expect(find.byTooltip(l10n.titleGameRules), findsOneWidget);
    expect(tester.state(find.byType(GameTimerText)), same(timerState));
    expect(
      tester.state(find.byType(LocationRevealCountdown)),
      same(revealState),
    );

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
    expect(tester.takeException(), isNull);
  });

  testWidgets('chat_channels_preserve_drafts_and_send_to_the_selected_scope', (
    tester,
  ) async {
    await mount(tester);
    final chatButton = find.byWidgetPredicate(
      (w) => w is SvgIconButton && w.assetPath == AppIcons.speechBubble,
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
        (w) => w is SvgIconButton && w.assetPath == AppIcons.speechBubble,
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
          (w) => w is SvgIconButton && w.assetPath == AppIcons.speechBubble,
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
        expect(map.style, MapStyles.arrested);
        expect(map.scrollGesturesEnabled, isTrue);
        expect(map.zoomGesturesEnabled, isTrue);
        final jail = map.circles.singleWhere((c) => c.circleId.value == 'jail');
        expect(jail.fillColor, AppColors.yellowAlpha20);
        expect(jail.radius, 20);
        final jailButton = find.byWidgetPredicate(
          (w) => w is SvgIconButton && w.assetPath.endsWith('/jailed.svg'),
        );
        expect(
          tester.getCenter(jailButton).dx,
          tester.getCenter(find.byType(MyLocationButton)).dx,
        );
        expect(
          tester.getBottomLeft(jailButton).dy,
          lessThan(tester.getTopLeft(find.byType(MyLocationButton)).dy),
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
            (w) => w is SvgIconButton && w.assetPath == AppIcons.speechBubble,
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
            (w) => w is SvgIconButton && w.assetPath == AppIcons.speechBubble,
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
            (w) => w is SvgIconButton && w.assetPath == AppIcons.speechBubble,
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

  testWidgets('sparse_positions_escape_with_a_fresh_confirmation', (
    tester,
  ) async {
    await withClock(Clock(() => tester.binding.clock.now()), () async {
      await mount(tester);
      location.positions.add(location.position(true));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      location.inside = false;
      location.positions.add(location.position(false));
      await tester.pump();
      expect(game.escapes, 0);
      await tester.pump(const Duration(seconds: 2));
      expect(game.escapes, 1);
      expect(container.read(gameEventNotifierProvider).escapedParticipantIds, {
        5,
      });
    });
  });

  testWidgets('late_confirmation_cannot_escape_after_disconnect', (
    tester,
  ) async {
    await withClock(Clock(() => tester.binding.clock.now()), () async {
      await mount(tester);
      location.positions.add(location.position(true));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      location.positions.add(location.position(false));
      await tester.pump();
      final pending = Completer<Position>();
      location.currentPosition = () => pending.future;
      await tester.pump(const Duration(seconds: 2));
      socket.emit(StompConnectionState.disconnected);
      await tester.pump();
      pending.complete(location.position(false));
      await tester.pump();
      container.read(gameEventNotifierProvider.notifier).disconnect();
      expect(game.escapes, 0);
      expect(container.read(gameEventNotifierProvider).arrestedParticipantIds, {
        5,
      });
    });
  });

  testWidgets('cached_confirmation_does_not_count_as_a_new_position', (
    tester,
  ) async {
    await withClock(Clock(() => tester.binding.clock.now()), () async {
      await mount(tester);
      location.positions.add(location.position(true));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      final cached = location.position(false);
      location.positions.add(cached);
      location.currentPosition = () async => cached;
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      expect(game.escapes, 0);
      await tester.pump(const Duration(seconds: 20));
      expect(game.escapes, 0);
    });
  });

  for (final interruption in ['rearrest', 'dispose', 'failure']) {
    testWidgets('pending_confirmation_is_safe_on_$interruption', (
      tester,
    ) async {
      await withClock(Clock(() => tester.binding.clock.now()), () async {
        await mount(tester);
        location.positions.add(location.position(true));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        location.positions.add(location.position(false));
        await tester.pump();
        final pending = Completer<Position>();
        location.currentPosition = () => pending.future;
        await tester.pump(const Duration(seconds: 2));
        if (interruption == 'rearrest') {
          socket.events.add(
            const GameEventModel(
              eventId: 'new-arrest',
              type: GameEventType.arrest,
              data: {
                'robber': {
                  'participantId': 5,
                  'nickname': '도둑',
                  'status': 'JAILED',
                },
                'police': {
                  'participantId': 2,
                  'nickname': '경찰',
                  'status': 'ALIVE',
                },
                'remainingThieves': 1,
              },
            ),
          );
          await tester.pump();
        } else if (interruption == 'dispose') {
          await tester.pumpWidget(const SizedBox());
        }
        if (interruption == 'failure') {
          pending.completeError(Exception('GPS unavailable'));
        } else {
          pending.complete(location.position(false));
        }
        await tester.pump();
        expect(game.escapes, 0);
        expect(tester.takeException(), isNull);
        if (interruption == 'rearrest') {
          // ARREST가 띄운 기존 배너(8.8초)의 표시 수명을 끝낸다.
          await tester.pump(const Duration(seconds: 9));
          expect(game.escapes, 0);
        }
        if (interruption == 'failure') {
          location.currentPosition = null;
          location.inside = false;
          await tester.pump(const Duration(seconds: 1));
          location.positions.add(location.position(false));
          await tester.pump();
          expect(game.escapes, 1);
        }
      });
    });
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
    for (final inside in [true, false]) {
      location.inside = inside;
      location.positions.add(location.position(inside));
      await tester.idle();
      await tester.pump(const Duration(milliseconds: 2100));
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
