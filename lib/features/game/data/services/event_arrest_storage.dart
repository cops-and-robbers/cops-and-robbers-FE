import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'event_arrest_storage.g.dart';

/// 이벤트 게임 — 경찰이 검거한 운영진(도둑) ID 로컬 영속화.
///
/// 단일 레코드(키 1개)에 `{gameId, arrestedRobberIds}`를 저장한다.
/// 같은 gameId 재진입 시 복원, 다른 gameId면 빈 집합(자동 리셋).
/// 기기(=경찰)별 저장이라 경찰 간 공유되지 않는다.
class EventArrestStorage {
  static const String _key = 'event_game_arrest';

  /// 저장된 gameId가 현재 [gameId]와 같으면 검거 집합 복원, 아니면 빈 집합.
  ///
  /// 다른 게임/손상 레코드면 **제거**해 부활을 막는다(자동 리셋 보장).
  /// 이 제거 부수효과는 game_page 진입 시 loadMyArrests가 **체포 가능 시점 이전에
  /// await**되므로(§Task 9) 신규 체포 저장과 경쟁하지 않는다.
  Future<Set<int>> load(int gameId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        if ((map['gameId'] as num?)?.toInt() == gameId) {
          return (map['arrestedRobberIds'] as List<dynamic>? ?? const [])
              .map((e) => (e as num).toInt())
              .toSet();
        }
      } catch (_) {
        // 손상 레코드 → 아래에서 제거
      }
      // 다른 게임/손상 → 기존 레코드 제거(부활 방지)
      await prefs.remove(_key);
    }
    return <int>{};
  }

  /// 현재 [gameId] 기준으로 검거 집합을 덮어쓴다.
  Future<void> save(int gameId, Set<int> robberIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode({'gameId': gameId, 'arrestedRobberIds': robberIds.toList()}),
    );
  }
}

/// 앱 생애주기 동안 단일 인스턴스 유지.
@Riverpod(keepAlive: true)
EventArrestStorage eventArrestStorage(Ref ref) => EventArrestStorage();
