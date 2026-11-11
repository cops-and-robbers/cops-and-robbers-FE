import 'package:audioplayers/audioplayers.dart';
import 'package:cops_and_robbers/core/services/sound_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // iOS 오디오 세션은 앱 전체가 하나다 — 무전 중 효과음이 ambient로 바꾸면 마이크·상대 목소리가 죽는다 (#697)
  test('keeps_ios_session_able_to_record_when_beep_plays_during_radio', () {
    final context = SoundService.audioContextFor(isRadioActive: true);
    expect(context.iOS.category, AVAudioSessionCategory.playAndRecord);
    expect(
      context.iOS.options,
      containsAll({
        AVAudioSessionOptions.mixWithOthers,
        AVAudioSessionOptions.defaultToSpeaker,
      }),
    );
  });

  test('follows_silent_switch_when_no_radio_is_on', () {
    expect(
      SoundService.audioContextFor(isRadioActive: false).iOS.category,
      AVAudioSessionCategory.ambient,
    );
  });
}
