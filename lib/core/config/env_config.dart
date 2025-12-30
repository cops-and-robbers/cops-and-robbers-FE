/// 환경 변수 설정 관리
library;

import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 환경 변수 설정 클래스
///
/// 사용 예시:
/// ```dart
/// await EnvConfig.initialize();
/// final apiUrl = EnvConfig.apiBaseUrl;
/// ```
class EnvConfig {
  EnvConfig._();

  /// .env 파일 초기화 (main()에서 호출 필수)
  static Future<void> initialize() async {
    await dotenv.load(fileName: '.env');
  }

  // API URL
  static String get apiBaseUrl {
    return dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';
  }

  // WebSocket URL
  static String get webSocketUrl {
    return dotenv.env['WS_URL'] ?? 'ws://localhost:8080/ws';
  }

  // Mock API 사용 여부
  static bool get useMockApi {
    final value = dotenv.env['USE_MOCK_API']?.toLowerCase();
    return value == 'true' || value == '1';
  }
}
