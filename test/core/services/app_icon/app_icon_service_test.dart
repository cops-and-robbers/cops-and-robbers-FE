import 'package:cops_and_robbers/core/services/app_icon/app_icon_service.dart';
import 'package:cops_and_robbers/core/services/app_icon/dynamic_icon_client.dart';
import 'package:flutter_test/flutter_test.dart';

/// 플랫폼 채널 fake — 시스템 경계만 대체
class _FakeDynamicIconClient implements DynamicIconClient {
  _FakeDynamicIconClient({
    this.supported = true,
    this.current,
    this.throwOnSet = false,
  });

  bool supported;
  String? current;
  bool throwOnSet;

  int setCallCount = 0;
  String? lastSetName;
  bool setWasCalled = false;

  @override
  Future<bool> supportsAlternateIcons() async => supported;

  @override
  Future<String?> currentAlternateIconName() async => current;

  @override
  Future<void> setAlternateIconName(String? name) async {
    setWasCalled = true;
    setCallCount++;
    lastSetName = name;
    if (throwOnSet) throw Exception('icon set failed');
    current = name;
  }
}

void main() {
  group('AppIconService.applyIconForIdentifier', () {
    test('requests_set_icon_when_current_differs_from_target', () async {
      final fake = _FakeDynamicIconClient(current: null); // 현재 Primary
      final service = AppIconService(client: fake);

      await service.applyIconForIdentifier('app_icon_ko');

      expect(fake.setWasCalled, isTrue);
      expect(fake.lastSetName, 'app_icon_ko');
    });

    test('skips_set_icon_when_current_equals_target', () async {
      // 알럿 방지 핵심 — 변화 없으면 절대 set 호출 안 함
      final fake = _FakeDynamicIconClient(current: 'app_icon_ja');
      final service = AppIconService(client: fake);

      await service.applyIconForIdentifier('app_icon_ja');

      expect(fake.setWasCalled, isFalse);
    });

    test('skips_set_icon_when_alternate_icons_unsupported', () async {
      final fake = _FakeDynamicIconClient(supported: false, current: null);
      final service = AppIconService(client: fake);

      await service.applyIconForIdentifier('app_icon_ko');

      expect(fake.setWasCalled, isFalse);
    });

    test('makes_no_set_call_when_using_noop_client', () async {
      // unsupported 플랫폼은 NoopIconClient가 선택되어 set이 일어나지 않음
      final service = AppIconService(client: const NoopIconClient());

      await expectLater(
        service.applyIconForIdentifier('app_icon_ko'),
        completes,
      );
    });

    test('swallows_exception_and_does_not_throw', () async {
      final fake = _FakeDynamicIconClient(current: null, throwOnSet: true);
      final service = AppIconService(client: fake);

      await expectLater(
        service.applyIconForIdentifier('app_icon_ko'),
        completes,
      );
    });
  });
}
