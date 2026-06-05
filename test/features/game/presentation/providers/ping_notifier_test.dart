import 'dart:async';

import 'package:cops_and_robbers/core/constants/game_config.dart';
import 'package:cops_and_robbers/features/game/data/datasources/game_event_stomp_datasource.dart';
import 'package:cops_and_robbers/features/game/data/models/ping_message_dto.dart';
import 'package:cops_and_robbers/features/game/domain/entities/ping.dart';
import 'package:cops_and_robbers/features/game/presentation/providers/game_event_provider.dart';
import 'package:cops_and_robbers/features/game/presentation/providers/ping_provider.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// publishPing 결과를 제어하고 onPing을 수동 emit하는 fake.
class _FakeDatasource extends GameEventStompDatasource {
  bool publishResult = true;
  int publishCount = 0;

  // onPing은 부모 _pingController(private) 대신 테스트용 컨트롤러로 노출한다.
  final _testCtrl = StreamController<PingMessageDto>.broadcast();

  @override
  Stream<PingMessageDto> get onPing => _testCtrl.stream;

  @override
  bool publishPing(int gameId, PingType type, double lat, double lng) {
    publishCount++;
    return publishResult;
  }

  void emitPing(PingMessageDto dto) => _testCtrl.add(dto);
}

PingMessageDto _dto({required String id, String type = 'FOUND'}) =>
    PingMessageDto(
      id: id,
      gameId: 1,
      pingType: type,
      location: const PingLocationDto(latitude: 37.5, longitude: 127.0),
      pingSender: const PingSenderDto(participantId: 9, nickname: '플레이어'),
      timestamp: '2026-06-01T14:32:10.123+09:00',
    );

ProviderContainer _container(_FakeDatasource fake) {
  final c = ProviderContainer(
    overrides: [gameEventStompDatasourceProvider.overrideWithValue(fake)],
  );
  // autoDispose 생존 유지 (Timer 진행 중 dispose 방지)
  c.listen(pingNotifierProvider, (prev, next) {}, fireImmediately: true);
  addTearDown(c.dispose);
  return c;
}

bool _add(ProviderContainer c) => c
    .read(pingNotifierProvider.notifier)
    .addPing(type: PingType.found, latitude: 1, longitude: 2, gameId: 1);

void main() {
  group('PingNotifier (echo)', () {
    test('publishes_when_added_but_does_not_add_to_state_locally', () {
      fakeAsync((async) {
        final fake = _FakeDatasource();
        final c = _container(fake);
        final ok = _add(c);
        expect(ok, true);
        expect(fake.publishCount, 1);
        expect(c.read(pingNotifierProvider), isEmpty);
      });
    });

    test('adds_to_state_when_ping_received_via_echo', () {
      fakeAsync((async) {
        final fake = _FakeDatasource();
        final c = _container(fake);
        fake.emitPing(_dto(id: 'srv-1'));
        async.flushMicrotasks();
        expect(c.read(pingNotifierProvider).length, 1);
        expect(c.read(pingNotifierProvider).first.id, 'srv-1');
      });
    });

    test('removes_received_ping_after_lifetime', () {
      fakeAsync((async) {
        final fake = _FakeDatasource();
        final c = _container(fake);
        fake.emitPing(_dto(id: 'srv-1'));
        async.flushMicrotasks();
        expect(c.read(pingNotifierProvider).length, 1);
        async.elapse(GameConfig.pingLifetime + const Duration(milliseconds: 1));
        expect(c.read(pingNotifierProvider), isEmpty);
      });
    });

    test('upserts_and_resets_timer_on_duplicate_id', () {
      fakeAsync((async) {
        final fake = _FakeDatasource();
        final c = _container(fake);
        fake.emitPing(_dto(id: 'srv-1'));
        async.flushMicrotasks();
        async.elapse(const Duration(milliseconds: 2000));
        fake.emitPing(_dto(id: 'srv-1')); // 같은 id 재수신 → 타이머 리셋
        async.flushMicrotasks();
        expect(c.read(pingNotifierProvider).length, 1);
        async.elapse(const Duration(milliseconds: 1000));
        expect(c.read(pingNotifierProvider).length, 1);
        async.elapse(const Duration(milliseconds: 1600));
        expect(c.read(pingNotifierProvider), isEmpty);
      });
    });

    test('skips_help_ping', () {
      fakeAsync((async) {
        final fake = _FakeDatasource();
        final c = _container(fake);
        fake.emitPing(_dto(id: 'srv-1', type: 'HELP'));
        async.flushMicrotasks();
        expect(c.read(pingNotifierProvider), isEmpty);
      });
    });

    test('rejects_and_cooldowns_when_window_exceeded', () {
      fakeAsync((async) {
        final fake = _FakeDatasource();
        final c = _container(fake);
        for (var i = 0; i < GameConfig.pingRateMaxCount; i++) {
          expect(_add(c), true);
        }
        expect(_add(c), false);
      });
    });

    test('does_not_consume_rate_limit_when_disconnected', () {
      fakeAsync((async) {
        final fake = _FakeDatasource()..publishResult = false;
        final c = _container(fake);
        for (var i = 0; i < 20; i++) {
          expect(_add(c), false);
        }
        fake.publishResult = true;
        expect(_add(c), true);
      });
    });
  });
}
