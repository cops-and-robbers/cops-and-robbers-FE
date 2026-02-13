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

  /// 게임 소켓 연결 URL (STOMP over WebSocket)
  ///
  /// 채팅, 게임 이벤트 등 실시간 통신에 사용됩니다.
  /// .env의 WS_URL을 직접 사용합니다.
  ///
  static String get gameConnectionUrl => wsUrl;

  /// Mock API 사용 여부 (.env에서 로드)
  /// Whether to use Mock API (loaded from .env)
  ///
  /// **기본값**: `true`
  /// **Default**: `true`
  static bool get useMockApi =>
      dotenv.env['USE_MOCK_API']?.toLowerCase() == 'true';

  // ============================================
  // Auth API - 소셜 로그인 및 토큰 관리
  // ============================================

  /// 소셜 로그인
  static const String login = '/api/auth/login';

  /// 로그아웃
  static const String logout = '/api/auth/logout';

  /// 토큰 재발급
  static const String reissue = '/api/auth/reissue';

  // ============================================
  // Game API - 게임 방 생성 및 관리
  // ============================================

  /// 게임 방 생성
  static const String createGame = '/api/games';

  // ============================================
  // Game Participant API - 게임 참여자 관리
  // ============================================

  /// 게임 방 참여
  static String joinGame(int gameId) => '/api/games/$gameId/participants';

  /// 게임 방 퇴장
  static String leaveGame(int gameId) => '/api/games/$gameId/participants';

  // ============================================
  // Lobby API - 게임 로비 상태 변경
  // ============================================

  /// 로비 팀 변경
  static String changeTeam(int gameId) => '/api/games/$gameId/lobby/team';

  /// 로비 준비 상태 변경
  static String updateReady(int gameId) => '/api/games/$gameId/lobby/ready';

  /// 게임 시작 (방장만 가능)
  static String startGame(int gameId) => '/api/games/$gameId/lobby/start';

  // ============================================
  // System API - 게임 시스템 상호작용
  // ============================================

  /// 도둑 체포 (경찰만)
  static String arrestRobber(int gameId) => '/api/games/$gameId/system/arrest';

  /// 도둑 탈옥 (수감된 도둑만)
  static String escapeFromPrison(int gameId) =>
      '/api/games/$gameId/system/escape';

  // ============================================
  // User API - 사용자 정보
  // ============================================

  /// 내 정보 조회
  static const String myPage = '/api/user/me';

  /// 닉네임 변경
  static const String updateNickname = '/api/user/me/nickname';

  /// 닉네임 중복 확인
  static const String checkNickname = '/api/user/check-nickname';
}
