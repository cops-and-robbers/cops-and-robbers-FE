import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/storage/secure_token_storage.dart';

part 'token_provider.g.dart';

/// 토큰 제공자 인터페이스
///
/// SecureTokenStorage에서 서버 발급 JWT를 제공합니다.
abstract class TokenProvider {
  /// Access Token 획득
  ///
  /// 유효한 토큰이 없으면 null을 반환합니다.
  /// STOMP 연결 시 Authorization 헤더에 사용됩니다.
  Future<String?> getAccessToken();

  /// Access Token 갱신 시도
  ///
  /// 토큰이 만료되었거나 401 응답을 받았을 때 호출합니다.
  /// 갱신 성공 시 새 accessToken을, 실패 시 null을 반환합니다.
  ///
  /// null 반환 시 호출자는 재로그인 필요 상태로 처리해야 합니다.
  Future<String?> refreshAccessTokenIfNeeded();
}

/// 서버 JWT 기반 TokenProvider 구현
///
/// SecureTokenStorage에서 서버 발급 JWT를 조회합니다.
/// 토큰 갱신은 AuthInterceptor에서 처리하므로,
/// 여기서는 저장된 토큰을 반환만 합니다.
class ServerTokenProvider implements TokenProvider {
  final SecureTokenStorage _tokenStorage;

  ServerTokenProvider(this._tokenStorage);

  @override
  Future<String?> getAccessToken() async {
    try {
      final token = await _tokenStorage.getAccessToken();
      if (token == null) {
        debugPrint('[TokenProvider] ⚠️ 저장된 accessToken 없음');
      }
      return token;
    } catch (e) {
      debugPrint('[TokenProvider] ❌ getAccessToken 실패: $e');
      return null;
    }
  }

  @override
  Future<String?> refreshAccessTokenIfNeeded() async {
    // 토큰 갱신은 AuthInterceptor에서 자동으로 처리됨.
    // STOMP 401 에러 시에는 현재 저장된 토큰을 다시 가져옴.
    // (AuthInterceptor가 이미 갱신했을 수 있음)
    try {
      final token = await _tokenStorage.getAccessToken();
      if (token != null) {
        debugPrint('[TokenProvider] ✅ 갱신된 토큰 조회 성공');
      }
      return token;
    } catch (e) {
      debugPrint('[TokenProvider] ❌ 토큰 갱신 조회 실패: $e');
      return null;
    }
  }
}

/// TokenProvider Provider
///
/// SecureTokenStorage에서 서버 JWT를 제공합니다.
@riverpod
TokenProvider tokenProvider(Ref ref) {
  final tokenStorage = ref.watch(secureTokenStorageProvider);
  return ServerTokenProvider(tokenStorage);
}
