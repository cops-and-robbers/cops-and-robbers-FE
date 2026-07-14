import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

import 'package:cops_and_robbers/features/game/data/models/game_area_model.dart';
import 'package:cops_and_robbers/features/game/presentation/providers/player_game_record_provider.dart';

void main() {
  late ProviderContainer container;

  setUp(() => container = ProviderContainer());
  tearDown(() => container.dispose());

  PlayerGameRecordNotifier notifier() =>
      container.read(playerGameRecordNotifierProvider.notifier);

  group('PlayerGameRecordNotifier', () {
    const a = LatLngModel(latitude: 37.5665, longitude: 126.9780);
    const b = LatLngModel(latitude: 37.5675, longitude: 126.9790); // 약 130m

    test('accumulates_distance_between_consecutive_points', () {
      notifier()
        ..addPoint(a)
        ..addPoint(b);

      final expected = Geolocator.distanceBetween(
        a.latitude,
        a.longitude,
        b.latitude,
        b.longitude,
      );
      final state = container.read(playerGameRecordNotifierProvider);
      expect(state.route.length, 2);
      expect(state.distanceMeters, closeTo(expected, 0.001));
    });

    test('skips_point_within_2m_to_filter_gps_noise', () {
      const near = LatLngModel(
        latitude: 37.56650,
        longitude: 126.97801,
      ); // a에서 1m 미만
      notifier()
        ..addPoint(a)
        ..addPoint(near);

      final state = container.read(playerGameRecordNotifierProvider);
      expect(state.route.length, 1); // near는 2m 미만 → 제외
      expect(state.distanceMeters, 0.0);
    });

    test('increments_personal_arrest_and_escape_counts', () {
      notifier()
        ..incrementArrest()
        ..incrementArrest()
        ..incrementEscape();

      final state = container.read(playerGameRecordNotifierProvider);
      expect(state.myArrestCount, 2);
      expect(state.myEscapeCount, 1);
    });

    test('reset_clears_all_accumulated_data', () {
      notifier()
        ..addPoint(a)
        ..addPoint(b)
        ..incrementArrest()
        ..reset();

      final state = container.read(playerGameRecordNotifierProvider);
      expect(state.route, isEmpty);
      expect(state.distanceMeters, 0.0);
      expect(state.myArrestCount, 0);
    });
  });
}
