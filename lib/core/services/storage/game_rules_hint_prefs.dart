import 'package:shared_preferences/shared_preferences.dart';

/// "규칙은 오른쪽 위 ⓘ에서 다시 볼 수 있어요" 안내를 이 기기에서 봤는지.
///
/// 계정이 아니라 기기 기준이다 — 화면 구성을 알려 주는 안내라 로그인과 무관하다.
class GameRulesHintPrefs {
  GameRulesHintPrefs._();

  static const _key = 'game_rules_hint_seen';

  static Future<bool> seen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  static Future<void> markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }
}
