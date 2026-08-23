import 'package:cops_and_robbers/features/community/data/datasources/community_recent_keyword_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    // SharedPreferences는 시스템 경계다 — 인메모리 구현으로 갈아끼운다.
    SharedPreferences.setMockInitialValues({});
  });

  test('returns_empty_list_when_nothing_was_searched', () async {
    final storage = CommunityRecentKeywordStorage();

    expect(await storage.load(), isEmpty);
  });

  test('returns_newest_first_when_multiple_keywords_added', () async {
    final storage = CommunityRecentKeywordStorage();

    await storage.add('서울');
    await storage.add('광진구');

    expect(await storage.load(), ['광진구', '서울']);
  });

  test('moves_keyword_to_front_when_searched_again', () async {
    final storage = CommunityRecentKeywordStorage();

    await storage.add('서울');
    await storage.add('광진구');
    await storage.add('서울');

    // 중복으로 쌓이지 않고 맨 앞으로 올라온다.
    expect(await storage.load(), ['서울', '광진구']);
  });

  test('keeps_only_ten_most_recent_when_limit_exceeded', () async {
    final storage = CommunityRecentKeywordStorage();

    for (var i = 1; i <= 12; i++) {
      await storage.add('검색어$i');
    }

    final loaded = await storage.load();
    expect(loaded.length, 10);
    expect(loaded.first, '검색어12');
    expect(loaded.last, '검색어3');
  });

  test('drops_only_the_given_keyword_when_removed', () async {
    final storage = CommunityRecentKeywordStorage();
    await storage.add('서울');
    await storage.add('광진구');

    await storage.remove('서울');

    expect(await storage.load(), ['광진구']);
  });

  test('returns_empty_list_when_cleared', () async {
    final storage = CommunityRecentKeywordStorage();
    await storage.add('서울');

    await storage.clear();

    expect(await storage.load(), isEmpty);
  });
}
