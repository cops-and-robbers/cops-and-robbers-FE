import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/datasources/firebase_auth_datasource.dart';
import 'auth_provider.dart';

part 'token_provider.g.dart';

/// 토큰 제공자 인터페이스
///
/// 서버 JWT 기반 인증으로 전환 시 이 인터페이스를 통해
/// accessToken/refreshToken을 획득합니다.
///
/// 현재는 Firebase ID Token을 사용하며,
/// 추후 서버 로그인 연동 시 구현체를 교체할 예정입니다.
abstract class TokenProvider {
  /// Access Token 획득
  ///
  /// 유효한 토큰이 없으면 null을 반환합니다.
  /// STOMP 연결 시 Authorization 헤더에 사용됩니다.
  Future<String?> getAccessToken();

  /// Refresh Token 획득
  ///
  /// 현재 단계에서는 사용하지 않습니다 (null 반환).
  /// 서버 JWT 도입 시 토큰 갱신에 사용됩니다.
  Future<String?> getRefreshToken();

  /// Access Token 갱신 시도
  ///
  /// 토큰이 만료되었거나 401 응답을 받았을 때 호출합니다.
  /// 갱신 성공 시 새 accessToken을, 실패 시 null을 반환합니다.
  ///
  /// null 반환 시 호출자는 재로그인 필요 상태로 처리해야 합니다.
  Future<String?> refreshAccessTokenIfNeeded();
}

/// Firebase 기반 TokenProvider 임시 구현
///
/// 현재 프로젝트는 Firebase ID Token을 사용하므로,
/// Firebase의 getIdToken을 위임합니다.
///
/// TODO:
/// 서버 로그인(/api/auth/login) 연동 후 ServerTokenProvider로 교체 예정.
/// - accessToken: 서버 발급 JWT
/// - refreshToken: 서버 발급 Refresh Token
/// - TokenStorage 도입하여 secure storage에 토큰 저장
class FirebaseTokenProvider implements TokenProvider {
  final FirebaseAuthDataSource _authDataSource;

  FirebaseTokenProvider(this._authDataSource);

  @override
  Future<String?> getAccessToken() async {
    // TODO:
    // 서버 로그인 기능 구현 후 accessToken을 여기서 가져오도록 연결 필요.
    // 현재는 Firebase ID Token을 accessToken 대용으로 사용.
    try {
      final token = await _authDataSource.getIdToken();
      return token;
    } catch (e) {
      debugPrint('[TokenProvider] ❌ getAccessToken 실패: $e');
      return null;
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    // TODO:
    // 서버 JWT 도입 시 TokenStorage에서 refreshToken 조회.
    // 현재는 Firebase가 내부적으로 토큰을 관리하므로 null 반환.
    return null;
  }

  @override
  Future<String?> refreshAccessTokenIfNeeded() async {
    // TODO:
    // 서버 JWT 도입 시 refresh API 호출 후 새 accessToken 반환.
    // 현재는 Firebase의 forceRefresh를 사용하여 토큰 갱신.
    try {
      final token = await _authDataSource.getIdToken(forceRefresh: true);
      debugPrint('[TokenProvider] ✅ 토큰 갱신 성공');
      return token;
    } catch (e) {
      debugPrint('[TokenProvider] ❌ 토큰 갱신 실패: $e');
      return null;
    }
  }
}

/// TokenProvider Provider
///
/// 현재는 FirebaseTokenProvider를 사용합니다.
/// 서버 JWT 도입 시 ServerTokenProvider로 교체 예정.
@riverpod
TokenProvider tokenProvider(Ref ref) {
  // TODO:
  // 서버 로그인 연동 후 ServerTokenProvider로 교체.
  // 예: return ServerTokenProvider(ref.watch(tokenStorageProvider));
  final authDataSource = ref.watch(firebaseAuthDataSourceProvider);
  return FirebaseTokenProvider(authDataSource);
}
