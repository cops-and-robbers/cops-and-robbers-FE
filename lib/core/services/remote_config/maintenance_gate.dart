import 'dart:async';

import 'package:go_router/go_router.dart';

import '../../../router/route_paths.dart';

final RegExp _postEditPath = RegExp(r'^/community/[^/]+/edit$');
final RegExp _chatNoticeEditPath = RegExp(
  r'^/community/[^/]+/chat/notice/edit$',
);

/// 글을 쓰는 화면인지. 임시 저장이 없어 끊으면 쓰던 내용을 잃는다.
bool _isWritingPath(String path) =>
    path == RoutePaths.communityCreate ||
    path == RoutePaths.bugReport ||
    path == RoutePaths.reportReason ||
    _postEditPath.hasMatch(path) ||
    _chatNoticeEditPath.hasMatch(path);

/// 점검 상태에 따라 이동할 경로를 정한다. 이동이 필요 없으면 null.
///
/// [stack]은 아래부터 쌓인 화면 경로다. 게임 위에 신고 화면이 떠 있어도 게임이고,
/// 글쓰기 위에 다른 화면이 떠 있어도 쓰던 내용은 그대로라 쌓인 화면을 모두 본다.
///
/// - 점검이 켜지면 어느 화면이든 점검 화면으로 보낸다.
/// - 스플래시는 자체 판단이 있어 그대로 둔다.
/// - 게임과 글쓰기는 끊지 않고, 그 화면에서 나올 때 막는다.
/// - 점검이 꺼지면 점검 화면의 사용자를 스플래시로 돌려보낸다.
String? maintenanceRedirect({
  required List<String> stack,
  required bool underMaintenance,
}) {
  if (!underMaintenance) {
    return stack.last == RoutePaths.maintenance ? RoutePaths.splash : null;
  }
  final keepsScreen = stack.any(
    (path) =>
        path == RoutePaths.maintenance ||
        path == RoutePaths.splash ||
        path.startsWith(RoutePaths.gameWithId('')) ||
        _isWritingPath(path),
  );
  return keepsScreen ? null : RoutePaths.maintenance;
}

/// 게시된 점검 값을 실행 중인 앱의 화면에 반영한다.
///
/// 라우터의 redirect와 refresh로는 안 된다. redirect는 뒤로 가기에 돌지 않아 글쓰기에서
/// 나온 사용자를 놓치고, refresh는 push로 쌓인 화면의 extra와 결과 Future를 잃는다.
/// 그래서 화면 변화와 값 변화를 함께 보고, 막아야 할 때만 `go`로 스택을 바꾼다.
class MaintenanceGuard {
  MaintenanceGuard({
    required GoRouter router,
    required Stream<void> updates,
    required bool Function() isUnderMaintenance,
    required void Function() onWritingInterrupted,
  }) : _router = router,
       _isUnderMaintenance = isUnderMaintenance,
       _onWritingInterrupted = onWritingInterrupted {
    _router.routerDelegate.addListener(_apply);
    _subscription = updates.listen((_) => _apply());
  }

  final GoRouter _router;
  final bool Function() _isUnderMaintenance;
  final void Function() _onWritingInterrupted;
  late final StreamSubscription<void> _subscription;

  bool _moving = false;
  bool _writingNoticeShown = false;

  void _apply() {
    final configuration = _router.routerDelegate.currentConfiguration;
    if (_moving || configuration.isEmpty) return;

    final underMaintenance = _isUnderMaintenance();
    final stack = [
      configuration.uri.path,
      ..._pushedPaths(configuration.matches),
    ];
    if (!underMaintenance) {
      _writingNoticeShown = false;
    } else if (!_writingNoticeShown && stack.any(_isWritingPath)) {
      _writingNoticeShown = true;
      _onWritingInterrupted();
    }

    final target = maintenanceRedirect(
      stack: stack,
      underMaintenance: underMaintenance,
    );
    if (target == null) return;

    // 라우터가 알리는 중에 다시 이동하지 않도록 한 박자 미룬다.
    _moving = true;
    scheduleMicrotask(() {
      _moving = false;
      _router.go(target);
    });
  }

  Iterable<String> _pushedPaths(List<RouteMatchBase> matches) sync* {
    for (final match in matches) {
      if (match is ImperativeRouteMatch) {
        yield match.matches.uri.path;
      } else if (match is ShellRouteMatch) {
        yield* _pushedPaths(match.matches);
      }
    }
  }

  void dispose() {
    _router.routerDelegate.removeListener(_apply);
    unawaited(_subscription.cancel());
  }
}
