/// Failure 클래스 (Either 패턴용)
/// Failure class for Either pattern
///
/// Repository 및 Use Case에서 에러를 표현하는데 사용됩니다.
/// Used to represent errors in Repository and Use Case.
abstract class Failure {
  /// 에러 메시지
  /// Error message
  final String message;

  const Failure(this.message);

  @override
  String toString() => '$runtimeType: $message';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure &&
        other.runtimeType == runtimeType &&
        other.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}

/// 네트워크 실패
/// Network failure
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// 서버 실패
/// Server failure
class ServerFailure extends Failure {
  /// HTTP 상태 코드
  /// HTTP status code
  final int? statusCode;

  const ServerFailure(super.message, {this.statusCode});

  @override
  String toString() {
    if (statusCode != null) {
      return 'ServerFailure [$statusCode]: $message';
    }
    return 'ServerFailure: $message';
  }
}

/// 검증 실패
/// Validation failure
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// 인증 실패
/// Authentication failure
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// 권한 실패
/// Permission failure
class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

/// 캐시 실패
/// Cache failure
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// WebSocket 실패
/// WebSocket failure
class WebSocketFailure extends Failure {
  const WebSocketFailure(super.message);
}

/// 위치 서비스 실패
/// Location service failure
class LocationFailure extends Failure {
  const LocationFailure(super.message);
}

/// 게임 로직 실패
/// Game logic failure
class GameFailure extends Failure {
  const GameFailure(super.message);
}

/// 알 수 없는 실패
/// Unknown failure
class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}
