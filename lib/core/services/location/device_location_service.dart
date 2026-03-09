import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// 디바이스 위치 서비스
///
/// 역할:
/// - 현재 위치 1회 조회
/// - 실시간 위치 스트림 제공
class DeviceLocationService {
  DeviceLocationService._();

  /// 현재 위치 1회 조회
  ///
  /// [timeLimit] 내에 GPS 응답이 없으면 마지막 알려진 위치로 폴백.
  /// 둘 다 없으면 null 반환.
  static Future<Position?> getCurrentPosition({
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration timeLimit = const Duration(seconds: 10),
  }) async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: accuracy),
      ).timeout(timeLimit);
    } on TimeoutException {
      return Geolocator.getLastKnownPosition();
    }
  }

  /// 실시간 위치 스트림
  static Stream<Position> getPositionStream({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 5,
  }) {
    debugPrint('[위치] 위치 스트림 시작 (distanceFilter: ${distanceFilter}m)');

    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
      ),
    );
  }
}
