import 'package:cops_and_robbers/features/game/data/services/event_arrest_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('load_returns_empty_when_no_record', () async {
    expect(await EventArrestStorage().load(1), isEmpty);
  });

  test('save_then_load_restores_set_for_same_game', () async {
    final storage = EventArrestStorage();
    await storage.save(1, {7, 8});
    expect(await storage.load(1), {7, 8});
  });

  test('different_game_load_clears_record_so_it_does_not_revive', () async {
    final storage = EventArrestStorage();
    await storage.save(1, {7, 8});
    expect(await storage.load(2), isEmpty); // 다른 게임 진입 → 리셋
    expect(await storage.load(1), isEmpty); // 부활하지 않음(레코드 제거됨)
  });

  test('save_persists_for_current_game_after_reset', () async {
    final storage = EventArrestStorage();
    await storage.save(1, {7});
    await storage.load(2); // 게임 2 진입 → 게임1 레코드 제거
    await storage.save(2, {9}); // 게임 2 검거
    expect(await storage.load(2), {9});
  });
}
