/// 앱 전역 예외 클래스
/// App Global Exception Class
///
/// 모든 커스텀 예외의 부모 클래스입니다.
/// Parent class for all custom exceptions.
abstract class AppException implements Exception {
  /// 에러 메시지
  /// Error message
  final String message;

  /// 에러 코드 (선택사항)
  /// Error code (optional)
  final String? code;

  /// 원인이 된 예외 (선택사항)
  /// Original exception (optional)
  final dynamic originalException;

  const AppException({
    required this.message,
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
    super.code,
    super.originalException,
  });
}

/// 인증 관련 예외
/// Authentication related exception
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code,
    super.originalException,
  });
}

/// 검증 관련 예외
/// Validation related exception
class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.code,
    super.originalException,
  });
}

/// 서버 관련 예외
/// Server related exception
class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.code,
    super.originalException,
  });
}

/// 데이터베이스 관련 예외
/// Database related exception
class DatabaseException extends AppException {
  const DatabaseException({
    required super.message,
    super.code,
    super.originalException,
  });
}

/// WebSocket 관련 예외
/// WebSocket related exception
class WebSocketException extends AppException {
  const WebSocketException({
    required super.message,
    super.code,
    super.originalException,
  });
}

/// 위치 서비스 관련 예외
/// Location service related exception
class LocationException extends AppException {
  const LocationException({
    required super.message,
    super.code,
    super.originalException,
  });
}

/// 게임 로직 관련 예외
/// Game logic related exception
class GameException extends AppException {
  const GameException({
    required super.message,
    super.code,
    super.originalException,
  });
}
