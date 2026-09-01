import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/dividers/solid_divider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../user/presentation/providers/profile_icon_provider.dart';
import '../../domain/entities/community_comment_entity.dart';
import 'community_menu_button.dart';

/// 댓글 목록 (답글 한 겹 중첩)
///
/// 스크롤은 부모가 가진다 — 상세 화면 전체가 하나의 스크롤이라 여기서 또
/// 스크롤을 만들면 중첩된다.
class CommunityCommentList extends StatelessWidget {
  const CommunityCommentList({
    super.key,
    required this.comments,
    required this.currentUserId,
    required this.onReply,
    required this.onDelete,
    required this.onReport,
    required this.onToggleReplyNotification,
    this.replyTargetId,
  });

  final List<CommunityCommentEntity> comments;

  /// 로그인 사용자 id — 내 댓글에만 삭제를 보여주기 위해 쓴다. 비로그인이면 null.
  final int? currentUserId;

  /// 답글 달기 — 부모가 입력창을 답글 모드로 바꾼다.
  final ValueChanged<CommunityCommentEntity> onReply;

  final ValueChanged<CommunityCommentEntity> onDelete;

  /// 남의 댓글 신고하기.
  final ValueChanged<CommunityCommentEntity> onReport;

  /// 내 1depth 댓글의 답글 알림 켜기/끄기. 답글 타일에는 바인딩하지 않는다.
  final ValueChanged<CommunityCommentEntity> onToggleReplyNotification;

  /// 현재 답글 작성 중인 댓글 id — 그 댓글만 배경을 강조한다.
  final int? replyTargetId;

  /// 답글 달기(말풍선) 버튼 — 테스트에서 탭 대상을 찾는다. 댓글마다 붙으므로
  /// 여러 개가 잡힌다.
  static const Key replyButtonKey = Key('community_comment_reply');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (comments.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.vertical32),
        child: Center(
          child: Text(
            l10n.communityCommentEmpty,
            style: AppTextStyles.paragraph_14.copyWith(
              color: AppColors.black500,
            ),
          ),
        ),
      );
    }

    // 답글 대상 하이라이트가 화면 폭을 꽉 채워야 하므로 타일이 폭을 늘려 잡는다.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < comments.length; i++)
          ..._buildGroup(
            comments[i],
            isFirstGroup: i == 0,
            isLastGroup: i == comments.length - 1,
          ),
      ],
    );
  }

  /// 원댓글 + 답글 한 그룹. 그룹 사이에만 14-구분선-14를 끼운다 — 답글은
  /// 원댓글에 딸린 덩어리라 사이에 선을 그으면 별개 댓글로 보인다.
  List<Widget> _buildGroup(
    CommunityCommentEntity comment, {
    required bool isFirstGroup,
    required bool isLastGroup,
  }) {
    final hasReplies = comment.replies.isNotEmpty;
    // 구분선과 맞닿는 쪽 여백(14)은 SizedBox가 아니라 타일 자신의 패딩으로
    // 준다 — 답글달기로 하이라이트된 타일이면 그 여백까지 배경색이 덮여야
    // 구분선까지 끊김 없이 이어진다. 그룹의 마지막 타일(답글이 없으면
    // 원댓글 자신)의 아래 여백은 다음이 새 그룹이면 이 규칙(14), 목록 맨
    // 끝이면 원래 여백(18)을 쓴다.
    final lastTileBottom = isLastGroup
        ? AppSpacing.vertical18
        : AppSpacing.vertical14;

    return [
      _CommentTile(
        comment: comment,
        currentUserId: currentUserId,
        onReply: () => onReply(comment),
        onDelete: () => onDelete(comment),
        onReport: () => onReport(comment),
        onToggleReplyNotification: () => onToggleReplyNotification(comment),
        isReplyTarget: comment.id == replyTargetId,
        topPadding: isFirstGroup
            ? AppSpacing.vertical18
            : AppSpacing.vertical14,
        bottomPadding: hasReplies ? AppSpacing.vertical18 : lastTileBottom,
      ),
      // 원댓글과 대댓글이 너무 붙어 보여 4를 더 띄운다 — 답글달기 하이라이트에는
      // 안 걸리도록 타일 패딩이 아니라 별도 SizedBox로 둔다.
      if (hasReplies) SizedBox(height: AppSpacing.vertical4),
      // 답글의 들여쓰기는 앞에 붙는 ↳ 아이콘이 만든다 — 바깥에 패딩을 또 주면
      // 배경 하이라이트가 화면 끝까지 못 닿는다.
      for (int j = 0; j < comment.replies.length; j++)
        _CommentTile(
          comment: comment.replies[j],
          currentUserId: currentUserId,
          isReply: true,
          onDelete: () => onDelete(comment.replies[j]),
          onReport: () => onReport(comment.replies[j]),
          isReplyTarget: comment.replies[j].id == replyTargetId,
          topPadding: 0,
          bottomPadding: j == comment.replies.length - 1
              ? lastTileBottom
              : AppSpacing.vertical18,
        ),
      // 타일의 좌우 패딩(24)에 맞춰 들여쓴다 — 안 그러면 목록이 화면 끝까지
      // 확장된 폭이라 구분선만 화면 끝까지 붙는다.
      if (!isLastGroup)
        SolidDivider(
          indent: AppSpacing.horizontal24,
          endIndent: AppSpacing.horizontal24,
        ),
    ];
  }
}

/// 댓글 한 건
class _CommentTile extends StatelessWidget {
  const _CommentTile({
    required this.comment,
    required this.currentUserId,
    required this.onDelete,
    required this.onReport,
    required this.topPadding,
    required this.bottomPadding,
    this.onReply,
    this.onToggleReplyNotification,
    this.isReply = false,
    this.isReplyTarget = false,
  });

  final CommunityCommentEntity comment;
  final int? currentUserId;
  final VoidCallback onDelete;
  final VoidCallback onReport;

  /// 답글에는 null — 답글의 답글은 열지 않는다.
  final VoidCallback? onReply;

  /// 답글에는 null — 답글의 답글이 없어 답글 알림 값이 무의미하다.
  final VoidCallback? onToggleReplyNotification;

  final bool isReply;

  /// 지금 이 댓글에 답글을 다는 중인지 — 맞으면 배경을 강조한다.
  final bool isReplyTarget;

  /// 그룹 내 위치에 따라 [CommunityCommentList]가 계산해 넘기는 여백.
  final double topPadding;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isMine = currentUserId != null && currentUserId == comment.writerId;

    // 답글이 남아 자리만 지킨 댓글 — 서버가 작성자·본문·아이콘을 전부 비워
    // 보낸다(DEC-0034). 그릴 것도 누를 것도 없으니 한 줄만 남긴다.
    if (comment.deleted) {
      return Container(
        color: AppColors.white,
        padding: EdgeInsets.only(
          top: topPadding,
          bottom: bottomPadding,
          left: AppSpacing.horizontal24,
          right: AppSpacing.horizontal24,
        ),
        child: Text(
          l10n.communityCommentDeleted,
          style: AppTextStyles.paragraph14Regular.copyWith(
            color: AppColors.black300,
          ),
        ),
      );
    }

    // 좌우 24는 페이지 패딩이 아니라 타일이 갖는다 — 답글 대상 배경색이 화면
    // 끝까지 닿아야 하므로 목록이 페이지 좌우 패딩 밖에 놓이기 때문이다.
    return Container(
      color: isReplyTarget ? AppColors.blueVer2_50 : AppColors.white,
      padding: EdgeInsets.only(
        top: topPadding,
        bottom: bottomPadding,
        left: AppSpacing.horizontal24,
        right: AppSpacing.horizontal24,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (isReply) ...[
            // 14짜리 아이콘이 34짜리 프로필과 위끝을 맞추면 너무 높이 뜬다 —
            // 위로 6 밀어 프로필 아이콘 쪽에 눈높이를 맞춘다.
            Padding(
              padding: EdgeInsets.only(top: AppSpacing.vertical6),
              child: SvgPicture.asset(
                AppIcons.reply,
                width: 14.w,
                height: 14.h,
                colorFilter: ColorFilter.mode(
                  AppColors.black600,
                  BlendMode.srcIn,
                ),
              ),
            ),
            SizedBox(width: AppSpacing.horizontal8),
          ],
          // 프로필 아이콘은 앱 내장 SVG다 — 서버는 번호만 준다.
          SvgPicture.asset(
            profileIconAsset(comment.writerProfileIconId),
            width: 34.w,
            height: 34.w,
          ),
          SizedBox(width: AppSpacing.horizontal10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        comment.writerNickname ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.paragraph14Semibold.copyWith(
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        if (onReply != null) ...[
                          GestureDetector(
                            key: CommunityCommentList.replyButtonKey,
                            behavior: HitTestBehavior.opaque,
                            onTap: onReply,
                            child: SvgPicture.asset(
                              AppIcons.speechBubble,
                              width: 16.w,
                              height: 16.h,
                              colorFilter: ColorFilter.mode(
                                AppColors.black200,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          SizedBox(width: AppSpacing.horizontal10),
                        ],
                        // 내 댓글은 답글 알림·삭제, 남의 댓글은 신고 하나만 보여준다.
                        CommunityMenuButton(
                          items: [
                            if (isMine) ...[
                              if (onToggleReplyNotification != null)
                                CommunityMenuItem(
                                  // 다색 SVG라 틴트하지 않는다. 아이콘도 라벨과
                                  // 같이 누르면 되는 것을 가리킨다(모집글 메뉴와
                                  // 같은 규칙).
                                  iconPath: comment.replyNotificationsEnabled
                                      ? AppIcons.bellBlock
                                      : AppIcons.bell,
                                  label: comment.replyNotificationsEnabled
                                      ? l10n.communityMenuReplyNotificationOff
                                      : l10n.communityMenuReplyNotificationOn,
                                  onTap: onToggleReplyNotification!,
                                ),
                              CommunityMenuItem(
                                iconPath: AppIcons.trash,
                                label: l10n.communityMenuDelete,
                                onTap: onDelete,
                                isDestructive: true,
                              ),
                            ] else
                              CommunityMenuItem(
                                iconPath: AppIcons.warningLight,
                                label: l10n.buttonReport,
                                onTap: onReport,
                                isDestructive: true,
                              ),
                          ],
                          iconColor: AppColors.black200,
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.vertical4),
                Text(
                  comment.content ?? '',
                  style: AppTextStyles.paragraph14Regular.copyWith(
                    color: AppColors.black700,
                  ),
                ),
                SizedBox(height: AppSpacing.vertical6),
                Text(
                  _formattedDate(comment.createdAt),
                  style: AppTextStyles.tag_12.copyWith(
                    color: AppColors.black300,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 1년 안이면 `mm/dd hh:mm`, 1년이 넘으면 `yy/mm/dd hh:mm` (24시 기준).
  String _formattedDate(DateTime at) {
    String two(int n) => n.toString().padLeft(2, '0');
    final hhmm = '${two(at.hour)}:${two(at.minute)}';
    final mmdd = '${two(at.month)}/${two(at.day)} $hhmm';
    if (DateTime.now().difference(at).inDays < 365) return mmdd;
    return '${two(at.year % 100)}/$mmdd';
  }
}
