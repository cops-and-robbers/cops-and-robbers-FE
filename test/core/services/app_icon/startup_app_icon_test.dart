import 'dart:ui';

import 'package:cops_and_robbers/core/services/app_icon/app_icon_service.dart';
import 'package:cops_and_robbers/core/services/app_icon/dynamic_icon_client.dart';
import 'package:cops_and_robbers/core/services/app_icon/startup_app_icon.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _CapturingClient implements DynamicIconClient {
  _CapturingClient({this.current});

  String? requestedName;
  bool setWasCalled = false;
  String? current;

  @override
  Future<bool> supportsAlternateIcons() async => true;

  @override
  Future<String?> currentAlternateIconName() async => current;

  @override
  Future<void> setAlternateIconName(String? name) async {
    setWasCalled = true;
    requestedName = name;
    current = name;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('applies_ja_icon_when_stored_locale_is_ja', () async {
    SharedPreferences.setMockInitialValues({'app_locale_code': 'ja'});
    final client = _CapturingClient();
    final service = AppIconService(client: client, isIOS: true);

    await applyStartupLocaleIcon(service: service);

    expect(client.setWasCalled, isTrue);
    expect(client.requestedName, 'app_icon_ja');
  });

  test('applies_ko_icon_when_stored_locale_is_ko', () async {
    SharedPreferences.setMockInitialValues({'app_locale_code': 'ko'});
    final client = _CapturingClient();
    final service = AppIconService(client: client, isIOS: true);

    await applyStartupLocaleIcon(service: service);

    expect(client.requestedName, 'app_icon_ko');
  });

  test('applies_primary_when_stored_locale_is_en', () async {
    SharedPreferences.setMockInitialValues({'app_locale_code': 'en'});
    final client = _CapturingClient();
    final service = AppIconService(client: client, isIOS: true);

    await applyStartupLocaleIcon(service: service);

    // en → Primary(null). 현재도 Primary(null)이므로 교체 안 함
    expect(client.setWasCalled, isFalse);
  });

  test('applies_primary_icon_when_locale_changes_to_en', () async {
    final client = _CapturingClient(current: 'app_icon_ko');
    final service = AppIconService(client: client, isIOS: true);

    await applyLocaleIcon(const Locale('en'), service: service);

    expect(client.setWasCalled, isTrue);
    expect(client.requestedName, isNull);
  });
}
