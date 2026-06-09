import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

import '../constants/vibration_patterns.dart';

/// 진동 피드백 서비스
///
/// 디바이스 지원 여부를 체크하고, 상수 기반으로 진동을 실행한다.
/// amplitude 미지원 기기에서는 duration만으로 폴백.
class VibrationService {
  VibrationService._();

  static final VibrationService _instance = VibrationService._();
  factory VibrationService.instance() => _instance;

  /// 디바이스 지원 여부 캐싱
  bool _hasVibrator = false;
  bool _hasAmplitudeControl = false;
  bool _hasCustomVibrationsSupport = false;
  bool _initialized = false;

  /// 초기화 — 앱 시작 시 1회 호출
  Future<void> init() async {
    if (_initialized) return;

    try {
      _hasVibrator = await Vibration.hasVibrator();
      _hasAmplitudeControl = await Vibration.hasAmplitudeControl();
      _hasCustomVibrationsSupport =
          await Vibration.hasCustomVibrationsSupport();
    } catch (e) {
      // 초기화 실패 시 진동 비활성 (앱 실행에는 영향 없음)
      debugPrint('[Vibration] ❌ 초기화 실패: $e');
      _hasVibrator = false;
    }

    _initialized = true;

    debugPrint(
      '[Vibration] vibrator: $_hasVibrator, '
      'amplitude: $_hasAmplitudeControl, '
      'custom: $_hasCustomVibrationsSupport',
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 단일 진동 (duration + amplitude)
  // ═══════════════════════════════════════════════════════════════════════

  /// 단일 진동 실행 (fire-and-forget)
  void _vibrateSingle(int duration, int amplitude) {
    if (!_hasVibrator) return;

    if (_hasAmplitudeControl) {
      Vibration.vibrate(duration: duration, amplitude: amplitude);
    } else {
      // amplitude 미지원 → duration만으로 폴백
      Vibration.vibrate(duration: duration);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 패턴 진동 (pattern + intensities)
  // ═══════════════════════════════════════════════════════════════════════

  /// 패턴 진동 실행 (fire-and-forget)
  void _vibratePattern(List<int> pattern, List<int> intensities) {
    if (!_hasVibrator) return;

    if (_hasCustomVibrationsSupport && _hasAmplitudeControl) {
      Vibration.vibrate(pattern: pattern, intensities: intensities);
    } else if (_hasCustomVibrationsSupport) {
      // intensities 미지원 → pattern만으로 실행
      Vibration.vibrate(pattern: pattern);
    } else {
      // custom pattern 미지원 → 진동 구간만 합산하여 단일 진동 폴백
      var vibrationOnly = 0;
      for (var i = 1; i < pattern.length; i += 2) {
        vibrationOnly += pattern[i];
      }
      Vibration.vibrate(duration: vibrationOnly);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // UI
  // ═══════════════════════════════════════════════════════════════════════

  /// 버튼 탭 햅틱 (OS 네이티브 — UI 피드백에 자연스러움)
  void buttonTap() => HapticFeedback.lightImpact();

  /// 맵 롱프레스 햅틱 (OS 네이티브 — 의도적 제스처라 medium 임팩트)
  void longPress() => HapticFeedback.mediumImpact();

  // ═══════════════════════════════════════════════════════════════════════
  // 채팅
  // ═══════════════════════════════════════════════════════════════════════

  /// 채팅 메시지 수신 진동 (호출자가 on/off 판단)
  void messageReceived() => _vibrateSingle(
    VibrationPatterns.messageReceivedDuration,
    VibrationPatterns.messageReceivedAmplitude,
  );

  // ═══════════════════════════════════════════════════════════════════════
  // 대기방
  // ═══════════════════════════════════════════════════════════════════════

  /// 플레이어 입장/퇴장 진동
  void playerJoinLeave() => _vibrateSingle(
    VibrationPatterns.playerJoinLeaveDuration,
    VibrationPatterns.playerJoinLeaveAmplitude,
  );

  /// 게임 시작 진동
  void gameStart() => _vibratePattern(
    VibrationPatterns.gameStartPattern,
    VibrationPatterns.gameStartIntensities,
  );

  // ═══════════════════════════════════════════════════════════════════════
  // 인게임
  // ═══════════════════════════════════════════════════════════════════════

  /// 체포 진동
  void arrested() => _vibrateSingle(
    VibrationPatterns.arrestedDuration,
    VibrationPatterns.arrestedAmplitude,
  );

  /// 탈옥 진동
  void escaped() => _vibratePattern(
    VibrationPatterns.escapedPattern,
    VibrationPatterns.escapedIntensities,
  );

  /// 위치 공개 진동
  void locationRevealed() => _vibrateSingle(
    VibrationPatterns.locationRevealedDuration,
    VibrationPatterns.locationRevealedAmplitude,
  );

  /// 영역 이탈 경고 진동
  void zoneExit() => _vibratePattern(
    VibrationPatterns.zoneExitPattern,
    VibrationPatterns.zoneExitIntensities,
  );

  /// 게임 종료 진동
  void gameEnd() => _vibratePattern(
    VibrationPatterns.gameEndPattern,
    VibrationPatterns.gameEndIntensities,
  );
}
