import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/community_post_entity.dart';
import '../community_chat_time_format.dart';

/// 채팅방 상단 모임 카드 — 모임 시각 · 장소 보기 · 현재 인원 · 방장 "게임 시작"
///
/// 인원수는 목록 응답에서만 오므로 못 받았으면 `-/10명`으로 그린다.
class CommunityChatMeetingCard extends StatelessWidget {
  const CommunityChatMeetingCard({
    required this.post,
    required this.memberCount,
    required this.onViewLocation,
    required this.onOpenMeetingInfo,
    this.onStartGame,
    super.key,
  });

  final CommunityPostEntity post;
  final int? memberCount;
  final VoidCallback onViewLocation;

  /// 카드 전체를 누르면 모임 정보(전체 화면)로 이동.
  final VoidCallback onOpenMeetingInfo;

  /// 방장 전용 "게임 시작" — null이면 버튼을 그리지 않는다(비방장).
  final VoidCallback? onStartGame;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: onOpenMeetingInfo,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: EdgeInsets.fromLTRB(
          AppSpacing.horizontal16,
          AppSpacing.vertical10,
          AppSpacing.horizontal16,
          0,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.horizontal14,
          vertical: AppSpacing.vertical16,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.large,
          boxShadow: AppShadows.vague,
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/icon_notice.svg',
              width: 20.w,
              height: 20.w,
            ),
            SizedBox(width: AppSpacing.horizontal12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // 방장 버튼이 폭을 가져가면 시각이 먼저 줄어든다 — 링크는 남긴다
                      Flexible(
                        child: Text(
                          formatCommunityMeetingAt(l10n, post.meetingAt),
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.tag_14.copyWith(
                            color: AppColors.black,
                          ),
                        ),
                      ),
                      SizedBox(width: AppSpacing.horizontal6),
                      GestureDetector(
                        onTap: onViewLocation,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: EdgeInsets.only(bottom: 2.h),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: AppColors.black500),
                            ),
                          ),
                          child: Text(
                            l10n.communityChatViewLocation,
                            style: AppTextStyles.tag_12.copyWith(
                              color: AppColors.black500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.vertical4),
                  Text(
                    l10n.communityChatMeetingMembers(
                      memberCount?.toString() ?? '-',
                      post.maxParticipants,
                    ),
                    style: AppTextStyles.tag_12.copyWith(
                      color: AppColors.black600,
                    ),
                  ),
                ],
              ),
            ),
            if (onStartGame != null) ...[
              SizedBox(width: AppSpacing.horizontal8),
              AppButton(
                width: 88.w,
                height: 36.h,
                text: l10n.communityChatStartGame,
                backgroundColor: AppColors.logo,
                foregroundColor: AppColors.white,
                textStyle: AppTextStyles.paragraph14Semibold,
                borderRadius: AppRadius.large,
                showBorder: false,
                onPressed: onStartGame,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
