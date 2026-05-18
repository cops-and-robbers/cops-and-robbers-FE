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
    //    백엔드 detail은 한국어 고정이라 비-ko 로케일에 노출되면 안 됨 → 로그용으로만 사용
    //    (_logError에서 이미 debugPrint 처리됨). 사용자 노출은 항상 messageKey 기반.
    if (_isTimeoutError(e)) {
      return NetworkException(
        message: 'request timeout',
        messageKey: 'errorNetworkTimeout',
        code: 'timeout',
        originalException: e,
      );
    }

    if (_isConnectionError(e)) {
      return NetworkException(
        message: 'connection error',
        messageKey: 'errorNetworkOffline',
        code: 'connection-error',
        originalException: e,
      );
    }

    // 4. HTTP 상태 코드별 분기
    //    백엔드 detail/title은 사용자 노출에 사용하지 않음 (한국어 고정 응답 한계)
    //    code 필드도 백엔드 title이 한국어("필수 약관 미동의" 등) 식별자라 그대로 두면 분석/추적용
    final statusCode = e.response?.statusCode;
    final title = apiError?.title ?? '';

    // 5xx 서버 에러 처리
    if (statusCode != null && statusCode >= 500) {
      return ServerException(
        message: 'server error',
        messageKey: 'errorServerInternal',
        code: title.isNotEmpty ? title : 'server-error',
        originalException: e,
      );
    }

    return switch (statusCode) {
      400 => ValidationException(
        message: 'bad request',
        messageKey: 'errorBadRequest',
        code: title.isNotEmpty ? title : 'bad-request',
        originalException: e,
      ),
      401 => AuthException(
        message: 'unauthorized',
        messageKey: 'errorUnauthorized',
        code: title.isNotEmpty ? title : 'unauthorized',
        originalException: e,
      ),
      403 => AuthException(
        message: 'forbidden',
        messageKey: 'errorForbidden',
        code: title.isNotEmpty ? title : 'forbidden',
        originalException: e,
      ),
      404 => ServerException(
        message: 'not found',
        messageKey: 'errorNotFound',
        code: title.isNotEmpty ? title : 'not-found',
        originalException: e,
      ),
      409 => ServerException(
        message: 'conflict',
        messageKey: 'errorConflict',
        code: title.isNotEmpty ? title : 'conflict',
        originalException: e,
      ),
      _ => NetworkException(
        message: 'network error',
        messageKey: 'errorNetworkOffline',
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
