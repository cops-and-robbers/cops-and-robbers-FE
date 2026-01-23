import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

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
      case 'firebase-api-key-invalid':
        return 'Firebase 설정에 문제가 있습니다. 잠시 후 다시 시도해주세요.';
      case 'internal-error':
        return 'Firebase 내부 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
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
    String errorCode = e.code;

    // API 키 에러 감지
    if (e.code == 'internal-error' && _isApiKeyError(e)) {
      errorCode = 'firebase-api-key-invalid';

      // 개발 모드에서만 상세 정보 출력
      if (kDebugMode) {
        debugPrint('🔥 Firebase API Key 에러 감지');
        debugPrint('  - Error Code: ${e.code}');
        debugPrint('  - Message: ${e.message}');
        debugPrint('  - 조치 방법:');
        debugPrint('    1. Firebase Console에서 API 키 상태 확인');
        debugPrint('    2. google-services.json (Android) 재다운로드');
        debugPrint('       위치: android/app/google-services.json');
        debugPrint('    3. GoogleService-Info.plist (iOS) 재다운로드');
        debugPrint('       위치: ios/Runner/GoogleService-Info.plist');
        debugPrint(
          '  - Firebase Console: https://console.firebase.google.com/',
        );
      }
    }

    return AuthException(
      message: customMessage ?? getErrorMessage(errorCode, provider: provider),
      code: errorCode,
      originalException: e,
    );
  }

  /// FirebaseAuthException이 API 키 관련 에러인지 확인
  ///
  /// internal-error 중에서 API_KEY_INVALID reason을 가진 에러만 감지합니다.
  ///
  /// [e]: Firebase에서 발생한 원본 예외
  ///
  /// Returns: API 키 에러 여부
  static bool _isApiKeyError(FirebaseAuthException e) {
    final message = e.message?.toLowerCase() ?? '';
    return message.contains('api key') || message.contains('api_key_invalid');
  }
}
