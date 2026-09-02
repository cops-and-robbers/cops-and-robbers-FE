import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'community_recent_keyword_storage.g.dart';

/// 커뮤니티 검색의 최근 검색어 로컬 영속화.
///
/// 기기에만 남고 서버로 보내지 않는다 — 남에게 노출되는 값이 아니라 UGC
/// 안전장치(필터·신고·차단) 대상이 아니다.
///
/// 문자열 목록 하나라 `setStringList`로 충분하다. JSON으로 감쌀 구조가 없다.
class CommunityRecentKeywordStorage {
  static const String _key = 'community_recent_keywords';

  /// 최대 보관 개수. 넘으면 오래된 것부터 버린다.
  static const int _limit = 10;

  /// 최근 검색어를 최신순으로 돌려준다. 없으면 빈 목록.
  Future<List<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? const [];
  }

  /// 검색어를 맨 앞에 넣는다. 이미 있으면 거기서 빼고 앞으로 올린다 —
  /// 같은 말을 두 번 검색했다고 목록에 두 줄이 남으면 안 된다.
  Future<void> add(String keyword) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_key) ?? const <String>[];
    final next = [
      keyword,
      for (final each in current)
        if (each != keyword) each,
    ].take(_limit).toList();
    await prefs.setStringList(_key, next);
  }

  /// 검색어 하나를 뺀다 (목록의 ✕).
  Future<void> remove(String keyword) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_key) ?? const <String>[];
    await prefs.setStringList(_key, [
      for (final each in current)
        if (each != keyword) each,
    ]);
  }

  /// 전부 지운다 (모두 삭제).
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

/// 최근 검색어 저장소 Provider
///
/// SharedPreferences는 시스템 경계라 여기서 한 번 갈라 둔다 — 테스트는 이
/// provider만 갈아끼우면 플랫폼 채널을 건드리지 않는다.
@riverpod
CommunityRecentKeywordStorage communityRecentKeywordStorage(Ref ref) =>
    CommunityRecentKeywordStorage();
