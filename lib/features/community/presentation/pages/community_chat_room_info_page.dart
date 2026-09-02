import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/services/vibration_service.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/i18n/error_message_mapper.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/navigation/app_top_bar.dart';
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
/// 멤버 목록은 BE 이슈 가정 API다.
class CommunityChatRoomInfoPage extends ConsumerWidget {
  const CommunityChatRoomInfoPage({required this.postId, super.key});

  final int postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final post = ref
        .watch(communityDetailNotifierProvider(postId))
        .valueOrNull
        ?.post;
    final members = ref.watch(communityChatMembersNotifierProvider(postId));
    final freshMembers = members.valueOrNull?.members;
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

    // 서버 값이 오기 전에는 기본값(받음)으로 그린다 — 스웨거 기본값과 같다.
    final isNotificationOn = members.valueOrNull?.notificationEnabled ?? true;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppTopBar(
        onBack: () => context.pop(),
        actions: [
          GestureDetector(
            onTap: () {
              VibrationService.instance().buttonTap();
              _toggleNotification(context, ref, l10n);
            },
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.horizontal16,
              ),
              child: SvgPicture.asset(
                isNotificationOn ? AppIcons.bell : AppIcons.bellBlock,
                width: 24.w,
                height: 24.w,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: AppPadding.all16,
        children: [
          SizedBox(height: AppSpacing.vertical8),
          Text(
            l10n.communityChatMemberCount(memberCount),
            style: AppTextStyles.paragraph14Semibold.copyWith(
              color: AppColors.black600,
            ),
          ),
          SizedBox(height: AppSpacing.vertical10),
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
                children: [
                  for (final (i, m) in list.members.indexed) ...[
                    if (i > 0) SizedBox(height: AppSpacing.vertical12),
                    _MemberRow(
                      member: m,
                      // 방장만, 그리고 자기 자신은 뺀다. 서버도 403·400으로 다시
                      // 검증하므로 여기서 막는 것은 UI 차원의 1차 제한이다.
                      canKick: isAuthor && !m.isAuthor,
                      onKick: () => _confirmKick(context, ref, l10n, m),
                    ),
                  ],
                ],
              ),
            ),
          ),
          SizedBox(height: AppSpacing.vertical10),
          _MenuButton(
            iconPath: AppIcons.post,
            label: l10n.communityChatViewPost,
            tint: false, // icon_post.svg는 다색 아이콘이라 단색 필터를 씌우면 뭉개진다
            // push하면 detail이 스택에 중복으로 쌓여 뒤로가기를 여러 번 눌러야
            // 목록으로 나간다 — go로 스택을 detail까지만 새로 짜서 한 번에 나가게 한다.
            onPressed: () => context.goNamed(
              RoutePaths.communityDetailName,
              pathParameters: {'postId': '$postId'},
            ),
          ),
          if (!isAuthor) ...[
            SizedBox(height: AppSpacing.vertical10),
            _MenuButton(
              iconPath: AppIcons.gameOut,
              label: l10n.communityChatLeave,
              color: AppColors.red,
              onPressed: () => _confirmLeave(context, ref, l10n),
            ),
          ],
        ],
      ),
    );
  }

  /// 낙관적 토글 — 실패하면 Notifier가 되돌리고 여기서 알린다.
  Future<void> _toggleNotification(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    try {
      await ref
          .read(communityChatMembersNotifierProvider(postId).notifier)
          .toggleNotification();
    } on AppException catch (e) {
      if (!context.mounted) return;
      AppSnackbar.show(context, message: l10n.errorByException(e));
    }
  }

  /// 강퇴 확인 → 실행. 목록 갱신은 Notifier가 서버에서 다시 받아 한다.
  Future<void> _confirmKick(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    CommunityChatMemberEntity member,
  ) async {
    final confirmed = await AppDialog.confirm(
      context: context,
      title: l10n.dialogKickConfirmTitle(member.nickname),
      // 게임 로비의 dialogKickConfirmMessage를 재사용하지 않는다 — 그쪽은
      // 재입장에 초대코드가 필요하지만 채팅방은 제한이 없다 (DEC-0043).
      message: l10n.communityChatKickConfirmMessage,
      confirmText: l10n.buttonKick,
      cancelText: l10n.buttonCancel,
      isDestructive: true,
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await ref
          .read(communityChatMembersNotifierProvider(postId).notifier)
          .kick(member.userId);
    } on AppException catch (e) {
      if (!context.mounted) return;
      AppSnackbar.show(context, message: l10n.errorByException(e));
    }
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
      confirmText: l10n.buttonLeave, // 제목이 이미 "채팅방에서" — 버튼은 동사만
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
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.horizontal24,
        vertical: AppSpacing.vertical20,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.xlarge,
        border: Border.all(color: AppColors.black100),
        boxShadow: AppShadows.vague,
      ),
      child: child,
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({
    required this.member,
    required this.canKick,
    required this.onKick,
  });

  final CommunityChatMemberEntity member;

  /// 이 행에 내보내기 칩을 붙일지 — 보는 사람이 방장이고 대상이 방장이 아닐 때만
  final bool canKick;
  final VoidCallback onKick;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        const CommunityChatAvatar(size: 32),
        SizedBox(width: AppSpacing.horizontal12),
        if (member.isAuthor) ...[
          _Chip(
            label: l10n.communityChatAuthorBadge,
            // 채도 높은 배경 위 10px 흰 글자라 Bold로 획을 지킨다 (대비 4.85:1)
            style: AppTextStyles.tag10Bold.copyWith(color: AppColors.white),
            background: AppColors.blueVer2Strong,
          ),
          SizedBox(width: AppSpacing.horizontal6),
        ],
        // 폭이 모자라면 양보하는 쪽은 닉네임이다 — 칩 둘은 고정 폭이다.
        Expanded(
          child: Text(
            member.nickname,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.label_16.copyWith(color: AppColors.black),
          ),
        ),
        if (canKick) ...[
          SizedBox(width: AppSpacing.horizontal12),
          _Chip(
            label: l10n.buttonKick,
            // 행마다 반복되는 액션이라 Medium — Bold면 닉네임보다 먼저 읽힌다
            style: AppTextStyles.tag_10.copyWith(color: AppColors.black700),
            background: AppColors.white,
            borderColor: AppColors.black400,
            onTap: onKick,
          ),
        ],
      ],
    );
  }
}

/// 참가자 행의 작은 칩 — 채워진 방장 표시와 테두리만 있는 내보내기를 함께 그린다.
///
/// `core/widgets/chips/ActionChip`을 쓰지 않는 이유: 그쪽은 최소 폭 100.w·높이
/// 40.h·`label_16` 고정에 테두리도 없어, 이 크기로 맞추려면 파라미터를 넷 더
/// 뚫어야 한다. 여기서만 쓰는 모양이라 지역 위젯이 더 싸다.
class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.style,
    required this.background,
    this.borderColor,
    this.onTap,
  });

  final String label;
  final TextStyle style;
  final Color background;
  final Color? borderColor;

  /// null이면 누를 수 없는 표시용 칩
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final chip = Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.horizontal10,
        vertical: AppSpacing.vertical4,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.pill,
        border: borderColor == null ? null : Border.all(color: borderColor!),
      ),
      child: Text(label, style: style),
    );
    if (onTap == null) return chip;
    return GestureDetector(
      onTap: () {
        VibrationService.instance().buttonTap();
        onTap!();
      },
      behavior: HitTestBehavior.opaque,
      child: chip,
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.iconPath,
    required this.label,
    required this.onPressed,
    this.color = AppColors.black,
    this.tint = true,
  });

  final String iconPath;
  final String label;
  final VoidCallback onPressed;
  final Color color;

  /// 아이콘에 [color] 단색 필터를 씌울지 여부. 다색 아이콘에 씌우면 실루엣만
  /// 남아 뭉개져 보이므로 그런 아이콘은 false로 원색 그대로 둔다.
  final bool tint;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: label,
      onPressed: onPressed,
      width: double.infinity,
      height: 52.h,
      backgroundColor: AppColors.white,
      foregroundColor: color,
      showBorder: true,
      borderColor: AppColors.black100,
      boxShadow: AppShadows.vague,
      icon: SvgPicture.asset(
        iconPath,
        width: 20.w,
        height: 20.w,
        colorFilter: tint ? ColorFilter.mode(color, BlendMode.srcIn) : null,
      ),
    );
  }
}
