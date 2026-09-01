import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/i18n/error_message_mapper.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading/app_refresh_control.dart';
import '../../../../core/widgets/snackbars/app_snackbar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../router/route_paths.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/community_chat_rooms_provider.dart';
import '../providers/community_provider.dart';
import 'community_chat_room_tile.dart';

/// 내 모임 탭 본문 — 참여 중인 채팅방 목록
///
/// 로그인 없이는 목록이 없다(`GET /chat/rooms`는 401). 다른 탭은 비로그인도
/// 볼 수 있지만(DEC-0014) 여기는 "내" 것이라 로그인 안내로 대신한다.
///
/// 목록 갱신은 소켓이 맡는다 — 유저당 알림 채널(DEC-0045)로 새 메시지·연결
/// 복구마다 `CommunityChatRooms`가 스스로 갱신한다. 사용자가 직접 트리거하는
/// 갱신은 당겨서 새로고침뿐이다(최종 리뷰 M-4).
class CommunityChatRoomList extends ConsumerWidget {
  const CommunityChatRoomList({required this.bottomPadding, super.key});

  /// 떠 있는 작성 버튼에 마지막 칸이 가리지 않도록 비우는 높이
  final double bottomPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    if (ref.watch(currentUserIdProvider) == null) {
      return Center(
        child: EmptyState(
          message: l10n.communityChatRoomsLoginRequired,
          actionText: l10n.buttonLogin,
          onAction: () => context.push(RoutePaths.login),
        ),
      );
    }

    final rooms = ref.watch(communityChatRoomsProvider);
    return rooms.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: EmptyState(
          message: e is AppException
              ? l10n.errorByException(e)
              : l10n.errorTemporaryRetry,
          actionText: l10n.buttonRetry,
          onAction: () => ref.invalidate(communityChatRoomsProvider),
        ),
      ),
      data: (list) => AppRefreshControl(
        onRefresh: () => _refresh(context, ref),
        child: list.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: AppSpacing.vertical64 * 2),
                  EmptyState(message: l10n.communityChatRoomsEmpty),
                ],
              )
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(
                  left: AppSpacing.horizontal16,
                  right: AppSpacing.horizontal16,
                  top: AppSpacing.vertical16,
                  bottom: bottomPadding + AppSpacing.vertical16,
                ),
                itemCount: list.length,
                separatorBuilder: (_, _) =>
                    SizedBox(height: AppSpacing.vertical14),
                itemBuilder: (context, i) => CommunityChatRoomTile(
                  room: list[i],
                  now: ref.read(clockProvider)(),
                  onTap: () => context.push(
                    RoutePaths.communityChatWithId(list[i].postId),
                  ),
                ),
              ),
      ),
    );
  }

  /// 실패해도 보던 목록은 남는다 — 스낵바로만 알린다.
  Future<void> _refresh(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(communityChatRoomsProvider.notifier).refresh();
    } on AppException catch (e) {
      if (!context.mounted) return;
      AppSnackbar.show(
        context,
        message: AppLocalizations.of(context).errorByException(e),
      );
    }
  }
}
