import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// 위치 권한 서비스
///
/// 역할:
/// - 위치 서비스(GPS) 활성화 여부 확인
/// - 위치 권한 상태 확인 및 요청
/// - 게임 진입 전 위치 접근 가능 여부 판단
/// - 설정 화면 이동 유틸 제공
class LocationPermissionService {
  LocationPermissionService._();

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

  /// 위치 접근 가능 여부 종합 판단
  ///
  /// true 조건:
  /// - 위치 서비스 활성화
  /// - 권한 상태가 whileInUse 또는 always
  static Future<bool> canAccessLocation() async {
    final serviceEnabled = await isServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('[위치] ⚠️ 위치 서비스가 비활성화 상태');
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

  /// 게임 진입 전 기본 권한 확보 플로우
  ///
  /// 흐름:
  /// 1. 위치 서비스 활성화 여부 확인
  /// 2. 권한 상태 확인
  /// 3. denied → 권한 요청
  /// 4. deniedForever → 설정 이동 필요
  static Future<bool> ensurePermission() async {
    final serviceEnabled = await isServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('[위치] ⚠️ 위치 서비스 꺼짐 (설정 필요)');
      return false;
    }

    var permission = await checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('[위치] ⚠️ 위치 권한 영구 거부 상태 (설정 이동 필요)');
      return false;
    }

    final granted =
        permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;

    debugPrint('[위치] ✅ 최종 위치 권한 상태: $permission');
    return granted;
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
