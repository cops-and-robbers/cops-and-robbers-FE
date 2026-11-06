import 'package:cops_and_robbers/features/game/domain/game_menu_entries.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  List<GameMenuEntry> entries({
    bool isPolice = false,
    bool isArrested = false,
    bool isZoneExitActive = false,
    bool isEventGame = false,
  }) => gameMenuEntries(
    isPolice: isPolice,
    isArrested: isArrested,
    isZoneExitActive: isZoneExitActive,
    isEventGame: isEventGame,
  );

  // 대기·설명 장면은 지도를 덮고 있어 좌표를 켜도 보이지 않는다
  test('grid_is_left_out_when_scene_covers_the_map', () {
    expect(
      gameMenuEntries(
        isPolice: true,
        isArrested: false,
        isZoneExitActive: false,
        isEventGame: false,
        isMapVisible: false,
      ),
      [GameMenuEntry.participants, GameMenuEntry.arrest],
    );
  });

  test('police_gets_arrest_on_the_right_when_chasing_in_a_normal_game', () {
    expect(entries(isPolice: true), [
      GameMenuEntry.grid,
      GameMenuEntry.participants,
      GameMenuEntry.arrest,
    ]);
  });

  test('robber_gets_my_qr_when_running_in_a_normal_game', () {
    expect(entries(), [
      GameMenuEntry.grid,
      GameMenuEntry.participants,
      GameMenuEntry.myQr,
    ]);
  });

  test('jailed_robber_gets_jail_info_instead_of_qr_when_caught', () {
    expect(entries(isArrested: true), [
      GameMenuEntry.grid,
      GameMenuEntry.participants,
      GameMenuEntry.jailed,
    ]);
  });

  test('only_grid_remains_when_robber_runs_out_of_the_zone', () {
    expect(entries(isZoneExitActive: true), [GameMenuEntry.grid]);
  });

  test('event_police_keeps_evidence_board_when_out_of_the_zone', () {
    expect(entries(isPolice: true, isEventGame: true, isZoneExitActive: true), [
      GameMenuEntry.grid,
      GameMenuEntry.evidenceBoard,
    ]);
  });

  test('event_police_gets_evidence_board_at_the_right_end', () {
    expect(entries(isPolice: true, isEventGame: true), [
      GameMenuEntry.grid,
      GameMenuEntry.participants,
      GameMenuEntry.arrest,
      GameMenuEntry.evidenceBoard,
    ]);
  });

  test('event_robber_has_no_evidence_board_when_staffing_the_booth', () {
    expect(entries(isEventGame: true), [
      GameMenuEntry.grid,
      GameMenuEntry.participants,
      GameMenuEntry.myQr,
    ]);
  });
}
