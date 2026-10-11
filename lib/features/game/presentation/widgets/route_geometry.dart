import '../../data/models/game_area_model.dart';

/// 경로를 [segmentStarts] 인덱스에서 끊어 구간 목록으로 나눈다.
///
/// 앱이 꺼져 있던 동안의 이동은 알 수 없으므로, 끊긴 지점끼리는 선으로 잇지 않는다.
List<List<LatLngModel>> splitRouteSegments(
  List<LatLngModel> route,
  List<int> segmentStarts,
) {
  final bounds = [0, ...segmentStarts, route.length];
  return [
    for (var i = 0; i < bounds.length - 1; i++)
      route.sublist(bounds[i], bounds[i + 1]),
  ];
}
