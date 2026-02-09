import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/env_config.dart';
import '../storage/secure_token_storage.dart';
import 'auth_interceptor.dart';

/// Dio HTTP 클라이언트 설정
///
/// 앱 전체에서 사용되는 Dio 인스턴스를 생성합니다.
/// AuthInterceptor를 통해 JWT 토큰 자동 주입 및 재발급을 처리합니다.
///
/// **사용 예시**:
/// ```dart
/// final dio = DioClient.create(
///   tokenStorage: secureTokenStorage,
///   onForceLogout: () async { /* 강제 로그아웃 처리 */ },
/// );
/// ```
class DioClient {
  // Private 생성자 - 인스턴스화 방지
  DioClient._();

  /// Dio 인스턴스 생성
  ///
  /// [tokenStorage]: JWT 토큰 저장소
  /// [onForceLogout]: 토큰 재발급 실패 시 호출되는 강제 로그아웃 콜백
  static Dio create({
    required SecureTokenStorage tokenStorage,
    required Future<void> Function() onForceLogout,
  }) {
    final baseOptions = BaseOptions(
      baseUrl: EnvConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    final dio = Dio(baseOptions);

    // reissue 전용 plain Dio (인터셉터 없음)
    // AuthInterceptor 재진입으로 인한 이중 강제 로그아웃 방지
    final plainDio = Dio(baseOptions);

    // 인터셉터 추가
    dio.interceptors.addAll([
      // 1. 인증 인터셉터 (토큰 주입 + 자동 재발급)
      AuthInterceptor(
        tokenStorage: tokenStorage,
        dio: dio,
        plainDio: plainDio,
        onForceLogout: onForceLogout,
      ),

      // 2. 로깅 인터셉터 (디버그 모드에서만)
      if (kDebugMode)
        LogInterceptor(
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
          logPrint: (log) => debugPrint('📡 $log'),
        ),
    ]);

    return dio;
  }
}
