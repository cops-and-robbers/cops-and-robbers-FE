import 'package:shared_preferences/shared_preferences.dart';

/// 앱 소개(온보딩)를 이 기기에서 봤는지 여부.
///
/// 계정이 아니라 **기기**의 문제다 — 온보딩은 "이 앱이 뭐 하는 앱인지"라서
/// 로그인 상태와 무관하고, 로그아웃해도 초기화하지 않는다. 앱을 지우면
/// `SharedPreferences`도 함께 사라지므로 "설치 후 1회"가 그대로 성립한다.
class OnboardingPrefs {
  OnboardingPrefs._();

  static const _key = 'onboarding_seen';

  static Future<bool> seen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  static Future<void> markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }
}
