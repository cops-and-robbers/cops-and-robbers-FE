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
    //    errorCode(SCREAMING_SNAKE)를 code에 저장 → error_message_mapper의 shouldUseBackendErrorCode 가드가 사용
    final statusCode = e.response?.statusCode;
    final errorCode = apiError?.errorCode;

    // 5xx 서버 에러 처리
    // messageKey는 공통 'errorTemporaryRetry' — error_message_mapper가 errorCode로 세분화
    if (statusCode != null && statusCode >= 500) {
      return ServerException(
        message: 'server error',
        messageKey: 'errorTemporaryRetry',
        code: errorCode,
        originalException: e,
      );
    }

    return switch (statusCode) {
      400 => ValidationException(
        message: 'bad request',
        messageKey:
            'errorTemporaryRetry', // shouldUseBackendErrorCode 가드의 전제 (error_message_mapper.dart)
        code: errorCode, // 백엔드 errorCode (없으면 null)
        originalException: e,
      ),
      401 => AuthException(
        message: 'unauthorized',
        messageKey: 'errorTemporaryRetry',
        code: errorCode,
        originalException: e,
      ),
      403 => AuthException(
        message: 'forbidden',
        messageKey: 'errorTemporaryRetry',
        code: errorCode,
        originalException: e,
      ),
      404 => ServerException(
        message: 'not found',
        messageKey: 'errorTemporaryRetry',
        code: errorCode,
        originalException: e,
      ),
      409 => ServerException(
        message: 'conflict',
        messageKey: 'errorTemporaryRetry',
        code: errorCode,
        originalException: e,
      ),
      // 미처리 분기 — statusCode 유무로 네트워크 문제와 서버 응답을 분리
      // (422/429 등을 NetworkException으로 묶으면 "네트워크 연결 확인" 안내 오진)
      _ => _buildFallbackException(statusCode, errorCode, e),
    };
  }

  /// 명시 케이스에 잡히지 않은 응답을 statusCode 기준으로 분류
  ///
  /// - statusCode == null: 네트워크 자체 문제 (timeout/connection은 위에서 처리됨)
  /// - 4xx: 미처리 클라이언트 오류 (422 Unprocessable, 429 Too Many Requests 등)
  /// - 그 외: 서버측 오류 (5xx는 위에서 처리됐지만 안전망)
  static AppException _buildFallbackException(
    int? statusCode,
    String? errorCode, // 백엔드 errorCode — null이면 code도 null
    DioException e,
  ) {
    if (statusCode == null) {
      // 오프라인/미확인 에러 — errorCode는 null이 맞음
      return NetworkException(
        message: 'network error',
        messageKey: 'errorNetworkOffline',
        code: errorCode, // 오프라인 시 null, 정상
        originalException: e,
      );
    }
    if (statusCode >= 400 && statusCode < 500) {
      return ValidationException(
        message: 'unhandled client error ($statusCode)',
        messageKey: 'errorTemporaryRetry',
        code: errorCode,
        originalException: e,
      );
    }
    return ServerException(
      message: 'unhandled server error ($statusCode)',
      messageKey: 'errorTemporaryRetry',
      code: errorCode,
      originalException: e,
    );
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
