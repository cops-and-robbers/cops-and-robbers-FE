import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text_styles.dart';
import '../../data/models/chat_message_dto.dart';

/// 채팅 메시지 버블 위젯
///
/// 개별 채팅 메시지를 표시합니다.
/// 본인 메시지는 오른쪽(우측 꼬리), 다른 사람 메시지는 왼쪽(좌측 꼬리)에 표시됩니다.
class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    required this.message,
    required this.isMe,
    required this.myTeam,
    this.isDarkMode = false,
    super.key,
  });

  final ChatMessageDto message;
  final bool isMe;
  final String myTeam;

  /// 다크 모드 여부
  final bool isDarkMode;

  bool get _isSystemMessage =>
      message.sender.team.toUpperCase() == 'SYSTEM' ||
      message.sender.participantId == 0;

  String get _formattedTime {
    try {
      final dt = DateTime.parse(message.timestamp);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isSystemMessage) {
      return _buildSystemMessage();
    }

    return Padding(
      padding: EdgeInsets.only(
        left: isMe ? 16.w : 24.w,
        right: isMe ? 24.w : 16.w,
        top: 4.h,
        bottom: 4.h,
      ),
      child: isMe ? _buildMyMessage() : _buildOtherMessage(),
    );
  }

  /// 시스템 메시지 (중앙 정렬, 파란색 텍스트 + Loudspeaker 16x16)
  Widget _buildSystemMessage() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/icons/Loudspeaker.svg',
            width: 16.w,
            height: 16.w,
            colorFilter: ColorFilter.mode(
              isDarkMode ? AppColors.green : AppColors.blue,
              BlendMode.srcIn,
            ),
          ),
          SizedBox(width: 4.w),
          Flexible(
            child: Text(
              message.message,
              style: AppTextStyles.paragraph_14.copyWith(
                color: isDarkMode ? AppColors.green : AppColors.blue,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyMessage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 4.h, right: 4.w),
          child: Text(
            message.sender.nickname,
            style: AppTextStyles.tag_12.copyWith(
              color: isDarkMode ? AppColors.black400 : AppColors.black600,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: EdgeInsets.only(right: 4.w, bottom: 2.h),
              child: Text(
                _formattedTime,
                style: AppTextStyles.tag_10.copyWith(color: AppColors.black400),
              ),
            ),
            Flexible(
              child: Container(
                constraints: BoxConstraints(maxWidth: 240.w),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isDarkMode ? AppColors.black : AppColors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.r),
                    topRight: Radius.circular(12.r),
                    bottomLeft: Radius.circular(12.r),
                    bottomRight: Radius.circular(4.r),
                  ),
                ),
                child: Text(
                  message.message,
                  style: AppTextStyles.paragraph_14.copyWith(
                    color: isDarkMode ? AppColors.white : AppColors.black900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOtherMessage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 4.h, left: 4.w),
          child: Text(
            message.sender.nickname,
            style: AppTextStyles.tag_12.copyWith(
              color: isDarkMode ? AppColors.black400 : AppColors.black600,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Container(
                constraints: BoxConstraints(maxWidth: 240.w),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isDarkMode ? AppColors.black : AppColors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.r),
                    topRight: Radius.circular(12.r),
                    bottomLeft: Radius.circular(4.r),
                    bottomRight: Radius.circular(12.r),
                  ),
                ),
                child: Text(
                  message.message,
                  style: AppTextStyles.paragraph_14.copyWith(
                    color: isDarkMode ? AppColors.white : AppColors.black900,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 4.w, bottom: 2.h),
              child: Text(
                _formattedTime,
                style: AppTextStyles.tag_10.copyWith(color: AppColors.black400),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
