import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/i18n/error_message_mapper.dart';
import '../../../../core/widgets/dialogs/app_dialog.dart';
import '../../../../core/widgets/navigation/app_top_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../router/route_paths.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/community_chat_notice_entity.dart';
import '../community_chat_time_format.dart';
import '../providers/community_chat_notice_provider.dart';
import '../providers/community_chat_rooms_provider.dart';
import '../widgets/community_chat_avatar.dart';
import '../widgets/community_menu_button.dart';

/// 채팅방 고정 공지 — 상단 모임 카드를 누르면 열린다
///
/// 방마다 하나뿐이라(DEC-0054) 화면은 "있다/없다" 둘만 그린다. 등록·수정·삭제
/// 진입점은 방장에게만 보인다 — 서버도 403으로 막지만 눌러 놓고 거절당하는
/// 화면을 보여줄 이유가 없다.
class CommunityChatNoticePage extends ConsumerWidget {
  const CommunityChatNoticePage({required this.postId, super.key});

  final int postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final notice = ref.watch(communityChatNoticeProvider(postId));
    // 방장 판정은 모집글 작성자와 로그인 사용자 비교 하나뿐이다 — 상단 카드의
    // "게임 시작" 버튼과 같은 기준이다.
    final post = ref.watch(communityChatPostProvider(postId)).valueOrNull;
    final isHost =
        post != null && post.writerId == ref.watch(currentUserIdProvider);

    return Scaffold(
      // 목록·작성 화면과 달리 흰 바탕이다 — 공지 카드가 테두리만으로 구분되므로
      // 연하늘 배경 위에 두면 카드 경계가 배경색에 묻힌다.
      backgroundColor: AppColors.white,
      appBar: AppTopBar(
        backgroundColor: AppColors.white,
        title: l10n.communityChatNoticeTitle,
        onBack: () => Navigator.of(context).maybePop(),
        actions: [
          if (isHost)
            _WriteAction(
              tooltip: l10n.communityChatNoticeWriteTitle,
              onTap: () => _openEditor(context, notice.valueOrNull),
            ),
        ],
      ),
      body: SafeArea(
        child: notice.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _centered(
            e is AppException ? l10n.errorByException(e) : l10n.errorUnknown,
          ),
          data: (data) => data == null
              ? _centered(
                  isHost
                      ? l10n.communityChatNoticeEmptyHost
                      : l10n.communityChatNoticeEmpty,
                )
              : _body(context, ref, l10n, data, isHost: isHost),
        ),
      ),
    );
  }

  Widget _centered(String text) => Center(
    child: Padding(
      padding: AppPadding.horizontal16,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppTextStyles.paragraph_14.copyWith(color: AppColors.black500),
      ),
    ),
  );

  Widget _body(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    CommunityChatNoticeEntity notice, {
    required bool isHost,
  }) => SingleChildScrollView(
    padding: EdgeInsets.symmetric(
      horizontal: AppSpacing.horizontal16,
      vertical: AppSpacing.vertical16,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommunityChatAvatar(iconId: notice.writerProfileIcon),
            SizedBox(width: AppSpacing.horizontal12),
            // 닉네임이 길면 ⋮가 밀려나므로 이름 쪽이 줄어든다(LSN-0035).
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notice.writerNickname,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.label_16.copyWith(
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: AppSpacing.vertical4),
                  Text(
                    // 등록 시각을 쓴다 — 수정 시각을 쓰면 방장이 오타 하나를
                    // 고쳐도 "방금 올라온 공지"처럼 보인다.
                    formatCommunityDateTime(notice.createdAt),
                    style: AppTextStyles.tag_12.copyWith(
                      color: AppColors.black300,
                    ),
                  ),
                ],
              ),
            ),
            if (isHost)
              CommunityMenuButton(
                iconSize: 24,
                iconColor: AppColors.black600,
                items: [
                  CommunityMenuItem(
                    iconPath: AppIcons.write,
                    label: l10n.communityMenuEdit,
                    onTap: () => _openEditor(context, notice),
                  ),
                  CommunityMenuItem(
                    iconPath: AppIcons.trash,
                    label: l10n.communityMenuDelete,
                    isDestructive: true,
                    onTap: () => _confirmDelete(context, ref, l10n),
                  ),
                ],
              ),
          ],
        ),
        SizedBox(height: AppSpacing.vertical12),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.horizontal16,
            vertical: AppSpacing.vertical16,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: AppRadius.large,
            // 그림자가 아니라 선으로 구분한다 — 흰 배경 위 흰 카드라 그림자를
            // 쓰면 카드가 떠 보이고, 시안은 얇은 테두리 하나뿐이다.
            border: Border.all(color: AppColors.black100),
          ),
          child: Text(
            notice.content,
            style: AppTextStyles.paragraph_14.copyWith(
              color: AppColors.black800,
            ),
          ),
        ),
      ],
    ),
  );

  void _openEditor(BuildContext context, CommunityChatNoticeEntity? notice) =>
      context.push(
        RoutePaths.communityChatNoticeEditWithId(postId),
        extra: notice?.content,
      );

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final confirmed = await AppDialog.confirm(
      context: context,
      title: l10n.communityChatNoticeDeleteConfirmTitle,
      // 다시 등록해도 이전 내용은 돌아오지 않는다 — 서버가 이력을 남기지 않는다.
      message: l10n.communityDeleteConfirmMessage,
      confirmText: l10n.communityMenuDelete,
      isDestructive: true,
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(communityChatNoticeProvider(postId).notifier).delete();
    } on AppException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.errorByException(e))));
    }
  }
}

/// 앱바 우측 쓰기 아이콘 — 공지가 없으면 등록, 있으면 수정으로 간다.
class _WriteAction extends StatelessWidget {
  const _WriteAction({required this.tooltip, required this.onTap});

  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => IconButton(
    onPressed: onTap,
    tooltip: tooltip,
    // 세로도 `.w`로 잡는다 — `.h`를 섞으면 화면 비율에 따라 정사각 아이콘이
    // 눌린다(채팅방 앱바 햄버거·모임 카드와 같은 규칙).
    icon: SvgPicture.asset(AppIcons.write, width: 24.w, height: 24.w),
  );
}
