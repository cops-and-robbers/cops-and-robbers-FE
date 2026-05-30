import 'package:cops_and_robbers/core/constants/game_team.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GameTeam.isPolice', () {
    test('isPolice_returnsTrue_when_value_is_uppercase_police', () {
      expect(GameTeam.isPolice('POLICE'), isTrue);
    });

    test('isPolice_returnsTrue_when_value_is_lowercase_police', () {
      expect(GameTeam.isPolice('police'), isTrue);
    });

    test('isPolice_returnsFalse_when_value_is_robber', () {
      expect(GameTeam.isPolice('ROBBER'), isFalse);
    });

    test('isPolice_returnsFalse_when_value_is_null', () {
      expect(GameTeam.isPolice(null), isFalse);
    });
  });

  group('GameTeam.isRobber', () {
    test('isRobber_returnsTrue_when_value_is_robber_any_case', () {
      expect(GameTeam.isRobber('robber'), isTrue);
      expect(GameTeam.isRobber('ROBBER'), isTrue);
    });

    test('isRobber_returnsFalse_when_value_is_null', () {
      expect(GameTeam.isRobber(null), isFalse);
    });
  });

  group('GameTeam.toLowerKey', () {
    test('toLowerKey_returns_lowercase_for_uppercase_constant', () {
      expect(GameTeam.toLowerKey(GameTeam.police), 'police');
      expect(GameTeam.toLowerKey(GameTeam.robber), 'robber');
    });
  });
}
