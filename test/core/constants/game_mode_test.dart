import 'package:cops_and_robbers/core/constants/game_mode.dart';
import 'package:cops_and_robbers/core/widgets/tutorial/tutorial_script.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'game_mode_from_json_is_cops_and_robbers_when_old_server_omits_mode',
    () {
      expect(GameMode.fromJson(null), GameMode.copsAndRobbers);
    },
  );

  test(
    'game_mode_from_json_is_unknown_when_server_sends_future_zombie_mode',
    () {
      final mode = GameMode.fromJson('ZOMBIE');
      expect(mode, GameMode.unknown);
      expect(mode.isSupported, isFalse);
    },
  );

  test('game_mode_from_json_parses_hide_and_seek_when_server_sends_it', () {
    expect(GameMode.fromJson('TAG'), GameMode.hideAndSeek);
    expect(GameMode.hideAndSeek.toJson(), 'TAG');
    expect(GameMode.copsAndRobbers.toJson(), 'COPS_AND_ROBBERS');
  });

  test('hide_and_seek_does_not_use_jail_when_room_has_no_jail', () {
    expect(GameMode.hideAndSeek.usesJail, isFalse);
    expect(GameMode.copsAndRobbers.usesJail, isTrue);
  });

  test('tutorial_mode_is_tag_when_room_plays_hide_and_seek', () {
    expect(GameMode.hideAndSeek.tutorialMode, TutorialMode.tag);
    expect(GameMode.copsAndRobbers.tutorialMode, TutorialMode.classic);
  });
}
