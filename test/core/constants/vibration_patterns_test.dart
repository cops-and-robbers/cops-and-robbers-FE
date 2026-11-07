import 'package:cops_and_robbers/core/constants/vibration_patterns.dart';
import 'package:flutter_test/flutter_test.dart';

/// 진동이 얼마나 센지 — 울리는 구간(홀수 칸)의 길이 × 세기를 더한다.
int energy(List<int> pattern, List<int> intensities) {
  var sum = 0;
  for (var i = 1; i < pattern.length; i += 2) {
    sum += pattern[i] * intensities[i];
  }
  return sum;
}

void main() {
  // 빛줄기가 4초부터 1초까지 세지듯 진동도 출동이 가까울수록 세진다
  test('countdown_beat_grows_stronger_each_second_when_dispatch_nears', () {
    final strengths = [
      for (final s in [5, 4, 3, 2, 1])
        energy(
          VibrationPatterns.dispatchCountdownBeat(s).pattern,
          VibrationPatterns.dispatchCountdownBeat(s).intensities,
        ),
    ];
    for (var i = 1; i < strengths.length; i++) {
      expect(strengths[i], greaterThan(strengths[i - 1]));
    }
  });

  test('go_vibration_is_strongest_when_police_moves_out', () {
    final one = VibrationPatterns.dispatchCountdownBeat(1);
    expect(
      energy(
        VibrationPatterns.dispatchGoPattern,
        VibrationPatterns.dispatchGoIntensities,
      ),
      greaterThan(energy(one.pattern, one.intensities)),
    );
  });

  test('every_pattern_pairs_each_step_with_an_intensity_when_defined', () {
    for (final s in [5, 4, 3, 2, 1]) {
      final b = VibrationPatterns.dispatchCountdownBeat(s);
      expect(b.intensities.length, b.pattern.length);
    }
    expect(
      VibrationPatterns.dispatchGoIntensities.length,
      VibrationPatterns.dispatchGoPattern.length,
    );
  });
}
