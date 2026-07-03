import 'package:cops_and_robbers/features/session/presentation/providers/game_participant_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GameParticipantInfo.isEventGame', () {
    test('defaults_to_false', () {
      const info = GameParticipantInfo(
        gameId: 1,
        team: 'POLICE',
        nickname: 'a',
      );
      expect(info.isEventGame, isFalse);
    });

    test('copyWith_updates_is_event_game', () {
      const info = GameParticipantInfo(
        gameId: 1,
        team: 'POLICE',
        nickname: 'a',
      );
      expect(info.copyWith(isEventGame: true).isEventGame, isTrue);
    });

    test('copyWith_preserves_is_event_game_when_omitted', () {
      const info = GameParticipantInfo(
        gameId: 1,
        team: 'POLICE',
        nickname: 'a',
        isEventGame: true,
      );
      expect(info.copyWith(nickname: 'b').isEventGame, isTrue);
    });
  });
}
