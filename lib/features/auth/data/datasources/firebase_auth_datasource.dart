import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/foundation.dart';

/// Firebase Authentication DataSource
///
/// Firebase Auth와 Google Sign-In을 직접 호출하여
/// 인증 처리를 수행합니다.
class FirebaseAuthDataSource {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final Future<String> Function() _requestAppleAuthorizationCode;

  FirebaseAuthDataSource({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    Future<String> Function()? requestAppleAuthorizationCode,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn(),
       _requestAppleAuthorizationCode =
           requestAppleAuthorizationCode ?? _appleAuthorizationCode;

  /// Firebase Auth State Stream (GoRouter 감지용)
  Stream<User?> authStateChanges() {
    return _firebaseAuth.authStateChanges();
  }

  /// Google 로그인 수행
  ///
  /// Returns: Firebase [UserCredential]
  /// Throws: [FirebaseAuthException], [Exception]
  Future<UserCredential> signInWithGoogle() async {
    try {
      // 1. Google Sign-In 실행
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // 2. 사용자가 취소한 경우
      if (googleUser == null) {
        throw FirebaseAuthException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Sign in aborted by user',
        );
      }

      // 3. 인증 정보 획득
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 4. Firebase Credential 생성
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 5. Firebase Auth 로그인
      final UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(credential);

      // 6. 디버그 콘솔 출력
      _printDebugInfo(userCredential, googleAuth);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ FirebaseAuthException: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ Google Sign-In Error: $e');
      rethrow;
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    try {
      await Future.wait([_firebaseAuth.signOut(), _googleSignIn.signOut()]);
      debugPrint('✅ Sign out success');
    } catch (e) {
      debugPrint('❌ Sign out error: $e');
      rethrow;
    }
  }

  /// 현재 사용자 가져오기
  User? get currentUser => _firebaseAuth.currentUser;

  /// 현재 사용자의 Firebase ID Token 가져오기
  ///
  /// [forceRefresh]가 true이면 캐시를 무시하고 새 토큰을 요청합니다.
  /// 토큰은 자동으로 만료되기 전에 갱신됩니다 (약 1시간 유효).
  ///
  /// Returns: Firebase ID Token (백엔드 API 인증용)
  /// Throws: [FirebaseAuthException] 사용자가 로그인하지 않은 경우
  Future<String> getIdToken({bool forceRefresh = false}) async {
    try {
      final User? user = _firebaseAuth.currentUser;

      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'No user is currently signed in',
        );
      }

      final String? idToken = await user.getIdToken(forceRefresh);

      if (idToken == null) {
        throw FirebaseAuthException(
          code: 'token-not-available',
          message: 'Failed to retrieve Firebase ID Token',
        );
      }
      if (kDebugMode) {
        debugPrint('🔥 Firebase ID Token length: ${idToken.length}');
      }

      return idToken;
    } catch (e) {
      debugPrint('❌ Failed to get Firebase ID Token: $e');
      rethrow;
    }
  }

  /// Apple 로그인 수행
  ///
  /// Returns: Firebase [UserCredential]
  /// Throws: [FirebaseAuthException], [SignInWithAppleAuthorizationException], [Exception]
  Future<UserCredential> signInWithApple() async {
    try {
      // 1. Apple Sign-In 실행
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // 2. Firebase Credential 생성
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // 3. Firebase Auth 로그인
      final UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(oauthCredential);

      // 4. 디버그 콘솔 출력
      _printAppleDebugInfo(userCredential, appleCredential);

      return userCredential;
    } on SignInWithAppleAuthorizationException catch (e) {
      debugPrint(
        '❌ Apple SignIn Authorization Error: ${e.code} - ${e.message}',
      );

      // 사용자 취소 시 Firebase 에러 코드로 변환
      // - canceled: 명시적 취소
      // - unknown (1000): iOS에서 사용자 취소 시 발생하는 일반적인 에러
      if (e.code == AuthorizationErrorCode.canceled ||
          e.code == AuthorizationErrorCode.unknown) {
        throw FirebaseAuthException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Sign in aborted by user',
        );
      }
      rethrow;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ FirebaseAuthException: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ Apple Sign-In Error: $e');
      rethrow;
    }
  }

  /// 현재 Firebase 계정이 Apple 로그인 계정인지 여부
  bool get isAppleUser =>
      _firebaseAuth.currentUser?.providerData.any(
        (info) => info.providerId == 'apple.com',
      ) ??
      false;

  /// Apple 토큰 철회
  ///
  /// 로그인 때 받은 authorizationCode는 저장하지 않으므로 Apple 인증을 다시 받습니다.
  ///
  /// **주의**: Firebase 계정이 있어야 철회할 수 있어 백엔드 탈퇴 전에 호출해야 합니다.
  ///
  /// Throws: [FirebaseAuthException], [SignInWithAppleAuthorizationException], [Exception]
  Future<void> revokeAppleToken() async {
    try {
      final authorizationCode = await _requestAppleAuthorizationCode();
      await _firebaseAuth.revokeTokenWithAuthorizationCode(authorizationCode);
    } on SignInWithAppleAuthorizationException catch (e) {
      debugPrint('❌ Apple Token Revoke Error: ${e.code} - ${e.message}');

      // signInWithApple과 같은 기준으로 사용자 취소를 구분한다
      if (e.code == AuthorizationErrorCode.canceled ||
          e.code == AuthorizationErrorCode.unknown) {
        throw FirebaseAuthException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Apple token revocation aborted by user',
        );
      }
      rethrow;
    }
  }

  static Future<String> _appleAuthorizationCode() async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: const [],
    );
    return credential.authorizationCode;
  }

  /// 디버그 정보 출력 (Google)
  void _printDebugInfo(
    UserCredential userCredential,
    GoogleSignInAuthentication googleAuth,
  ) {
    if (kDebugMode) {
      debugPrint('========================================');
      debugPrint('🔐 Firebase Google Login Success');
      debugPrint('========================================');
      debugPrint('📧 Email: ${userCredential.user?.email}');
      debugPrint('🆔 UID: ${userCredential.user?.uid}');
      debugPrint('👤 DisplayName: ${userCredential.user?.displayName}');
      debugPrint('🖼️ PhotoURL: ${userCredential.user?.photoURL}');
      debugPrint('🎫 Google ID Token length: ${googleAuth.idToken?.length}');
      debugPrint(
        '🔄 Google Access Token length: ${googleAuth.accessToken?.length}',
      );
      debugPrint('========================================');
    }
  }

  /// Apple 로그인 디버그 정보 출력
  void _printAppleDebugInfo(
    UserCredential userCredential,
    AuthorizationCredentialAppleID appleCredential,
  ) {
    if (kDebugMode) {
      debugPrint('========================================');
      debugPrint('🍎 Firebase Apple Login Success');
      debugPrint('========================================');
      debugPrint('📧 Email: ${userCredential.user?.email}');
      debugPrint('🆔 UID: ${userCredential.user?.uid}');
      debugPrint('👤 DisplayName: ${userCredential.user?.displayName}');
      debugPrint('🖼️ PhotoURL: ${userCredential.user?.photoURL}');
      debugPrint(
        '🎫 Apple ID Token length: ${appleCredential.identityToken?.length}',
      );
      debugPrint(
        '🔄 Apple Auth Code length: ${appleCredential.authorizationCode.length}',
      );
      debugPrint('========================================');
    }
  }
}
