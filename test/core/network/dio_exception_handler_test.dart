import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cops_and_robbers/core/errors/app_exception.dart';
import 'package:cops_and_robbers/core/network/dio_exception_handler.dart';

DioException _serverError(int status, {String? errorCode}) {
  final req = RequestOptions(path: '/api/x');
  return DioException(
    requestOptions: req,
    response: Response(
      requestOptions: req,
      statusCode: status,
      data: {
        if (errorCode != null) 'errorCode': errorCode,
        'title': '오류',
        'status': status,
        'detail': '한국어 detail',
        'instance': '/api/x',
      },
    ),
    type: DioExceptionType.badResponse,
  );
}

void main() {
  group('DioExceptionHandler.handle', () {
    test('stores_errorCode_in_code_and_common_messageKey_for_400', () {
      final e = DioExceptionHandler.handle(
        _serverError(400, errorCode: 'GAME_FULL'),
      );
      expect(e, isA<ValidationException>());
      expect(e.code, 'GAME_FULL');
      expect(e.messageKey, 'errorTemporaryRetry');
    });

    test('stores_errorCode_for_500_server_error', () {
      final e = DioExceptionHandler.handle(
        _serverError(500, errorCode: 'INTERNAL_SERVER_ERROR'),
      );
      expect(e, isA<ServerException>());
      expect(e.code, 'INTERNAL_SERVER_ERROR');
      expect(e.messageKey, 'errorTemporaryRetry');
    });

    test('timeout_keeps_network_messageKey_and_no_errorCode', () {
      final req = RequestOptions(path: '/api/x');
      final e = DioExceptionHandler.handle(
        DioException(
          requestOptions: req,
          type: DioExceptionType.connectionTimeout,
        ),
      );
      expect(e, isA<NetworkException>());
      expect(e.messageKey, 'errorNetworkTimeout');
    });
  });
}
