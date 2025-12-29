import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

/// 기기 정보 수집 서비스
///
/// iOS와 Android 기기의 정보를 가져오는 유틸리티 클래스입니다.
/// FCM 푸시 알림에서 기기를 식별하기 위해 사용됩니다.
///
/// 주요 기능:
/// - 기기 이름 가져오기 (예: "Elipair's iPhone", "Samsung SM-S911N")
/// - 기기 타입 가져오기 (IOS, ANDROID)
/// - 전체 기기 정보 가져오기 (디버깅용)
class DeviceInfoService {
  /// DeviceInfoPlugin 싱글톤 인스턴스
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// 기기 이름을 가져옵니다
  ///
  /// iOS의 경우 사용자가 설정한 기기 이름을 반환합니다.
  /// - 예: "Elipair's iPhone", "iPad Pro"
  ///
  /// Android의 경우 제조사와 모델명을 조합하여 반환합니다.
  /// - 예: "Samsung SM-S911N", "Google Pixel 7"
  ///
  /// Returns:
  /// - 성공: 기기 이름 문자열
  /// - 실패: "Unknown Device"
  static Future<String> getDeviceName() async {
    try {
      if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        // iOS 기기의 사용자 지정 이름 (설정 > 일반 > 정보 > 이름)
        return iosInfo.name;
      } else if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        // Android 제조사 + 모델명 조합
        // 예: "samsung" + "SM-S911N" = "Samsung SM-S911N"
        final manufacturer = androidInfo.manufacturer;
        final model = androidInfo.model;

        // 제조사 이름 첫 글자 대문자로 변환
        final capitalizedManufacturer = manufacturer.isNotEmpty
            ? manufacturer[0].toUpperCase() + manufacturer.substring(1)
            : manufacturer;

        return '$capitalizedManufacturer $model';
      }

      return 'Unknown Device';
    } catch (e) {
      debugPrint('⚠️ DeviceInfoService: 기기 이름 가져오기 실패 - $e');
      return 'Unknown Device';
    }
  }

  /// 기기 타입을 가져옵니다
  ///
  /// Returns:
  /// - "IOS": iOS 기기 (iPhone, iPad)
  /// - "ANDROID": Android 기기
  /// - "UNKNOWN": 기타 플랫폼 (웹, 데스크톱 등)
  static String getDeviceType() {
    if (Platform.isIOS) {
      return 'IOS';
    } else if (Platform.isAndroid) {
      return 'ANDROID';
    }
    return 'UNKNOWN';
  }

  /// 전체 기기 정보를 가져옵니다 (디버깅용)
  ///
  /// iOS와 Android의 모든 기기 정보를 Map 형태로 반환합니다.
  /// 개발 및 디버깅 목적으로 사용하며, 실제 서비스에서는 필요한 정보만 사용하세요.
  ///
  /// Returns:
  /// - iOS: name, model, systemName, systemVersion, localizedModel 등
  /// - Android: brand, manufacturer, model, device, product, androidId 등
  static Future<Map<String, dynamic>> getFullDeviceInfo() async {
    try {
      if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return {
          'name': iosInfo.name, // "Elipair's iPhone"
          'model': iosInfo.model, // "iPhone"
          'systemName': iosInfo.systemName, // "iOS"
          'systemVersion': iosInfo.systemVersion, // "17.4"
          'localizedModel': iosInfo.localizedModel, // "iPhone"
          'identifierForVendor': iosInfo.identifierForVendor, // UUID
          'isPhysicalDevice': iosInfo.isPhysicalDevice, // true/false
          'utsname': {
            'machine': iosInfo.utsname.machine, // "iPhone15,2" (실제 모델 코드)
            'nodename': iosInfo.utsname.nodename, // 디바이스 노드 이름
            'release': iosInfo.utsname.release, // 커널 릴리즈 버전
            'sysname': iosInfo.utsname.sysname, // 시스템 이름
            'version': iosInfo.utsname.version, // 커널 빌드 버전
          },
        };
      } else if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return {
          'brand': androidInfo.brand, // "Samsung"
          'manufacturer': androidInfo.manufacturer, // "samsung"
          'model': androidInfo.model, // "SM-S911N"
          'device': androidInfo.device, // "r0s"
          'product': androidInfo.product, // "r0sxx"
          'androidId': androidInfo.id, // 안드로이드 고유 ID
          'board': androidInfo.board, // 보드 이름
          'bootloader': androidInfo.bootloader, // 부트로더 버전
          'display': androidInfo.display, // 디스플레이 ID
          'fingerprint': androidInfo.fingerprint, // 빌드 지문
          'hardware': androidInfo.hardware, // 하드웨어 이름
          'host': androidInfo.host, // 빌드 호스트
          'isPhysicalDevice': androidInfo.isPhysicalDevice, // true/false
          'tags': androidInfo.tags, // 빌드 태그
          'type': androidInfo.type, // 빌드 타입
          'versionRelease': androidInfo.version.release, // "13" (안드로이드 버전)
          'versionSdkInt': androidInfo.version.sdkInt, // 33 (API 레벨)
        };
      }

      return {'error': 'Unsupported platform'};
    } catch (e) {
      debugPrint('⚠️ DeviceInfoService: 전체 기기 정보 가져오기 실패 - $e');
      return {'error': e.toString()};
    }
  }

  /// 기기 OS 버전을 가져옵니다
  ///
  /// Returns:
  /// - iOS: "17.4" 형식의 iOS 버전
  /// - Android: "13" 형식의 Android 버전
  /// - 기타: "Unknown"
  static Future<String> getOSVersion() async {
    try {
      if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.systemVersion;
      } else if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.version.release;
      }

      return 'Unknown';
    } catch (e) {
      debugPrint('⚠️ DeviceInfoService: OS 버전 가져오기 실패 - $e');
      return 'Unknown';
    }
  }

  /// 실제 기기인지 시뮬레이터/에뮬레이터인지 확인합니다
  ///
  /// Returns:
  /// - true: 실제 물리적 기기
  /// - false: 시뮬레이터 또는 에뮬레이터
  static Future<bool> isPhysicalDevice() async {
    try {
      if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.isPhysicalDevice;
      } else if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.isPhysicalDevice;
      }

      return false;
    } catch (e) {
      debugPrint('⚠️ DeviceInfoService: 기기 타입 확인 실패 - $e');
      return false;
    }
  }
}
