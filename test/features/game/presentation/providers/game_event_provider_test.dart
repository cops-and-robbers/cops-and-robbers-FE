import 'dart:async';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cops_and_robbers/features/game/data/datasources/game_event_stomp_datasource.dart';
import 'package:cops_and_robbers/features/game/data/datasources/game_system_api_datasource.dart';
import 'package:cops_and_robbers/features/game/data/models/arrest_request_model.dart';
import 'package:cops_and_robbers/features/game/data/models/arrest_response_model.dart';
import 'package:cops_and_robbers/features/game/data/models/game_area_model.dart';
import 'package:cops_and_robbers/features/game/data/models/game_event_model.dart';
import 'package:cops_and_robbers/features/game/data/services/event_arrest_storage.dart';
import 'package:cops_and_robbers/features/game/presentation/providers/game_event_provider.dart';
import 'package:cops_and_robbers/features/auth/presentation/providers/token_provider.dart';
import 'package:cops_and_robbers/features/session/presentation/providers/game_participant_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// STOMP 실제 연결을 차단하는 fake.
/// build()가 datasource를 watch하므로 주입해 네트워크 부작용을 막는다.
class _FakeDatasource extends GameEventStompDatasource {
  @override
  void connect(String wsUrl, String accessToken) {
    // no-op (실제 WS 연결 차단)
  }
}

/// 체포/탈옥 REST 경계 fake — 성공/실패/지연(gate)을 제어한다.
///
/// [arrestGate]가 설정되면 arrest()가 그 Completer 완료까지 대기하여
/// "API 진행 중" 상태를 재현한다(재진입 방어 테스트용).
class _FakeGameSystemApi implements GameSystemApi {
  Object? arrestError;
  Object? escapeError;
  Completer<void>? arrestGate;
  Completer<void>? escapeGate;

  int arrestCount = 0;
  int escapeCount = 0;
  (int, int)? lastArrest;
  int? lastEscapeGameId;

  @override
  Future<ArrestResponseModel> arrest(
    int gameId,
    ArrestRequestModel body,
  ) async {
    arrestCount++;
    lastArrest = (gameId, body.robberParticipantId);
    if (arrestGate != null) await arrestGate!.future;
    if (arrestError != null) throw arrestError!;
    return const ArrestResponseModel(robberNickname: '도둑', remainingThieves: 1);
  }

  @override
  Future<void> escape(int gameId) async {
    escapeCount++;
    lastEscapeGameId = gameId;
    if (escapeGate != null) await escapeGate!.future;
    if (escapeError != null) throw escapeError!;
  }

  @override
  Future<GameAreaModel> getArea(int gameId) => throw UnimplementedError();

  @override
  Future<GameStateModel> getGameState(int gameId) => throw UnimplementedError();
}

ProviderContainer _container({required _FakeGameSystemApi api}) {
  final c = ProviderContainer(
    overrides: [
      gameEventStompDatasourceProvider.overrideWithValue(_FakeDatasource()),
      gameSystemApiProvider.overrideWithValue(api),
    ],
  );
  // autoDispose 생존 유지 (notifier가 테스트 중 dispose되지 않도록)
  c.listen(gameEventNotifierProvider, (_, _) {}, fireImmediately: true);
  addTearDown(c.dispose);
  return c;
}

/// 이벤트 주입 가능한 STOMP datasource fake — onEvent를 테스트가 직접 발행한다.
/// 서버 `ARREST` 브로드캐스트를 모사해 STOMP 기준 검거 집계(스펙 §3)를 검증한다.
class _EventInjectableDatasource extends GameEventStompDatasource {
  final _events = StreamController<GameEventModel>.broadcast();
  final connections = StreamController<StompConnectionState>.broadcast();
  final errors = StreamController<StompErrorInfo>.broadcast();

  @override
  Stream<StompConnectionState> get onConnectionState => connections.stream;

  @override
  Stream<StompErrorInfo> get onError => errors.stream;

  @override
  void dispose() {
    _events.close();
    connections.close();
    errors.close();
    super.dispose();
  }

  @override
  Stream<GameEventModel> get onEvent => _events.stream;

  @override
  void connect(String wsUrl, String accessToken) {
    // no-op (실제 WS 연결 차단)
  }

  @override
  void subscribeEvents(int gameId, {required String team}) {
    // no-op (실제 STOMP 구독 차단)
  }

  void emitArrest({
    required int policeId,
    required int robberId,
    String robberNickname = '운영진',
  }) {
    _events.add(
      GameEventModel(
        type: GameEventType.arrest,
        data: {
          'police': {
            'participantId': policeId,
            'nickname': '경찰',
            'status': 'ALIVE',
          },
          'robber': {
            'participantId': robberId,
            'nickname': robberNickname,
            'status': 'ALIVE',
          },
          'remainingThieves': 1,
        },
      ),
    );
  }
}

/// connectAndSubscribe가 토큰을 요구하므로 항상 유효 토큰을 주는 fake.
class _FakeTokenProvider implements TokenProvider {
  @override
  Future<String?> getAccessToken() async => 'test-token';

  @override
  Future<String?> refreshAccessTokenIfNeeded() async => 'test-token';
}

/// 이벤트 주입 datasource + 이벤트 모드 참가자(내 participantId)를 세팅한 컨테이너.
ProviderContainer _eventContainer({
  required _EventInjectableDatasource datasource,
  required int myParticipantId,
  EventArrestStorage? storage,
}) {
  final c = ProviderContainer(
    overrides: [
      gameEventStompDatasourceProvider.overrideWithValue(datasource),
      gameSystemApiProvider.overrideWithValue(_FakeGameSystemApi()),
      tokenProviderProvider.overrideWithValue(_FakeTokenProvider()),
      if (storage != null)
        eventArrestStorageProvider.overrideWithValue(storage),
    ],
  );
  c.listen(gameEventNotifierProvider, (_, _) {}, fireImmediately: true);
  c
      .read(gameParticipantNotifierProvider.notifier)
      .setGameInfo(
        gameId: 1,
        nickname: '경찰',
        team: 'police',
        participantId: myParticipantId,
        isEventGame: true,
      );
  addTearDown(c.dispose);
  return c;
}

GameParticipantInfo _participant({
  int? policeWaitMinutes,
  String? gameStartTime,
}) => GameParticipantInfo(
  gameId: 1,
  team: 'police',
  nickname: '경찰',
  policeWaitMinutes: policeWaitMinutes,
  gameStartTime: gameStartTime,
);

void main() {
  // connectAndSubscribe가 ApiEndpoints.gameConnectionUrl(.env)을 읽으므로 dotenv 초기화.
  setUpAll(() => dotenv.loadFromString(envString: '', isOptional: true));

  // canPoliceArrest는 GameEventState의 메서드 → State 직접 생성으로 순수 검증.
  group('GameEventState.canPoliceArrest', () {
    test('returns_true_when_police_is_moving', () {
      const state = GameEventState(isPoliceMoving: true);
      expect(state.canPoliceArrest(participantInfo: null), isTrue);
    });

    test('returns_true_when_wait_minutes_is_zero', () {
      const state = GameEventState();
      expect(
        state.canPoliceArrest(
          participantInfo: _participant(policeWaitMinutes: 0),
        ),
        isTrue,
      );
    });

    test('returns_true_when_wait_time_already_elapsed', () {
      // gameStartTime(state)이 ISO 파싱보다 우선하므로 타임존 영향 없이 검증.
      final state = GameEventState(
        gameStartTime: DateTime.now().subtract(const Duration(minutes: 10)),
      );
      expect(
        state.canPoliceArrest(
          participantInfo: _participant(policeWaitMinutes: 5),
        ),
        isTrue,
      );
    });

    test('returns_false_when_still_within_wait_time', () {
      final state = GameEventState(
        gameStartTime: DateTime.now().subtract(const Duration(minutes: 1)),
      );
      expect(
        state.canPoliceArrest(
          participantInfo: _participant(policeWaitMinutes: 5),
        ),
        isFalse,
      );
    });

    test('returns_false_when_participant_info_is_null', () {
      const state = GameEventState();
      expect(state.canPoliceArrest(participantInfo: null), isFalse);
    });
  });

  group('GameEventNotifier.syncFromParticipants', () {
    test('overwrites_arrested_and_updates_remaining_thieves', () {
      final api = _FakeGameSystemApi();
      final c = _container(api: api);
      final notifier = c.read(gameEventNotifierProvider.notifier);

      notifier.syncFromParticipants(arrestedIds: {2, 3}, remainingThieves: 1);

      final state = c.read(gameEventNotifierProvider);
      expect(state.arrestedParticipantIds, {2, 3});
      expect(state.remainingThieves, 1);
    });

    test('removes_rearrested_id_from_escaped_set', () async {
      final api = _FakeGameSystemApi();
      final c = _container(api: api);
      final notifier = c.read(gameEventNotifierProvider.notifier);

      // 5번 탈옥 상태 시드 (escaped={5})
      notifier.syncFromParticipants(arrestedIds: {5}, remainingThieves: 1);
      await notifier.escape(1, 5);
      expect(
        c.read(gameEventNotifierProvider).escapedParticipantIds,
        contains(5),
      );

      // 서버 동기화: 5번이 재체포됨 → escaped에서 제거되어야 함
      notifier.syncFromParticipants(arrestedIds: {5, 6}, remainingThieves: 2);

      final state = c.read(gameEventNotifierProvider);
      expect(state.arrestedParticipantIds, {5, 6});
      expect(state.escapedParticipantIds, isEmpty);
    });
  });

  group('GameEventNotifier.arrestRobber', () {
    test('adds_robber_to_arrested_when_api_succeeds', () async {
      final api = _FakeGameSystemApi();
      final c = _container(api: api);
      final notifier = c.read(gameEventNotifierProvider.notifier);

      await notifier.arrestRobber(1, 5);

      final state = c.read(gameEventNotifierProvider);
      expect(state.arrestedParticipantIds, contains(5));
      expect(state.isApiLoading, isFalse);
    });

    test('rolls_back_arrested_and_sets_error_when_api_fails', () async {
      final api = _FakeGameSystemApi()..arrestError = Exception('boom');
      final c = _container(api: api);
      final notifier = c.read(gameEventNotifierProvider.notifier);

      await notifier.arrestRobber(1, 5);

      final state = c.read(gameEventNotifierProvider);
      expect(state.arrestedParticipantIds, isNot(contains(5)));
      expect(state.errorMessage, isNotNull);
      expect(state.isApiLoading, isFalse);
    });

    test('ignores_second_call_while_first_is_in_flight', () async {
      final api = _FakeGameSystemApi()..arrestGate = Completer<void>();
      final c = _container(api: api);
      final notifier = c.read(gameEventNotifierProvider.notifier);

      final first = notifier.arrestRobber(1, 5); // gate에서 대기
      await notifier.arrestRobber(1, 6); // _pendingArrestId != null → 즉시 무시

      final mid = c.read(gameEventNotifierProvider);
      expect(mid.arrestedParticipantIds, contains(5));
      expect(mid.arrestedParticipantIds, isNot(contains(6)));
      expect(api.arrestCount, 1); // 두 번째는 API 호출 자체가 차단됨

      api.arrestGate!.complete();
      await first;
    });
  });

  group('GameEventState.leftParticipantIds', () {
    test('defaults_to_empty_set', () {
      const state = GameEventState();
      expect(state.leftParticipantIds, isEmpty);
    });

    test('copyWith_updates_left_participant_ids', () {
      const state = GameEventState();
      final next = state.copyWith(leftParticipantIds: {2, 3});
      expect(next.leftParticipantIds, {2, 3});
    });

    test('copyWith_preserves_left_participant_ids_when_omitted', () {
      const state = GameEventState(leftParticipantIds: {2});
      final next = state.copyWith(isPoliceMoving: true);
      expect(next.leftParticipantIds, {2});
    });
  });

  group('GameEventNotifier.escape', () {
    for (final loss in ['disconnected', 'error', 'stompError', 'intentional']) {
      test(
        '${loss}_invalidates_old_response_and_manual_confirmation',
        () async {
          SharedPreferences.setMockInitialValues({});
          final oldGate = Completer<void>();
          final api = _FakeGameSystemApi()..escapeGate = oldGate;
          final datasource = _EventInjectableDatasource();
          final c = ProviderContainer(
            overrides: [
              gameEventStompDatasourceProvider.overrideWithValue(datasource),
              gameSystemApiProvider.overrideWithValue(api),
              tokenProviderProvider.overrideWithValue(_FakeTokenProvider()),
            ],
          );
          c.listen(gameEventNotifierProvider, (_, _) {}, fireImmediately: true);
          addTearDown(c.dispose);
          addTearDown(datasource.dispose);
          final notifier = c.read(gameEventNotifierProvider.notifier)
            ..setLocalParticipantId(5)
            ..syncFromParticipants(arrestedIds: {5}, remainingThieves: 1);
          await notifier.connectAndSubscribe(1, team: 'robber');
          datasource.connections.add(StompConnectionState.connected);
          await Future<void>.delayed(Duration.zero);
          final revision = c
              .read(gameEventNotifierProvider)
              .localArrestRevision;
          final oldRequest = notifier.escape(1, 5);

          if (loss == 'intentional') {
            notifier.disconnect();
            await notifier.connectAndSubscribe(1, team: 'robber');
          } else if (loss == 'stompError') {
            datasource.errors.add(
              const StompErrorInfo(
                title: 'lost',
                status: 500,
                detail: '',
                instance: 'STOMP',
              ),
            );
          } else {
            datasource.connections.add(
              loss == 'error'
                  ? StompConnectionState.error
                  : StompConnectionState.disconnected,
            );
          }
          await Future<void>.delayed(Duration.zero);
          expect(c.read(gameEventNotifierProvider).isEscapeInFlight, isFalse);
          datasource.connections.add(StompConnectionState.connected);
          await Future<void>.delayed(Duration.zero);
          // 끊김 중 탈옥→재체포를 놓쳐도 최종 JAILED 집합은 동일하다.
          notifier.syncFromParticipants(arrestedIds: {5}, remainingThieves: 1);
          expect(
            await notifier.escape(1, 5, expectedArrestRevision: revision),
            EscapeRequestResult.ignored,
          );

          final newGate = Completer<void>();
          api.escapeGate = newGate;
          final newRequest = notifier.escape(1, 5);
          oldGate.complete();
          expect(await oldRequest, EscapeRequestResult.stale);
          expect(c.read(gameEventNotifierProvider).arrestedParticipantIds, {5});
          expect(
            c.read(gameEventNotifierProvider).escapedParticipantIds,
            isEmpty,
          );
          expect(c.read(gameEventNotifierProvider).isEscapeInFlight, isTrue);
          newGate.complete();
          expect(await newRequest, EscapeRequestResult.success);
          expect(api.escapeCount, 2);
        },
      );
    }

    test('moves_from_arrested_to_escaped_when_api_succeeds', () async {
      final api = _FakeGameSystemApi();
      final c = _container(api: api);
      final notifier = c.read(gameEventNotifierProvider.notifier);

      notifier.syncFromParticipants(arrestedIds: {5}, remainingThieves: 1);
      final result = await notifier.escape(1, 5);

      final state = c.read(gameEventNotifierProvider);
      expect(result, EscapeRequestResult.success);
      expect(state.arrestedParticipantIds, isNot(contains(5)));
      expect(state.escapedParticipantIds, contains(5));
      expect(state.isApiLoading, isFalse);
    });

    test('restores_arrested_and_sets_error_when_api_fails', () async {
      final api = _FakeGameSystemApi()..escapeError = Exception('boom');
      final c = _container(api: api);
      final notifier = c.read(gameEventNotifierProvider.notifier);

      notifier.syncFromParticipants(arrestedIds: {5}, remainingThieves: 1);
      final result = await notifier.escape(1, 5);

      final state = c.read(gameEventNotifierProvider);
      expect(result, EscapeRequestResult.failure);
      expect(state.arrestedParticipantIds, contains(5));
      expect(state.escapedParticipantIds, isNot(contains(5)));
      expect(state.errorMessage, isNotNull);
    });

    test('submits_once_when_automatic_and_manual_requests_overlap', () async {
      final gate = Completer<void>();
      final api = _FakeGameSystemApi()..escapeGate = gate;
      final c = _container(api: api);
      final notifier = c.read(gameEventNotifierProvider.notifier);
      notifier.syncFromParticipants(arrestedIds: {5}, remainingThieves: 1);

      final automatic = notifier.escape(1, 5);
      await Future<void>.delayed(Duration.zero);
      final manual = await notifier.escape(1, 5);

      expect(manual, EscapeRequestResult.ignored);
      expect(api.escapeCount, 1);
      expect(c.read(gameEventNotifierProvider).isEscapeInFlight, isTrue);

      gate.complete();
      expect(await automatic, EscapeRequestResult.success);
      expect(c.read(gameEventNotifierProvider).isEscapeInFlight, isFalse);
    });

    test('late_failure_does_not_overwrite_a_new_arrest_cycle', () async {
      final gate = Completer<void>();
      final api = _FakeGameSystemApi()
        ..escapeGate = gate
        ..escapeError = Exception('boom');
      final c = _container(api: api);
      final notifier = c.read(gameEventNotifierProvider.notifier);
      notifier.setLocalParticipantId(5);
      notifier.syncFromParticipants(arrestedIds: {5}, remainingThieves: 1);

      final oldRequest = notifier.escape(1, 5);
      await Future<void>.delayed(Duration.zero);
      notifier.syncFromParticipants(arrestedIds: {}, remainingThieves: 2);
      notifier.syncFromParticipants(arrestedIds: {5}, remainingThieves: 1);
      gate.complete();

      expect(await oldRequest, EscapeRequestResult.stale);
      final state = c.read(gameEventNotifierProvider);
      expect(state.arrestedParticipantIds, contains(5));
      expect(state.escapedParticipantIds, isNot(contains(5)));
      expect(state.errorMessage, isNull);
      expect(state.isEscapeInFlight, isFalse);
    });

    test('rearrest_event_wins_over_an_in_flight_escape_response', () async {
      SharedPreferences.setMockInitialValues({});
      final gate = Completer<void>();
      final api = _FakeGameSystemApi()..escapeGate = gate;
      final datasource = _EventInjectableDatasource();
      final c = ProviderContainer(
        overrides: [
          gameEventStompDatasourceProvider.overrideWithValue(datasource),
          gameSystemApiProvider.overrideWithValue(api),
          tokenProviderProvider.overrideWithValue(_FakeTokenProvider()),
        ],
      );
      c.listen(gameEventNotifierProvider, (_, _) {}, fireImmediately: true);
      addTearDown(c.dispose);
      final notifier = c.read(gameEventNotifierProvider.notifier)
        ..setLocalParticipantId(5)
        ..syncFromParticipants(arrestedIds: {5}, remainingThieves: 1);
      await notifier.connectAndSubscribe(1, team: 'robber');

      final escape = notifier.escape(1, 5);
      await Future<void>.delayed(Duration.zero);
      datasource.emitArrest(policeId: 2, robberId: 5);
      await Future<void>.delayed(Duration.zero);
      gate.complete();
      expect(await escape, EscapeRequestResult.stale);

      final state = c.read(gameEventNotifierProvider);
      expect(state.arrestedParticipantIds, contains(5));
      expect(state.escapedParticipantIds, isNot(contains(5)));
      expect(state.isEscapeInFlight, isFalse);
    });

    test('ignores_confirmation_opened_in_a_previous_arrest_cycle', () async {
      final api = _FakeGameSystemApi();
      final c = _container(api: api);
      final notifier = c.read(gameEventNotifierProvider.notifier);
      notifier.setLocalParticipantId(5);
      notifier.syncFromParticipants(arrestedIds: {5}, remainingThieves: 1);
      final previousRevision = c
          .read(gameEventNotifierProvider)
          .localArrestRevision;

      notifier.syncFromParticipants(arrestedIds: {}, remainingThieves: 2);
      notifier.syncFromParticipants(arrestedIds: {5}, remainingThieves: 1);
      final result = await notifier.escape(
        1,
        5,
        expectedArrestRevision: previousRevision,
      );

      expect(result, EscapeRequestResult.ignored);
      expect(api.escapeCount, 0);
      expect(
        c.read(gameEventNotifierProvider).arrestedParticipantIds,
        contains(5),
      );
    });
  });

  group('GameEventNotifier.requestEventArrest (체포 트리거 전용)', () {
    test(
      'returns_true_and_leaves_local_set_untouched_when_api_succeeds',
      () async {
        final api = _FakeGameSystemApi();
        final c = _container(api: api);
        final notifier = c.read(gameEventNotifierProvider.notifier);

        final ok = await notifier.requestEventArrest(1, 7);

        expect(ok, isTrue);
        expect(api.lastArrest, (1, 7));
        final s = c.read(gameEventNotifierProvider);
        // 카운트·집합은 STOMP ARREST 수신이 담당 — 트리거만으로는 비어 있어야 함
        expect(s.myArrestedRobberIds, isEmpty);
        expect(s.arrestedParticipantIds, isEmpty);
        expect(s.isApiLoading, isFalse);
      },
    );

    test('returns_false_and_keeps_set_empty_when_api_fails', () async {
      final api = _FakeGameSystemApi()..arrestError = Exception('boom');
      final c = _container(api: api);
      final notifier = c.read(gameEventNotifierProvider.notifier);

      final ok = await notifier.requestEventArrest(1, 7);

      expect(ok, isFalse);
      final s = c.read(gameEventNotifierProvider);
      expect(s.myArrestedRobberIds, isEmpty);
      expect(s.isApiLoading, isFalse);
    });

    test('ignores_second_request_while_first_in_flight', () async {
      final api = _FakeGameSystemApi()..arrestGate = Completer<void>();
      final c = _container(api: api);
      final notifier = c.read(gameEventNotifierProvider.notifier);

      final first = notifier.requestEventArrest(1, 7); // gate에서 대기
      final second = await notifier.requestEventArrest(1, 8); // pending → false

      expect(second, isFalse);
      expect(api.arrestCount, 1); // 두 번째는 API 호출 자체가 차단됨

      api.arrestGate!.complete();
      expect(await first, isTrue);
    });
  });

  group('GameEventNotifier event-mode arrest (STOMP ARREST 기준, 스펙 §3)', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));
    tearDown(() => SharedPreferences.setMockInitialValues({}));

    test('arrest_event_increments_local_count_when_police_is_me', () async {
      final ds = _EventInjectableDatasource();
      final c = _eventContainer(datasource: ds, myParticipantId: 100);
      final notifier = c.read(gameEventNotifierProvider.notifier);
      await notifier.connectAndSubscribe(1, team: 'police'); // _eventSub 배선

      ds.emitArrest(policeId: 100, robberId: 7, robberNickname: '운영진A');
      await Future<void>.delayed(Duration.zero); // broadcast 전달 대기

      final s = c.read(gameEventNotifierProvider);
      expect(s.myArrestedRobberIds, {7});
      expect(s.myArrestSeq, 1); // 증거 다이얼로그 트리거 신호
      expect(s.lastMyArrestNickname, '운영진A');
      expect(s.arrestedParticipantIds, isEmpty); // 전역 수감 미변경(도둑 ALIVE)
    });

    test('arrest_event_ignored_when_police_is_other', () async {
      final ds = _EventInjectableDatasource();
      final c = _eventContainer(datasource: ds, myParticipantId: 100);
      final notifier = c.read(gameEventNotifierProvider.notifier);
      await notifier.connectAndSubscribe(1, team: 'police');

      ds.emitArrest(policeId: 999, robberId: 7); // 다른 경찰의 체포
      await Future<void>.delayed(Duration.zero);

      final s = c.read(gameEventNotifierProvider);
      expect(s.myArrestedRobberIds, isEmpty);
      expect(s.myArrestSeq, 0);
    });

    test('duplicate_arrest_event_does_not_double_count', () async {
      final ds = _EventInjectableDatasource();
      final c = _eventContainer(datasource: ds, myParticipantId: 100);
      final notifier = c.read(gameEventNotifierProvider.notifier);
      await notifier.connectAndSubscribe(1, team: 'police');

      ds.emitArrest(policeId: 100, robberId: 7);
      await Future<void>.delayed(Duration.zero);
      ds.emitArrest(policeId: 100, robberId: 7); // 같은 도둑 중복 수신
      await Future<void>.delayed(Duration.zero);

      final s = c.read(gameEventNotifierProvider);
      expect(s.myArrestedRobberIds, {7});
      expect(s.myArrestSeq, 1); // 중복은 카운트/신호 미증가
    });

    test('restore_then_arrest_preserves_persisted_ids', () async {
      // 입장 시 복원({7}) 후 신규 체포(8) → {7,8} 유지 & 영속화
      SharedPreferences.setMockInitialValues({
        'event_game_arrest': '{"gameId":1,"arrestedRobberIds":[7]}',
      });
      final ds = _EventInjectableDatasource();
      final c = _eventContainer(datasource: ds, myParticipantId: 100);
      final notifier = c.read(gameEventNotifierProvider.notifier);
      await notifier.connectAndSubscribe(1, team: 'police');

      await notifier.loadMyArrests(1); // 입장 복원
      ds.emitArrest(policeId: 100, robberId: 8); // 신규 체포
      // 영속화는 fire-and-forget — load 전에 settle 시간을 준다.
      await Future<void>.delayed(const Duration(milliseconds: 20));

      final s = c.read(gameEventNotifierProvider);
      expect(s.myArrestedRobberIds, {7, 8});
      expect(await c.read(eventArrestStorageProvider).load(1), {7, 8});
    });

    test('loadMyArrests_restores_persisted_set_for_same_game', () async {
      SharedPreferences.setMockInitialValues({
        'event_game_arrest': '{"gameId":1,"arrestedRobberIds":[7,8]}',
      });
      final c = _container(api: _FakeGameSystemApi());
      final notifier = c.read(gameEventNotifierProvider.notifier);

      await notifier.loadMyArrests(1);

      expect(c.read(gameEventNotifierProvider).myArrestedRobberIds, {7, 8});
    });

    test('arrest_event_still_counts_when_persistence_throws', () async {
      final ds = _EventInjectableDatasource();
      final c = _eventContainer(
        datasource: ds,
        myParticipantId: 100,
        storage: _ThrowingArrestStorage(),
      );
      final notifier = c.read(gameEventNotifierProvider.notifier);
      await notifier.connectAndSubscribe(1, team: 'police');

      ds.emitArrest(policeId: 100, robberId: 7, robberNickname: '운영진A');
      await Future<void>.delayed(Duration.zero);

      final s = c.read(gameEventNotifierProvider);
      // 영속화 실패해도 인메모리 집계·신호는 유지된다.
      expect(s.myArrestedRobberIds, contains(7));
      expect(s.myArrestSeq, 1);
    });
  });
}

/// load/save 모두 throw — 영속화 실패가 체포 성공을 무효화하지 않는지 검증용.
class _ThrowingArrestStorage extends EventArrestStorage {
  @override
  Future<Set<int>> load(int gameId) async => throw Exception('io');
  @override
  Future<void> save(int gameId, Set<int> ids) async => throw Exception('io');
}
