import '../widgets/tutorial/tutorial_script.dart';

/// 게임 모드 (서버 값: COPS_AND_ROBBERS / TAG)
enum GameMode {
  copsAndRobbers,
  hideAndSeek,

  /// 이 앱이 모르는 모드 — 강제 업데이트 안내용. 서버로 보내지 않는다.
  unknown;

  /// 모드 필드가 없는 구버전 서버 응답은 경찰과 도둑으로 본다.
  static GameMode fromJson(String? value) => switch (value) {
    null || 'COPS_AND_ROBBERS' => copsAndRobbers,
    'TAG' => hideAndSeek,
    _ => unknown,
  };

  String toJson() {
    assert(this != unknown, 'unknown 모드는 서버로 보내지 않는다');
    return this == hideAndSeek ? 'TAG' : 'COPS_AND_ROBBERS';
  }

  bool get usesJail => this == copsAndRobbers;

  bool get isSupported => this != unknown;

  TutorialMode get tutorialMode =>
      this == hideAndSeek ? TutorialMode.tag : TutorialMode.classic;
}
