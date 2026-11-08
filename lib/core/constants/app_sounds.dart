/// 효과음 에셋 경로 상수
///
/// `assets/sounds/` 아래 효과음 경로를 한곳에 모은다. 호출부는 경로 리터럴 대신
/// 이 클래스를 참조한다(`AppIcons`와 같은 구조).
/// 새 효과음은 `assets/sounds/`에 파일을 넣고 여기에 상수를 한 줄 추가한다.
abstract final class AppSounds {
  /// 출동 사이렌 2.0초 — "출동!"에 시작해 원형 열기(start_flow `dispatchGoHold` +
  /// `dispatchIrisDuration` = 2.2초)가 끝나기 조금 전에 잦아들게 앞 2.0초만 자르고
  /// 끝 0.3초를 줄였다(실기기로 들어 보고 정한 길이). 두 값을 바꾸면 이 파일도 다시
  /// 자른다. 원본: OpenGameArt "Sirens and Alarm Noise"(aquinn, CC0)
  static const String siren = 'assets/sounds/siren.mp3';
}
