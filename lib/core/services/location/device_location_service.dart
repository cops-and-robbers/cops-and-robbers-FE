import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// 디바이스 위치 서비스
///
/// 역할:
/// - 현재 위치 1회 조회
/// - 실시간 위치 스트림 제공 (백그라운드 위치 추적 포함)
class DeviceLocationService {
  DeviceLocationService._();

  /// 현재 위치 1회 조회
  ///
  /// [timeLimit] 내 GPS 응답이 없으면 lastKnownPosition으로 폴백.
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
  ///
  /// 플랫폼별 분기:
  /// - iOS: AppleSettings (백그라운드 위치 추적 활성화)
  /// - Android: AndroidSettings (Foreground Service가 별도로 프로세스 keep-alive)
  static Stream<Position> getPositionStream({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 5,
  }) {
    debugPrint('[위치] 위치 스트림 시작 (distanceFilter: ${distanceFilter}m)');

    final settings = _buildLocationSettings(accuracy, distanceFilter);
    return Geolocator.getPositionStream(locationSettings: settings);
  }

  /// 플랫폼별 LocationSettings 빌드
  ///
  /// iOS:
  /// - allowBackgroundLocationUpdates: 백그라운드 위치 콜백 수신 활성
  /// - pauseLocationUpdatesAutomatically: false → OS 자동 일시정지 차단
  /// - activityType: otherNavigation → 네비 앱처럼 우대 처리
  /// - showBackgroundLocationIndicator: 상단 파란 인디케이터 표시(투명성)
  static LocationSettings _buildLocationSettings(
    LocationAccuracy accuracy,
    int distanceFilter,
  ) {
    if (Platform.isIOS) {
      return AppleSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
        allowBackgroundLocationUpdates: true,
        pauseLocationUpdatesAutomatically: false,
        activityType: ActivityType.otherNavigation,
        showBackgroundLocationIndicator: true,
      );
    }

    if (Platform.isAndroid) {
      return AndroidSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
      );
    }

    // 기타 플랫폼 (테스트/데스크톱) fallback
    return LocationSettings(accuracy: accuracy, distanceFilter: distanceFilter);
  }
}
