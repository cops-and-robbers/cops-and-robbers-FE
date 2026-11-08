import 'zone_warning_accumulator.dart';

/// 강제 체포 요청 결과.
enum ForceArrestResult {
  /// 잡혔다.
  success,

  /// 다시 불러도 안 된다 — 이미 수감, 게임 종료, 이벤트 게임, 도둑 아님.
  terminal,

  /// 네트워크·서버 오류 — 잠시 뒤 다시.
  retry,
}

/// 구역 밖 경고 누적과 강제 체포 호출 시점을 정한다 (#668).
///
/// 게임 화면은 위치가 올 때마다 [onPosition]을 부르고, true가 돌아오면 강제 체포 API를
/// 한 번 부른 뒤 결과를 [onForceArrestResult]로 알려 준다.
class ZoneWarningFlow {
  ZoneWarningFlow({double restoredSeconds = 0})
    : _acc = ZoneWarningAccumulator(outsideSeconds: restoredSeconds);

  static const _retryGap = Duration(seconds: 5);
  static const _saveGap = Duration(seconds: 10);

  final ZoneWarningAccumulator _acc;
  bool _inFlight = false;
  DateTime? _lastAttempt;
  DateTime? _countingSince;
  DateTime? _lastSave;
  int _savedWarnings = -1;

  double get outsideSeconds => _acc.outsideSeconds;
  int get warnings => _acc.warnings;

  /// [now]에 다음 경고까지 남은 시간. 밖에서 세고 있지 않으면 지금 누적 기준 그대로.
  Duration untilNextWarningAt(DateTime now) {
    final base = _acc.untilNextWarning;
    final since = _countingSince;
    if (since == null) return base;
    final left = base - now.difference(since);
    return left.isNegative ? Duration.zero : left;
  }

  /// 위치 한 번. [eligible]은 축소 켠 게임의 도둑이고 수감·종료·이벤트 게임이 아닐 때만 true.
  /// 강제 체포를 지금 불러야 하면 true.
  bool onPosition({
    required bool eligible,
    required bool countsAsOutside,
    required DateTime at,
  }) {
    if (!eligible) {
      // 수감 등으로 세지 않은 시간이 다음 위치에서 한꺼번에 더해지지 않게
      _acc.pause();
      _countingSince = null;
      return false;
    }
    _acc.update(countsAsOutside: countsAsOutside, at: at);
    _countingSince = countsAsOutside ? at : null;
    if (!_acc.shouldForceArrest || _inFlight) return false;
    final last = _lastAttempt;
    if (last != null && at.difference(last) < _retryGap) return false;
    _inFlight = true;
    _lastAttempt = at;
    return true;
  }

  /// 위치 없이 1초마다 — 마지막 위치의 안/밖 그대로 시간을 이어 센다.
  /// iOS는 가만히 서 있으면 위치를 거의 주지 않아, 위치로만 세면 밖에 서 있는 도둑의 경고가
  /// "0/3 · 00:00"에서 멈추고 강제 체포도 오지 않았다(실기기).
  bool onTick({required bool eligible, required DateTime at}) => onPosition(
    eligible: eligible,
    countsAsOutside: _countingSince != null,
    at: at,
  );

  void onForceArrestResult(ForceArrestResult result) {
    _inFlight = false;
    if (result != ForceArrestResult.retry) {
      _acc.reset();
      _countingSince = null;
    }
  }

  /// 저장소에 쓸 때인지 — 경고 수가 바뀌었거나 10초가 지났을 때만(매초 쓰지 않게).
  bool shouldSave(DateTime now) {
    final last = _lastSave;
    return warnings != _savedWarnings ||
        last == null ||
        now.difference(last) >= _saveGap;
  }

  void markSaved(DateTime now) {
    _lastSave = now;
    _savedWarnings = warnings;
  }
}
