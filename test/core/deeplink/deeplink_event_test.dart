import 'package:flutter_test/flutter_test.dart';
import 'package:cops_and_robbers/core/deeplink/deeplink_event.dart';

void main() {
  group('DeeplinkEvent.fromUri', () {
    final cases = <(String, String, DeeplinkEvent Function())>[
      (
        '정상 invite URL',
        'https://copsnro66ers.site/join/ABC123',
        () => const DeeplinkEvent.inviteJoin(inviteCode: 'ABC123'),
      ),
      (
        '허용되지 않은 host',
        'https://evil.example.com/join/ABC123',
        () => DeeplinkEvent.unknown(
          uri: Uri.parse('https://evil.example.com/join/ABC123'),
        ),
      ),
      (
        '/join 만 있고 코드 없음',
        'https://copsnro66ers.site/join/',
        () => DeeplinkEvent.unknown(
          uri: Uri.parse('https://copsnro66ers.site/join/'),
        ),
      ),
      (
        '/join 외 다른 path',
        'https://copsnro66ers.site/friend/USER1',
        () => DeeplinkEvent.unknown(
          uri: Uri.parse('https://copsnro66ers.site/friend/USER1'),
        ),
      ),
      (
        '코드에 URL encoded 문자 포함',
        'https://copsnro66ers.site/join/A%2DB%2DC',
        () => const DeeplinkEvent.inviteJoin(inviteCode: 'A-B-C'),
      ),
    ];

    for (final (name, urlStr, expected) in cases) {
      test('$name 은 ${expected()} 를 반환한다', () {
        final result = DeeplinkEvent.fromUri(Uri.parse(urlStr));
        expect(result, equals(expected()));
      });
    }
  });
}
