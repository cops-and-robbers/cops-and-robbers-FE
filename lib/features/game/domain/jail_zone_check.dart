/// 감옥 진입/이탈 판정 결과
enum JailZoneTransition {
  /// 직전 tick에는 밖, 이번 tick에는 안 (out → in)
  entered,

  /// 직전 tick에는 안, 이번 tick에는 밖 (in → out)
  exited,

  /// 상태 변화 없음
  none,
}

/// 감옥 영역 진입/이탈 판정 도메인 로직 (순수 함수 모음)
///
/// GPS 정확도(5~15m)로 인한 진동을 흡수하기 위해 진입/이탈에 비대칭 경계
/// (히스테리시스)를 적용한다. 진입은 반경 안, 이탈은 반경 + buffer 밖일 때만
/// 상태가 전환된다. 두 조건 사이의 buffer 영역은 직전 상태를 유지한다.
class JailZoneCheck {
  JailZoneCheck._();

  /// 자동 탈옥 기본 히스테리시스 buffer (m)
  static const double defaultExitBuffer = 10.0;

  /// 히스테리시스를 적용해 "감옥 밖" 여부를 판정한다.
  ///
  /// - distance ≤ radius → 안 (false)
  /// - distance > radius + buffer → 밖 (true)
  /// - 그 사이 band → 직전 상태(previousIsOutside) 유지
  static bool computeIsOutside({
    required double distanceMeters,
    required double radiusMeters,
    required double buffer,
    required bool previousIsOutside,
  }) {
    if (distanceMeters > radiusMeters + buffer) return true;
    if (distanceMeters <= radiusMeters) return false;
    return previousIsOutside;
  }

  /// 직전 상태와 현재 상태를 비교하여 전환 종류를 반환한다.
  static JailZoneTransition evaluateTransition({
    required bool wasOutside,
    required bool isOutside,
  }) {
    if (wasOutside && !isOutside) return JailZoneTransition.entered;
    if (!wasOutside && isOutside) return JailZoneTransition.exited;
    return JailZoneTransition.none;
  }
}
