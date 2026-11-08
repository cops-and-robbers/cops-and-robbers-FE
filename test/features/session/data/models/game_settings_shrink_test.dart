import 'package:cops_and_robbers/features/session/data/models/game_create_request_model.dart';
import 'package:cops_and_robbers/features/session/data/models/game_settings_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'turning_shrink_off_sends_explicit_null_because_put_settings_overwrites',
    () {
      // PUT /settings는 값을 통째로 덮어쓴다 — 키가 빠지면 서버가 null로 저장한다
      final json = const GameSettingsRequestModel(
        roundDurationMinutes: 30,
        locationRevealIntervalMinutes: 5,
        policeWaitMinutes: 5,
        maxParticipants: 10,
        shrinkFinalRadiusInMeters: null,
      ).toJson();
      expect(json.containsKey('shrinkFinalRadiusInMeters'), isTrue);
      expect(json['shrinkFinalRadiusInMeters'], isNull);
    },
  );

  test('shrink_on_room_sends_final_radius', () {
    final json = const GameSettingsRequestModel(
      roundDurationMinutes: 30,
      locationRevealIntervalMinutes: 5,
      policeWaitMinutes: 5,
      maxParticipants: 10,
      shrinkFinalRadiusInMeters: 200,
    ).toJson();
    expect(json['shrinkFinalRadiusInMeters'], 200);
  });

  test('reads_final_radius_of_shrink_on_room_from_game_info', () {
    final base = {
      'roundDurationMinutes': 30,
      'locationRevealIntervalMinutes': 5,
      'policeWaitMinutes': 5,
      'maxParticipants': 10,
    };
    expect(
      GameSettingsResponse.fromJson({
        ...base,
        'shrinkFinalRadiusInMeters': 200,
      }).shrinkFinalRadiusInMeters,
      200,
    );
    // 축소 꺼진 방·구버전 서버
    expect(
      GameSettingsResponse.fromJson(base).shrinkFinalRadiusInMeters,
      isNull,
    );
  });

  test('host_editing_only_game_time_keeps_shrink_on', () {
    // 대기방 설정 수정 화면은 조회한 값을 그대로 싣고 바꾼 항목만 덮는다
    final settings = GameSettingsResponse.fromJson({
      'roundDurationMinutes': 30,
      'locationRevealIntervalMinutes': 5,
      'policeWaitMinutes': 5,
      'maxParticipants': 10,
      'shrinkFinalRadiusInMeters': 200,
    });
    final request = settings.toEditRequest(
      maxParticipants: 10,
      roundDurationMinutes: 45,
      locationRevealIntervalMinutes: 5,
      policeWaitMinutes: 5,
    );
    expect(request.roundDurationMinutes, 45);
    expect(request.shrinkFinalRadiusInMeters, 200);
  });
}
