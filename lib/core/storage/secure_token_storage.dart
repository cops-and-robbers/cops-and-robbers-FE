import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'secure_token_storage.g.dart';

/// JWT 토큰 보안 저장소
///
/// flutter_secure_storage를 활용하여 Access Token과 Refresh Token을
/// 안전하게 저장합니다.
///
/// **사용 예시**:
/// ```dart
/// final storage = SecureTokenStorage();
///
/// // 토큰 저장
/// await storage.saveTokens(accessToken: 'abc', refreshToken: 'xyz');
///
/// // 토큰 조회
/// final access = await storage.getAccessToken();
/// final refresh = await storage.getRefreshToken();
///
/// // 전체 삭제
/// await storage.clearTokens();
/// ```
class SecureTokenStorage {
  final FlutterSecureStorage _storage;

  SecureTokenStorage({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
          );

  // ============================================
  // Storage Keys
  // ============================================

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _isNewUserKey = 'is_new_user';

  // ============================================
  // Token 저장
  // ============================================

  /// Access Token과 Refresh Token을 동시에 저장
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: accessToken),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
    ]);
    if (kDebugMode) {
      debugPrint('✅ 토큰 저장 완료 (accessToken length: ${accessToken.length})');
    }
  }

  /// 사용자 ID 저장
  ///
  /// 로그인 성공 시 백엔드에서 반환한 userId를 저장합니다.
  /// 앱 재시작 시 AuthNotifier에서 복원에 사용됩니다.
  Future<void> saveUserId(int userId) async {
    await _storage.write(key: _userIdKey, value: userId.toString());
  }

  /// 신규 회원 여부 저장
  ///
  /// 로그인 성공 시 백엔드 응답의 `isNewUser`를 저장합니다.
  /// 앱 재시작 시 cold-start 경로에서 복원되어 닉네임 설정 플로우 유지에 사용됩니다.
  /// 닉네임 설정 완료 시 `false`로 갱신됩니다.
  Future<void> saveIsNewUser(bool value) async {
    await _storage.write(key: _isNewUserKey, value: value ? 'true' : 'false');
  }

  // ============================================
  // Token 조회
  // ============================================

  /// Access Token 조회
  ///
  /// 저장된 토큰이 없으면 null 반환
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  /// Refresh Token 조회
  ///
  /// 저장된 토큰이 없으면 null 반환
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// 사용자 ID 조회
  ///
  /// 저장된 userId가 없으면 null 반환
  Future<int?> getUserId() async {
    final value = await _storage.read(key: _userIdKey);
    return value != null ? int.tryParse(value) : null;
  }

  /// 신규 회원 여부 조회
  ///
  /// 저장된 값이 없거나 `'true'`가 아닌 경우 false를 반환합니다.
  /// fail-safe 설계: 예외적 상황에서도 항상 false로 폴백 (기존 유저로 취급).
  Future<bool> getIsNewUser() async {
    final value = await _storage.read(key: _isNewUserKey);
    return value == 'true';
  }

  // ============================================
  // Token 삭제
  // ============================================

  /// 모든 토큰 삭제
  ///
  /// 로그아웃, 강제 로그아웃 시 호출
  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
      _storage.delete(key: _userIdKey),
      _storage.delete(key: _isNewUserKey),
    ]);
    if (kDebugMode) {
      debugPrint('✅ 토큰 삭제 완료');
    }
  }

  /// 토큰 존재 여부 확인
  Future<bool> hasTokens() async {
    final accessToken = await getAccessToken();
    return accessToken != null;
  }

  // ============================================
  // 재설치 감지 및 Keychain 초기화 (iOS)
  // ============================================

  static const String _freshInstallKey = 'has_run_before';

  /// 앱 재설치 시 이전 토큰을 삭제
  ///
  /// iOS에서는 앱을 삭제해도 Keychain 데이터가 남아있어
  /// 재설치 시 만료된 토큰으로 인증을 시도할 수 있습니다.
  /// Android에서는 앱 삭제 시 EncryptedSharedPreferences도 함께 삭제되므로
  /// 실질적으로 no-op이지만, 플랫폼 분기 없이 동일하게 처리합니다.
  /// SharedPreferences는 양 플랫폼 모두 앱 삭제 시 제거되므로
  /// 플래그 부재 = 신규 설치로 판단하여 토큰을 초기화합니다.
  Future<void> clearTokensIfReinstalled() async {
    final prefs = await SharedPreferences.getInstance();
    final hasRunBefore = prefs.getBool(_freshInstallKey) ?? false;

    if (!hasRunBefore) {
      await clearTokens();
      await prefs.setBool(_freshInstallKey, true);
      if (kDebugMode) {
        debugPrint('🔄 재설치 감지 — Keychain 토큰 초기화 완료');
      }
    }
  }
}

/// SecureTokenStorage Provider
///
/// 앱 생애주기 동안 유지 (keepAlive) — 인터셉터 콜백에서 안전하게 접근 가능
@Riverpod(keepAlive: true)
SecureTokenStorage secureTokenStorage(Ref ref) {
  return SecureTokenStorage();
}
