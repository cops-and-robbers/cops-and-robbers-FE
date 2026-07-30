import 'package:cops_and_robbers/core/utils/share_util.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('gal');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test('save_image_returns_true_when_gallery_accepts_image', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'requestAccess') return true;
      if (call.method == 'putImageBytes') return null;
      throw MissingPluginException();
    });

    expect(await saveImageBytes(Uint8List.fromList([1, 2, 3])), isTrue);
  });
}
