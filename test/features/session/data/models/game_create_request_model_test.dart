import 'package:cops_and_robbers/core/constants/game_mode.dart';
import 'package:cops_and_robbers/core/errors/app_exception.dart';
import 'package:cops_and_robbers/features/game/data/models/game_area_model.dart';
import 'package:cops_and_robbers/features/game/domain/entities/area_shape.dart';
import 'package:cops_and_robbers/features/session/data/models/game_create_request_model.dart';
import 'package:flutter_test/flutter_test.dart';

const _origin = GeoPoint(latitude: 37.5665, longitude: 126.978);

void main() {
  group('GameAreaEntity.toRequestModel', () {
    test('request_omits_jail_when_hide_and_seek_room_is_created', () {
      const area = GameAreaEntity(
        playground: AreaShape.circle(center: _origin, radiusInMeters: 300),
      );

      final circle = area.toRequestModel().toJson()['circle'] as Map;

      // 키가 있으면 BE가 거절하므로 아예 없어야 한다
      expect(circle.containsKey('jailCenter'), isFalse);
      expect(circle.containsKey('jailRadiusInMeters'), isFalse);
    });

    test('request_omits_jail_polygon_when_hide_and_seek_room_is_created', () {
      const area = GameAreaEntity(
        playground: AreaShape.polygon(
          points: [
            _origin,
            GeoPoint(latitude: 37.5685, longitude: 126.978),
            GeoPoint(latitude: 37.5685, longitude: 126.980),
          ],
        ),
      );

      final polygon = area.toRequestModel().toJson()['polygon'] as Map;

      expect(polygon.containsKey('jailPolygon'), isFalse);
    });

    test(
      'request_rejects_mixed_shapes_when_jail_type_differs_from_playground',
      () {
        const area = GameAreaEntity(
          playground: AreaShape.circle(center: _origin, radiusInMeters: 300),
          jail: AreaShape.polygon(
            points: [
              _origin,
              GeoPoint(latitude: 37.5685, longitude: 126.978),
              GeoPoint(latitude: 37.5685, longitude: 126.980),
            ],
          ),
        );

        expect(area.toRequestModel, throwsA(isA<ValidationException>()));
      },
    );
  });

  const settings = GameSettingsRequestModel(
    roundDurationMinutes: 30,
    locationRevealIntervalMinutes: 5,
    policeWaitMinutes: 3,
    maxParticipants: 10,
  );
  const area = GameAreaRequestModel(areaType: GameAreaType.circle);

  test(
    'create_request_puts_game_mode_at_top_level_when_host_creates_hide_and_seek_room',
    () {
      final json = const GameCreateRequestModel(
        gameMode: GameMode.hideAndSeek,
        area: area,
        settings: settings,
      ).toJson();

      expect(json['gameMode'], 'TAG');
      expect((json['settings'] as Map).containsKey('gameMode'), isFalse);
    },
  );
}
