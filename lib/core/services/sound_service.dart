import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../constants/app_sounds.dart';

/// 효과음 서비스
///
/// 시스템 소리 설정을 따른다 — iOS는 무음 스위치를 켜면 울리지 않고(ambient),
/// Android는 미디어 볼륨을 따른다(게임 용도). 듣던 음악은 끊지 않고 섞어 낸다.
/// 소리가 안 나도 진동·화면이 같은 신호를 주므로 실패는 로그만 남긴다.
class SoundService {
  SoundService._();

  static final SoundService _instance = SoundService._();
  factory SoundService.instance() => _instance;

  /// 효과음 오디오 설정.
  ///
  /// iOS 오디오 세션은 앱 전체에 하나라 효과음이 바꾸면 무전(WebRTC)도 같이 바뀐다.
  /// 무전 중에 ambient로 바꾸면 마이크 입력이 끊기고 무음 스위치에 상대 목소리까지 꺼지므로,
  /// 무전이 켜져 있는 동안은 녹음·재생이 되는 playAndRecord로 둔다 (#697).
  @visibleForTesting
  static AudioContext audioContextFor({required bool radioActive}) =>
      AudioContext(
        iOS: radioActive
            ? AudioContextIOS(
                category: AVAudioSessionCategory.playAndRecord,
                options: const {
                  AVAudioSessionOptions.mixWithOthers,
                  AVAudioSessionOptions.defaultToSpeaker,
                  AVAudioSessionOptions.allowBluetooth,
                },
              )
            : AudioContextIOS(category: AVAudioSessionCategory.ambient),
        android: const AudioContextAndroid(
          usageType: AndroidUsageType.game,
          contentType: AndroidContentType.sonification,
          audioFocus: AndroidAudioFocus.none,
        ),
      );

  /// 경찰 무전 방에 있는 동안 true — 무전 세션이 켜고 끈다
  bool radioActive = false;

  AudioContext get _context => audioContextFor(radioActive: radioActive);

  AudioPlayer? _siren;
  bool _sirenOn = false;
  AudioPlayer? _beep;

  // 경로를 AppSounds 값 그대로 쓰도록 기본 접두어('assets/')를 뺀다
  AudioPlayer get _sirenPlayer =>
      _siren ??= AudioPlayer()..audioCache = AudioCache(prefix: '');

  /// 사이렌을 미리 꺼내 둔다 — 첫 재생이 에셋을 꺼내느라 "출동!"보다 늦지 않게
  Future<void> preloadSiren() async {
    try {
      await _sirenPlayer.audioCache.load(AppSounds.siren);
    } catch (e) {
      debugPrint('[Sound] ❌ 사이렌 미리 불러오기 실패: $e');
    }
  }

  /// 출동 사이렌을 한 번 틀거나 끈다
  Future<void> siren(bool on) async {
    _sirenOn = on;
    try {
      final player = on ? _sirenPlayer : _siren;
      if (player == null) return;
      if (on) {
        await player.setAudioContext(_context);
        await player.setReleaseMode(ReleaseMode.stop);
        await player.play(AssetSource(AppSounds.siren));
      }
      // 첫 재생은 에셋을 꺼내느라 늦다 — 그사이 끄라는 요청이 왔으면 여기서 끈다
      if (!_sirenOn) await player.stop();
    } catch (e) {
      debugPrint('[Sound] ❌ 사이렌 ${on ? '재생' : '정지'} 실패: $e');
    }
  }

  /// 무전 삑 — 다른 경찰이 말을 시작하거나 끝냈다는 신호 (#697)
  ///
  /// 화면을 안 보고 뛰는 중에도 무전이 왔다는 걸 알게 한다. 사이렌과 같은 설정이라
  /// 무음 스위치(iOS)·미디어 볼륨(Android)을 따른다.
  Future<void> radioBeep() async {
    try {
      final player = _beep ??= AudioPlayer()..audioCache = AudioCache(prefix: '');
      await player.setAudioContext(_context);
      await player.setReleaseMode(ReleaseMode.stop);
      await player.play(AssetSource(AppSounds.radioBeep));
    } catch (e) {
      debugPrint('[Sound] ❌ 무전 삑 재생 실패: $e');
    }
  }
}
