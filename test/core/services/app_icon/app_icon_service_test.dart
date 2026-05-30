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
      final service = AppIconService(client: fake, isIOS: true);

      await service.applyIconForIdentifier('app_icon_ko');

      expect(fake.setWasCalled, isTrue);
      expect(fake.lastSetName, 'app_icon_ko');
    });

    test('skips_set_icon_when_current_equals_target', () async {
      // 알럿 방지 핵심 — 변화 없으면 절대 set 호출 안 함
      final fake = _FakeDynamicIconClient(current: 'app_icon_ja');
      final service = AppIconService(client: fake, isIOS: true);

      await service.applyIconForIdentifier('app_icon_ja');

      expect(fake.setWasCalled, isFalse);
    });

    test('skips_when_alternate_icons_unsupported', () async {
      final fake = _FakeDynamicIconClient(supported: false, current: null);
      final service = AppIconService(client: fake, isIOS: true);

      await service.applyIconForIdentifier('app_icon_ko');

      expect(fake.setWasCalled, isFalse);
    });

    test('does_nothing_on_non_ios', () async {
      final fake = _FakeDynamicIconClient(current: null);
      final service = AppIconService(client: fake, isIOS: false);

      await service.applyIconForIdentifier('app_icon_ko');

      expect(fake.setWasCalled, isFalse);
    });

    test('swallows_exception_and_does_not_throw', () async {
      final fake = _FakeDynamicIconClient(current: null, throwOnSet: true);
      final service = AppIconService(client: fake, isIOS: true);

      await expectLater(
        service.applyIconForIdentifier('app_icon_ko'),
        completes,
      );
    });
  });
}
