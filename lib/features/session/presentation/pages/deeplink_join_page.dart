import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/loading_message_service.dart';
import '../../../../core/widgets/loading/loading_page.dart';
import '../../../../core/widgets/snackbars/app_snackbar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../router/active_game_route.dart';
import '../../../../router/route_paths.dart';
import '../providers/deeplink_join_notifier.dart';

/// 딥링크(/join/:inviteCode) 진입 시 표시되는 transient 화면.
///
/// 빌드 직후 [DeepLinkJoinNotifier.handle] 을 호출하고,
/// 반환된 [DeepLinkJoinOutcome] 에 따라 자동으로 다음 화면으로 이동합니다.
/// 사용자가 머무는 시간은 최대 API 응답 시간이므로, 로딩 인디케이터만 표시합니다.
class DeepLinkJoinPage extends ConsumerStatefulWidget {
  const DeepLinkJoinPage({super.key, required this.inviteCode});

  final String inviteCode;

  @override
  ConsumerState<DeepLinkJoinPage> createState() => _DeepLinkJoinPageState();
}

class _DeepLinkJoinPageState extends ConsumerState<DeepLinkJoinPage> {
  // 중복 실행 방지 — initState 가 두 번 호출되는 경우 대비
  bool _started = false;

  // 로딩 메시지는 한 번만 뽑아 고정한다. getMessage 가 호출마다 랜덤이라
  // build() 에서 직접 호출하면 rebuild 시 메시지가 바뀌어 깜빡인다.
  String? _loadingMessage;

  @override
  void initState() {
    super.initState();
    // build() 가 완료된 후 실행하여 context 가 유효한 시점에 라우팅
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // context(l10n) 가 유효한 첫 시점에 "방 잠입" 카테고리 메시지 1회 선택
    _loadingMessage ??= LoadingMessageService.getMessage(
      context,
      LoadingCategory.joinRoom,
    );
  }

  Future<void> _run() async {
    if (_started) return;
    _started = true;

    // handle() 자체가 throw 하는 경로는 _classifyError로 거의 막혀있지만,
    // 예상치 못한 예외가 새서 화면이 무한 로딩으로 갇히는 것을 막는 최종 안전망.
    DeepLinkJoinOutcome outcome;
    try {
      outcome = await ref
          .read(deepLinkJoinNotifierProvider.notifier)
          .handle(widget.inviteCode);
    } catch (e) {
      debugPrint('[DeepLinkJoinPage] handle() 예외: $e');
      outcome = const DeepLinkJoinOutcome.failure(
        messageKey: 'errorServerInternal',
      );
    }

    // async gap 이후 context 유효성 확인 필수
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);

    switch (outcome) {
      case LoginRedirectOutcome():
        // 미로그인 — 로그인 화면으로 이동 (PendingInvite 에 코드 저장 완료)
        context.go(RoutePaths.login);

      case JoinedRoomOutcome(:final gameId):
        // join 성공 — 해당 gameId 의 대기실로 이동
        context.go(RoutePaths.waitingRoomWithId(gameId.toString()));

      case AlreadyInRoomOutcome(:final participation):
        // 이미 방에 참가 중 — 홈이 아니라 현재 활성 방으로 복귀 + 중립 안내.
        // 활성 게임 조회 실패(participation == null)면 홈으로 폴백.
        AppSnackbar.show(context, message: l10n.deeplinkAlreadyInRoom);
        final route = participation == null
            ? null
            : activeGameRoute(participation);
        context.go(route ?? RoutePaths.home);

      case FailureOutcome(:final messageKey):
        // 처리 불가 에러 — 메시지 키로 사용자에게 표시 후 홈으로
        AppSnackbar.show(
          context,
          message: _resolveErrorMessage(l10n, messageKey),
          backgroundColor: AppColors.red,
        );
        context.go(RoutePaths.home);
    }
  }

  /// ARB 키를 사용자에게 표시할 문자열로 변환합니다.
  ///
  /// 새 에러 키 추가 시 ARB 파일과 이 switch 를 함께 업데이트하세요.
  String _resolveErrorMessage(AppLocalizations l10n, String key) {
    return switch (key) {
      'errorInviteCodeInvalid' => l10n.errorInviteCodeInvalid,
      'errorGameFull' => l10n.errorGameFull,
      'errorNetworkOffline' => l10n.errorNetworkOffline,
      'errorPendingInviteSave' => l10n.errorPendingInviteSave,
      _ => l10n.errorServerInternal,
    };
  }

  @override
  Widget build(BuildContext context) {
    // 전체화면 로딩은 앱 공통 LoadingPage 로 통일 (splash 재접속 로딩과 동일 룩)
    // 메시지는 didChangeDependencies 에서 이미 고정됨 (?? 는 방어적 폴백)
    return LoadingPage(
      message:
          _loadingMessage ??
          LoadingMessageService.getMessage(context, LoadingCategory.joinRoom),
    );
  }
}
