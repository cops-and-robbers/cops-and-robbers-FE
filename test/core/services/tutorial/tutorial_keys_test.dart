import 'package:cops_and_robbers/core/services/tutorial/tutorial_keys.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TutorialKeys.waitingRoomByTeam', () {
    test('POLICE 입력 시 경찰 튜토리얼 키를 반환한다', () {
      expect(
        TutorialKeys.waitingRoomByTeam('POLICE'),
        TutorialKeys.waitingRoomPolice,
      );
    });

    test('ROBBER 입력 시 도둑 튜토리얼 키를 반환한다', () {
      expect(
        TutorialKeys.waitingRoomByTeam('ROBBER'),
        TutorialKeys.waitingRoomRobber,
      );
    });

    test('null 입력 시 null을 반환한다', () {
      expect(TutorialKeys.waitingRoomByTeam(null), isNull);
    });

    test('알 수 없는 팀 문자열은 null을 반환한다', () {
      expect(TutorialKeys.waitingRoomByTeam('SPECTATOR'), isNull);
      expect(TutorialKeys.waitingRoomByTeam(''), isNull);
      expect(TutorialKeys.waitingRoomByTeam('police'), isNull); // 소문자 불허
    });
  });

  group('TutorialKeys.waitingRoomPolice / waitingRoomRobber', () {
    test('경찰과 도둑 키는 서로 다른 문자열이다', () {
      expect(
        TutorialKeys.waitingRoomPolice,
        isNot(equals(TutorialKeys.waitingRoomRobber)),
      );
    });

    test('두 키 모두 all 목록에 포함된다', () {
      expect(TutorialKeys.all, contains(TutorialKeys.waitingRoomPolice));
      expect(TutorialKeys.all, contains(TutorialKeys.waitingRoomRobber));
    });
  });
}
