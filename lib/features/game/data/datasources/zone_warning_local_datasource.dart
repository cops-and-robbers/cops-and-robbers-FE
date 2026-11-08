import 'package:shared_preferences/shared_preferences.dart';

/// 구역 밖 누적 시간을 라운드 단위로 보관한다 (#668).
///
/// 앱을 다시 켜도 같은 라운드면 이어서 센다. 같은 방의 다음 라운드는 게임 id가 같으므로
/// 시작 시각으로 가른다 — 게임 기록 복원(#641)과 같은 2초 허용.
/// 형식: `<gameId>|<라운드 시작 epoch ms>|<누적 초>`
class ZoneWarningLocalDataSource {
  ZoneWarningLocalDataSource(this._prefs);

  final SharedPreferences _prefs;

  static const _key = 'zone_warning_round';
  static const _sameRoundTolerance = Duration(seconds: 2);

  Future<double> load({
    required int gameId,
    required DateTime? startedAt,
  }) async {
    if (startedAt == null) return 0;
    final parts = _prefs.getString(_key)?.split('|');
    if (parts == null || parts.length != 3) return 0;
    if (int.tryParse(parts[0]) != gameId) return 0;
    final savedMs = int.tryParse(parts[1]);
    if (savedMs == null) return 0;
    final sameRound =
        (startedAt.millisecondsSinceEpoch - savedMs).abs() <=
        _sameRoundTolerance.inMilliseconds;
    return sameRound ? double.tryParse(parts[2]) ?? 0 : 0;
  }

  Future<void> save({
    required int gameId,
    required DateTime startedAt,
    required double outsideSeconds,
  }) => _prefs.setString(
    _key,
    '$gameId|${startedAt.millisecondsSinceEpoch}|$outsideSeconds',
  );

  Future<void> clear() => _prefs.remove(_key);
}
