import 'package:flutter_test/flutter_test.dart';

import 'package:cops_and_robbers/features/chat/domain/input_focus_guard.dart';

void main() {
  late InputFocusGuard guard;
  late List<String> callLog;

  setUp(() {
    callLog = [];
    guard = InputFocusGuard(
      onAllowFocus: () => callLog.add('allow'),
      onRejectFocus: () => callLog.add('reject'),
    );
  });

  group('InputFocusGuard', () {
    test('사용자 탭 후 포커스 → onAllowFocus 호출', () {
      guard.markUserTapped();
      guard.handleFocusGained();

      expect(callLog, ['allow']);
    });

    test('사용자 탭 없이 포커스(프로그래매틱) → onRejectFocus 호출', () {
      guard.handleFocusGained();

      expect(callLog, ['reject']);
    });

    test('포커스 상실 시 _userTapped 플래그 리셋', () {
      guard.markUserTapped();
      guard.handleFocusLost();

      // 리셋 후 포커스 → 프로그래매틱으로 판단
      guard.handleFocusGained();

      expect(callLog, ['reject']);
    });

    test('사용자 탭 → 포커스 → 포커스 해제 → 다시 프로그래매틱 포커스 → reject', () {
      guard.markUserTapped();
      guard.handleFocusGained(); // allow
      guard.handleFocusLost(); // 리셋
      guard.handleFocusGained(); // reject (탭 없이)

      expect(callLog, ['allow', 'reject']);
    });

    test('연속 사용자 탭 → 포커스 → 포커스 해제 → 사용자 탭 → 포커스 → 모두 allow', () {
      guard.markUserTapped();
      guard.handleFocusGained(); // allow
      guard.handleFocusLost();

      guard.markUserTapped();
      guard.handleFocusGained(); // allow

      expect(callLog, ['allow', 'allow']);
    });

    test('초기 상태에서 userTapped는 false', () {
      expect(guard.isUserTapped, isFalse);
    });

    test('markUserTapped 후 userTapped는 true', () {
      guard.markUserTapped();
      expect(guard.isUserTapped, isTrue);
    });
  });
}
