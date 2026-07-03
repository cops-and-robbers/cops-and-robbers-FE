import 'package:cops_and_robbers/features/game/domain/arrest_lock_visibility.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('shouldShowArrestLock', () {
    test('true_when_robber_arrested_and_not_escaped_in_normal_mode', () {
      expect(
        shouldShowArrestLock(
          isRobber: true,
          isEventGame: false,
          isArrested: true,
          isEscaped: false,
        ),
        isTrue,
      );
    });

    test('false_in_event_mode_even_if_arrested', () {
      expect(
        shouldShowArrestLock(
          isRobber: true,
          isEventGame: true,
          isArrested: true,
          isEscaped: false,
        ),
        isFalse, // 이벤트 모드 도둑은 잡혀도 ALIVE
      );
    });

    test('false_when_escaped', () {
      expect(
        shouldShowArrestLock(
          isRobber: true,
          isEventGame: false,
          isArrested: true,
          isEscaped: true,
        ),
        isFalse,
      );
    });

    test('false_when_not_robber', () {
      expect(
        shouldShowArrestLock(
          isRobber: false,
          isEventGame: false,
          isArrested: true,
          isEscaped: false,
        ),
        isFalse,
      );
    });
  });
}
