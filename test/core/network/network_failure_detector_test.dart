import 'dart:async';
import 'dart:io';

import 'package:cops_and_robbers/core/errors/app_exception.dart';
import 'package:cops_and_robbers/core/network/network_failure_detector.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isNetworkFailure', () {
    test('NetworkException은 true를 반환한다', () {
      final error = NetworkException(message: '네트워크 에러');
      expect(isNetworkFailure(error), isTrue);
    });

    test('TimeoutException은 true를 반환한다', () {
      final error = TimeoutException('타임아웃');
      expect(isNetworkFailure(error), isTrue);
    });

    test('SocketException은 true를 반환한다', () {
      final error = const SocketException('호스트 도달 불가');
      expect(isNetworkFailure(error), isTrue);
    });

    test('connectionError 타입의 DioException은 true를 반환한다', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionError,
      );
      expect(isNetworkFailure(error), isTrue);
    });

    test('connectionTimeout 타입의 DioException은 true를 반환한다', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
      );
      expect(isNetworkFailure(error), isTrue);
    });

    test('sendTimeout 타입의 DioException은 true를 반환한다', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.sendTimeout,
      );
      expect(isNetworkFailure(error), isTrue);
    });

    test('receiveTimeout 타입의 DioException은 true를 반환한다', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.receiveTimeout,
      );
      expect(isNetworkFailure(error), isTrue);
    });

    test('badResponse 타입의 DioException은 false를 반환한다', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 500,
        ),
      );
      expect(isNetworkFailure(error), isFalse);
    });

    test('ServerException은 false를 반환한다', () {
      final error = ServerException(message: '서버 에러');
      expect(isNetworkFailure(error), isFalse);
    });

    test('ValidationException은 false를 반환한다', () {
      final error = ValidationException(message: '잘못된 요청');
      expect(isNetworkFailure(error), isFalse);
    });

    test('FormatException은 false를 반환한다', () {
      expect(isNetworkFailure(const FormatException('파싱 에러')), isFalse);
    });
  });

  group('isServerFailure', () {
    DioException badResponse(int status) => DioException(
      requestOptions: RequestOptions(path: '/test'),
      type: DioExceptionType.badResponse,
      response: Response(
        requestOptions: RequestOptions(path: '/test'),
        statusCode: status,
      ),
    );

    test('5xx 응답을 감싼 ServerException은 true를 반환한다', () {
      final error = ServerException(
        message: 'server error',
        originalException: badResponse(502),
      );
      expect(isServerFailure(error), isTrue);
    });

    test('원시 5xx DioException도 true를 반환한다', () {
      expect(isServerFailure(badResponse(500)), isTrue);
    });

    test('4xx 응답은 false를 반환한다', () {
      final error = ServerException(
        message: 'not found',
        originalException: badResponse(404),
      );
      expect(isServerFailure(error), isFalse);
    });

    test('응답 없는 연결 에러는 false를 반환한다 (isNetworkFailure 소관)', () {
      final error = NetworkException(
        message: 'connection error',
        originalException: DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.connectionError,
        ),
      );
      expect(isServerFailure(error), isFalse);
    });

    test('원인 예외가 없는 AppException은 false를 반환한다', () {
      expect(isServerFailure(ServerException(message: 'x')), isFalse);
    });
  });

  group('classifyFailure', () {
    DioException withStatus(int status) => DioException(
      requestOptions: RequestOptions(path: '/test'),
      type: DioExceptionType.badResponse,
      response: Response(
        requestOptions: RequestOptions(path: '/test'),
        statusCode: status,
      ),
    );

    test('타임아웃·연결 실패는 network', () {
      expect(
        classifyFailure(NetworkException(message: 'timeout')),
        FailureKind.network,
      );
    });

    test('5xx는 server', () {
      expect(
        classifyFailure(
          ServerException(message: 'x', originalException: withStatus(503)),
        ),
        FailureKind.server,
      );
    });

    test('4xx는 client', () {
      expect(
        classifyFailure(
          ValidationException(message: 'x', originalException: withStatus(400)),
        ),
        FailureKind.client,
      );
      expect(classifyFailure(withStatus(404)), FailureKind.client);
    });

    test('파싱 에러 등은 other', () {
      expect(
        classifyFailure(const FormatException('parse')),
        FailureKind.other,
      );
    });
  });
}
