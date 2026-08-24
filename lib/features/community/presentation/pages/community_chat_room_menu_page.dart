import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/i18n/error_message_mapper.dart';
import '../../../../core/widgets/buttons/previous_button.dart';
import '../../../../core/widgets/dialogs/app_dialog.dart';
import '../../../../core/widgets/snackbars/app_snackbar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../router/route_paths.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/community_chat_member_entity.dart';
import '../community_chat_author.dart';
import '../providers/community_chat_room_provider.dart';
import '../providers/community_chat_rooms_provider.dart';
import '../providers/community_detail_provider.dart';
import '../widgets/community_chat_avatar.dart';

/// 채팅방 사이드바 — 시안이 전체 화면이라 drawer 대신 push한다
///
/// 작성자는 방을 나갈 수 없다(서버 `AUTHOR_CANNOT_LEAVE`) — 버튼 자체를 숨긴다.
/// 시안의 알림 종은 뒤에 붙을 기능이 없어 뺐다. 멤버 목록은 BE 이슈 가정 API다.
class CommunityChatRoomMenuPage extends ConsumerWidget {
  const CommunityChatRoomMenuPage({required this.postId, super.key});

  final int postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final post = ref
        .watch(communityDetailNotifierProvider(postId))
        .valueOrNull
        ?.post;
    final members = ref.watch(communityChatMembersProvider(postId));
    final freshMembers = members.valueOrNull;
    // 방 notifier는 매 빌드 무조건 watch한다 — 조건부로 watch하면 멤버 목록이
    // 채워지는 순간 이 provider를 놓아버려 소켓이 조기 disconnect된다.
    final roomMemberCount = ref
        .watch(communityChatRoomNotifierProvider(postId))
        .valueOrNull
        ?.memberCount;
    // 멤버 목록이 있으면 그게 정본이다(사이드바를 열 때마다 새로 받는다). 서버가
    // 아직 멤버 API를 안 주면 빈 목록이 오므로 그때만 목록 응답의 인원수로 물러선다.
    final memberCount = (freshMembers != null && freshMembers.isNotEmpty)
        ? freshMembers.length
        : (roomMemberCount ?? 0);
    final myId = ref.watch(currentUserIdProvider);
    final isAuthor = isChatRoomAuthor(
      post: post,
      members: freshMembers,
      myId: myId,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: PreviousButton(onPressed: () => context.pop()),
      ),
      body: ListView(
        padding: AppPadding.horizontal16,
        children: [
          SizedBox(height: AppSpacing.vertical8),
          Text(
            l10n.communityChatMemberCount(memberCount),
            style: AppTextStyles.tag_12.copyWith(color: AppColors.black600),
          ),
          SizedBox(height: AppSpacing.vertical8),
          _Card(
            child: members.when(
              loading: () => Padding(
                padding: EdgeInsets.all(AppSpacing.horizontal16),
                child: const Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Padding(
                padding: EdgeInsets.all(AppSpacing.horizontal16),
                child: Text(
                  e is AppException
                      ? l10n.errorByException(e)
                      : l10n.errorTemporaryRetry,
                  style: AppTextStyles.paragraph_14.copyWith(
                    color: AppColors.black600,
                  ),
                ),
              ),
              data: (list) => Column(
                children: [for (final m in list) _MemberRow(member: m)],
              ),
            ),
          ),
          SizedBox(height: AppSpacing.vertical12),
          _MenuButton(
            iconPath: 'assets/icons/icon_post.svg',
            label: l10n.communityChatViewPost,
            onTap: () => context.pushNamed(
              RoutePaths.communityDetailName,
              pathParameters: {'postId': '$postId'},
            ),
          ),
          if (!isAuthor) ...[
            SizedBox(height: AppSpacing.vertical8),
            _MenuButton(
              iconPath: 'assets/icons/icon_exit.svg',
              label: l10n.communityChatLeave,
              color: AppColors.red,
              onTap: () => _confirmLeave(context, ref, l10n),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmLeave(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final confirmed = await AppDialog.confirm(
      context: context,
      title: l10n.communityChatLeaveConfirmTitle,
      message: l10n.communityChatLeaveConfirmMessage,
      confirmText: l10n.communityChatLeave,
      cancelText: l10n.buttonCancel, // "닫기" — 취소는 작업 취소로 오해된다(UX 가이드)
      isDestructive: true,
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await ref
          .read(communityChatRoomNotifierProvider(postId).notifier)
          .leave();
    } on AppException catch (e) {
      if (!context.mounted) return;
      AppSnackbar.show(context, message: l10n.errorByException(e));
      return;
    }
    if (!context.mounted) return;
    // 메뉴와 채팅방을 한 번에 걷고 목록으로 — 나간 방에 남을 이유가 없다.
    context.go(RoutePaths.community);
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.vertical8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.xlarge,
        boxShadow: AppShadows.ver2,
      ),
      child: child,
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({required this.member});
  final CommunityChatMemberEntity member;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.horizontal16,
        vertical: AppSpacing.vertical8,
      ),
      child: Row(
        children: [
          const CommunityChatAvatar(size: 28),
          SizedBox(width: AppSpacing.horizontal12),
          Expanded(
            child: Text(
              member.nickname,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.paragraph_14.copyWith(
                color: AppColors.black,
              ),
            ),
          ),
          if (member.isAuthor)
            Text(
              l10n.communityChatAuthorBadge,
              style: AppTextStyles.tag_12.copyWith(
                color: AppColors.blueVer2Basic,
              ),
            ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.iconPath,
    required this.label,
    required this.onTap,
    this.color = AppColors.black,
  });

  final String iconPath;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 52.h,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.xlarge,
          boxShadow: AppShadows.ver2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              iconPath,
              width: 18.w,
              height: 18.w,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
            SizedBox(width: AppSpacing.horizontal8),
            Text(label, style: AppTextStyles.label_16.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}
