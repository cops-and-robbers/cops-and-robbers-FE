import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/game_status.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/i18n/error_message_mapper.dart';
import '../../../../core/services/fcm/push_navigation_service.dart';
import '../../../../core/widgets/snackbars/app_snackbar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../router/active_game_route.dart';
import '../../../../router/route_paths.dart';
import '../../../auth/domain/entities/auth_result_entity.dart';
import '../../../session/presentation/providers/session_provider.dart';

/// Splash/인증의 최종 이동 뒤에 채팅을 연다. 진행 중인 게임 화면은 재생성하지 않는다.
class GameChatPushListener extends ConsumerStatefulWidget {
  const GameChatPushListener({
    required this.router,
    required this.auth,
    required this.child,
    super.key,
  });

  final GoRouter router;
  final AsyncValue<AuthResultEntity?> auth;
  final Widget child;

  @override
  ConsumerState<GameChatPushListener> createState() =>
      _GameChatPushListenerState();
}

class _GameChatPushListenerState extends ConsumerState<GameChatPushListener> {
  bool _scheduled = false;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    widget.router.routerDelegate.addListener(_schedule);
    ref.listenManual(
      pendingGameChatPushProvider,
      (_, _) => _schedule(),
      fireImmediately: true,
    );
  }

  @override
  void didUpdateWidget(GameChatPushListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.router != widget.router) {
      oldWidget.router.routerDelegate.removeListener(_schedule);
      widget.router.routerDelegate.addListener(_schedule);
    }
    if (oldWidget.auth != widget.auth || oldWidget.router != widget.router) {
      _schedule();
    }
  }

  void _schedule() {
    // mounted만으로 오래된 HTTP 응답을 막을 수 없어 경로·인증·새 탭으로 무효화한다.
    _generation++;
    if (_scheduled) return;
    _scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      if (mounted) _openChat();
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  Future<void> _openChat() async {
    final generation = _generation;
    final event = ref.read(pendingGameChatPushProvider);
    final user = widget.auth.valueOrNull;
    if (widget.auth.isLoading ||
        user == null ||
        user.isNewUser ||
        user.requiresAgreement) {
      ref.read(openGameChatPushProvider.notifier).state = null;
      return;
    }
    if (event == null) return;
    final path = widget.router.routerDelegate.currentConfiguration.uri.path;
    if ({
      RoutePaths.splash,
      RoutePaths.login,
      RoutePaths.agreement,
      RoutePaths.nicknameSetup,
      RoutePaths.onboarding,
      RoutePaths.maintenance,
      RoutePaths.forceUpdate,
    }.contains(path)) {
      return;
    }

    try {
      final status = await ref.read(getMyActiveGameUsecaseProvider).execute();
      if (!mounted || generation != _generation) return;
      final info = status.participationInfo;
      ref.read(pendingGameChatPushProvider.notifier).state = null;
      if (!status.isParticipating ||
          info == null ||
          info.gameId != event.gameId ||
          info.gameStatus != GameStatus.inProgress) {
        _showMessage(AppLocalizations.of(context).gameChatPushUnavailable);
        return;
      }
      ref.read(openGameChatPushProvider.notifier).state = event;
      if (path != RoutePaths.gameWithId(info.gameId.toString())) {
        widget.router.go(activeGameRoute(info)!);
      }
    } catch (e) {
      if (!mounted || generation != _generation) return;
      ref.read(pendingGameChatPushProvider.notifier).state = null;
      final l10n = AppLocalizations.of(context);
      _showMessage(
        e is AppException
            ? l10n.errorByException(e)
            : l10n.errorActiveGameFetchUnexpected,
      );
    }
  }

  void _showMessage(String message) {
    final overlay =
        widget.router.routerDelegate.navigatorKey.currentState?.overlay;
    if (overlay == null) return;
    AppSnackbar.show(context, message: message, overlay: overlay);
  }

  @override
  void dispose() {
    widget.router.routerDelegate.removeListener(_schedule);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
