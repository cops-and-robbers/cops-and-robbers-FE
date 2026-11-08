import 'package:cops_and_robbers/core/services/device/device_id_manager.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// #687: Android 가 기기 ID 자리에 OS 빌드 번호(Build.ID)를 보내던 문제의 회귀 가드.
///
/// 옛 캐시(`DEVICE_ID`)가 남아 있으면 로직을 고쳐도 빌드 번호가 계속 나가므로,
/// Android 는 새 값으로 갈아끼우고 iOS·기타 플랫폼은 옛 값을 그대로 이어 써야 한다.
void main() {
  const androidId = '9774d56d682e549c';
  const legacyBuildNumber = 'BP4A.251205.006';

  DeviceIdManager manager({
    required TargetPlatform platform,
    Future<String?> Function()? readAndroidId,
    Future<String?> Function()? readIosVendorId,
  }) {
    // 호출마다 다른 값을 내야 "두 번째 호출이 캐시를 탔다"를 확인할 수 있다
    var generated = 0;
    return DeviceIdManager(
      platform: platform,
      readAndroidId: readAndroidId ?? () async => androidId,
      readIosVendorId:
          readIosVendorId ?? () async => 'A1B2C3D4-0000-4000-8000-000000000001',
      generateUuid: () => 'generated-uuid-${++generated}',
    );
  }

  Future<Map<String, Object?>> storedValues() async {
    final prefs = await SharedPreferences.getInstance();
    return {for (final key in prefs.getKeys()) key: prefs.get(key)};
  }

  test('device_id_is_android_id_when_android_launches_first_time', () async {
    SharedPreferences.setMockInitialValues({});

    final id = await manager(platform: TargetPlatform.android).getOrCreate();

    expect(id, androidId);
    expect(await storedValues(), {'DEVICE_ID_V2': androidId});
  });

  test(
    'device_id_replaces_legacy_build_number_when_android_has_old_cache',
    () async {
      SharedPreferences.setMockInitialValues({'DEVICE_ID': legacyBuildNumber});

      final id = await manager(platform: TargetPlatform.android).getOrCreate();

      expect(id, androidId);
      expect(await storedValues(), {'DEVICE_ID_V2': androidId});
    },
  );

  test('device_id_keeps_legacy_value_when_ios_has_old_cache', () async {
    // 2026-01 이전 설치분은 IDFV 가 아니라 UUID 가 캐시돼 있다 — 이 값이 바뀌면 안 된다
    const legacyIosId = '3f2b9c1e-7d4a-4e8b-9c6f-1a2b3c4d5e6f';
    SharedPreferences.setMockInitialValues({'DEVICE_ID': legacyIosId});

    final id = await manager(platform: TargetPlatform.iOS).getOrCreate();

    expect(id, legacyIosId);
    expect(await storedValues(), {'DEVICE_ID_V2': legacyIosId});
  });

  test('device_id_keeps_legacy_value_when_desktop_has_old_cache', () async {
    const legacyDesktopId = '0e6b7f8a-1c2d-4e3f-8a9b-0c1d2e3f4a5b';
    SharedPreferences.setMockInitialValues({'DEVICE_ID': legacyDesktopId});

    final id = await manager(platform: TargetPlatform.macOS).getOrCreate();

    expect(id, legacyDesktopId);
    expect(await storedValues(), {'DEVICE_ID_V2': legacyDesktopId});
  });

  test('device_id_is_saved_uuid_when_android_id_read_throws', () async {
    SharedPreferences.setMockInitialValues({});
    final failing = manager(
      platform: TargetPlatform.android,
      readAndroidId: () async =>
          throw PlatformException(code: 'ERROR_GETTING_ID'),
    );

    final first = await failing.getOrCreate();
    final second = await failing.getOrCreate();

    expect([first, second], ['generated-uuid-1', 'generated-uuid-1']);
    expect(await storedValues(), {'DEVICE_ID_V2': 'generated-uuid-1'});
  });

  test('device_id_is_saved_uuid_when_android_id_is_empty', () async {
    SharedPreferences.setMockInitialValues({});

    final id = await manager(
      platform: TargetPlatform.android,
      readAndroidId: () async => '',
    ).getOrCreate();

    expect(id, 'generated-uuid-1');
    expect(await storedValues(), {'DEVICE_ID_V2': 'generated-uuid-1'});
  });
}
