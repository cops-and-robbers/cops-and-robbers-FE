import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/api_endpoints.dart';
import '../storage/secure_token_storage.dart';
import 'api_error_response.dart';

/// JWT 인증 인터셉터
///
/// 모든 API 요청에 Access Token을 자동으로 주입하고,
/// 401 응답 시 Refresh Token으로 자동 재발급을 시도합니다.
///
/// **동작 흐름**:
/// 1. `onRequest`: Authorization 헤더에 Bearer Token 주입
/// 2. `onError` (401): refreshToken으로 `/api/auth/reissue` 호출
///    - 성공: 새 토큰 저장 → 원래 요청 재시도
///    - 실패: 토큰 삭제 → 강제 로그아웃 콜백 실행
class AuthInterceptor extends Interceptor {
  final SecureTokenStorage _tokenStorage;
  final Dio _dio;

  /// 강제 로그아웃 콜백
  ///
  /// 토큰 재발급 실패 시 호출됩니다.
  /// Presentation Layer에서 Firebase 로그아웃 + 로그인 화면 이동을 처리합니다.
  final Future<void> Function() onForceLogout;

  /// 토큰 재발급 중복 방지 Lock
  bool _isRefreshing = false;

  /// 토큰 재발급 대기 큐
  ///
  /// 재발급 진행 중 들어온 401 요청들을 대기시키고,
  /// 재발급 완료 후 일괄 재시도합니다.
  final List<_RetryRequest> _pendingRequests = [];

  AuthInterceptor({
    required SecureTokenStorage tokenStorage,
    required Dio dio,
    required this.onForceLogout,
  }) : _tokenStorage = tokenStorage,
       _dio = dio;

  // ============================================
  // 토큰 자동 주입을 제외할 경로
  // ============================================

  /// 인증 토큰이 불필요한 API 경로
  static const List<String> _publicPaths = [
    ApiEndpoints.login,
    ApiEndpoints.reissue,
    ApiEndpoints.checkNickname, // 닉네임 중복 확인 (인증 불필요)
  ];

  /// 해당 경로가 인증 불필요한 공개 API인지 확인
  bool _isPublicPath(String path) {
    return _publicPaths.any((publicPath) => path == publicPath);
  }

  // ============================================
  // Interceptor Overrides
  // ============================================

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 공개 API는 토큰 주입 생략
    if (_isPublicPath(options.path)) {
      return handler.next(options);
    }

    // Access Token 주입
    final accessToken = await _tokenStorage.getAccessToken();
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 401이 아니면 그대로 전달
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // reissue API 자체가 401이면 강제 로그아웃
    if (err.requestOptions.path.contains(ApiEndpoints.reissue)) {
      await _handleForceLogout();
      return handler.next(err);
    }

    // 공개 API의 401은 토큰 재발급 대상이 아님
    if (_isPublicPath(err.requestOptions.path)) {
      return handler.next(err);
    }

    // 이미 재시도한 요청이 다시 401이면 무한 루프 방지 → 강제 로그아웃
    if (err.requestOptions.extra['_isRetry'] == true) {
      await _handleForceLogout();
      return handler.next(err);
    }

    // 토큰 재발급 시도
    if (_isRefreshing) {
      // 이미 재발급 진행 중이면 대기 큐에 추가
      final completer = Completer<Response>();
      _pendingRequests.add(
        _RetryRequest(requestOptions: err.requestOptions, completer: completer),
      );
      try {
        final response = await completer.future;
        return handler.resolve(response);
      } catch (e) {
        return handler.next(err);
      }
    }

    // 재발급 시작
    _isRefreshing = true;

    try {
      final refreshToken = await _tokenStorage.getRefreshToken();

      if (refreshToken == null) {
        // Refresh Token이 없으면 강제 로그아웃
        await _handleForceLogout();
        return handler.next(err);
      }

      // /api/auth/reissue 호출
      final response = await _dio.post(
        ApiEndpoints.reissue,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final tokens = response.data['tokens'] as Map<String, dynamic>?;
        final newAccessToken = tokens?['accessToken'] as String?;
        final newRefreshToken = tokens?['refreshToken'] as String?;

        if (newAccessToken == null || newRefreshToken == null) {
          if (kDebugMode) {
            debugPrint('❌ 토큰 재발급 응답 파싱 실패: tokens=$tokens');
          }
          await _handleForceLogout();
          _rejectPendingRequests(err);
          return handler.next(err);
        }

        // 새 토큰 저장
        await _tokenStorage.saveTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        );

        if (kDebugMode) {
          debugPrint('🔄 토큰 재발급 성공');
        }

        // 대기 중인 요청들 재시도
        _retryPendingRequests(newAccessToken);

        // 원래 요청 재시도
        final retryResponse = await _retryRequest(
          err.requestOptions,
          newAccessToken,
        );
        return handler.resolve(retryResponse);
      } else {
        // 재발급 실패
        await _handleForceLogout();
        _rejectPendingRequests(err);
        return handler.next(err);
      }
    } catch (e) {
      if (kDebugMode) {
        if (e is DioException) {
          final apiError = ApiErrorResponse.tryParse(e.response?.data);
          if (apiError != null) {
            debugPrint('❌ 토큰 재발급 실패 [${apiError.status}]');
            debugPrint('   title: ${apiError.title}');
            debugPrint('   detail: ${apiError.detail}');
            debugPrint('   instance: ${apiError.instance}');
          } else {
            debugPrint('❌ 토큰 재발급 실패: $e');
          }
        } else {
          debugPrint('❌ 토큰 재발급 실패: $e');
        }
      }
      await _handleForceLogout();
      _rejectPendingRequests(err);
      return handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }

  // ============================================
  // Private Methods
  // ============================================

  /// 원래 요청을 새 토큰으로 재시도
  ///
  /// [_isRetry] extra 플래그를 설정하여 재시도 요청이
  /// 다시 401을 받을 경우 무한 루프를 방지합니다.
  Future<Response> _retryRequest(
    RequestOptions requestOptions,
    String newAccessToken,
  ) async {
    requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
    requestOptions.extra['_isRetry'] = true;
    return await _dio.fetch(requestOptions);
  }

  /// 대기 중인 요청들을 새 토큰으로 재시도
  void _retryPendingRequests(String newAccessToken) {
    for (final request in _pendingRequests) {
      _retryRequest(request.requestOptions, newAccessToken)
          .then((response) => request.completer.complete(response))
          .catchError((e) => request.completer.completeError(e));
    }
    _pendingRequests.clear();
  }

  /// 대기 중인 요청들을 에러로 거부
  void _rejectPendingRequests(DioException err) {
    for (final request in _pendingRequests) {
      request.completer.completeError(err);
    }
    _pendingRequests.clear();
  }

  /// 강제 로그아웃 처리
  ///
  /// 토큰 삭제 후 콜백을 통해 Firebase 로그아웃 및 화면 이동을 수행합니다.
  Future<void> _handleForceLogout() async {
    if (kDebugMode) {
      debugPrint('🚨 강제 로그아웃 실행');
    }
    await _tokenStorage.clearTokens();
    await onForceLogout();
  }
}

/// 토큰 재발급 대기 요청
class _RetryRequest {
  final RequestOptions requestOptions;
  final Completer<Response> completer;

  _RetryRequest({required this.requestOptions, required this.completer});
}
