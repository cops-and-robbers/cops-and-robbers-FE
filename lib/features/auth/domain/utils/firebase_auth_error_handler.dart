import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/errors/app_exception.dart';

/// Firebase Authentication 에러를 처리하는 유틸리티 클래스
///
/// FirebaseAuthException을 사용자 친화적인 메시지로 변환하고
/// [AuthException]으로 래핑하는 기능을 제공합니다.
///
/// 사용 예시:
/// ```dart
/// try {
///   await _firebaseAuth.signInWithCredential(credential);
/// } on FirebaseAuthException catch (e) {
///   throw FirebaseAuthErrorHandler.createAuthException(e);
/// }
/// ```
class FirebaseAuthErrorHandler {
  FirebaseAuthErrorHandler._();

  /// Firebase 에러 코드를 사용자 친화적 메시지로 변환
  ///
  /// [errorCode]: Firebase 에러 코드
  /// [provider]: 로그인 제공자 이름 (선택적, 에러 메시지 커스터마이징용)
  ///
  /// Returns: 사용자 친화적인 에러 메시지
  static String getErrorMessage(String errorCode, {String? provider}) {
    switch (errorCode) {
      case 'user-not-found':
        return '로그인 정보를 가져올 수 없습니다. 다시 시도해주세요.';
      case 'token-not-available':
        return '인증 토큰 발급에 실패했습니다. 다시 시도해주세요.';
      case 'token-validation-failed':
        return 'Firebase 인증 토큰 검증에 실패했습니다. 다시 로그인해주세요.';
      case 'ERROR_ABORTED_BY_USER':
        return '로그인이 취소되었습니다.';
      case 'network-request-failed':
        return '네트워크 연결을 확인해주세요.';
      case 'invalid-credential':
        return '잘못된 인증 정보입니다.';
      case 'user-disabled':
        return '비활성화된 계정입니다.';
      case 'too-many-requests':
        return '너무 많은 요청이 발생했습니다. 잠시 후 다시 시도해주세요.';
      case 'operation-not-allowed':
        return '이 로그인 방법은 현재 사용할 수 없습니다.';
      default:
        // 제공자별 기본 메시지 커스터마이징
        if (provider != null) {
          return '$provider 로그인에 실패했습니다. 다시 시도해주세요.';
        }
        return '로그인에 실패했습니다. 다시 시도해주세요.';
    }
  }

  /// FirebaseAuthException을 AuthException으로 변환
  ///
  /// [e]: Firebase에서 발생한 원본 예외
  /// [customMessage]: 커스텀 에러 메시지 (선택적, 없으면 에러 코드 기반 메시지 사용)
  /// [provider]: 로그인 제공자 이름 (선택적, 에러 메시지 커스터마이징용)
  ///
  /// Returns: 변환된 [AuthException]
  static AuthException createAuthException(
    FirebaseAuthException e, {
    String? customMessage,
    String? provider,
  }) {
    return AuthException(
      message: customMessage ?? getErrorMessage(e.code, provider: provider),
      code: e.code,
      originalException: e,
    );
  }
}
