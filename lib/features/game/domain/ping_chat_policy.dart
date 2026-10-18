import 'entities/area_shape.dart';
import 'entities/ping.dart';
import 'zone_grid.dart';

/// 핑과 함께 팀 채팅에 올릴 칸 이름을 정한다 (#636)
///
/// 격자를 켠 사람만 보낸다 — 지도에 라벨이 보이는 사람이라야 자기 이름으로 나가는 "C3"을 안다.
/// 핑은 5초에 8번까지 허용되므로, 같은 칸·같은 종류를 [repeatWindow] 안에 다시 찍으면
/// 채팅은 건너뛴다(핑 자체는 그대로 나간다). 의심 → 발견처럼 종류가 바뀌면 새 정보라 보낸다.
class PingChatPolicy {
  PingChatPolicy({this.repeatWindow = const Duration(seconds: 10)});

  final Duration repeatWindow;
  final Map<String, DateTime> _lastAnnounced = {};

  /// 보낼 칸 이름, 보내지 않으면 null. [grid]는 내 격자가 꺼져 있으면 null로 넘긴다.
  String? cellToAnnounce({
    required ZoneGrid? grid,
    required PingType type,
    required GeoPoint point,
    required DateTime now,
  }) {
    final cell = grid?.cellAt(point);
    if (cell == null) return null;

    final key = '${type.name}:$cell';
    final last = _lastAnnounced[key];
    if (last != null && now.difference(last) < repeatWindow) return null;

    _lastAnnounced[key] = now;
    return cell;
  }
}
