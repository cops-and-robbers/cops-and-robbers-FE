import 'package:flutter_test/flutter_test.dart';

import 'package:cops_and_robbers/features/game/presentation/helpers/zone_exit_reconnect_policy.dart';

void main() {
  group('shouldMarkZoneExitAsPendingOnReconnect', () {
    test('팝업 숨김 + 구역 안 → false (재연결 후 복구 불필요)', () {
      final result = shouldMarkZoneExitAsPendingOnReconnect(
        isPopupShown: false,
        isDetectorOutside: false,
      );

      expect(result, isFalse);
    });

    test('팝업 숨김 + 구역 밖 → true (팝업이 아직 안 떴어도 이탈 중이면 복구)', () {
      final result = shouldMarkZoneExitAsPendingOnReconnect(
        isPopupShown: false,
        isDetectorOutside: true,
      );

      expect(result, isTrue);
    });

    test('팝업 표시 중 + 구역 안 → true (팝업이 떠 있으면 일단 복구 예약)', () {
      // detector가 안으로 갱신된 직후 팝업이 아직 정리 중인 경계 케이스.
      final result = shouldMarkZoneExitAsPendingOnReconnect(
        isPopupShown: true,
        isDetectorOutside: false,
      );

      expect(result, isTrue);
    });

    test('팝업 표시 중 + 구역 밖 → true (이번 버그의 핵심 시나리오)', () {
      final result = shouldMarkZoneExitAsPendingOnReconnect(
        isPopupShown: true,
        isDetectorOutside: true,
      );

      expect(result, isTrue);
    });
  });
}
