import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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

  /// Access Token만 저장
  Future<void> saveAccessToken(String accessToken) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
  }

  /// Refresh Token만 저장
  Future<void> saveRefreshToken(String refreshToken) async {
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  /// 사용자 ID 저장
  ///
  /// 로그인 성공 시 백엔드에서 반환한 userId를 저장합니다.
  /// 앱 재시작 시 AuthNotifier에서 복원에 사용됩니다.
  Future<void> saveUserId(int userId) async {
    await _storage.write(key: _userIdKey, value: userId.toString());
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
}
