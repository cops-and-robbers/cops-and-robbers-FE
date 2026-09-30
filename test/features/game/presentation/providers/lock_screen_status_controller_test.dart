import 'dart:async';

import 'package:cops_and_robbers/core/services/background/background_service_provider.dart';
import 'package:cops_and_robbers/core/services/background/method_channel_background_service.dart';
import 'package:cops_and_robbers/features/auth/presentation/providers/token_provider.dart';
import 'package:cops_and_robbers/features/game/data/datasources/game_event_stomp_datasource.dart';
import 'package:cops_and_robbers/features/game/data/datasources/game_system_api_datasource.dart';
import 'package:cops_and_robbers/features/game/data/models/game_event_model.dart';
import 'package:cops_and_robbers/features/game/presentation/providers/game_event_provider.dart';
import 'package:cops_and_robbers/features/game/presentation/providers/lock_screen_status_controller.dart';
import 'package:cops_and_robbers/features/session/presentation/providers/game_participant_provider.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// STOMP 연결을 막고, 테스트가 이벤트를 직접 발행하는 fake (네트워크 경계).
class _EventInjectableDatasource extends GameEventStompDatasource {
  final _events = StreamController<GameEventModel>.broadcast();
  final _connections = StreamController<StompConnectionState>.broadcast();
  final _errors = StreamController<StompErrorInfo>.broadcast();

  @override
  Stream<GameEventModel> get onEvent => _events.stream;

  @override
  Stream<StompConnectionState> get onConnectionState => _connections.stream;

  @override
  Stream<StompErrorInfo> get onError => _errors.stream;

  @override
  void connect(String wsUrl, String accessToken) {
    // no-op (실제 WS 연결 차단)
  }

  @override
  void subscribeEvents(int gameId, {required String team}) {
    // no-op (실제 STOMP 구독 차단)
  }

  @override
  void dispose() {
    _events.close();
    _connections.close();
    _errors.close();
    super.dispose();
  }

  void emitPlayerLeft(int participantId) {
    _events.add(
      GameEventModel(
        type: GameEventType.playerLeft,
        data: {
          'participantId': participantId,
          'nickname': 'r$participantId',
          'team': 'ROBBER',
        },
      ),
    );
  }

  void emitGameOver() {
    _events.add(
      GameEventModel(
        type: GameEventType.gameOver,
        data: {
          'winnerTeam': 'POLICE',
          'reason': 'TIME_OVER',
          'gameResultId': 1,
        },
      ),
    );
  }
}

/// 체포/탈옥 REST 경계 — 이 테스트에서는 호출되지 않는다.
class _UnusedGameSystemApi implements GameSystemApi {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeTokenProvider implements TokenProvider {
  @override
  Future<String?> getAccessToken() async => 'test-token';

  @override
  Future<String?> refreshAccessTokenIfNeeded() async => 'test-token';
}

const _gameId = 1;
// 로컬 시각으로 둔다 — IsoTimestampParser가 오프셋 없는 문자열을 로컬로 읽는다.
final _start = DateTime(2026, 9, 30, 10);

class _Harness {
  _Harness(this.container, this.calls, this.service);
  final ProviderContainer container;
  final List<MethodCall> calls;
  final MethodChannelBackgroundService service;

  List<Map<Object?, Object?>> get updates => [
    for (final c in calls)
      if (c.method == 'update') c.arguments as Map<Object?, Object?>,
  ];

  /// 게임 화면의 참가자 동기화(_syncGameStateOnReconnect)가 하는 호출을 흉내 낸다.
  void sync({required Set<int> arrested, Set<int>? robbers}) => container
      .read(gameEventNotifierProvider.notifier)
      .syncFromParticipants(
        arrestedIds: arrested,
        remainingThieves: (robbers?.length ?? 0) - arrested.length,
        robberIds: robbers,
      );
}

/// 대기실 응답과 같은 경로로 참가 정보·게임 설정·시작 시각을 채운다(STOMP START 없이 재진입한 상황).
void _fillGameInfo(
  ProviderContainer c, {
  bool isEventGame = false,
  String team = 'police',
}) {
  c.read(gameParticipantNotifierProvider.notifier)
    ..setGameInfo(
      gameId: _gameId,
      nickname: '경찰',
      team: team,
      participantId: 100,
      isEventGame: isEventGame,
    )
    ..updateSettings(
      roundTimeMinutes: 30,
      policeWaitMinutes: 5,
      locationRevealIntervalMinutes: 3,
    )
    ..setGameStartTime('2026-09-30T10:00:00');
}

_Harness _harness({
  GameEventStompDatasource? datasource,
  bool isEventGame = false,
  bool fillGameInfo = true,
}) {
  final calls = <MethodCall>[];
  const channel = MethodChannel(MethodChannelBackgroundService.channelName);
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (call) async {
        calls.add(call);
        return null;
      });
  addTearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null),
  );
  final service = MethodChannelBackgroundService(channel: channel);

  final c = ProviderContainer(
    overrides: [
      gameEventStompDatasourceProvider.overrideWithValue(
        datasource ?? _EventInjectableDatasource(),
      ),
      gameSystemApiProvider.overrideWithValue(_UnusedGameSystemApi()),
      tokenProviderProvider.overrideWithValue(_FakeTokenProvider()),
      backgroundServiceProvider.overrideWithValue(service),
    ],
  );
  addTearDown(c.dispose);
  c.listen(gameEventNotifierProvider, (_, _) {}, fireImmediately: true);
  if (fillGameInfo) _fillGameInfo(c, isEventGame: isEventGame);
  return _Harness(c, calls, service);
}

void _listenController(_Harness h) => h.container.listen(
  lockScreenStatusControllerProvider,
  (_, _) {},
  fireImmediately: true,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await initializeDateFormatting();
    dotenv.loadFromString(envString: '', isOptional: true);
  });
  setUp(() => SharedPreferences.setMockInitialValues({}));

  const fiveRobbers = {1, 2, 3, 4, 5};
  final twoMinutesIn = DateTime(2026, 9, 30, 10, 2);

  test('uses_participant_start_time_when_stomp_start_is_missing', () {
    fakeAsync((async) {
      final h = _harness();
      h.service.start(gameId: _gameId);
      _listenController(h);
      async.flushMicrotasks();

      expect(
        h.updates.last['endAtMs'],
        _start.add(const Duration(minutes: 30)).millisecondsSinceEpoch,
      );
    }, initialTime: twoMinutesIn);
  });

  test('hides_robbers_when_game_sync_has_not_arrived', () {
    fakeAsync((async) {
      final h = _harness();
      h.service.start(gameId: _gameId);
      _listenController(h);
      async.flushMicrotasks();

      expect((
        h.updates.last['aliveRobbers'],
        h.updates.last['totalRobbers'],
      ), (null, null));
    }, initialTime: twoMinutesIn);
  });

  test('counts_alive_robbers_from_game_sync_when_synced', () {
    fakeAsync((async) {
      final h = _harness();
      h.service.start(gameId: _gameId);
      _listenController(h);
      async.flushMicrotasks();

      h.sync(arrested: {5}, robbers: fiveRobbers);
      async.flushMicrotasks();

      expect((
        h.updates.last['aliveRobbers'],
        h.updates.last['totalRobbers'],
      ), (4, 5));
    }, initialTime: twoMinutesIn);
  });

  test('counts_robbers_when_game_info_arrives_after_sync', () {
    // 콜드 재진입: 소켓 동기화가 참가 정보(설정 API)보다 먼저 끝날 수 있다.
    fakeAsync((async) {
      final h = _harness(fillGameInfo: false);
      h.service.start(gameId: _gameId);
      _listenController(h);
      h.sync(arrested: {5}, robbers: fiveRobbers);
      async.flushMicrotasks();

      _fillGameInfo(h.container);
      async.flushMicrotasks();

      expect((
        h.updates.last['aliveRobbers'],
        h.updates.last['totalRobbers'],
      ), (4, 5));
    }, initialTime: twoMinutesIn);
  });

  test('recounts_robbers_locally_when_arrest_set_changes', () {
    fakeAsync((async) {
      final h = _harness();
      h.service.start(gameId: _gameId);
      _listenController(h);
      h.sync(arrested: {5}, robbers: fiveRobbers);
      async.flushMicrotasks();

      // 명단 없이 수감 집합만 바뀐다(소켓 체포 이벤트와 같은 효과) — 마지막 명단으로 다시 센다.
      h.sync(arrested: {1, 5});
      async.flushMicrotasks();

      expect(h.updates.last['aliveRobbers'], 3);
    }, initialTime: twoMinutesIn);
  });

  test('excludes_robber_who_left_when_player_leaves', () {
    fakeAsync((async) {
      final ds = _EventInjectableDatasource();
      final h = _harness(datasource: ds);
      h.service.start(gameId: _gameId);
      _listenController(h);
      h.container
          .read(gameEventNotifierProvider.notifier)
          .connectAndSubscribe(_gameId, team: 'police');
      h.sync(arrested: {5}, robbers: fiveRobbers);
      async.flushMicrotasks();

      ds.emitPlayerLeft(2);
      async.flushMicrotasks();

      expect((
        h.updates.last['aliveRobbers'],
        h.updates.last['totalRobbers'],
      ), (3, 4));
    }, initialTime: twoMinutesIn);
  });

  test('marks_robber_theme_when_my_team_is_robber', () {
    fakeAsync((async) {
      final h = _harness(fillGameInfo: false);
      h.service.start(gameId: _gameId);
      _listenController(h);
      // 서버 팀 값은 대문자(ROBBER)로 온다.
      _fillGameInfo(h.container, team: 'ROBBER');
      async.flushMicrotasks();

      expect(h.updates.last['isRobberTeam'], isTrue);
    }, initialTime: twoMinutesIn);
  });

  test('advances_reveal_time_when_reveal_moment_passes', () {
    fakeAsync((async) {
      final h = _harness();
      h.service.start(gameId: _gameId);
      _listenController(h);
      async.flushMicrotasks();
      expect(
        h.updates.last['nextRevealAtMs'],
        DateTime(2026, 9, 30, 10, 8).millisecondsSinceEpoch,
      );

      async.elapse(const Duration(minutes: 6, seconds: 1)); // 10:08:01

      expect(
        h.updates.last['nextRevealAtMs'],
        DateTime(2026, 9, 30, 10, 11).millisecondsSinceEpoch,
      );
    }, initialTime: twoMinutesIn);
  });

  test('leaves_no_pending_timer_when_game_screen_stops_listening', () {
    // 게임 화면이 사라지면 autoDispose 정리 전이라도 타이머가 남으면 안 된다.
    fakeAsync((async) {
      final h = _harness();
      h.service.start(gameId: _gameId);
      final sub = h.container.listen(
        lockScreenStatusControllerProvider,
        (_, _) {},
        fireImmediately: true,
      );
      async.flushMicrotasks();

      sub.close();
      // 닫은 뒤 늦게 온 동기화도 타이머를 다시 만들지 않아야 한다.
      h.sync(arrested: {1, 5}, robbers: fiveRobbers);
      async.flushMicrotasks();

      // autoDispose 정리(Riverpod의 0초 예약)가 돌기 전 시점을 본다 — 위젯 테스트는 이 시점에
      // 타이머 불변식을 검사한다. 0초 예약은 Riverpod 것이라 제외한다.
      expect(
        async.pendingTimers.where((t) => t.duration > Duration.zero),
        isEmpty,
      );
    }, initialTime: twoMinutesIn);
  });

  test('does_not_replay_finished_game_status_when_next_game_starts', () {
    // 종료 가드가 빠지면 공개 타이머가 종료 뒤에도 돌아 서비스에 이전 게임 값을 쌓는다.
    fakeAsync((async) {
      final ds = _EventInjectableDatasource();
      final h = _harness(datasource: ds);
      h.service.start(gameId: _gameId);
      _listenController(h);
      h.container
          .read(gameEventNotifierProvider.notifier)
          .connectAndSubscribe(_gameId, team: 'police');
      async.flushMicrotasks();

      ds.emitGameOver();
      async.flushMicrotasks();
      async.elapse(const Duration(minutes: 10)); // 다음 공개 시각(10:08)을 지난다
      final before = h.calls.length;
      h.service.start(gameId: 2);
      async.flushMicrotasks();

      expect(h.calls.skip(before).map((c) => c.method).toList(), ['start']);
    }, initialTime: twoMinutesIn);
  });

  test('does_not_resend_when_status_is_unchanged', () {
    fakeAsync((async) {
      final h = _harness();
      h.service.start(gameId: _gameId);
      _listenController(h);
      h.sync(arrested: {5}, robbers: fiveRobbers);
      async.flushMicrotasks();
      final before = h.updates.length;

      // 같은 결과가 나오는 재동기화
      h.sync(arrested: {5}, robbers: fiveRobbers);
      async.flushMicrotasks();

      expect(h.updates.length, before);
    }, initialTime: twoMinutesIn);
  });

  test('sends_nothing_when_game_is_over', () async {
    final ds = _EventInjectableDatasource();
    final h = _harness(datasource: ds);
    await h.service.start(gameId: _gameId);
    _listenController(h);
    await h.container
        .read(gameEventNotifierProvider.notifier)
        .connectAndSubscribe(_gameId, team: 'police');
    h.sync(arrested: {5}, robbers: fiveRobbers);
    await pumpEventQueue();

    ds.emitGameOver();
    await pumpEventQueue();
    final afterGameOver = h.calls.length;
    h.sync(arrested: {1, 5});
    await pumpEventQueue();

    expect(
      h.calls.skip(afterGameOver).where((c) => c.method == 'update'),
      isEmpty,
    );
  });
}
