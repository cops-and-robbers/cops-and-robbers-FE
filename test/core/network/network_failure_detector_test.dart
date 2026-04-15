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
}
