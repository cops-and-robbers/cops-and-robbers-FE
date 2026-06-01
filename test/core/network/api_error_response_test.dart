import 'package:flutter_test/flutter_test.dart';
import 'package:cops_and_robbers/core/network/api_error_response.dart';

void main() {
  group('ApiErrorResponse.tryParse', () {
    test('parses_errorCode_when_present', () {
      final result = ApiErrorResponse.tryParse({
        'errorCode': 'INVALID_INVITE_CODE',
        'title': '초대 코드 오류',
        'status': 400,
        'detail': '입력하신 초대 코드가 유효하지 않습니다.',
        'instance': '/api/games/1/participants',
      });
      expect(result, isNotNull);
      expect(result!.errorCode, 'INVALID_INVITE_CODE');
      expect(result.title, '초대 코드 오류');
    });

    test('errorCode_is_null_when_absent', () {
      final result = ApiErrorResponse.tryParse({
        'title': '오류',
        'status': 400,
        'detail': '...',
        'instance': '/x',
      });
      expect(result, isNotNull);
      expect(result!.errorCode, isNull);
    });
  });
}
