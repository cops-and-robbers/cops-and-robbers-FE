import 'package:cops_and_robbers/core/constants/game_status.dart';
import 'package:cops_and_robbers/features/session/domain/entities/user_game_status_entity.dart';
import 'package:cops_and_robbers/router/route_paths.dart';

/// 활성 게임 참여 정보를 복귀 라우트 경로로 변환한다.
///
/// 로그인 후 복귀, 딥링크 중복 참가 등 "현재 참여 중인 게임으로 돌려보내야 하는"
/// 여러 진입점이 동일한 매핑을 필요로 해 한 곳에 모은다.
/// 알 수 없는 상태면 null 을 반환하므로, 호출자가 홈 등으로 폴백한다.
String? activeGameRoute(UserGameParticipationEntity info) {
  return switch (info.gameStatus) {
    GameStatus.waiting => RoutePaths.waitingRoomWithId(info.gameId.toString()),
    GameStatus.inProgress =>
      '${RoutePaths.gameWithId(info.gameId.toString())}'
          '?team=${info.team}&pid=${info.participantId}',
    _ => null,
  };
}
