import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/i18n/error_message_mapper.dart';
import '../../../../core/widgets/buttons/app_button.dart';
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
/// 탭에 다시 들어올 때마다 목록을 조용히 다시 받는다. 목록은 `keepAlive`라
/// 방에서 대화하고 나와도 미리보기가 그대로고, 서버에는 새 메시지를 알려 줄
/// 채널이 없다(유저당 알림 채널은 아직 없음 — DOC-0037 §10). 방 수에 상한이
/// 있어 페이징 없는 가벼운 응답이라 진입마다 한 번은 감당할 만하다.
class CommunityChatRoomList extends ConsumerStatefulWidget {
  const CommunityChatRoomList({required this.bottomPadding, super.key});

  /// 떠 있는 작성 버튼에 마지막 칸이 가리지 않도록 비우는 높이
  final double bottomPadding;

  @override
  ConsumerState<CommunityChatRoomList> createState() =>
      _CommunityChatRoomListState();
}

class _CommunityChatRoomListState extends ConsumerState<CommunityChatRoomList> {
  @override
  void initState() {
    super.initState();
    if (ref.read(currentUserIdProvider) == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_refreshQuietly());
    });
  }

  /// 보던 목록을 그대로 둔 채 뒤에서 새로 받는다.
  ///
  /// 첫 진입은 provider의 build가 이미 받아 오는 중이라 저장소가 알아서 넘긴다.
  ///
  /// 실패해도 알리지 않는다 — 사용자가 시킨 적 없는 갱신이라 스낵바를 띄우면
  /// 탭을 옮길 때마다 잔소리가 된다. 당겨서 새로고침은 그대로 알린다.
  Future<void> _refreshQuietly() async {
    try {
      await ref.read(communityChatRoomsProvider.notifier).refreshOnReturn();
    } on AppException catch (e) {
      debugPrint('[내 모임] ⚠️ 목록 갱신 실패 — 보던 목록 유지: ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (ref.watch(currentUserIdProvider) == null) {
      return _Notice(
        message: l10n.communityChatRoomsLoginRequired,
        actionText: l10n.buttonLogin,
        onAction: () => context.push(RoutePaths.login),
      );
    }

    final rooms = ref.watch(communityChatRoomsProvider);
    return rooms.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _Notice(
        message: e is AppException
            ? l10n.errorByException(e)
            : l10n.errorTemporaryRetry,
        actionText: l10n.buttonRetry,
        onAction: () => ref.invalidate(communityChatRoomsProvider),
      ),
      data: (list) => AppRefreshControl(
        onRefresh: () => _refresh(context, ref),
        child: list.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: AppSpacing.vertical64 * 2),
                  _Notice(message: l10n.communityChatRoomsEmpty),
                ],
              )
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(
                  left: AppSpacing.horizontal16,
                  right: AppSpacing.horizontal16,
                  top: AppSpacing.vertical16,
                  bottom: widget.bottomPadding + AppSpacing.vertical16,
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

/// 가운데 안내 문구 + 선택 버튼 (빈 목록·로그인·실패)
class _Notice extends StatelessWidget {
  const _Notice({required this.message, this.actionText, this.onAction});

  final String message;
  final String? actionText;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppPadding.horizontal24,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.paragraph_14.copyWith(
                color: AppColors.black600,
              ),
            ),
            if (actionText != null) ...[
              SizedBox(height: AppSpacing.vertical16),
              AppButton(
                width: double.infinity,
                text: actionText!,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
