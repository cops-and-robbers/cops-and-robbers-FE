import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:cops_and_robbers/features/game/data/datasources/game_event_stomp_datasource.dart';
import 'package:cops_and_robbers/features/game/data/datasources/game_system_api_datasource.dart';
import 'package:cops_and_robbers/features/game/data/models/arrest_request_model.dart';
import 'package:cops_and_robbers/features/game/data/models/arrest_response_model.dart';
import 'package:cops_and_robbers/features/game/data/models/game_area_model.dart';
import 'package:cops_and_robbers/features/game/data/services/event_arrest_storage.dart';
import 'package:cops_and_robbers/features/game/presentation/providers/game_event_provider.dart';
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
    test('moves_from_arrested_to_escaped_when_api_succeeds', () async {
      final api = _FakeGameSystemApi();
      final c = _container(api: api);
      final notifier = c.read(gameEventNotifierProvider.notifier);

      notifier.syncFromParticipants(arrestedIds: {5}, remainingThieves: 1);
      await notifier.escape(1, 5);

      final state = c.read(gameEventNotifierProvider);
      expect(state.arrestedParticipantIds, isNot(contains(5)));
      expect(state.escapedParticipantIds, contains(5));
      expect(state.isApiLoading, isFalse);
    });

    test('restores_arrested_and_sets_error_when_api_fails', () async {
      final api = _FakeGameSystemApi()..escapeError = Exception('boom');
      final c = _container(api: api);
      final notifier = c.read(gameEventNotifierProvider.notifier);

      notifier.syncFromParticipants(arrestedIds: {5}, remainingThieves: 1);
      await notifier.escape(1, 5);

      final state = c.read(gameEventNotifierProvider);
      expect(state.arrestedParticipantIds, contains(5));
      expect(state.escapedParticipantIds, isNot(contains(5)));
      expect(state.errorMessage, isNotNull);
    });
  });

  group('GameEventNotifier event-mode arrest', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));
    tearDown(() => SharedPreferences.setMockInitialValues({}));

    test('arrestForEvent_adds_local_set_returns_index_and_leaves_global_empty',
        () async {
      final api = _FakeGameSystemApi();
      final c = _container(api: api);
      final notifier = c.read(gameEventNotifierProvider.notifier);

      final result = await notifier.arrestRobberForEvent(1, 7);

      expect(result?.evidenceIndex, 1);
      expect(result?.robberNickname, '도둑');
      final s = c.read(gameEventNotifierProvider);
      expect(s.myArrestedRobberIds, {7});
      expect(s.arrestedParticipantIds, isEmpty); // 전역 수감 집합 미변경(도둑 ALIVE)
    });

    test('arrestForEvent_returns_null_and_keeps_set_when_api_fails', () async {
      final api = _FakeGameSystemApi()..arrestError = Exception('boom');
      final c = _container(api: api);
      final notifier = c.read(gameEventNotifierProvider.notifier);

      final result = await notifier.arrestRobberForEvent(1, 7);

      expect(result, isNull);
      expect(c.read(gameEventNotifierProvider).myArrestedRobberIds, isEmpty);
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

    test('loadMyArrests_merges_without_overwriting_in_flight_arrest', () async {
      // 영속값 {7} 이 있는데, 복원 전에 신규 체포 8이 반영된 상태에서 복원이 늦게 완료돼도
      // 8이 유실되지 않고 {7,8} 로 병합돼야 한다.
      SharedPreferences.setMockInitialValues({
        'event_game_arrest': '{"gameId":1,"arrestedRobberIds":[7]}',
      });
      final c = _container(api: _FakeGameSystemApi());
      final notifier = c.read(gameEventNotifierProvider.notifier);
      await notifier.arrestRobberForEvent(1, 8); // 신규 체포 먼저 반영

      await notifier.loadMyArrests(1); // 늦은 복원

      expect(c.read(gameEventNotifierProvider).myArrestedRobberIds, {7, 8});
    });

    test('arrestForEvent_ignores_second_call_while_first_in_flight', () async {
      final api = _FakeGameSystemApi()..arrestGate = Completer<void>();
      final c = _container(api: api);
      final notifier = c.read(gameEventNotifierProvider.notifier);

      final first = notifier.arrestRobberForEvent(1, 7); // gate에서 대기
      final second = await notifier.arrestRobberForEvent(1, 8); // pending → 즉시 null

      expect(second, isNull);
      expect(api.arrestCount, 1); // 두 번째는 API 호출 자체가 차단됨

      api.arrestGate!.complete();
      expect((await first)?.evidenceIndex, 1);
      expect(c.read(gameEventNotifierProvider).myArrestedRobberIds, {7});
    });

    test('arrestForEvent_still_succeeds_when_persistence_throws', () async {
      final c = ProviderContainer(
        overrides: [
          gameEventStompDatasourceProvider.overrideWithValue(_FakeDatasource()),
          gameSystemApiProvider.overrideWithValue(_FakeGameSystemApi()),
          eventArrestStorageProvider.overrideWithValue(_ThrowingArrestStorage()),
        ],
      );
      c.listen(gameEventNotifierProvider, (_, _) {}, fireImmediately: true);
      addTearDown(c.dispose);
      final notifier = c.read(gameEventNotifierProvider.notifier);

      final result = await notifier.arrestRobberForEvent(1, 7);

      expect(result, isNotNull); // 영속화 실패해도 체포 성공 피드백 유지
      expect(result?.robberNickname, '도둑');
      expect(c.read(gameEventNotifierProvider).myArrestedRobberIds, contains(7));
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
