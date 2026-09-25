import 'package:cops_and_robbers/core/constants/game_status.dart';
import 'package:cops_and_robbers/features/session/domain/entities/user_game_status_entity.dart';
import 'package:cops_and_robbers/router/route_paths.dart';
import 'package:go_router/go_router.dart';

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

/// 게임·대기실 화면이 스택에 살아 있는지 — 맨 위 화면만 보지 않는다.
///
/// 게임 중 다른 화면이 얹힌 뒤 그 화면이 `go`로 스택을 갈아엎으면 GamePage가
/// dispose되며 소켓·백그라운드 위치가 끊긴다. 그래서 게임 위에 무엇이 떠 있든
/// 아래에 게임·대기실이 있으면 게임 중으로 본다. 앱은 게임·대기실에 항상 `go`로
/// 들어가므로 둘은 스택 최상위 match에 있다.
// ponytail: 최상위 match만 본다 — 게임·대기실을 push로 여는 곳이 생기면
// ImperativeRouteMatch 안까지 훑어야 한다.
bool isInGameFlow(RouteMatchList stack) => stack.matches.any((match) {
  final route = match.route;
  return route is GoRoute &&
      (route.name == RoutePaths.gameName ||
          route.name == RoutePaths.waitingRoomName);
});
