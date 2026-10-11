import 'package:flutter_test/flutter_test.dart';
import 'package:cops_and_robbers/features/game/data/models/game_area_model.dart';
import 'package:cops_and_robbers/features/game/presentation/widgets/route_geometry.dart';

void main() {
  group('splitRouteSegments', () {
    const a = LatLngModel(latitude: 37.50, longitude: 127.00);
    const b = LatLngModel(latitude: 37.51, longitude: 127.01);
    const c = LatLngModel(latitude: 37.52, longitude: 127.02);
    const d = LatLngModel(latitude: 37.53, longitude: 127.03);

    test('returns_whole_route_as_one_segment_when_no_breaks', () {
      expect(splitRouteSegments(const [a, b, c], const []), [
        [a, b, c],
      ]);
    });

    test('splits_route_at_each_segment_start', () {
      // 앱이 꺼져 있던 구간(b→c)은 선으로 잇지 않는다.
      expect(splitRouteSegments(const [a, b, c, d], const [2]), [
        [a, b],
        [c, d],
      ]);
    });
  });
}
