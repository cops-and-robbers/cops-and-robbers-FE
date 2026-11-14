import 'package:cops_and_robbers/core/constants/game_mode.dart';
import 'package:cops_and_robbers/features/session/data/models/game_settings_response.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _json({String? mode, bool withMode = true}) => {
  'roundDurationMinutes': 30,
  'locationRevealIntervalMinutes': 2,
  'policeWaitMinutes': 3,
  'maxParticipants': 10,
  if (withMode) 'gameMode': mode,
};

void main() {
  test('settings_response_reads_hide_and_seek_when_server_sends_mode', () {
    final res = GameSettingsResponse.fromJson(_json(mode: 'TAG'));
    expect(res.gameMode, GameMode.hideAndSeek);
  });

  test('settings_response_is_cops_and_robbers_when_old_server_omits_mode', () {
    final res = GameSettingsResponse.fromJson(_json(withMode: false));
    expect(res.gameMode, GameMode.copsAndRobbers);
  });

  test('settings_response_is_unknown_when_server_sends_future_mode', () {
    final res = GameSettingsResponse.fromJson(_json(mode: 'ZOMBIE'));
    expect(res.gameMode, GameMode.unknown);
  });
}
