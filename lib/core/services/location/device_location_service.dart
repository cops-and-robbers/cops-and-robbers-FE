import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// 디바이스 위치 서비스
///
/// 역할:
/// - 현재 위치 1회 조회
/// - 실시간 위치 스트림 제공 (백그라운드 위치 추적 포함)
class DeviceLocationService {
  DeviceLocationService._();

  /// 위치를 얻지 못했을 때 지도가 보여줄 기본 좌표 (어린이대공원역)
  ///
  /// 지도 카메라의 시작점으로만 쓴다. **서버로 보내는 위치에는 절대 쓰지 않는다**
  /// — 가짜 좌표를 전송하면 게임 판정이 틀어진다. 그래서 이 상수는 폴백이 필요한
  /// 지도 화면이 직접 참조하고, [getCurrentLatLng] 는 실패를 null 로 알린다.
  static const LatLng fallbackLocation = LatLng(37.5480, 127.0810);

  /// 현재 위치 1회 조회. 얻지 못하면 null.
  ///
  /// [timeLimit] 내 GPS 응답이 없으면 lastKnownPosition 으로 폴백한다.
  ///
  /// 권한 거부·위치 서비스 꺼짐도 여기서 흡수해 null 로 돌려준다. 예전에는
  /// `TimeoutException` 만 잡아 나머지가 호출부로 던져졌고, 호출부마다 제각각인
  /// `catch (e)` 가 그것을 조용히 폴백 좌표로 바꿔 놓았다 — 권한 문제가 "그냥 좀
  /// 이상한 위치"로만 보인 이유다(#525). 실패 형태를 여기서 null 하나로 모은다.
  static Future<Position?> getCurrentPosition({
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration timeLimit = const Duration(seconds: 10),
  }) async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: accuracy),
      ).timeout(timeLimit);
    } on TimeoutException {
      return _lastKnownOrNull();
    } catch (e) {
      // 권한 거부·서비스 꺼짐 등. 마지막으로 알던 위치라도 있으면 그것을 쓴다.
      debugPrint('[위치] 현재 위치 조회 실패: $e');
      return _lastKnownOrNull();
    }
  }

  /// 지도용 현재 위치. 얻지 못하면 null — 폴백 여부는 호출부가 정한다.
  static Future<LatLng?> getCurrentLatLng({
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration timeLimit = const Duration(seconds: 10),
  }) async {
    final pos = await getCurrentPosition(
      accuracy: accuracy,
      timeLimit: timeLimit,
    );
    return pos == null ? null : LatLng(pos.latitude, pos.longitude);
  }

  static Future<Position?> _lastKnownOrNull() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      debugPrint('[위치] 마지막 위치 조회도 실패: $e');
      return null;
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
        // 요청 주기일 뿐 보장 간격은 아니다. 판정기는 수신 지연을 별도로 허용한다.
        intervalDuration: const Duration(seconds: 2),
      );
    }

    // 기타 플랫폼 (테스트/데스크톱) fallback
    return LocationSettings(accuracy: accuracy, distanceFilter: distanceFilter);
  }
}
