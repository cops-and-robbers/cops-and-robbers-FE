import 'dart:async';

import 'package:clock/clock.dart';

import '../../domain/shrink_schedule.dart';

/// 다음 축소 시각에 타이머 하나만 걸고, 차수가 바뀔 때만 알린다 (DEC-0148).
///
/// 주기 타이머를 쓰지 않는다. 진입·앱 복귀(resumed) 때는 [recompute]로 지금 차수를
/// 연출 없이 다시 그리고, 지나간 축소의 연출·알림은 되살리지 않는다(DEC-0149).
class ShrinkController {
  ShrinkController({required this.stateAt, required this.onChange});

  final ShrinkState Function(DateTime now) stateAt;
  final void Function(ShrinkState state, {required bool animate}) onChange;

  /// 이보다 늦게 깬 타이머는 지나간 축소로 본다
  static const _lateLimit = Duration(seconds: 5);

  Timer? _timer;
  ShrinkState? _current;
  bool _disposed = false;

  ShrinkState? get current => _current;

  void start() => recompute(animate: false, force: true);

  void recompute({required bool animate, bool force = false}) {
    if (_disposed) return;
    final next = stateAt(clock.now());
    final changed = force || next.stage != _current?.stage;
    _current = next;
    if (changed) onChange(next, animate: animate);
    _schedule(next);
  }

  void _schedule(ShrinkState state) {
    _timer?.cancel();
    final at = state.nextAt;
    if (at == null) return;
    // 타이머가 조금 일찍 깨어 차수가 그대로면 recompute가 같은 시각으로 다시 건다.
    // iOS가 앱을 멈췄다 깨우면 지난 타이머가 resumed보다 먼저 돈다 — 한참 늦었으면
    // 지나간 축소이므로 연출·알림 없이 다시 그리기만 한다 (DEC-0149).
    _timer = Timer(
      at.difference(clock.now()),
      () => recompute(animate: clock.now().difference(at) <= _lateLimit),
    );
  }

  void dispose() {
    _disposed = true;
    _timer?.cancel();
  }
}
