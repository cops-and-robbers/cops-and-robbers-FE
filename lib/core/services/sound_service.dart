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

  static final _context = AudioContext(
    iOS: AudioContextIOS(category: AVAudioSessionCategory.ambient),
    android: const AudioContextAndroid(
      usageType: AndroidUsageType.game,
      contentType: AndroidContentType.sonification,
      audioFocus: AndroidAudioFocus.none,
    ),
  );

  AudioPlayer? _siren;
  bool _sirenOn = false;

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
}
