/// 게임 팀 식별자 (서버 API enum: POLICE / ROBBER)
///
/// 서버는 대문자로 내려주지만, 에셋 경로 등은 소문자 키를 쓰므로
/// 대소문자 혼재 비교를 [isPolice]/[isRobber]로, 소문자 변환을 [toLowerKey]로 중앙화한다.
class GameTeam {
  GameTeam._();

  static const String police = 'POLICE';
  static const String robber = 'ROBBER';

  /// 대소문자 무관하게 경찰 팀인지 판정 (null 안전)
  static bool isPolice(String? value) => value?.toUpperCase() == police;

  /// 대소문자 무관하게 도둑 팀인지 판정 (null 안전)
  static bool isRobber(String? value) => value?.toUpperCase() == robber;

  /// 에셋 경로 등 소문자 키 생성용
  static String toLowerKey(String value) => value.toLowerCase();
}
