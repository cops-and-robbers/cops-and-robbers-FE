import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/dev_flags.dart';
import '../../../../core/constants/game_team.dart';
import '../../../../core/i18n/error_message_mapper.dart';
import '../../../../core/services/analytics/analytics_service.dart';
import '../../../../core/services/loading_message_service.dart';
import '../../../../core/services/permission/game_entry_gate.dart';
import '../../../../core/services/permission/location_permission_messages.dart';
import '../../../../core/widgets/loading/loading_page.dart';
import '../../../../core/widgets/snackbars/app_snackbar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../router/active_game_route.dart';
import '../../../../router/route_paths.dart';
import '../../../auth/domain/entities/auth_result_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
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

    // 로그인 상태면 join API(handle) 전에 위치/배터리 게이트를 태운다.
    // 미로그인은 게이트 없이 handle() 로 보내야 한다 — handle() 내부에서만
    // pending invite 저장 + 로그인 이동이 일어나므로, 게이트를 먼저 태우면
    // 거부 시 invite 가 저장되지 않은 채 흐름이 끊긴다.
    final user = await _readUserSafely();
    if (!mounted) return;

    if (user != null) {
      final passed = await ref
          .read(gameEntryGateProvider)
          .ensure(
            context: context,
            locationContext: LocationPermissionContext.waitingRoom,
          );
      if (!mounted) return;
      if (!passed) {
        // 게이트 미통과 — 안내 다이얼로그가 닫힌 뒤 홈으로 (무한 로딩 방지)
        context.go(RoutePaths.home);
        return;
      }
    }

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

      case JoinedRoomOutcome(
        :final gameId,
        :final participantId,
        :final isEventGame,
      ):
        // 딥링크 참가 퍼널 이벤트
        unawaited(
          ref.read(analyticsServiceProvider).logGameJoin(method: 'deeplink'),
        );
        if (isEventGame || kEventGameDevOverride) {
          // 이벤트 모드 — 로비 스킵, 경찰로 인게임 직행
          context.go(
            '${RoutePaths.gameWithId(gameId.toString())}'
            '?team=${GameTeam.police}&pid=$participantId',
          );
        } else {
          // 일반 모드 — 해당 gameId 의 대기실로 이동
          context.go(RoutePaths.waitingRoomWithId(gameId.toString()));
        }

      case AlreadyInRoomOutcome(:final participation):
        // 이미 방에 참가 중 — 홈이 아니라 현재 활성 방으로 복귀 + 중립 안내.
        // 활성 게임 조회 실패(participation == null)면 홈으로 폴백.
        AppSnackbar.show(context, message: l10n.deeplinkAlreadyInRoom);
        final route = participation == null
            ? null
            : activeGameRoute(participation);
        context.go(route ?? RoutePaths.home);

      case FailureOutcome(:final errorCode, :final messageKey):
        // 처리 불가 에러 — errorCode 가 있으면 errorByCode, 없으면 messageKey 로 표시 후 홈으로
        final msg = errorCode != null
            ? l10n.errorByCode(errorCode)
            : _resolveErrorMessage(l10n, messageKey);
        AppSnackbar.show(context, message: msg, backgroundColor: AppColors.red);
        context.go(RoutePaths.home);
    }
  }

  /// 인증 상태를 안전하게 읽는다. 실패 시 null(미로그인 취급)로 폴백한다.
  ///
  /// handle() 도 동일하게 authNotifierProvider.future 를 읽으므로,
  /// 여기서 null 로 폴백해도 handle() 단계에서 일관되게 재처리된다.
  Future<AuthResultEntity?> _readUserSafely() async {
    try {
      return await ref.read(authNotifierProvider.future);
    } catch (e) {
      debugPrint('[DeepLinkJoinPage] 인증 상태 읽기 실패: $e');
      return null;
    }
  }

  /// messageKey 를 사용자에게 표시할 문자열로 변환합니다.
  ///
  /// 백엔드 errorCode 경로(ValidationException 등)는 호출자가 errorByCode 로
  /// 처리하므로 이 메서드에는 도달하지 않습니다.
  String _resolveErrorMessage(AppLocalizations l10n, String? key) {
    return switch (key) {
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
