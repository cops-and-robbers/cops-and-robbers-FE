import 'package:cops_and_robbers/features/session/data/models/join_game_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('JoinGameResponse.fromJson', () {
    test('isEventGame_defaults_to_false_when_absent', () {
      final r = JoinGameResponse.fromJson({'gameId': 1, 'participantId': 2});
      expect(r.isEventGame, isFalse);
    });

    test('isEventGame_is_true_when_present', () {
      final r = JoinGameResponse.fromJson(
        {'gameId': 1, 'participantId': 2, 'isEventGame': true},
      );
      expect(r.isEventGame, isTrue);
    });
  });
}
