import 'package:cops_and_robbers/features/session/presentation/widgets/game_setting_values_editor.dart';
import 'package:flutter_test/flutter_test.dart';

GameSettingValues _defaults({bool touched = false}) => GameSettingValues(
  participants: 10,
  roundDuration: 30,
  locationShare: 5,
  policeWait: 5,
  touched: touched,
);

void main() {
  group('inputDigit', () {
    test('first_digit_after_activation_replaces_the_value', () {
      final v = _defaults();
      v.activate(GameSettingField.participants); // 10
      v.inputDigit(7);
      expect(v[GameSettingField.participants], 7);
    });

    test('following_digits_append', () {
      final v = _defaults();
      v.activate(GameSettingField.roundDuration);
      v.inputDigit(1);
      v.inputDigit(2);
      v.inputDigit(0);
      expect(v[GameSettingField.roundDuration], 120);
    });

    test('ignores_append_beyond_max', () {
      final v = _defaults();
      v.activate(GameSettingField.participants);
      v.inputDigit(1);
      v.inputDigit(5); // 15
      v.inputDigit(5); // 155 > 150 → 무시
      expect(v[GameSettingField.participants], 15);
    });

    test('flags_rejection_and_clears_on_accept', () {
      final v = _defaults();
      v.activate(GameSettingField.participants);
      v.inputDigit(1);
      v.inputDigit(6); // 16
      expect(v.lastInputExceededMax, isFalse);
      v.inputDigit(0); // 160 > 150 → 거절
      expect(v.lastInputExceededMax, isTrue);
      v.backspace(); // 1 → 수용 동작이 표식을 지운다
      expect(v.lastInputExceededMax, isFalse);
    });

    test('quick_add_at_max_flags_rejection', () {
      final v = _defaults();
      v.activate(GameSettingField.participants);
      v.inputDigit(1);
      v.inputDigit(4);
      v.inputDigit(5); // 145
      v.quickAdd(20); // 150 에서 멈춤
      expect(v[GameSettingField.participants], 150);
      expect(v.lastInputExceededMax, isFalse);
      v.quickAdd(5); // 이미 상한
      expect(v.lastInputExceededMax, isTrue);
    });

    test('marks_field_touched', () {
      final v = _defaults();
      v.activate(GameSettingField.participants);
      expect(v.isTouched(GameSettingField.participants), isFalse);
      v.inputDigit(3);
      expect(v.isTouched(GameSettingField.participants), isTrue);
    });
  });

  group('backspace', () {
    test('removes_one_digit_at_a_time', () {
      final v = _defaults();
      v.activate(GameSettingField.roundDuration); // 30
      v.backspace();
      expect(v[GameSettingField.roundDuration], 3);
      v.backspace();
      expect(v[GameSettingField.roundDuration], 0);
    });

    test('typing_after_backspace_appends_from_remainder', () {
      final v = _defaults();
      v.activate(GameSettingField.roundDuration); // 30
      v.backspace(); // 3
      v.inputDigit(5);
      expect(v[GameSettingField.roundDuration], 35);
    });
  });

  group('quickAdd', () {
    test('adds_to_current_value', () {
      final v = _defaults();
      v.activate(GameSettingField.participants); // 10
      v.quickAdd(5);
      expect(v[GameSettingField.participants], 15);
    });

    test('stops_at_max', () {
      final v = _defaults();
      v.activate(GameSettingField.participants);
      v.inputDigit(1);
      v.inputDigit(4);
      v.inputDigit(0); // 140
      v.quickAdd(20); // 160 → 150 에서 멈춤
      expect(v[GameSettingField.participants], 150);
    });
  });

  group('validation', () {
    test('below_min_is_invalid', () {
      final v = _defaults();
      v.activate(GameSettingField.participants);
      v.inputDigit(1); // 1 < 2
      expect(v.isValid(GameSettingField.participants), isFalse);
      expect(v.allValid, isFalse);
    });

    test('location_share_zero_is_valid', () {
      final v = _defaults();
      v.activate(GameSettingField.locationShare);
      v.inputDigit(0);
      expect(v.isValid(GameSettingField.locationShare), isTrue);
    });

    test('location_share_and_police_wait_must_be_shorter_than_round', () {
      final v = _defaults();
      // 게임 시간을 10분으로 줄이면 위치 공유 간격의 실질 상한은 9분
      v.activate(GameSettingField.roundDuration);
      v.inputDigit(1);
      v.inputDigit(0);
      expect(v.effectiveMax(GameSettingField.locationShare), 9);
      expect(v.effectiveMax(GameSettingField.policeWait), 9);

      v.activate(GameSettingField.locationShare);
      v.inputDigit(1);
      v.inputDigit(0); // 10 >= 게임 시간 10
      expect(v.isValid(GameSettingField.locationShare), isFalse);
      expect(v.violatesRoundDuration(GameSettingField.locationShare), isTrue);
    });

    test('shrinking_round_invalidates_already_answered_fields', () {
      final v = _defaults();
      v.activate(GameSettingField.policeWait);
      v.inputDigit(9); // 경찰 9분 (게임 30분 → 유효)
      expect(v.allValid, isTrue);

      v.activate(GameSettingField.roundDuration);
      v.inputDigit(1);
      v.inputDigit(0); // 게임 10분 → 경찰 9는 유효, 위치 공유 5도 유효
      expect(v.allValid, isTrue);

      v.activate(GameSettingField.policeWait);
      v.inputDigit(1);
      v.inputDigit(0); // 경찰 10 == 게임 10 → 위반
      expect(v.allValid, isFalse);
    });
  });

  test('spec_matches_server_constraints', () {
    // GameSettingsRequest 의 @Min/@Max 와 같아야 한다
    expect(GameSettingField.participants.min, 2);
    expect(GameSettingField.participants.max, 150);
    expect(GameSettingField.roundDuration.min, 10);
    expect(GameSettingField.roundDuration.max, 180);
    expect(GameSettingField.locationShare.min, 0);
    expect(GameSettingField.policeWait.min, 1);
  });
}
