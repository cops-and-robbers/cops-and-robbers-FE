import 'package:cops_and_robbers/features/session/data/models/game_create_request_model.dart';
import 'package:cops_and_robbers/features/session/data/models/game_settings_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const base = {
    'roundDurationMinutes': 30,
    'locationRevealIntervalMinutes': 5,
    'policeWaitMinutes': 3,
    'maxParticipants': 10,
  };

  // 방장이 무전을 켠 방의 설정 응답
  test('settings_response_reads_radio_on_when_host_turned_it_on', () {
    expect(
      GameSettingsResponse.fromJson({
        ...base,
        'radioEnabled': true,
      }).radioEnabled,
      isTrue,
    );
  });

  // 무전 설정이 생기기 전 서버·예전 방은 키가 없다 — 꺼짐으로 읽는다
  test('settings_response_reads_radio_off_when_old_server_omits_field', () {
    expect(GameSettingsResponse.fromJson(base).radioEnabled, isFalse);
  });

  // 방장이 무전을 켜고 방을 만든다 — 요청 본문에 켜짐이 실린다
  test('settings_request_carries_radio_on_when_host_turned_it_on', () {
    final json = const GameSettingsRequestModel(
      roundDurationMinutes: 30,
      locationRevealIntervalMinutes: 5,
      policeWaitMinutes: 3,
      maxParticipants: 10,
      radioEnabled: true,
    ).toJson();
    expect(json['radioEnabled'], isTrue);
  });

  // 무전을 끈 채 설정을 저장한다 — 통째로 덮어쓰는 PUT이라 꺼짐도 키를 싣는다
  test('settings_request_carries_radio_key_when_radio_is_off', () {
    final json = const GameSettingsRequestModel(
      roundDurationMinutes: 30,
      locationRevealIntervalMinutes: 5,
      policeWaitMinutes: 3,
      maxParticipants: 10,
    ).toJson();
    expect(json['radioEnabled'], isFalse);
  });

  // 무전을 켠 방에서 방장이 구역 축소만 켠다 — 무전이 꺼지면 안 된다
  test('shrink_change_request_keeps_radio_on_when_room_has_radio_on', () {
    final settings = GameSettingsResponse.fromJson({
      ...base,
      'radioEnabled': true,
    });
    expect(
      settings.toRequest(shrinkFinalRadiusInMeters: 200).radioEnabled,
      isTrue,
    );
  });

  // 무전을 켠 방에서 방장이 라운드 시간을 40분으로 고친다
  test('edit_request_keeps_radio_on_when_host_edits_round_time', () {
    final settings = GameSettingsResponse.fromJson({
      ...base,
      'radioEnabled': true,
    });
    expect(
      settings
          .toEditRequest(
            maxParticipants: 10,
            roundDurationMinutes: 40,
            locationRevealIntervalMinutes: 5,
            policeWaitMinutes: 3,
          )
          .radioEnabled,
      isTrue,
    );
  });

  // 방장이 대기방에서 무전을 끈다 — 켜 둔 구역 축소는 그대로
  test('radio_change_request_keeps_shrink_when_host_turns_radio_off', () {
    final settings = GameSettingsResponse.fromJson({
      ...base,
      'radioEnabled': true,
      'shrinkFinalRadiusInMeters': 200,
    });
    final request = settings.toRequest(
      shrinkFinalRadiusInMeters: settings.shrinkFinalRadiusInMeters,
      radioEnabled: false,
    );
    expect(
      (request.radioEnabled, request.shrinkFinalRadiusInMeters),
      (false, 200),
    );
  });
}
