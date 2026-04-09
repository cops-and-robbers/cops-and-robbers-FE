import 'package:flutter_test/flutter_test.dart';

/// KICKED 이벤트의 self-kick 판별 로직 단위 테스트
///
/// waiting_room_page.dart의 _handleKickedEvent 핵심 조건:
///   if (kickedPid == null || myPid == null) return;  // early return
///   if (kickedPid == myPid) { ... }                  // self-kick
///
/// 위젯 의존 없이 순수 로직만 검증한다.
bool isSelfKick({required int? kickedPid, required int? myPid}) {
  // null 방어: 어느 한쪽이라도 null이면 self-kick으로 판정하지 않음
  if (kickedPid == null || myPid == null) return false;
  return kickedPid == myPid;
}

void main() {
  group('KICKED 이벤트 self-kick null guard', () {
    test('kickedPid == null → early return (self-kick 아님)', () {
      expect(isSelfKick(kickedPid: null, myPid: 1), isFalse);
    });

    test('myPid == null → early return (self-kick 아님)', () {
      expect(isSelfKick(kickedPid: 1, myPid: null), isFalse);
    });

    test('둘 다 null → early return (self-kick 아님, null == null 오인식 방어)', () {
      expect(isSelfKick(kickedPid: null, myPid: null), isFalse);
    });

    test('kickedPid == myPid (non-null) → self-kick 감지', () {
      expect(isSelfKick(kickedPid: 5, myPid: 5), isTrue);
    });

    test('kickedPid != myPid (둘 다 non-null) → self-kick 아님', () {
      expect(isSelfKick(kickedPid: 5, myPid: 3), isFalse);
    });
  });
}
