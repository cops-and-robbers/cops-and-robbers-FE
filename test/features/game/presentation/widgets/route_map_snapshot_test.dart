import 'package:flutter_test/flutter_test.dart';

import 'package:cops_and_robbers/features/game/data/models/game_area_model.dart';
import 'package:cops_and_robbers/features/game/presentation/widgets/route_map_snapshot.dart';

void main() {
  group('routeBounds', () {
    test('returns_sw_ne_covering_all_points', () {
      const route = [
        LatLngModel(latitude: 37.50, longitude: 127.00),
        LatLngModel(latitude: 37.54, longitude: 127.06),
        LatLngModel(latitude: 37.49, longitude: 127.02),
      ];
      final b = routeBounds(route);
      expect(b.southwest.latitude, closeTo(37.49, 1e-9));
      expect(b.southwest.longitude, closeTo(127.00, 1e-9));
      expect(b.northeast.latitude, closeTo(37.54, 1e-9));
      expect(b.northeast.longitude, closeTo(127.06, 1e-9));
    });

    test('expands_single_point_to_nonzero_area', () {
      const route = [LatLngModel(latitude: 37.5, longitude: 127.0)];
      final b = routeBounds(route);
      // 단일 점이면 newLatLngBounds가 동작하도록 면적을 확보(sw < ne).
      expect(b.southwest.latitude, lessThan(b.northeast.latitude));
      expect(b.southwest.longitude, lessThan(b.northeast.longitude));
      // 중심은 원래 점.
      expect(
        (b.southwest.latitude + b.northeast.latitude) / 2,
        closeTo(37.5, 1e-9),
      );
      expect(
        (b.southwest.longitude + b.northeast.longitude) / 2,
        closeTo(127.0, 1e-9),
      );
    });
  });
}
