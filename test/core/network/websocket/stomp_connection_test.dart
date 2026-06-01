import 'package:flutter_test/flutter_test.dart';
import 'package:cops_and_robbers/core/network/websocket/stomp_connection.dart';

void main() {
  group('StompErrorInfo.fromJson', () {
    test('parses_errorCode_when_present', () {
      final info = StompErrorInfo.fromJson({
        'errorCode': 'UNAUTHORIZED_SUBSCRIPTION',
        'title': '구독 권한 없음',
        'status': 403,
        'detail': '해당 팀 전용 채널을 구독할 권한이 없습니다.',
        'instance': 'STOMP',
      });
      expect(info.errorCode, 'UNAUTHORIZED_SUBSCRIPTION');
      expect(info.isAuthExpired, isFalse);
    });

    test('errorCode_is_null_when_absent', () {
      final info = StompErrorInfo.fromJson({
        'title': 'STOMP Error',
        'status': 0,
        'detail': 'x',
        'instance': 'STOMP',
      });
      expect(info.errorCode, isNull);
    });

    test('isAuthExpired_true_when_401_and_stomp', () {
      final info = StompErrorInfo.fromJson({
        'errorCode': 'ACCESS_TOKEN_EXPIRED',
        'title': '인증 만료',
        'status': 401,
        'detail': '인증정보가 만료되었습니다.',
        'instance': 'STOMP',
      });
      expect(info.isAuthExpired, isTrue);
    });
  });
}
