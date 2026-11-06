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

  List<GameMenuEntry> sceneEntries({
    bool isPolice = false,
    bool isArrested = false,
    bool isZoneExitActive = false,
    bool isEventGame = false,
  }) => gameMenuEntries(
    isPolice: isPolice,
    isArrested: isArrested,
    isZoneExitActive: isZoneExitActive,
    isEventGame: isEventGame,
    isMapVisible: false,
  );

  // 시작 장면 메뉴는 위로 펼쳐진다 — 위에서부터 QR, 참가자, 채팅(DEC-0133). 지도를 덮어 좌표는 뺀다.
  test('police_wait_scene_stacks_arrest_participants_chat_when_menu_opens', () {
    expect(sceneEntries(isPolice: true), [
      GameMenuEntry.arrest,
      GameMenuEntry.participants,
      GameMenuEntry.chat,
    ]);
  });

  test('robber_explainer_scene_stacks_my_qr_participants_chat_when_menu_opens', () {
    expect(sceneEntries(), [
      GameMenuEntry.myQr,
      GameMenuEntry.participants,
      GameMenuEntry.chat,
    ]);
  });

  // 장면에는 채팅 전용 버튼이 없어, 구역을 벗어나도 채팅은 메뉴에 남는다
  test('scene_menu_keeps_only_chat_when_robber_runs_out_of_the_zone', () {
    expect(sceneEntries(isZoneExitActive: true), [GameMenuEntry.chat]);
  });

  test('map_menu_has_no_chat_because_chat_keeps_its_own_button', () {
    expect(entries(isPolice: true), isNot(contains(GameMenuEntry.chat)));
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
