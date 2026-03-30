/// 채팅 관련 상수
///
/// 서버 API와 일치하는 scope/team 문자열을 중앙 관리합니다.
/// 매직 문자열 분산 사용으로 인한 오타·비교 오류를 방지합니다.
class ChatScope {
  ChatScope._();

  static const String all = 'ALL';
  static const String team = 'TEAM';
}

/// 채팅 시스템 메시지 발신자 팀 식별자
class ChatTeam {
  ChatTeam._();

  static const String system = 'SYSTEM';
  static const String police = 'POLICE';
  static const String robber = 'ROBBER';
}
