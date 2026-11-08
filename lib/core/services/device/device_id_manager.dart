import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// 기기 고유 ID 관리 서비스
///
/// 로그인 요청의 `deviceId` 로 보내는 값을 정하고 SharedPreferences 에 캐시한다.
/// - Android: ANDROID_ID (`Settings.Secure.ANDROID_ID`, 16자리 hex)
/// - iOS: IDFV (Identifier For Vendor)
/// - 기타 플랫폼 / 읽기 실패: UUID v4 를 만들어 캐시
///
/// **캐시 키 이전 (#687)**:
/// 옛 키 `DEVICE_ID` 에 Android 는 OS 빌드 번호(`Build.ID`)가 들어 있어
/// 같은 펌웨어 기기끼리 값이 겹쳤다. 새 키 `DEVICE_ID_V2` 로 옮기면서
/// - Android: 옛 값을 버리고 ANDROID_ID 를 새로 읽는다
/// - iOS·기타: 옛 값이 정상 값이므로 그대로 옮긴다 (2026-01 이전 설치분은 UUID)
///
/// **ANDROID_ID 성질**:
/// - Android 8.0 이상: 앱 서명 키 + 사용자 + 기기 조합마다 다르다.
///   같은 서명 키면 재설치해도 유지, 공장 초기화하면 바뀐다.
///   디버그 빌드와 Play 서명 빌드는 서명 키가 달라 같은 기기여도 값이 다르다.
/// - Android 7.x (minSdk 24): 기기 + 사용자마다 하나, 모든 앱이 같은 값을 받는다.
/// - 업무 프로필·다중 사용자는 사용자마다 값이 다르다.
///
/// **iOS IDFV**: 같은 개발자의 앱이 하나라도 남아 있으면 유지, 모두 삭제하면 바뀐다.
class DeviceIdManager {
  /// 테스트에서 플랫폼과 기기 ID 출처(플랫폼 채널 경계)를 바꿔 끼우기 위한 생성자
  @visibleForTesting
  DeviceIdManager({
    required TargetPlatform platform,
    required Future<String?> Function() readAndroidId,
    required Future<String?> Function() readIosVendorId,
    String Function()? generateUuid,
  }) : _platform = platform,
       _readAndroidId = readAndroidId,
       _readIosVendorId = readIosVendorId,
       _generateUuid = generateUuid ?? const Uuid().v4;

  /// SharedPreferences 저장 키
  static const String _deviceIdKey = 'DEVICE_ID_V2';

  /// 빌드 번호가 섞여 있는 옛 저장 키 — 이전 후 지운다
  static const String _legacyDeviceIdKey = 'DEVICE_ID';

  static final _deviceInfo = DeviceInfoPlugin();

  static final _default = DeviceIdManager(
    platform: defaultTargetPlatform,
    readAndroidId: () => const AndroidId().getId(),
    readIosVendorId: () async =>
        (await _deviceInfo.iosInfo).identifierForVendor,
  );

  final TargetPlatform _platform;
  final Future<String?> Function() _readAndroidId;
  final Future<String?> Function() _readIosVendorId;
  final String Function() _generateUuid;

  /// 기기 고유 ID를 가져옵니다
  ///
  /// Returns: 캐시된 ID, 없으면 플랫폼 ID(실패 시 UUID)를 캐시한 뒤 반환
  static Future<String> getOrCreateDeviceId() => _default.getOrCreate();

  /// [getOrCreateDeviceId] 의 실제 동작
  ///
  /// **동작 순서**:
  /// 1. 새 키에 캐시가 있으면 반환
  /// 2. Android 는 ANDROID_ID, iOS·기타는 옛 키 값을 우선 사용
  /// 3. 둘 다 없으면 IDFV 또는 UUID
  /// 4. 새 키에 저장하고 옛 키 삭제
  @visibleForTesting
  Future<String> getOrCreate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedId = prefs.getString(_deviceIdKey);

      if (cachedId != null && cachedId.isNotEmpty) {
        debugPrint('[DeviceIdManager] 📱 캐시된 기기 ID 사용: $cachedId');
        return cachedId;
      }

      final deviceId =
          await _resolvePlatformId(prefs.getString(_legacyDeviceIdKey)) ??
          _generateUuid();

      await prefs.setString(_deviceIdKey, deviceId);
      await prefs.remove(_legacyDeviceIdKey);
      debugPrint('[DeviceIdManager] 💾 기기 ID 캐시 저장 완료: $deviceId');

      return deviceId;
    } catch (e) {
      // 저장소 자체를 못 쓰는 경우라 캐시할 수 없다
      debugPrint('[DeviceIdManager] ❌ 기기 ID 캐시 실패: $e');
      final tempId = _generateUuid();
      debugPrint('[DeviceIdManager] ⚠️ 임시 UUID 사용: $tempId');
      return tempId;
    }
  }

  /// 플랫폼 ID를 읽는다. 없거나 실패하면 null — 호출부가 UUID 로 대신해 캐시한다
  Future<String?> _resolvePlatformId(String? legacyId) async {
    try {
      if (_platform == TargetPlatform.android) {
        final androidId = _nonEmpty(await _readAndroidId());
        debugPrint('[DeviceIdManager] 📱 ANDROID_ID 가져오기: $androidId');
        return androidId;
      }

      final legacy = _nonEmpty(legacyId);
      if (legacy != null) {
        debugPrint('[DeviceIdManager] 📱 옛 캐시 값 이어 쓰기: $legacy');
        return legacy;
      }

      if (_platform == TargetPlatform.iOS) {
        final idfv = _nonEmpty(await _readIosVendorId());
        debugPrint('[DeviceIdManager] 📱 iOS IDFV 가져오기: $idfv');
        return idfv;
      }

      return null;
    } catch (e) {
      debugPrint('[DeviceIdManager] ❌ 플랫폼 기기 ID 가져오기 실패: $e');
      return null;
    }
  }

  static String? _nonEmpty(String? value) =>
      (value == null || value.isEmpty) ? null : value;

  /// 캐시된 기기 ID를 삭제합니다 (테스트용)
  ///
  /// **주의**: 프로덕션에서는 사용하지 마세요.
  /// Android·iOS 는 다음 호출 때 플랫폼 ID를 다시 읽으므로 대개 같은 값을 받습니다.
  @visibleForTesting
  static Future<void> clearDeviceId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_deviceIdKey);
      await prefs.remove(_legacyDeviceIdKey);
      debugPrint('[DeviceIdManager] 🗑️ 캐시된 기기 ID 삭제 완료');
    } catch (e) {
      debugPrint('[DeviceIdManager] ❌ 기기 ID 삭제 실패: $e');
    }
  }
}
