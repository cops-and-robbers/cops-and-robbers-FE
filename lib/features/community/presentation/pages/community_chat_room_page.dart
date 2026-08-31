import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/i18n/error_message_mapper.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/navigation/app_top_bar.dart';
import '../../../../core/widgets/snackbars/app_snackbar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../router/route_paths.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/community_chat_event.dart';
import '../providers/community_chat_room_provider.dart';
import '../providers/community_chat_rooms_provider.dart';
import '../providers/community_chat_socket_provider.dart';
import '../widgets/community_chat_connection_banner.dart';
import '../widgets/community_chat_input_bar.dart';
import '../widgets/community_chat_meeting_card.dart';
import '../widgets/community_chat_message_list.dart';

/// 모집글 채팅방
///
/// 소켓은 로그인 수명이다(`CommunityChatSocket`) — 이 화면은 방을 **구독**만 한다.
/// 상단 모임 카드가 쓰는 제목·모임 시각·정원은 모집글 단건 조회에서 온다.
/// 떠날 때 읽음 커서를 한 번 옮긴다(PopScope — `dispose()`에서 부르면 POST가
/// 나가지 않았다, 알림함과 같은 이유 · ISS-0157).
class CommunityChatRoomPage extends ConsumerStatefulWidget {
  const CommunityChatRoomPage({required this.postId, super.key});

  final int postId;

  @override
  ConsumerState<CommunityChatRoomPage> createState() =>
      _CommunityChatRoomPageState();
}

class _CommunityChatRoomPageState extends ConsumerState<CommunityChatRoomPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = communityChatRoomNotifierProvider(widget.postId);
    final room = ref.watch(provider);
    final socket = ref.watch(communityChatSocketProvider);
    // 상세 provider가 아니라 글만 받는 쪽을 본다 — 그쪽은 댓글·좋아요를 함께
    // 받아 하나만 실패해도 모임 카드가 통째로 사라진다.
    final post = ref
        .watch(communityChatPostProvider(widget.postId))
        .valueOrNull;
    // 내 모임 탭에서 들어오면 상세가 아직 없다 — 목록 응답의 제목으로 먼저 채운다.
    final rooms = ref.watch(communityChatRoomsProvider).valueOrNull;
    final roomMatches =
        rooms?.where((r) => r.postId == widget.postId) ?? const [];
    final roomTitle = roomMatches.isEmpty ? null : roomMatches.first.title;
    final chatTitle = post?.title ?? roomTitle ?? '';

    ref.listen(provider, (prev, next) {
      final s = next.valueOrNull;
      if (s == null) return;
      final p = prev?.valueOrNull;
      if (s.evicted && !(p?.evicted ?? false)) {
        AppSnackbar.show(context, message: l10n.communityChatEvicted);
        // 사이드바가 위에 떠 있어도 목록까지 걷는다 — 나간 방에 남을 이유가 없다(leave 흐름과 동일).
        context.go(RoutePaths.community);
        return;
      }
      if (s.lastErrorCode != null && s.errorSeq != (p?.errorSeq ?? 0)) {
        AppSnackbar.show(context, message: l10n.errorByCode(s.lastErrorCode!));
      }
    });

    return PopScope(
      // pop이 실제로 일어나는 이 시점에서 부른다. didPop이 true일 때만이다.
      // Notifier가 await 전에 필요한 것을 전부 잡으므로 여기서 기다리지 않는다.
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) return;
        unawaited(
          ProviderScope.containerOf(
            context,
            listen: false,
          ).read(provider.notifier).markReadOnExit(),
        );
      },
      child: Scaffold(
        backgroundColor: AppColors.blueVer2_50,
        appBar: AppTopBar(
          onBack: () => context.pop(),
          centerTitle: false,
          titleSpacing: 0,
          titleWidget: Text(
            chatTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.label_16.copyWith(color: AppColors.black),
          ),
          actions: [
            GestureDetector(
              onTap: () => context.push(
                RoutePaths.communityChatMenuWithId(widget.postId),
              ),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.horizontal16,
                ),
                child: SvgPicture.asset(
                  'assets/icons/icon_hamburger.svg',
                  width: 24.w,
                  height: 24.w,
                ),
              ),
            ),
          ],
        ),
        body: room.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _buildError(l10n, e),
          data: (state) => Column(
            children: [
              CommunityChatConnectionBanner(
                connection: state.connection,
                exhausted: socket.reconnectExhausted,
                onReconnect: () => ref
                    .read(communityChatSocketProvider.notifier)
                    .reconnectNow(),
              ),
              Expanded(
                child: Stack(
                  children: [
                    CommunityChatMessageList(
                      state: state,
                      myUserId: ref.watch(currentUserIdProvider),
                      roomTitle: chatTitle,
                      onLoadOlder: _loadOlder,
                      onRetry: (key) => ref.read(provider.notifier).retry(key),
                      onJoinInvite: (code) =>
                          context.push(RoutePaths.joinByInviteWithCode(code)),
                    ),
                    // 목록 위에 떠 있는 카드 — 스크롤에 밀리지 않고 항상 상단 고정.
                    if (post != null)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: CommunityChatMeetingCard(
                          post: post,
                          memberCount: state.memberCount,
                          onViewLocation: _openPost,
                          onOpenMeetingInfo: () => context.push(
                            RoutePaths.communityChatMeetingInfoWithId(
                              widget.postId,
                            ),
                          ),
                          onStartGame:
                              post.writerId == ref.watch(currentUserIdProvider)
                              ? _startGame
                              : null,
                        ),
                      ),
                  ],
                ),
              ),
              CommunityChatInputBar(
                enabled:
                    state.connection == CommunityChatConnectionState.connected,
                onSend: (text) => ref.read(provider.notifier).send(text),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError(AppLocalizations l10n, Object error) {
    return Center(
      child: Padding(
        padding: AppPadding.horizontal24,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              error is AppException
                  ? l10n.errorByException(error)
                  : l10n.errorTemporaryRetry,
              textAlign: TextAlign.center,
              style: AppTextStyles.paragraph_14.copyWith(
                color: AppColors.black600,
              ),
            ),
            SizedBox(height: AppSpacing.vertical16),
            AppButton(
              width: double.infinity,
              text: l10n.buttonRetry,
              onPressed: () => ref.invalidate(
                communityChatRoomNotifierProvider(widget.postId),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadOlder() async {
    try {
      await ref
          .read(communityChatRoomNotifierProvider(widget.postId).notifier)
          .loadOlder();
    } on AppException catch (e) {
      if (!mounted) return;
      AppSnackbar.show(
        context,
        message: AppLocalizations.of(context).errorByException(e),
      );
    }
  }

  /// 장소 보기 → 모집글 상세(지도). 상세에서 들어왔으면 한 장 더 쌓인다 —
  /// 뒤로 두 번이면 돌아오므로 감수한다.
  /// 방장 전용 — 기존 세션 생성 플로우로 진입해 방을 만든다. postId를 넘기면
  /// 플로우가 생성 성공 직후 이 방에 GAME_INVITE를 쏜다(#516).
  void _startGame() {
    context.push(RoutePaths.sessionCreationFlow, extra: widget.postId);
  }

  void _openPost() {
    context.pushNamed(
      RoutePaths.communityDetailName,
      pathParameters: {'postId': '${widget.postId}'},
    );
  }
}
