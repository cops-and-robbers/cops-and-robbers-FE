import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

/// 로딩 메시지 카테고리
///
/// `assets/messages/loading_messages.json`의 키와 1:1 매핑됩니다.
enum LoadingCategory {
  joinRoom('join_room'),
  createRoom('create_room'),
  changeTeam('change_team'),
  startGame('start_game'),
  updateArea('update_area'),
  saveSettings('save_settings'),
  loadProfile('load_profile'),
  logout('logout'),
  deleteAccount('delete_account'),
  reconnect('reconnect'),
  bugReport('bug_report');

  const LoadingCategory(this.jsonKey);

  /// JSON 파일 내 키
  final String jsonKey;
}

/// 카테고리별 랜덤 로딩 메시지 제공 서비스
///
/// `assets/messages/loading_messages.json`에서 메시지를 로드하고 캐싱합니다.
/// 최초 호출 시 1회 로드 후 메모리에 유지합니다.
///
/// ```dart
/// final message = await LoadingMessageService.getMessage(LoadingCategory.joinRoom);
/// // → "잠입 준비 중..." (랜덤)
/// ```
class LoadingMessageService {
  LoadingMessageService._();

  static Map<String, List<String>>? _cache;
  static final _random = Random();

  /// 카테고리에 해당하는 랜덤 메시지 반환
  ///
  /// JSON 미로드 시 자동으로 로드합니다.
  /// 카테고리가 없거나 로드 실패 시 [fallback]을 반환합니다.
  static Future<String> getMessage(
    LoadingCategory category, {
    String fallback = '처리 중...',
  }) async {
    _cache ??= await _load();

    final messages = _cache?[category.jsonKey];
    if (messages == null || messages.isEmpty) return fallback;
    return messages[_random.nextInt(messages.length)];
  }

  /// JSON 파일 로드
  static Future<Map<String, List<String>>> _load() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/messages/loading_messages.json',
      );
      final Map<String, dynamic> raw = jsonDecode(jsonString);
      return raw.map((key, value) => MapEntry(key, List<String>.from(value)));
    } catch (_) {
      return {};
    }
  }
}
