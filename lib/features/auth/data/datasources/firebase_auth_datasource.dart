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

  FirebaseAuthDataSource({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn();

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
      debugPrint('🔥 Firebase ID Token : $idToken)');
      debugPrint('🔥 Firebase ID Token length: ${idToken.length})');

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

  /// 디버그 정보 출력 (Google)
  void _printDebugInfo(
    UserCredential userCredential,
    GoogleSignInAuthentication googleAuth,
  ) {
    debugPrint('========================================');
    debugPrint('🔐 Firebase Google Login Success');
    debugPrint('========================================');
    debugPrint('📧 Email: ${userCredential.user?.email}');
    debugPrint('🆔 UID: ${userCredential.user?.uid}');
    debugPrint('👤 DisplayName: ${userCredential.user?.displayName}');
    debugPrint('🖼️ PhotoURL: ${userCredential.user?.photoURL}');
    debugPrint('🎫 Google ID Token: ${googleAuth.idToken}');
    debugPrint('🎫 Google ID Token length : ${googleAuth.idToken?.length}');

    debugPrint(
      '🔄 Google Access Token: ${googleAuth.accessToken?.substring(0, 20)}...',
    );
    debugPrint('========================================');
  }

  /// Apple 로그인 디버그 정보 출력
  void _printAppleDebugInfo(
    UserCredential userCredential,
    AuthorizationCredentialAppleID appleCredential,
  ) {
    debugPrint('========================================');
    debugPrint('🍎 Firebase Apple Login Success');
    debugPrint('========================================');
    debugPrint('📧 Email: ${userCredential.user?.email}');
    debugPrint('🆔 UID: ${userCredential.user?.uid}');
    debugPrint('👤 DisplayName: ${userCredential.user?.displayName}');
    debugPrint('🖼️ PhotoURL: ${userCredential.user?.photoURL}');
    debugPrint('🎫 Apple ID Token: ${appleCredential.identityToken}');
    debugPrint(
      '🎫 Apple ID Token length: ${appleCredential.identityToken?.length}',
    );
    debugPrint(
      '🔄 Apple Auth Code: ${appleCredential.authorizationCode.substring(0, 20)}...',
    );
    debugPrint('========================================');
  }
}
