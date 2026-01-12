import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// 기기 고유 ID 관리 서비스
///
/// 플랫폼별 고유 ID를 사용하여 기기를 식별합니다.
/// - Android: Android ID (Settings.Secure.ANDROID_ID)
/// - iOS: IDFV (Identifier For Vendor)
///
/// 플랫폼 ID를 SharedPreferences에 캐싱하여 성능을 최적화합니다.
///
/// **사용 목적**:
/// - FCM 멀티 디바이스 푸시 알림 지원
/// - 한 사용자가 여러 기기(폰, 태블릿)에서 로그인 시 각 기기별 식별
///
/// **영속성**:
/// - 앱 재시작: ID 유지 ✅
/// - 앱 업데이트: ID 유지 ✅
/// - 앱 재설치: ID 유지 ✅ (Android), 조건부 유지 ⚠️ (iOS)
/// - 공장 초기화: ID 변경 (Android), 조건부 변경 (iOS)
///
/// **플랫폼별 특징**:
/// - **Android ID**: 공장 초기화 전까지 영구적, 앱 재설치해도 동일
/// - **iOS IDFV**: 같은 개발자의 앱이 하나라도 남아있으면 유지, 모두 삭제 시 리셋
class DeviceIdManager {
  /// SharedPreferences 저장 키
  static const String _deviceIdKey = 'DEVICE_ID';

  /// UUID 생성기 인스턴스
  static const _uuid = Uuid();

  /// DeviceInfoPlugin 인스턴스
  static final _deviceInfo = DeviceInfoPlugin();

  /// 기기 고유 ID를 가져옵니다
  ///
  /// **동작 순서**:
  /// 1. SharedPreferences에서 캐시된 ID 확인
  /// 2. 없으면 플랫폼별 ID 가져오기:
  ///    - Android: Android ID (androidInfo.id)
  ///    - iOS: IDFV (iosInfo.identifierForVendor)
  /// 3. 플랫폼 ID를 SharedPreferences에 캐시
  /// 4. ID 반환
  ///
  /// **반환값 형식**:
  /// - Android: 16자리 Hex (예: "9774d56d682e549c")
  /// - iOS: UUID 형식 (예: "A1B2C3D4-E5F6-47G8-H9I0-J1K2L3M4N5O6")
  ///
  /// Returns: 플랫폼별 기기 고유 ID
  static Future<String> getOrCreateDeviceId() async {
    try {
      // 1. 캐시된 ID 확인
      final prefs = await SharedPreferences.getInstance();
      String? cachedId = prefs.getString(_deviceIdKey);

      if (cachedId != null && cachedId.isNotEmpty) {
        debugPrint('[DeviceIdManager] 📱 캐시된 기기 ID 사용: $cachedId');
        return cachedId;
      }

      // 2. 플랫폼별 ID 가져오기
      String platformId;

      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        platformId = androidInfo.id; // Android ID
        debugPrint('[DeviceIdManager] 📱 Android ID 가져오기: $platformId');
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        platformId = iosInfo.identifierForVendor ?? _uuid.v4();

        if (iosInfo.identifierForVendor != null) {
          debugPrint('[DeviceIdManager] 📱 iOS IDFV 가져오기: $platformId');
        } else {
          debugPrint('[DeviceIdManager] ⚠️ IDFV 없음, UUID 생성: $platformId');
        }
      } else {
        // 기타 플랫폼 (웹, 데스크톱)
        platformId = _uuid.v4();
        debugPrint('[DeviceIdManager] 📱 기타 플랫폼, UUID 생성: $platformId');
      }

      // 3. 캐시에 저장
      await prefs.setString(_deviceIdKey, platformId);
      debugPrint('[DeviceIdManager] 💾 기기 ID 캐시 저장 완료');

      return platformId;
    } catch (e) {
      debugPrint('[DeviceIdManager] ❌ 기기 ID 가져오기 실패: $e');

      // 실패 시 임시 UUID 생성 (저장하지 않음)
      final tempId = _uuid.v4();
      debugPrint('[DeviceIdManager] ⚠️ 임시 UUID 사용: $tempId');
      return tempId;
    }
  }

  /// 캐시된 기기 ID를 삭제합니다 (테스트용)
  ///
  /// **주의**: 프로덕션에서는 사용하지 마세요.
  /// 캐시를 삭제해도 플랫폼 ID는 동일하므로 다음 호출 시 같은 ID를 받습니다.
  ///
  /// **사용 시나리오**:
  /// - 테스트 중 캐시 초기화
  /// - 디버깅 목적
  @visibleForTesting
  static Future<void> clearDeviceId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_deviceIdKey);
      debugPrint('[DeviceIdManager] 🗑️ 캐시된 기기 ID 삭제 완료');
    } catch (e) {
      debugPrint('[DeviceIdManager] ❌ 기기 ID 삭제 실패: $e');
    }
  }
}
