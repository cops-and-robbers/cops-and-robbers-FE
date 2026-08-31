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

/// 내 모임 탭의 채팅방 한 칸 — 아바타 · 제목+인원 · 마지막 메시지 · 시각 · 안 읽은 배지
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
            // 마지막으로 말한 사람의 얼굴. 대화가 없으면 기본 아이콘이다 —
            // 방을 열었을 때 보이는 말풍선 얼굴과 어긋나지 않게 맞춘다.
            CommunityChatAvatar(size: 40, iconId: last?.senderProfileIcon),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // label_16 제목과 글자 크기가 달라 위쪽에 살짝 여백을 줘야
                  // 두 텍스트의 시각적 중심이 맞는다.
                  Text(
                    formatChatListTime(l10n, last.createdAt, now),
                    style: AppTextStyles.tag_12.copyWith(
                      color: AppColors.black600,
                    ),
                  ),
                  if (room.unreadCount > 0) ...[
                    SizedBox(height: AppSpacing.vertical8),
                    _UnreadBadge(count: room.unreadCount),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 안 읽은 개수 알약. 99를 넘으면 `99+` — 세 자리가 되면 칸이 넓어져 제목을 민다.
class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.horizontal6,
        vertical: AppSpacing.vertical4,
      ),
      decoration: BoxDecoration(
        color: AppColors.blueVer2Strong,
        borderRadius: AppRadius.large,
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: AppTextStyles.tag_12.copyWith(color: AppColors.white),
      ),
    );
  }
}
