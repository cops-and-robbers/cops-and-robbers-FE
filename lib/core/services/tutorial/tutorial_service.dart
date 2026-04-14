import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'tutorial_keys.dart';

/// 튜토리얼 리셋 신호 (설정에서 초기화 시 tick 증가 → 각 페이지가 감지해 재노출)
final tutorialResetSignalProvider = StateProvider<int>((ref) => 0);

/// 화면별 튜토리얼 완료 상태를 SharedPreferences로 관리
class TutorialService {
  TutorialService._();

  /// 해당 화면의 튜토리얼을 완료했는지 확인
  static Future<bool> isCompleted(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false;
  }

  /// 해당 화면의 튜토리얼을 완료 처리
  static Future<void> markCompleted(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, true);
  }

  /// 모든 튜토리얼 초기화 (설정 페이지에서 호출)
  static Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in TutorialKeys.all) {
      await prefs.remove(key);
    }
  }
}
