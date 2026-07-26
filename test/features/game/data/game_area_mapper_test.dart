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

    // 백엔드 하위호환 대응(v2.13.0 + compat)으로 CIRCLE 응답에는 중첩 circle과
    // 구버전 앱용 평면 필드가 함께 내려온다. 신규 앱은 중첩만 읽고 평면은 무시해야
    // 하며, 이 동작이 깨지면 하위호환 롤아웃 전체가 무너진다.
    test('ignores_legacy_flat_fields_when_response_contains_both_shapes', () {
      final model = GameAreaModel.fromJson({
        'areaType': 'CIRCLE',
        'circle': {
          'playgroundCenter': {'latitude': 37.5665, 'longitude': 126.978},
          'playgroundRadiusInMeters': 1000,
          'jailCenter': {'latitude': 37.567, 'longitude': 126.9785},
          'jailRadiusInMeters': 100,
        },
        // 구버전 앱용 평면 필드 (deprecated). 중첩을 읽는지 확인하기 위해
        // 의도적으로 다른 값을 넣는다 — 실제 응답은 중첩과 동일한 값이다.
        'playgroundCenter': {'latitude': 1.0, 'longitude': 2.0},
        'playgroundRadiusInMeters': 9999,
        'jailCenter': {'latitude': 3.0, 'longitude': 4.0},
        'jailRadiusInMeters': 8888,
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
