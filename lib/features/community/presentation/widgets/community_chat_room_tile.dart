import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/community_chat_room_entity.dart';
import '../community_chat_preview_text.dart';
import '../community_chat_time_format.dart';
import 'community_chat_avatar.dart';

/// 내 모임 탭의 채팅방 한 칸 — 아바타 · 제목+인원 · 마지막 메시지 · 시각
///
/// 안 읽은 개수 배지는 그리지 않는다 — 서버가 만들지 않기로 확정했고(DEC-0030)
/// 앱 로컬로는 개수를 못 센다.
class CommunityChatRoomTile extends StatelessWidget {
  const CommunityChatRoomTile({
    required this.room,
    required this.now,
    required this.onTap,
    super.key,
  });

  final CommunityChatRoomEntity room;
  final DateTime now;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final last = room.lastMessage;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.horizontal20,
          vertical: AppSpacing.vertical16,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.large,
          boxShadow: AppShadows.ver2,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CommunityChatAvatar(size: 40),
            SizedBox(width: AppSpacing.horizontal14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          room.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.label_16.copyWith(
                            color: AppColors.black,
                          ),
                        ),
                      ),
                      SizedBox(width: AppSpacing.horizontal6),
                      Text(
                        '${room.memberCount}',
                        style: AppTextStyles.paragraph_14.copyWith(
                          color: AppColors.black600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.vertical4),
                  // 대화 없는 방도 같은 높이를 지킨다 — 빈 줄을 둔다.
                  Text(
                    last == null ? '' : chatPreviewText(l10n, last),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.paragraph_14.copyWith(
                      color: AppColors.black700,
                    ),
                  ),
                ],
              ),
            ),
            if (last != null) ...[
              SizedBox(width: AppSpacing.horizontal8),
              Text(
                formatChatListTime(l10n, last.createdAt, now),
                style: AppTextStyles.tag_12.copyWith(color: AppColors.black600),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
