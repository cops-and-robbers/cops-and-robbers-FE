import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// 위치 권한 서비스
///
/// 역할:
/// - 위치 서비스(GPS) 활성화 여부 확인
/// - 위치 권한 상태 확인 및 요청
/// - 게임 진입 전 위치 접근 가능 여부 판단
/// - 권한 미충족 시 false 반환 (설정 화면 이동은 호출 측에서 안내 UI로 처리)
class LocationPermissionService {
  LocationPermissionService._();

  /// 게임 진입 전 위치 권한 확보 플로우
  ///
  /// 흐름:
  /// 1. 위치 서비스 OFF → false 반환
  /// 2. 권한 denied → 권한 요청
  /// 3. deniedForever → false 반환
  /// 4. 허용 시 true 반환
  static Future<bool> ensurePermission() async {
    try {
      // 1. 위치 서비스 확인
      final serviceEnabled = await isServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('[위치] ❌ 위치 서비스 꺼짐');
        return false;
      }

      // 2. 권한 상태 확인
      var permission = await checkPermission();

      // 3. 권한 거부 → 요청
      if (permission == LocationPermission.denied) {
        debugPrint('[위치] ⚠️ 위치 권한 미허용 → 권한 요청');
        permission = await requestPermission();
      }

      // 4. 영구 거부
      if (permission == LocationPermission.deniedForever) {
        debugPrint('[위치] ❌ 위치 권한 영구 거부');
        return false;
      }

      // 5. 최종 판단
      final granted =
          permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;

      debugPrint('[위치] ✅ 최종 위치 권한 상태: $permission');
      return granted;
    } catch (e) {
      debugPrint('[위치] ❌ 위치 권한 처리 중 오류 발생: $e');
      return false;
    }
  }

  /// 위치 접근 가능 여부 종합 판단 (상태 체크용)
  ///
  /// true 조건:
  /// - 위치 서비스 활성화
  /// - 권한 상태가 whileInUse 또는 always
  static Future<bool> canAccessLocation() async {
    final serviceEnabled = await isServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('[위치] ⚠️ 위치 서비스 비활성화 상태');
      return false;
    }

    final permission = await checkPermission();
    final granted =
        permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;

    if (!granted) {
      debugPrint('[위치] ⚠️ 위치 권한 미허용 상태: $permission');
    }

    return granted;
  }

  /// 위치 서비스(GPS)가 켜져 있는지 확인
  static Future<bool> isServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      debugPrint('[위치] ❌ 위치 서비스 상태 확인 실패: $e');
      return false;
    }
  }

  /// 현재 위치 권한 상태 확인
  static Future<LocationPermission> checkPermission() async {
    try {
      return await Geolocator.checkPermission();
    } catch (e) {
      debugPrint('[위치] ❌ 위치 권한 상태 확인 실패: $e');
      return LocationPermission.denied;
    }
  }

  /// 위치 권한 요청
  static Future<LocationPermission> requestPermission() async {
    try {
      return await Geolocator.requestPermission();
    } catch (e) {
      debugPrint('[위치] ❌ 위치 권한 요청 중 오류 발생: $e');
      return LocationPermission.denied;
    }
  }

  /// 앱 권한 설정 화면으로 이동
  static Future<bool> openAppSettings() async {
    try {
      return await Geolocator.openAppSettings();
    } catch (e) {
      debugPrint('[위치] ❌ 앱 권한 설정 화면 이동 실패: $e');
      return false;
    }
  }

  /// 기기 위치 서비스 설정 화면으로 이동
  static Future<bool> openLocationSettings() async {
    try {
      return await Geolocator.openLocationSettings();
    } catch (e) {
      debugPrint('[위치] ❌ 위치 서비스 설정 화면 이동 실패: $e');
      return false;
    }
  }
}
