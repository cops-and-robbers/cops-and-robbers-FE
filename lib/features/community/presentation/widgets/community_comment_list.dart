import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../user/presentation/providers/profile_icon_provider.dart';
import '../../domain/entities/community_interaction_entity.dart';

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
  });

  final List<CommunityCommentEntity> comments;

  /// 로그인 사용자 id — 내 댓글에만 삭제를 보여주기 위해 쓴다. 비로그인이면 null.
  final int? currentUserId;

  /// 답글 달기 — 부모가 입력창을 답글 모드로 바꾼다.
  final ValueChanged<CommunityCommentEntity> onReply;

  final ValueChanged<CommunityCommentEntity> onDelete;

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final comment in comments) ...[
          _CommentTile(
            comment: comment,
            currentUserId: currentUserId,
            onReply: () => onReply(comment),
            onDelete: () => onDelete(comment),
          ),
          // 답글은 왼쪽으로 들여쓰고 답글 아이콘을 앞에 둔다.
          for (final reply in comment.replies)
            Padding(
              padding: EdgeInsets.only(left: AppSpacing.horizontal24),
              child: _CommentTile(
                comment: reply,
                currentUserId: currentUserId,
                isReply: true,
                onDelete: () => onDelete(reply),
              ),
            ),
        ],
      ],
    );
  }
}

/// 댓글 한 건
class _CommentTile extends StatelessWidget {
  const _CommentTile({
    required this.comment,
    required this.currentUserId,
    required this.onDelete,
    this.onReply,
    this.isReply = false,
  });

  final CommunityCommentEntity comment;
  final int? currentUserId;
  final VoidCallback onDelete;

  /// 답글에는 null — 답글의 답글은 열지 않는다.
  final VoidCallback? onReply;

  final bool isReply;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isMine = currentUserId != null && currentUserId == comment.writerId;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.vertical12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isReply) ...[
            SvgPicture.asset(
              'assets/icons/icon_reply.svg',
              width: 14.w,
              height: 14.h,
              colorFilter: ColorFilter.mode(
                AppColors.black300,
                BlendMode.srcIn,
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
                  children: [
                    Flexible(
                      child: Text(
                        comment.writerNickname,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.paragraph14Semibold.copyWith(
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpacing.horizontal8),
                    Text(
                      _relativeTime(comment.createdAt, l10n),
                      style: AppTextStyles.tag_12.copyWith(
                        color: AppColors.black500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.vertical4),
                Text(
                  comment.content,
                  style: AppTextStyles.paragraph_14.copyWith(
                    color: AppColors.black800,
                  ),
                ),
                SizedBox(height: AppSpacing.vertical6),
                Row(
                  children: [
                    if (onReply != null)
                      _TextAction(
                        label: l10n.communityCommentReply,
                        onTap: onReply!,
                      ),
                    if (onReply != null && isMine)
                      SizedBox(width: AppSpacing.horizontal12),
                    if (isMine)
                      _TextAction(
                        label: l10n.communityMenuDelete,
                        color: AppColors.red,
                        onTap: onDelete,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// `방금`·`3분 전`·`2시간 전`·`8/18` — 하루가 넘으면 날짜로 바꾼다.
  ///
  /// `DateFormat`에 로케일을 넘기려면 `initializeDateFormatting`이 필요한데 이 앱은
  /// 그걸 호출하지 않는다. 카드의 모임 일시와 같은 방식으로 ARB에서 조립한다.
  String _relativeTime(DateTime at, AppLocalizations l10n) {
    final diff = DateTime.now().difference(at);
    if (diff.inMinutes < 1) return l10n.communityCommentJustNow;
    if (diff.inHours < 1) {
      return l10n.communityCommentMinutesAgo(diff.inMinutes);
    }
    if (diff.inDays < 1) return l10n.communityCommentHoursAgo(diff.inHours);
    return '${at.month}/${at.day}';
  }
}

/// 텍스트 버튼 (답글 달기 / 삭제)
class _TextAction extends StatelessWidget {
  const _TextAction({required this.label, required this.onTap, this.color});

  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      // 글자만으로는 터치 영역이 너무 좁다 — 위아래로 4씩 늘린다.
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.vertical4),
        child: Text(
          label,
          style: AppTextStyles.tag_12.copyWith(
            color: color ?? AppColors.black500,
          ),
        ),
      ),
    );
  }
}
