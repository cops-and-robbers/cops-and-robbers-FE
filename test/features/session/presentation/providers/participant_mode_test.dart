import 'package:cops_and_robbers/core/constants/game_mode.dart';
import 'package:cops_and_robbers/features/session/data/models/game_settings_response.dart';
import 'package:cops_and_robbers/features/session/presentation/providers/game_participant_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

GameSettingsResponse _settings(String mode) => GameSettingsResponse.fromJson({
  'roundDurationMinutes': 30,
  'locationRevealIntervalMinutes': 2,
  'policeWaitMinutes': 3,
  'maxParticipants': 10,
  'gameMode': mode,
});

void main() {
  test(
    'participant_mode_becomes_hide_and_seek_when_lobby_settings_say_tag',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameParticipantNotifierProvider.notifier);
      notifier.setGameInfo(gameId: 1, nickname: '참가자');

      final settings = _settings('TAG');
      notifier.initFromLobby(participantId: 5, gameMode: settings.gameMode);

      expect(
        container.read(gameParticipantNotifierProvider)!.gameMode,
        GameMode.hideAndSeek,
      );
    },
  );

  test(
    'participant_mode_becomes_hide_and_seek_when_settings_update_says_tag',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameParticipantNotifierProvider.notifier);
      notifier.setGameInfo(gameId: 1, nickname: '참가자');

      notifier.updateSettings(gameMode: _settings('TAG').gameMode);

      expect(
        container.read(gameParticipantNotifierProvider)!.gameMode,
        GameMode.hideAndSeek,
      );
    },
  );
}
