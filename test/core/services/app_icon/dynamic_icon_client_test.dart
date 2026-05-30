import 'package:cops_and_robbers/core/services/app_icon/dynamic_icon_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NoopIconClient', () {
    test('supports_alternate_icons_returns_false', () async {
      expect(await const NoopIconClient().supportsAlternateIcons(), isFalse);
    });

    test('current_icon_returns_null', () async {
      expect(await const NoopIconClient().currentAlternateIconName(), isNull);
    });

    test('set_icon_is_noop_and_does_not_throw', () async {
      await expectLater(
        const NoopIconClient().setAlternateIconName('app_icon_ko'),
        completes,
      );
    });
  });
}
