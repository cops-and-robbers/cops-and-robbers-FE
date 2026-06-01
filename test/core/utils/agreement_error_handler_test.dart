import 'package:cops_and_robbers/core/errors/app_exception.dart';
import 'package:cops_and_robbers/core/utils/agreement_error_handler.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

DioException _dioErrorWithTitle(
  String title, {
  int statusCode = 400,
  String detail = '필수 약관은 모두 동의해야 합니다.',
  String instance = '/api/games',
  String? errorCode,
}) {
  return DioException(
    requestOptions: RequestOptions(path: instance),
    response: Response(
      requestOptions: RequestOptions(path: instance),
      statusCode: statusCode,
      data: {
        'title': title,
        'status': statusCode,
        'detail': detail,
        'instance': instance,
        if (errorCode != null) 'errorCode': errorCode,
      },
    ),
    type: DioExceptionType.badResponse,
  );
}

void main() {
  group('isRequiredTermsMissingError', () {
    test('null 에러는 false를 반환한다', () {
      expect(isRequiredTermsMissingError(null), isFalse);
    });

    test(
      'AppException(originalException=DioException title="필수 약관 미동의") → true',
      () {
        final dio = _dioErrorWithTitle(
          '필수 약관 미동의',
          errorCode: 'REQUIRED_TERMS_NOT_AGREED',
        );
        final appError = ValidationException(
          message: '필수 약관은 모두 동의해야 합니다.',
          originalException: dio,
        );
        expect(isRequiredTermsMissingError(appError), isTrue);
      },
    );

    test('DioException title="필수 약관 미동의" → true (home_page 케이스)', () {
      final dio = _dioErrorWithTitle(
        '필수 약관 미동의',
        instance: '/api/games/join',
        errorCode: 'REQUIRED_TERMS_NOT_AGREED',
      );
      expect(isRequiredTermsMissingError(dio), isTrue);
    });

    test('title이 다른 AppException은 false', () {
      final dio = _dioErrorWithTitle('이미 참가 중인 게임', statusCode: 409);
      final appError = ServerException(
        message: '이미 해당 게임에 참가하고 있습니다.',
        originalException: dio,
      );
      expect(isRequiredTermsMissingError(appError), isFalse);
    });

    test('originalException 없는 AppException은 false', () {
      const appError = NetworkException(message: '네트워크 에러');
      expect(isRequiredTermsMissingError(appError), isFalse);
    });

    test('일반 Exception은 false', () {
      expect(isRequiredTermsMissingError(Exception('generic')), isFalse);
    });

    test('RFC 7807 형식이 아닌 response.data는 false', () {
      final dio = DioException(
        requestOptions: RequestOptions(path: '/api/games'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/games'),
          statusCode: 400,
          data: 'plain text error',
        ),
        type: DioExceptionType.badResponse,
      );
      expect(isRequiredTermsMissingError(dio), isFalse);
    });

    test('response가 null인 DioException은 false (연결 실패 등)', () {
      final dio = DioException(
        requestOptions: RequestOptions(path: '/api/games'),
        type: DioExceptionType.connectionError,
      );
      expect(isRequiredTermsMissingError(dio), isFalse);
    });
  });
}
