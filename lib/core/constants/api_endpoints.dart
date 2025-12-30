import 'package:flutter_dotenv/flutter_dotenv.dart';

/// API 엔드포인트 중앙 관리
/// Centralized API Endpoint Management
///
/// 환경 변수(.env)를 통해 설정 관리
/// Configuration managed via environment variables (.env)
///
/// **사용 가능한 환경 변수**:
/// - `API_BASE_URL`: 백엔드 API Base URL
/// - `WS_URL`: WebSocket 연결 URL
/// - `USE_MOCK_API`: Mock API 사용 여부 (true/false)
class ApiEndpoints {
  // Private 생성자 - 인스턴스화 방지
  // Private constructor to prevent instantiation
  ApiEndpoints._();

  // ============================================
  // Base URL (환경 변수에서 로드)
  // Base URL (loaded from environment variables)
  // ============================================

  /// API Base URL (.env에서 로드)
  /// API Base URL (loaded from .env)
  ///
  /// **기본값**: `http://localhost:8080`
  /// **Default**: `http://localhost:8080`
  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';

  /// WebSocket URL (.env에서 로드)
  /// WebSocket URL (loaded from .env)
  ///
  /// **기본값**: `ws://localhost:8080/ws`
  /// **Default**: `ws://localhost:8080/ws`
  static String get wsUrl => dotenv.env['WS_URL'] ?? 'ws://localhost:8080/ws';

  /// Mock API 사용 여부 (.env에서 로드)
  /// Whether to use Mock API (loaded from .env)
  ///
  /// **기본값**: `true`
  /// **Default**: `true`
  static bool get useMockApi =>
      dotenv.env['USE_MOCK_API']?.toLowerCase() == 'true';

  // ============================================
  // 참고: 구체적인 API 엔드포인트
  // Note: Specific API Endpoints
  // ============================================
  //
  // 백엔드 API가 정의되면 아래와 같은 형태로 추가 예정:
  // Will be added in the following format once backend API is defined:
  //
  // static const String googleLogin = '/auth/google';
  // static const String refreshToken = '/auth/refresh';
  // static const String createSession = '/api/sessions';
  // static String getSession(String sessionId) => '/api/sessions/$sessionId';
  //
  // 현재는 백엔드 정의 전이므로 빈 상태로 유지
  // Currently kept empty until backend is defined
}
