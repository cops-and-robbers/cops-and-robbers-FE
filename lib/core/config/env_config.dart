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

  // ─── Feature Flags ────────────────────────────────────────────────────────

  /// 딥링크 초대 공유 기능 노출 여부.
  ///
  /// 백엔드 .well-known/* 호스팅 검증 완료 전엔 false(기본값).
  /// 활성화: `.env` 에 `SHOW_INVITE_DEEPLINK_SHARING=true` 설정.
  /// 영향: 대기실 공유 버튼 노출 + QR 인코딩 데이터를 풀 URL 로 전환.
  static bool get showInviteDeeplinkSharing {
    final value = dotenv.env['SHOW_INVITE_DEEPLINK_SHARING']?.toLowerCase();
    return value == 'true' || value == '1';
  }

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
