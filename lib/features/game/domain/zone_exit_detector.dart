import 'package:flutter/foundation.dart';

/// 구역 이탈/복귀 상태 전환 감지기
///
/// 위치 업데이트마다 [update]를 호출하면
/// 안→밖 전환 시 [onExitZone], 밖→안 전환 시 [onEnterZone] 콜백을 실행합니다.
/// 동일 상태가 반복되면 콜백을 호출하지 않습니다.
class ZoneExitDetector {
  ZoneExitDetector({required this.onExitZone, required this.onEnterZone});

  /// 안 → 밖 전환 시 호출
  final VoidCallback onExitZone;

  /// 밖 → 안 전환 시 호출
  final VoidCallback onEnterZone;

  /// 현재 구역 이탈 여부
  bool _isOutside = false;
  bool get isOutside => _isOutside;

  /// 위치 업데이트 시 호출하여 상태 전환 감지
  void update({required bool isOutside}) {
    if (isOutside && !_isOutside) {
      onExitZone();
    } else if (!isOutside && _isOutside) {
      onEnterZone();
    }
    _isOutside = isOutside;
  }
}
