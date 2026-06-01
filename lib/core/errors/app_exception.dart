/// 앱 전역 예외 클래스
/// App Global Exception Class
///
/// 모든 커스텀 예외의 부모 클래스입니다.
/// Parent class for all custom exceptions.
abstract class AppException implements Exception {
  /// 에러 메시지 (로깅/디버깅용 폴백)
  /// Error message — used as fallback when [messageKey]가 없거나 i18n 매핑 실패 시
  final String message;

  /// 다국어 메시지 키 (ARB의 의미 기반 키)
  ///
  /// UI 레이어에서 [AppLocalizations]로 변환해 사용자에게 표시.
  /// 정적 클래스(예: DioExceptionHandler)에서는 BuildContext 없이 이 키만 결정하고,
  /// 위젯/Notifier 레이어에서 `errorMessageFromKey(l10n, exception.messageKey)`로 변환.
  /// 비어있으면 [message]를 그대로 표시 (i18n 미적용 레거시 코드 호환).
  final String? messageKey;

  /// 에러 코드 (선택사항)
  /// Error code (optional)
  ///
  /// `DioExceptionHandler`가 서버 응답으로 생성하는 경우 백엔드 errorCode(SCREAMING_SNAKE)를 담는다.
  /// Firebase/소셜 인증 흐름은 provider 에러 코드(kebab-case 등)를 담는다 — 의미가 경로별로 다르므로
  /// 사용자 노출 변환은 `error_message_mapper.shouldUseBackendErrorCode` 가드로 구분한다.
  final String? code;

  /// 원인이 된 예외 (선택사항)
  /// Original exception (optional)
  final dynamic originalException;

  const AppException({
    required this.message,
    this.messageKey,
    this.code,
    this.originalException,
  });

  @override
  String toString() {
    if (code != null) {
      return '$runtimeType [$code]: $message';
    }
    return '$runtimeType: $message';
  }
}

/// 네트워크 관련 예외
/// Network related exception
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.messageKey,
    super.code,
    super.originalException,
  });
}

/// 인증 관련 예외
/// Authentication related exception
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.messageKey,
    super.code,
    super.originalException,
  });
}

/// 사용자가 로그인을 취소한 경우
/// User cancelled the login process
class AuthCancelledException extends AuthException {
  const AuthCancelledException()
    : super(message: '로그인이 취소되었습니다', messageKey: 'errorAuthLoginCancelled');
}

/// 검증 관련 예외
/// Validation related exception
class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.messageKey,
    super.code,
    super.originalException,
  });
}

/// 서버 관련 예외
/// Server related exception
class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.messageKey,
    super.code,
    super.originalException,
  });
}

/// 데이터베이스 관련 예외
/// Database related exception
class DatabaseException extends AppException {
  const DatabaseException({
    required super.message,
    super.messageKey,
    super.code,
    super.originalException,
  });
}

/// WebSocket 관련 예외
/// WebSocket related exception
class WebSocketException extends AppException {
  const WebSocketException({
    required super.message,
    super.messageKey,
    super.code,
    super.originalException,
  });
}

/// 위치 서비스 관련 예외
/// Location service related exception
class LocationException extends AppException {
  const LocationException({
    required super.message,
    super.messageKey,
    super.code,
    super.originalException,
  });
}

/// 게임 로직 관련 예외
/// Game logic related exception
class GameException extends AppException {
  const GameException({
    required super.message,
    super.messageKey,
    super.code,
    super.originalException,
  });
}
