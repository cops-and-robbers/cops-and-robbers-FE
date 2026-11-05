import 'package:flutter/foundation.dart';

/// 트윈 대상이 되는 이름 붙은 숫자 묶음.
///
/// 장면 연출이 값을 수십 개씩 옮기므로, 값마다 게터·세터를 넘기는 대신
/// `to(actor, {'x': 10, 'op': 1}, 300)` 한 줄로 쓰게 한다.
class TutorialProps {
  TutorialProps(Map<String, double> values) : _values = {...values};

  final Map<String, double> _values;

  double operator [](String key) => _values[key]!;
  void operator []=(String key, double value) => _values[key] = value;
}

class _Tween {
  _Tween(this.props, this.from, this.target, this.startMs, this.durationMs);

  final TutorialProps props;
  final Map<String, double> from;
  final Map<String, double> target;
  final int startMs;
  final int durationMs;
}

class _Step {
  _Step(this.dueMs, this.run);

  final int dueMs;
  final VoidCallback run;
}

/// 장면 연출의 시계. 값 옮기기와 예약 실행을 한 시간축에서 돌린다.
///
/// [isPlaying]이 다음 버튼을 잠근다. 연타로 설명을 놓치지 않게 하기 위해서다.
class TutorialTimeline {
  /// 앱이 백그라운드에서 돌아오면 큰 간격이 한 번에 들어온다.
  /// 그대로 쓰면 연출이 한 프레임에 끝나므로 한 번의 진행을 제한한다.
  static const int maxStepMs = 50;

  final List<_Tween> _tweens = [];
  final List<_Step> _steps = [];
  int _nowMs = 0;

  bool get isPlaying => _tweens.isNotEmpty || _steps.isNotEmpty;

  void to(TutorialProps props, Map<String, double> target, int ms) {
    // 겹치는 키만 넘겨받는다. 트윈 전체를 지우면 장면 정리처럼 함께 옮기던
    // 다른 값이 도중에 멈춘다.
    for (final tween in _tweens) {
      if (identical(tween.props, props)) {
        tween.target.removeWhere((key, _) => target.containsKey(key));
      }
    }
    _tweens.removeWhere((tween) => tween.target.isEmpty);

    if (ms <= 0) {
      target.forEach((key, value) => props[key] = value);
      return;
    }
    _tweens.add(
      _Tween(
        props,
        {for (final key in target.keys) key: props[key]},
        {...target},
        _nowMs,
        ms,
      ),
    );
  }

  void after(int ms, VoidCallback run) => _steps.add(_Step(_nowMs + ms, run));

  void tick(int elapsedMs) {
    _nowMs += elapsedMs.clamp(0, maxStepMs);

    final due = _steps.where((step) => step.dueMs <= _nowMs).toList()
      ..sort((a, b) => a.dueMs.compareTo(b.dueMs));
    _steps.removeWhere((step) => step.dueMs <= _nowMs);
    for (final step in due) {
      step.run();
    }

    _tweens.removeWhere((tween) {
      final ratio = ((_nowMs - tween.startMs) / tween.durationMs).clamp(
        0.0,
        1.0,
      );
      final eased = _ease(ratio);
      tween.target.forEach((key, value) {
        final from = tween.from[key]!;
        tween.props[key] = from + (value - from) * eased;
      });
      return ratio >= 1;
    });
  }

  static double _ease(double t) {
    if (t < .5) return 2 * t * t;
    final rest = -2 * t + 2;
    return 1 - rest * rest / 2;
  }
}
