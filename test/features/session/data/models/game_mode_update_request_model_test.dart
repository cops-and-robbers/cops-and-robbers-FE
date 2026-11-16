import 'package:cops_and_robbers/core/constants/game_mode.dart';
import 'package:cops_and_robbers/features/game/domain/entities/area_shape.dart';
import 'package:cops_and_robbers/features/session/data/models/game_create_request_model.dart';
import 'package:cops_and_robbers/features/session/data/models/game_mode_update_request_model.dart';
import 'package:flutter_test/flutter_test.dart';

const _origin = GeoPoint(latitude: 37.5665, longitude: 126.978);

void main() {
  group('GameModeUpdateRequestModel', () {
    test(
      'mode_change_request_sends_tag_without_jail_keys_when_host_switches_to_hide_and_seek',
      () {
        // 경찰과 도둑 방에서 술래잡기로 바꿀 때 감옥은 버려진다 (보내면 서버가 거절)
        const area = GameAreaEntity(
          playground: AreaShape.circle(center: _origin, radiusInMeters: 300),
        );

        final json = GameModeUpdateRequestModel(
          gameMode: GameMode.hideAndSeek,
          area: area.toRequestModel(),
        ).toJson();

        expect(json['gameMode'], 'TAG');
        final circle = (json['area'] as Map)['circle'] as Map;
        expect(circle['playgroundRadiusInMeters'], 300);
        expect(circle.containsKey('jailCenter'), isFalse);
        expect(circle.containsKey('jailRadiusInMeters'), isFalse);
      },
    );

    test(
      'mode_change_request_keeps_jail_when_host_switches_to_cops_and_robbers',
      () {
        const area = GameAreaEntity(
          playground: AreaShape.circle(center: _origin, radiusInMeters: 300),
          jail: AreaShape.circle(center: _origin, radiusInMeters: 30),
        );

        final json = GameModeUpdateRequestModel(
          gameMode: GameMode.copsAndRobbers,
          area: area.toRequestModel(),
        ).toJson();

        expect(json['gameMode'], 'COPS_AND_ROBBERS');
        final circle = (json['area'] as Map)['circle'] as Map;
        expect(circle['jailRadiusInMeters'], 30);
        expect(circle.containsKey('jailCenter'), isTrue);
      },
    );
  });
}
