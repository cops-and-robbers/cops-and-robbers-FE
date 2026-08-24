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
import '../../../../core/widgets/buttons/previous_button.dart';
import '../../../../core/widgets/snackbars/app_snackbar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../router/route_paths.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/community_chat_event.dart';
import '../providers/community_chat_room_provider.dart';
import '../providers/community_chat_rooms_provider.dart';
import '../providers/community_detail_provider.dart';
import '../widgets/community_chat_connection_banner.dart';
import '../widgets/community_chat_input_bar.dart';
import '../widgets/community_chat_meeting_card.dart';
import '../widgets/community_chat_message_list.dart';

/// 모집글 채팅방
///
/// 소켓은 이 화면의 provider 수명과 같다 — 들어오면 붙고 나가면 끊는다(spec 2절).
/// 상단 모임 카드는 상세 provider를 같이 본다: 제목·모임 시각·정원이 거기 있고,
/// 상세에서 들어오면 이미 로드돼 있다.
class CommunityChatRoomPage extends ConsumerStatefulWidget {
  const CommunityChatRoomPage({required this.postId, super.key});

  final int postId;

  @override
  ConsumerState<CommunityChatRoomPage> createState() =>
      _CommunityChatRoomPageState();
}

class _CommunityChatRoomPageState extends ConsumerState<CommunityChatRoomPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// 백그라운드에서 소켓이 죽었을 수 있다 — 돌아오면 바로 다시 붙인다.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref
          .read(communityChatRoomNotifierProvider(widget.postId).notifier)
          .reconnectNow();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = communityChatRoomNotifierProvider(widget.postId);
    final room = ref.watch(provider);
    final post = ref
        .watch(communityDetailNotifierProvider(widget.postId))
        .valueOrNull
        ?.post;
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

    return Scaffold(
      backgroundColor: AppColors.blueVer2_50,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: PreviousButton(onPressed: () => context.pop()),
        centerTitle: false,
        titleSpacing: 0,
        title: Text(
          chatTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.label_16.copyWith(color: AppColors.black),
        ),
        actions: [
          GestureDetector(
            onTap: () =>
                context.push(RoutePaths.communityChatMenuWithId(widget.postId)),
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
              exhausted: state.reconnectExhausted,
              onReconnect: () => ref.read(provider.notifier).reconnectNow(),
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
                        onOpenNotice: () => context.push(
                          RoutePaths.communityChatNoticeWithId(widget.postId),
                        ),
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
  void _openPost() {
    context.pushNamed(
      RoutePaths.communityDetailName,
      pathParameters: {'postId': '${widget.postId}'},
    );
  }
}
