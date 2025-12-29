import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// 기기 고유 ID 관리 서비스
///
/// SharedPreferences에 UUID를 저장하여
/// 앱 재시작 후에도 동일한 기기로 인식되도록 합니다.
///
/// **사용 목적**:
/// - FCM 멀티 디바이스 푸시 알림 지원
/// - 한 사용자가 여러 기기(폰, 태블릿)에서 로그인 시 각 기기별 식별
///
/// **영속성**:
/// - 앱 재시작: UUID 유지 ✅
/// - 앱 업데이트: UUID 유지 ✅
/// - 앱 재설치: UUID 새로 생성 (새 기기로 등록) ✅
class DeviceIdManager {
  /// SharedPreferences 저장 키
  static const String _deviceIdKey = 'DEVICE_ID';

  /// UUID 생성기 인스턴스
  static const _uuid = Uuid();

  /// 기존 기기 ID를 가져오거나 새로 생성합니다
  ///
  /// **동작**:
  /// 1. SharedPreferences에서 기존 ID 확인
  /// 2. 없으면 UUID v4 형식으로 새 ID 생성
  /// 3. 새 ID를 SharedPreferences에 저장
  /// 4. ID 반환
  ///
  /// **UUID v4 형식**:
  /// - 예: "550e8400-e29b-41d4-a716-446655440000"
  /// - 랜덤 생성, 충돌 가능성 극히 낮음
  ///
  /// Returns: UUID v4 형식의 기기 고유 ID
  static Future<String> getOrCreateDeviceId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? deviceId = prefs.getString(_deviceIdKey);

      if (deviceId == null || deviceId.isEmpty) {
        // 없으면 새로 생성하여 저장
        deviceId = _uuid.v4();
        await prefs.setString(_deviceIdKey, deviceId);
        debugPrint('[DeviceIdManager] 📱 새 기기 ID 생성: $deviceId');
      } else {
        debugPrint('[DeviceIdManager] 📱 기존 기기 ID 사용: $deviceId');
      }

      return deviceId;
    } catch (e) {
      debugPrint('[DeviceIdManager] ❌ 기기 ID 가져오기 실패: $e');
      // 실패 시 임시 ID 생성 (저장하지 않음)
      final tempId = _uuid.v4();
      debugPrint('[DeviceIdManager] ⚠️ 임시 ID 사용: $tempId');
      return tempId;
    }
  }

  /// 저장된 기기 ID를 삭제합니다 (테스트용)
  ///
  /// **주의**: 프로덕션에서는 사용하지 마세요.
  /// 기기 ID가 변경되면 푸시 알림이 해당 기기로 전송되지 않습니다.
  ///
  /// **사용 시나리오**:
  /// - 테스트 중 기기 ID 초기화
  /// - 디버깅 목적
  @visibleForTesting
  static Future<void> clearDeviceId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_deviceIdKey);
      debugPrint('[DeviceIdManager] 🗑️ 기기 ID 삭제 완료');
    } catch (e) {
      debugPrint('[DeviceIdManager] ❌ 기기 ID 삭제 실패: $e');
    }
  }
}
