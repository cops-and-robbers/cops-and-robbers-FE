import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'entities/area_shape.dart';

/// 수감 한 번 동안 "감옥에 들어갔다가 확실히 나갔는지"를 판정한다.
///
/// 수감이 시작되거나 풀릴 때 호출자가 새로 만든다. 위치 구독·네트워크·Timer는
/// 갖지 않는다. 시각은 앱이 위치를 받은 시각을 받는다 — Android 위치의 측정
/// 시각은 기기 시계와 어긋날 수 있어 쓰지 않는다.
class JailEscapeDetector {
  JailEscapeDetector({
    this.boundaryMarginInMeters = 3,
    this.minInsideSamples = 2,
    this.minInsideDuration = const Duration(seconds: 1),
    this.minOutsideDuration = const Duration(seconds: 3),
    this.retryInterval = const Duration(seconds: 5),
  });

  /// GPS 정확도에 더하거나 최소로 두는 경계 여유(m)
  final double boundaryMarginInMeters;

  /// 경계 근처 안쪽 위치를 입장으로 인정하는 연속 횟수와 시간
  final int minInsideSamples;
  final Duration minInsideDuration;

  /// 확실히 밖에 머물러야 하는 시간
  final Duration minOutsideDuration;

  /// 요청 뒤 다시 요청하기까지의 간격 — 실패나 응답 유실 뒤에도 밖이면 다시 보낸다
  final Duration retryInterval;

  bool _hasEnteredJail = false;
  int _insideStreak = 0;
  DateTime? _insideSince;
  DateTime? _outsideSince;
  DateTime? _lastRequestAt;

  /// 위치 하나를 반영하고, 지금 탈옥을 요청해야 하면 true를 반환한다.
  bool update({
    required AreaShape jail,
    required GeoPoint point,
    required double accuracyInMeters,
    required DateTime receivedAt,
  }) {
    // iOS는 쓸 수 없는 위치를 음수 정확도로 준다. 기록을 건드리지 않고 건너뛴다.
    if (!accuracyInMeters.isFinite || accuracyInMeters <= 0) return false;

    final distance = jail.distanceToBoundaryInMeters(point);
    if (jail.contains(point)) {
      _outsideSince = null;
      _insideSince ??= receivedAt;
      _insideStreak++;
      final confidentlyInside =
          distance > accuracyInMeters + boundaryMarginInMeters;
      final stayedInside =
          _insideStreak >= minInsideSamples &&
          receivedAt.difference(_insideSince!) >= minInsideDuration;
      if (!_hasEnteredJail && (confidentlyInside || stayedInside)) {
        _hasEnteredJail = true;
        debugPrint(
          '[자동탈옥] 들어감 — ${confidentlyInside ? '확실' : '연속'}, '
          'a=${accuracyInMeters.toStringAsFixed(1)}m, '
          'd=${distance.toStringAsFixed(1)}m',
        );
      }
      return false;
    }

    _insideStreak = 0;
    _insideSince = null;
    // 경계 완충 구간은 밖으로 치지 않는다 — 탈옥은 되돌릴 수 없다.
    final confidentlyOutside =
        distance > math.max(accuracyInMeters, boundaryMarginInMeters);
    if (!_hasEnteredJail || !confidentlyOutside) {
      _outsideSince = null;
      return false;
    }

    if (_outsideSince == null) {
      _outsideSince = receivedAt;
      debugPrint(
        '[자동탈옥] 밖 시작 — a=${accuracyInMeters.toStringAsFixed(1)}m, '
        'd=${distance.toStringAsFixed(1)}m',
      );
    }
    if (receivedAt.difference(_outsideSince!) < minOutsideDuration) {
      return false;
    }
    final lastRequestAt = _lastRequestAt;
    if (lastRequestAt != null &&
        receivedAt.difference(lastRequestAt) < retryInterval) {
      return false;
    }
    _lastRequestAt = receivedAt;
    return true;
  }
}
