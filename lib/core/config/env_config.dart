/// 환경 변수 설정 및 feature flag 관리
library;

import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 환경 변수 설정 및 feature flag 클래스
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

  /// 백엔드 API 기본 URL. 환경변수 `API_BASE_URL` 미설정 시 `http://localhost:8080`.
  static String get apiBaseUrl {
    return dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';
  }

  /// WebSocket 연결 URL. 환경변수 `WS_URL` 미설정 시 `ws://localhost:8080/ws`.
  static String get webSocketUrl {
    return dotenv.env['WS_URL'] ?? 'ws://localhost:8080/ws';
  }
}
