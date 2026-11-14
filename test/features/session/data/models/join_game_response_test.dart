import 'package:cops_and_robbers/core/constants/game_mode.dart';
import 'package:cops_and_robbers/features/session/data/models/join_game_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('JoinGameResponse.fromJson', () {
    test('isEventGame_defaults_to_false_when_absent', () {
      final r = JoinGameResponse.fromJson({'gameId': 1, 'participantId': 2});
      expect(r.isEventGame, isFalse);
    });

    test('isEventGame_is_true_when_present', () {
      final r = JoinGameResponse.fromJson({
        'gameId': 1,
        'participantId': 2,
        'isEventGame': true,
      });
      expect(r.isEventGame, isTrue);
    });

    test('joiner_sees_hide_and_seek_when_join_response_says_tag', () {
      final r = JoinGameResponse.fromJson({
        'gameId': 1,
        'participantId': 2,
        'gameMode': 'TAG',
      });
      expect(r.gameMode, GameMode.hideAndSeek);
    });

    test('joiner_sees_cops_and_robbers_when_old_server_omits_mode', () {
      final r = JoinGameResponse.fromJson({'gameId': 1, 'participantId': 2});
      expect(r.gameMode, GameMode.copsAndRobbers);
    });
  });
}
