/// 게임 참가자 상태 (서버 API enum)
class ParticipantStatus {
  ParticipantStatus._();

  static const String alive = 'ALIVE';
  static const String jailed = 'JAILED';
  static const String policeWaiting = 'POLICE_WAITING';
}
