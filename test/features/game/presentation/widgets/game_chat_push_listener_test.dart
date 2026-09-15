import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';

import 'package:cops_and_robbers/core/network/dio_client.dart';
import 'package:cops_and_robbers/core/services/fcm/push_navigation_event.dart';
import 'package:cops_and_robbers/core/services/fcm/push_navigation_service.dart';
import 'package:cops_and_robbers/core/widgets/snackbars/app_snackbar.dart';
import 'package:cops_and_robbers/features/auth/domain/entities/auth_result_entity.dart';
import 'package:cops_and_robbers/features/chat/presentation/widgets/chat_overlay.dart';
import 'package:cops_and_robbers/core/widgets/toggles/segmented_toggle.dart';
import 'package:cops_and_robbers/features/game/presentation/widgets/game_chat_push_listener.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:cops_and_robbers/router/route_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const _user = AuthResultEntity(
  userId: 1,
  nickname: 'u',
  isNewUser: false,
  requiresAgreement: false,
);
const _push = GameChatPushEvent(gameId: 42, scope: 'ALL');

Map<String, Object?> _game(int? id) => {
  'isParticipating': id != null,
  'participationInfo': id == null
      ? null
      : {
          'gameId': id,
          'participantId': 7,
          'team': 'POLICE',
          'gameStatus': 'IN_PROGRESS',
        },
};

class _GameApi implements HttpClientAdapter {
  Future<Map<String, Object?>> Function() respond = () async => _game(42);
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? stream,
    Future<void>? cancelFuture,
  ) async {
    expect(options.path, '/api/user/me/game');
    return ResponseBody.fromString(
      jsonEncode(await respond()),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

// 지도 플랫폼 뷰 대신 실제 채팅 패널을 호스팅한다. 채팅 상태와 채널 선택은 실제 구현이다.
class _GameScreen extends StatefulWidget {
  const _GameScreen();
  @override
  State<_GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<_GameScreen> {
  bool visible = false;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      children: [
        TextButton(
          onPressed: () => setState(() => visible = false),
          child: const Text('close chat'),
        ),
        ChatOverlay(
          gameId: 42,
          myParticipantId: 7,
          myTeam: 'POLICE',
          visible: visible,
          previewInsets: EdgeInsets.zero,
          onOpen: () => setState(() => visible = true),
        ),
      ],
    ),
  );
}

void main() {
  late _GameApi api;
  late ProviderContainer container;
  late GoRouter router;
  late ValueNotifier<AsyncValue<AuthResultEntity?>> auth;

  Future<void> pump(
    WidgetTester tester, {
    String path = '/home',
    GameChatPushEvent? initial,
  }) async {
    api = _GameApi();
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
      ..httpClientAdapter = api;
    container = ProviderContainer(
      overrides: [
        dioProvider.overrideWithValue(dio),
        pendingGameChatPushProvider.overrideWith((ref) => initial),
      ],
    );
    auth = ValueNotifier(const AsyncData(_user));
    router = GoRouter(
      initialLocation: path,
      routes: [
        for (final path in ['/home', RoutePaths.splash, '/login', '/agreement'])
          GoRoute(
            path: path,
            builder: (_, _) => Scaffold(body: Text(path)),
          ),
        GoRoute(path: '/game/:id', builder: (_, _) => const _GameScreen()),
      ],
    );
    addTearDown(() {
      AppSnackbar.dismiss();
      router.dispose();
      auth.dispose();
      container.dispose();
      dio.close();
    });
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: ScreenUtilInit(
          designSize: const Size(393, 852),
          builder: (_, _) => ValueListenableBuilder(
            valueListenable: auth,
            builder: (_, value, _) => MaterialApp.router(
              locale: const Locale('en'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              routerConfig: router,
              builder: (_, child) => GameChatPushListener(
                router: router,
                auth: value,
                child: child!,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  void send(GameChatPushEvent event) =>
      container.read(pendingGameChatPushProvider.notifier).state = event;

  testWidgets('tap_opens_all_chat_and_repeat_preserves_the_existing_panel', (
    tester,
  ) async {
    await pump(tester);
    send(_push);
    await tester.pumpAndSettle();
    expect(router.routerDelegate.currentConfiguration.uri.path, '/game/42');
    expect(
      tester
          .widget<SegmentedToggle>(find.byType(SegmentedToggle))
          .selectedIndex,
      1,
    );
    final panel = tester.state(find.byType(ChatOverlay));
    await tester.tap(find.text('close chat'));
    await tester.pumpAndSettle();
    send(const GameChatPushEvent(gameId: 42, scope: 'TEAM'));
    await tester.pumpAndSettle();
    expect(tester.state(find.byType(ChatOverlay)), same(panel));
    expect(
      tester
          .widget<SegmentedToggle>(find.byType(SegmentedToggle))
          .selectedIndex,
      0,
    );
    expect(container.read(pendingGameChatPushProvider), isNull);
    expect(container.read(openGameChatPushProvider), isNull);
    send(const GameChatPushEvent(gameId: 42, scope: 'TEAM'));
    await tester.pumpAndSettle();
    expect(tester.state(find.byType(ChatOverlay)), same(panel));
    expect(container.read(openGameChatPushProvider), isNull);
  });

  testWidgets('cold_push_waits_for_splash_and_auth_gates_before_opening_chat', (
    tester,
  ) async {
    await pump(tester, path: RoutePaths.splash, initial: _push);
    expect(container.read(pendingGameChatPushProvider), _push);
    auth.value = const AsyncData(null);
    router.go('/login');
    await tester.pumpAndSettle();
    expect(container.read(pendingGameChatPushProvider), _push);
    auth.value = AsyncData(_user.copyWith(requiresAgreement: true));
    router.go('/agreement');
    await tester.pumpAndSettle();
    expect(container.read(pendingGameChatPushProvider), _push);
    auth.value = const AsyncData(_user);
    router.go('/game/42?team=POLICE&pid=7');
    await tester.pumpAndSettle();
    expect(find.byType(SegmentedToggle), findsOneWidget);
    expect(container.read(pendingGameChatPushProvider), isNull);
  });

  testWidgets('stale_game_push_keeps_current_screen_and_shows_notice', (
    tester,
  ) async {
    await pump(tester);
    api.respond = () async => _game(99);
    send(_push);
    await tester.pumpAndSettle();
    expect(router.routerDelegate.currentConfiguration.uri.path, '/home');
    expect(
      find.text("You can't open this game's chat right now"),
      findsOneWidget,
    );
    expect(container.read(openGameChatPushProvider), isNull);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });

  testWidgets('late_response_cannot_override_a_newer_push', (tester) async {
    await pump(tester);
    final first = Completer<Map<String, Object?>>();
    api.respond = () => first.future;
    send(_push);
    await tester.pump();
    await tester.pump();
    api.respond = () async => _game(42);
    send(const GameChatPushEvent(gameId: 42, scope: 'TEAM'));
    await tester.pumpAndSettle();
    first.complete(_game(42));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<SegmentedToggle>(find.byType(SegmentedToggle))
          .selectedIndex,
      0,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('response_after_logout_waits_for_auth_again', (tester) async {
    await pump(tester);
    final response = Completer<Map<String, Object?>>();
    api.respond = () => response.future;
    send(_push);
    await tester.pump();
    await tester.pump();
    auth.value = const AsyncData(null);
    router.go('/login');
    await tester.pumpAndSettle();
    response.complete(_game(42));
    await tester.pumpAndSettle();
    expect(router.routerDelegate.currentConfiguration.uri.path, '/login');
    expect(container.read(pendingGameChatPushProvider), _push);
    expect(container.read(openGameChatPushProvider), isNull);
  });

  testWidgets('response_after_dispose_does_not_navigate', (tester) async {
    await pump(tester);
    final response = Completer<Map<String, Object?>>();
    api.respond = () => response.future;
    send(_push);
    await tester.pump();
    await tester.pump();
    await tester.pumpWidget(const SizedBox());
    response.complete(_game(42));
    await tester.pumpAndSettle();
    expect(router.routerDelegate.currentConfiguration.uri.path, '/home');
    expect(container.read(openGameChatPushProvider), isNull);
    expect(tester.takeException(), isNull);
  });
}
