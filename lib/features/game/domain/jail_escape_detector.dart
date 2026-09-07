import 'entities/area_shape.dart';

/// 자동 탈옥 판정에 필요한 한 번의 위치 관측값.
class JailLocationSample {
  const JailLocationSample({
    required this.point,
    required this.accuracyInMeters,
    required this.timestamp,
  });

  final GeoPoint point;
  final double accuracyInMeters;
  final DateTime timestamp;
}

/// 이번 체포 이후 감옥 진입과 확실한 이탈을 순서대로 확인한다.
///
/// 위치 구독과 API 호출은 소유하지 않는다. [update]가 true를 반환할 때 호출자가
/// 탈옥을 요청하며, 같은 외부 체류 중에는 한 번만 true를 반환한다.
class JailEscapeDetector {
  JailEscapeDetector({
    this.maxAccuracyInMeters = 10,
    this.maxSampleAge = const Duration(seconds: 5),
    this.maxSampleGap = const Duration(seconds: 10),
    this.minOutsideDistanceInMeters = 3,
    this.minConsecutiveSamples = 2,
    this.minInsideDuration = const Duration(seconds: 1),
    this.minOutsideDuration = const Duration(seconds: 2),
  });

  final double maxAccuracyInMeters;
  final Duration maxSampleAge;
  final Duration maxSampleGap;
  final double minOutsideDistanceInMeters;
  final int minConsecutiveSamples;
  final Duration minInsideDuration;
  final Duration minOutsideDuration;

  DateTime? _lastTimestamp;
  DateTime? _insideStartedAt;
  DateTime? _outsideStartedAt;
  int _insideSamples = 0;
  int _outsideSamples = 0;
  bool _hasEnteredJail = false;
  bool _triggeredForCurrentExcursion = false;

  bool get hasEnteredJail => _hasEnteredJail;

  bool update({
    required AreaShape jail,
    required JailLocationSample sample,
    required DateTime now,
  }) {
    if (!_isValid(sample, now)) {
      _clearCandidates();
      return false;
    }

    final lastTimestamp = _lastTimestamp;
    if (lastTimestamp != null &&
        sample.timestamp.difference(lastTimestamp) > maxSampleGap) {
      _clearCandidates();
    }
    _lastTimestamp = sample.timestamp;

    if (jail.contains(sample.point)) {
      _outsideStartedAt = null;
      _outsideSamples = 0;
      _insideStartedAt ??= sample.timestamp;
      _insideSamples++;
      if (_insideSamples >= minConsecutiveSamples &&
          sample.timestamp.difference(_insideStartedAt!) >= minInsideDuration) {
        _hasEnteredJail = true;
        _triggeredForCurrentExcursion = false;
      }
      return false;
    }

    _insideStartedAt = null;
    _insideSamples = 0;
    if (!_hasEnteredJail || _triggeredForCurrentExcursion) return false;

    final requiredDistance =
        sample.accuracyInMeters > minOutsideDistanceInMeters
        ? sample.accuracyInMeters
        : minOutsideDistanceInMeters;
    if (jail.distanceToBoundaryInMeters(sample.point) <= requiredDistance) {
      _outsideStartedAt = null;
      _outsideSamples = 0;
      return false;
    }

    _outsideStartedAt ??= sample.timestamp;
    _outsideSamples++;
    if (_outsideSamples < minConsecutiveSamples ||
        sample.timestamp.difference(_outsideStartedAt!) < minOutsideDuration) {
      return false;
    }

    _triggeredForCurrentExcursion = true;
    return true;
  }

  void reset() {
    _lastTimestamp = null;
    _hasEnteredJail = false;
    _triggeredForCurrentExcursion = false;
    _clearCandidates();
  }

  bool _isValid(JailLocationSample sample, DateTime now) {
    final point = sample.point;
    final age = now.difference(sample.timestamp);
    if (!point.latitude.isFinite ||
        !point.longitude.isFinite ||
        point.latitude < -90 ||
        point.latitude > 90 ||
        point.longitude < -180 ||
        point.longitude > 180 ||
        !sample.accuracyInMeters.isFinite ||
        sample.accuracyInMeters <= 0 ||
        sample.accuracyInMeters > maxAccuracyInMeters ||
        age.isNegative ||
        age > maxSampleAge) {
      return false;
    }
    return _lastTimestamp == null || sample.timestamp.isAfter(_lastTimestamp!);
  }

  void _clearCandidates() {
    _insideStartedAt = null;
    _outsideStartedAt = null;
    _insideSamples = 0;
    _outsideSamples = 0;
  }
}
