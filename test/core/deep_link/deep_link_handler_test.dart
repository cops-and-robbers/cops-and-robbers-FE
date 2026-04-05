import 'package:flutter_test/flutter_test.dart';
import 'package:cops_and_robbers/core/deep_link/deep_link_handler.dart';

void main() {
  group('DeepLinkHandler', () {
    group('parseDeepLink', () {
      test('유효한 방 초대 URI에서 RoomInviteResult를 반환한다', () {
        final uri = Uri.parse('https://example.com/room?code=ABC123');

        final result = DeepLinkHandler.parseDeepLink(uri);

        expect(result, isA<RoomInviteResult>());
        expect((result as RoomInviteResult).inviteCode, 'ABC123');
      });

      test('호스트가 다르면 null을 반환한다', () {
        final uri = Uri.parse('https://other.com/room?code=ABC123');

        final result = DeepLinkHandler.parseDeepLink(uri);

        expect(result, isNull);
      });

      test('경로가 /room이 아니면 null을 반환한다', () {
        final uri = Uri.parse('https://example.com/friend?code=ABC123');

        final result = DeepLinkHandler.parseDeepLink(uri);

        expect(result, isNull);
      });

      test('code 파라미터가 없으면 null을 반환한다', () {
        final uri = Uri.parse('https://example.com/room');

        final result = DeepLinkHandler.parseDeepLink(uri);

        expect(result, isNull);
      });

      test('code가 빈 문자열이면 null을 반환한다', () {
        final uri = Uri.parse('https://example.com/room?code=');

        final result = DeepLinkHandler.parseDeepLink(uri);

        expect(result, isNull);
      });
    });
  });
}
