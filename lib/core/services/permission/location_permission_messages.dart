import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 위치 권한 다이얼로그 사용 컨텍스트
enum LocationPermissionContext {
  home('home'),
  game('game'),
  waitingRoom('waiting_room');

  const LocationPermissionContext(this.jsonKey);

  /// JSON 파일 내 키
  final String jsonKey;
}

/// 위치 권한 다이얼로그 메시지 (title + message)
class LocationPermissionDialogText {
  const LocationPermissionDialogText({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;
}

/// 위치 권한 다이얼로그 메시지 서비스
///
/// `assets/messages/location_permission_messages.json`에서 메시지를 로드합니다.
/// 최초 호출 시 1회 로드 후 메모리에 캐싱합니다.
class LocationPermissionMessages {
  LocationPermissionMessages._();

  static Map<String, dynamic>? _cache;

  /// 위치 서비스 꺼짐 / 권한 미허용에 따른 다이얼로그 텍스트 반환
  static Future<LocationPermissionDialogText> getText({
    required bool isServiceDisabled,
    required LocationPermissionContext context,
  }) async {
    _cache ??= await _load();

    final key = isServiceDisabled ? 'service_disabled' : 'permission_denied';
    final section = _cache?[key] as Map<String, dynamic>?;

    final title = section?['title'] as String? ?? '위치 권한 안내';
    final message = section?[context.jsonKey] as String? ?? '위치 권한을 허용해주세요.';

    return LocationPermissionDialogText(title: title, message: message);
  }

  /// 버튼 텍스트 반환
  static Future<String> getButtonText(String key) async {
    _cache ??= await _load();
    final buttons = _cache?['buttons'] as Map<String, dynamic>?;
    return buttons?[key] as String? ?? key;
  }

  /// JSON 파일 로드
  static Future<Map<String, dynamic>> _load() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/messages/location_permission_messages.json',
      );
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('[LocationPermissionMessages] JSON 로드 실패: $e');
      return {};
    }
  }
}
