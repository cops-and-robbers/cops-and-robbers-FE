import 'package:cops_and_robbers/core/errors/app_exception.dart';
import 'package:cops_and_robbers/features/game/data/models/game_area_model.dart';
import 'package:cops_and_robbers/features/game/domain/entities/area_shape.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GameAreaModel.toEntity', () {
    test('maps_circle_json_to_circle_shapes', () {
      final model = GameAreaModel.fromJson({
        'areaType': 'CIRCLE',
        'circle': {
          'playgroundCenter': {'latitude': 37.5665, 'longitude': 126.978},
          'playgroundRadiusInMeters': 1000,
          'jailCenter': {'latitude': 37.567, 'longitude': 126.9785},
          'jailRadiusInMeters': 100,
        },
      });

      final entity = model.toEntity();

      expect(
        entity.playground,
        const AreaShape.circle(
          center: GeoPoint(latitude: 37.5665, longitude: 126.978),
          radiusInMeters: 1000,
        ),
      );
      expect(
        entity.jail,
        const AreaShape.circle(
          center: GeoPoint(latitude: 37.567, longitude: 126.9785),
          radiusInMeters: 100,
        ),
      );
    });

    test('maps_polygon_json_to_polygon_shapes', () {
      final model = GameAreaModel.fromJson({
        'areaType': 'POLYGON',
        'polygon': {
          'playgroundPolygon': [
            {'latitude': 37.5685, 'longitude': 126.976},
            {'latitude': 37.5685, 'longitude': 126.980},
            {'latitude': 37.5645, 'longitude': 126.978},
          ],
          'jailPolygon': [
            {'latitude': 37.5670, 'longitude': 126.9775},
            {'latitude': 37.5670, 'longitude': 126.9785},
            {'latitude': 37.5660, 'longitude': 126.978},
          ],
        },
      });

      final entity = model.toEntity();

      expect(entity.playground, isA<PolygonShape>());
      expect((entity.playground as PolygonShape).points.length, 3);
      expect(entity.jail, isA<PolygonShape>());
    });

    test('throws_server_exception_when_area_type_mismatches_payload', () {
      final model = GameAreaModel.fromJson({'areaType': 'POLYGON'});
      expect(model.toEntity, throwsA(isA<ServerException>()));
    });

    test(
      'throws_server_exception_when_polygon_has_less_than_three_vertices',
      () {
        final model = GameAreaModel.fromJson({
          'areaType': 'POLYGON',
          'polygon': {
            'playgroundPolygon': [
              {'latitude': 37.5685, 'longitude': 126.976},
              {'latitude': 37.5685, 'longitude': 126.980},
            ],
            'jailPolygon': [
              {'latitude': 37.5670, 'longitude': 126.9775},
              {'latitude': 37.5670, 'longitude': 126.9785},
              {'latitude': 37.5660, 'longitude': 126.978},
            ],
          },
        });
        expect(model.toEntity, throwsA(isA<ServerException>()));
      },
    );
  });
}
