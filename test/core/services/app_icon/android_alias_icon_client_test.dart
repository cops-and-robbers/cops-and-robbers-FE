import 'package:cops_and_robbers/core/services/app_icon/dynamic_icon_client.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('cops_and_robbers/app_icon');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  final calls = <MethodCall>[];

  void mockHandler(Future<Object?>? Function(MethodCall) handler) {
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return handler(call);
    });
  }

  setUp(calls.clear);
  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  group('NativeAppIconClient', () {
    test('current_icon_returns_null_when_native_reports_en', () async {
      mockHandler((_) async => 'app_icon_en');
      final result = await const NativeAppIconClient().currentAlternateIconName();
      expect(result, isNull); // en → null 역변환 (iOS와 동일 의미)
    });

    test('current_icon_returns_alias_when_native_reports_ko', () async {
      mockHandler((_) async => 'app_icon_ko');
      final result = await const NativeAppIconClient().currentAlternateIconName();
      expect(result, 'app_icon_ko');
    });

    test('current_icon_returns_null_when_channel_throws', () async {
      mockHandler((_) async => throw PlatformException(code: 'x'));
      final result = await const NativeAppIconClient().currentAlternateIconName();
      expect(result, isNull);
    });

    test('set_null_sends_en_alias_to_native', () async {
      mockHandler((_) async => null);
      await expectLater(
        const NativeAppIconClient().setAlternateIconName(null),
        completes,
      );
      final setCall = calls.firstWhere((c) => c.method == 'setIcon');
      expect((setCall.arguments as Map)['name'], 'app_icon_en');
    });

    test('set_ko_sends_ko_alias_to_native', () async {
      mockHandler((_) async => null);
      await expectLater(
        const NativeAppIconClient().setAlternateIconName('app_icon_ko'),
        completes,
      );
      final setCall = calls.firstWhere((c) => c.method == 'setIcon');
      expect((setCall.arguments as Map)['name'], 'app_icon_ko');
    });

    test('supports_returns_true_when_native_true', () async {
      mockHandler((_) async => true);
      expect(await const NativeAppIconClient().supportsAlternateIcons(), isTrue);
    });

    test('supports_returns_false_when_channel_throws', () async {
      mockHandler((_) async => throw MissingPluginException());
      expect(await const NativeAppIconClient().supportsAlternateIcons(), isFalse);
    });
  });
}
