import 'package:cops_and_robbers/core/services/fcm/push_navigation_event.dart';
import 'package:cops_and_robbers/router/active_game_route.dart';
import 'package:cops_and_robbers/router/route_paths.dart';
import 'package:go_router/go_router.dart';

/// 앱이 살아 있을 때 푸시 알림을 탭하면 할 일. 판단만 여기서 하고 실행
/// (push·스낵바·provider 갱신)은 `main.dart`의 `_LocalizedApp`이 한다.
sealed class PushTapAction {
  const PushTapAction();
}

/// 이 경로를 루트 네비게이터에 push한다.
final class OpenPushRoute extends PushTapAction {
  const OpenPushRoute(this.location);
  final String location;
}

/// 게임·대기실을 지키려 이동하지 않고 안내만 한다.
final class BlockPushDuringGame extends PushTapAction {
  const BlockPushDuringGame();
}

/// 인게임 채팅 — 참가 상태를 확인해 GameChatPushListener가 연다.
final class HandOffGameChatPush extends PushTapAction {
  const HandOffGameChatPush(this.event);
  final GameChatPushEvent event;
}

/// 게임·대기실 위에 커뮤니티 화면을 얹으면, 그 화면이 `go`로 스택을 갈아엎는
/// 순간(강퇴·나가기·게시글 보기) GamePage가 dispose돼 소켓과 백그라운드 위치가
/// 끊긴다. 그래서 게임이 끝날 때까지 커뮤니티 알림으로는 이동하지 않는다.
PushTapAction resolvePushTap(PushNavigationEvent event, RouteMatchList stack) {
  if (event is GameChatPushEvent) return HandOffGameChatPush(event);
  if (isInGameFlow(stack)) return const BlockPushDuringGame();
  // 인게임 채팅 외 알림은 전부 목적지가 있다(pushDestination 테스트가 고정).
  return OpenPushRoute(pushDestination(event)!);
}

/// 알림이 여는 화면 경로 — 콜드 스타트(스플래시)도 같은 경로를 쓴다.
/// 채팅방은 상세의 하위 라우트라 `go`하면 상세가 아래에 깔려 뒤로가기가 상세로
/// 돌아간다. 인게임 채팅은 게임 복구 뒤 리스너가 참가 상태를 검증해 열어 경로가 없다.
String? pushDestination(PushNavigationEvent event) => switch (event) {
  CommunityPostPushEvent(:final postId) => RoutePaths.communityDetailWithId(
    postId,
  ),
  CommunityChatPushEvent(:final postId) => RoutePaths.communityChatWithId(
    postId,
  ),
  GameChatPushEvent() => null,
};
