import 'dart:ui';

/// 손가락 궤적(화면 좌표)을 Douglas–Peucker로 단순화한다.
///
/// 양 끝점은 항상 남고 순서는 보존된다. [tolerance]보다 덜 벗어난 점은 버린다.
/// 단순화 후에도 [maxPoints]를 넘으면 균등 간격으로 솎는다.
List<Offset> simplifyPath(
  List<Offset> points, {
  required double tolerance,
  required int maxPoints,
}) {
  if (points.length < 3) return List.of(points);

  final keep = List<bool>.filled(points.length, false)
    ..first = true
    ..last = true;
  _markKeepers(points, 0, points.length - 1, tolerance, keep);

  var result = [
    for (var i = 0; i < points.length; i++)
      if (keep[i]) points[i],
  ];
  if (result.length > maxPoints) {
    // ponytail: 허용오차를 키워 재시도하지 않고 균등 간격으로 솎는다 —
    // 상한은 자기교차 검사 O(n²) 비용의 안전망이지 형태 품질 기준이 아니다.
    final step = (result.length - 1) / (maxPoints - 1);
    result = [for (var i = 0; i < maxPoints; i++) result[(i * step).round()]];
  }
  return result;
}

void _markKeepers(
  List<Offset> points,
  int start,
  int end,
  double tolerance,
  List<bool> keep,
) {
  if (end - start < 2) return;
  var maxDistance = 0.0;
  var farthest = start;
  for (var i = start + 1; i < end; i++) {
    final d = _distanceToSegment(points[i], points[start], points[end]);
    if (d > maxDistance) {
      maxDistance = d;
      farthest = i;
    }
  }
  if (maxDistance <= tolerance) return;
  keep[farthest] = true;
  _markKeepers(points, start, farthest, tolerance, keep);
  _markKeepers(points, farthest, end, tolerance, keep);
}

double _distanceToSegment(Offset p, Offset a, Offset b) {
  final ab = b - a;
  if (ab.distanceSquared == 0) return (p - a).distance;
  final ap = p - a;
  final t = ((ap.dx * ab.dx + ap.dy * ab.dy) / ab.distanceSquared).clamp(
    0.0,
    1.0,
  );
  return (p - (a + ab * t)).distance;
}

/// 궤적이 처음 자기 자신과 만나는 지점에서 고리를 닫는다 (올가미).
///
/// 손으로 닫힌 모양을 그리면 끝이 시작점을 지나쳐 겹치기 마련이다. 가장 이른 교차점에서
/// 고리만 남기고 진입선·넘친 꼬리는 버린다. 가장 이른 교차를 고르므로 남는 고리에는
/// 자기교차가 없다. 교차가 없으면 입력을 그대로 돌려준다.
///
/// 넓이가 [minLoopArea] 미만인 고리는 손 떨림으로 보고 교차점 하나로 접은 뒤 계속 찾는다.
List<Offset> closeLoopAtFirstCrossing(
  List<Offset> path, {
  required double minLoopArea,
}) {
  var points = path;
  // ponytail: 작은 고리를 접을 때마다 처음부터 다시 훑는다(최악 O(n³)) —
  // 단순화 후 n ≤ 40이라 무의미. 원본 궤적에 직접 쓸 거면 스윕라인으로 바꾼다.
  while (true) {
    final crossing = _firstCrossing(points);
    if (crossing == null) return points;
    final (i, j, at) = crossing;
    final loop = [at, ...points.sublist(i + 1, j + 1)];
    if (_shoelaceArea(loop) >= minLoopArea) return loop;
    points = [...points.sublist(0, i + 1), at, ...points.sublist(j + 1)];
  }
}

/// 가장 이른 교차 — 변 j(점 j→j+1)가 앞선 비인접 변 i와 만나는 첫 경우.
/// 한 변이 여러 변과 만나면 그 변의 시작점에 가장 가까운 교차를 고른다.
(int, int, Offset)? _firstCrossing(List<Offset> points) {
  for (var j = 2; j < points.length - 1; j++) {
    final p = points[j];
    final r = points[j + 1] - p;
    (int, double)? nearest;
    for (var i = 0; i < j - 1; i++) {
      final q = points[i];
      final s = points[i + 1] - q;
      final denominator = _cross(r, s);
      if (denominator.abs() < 1e-9) continue; // 평행
      final t = _cross(q - p, s) / denominator; // 변 j 위의 위치
      final u = _cross(q - p, r) / denominator; // 변 i 위의 위치
      if (t < 0 || t > 1 || u < 0 || u > 1) continue;
      if (nearest == null || t < nearest.$2) nearest = (i, t);
    }
    if (nearest != null) return (nearest.$1, j, p + r * nearest.$2);
  }
  return null;
}

double _cross(Offset a, Offset b) => a.dx * b.dy - a.dy * b.dx;

double _shoelaceArea(List<Offset> ring) {
  var sum = 0.0;
  for (var i = 0; i < ring.length; i++) {
    sum += _cross(ring[i], ring[(i + 1) % ring.length]);
  }
  return sum.abs() / 2;
}
