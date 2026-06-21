import 'package:cops_and_robbers/features/game/data/models/game_event_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GameEventModel.fromJson type 매핑', () {
    test('parses_player_left_type_from_server_string', () {
      final model = GameEventModel.fromJson({
        'type': 'PLAYER_LEFT',
        'data': {'participantId': 42, 'nickname': '도둑1', 'team': 'ROBBER'},
      });
      expect(model.type, GameEventType.playerLeft);
    });

    test('falls_back_to_unknown_for_unrecognized_type', () {
      final model = GameEventModel.fromJson({'type': 'SOMETHING_NEW'});
      expect(model.type, GameEventType.unknown);
    });
  });
}
