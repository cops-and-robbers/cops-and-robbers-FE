import 'dart:math' as math;

/// 구역 밖에 이만큼 누적되면 경고 1번 (#668). QA에서 조정한다.
const int kZoneWarnSeconds = 60;

/// 경고가 이만큼 쌓이면 강제 체포.
const int kZoneWarnMax = 3;

/// 라운드 동안 구역 밖에 있던 시간을 누적한다.
///
/// 안으로 들어오면 멈출 뿐 0이 되지 않는다 — 들락날락으로 경고를 피하지 못하게.
/// 위치 콜백 사이의 시각 차로 더하므로 백그라운드에서도 주기 타이머 없이 센다.
class ZoneWarningAccumulator {
  ZoneWarningAccumulator({double outsideSeconds = 0})
    : _outsideSeconds = outsideSeconds;

  double _outsideSeconds;
  DateTime? _outsideSince;

  double get outsideSeconds => _outsideSeconds;

  int get warnings =>
      math.min(kZoneWarnMax, _outsideSeconds ~/ kZoneWarnSeconds);

  Duration get untilNextWarning => Duration(
    milliseconds:
        ((kZoneWarnSeconds - _outsideSeconds % kZoneWarnSeconds) * 1000)
            .round(),
  );

  bool get shouldForceArrest => warnings >= kZoneWarnMax;

  void update({required bool countsAsOutside, required DateTime at}) {
    final since = _outsideSince;
    if (since != null) {
      _outsideSeconds += at.difference(since).inMilliseconds / 1000;
    }
    _outsideSince = countsAsOutside ? at : null;
  }

  /// 수감·게임 종료·앱 재시작 직후처럼 그 사이 시간을 세면 안 될 때.
  void pause() => _outsideSince = null;

  void reset() {
    _outsideSeconds = 0;
    _outsideSince = null;
  }
}
