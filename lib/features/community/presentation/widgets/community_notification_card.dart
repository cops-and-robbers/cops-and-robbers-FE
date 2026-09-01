import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/community_notification_entity.dart';
import '../community_notification_time_format.dart';

/// 알림함 카드 한 건
///
/// 좌우 24 / 상하 20 패딩, radius 12. 안읽음이면 배경을 옅은 파랑으로 강조한다
/// (시안) — [CommunityNotificationEntity.read]는 서버 커서 판정 결과라 탭한다고
/// 즉시 바뀌지 않는다(DEC-0038), 목록을 나갈 때 한 번에 읽음 처리된다.
class CommunityNotificationCard extends StatelessWidget {
  const CommunityNotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
  });

  final CommunityNotificationEntity notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final iconAsset = switch (notification.type) {
      CommunityNotificationType.comment ||
      CommunityNotificationType.reply => AppIcons.comment,
    };

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.horizontal24,
          vertical: AppSpacing.vertical20,
        ),
        decoration: BoxDecoration(
          color: notification.read ? AppColors.white : AppColors.blueVer2_70,
          borderRadius: AppRadius.large,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(iconAsset, width: 24.w, height: 24.h),
            SizedBox(width: AppSpacing.horizontal18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.postTitle,
                          style: AppTextStyles.label_16.copyWith(
                            color: AppColors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: AppSpacing.horizontal8),
                      Text(
                        formatNotificationTime(
                          l10n,
                          notification.createdAt,
                          DateTime.now(),
                        ),
                        style: AppTextStyles.tag_12.copyWith(
                          color: AppColors.black600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.vertical8),
                  Text(
                    switch (notification.type) {
                      CommunityNotificationType.comment =>
                        l10n.communityNotificationNewComment(
                          notification.content,
                        ),
                      CommunityNotificationType.reply =>
                        l10n.communityNotificationNewReply(
                          notification.content,
                        ),
                    },
                    style: AppTextStyles.tag_12.copyWith(
                      color: AppColors.black800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
