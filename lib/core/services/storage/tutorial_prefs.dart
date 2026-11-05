import 'package:shared_preferences/shared_preferences.dart';

import '../../widgets/tutorial/tutorial_script.dart';

/// 방 입장 튜토리얼을 이 기기에서 봤는지 여부. 모드마다 따로 기억한다.
///
/// 튜토리얼이 열리는 순간 저장한다. 어떻게 나가든 다음 입장 때 자동으로 뜨지 않는다.
class TutorialPrefs {
  TutorialPrefs._();

  static String _key(TutorialMode mode) => 'tutorial_seen_${mode.name}';

  static Future<bool> seen(TutorialMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key(mode)) ?? false;
  }

  static Future<void> markSeen(TutorialMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key(mode), true);
  }

  /// 방에 들어왔을 때 자동으로 띄울지. 이벤트 게임 대기방에는 띄우지 않는다.
  static Future<bool> shouldAutoOpen(
    TutorialMode mode, {
    required bool isEventGame,
  }) async {
    if (isEventGame) return false;
    return !await seen(mode);
  }
}

/// 한 방에서 튜토리얼을 자동으로 띄울지 판단한다.
///
/// 참가자 목록은 재연결마다 다시 읽으므로 한 번만 판단한다. 이미 ⓘ로 열었거나
/// 설정 화면 같은 다른 화면이 위에 있으면 띄우지 않는다.
class TutorialAutoOpen {
  bool _decided = false;

  void markOpened() => _decided = true;

  Future<bool> shouldOpen(
    TutorialMode mode, {
    required bool isEventGame,
    required bool Function() isTopRoute,
  }) async {
    if (_decided) return false;
    _decided = true;
    final shouldOpen = await TutorialPrefs.shouldAutoOpen(
      mode,
      isEventGame: isEventGame,
    );
    return shouldOpen && isTopRoute();
  }
}
