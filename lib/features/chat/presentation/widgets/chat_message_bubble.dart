import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/game_team.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/constants/chat_constants.dart';
import '../../../../core/widgets/chat/chat_bubble.dart';
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
    this.showNickname = true,
    this.showTime = true,
    this.isDarkMode = false,
    this.onLongPress,
    super.key,
  });

  final ChatMessageDto message;
  final bool isMe;
  final String myTeam;

  /// 닉네임 표시 여부 (그룹 첫 메시지만 true)
  final bool showNickname;

  /// 시간 표시 여부 (그룹 마지막 메시지만 true)
  final bool showTime;

  /// 다크 모드 여부
  final bool isDarkMode;

  /// 메시지 롱프레스 콜백 (버블 Container의 BuildContext 전달)
  final void Function(BuildContext bubbleContext)? onLongPress;

  bool get _isSystemMessage =>
      message.sender.team.toUpperCase() == ChatTeam.system ||
      message.sender.participantId == 0;

  /// 발신자 직업 아이콘 경로 (시스템 메시지는 null)
  String? get _roleIconPath {
    final team = message.sender.team.toUpperCase();
    if (team == ChatTeam.police) {
      return AppIcons.role(isPolice: true, isDark: isDarkMode);
    }
    if (team == ChatTeam.robber) {
      return AppIcons.role(isPolice: false, isDark: isDarkMode);
    }
    return null;
  }

  String get _formattedTime => message.formattedTimeLocal;

  @override
  Widget build(BuildContext context) {
    if (_isSystemMessage) {
      return _buildSystemMessage(context);
    }

    final roleIconPath = _roleIconPath;
    return ChatBubble(
      text: message.filteredMessage,
      isMe: isMe,
      nickname: message.sender.nickname,
      timeLabel: _formattedTime,
      showNickname: showNickname,
      showTime: showTime,
      bubbleColor: isDarkMode ? AppColors.black : AppColors.white,
      textStyle: AppTextStyles.paragraph_14.copyWith(
        color: isDarkMode ? AppColors.white : AppColors.black,
      ),
      nicknameStyle: AppTextStyles.tag_12.copyWith(
        color: isDarkMode ? AppColors.black400 : AppColors.black600,
      ),
      timeStyle: AppTextStyles.tag_10.copyWith(color: AppColors.black400),
      leading: roleIconPath == null
          ? null
          : SvgPicture.asset(roleIconPath, width: 12.w, height: 12.w),
      onLongPress: onLongPress,
    );
  }

  /// 시스템 메시지 (중앙 정렬, 파란색 텍스트 + Loudspeaker 16x16)
  Widget _buildSystemMessage(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.horizontal16,
        vertical: 6.h,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            AppIcons.loudspeaker,
            width: 16.w,
            height: 16.w,
            colorFilter: ColorFilter.mode(
              isDarkMode ? AppColors.green : AppColors.blue,
              BlendMode.srcIn,
            ),
          ),
          SizedBox(width: AppSpacing.horizontal4),
          Flexible(
            child: RichText(
              textAlign: TextAlign.center,
              textScaler: MediaQuery.textScalerOf(context),
              text: TextSpan(
                children: _parseSystemMessageSpans(message.message),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 시스템 메시지 텍스트에 포함된 아이콘 마커를 파싱하여 InlineSpan 리스트로 변환
  ///
  /// `@icon_police`, `@icon_robber` 마커를 SVG WidgetSpan으로 치환한다.
  /// 마커가 없는 일반 시스템 메시지는 텍스트만 반환한다.
  List<InlineSpan> _parseSystemMessageSpans(String text) {
    final style = AppTextStyles.paragraph_14.copyWith(
      color: isDarkMode ? AppColors.green : AppColors.blue,
    );
    final iconRegex = RegExp(r'@icon_(police|robber)');
    final spans = <InlineSpan>[];
    var lastEnd = 0;

    for (final match in iconRegex.allMatches(text)) {
      // 마커 앞 텍스트
      if (match.start > lastEnd) {
        spans.add(
          TextSpan(text: text.substring(lastEnd, match.start), style: style),
        );
      }
      // 아이콘 WidgetSpan (원본 SVG 색상 유지 — colorFilter 미적용)
      final isPolice = GameTeam.isPolice(match.group(1));
      final iconPath = AppIcons.role(isPolice: isPolice, isDark: isDarkMode);
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: EdgeInsets.only(right: 2.w),
            child: SvgPicture.asset(iconPath, width: 16.w, height: 16.w),
          ),
        ),
      );
      lastEnd = match.end;
    }

    // 마지막 남은 텍스트
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd), style: style));
    }

    // 마커가 없었으면 전체 텍스트 반환
    if (spans.isEmpty) {
      spans.add(TextSpan(text: text, style: style));
    }

    return spans;
  }
}
