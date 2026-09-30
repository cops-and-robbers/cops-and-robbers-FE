import '../../../core/constants/participant_status.dart';

/// 도둑이 지금 수감 중인지.
///
/// 소켓 이벤트가 API 응답보다 먼저 오므로 로컬 체포·탈옥 집합을 서버 status 위에 얹는다.
/// 탈옥이 체포·서버 JAILED보다 우선한다 — 참가자 목록과 잠금 화면이 같은 정의를 쓴다.
bool isRobberJailed({
  required int participantId,
  required String serverStatus,
  required Set<int> arrestedIds,
  required Set<int> escapedIds,
}) {
  if (escapedIds.contains(participantId)) return false;
  return arrestedIds.contains(participantId) ||
      serverStatus == ParticipantStatus.jailed;
}

/// 도주 중(수감 아님) 도둑 수. [robberStatuses]는 participantId → 서버 status.
int countAliveRobbers({
  required Map<int, String> robberStatuses,
  required Set<int> arrestedIds,
  required Set<int> escapedIds,
}) {
  return robberStatuses.entries
      .where(
        (e) => !isRobberJailed(
          participantId: e.key,
          serverStatus: e.value,
          arrestedIds: arrestedIds,
          escapedIds: escapedIds,
        ),
      )
      .length;
}
