import 'package:cops_and_robbers/features/game/data/datasources/zone_warning_local_datasource.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final start = DateTime(2026, 11, 8, 12);
  late ZoneWarningLocalDataSource ds;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    ds = ZoneWarningLocalDataSource(await SharedPreferences.getInstance());
  });

  test('same_round_restores_when_start_times_differ_by_1_5_seconds', () async {
    // 시작 이벤트와 게임 정보 API의 시각은 소수점 자리가 다를 수 있다 (#641)
    await ds.save(gameId: 7, startedAt: start, outsideSeconds: 75);
    final restored = await ds.load(
      gameId: 7,
      startedAt: start.add(const Duration(milliseconds: 1500)),
    );
    expect(restored, 75);
  });

  test('host_restart_three_seconds_later_is_a_new_round', () async {
    await ds.save(gameId: 7, startedAt: start, outsideSeconds: 75);
    expect(
      await ds.load(
        gameId: 7,
        startedAt: start.add(const Duration(seconds: 3)),
      ),
      0,
    );
  });

  test('unknown_start_time_does_not_restore', () async {
    await ds.save(gameId: 7, startedAt: start, outsideSeconds: 75);
    expect(await ds.load(gameId: 7, startedAt: null), 0);
  });

  test('other_game_does_not_restore', () async {
    await ds.save(gameId: 7, startedAt: start, outsideSeconds: 75);
    expect(await ds.load(gameId: 8, startedAt: start), 0);
  });

  test('cleared_after_force_arrest_restores_zero', () async {
    await ds.save(gameId: 7, startedAt: start, outsideSeconds: 75);
    await ds.clear();
    expect(await ds.load(gameId: 7, startedAt: start), 0);
  });
}
