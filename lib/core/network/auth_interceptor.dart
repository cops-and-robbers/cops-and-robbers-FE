import 'dart:async';
import 'dart:developer' as developer;

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
/// [QueuedInterceptor]를 사용하여 async 작업(토큰 조회, 재발급)이
/// 완료될 때까지 후속 요청을 큐에 대기시킵니다.
/// 일반 [Interceptor]는 async void 문제로 토큰 주입 전에 요청이 전송될 수 있습니다.
///
/// **동작 흐름**:
/// 1. `onRequest`: Authorization 헤더에 Bearer Token 주입
/// 2. `onError` (401): refreshToken으로 `/api/auth/reissue` 호출
///    - 성공: 새 토큰 저장 → 원래 요청 재시도
///    - 실패: 토큰 삭제 → 강제 로그아웃 콜백 실행
class AuthInterceptor extends QueuedInterceptor {
  final SecureTokenStorage _tokenStorage;

  /// 토큰 재발급 및 재시도 전용 Dio (인터셉터 없음)
  ///
  /// reissue API 호출 시 AuthInterceptor를 타지 않도록
  /// 별도의 plain Dio 인스턴스를 사용합니다.
  /// 이를 통해 reissue 401 시 이중 강제 로그아웃 방지.
  final Dio _plainDio;

  /// 강제 로그아웃 콜백
  ///
  /// 토큰 재발급 실패 시 호출됩니다.
  /// Presentation Layer에서 Firebase 로그아웃 + 로그인 화면 이동을 처리합니다.
  /// [messageKey]: 사유 식별자 — login_page에서 errorByKey로 i18n 변환하여 스낵바 표시
  final Future<void> Function({String? messageKey}) onForceLogout;

  AuthInterceptor({
    required SecureTokenStorage tokenStorage,
    required Dio plainDio,
    required this.onForceLogout,
  }) : _tokenStorage = tokenStorage,
       _plainDio = plainDio;

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
  // QueuedInterceptor Overrides
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
      final apiError = ApiErrorResponse.tryParse(err.response?.data);
      // errorCode로 정확한 원인을 파악해 messageKey 결정 — 백엔드 한국어 detail 대신 i18n 키 전달
      await _handleForceLogout(messageKey: _reissueMessageKey(apiError));
      return handler.next(err);
    }

    // 공개 API의 401은 토큰 재발급 대상이 아님
    if (_isPublicPath(err.requestOptions.path)) {
      return handler.next(err);
    }

    // 이미 재시도한 요청이 다시 401이면 무한 루프 방지 → 강제 로그아웃
    // 재시도 후에도 인증 거부 = 토큰이 유효하지 않음
    if (err.requestOptions.extra['_isRetry'] == true) {
      await _handleForceLogout(messageKey: 'errorAuthExpired');
      return handler.next(err);
    }

    final refreshToken = await _tokenStorage.getRefreshToken();

    if (refreshToken == null || refreshToken.trim().isEmpty) {
      // Refresh Token이 없으면 강제 로그아웃 (세션 만료와 동일한 UX)
      await _handleForceLogout(messageKey: 'errorAuthExpired');
      return handler.next(err);
    }

    final Response<dynamic> response;
    try {
      response = await _plainDio.post(
        ApiEndpoints.reissue,
        data: {'refreshToken': refreshToken},
      );
    } catch (e) {
      _logReissueFailure(e);
      if (_isRefreshTokenRejected(e)) {
        // 서버가 명시적으로 refresh token을 거부(400/401/403) — 재시도해도 소용 없음
        await _handleForceLogout(messageKey: 'errorAuthExpired');
        return handler.next(err);
      }

      if (kDebugMode) {
        debugPrint('ℹ️ [Reissue] 일시 실패로 판단하여 토큰을 유지합니다.');
      }
      _logTransientReissueFailure(originalError: err, reissueError: e);
      return handler.next(
        e is DioException ? _asOriginalRequestError(e, err) : err,
      );
    }

    if (kDebugMode) {
      debugPrint('🔑 [Reissue] 응답 수신: statusCode=${response.statusCode}');
      debugPrint('   responseData: ${response.data}');
    }

    if (response.statusCode != 200) {
      if (_shouldForceLogoutForReissueStatus(response.statusCode)) {
        // 400/401/403 — reissue 서버가 거부한 케이스. 재시도해도 동일한 결과일 가능성 높음
        await _handleForceLogout(messageKey: 'errorAuthExpired');
      }
      return handler.next(err);
    }

    final tokens = _parseTokens(response.data);
    if (tokens == null) {
      if (kDebugMode) {
        debugPrint('❌ 토큰 재발급 응답 파싱 실패: responseData=${response.data}');
      }
      // 200이지만 토큰 형식이 잘못됨 → 서버 응답 이상, 일시 오류로 안내
      await _handleForceLogout(messageKey: 'errorTemporaryRetry');
      return handler.next(err);
    }

    // 새 토큰 저장
    await _tokenStorage.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );

    if (kDebugMode) {
      debugPrint('🔄 토큰 재발급 성공');
    }

    try {
      final retryResponse = await _retryRequest(
        err.requestOptions,
        tokens.accessToken,
      );
      return handler.resolve(retryResponse);
    } catch (e) {
      if (_isAccessTokenRejected(e)) {
        // 새 토큰으로 재시도했는데도 401 — access token 자체가 무효
        await _handleForceLogout(messageKey: 'errorAuthExpired');
      }
      return handler.next(e is DioException ? e : err);
    }
  }

  // ============================================
  // Private Methods
  // ============================================

  /// 원래 요청을 새 토큰으로 재시도
  ///
  /// [_plainDio]를 사용하여 QueuedInterceptor 큐 교착 상태를 방지합니다.
  /// _plainDio에는 AuthInterceptor가 없으므로 무한 루프 위험 없음.
  Future<Response> _retryRequest(
    RequestOptions requestOptions,
    String newAccessToken,
  ) async {
    final retryOptions = requestOptions.copyWith(
      headers: {
        ...requestOptions.headers,
        'Authorization': 'Bearer $newAccessToken',
      },
    );
    return await _plainDio.fetch(retryOptions);
  }

  _ReissuedTokens? _parseTokens(dynamic data) {
    if (data is! Map<String, dynamic>) return null;

    final tokens = data['tokens'];
    if (tokens is! Map<String, dynamic>) return null;

    final accessToken = tokens['accessToken'];
    final refreshToken = tokens['refreshToken'];
    if (accessToken is! String || refreshToken is! String) return null;
    if (accessToken.trim().isEmpty || refreshToken.trim().isEmpty) return null;

    return _ReissuedTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  void _logReissueFailure(Object error) {
    if (kDebugMode) {
      if (error is DioException) {
        debugPrint('❌ [Reissue] 토큰 재발급 실패');
        debugPrint('   statusCode: ${error.response?.statusCode}');
        debugPrint('   responseData: ${error.response?.data}');
        debugPrint('   requestURL: ${error.requestOptions.uri}');
        debugPrint('   requestData: ${error.requestOptions.data}');
        final apiError = ApiErrorResponse.tryParse(error.response?.data);
        if (apiError != null) {
          debugPrint('   RFC7807 title: ${apiError.title}');
          debugPrint('   RFC7807 errorCode: ${apiError.errorCode}');
          debugPrint('   RFC7807 detail: ${apiError.detail}');
          debugPrint('   RFC7807 instance: ${apiError.instance}');
        }
      } else {
        debugPrint('❌ [Reissue] 토큰 재발급 실패 (non-Dio): $error');
      }
    }
  }

  void _logTransientReissueFailure({
    required DioException originalError,
    required Object reissueError,
  }) {
    final statusCode = reissueError is DioException
        ? reissueError.response?.statusCode
        : null;
    final type = reissueError is DioException ? reissueError.type.name : null;

    developer.log(
      'Transient token reissue failure; keeping stored tokens. '
      'originalPath=${originalError.requestOptions.path}, '
      'reissueStatus=$statusCode, reissueType=$type',
      name: 'AuthInterceptor',
      error: reissueError,
      stackTrace: reissueError is DioException ? reissueError.stackTrace : null,
    );
  }

  DioException _asOriginalRequestError(
    DioException reissueError,
    DioException originalError,
  ) {
    return DioException(
      requestOptions: originalError.requestOptions,
      response: reissueError.response,
      type: reissueError.type,
      error: reissueError.error,
      stackTrace: reissueError.stackTrace,
      message: reissueError.message,
    );
  }

  /// refresh token이 서버에서 명시적으로 거부된 경우만 강제 로그아웃한다.
  ///
  /// 네트워크 단절/타임아웃/서버 일시 장애는 refresh token 만료와 다르므로
  /// 토큰을 삭제하면 안 된다. 해당 요청만 실패로 전달하고 다음 요청에서
  /// 재발급을 다시 시도하도록 둔다.
  bool _isRefreshTokenRejected(Object error) {
    if (error is! DioException) return false;
    return _shouldForceLogoutForReissueStatus(error.response?.statusCode);
  }

  bool _shouldForceLogoutForReissueStatus(int? statusCode) {
    // 현재 reissue API spec은 400/401/500만 정의하지만,
    // 403은 refresh token 명시 거부로 해석 가능한 방어 분기로 유지한다.
    return statusCode == 400 || statusCode == 401 || statusCode == 403;
  }

  bool _isAccessTokenRejected(Object error) {
    if (error is! DioException) return false;
    return error.response?.statusCode == 401;
  }

  /// reissue 에러 응답을 분석해 강제 로그아웃 messageKey를 결정합니다.
  ///
  /// 토큰 관련 errorCode → 세션 만료 키, 그 외 → 일시 오류 키로 매핑.
  String _reissueMessageKey(ApiErrorResponse? apiError) {
    switch (apiError?.errorCode) {
      case 'REFRESH_TOKEN_EXPIRED':
      case 'ACCESS_TOKEN_EXPIRED':
      case 'INVALID_TOKEN':
        return 'errorAuthExpired';
      default:
        return 'errorTemporaryRetry';
    }
  }

  /// 강제 로그아웃 처리
  ///
  /// 토큰 삭제 후 콜백을 통해 Firebase 로그아웃 및 화면 이동을 수행합니다.
  /// [messageKey]: 로그인 화면에서 errorByKey로 i18n 변환해 스낵바로 표시할 식별자
  Future<void> _handleForceLogout({String? messageKey}) async {
    if (kDebugMode) {
      debugPrint(
        '🚨 강제 로그아웃 실행${messageKey != null ? ' (사유키: $messageKey)' : ''}',
      );
    }
    await _tokenStorage.clearTokens();
    await onForceLogout(messageKey: messageKey);
  }
}

class _ReissuedTokens {
  const _ReissuedTokens({
    required this.accessToken,
    required this.refreshToken,
  });

  final String accessToken;
  final String refreshToken;
}
