import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../errors/app_exception.dart';
import 'api_error_response.dart';

/// DioException → AppException 공통 변환 유틸리티
///
/// 모든 Repository에서 DioException을 일관된 방식으로 처리합니다.
///
/// **사용법**:
/// ```dart
/// try {
///   final response = await _api.createGame(request);
/// } on DioException catch (e) {
///   throw DioExceptionHandler.handle(e);
/// }
/// ```
///
/// **동작**:
/// 1. 에러 응답 본문에서 RFC 7807 필드(title, status, detail, instance) 파싱
/// 2. kDebugMode에서 전체 에러 정보 debugPrint 출력
/// 3. HTTP 상태 코드별 적절한 AppException 타입으로 변환
class DioExceptionHandler {
  DioExceptionHandler._();

  /// DioException을 AppException으로 변환
  ///
  /// [e] Dio에서 발생한 에러
  /// 반환: 적절한 AppException 하위 타입
  static AppException handle(DioException e) {
    // 1. 에러 응답 본문 파싱 시도
    final apiError = ApiErrorResponse.tryParse(e.response?.data);

    // 2. debugPrint 출력
    _logError(e, apiError);

    // 3. 타임아웃 / 연결 에러 우선 처리
    if (_isTimeoutError(e)) {
      return NetworkException(
        message: apiError?.detail ?? '서버 연결 시간이 초과되었습니다.',
        code: 'timeout',
        originalException: e,
      );
    }

    if (_isConnectionError(e)) {
      return NetworkException(
        message: apiError?.detail ?? '네트워크 연결을 확인하세요.',
        code: 'connection-error',
        originalException: e,
      );
    }

    // 4. HTTP 상태 코드별 분기
    final statusCode = e.response?.statusCode;
    final detail = apiError?.detail ?? '';
    final title = apiError?.title ?? '';

    // 5xx 서버 에러 처리
    if (statusCode != null && statusCode >= 500) {
      return ServerException(
        message: detail.isNotEmpty ? detail : '서버에 문제가 발생했습니다.',
        code: title.isNotEmpty ? title : 'server-error',
        originalException: e,
      );
    }

    return switch (statusCode) {
      400 => ValidationException(
        message: detail.isNotEmpty ? detail : '잘못된 요청입니다.',
        code: title.isNotEmpty ? title : 'bad-request',
        originalException: e,
      ),
      401 => AuthException(
        message: detail.isNotEmpty ? detail : '인증에 실패했습니다.',
        code: title.isNotEmpty ? title : 'unauthorized',
        originalException: e,
      ),
      403 => AuthException(
        message: detail.isNotEmpty ? detail : '접근 권한이 없습니다.',
        code: title.isNotEmpty ? title : 'forbidden',
        originalException: e,
      ),
      404 => ServerException(
        message: detail.isNotEmpty ? detail : '요청한 리소스를 찾을 수 없습니다.',
        code: title.isNotEmpty ? title : 'not-found',
        originalException: e,
      ),
      409 => ServerException(
        message: detail.isNotEmpty ? detail : '요청이 현재 상태와 충돌합니다.',
        code: title.isNotEmpty ? title : 'conflict',
        originalException: e,
      ),
      _ => NetworkException(
        message: detail.isNotEmpty ? detail : '네트워크 연결을 확인하세요.',
        code: 'network-error',
        originalException: e,
      ),
    };
  }

  /// 타임아웃 에러 여부 확인
  static bool _isTimeoutError(DioException e) {
    return e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout;
  }

  /// 연결 에러 여부 확인
  static bool _isConnectionError(DioException e) {
    return e.type == DioExceptionType.connectionError;
  }

  /// 에러 정보를 debugPrint로 출력 (kDebugMode에서만)
  static void _logError(DioException e, ApiErrorResponse? apiError) {
    if (!kDebugMode) return;

    final method = e.requestOptions.method;
    final path = e.requestOptions.path;
    final statusCode = e.response?.statusCode ?? 0;

    if (apiError != null) {
      debugPrint('❌ API 에러 [$statusCode] $method $path');
      debugPrint('   title: ${apiError.title}');
      debugPrint('   detail: ${apiError.detail}');
      debugPrint('   instance: ${apiError.instance}');
    } else {
      debugPrint('❌ API 에러 [$statusCode] $method $path');
      debugPrint('   type: ${e.type}');
      debugPrint('   message: ${e.message}');
    }
  }
}
