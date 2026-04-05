import 'package:flutter_test/flutter_test.dart';
import 'package:cops_and_robbers/core/constants/deep_link_config.dart';

void main() {
  group('DeepLinkConfig', () {
    test('roomInviteUrl은 올바른 형식의 딥링크 URL을 생성한다', () {
      final url = DeepLinkConfig.roomInviteUrl('ABC123');

      expect(url, 'https://example.com/room?code=ABC123');
    });

    test('roomInviteUrl은 다양한 초대코드를 처리한다', () {
      expect(
        DeepLinkConfig.roomInviteUrl('XYZ789'),
        'https://example.com/room?code=XYZ789',
      );
    });

    test('isDeepLink는 올바른 호스트의 URI를 true로 판별한다', () {
      final uri = Uri.parse('https://example.com/room?code=ABC123');

      expect(DeepLinkConfig.isDeepLink(uri), isTrue);
    });

    test('isDeepLink는 다른 호스트의 URI를 false로 판별한다', () {
      final uri = Uri.parse('https://other.com/room?code=ABC123');

      expect(DeepLinkConfig.isDeepLink(uri), isFalse);
    });

    test('isDeepLink는 http 스킴의 URI를 false로 판별한다', () {
      final uri = Uri.parse('http://example.com/room?code=ABC123');

      expect(DeepLinkConfig.isDeepLink(uri), isFalse);
    });

    test('isRoomInvite는 /room 경로를 true로 판별한다', () {
      final uri = Uri.parse('https://example.com/room?code=ABC123');

      expect(DeepLinkConfig.isRoomInvite(uri), isTrue);
    });

    test('isRoomInvite는 /friend 경로를 false로 판별한다', () {
      final uri = Uri.parse('https://example.com/friend?code=USER456');

      expect(DeepLinkConfig.isRoomInvite(uri), isFalse);
    });

    test('extractRoomCode는 code 파라미터를 추출한다', () {
      final uri = Uri.parse('https://example.com/room?code=ABC123');

      expect(DeepLinkConfig.extractRoomCode(uri), 'ABC123');
    });

    test('extractRoomCode는 code 파라미터가 없으면 null을 반환한다', () {
      final uri = Uri.parse('https://example.com/room');

      expect(DeepLinkConfig.extractRoomCode(uri), isNull);
    });
  });
}
