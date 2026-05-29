import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/game_team.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/constants/chat_constants.dart';
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
      return isDarkMode
          ? 'assets/icons/icon_police_darkmode.svg'
          : 'assets/icons/icon_police_lightmode.svg';
    }
    if (team == ChatTeam.robber) {
      return isDarkMode
          ? 'assets/icons/mdi_robber_darkmode.svg'
          : 'assets/icons/mdi_robber_lightmode.svg';
    }
    return null;
  }

  String get _formattedTime => message.formattedTimeLocal;

  @override
  Widget build(BuildContext context) {
    if (_isSystemMessage) {
      return _buildSystemMessage(context);
    }

    return Padding(
      padding: EdgeInsets.only(
        left: isMe ? AppSpacing.horizontal16 : AppSpacing.horizontal24,
        right: isMe ? AppSpacing.horizontal24 : AppSpacing.horizontal16,
        top: showNickname ? AppSpacing.vertical8 : 2.h,
        bottom: 2.h,
      ),
      child: isMe ? _buildMyMessage() : _buildOtherMessage(),
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
            'assets/icons/Loudspeaker.svg',
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
      final iconPath = isPolice
          ? (isDarkMode
                ? 'assets/icons/icon_police_darkmode.svg'
                : 'assets/icons/icon_police_lightmode.svg')
          : (isDarkMode
                ? 'assets/icons/mdi_robber_darkmode.svg'
                : 'assets/icons/mdi_robber_lightmode.svg');
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

  Widget _buildMyMessage() {
    // getter 반복 호출 방지 — null 체크와 실제 사용을 동일 인스턴스로 보장
    final roleIconPath = _roleIconPath;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (showNickname)
          Padding(
            padding: EdgeInsets.only(
              bottom: AppSpacing.vertical8,
              right: AppSpacing.horizontal4,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (roleIconPath != null) ...[
                  SvgPicture.asset(roleIconPath, width: 12.w, height: 12.w),
                  SizedBox(width: AppSpacing.horizontal4),
                ],
                Text(
                  message.sender.nickname,
                  style: AppTextStyles.tag_12.copyWith(
                    color: isDarkMode ? AppColors.black400 : AppColors.black600,
                  ),
                ),
              ],
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (showTime)
              Padding(
                padding: EdgeInsets.only(
                  right: AppSpacing.horizontal4,
                  bottom: 2.h,
                ),
                child: Text(
                  _formattedTime,
                  style: AppTextStyles.tag_10.copyWith(
                    color: AppColors.black400,
                  ),
                ),
              ),
            Flexible(
              child: Builder(
                builder: (bubbleCtx) => GestureDetector(
                  onLongPress: onLongPress != null
                      ? () => onLongPress!(bubbleCtx)
                      : null,
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 240.w),
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.horizontal12,
                      vertical: AppSpacing.vertical8,
                    ),
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
                      message.filteredMessage,
                      style: AppTextStyles.paragraph_14.copyWith(
                        color: isDarkMode ? AppColors.white : AppColors.black,
                      ),
                    ),
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
    // getter 반복 호출 방지 — null 체크와 실제 사용을 동일 인스턴스로 보장
    final roleIconPath = _roleIconPath;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showNickname)
          Padding(
            padding: EdgeInsets.only(
              bottom: AppSpacing.vertical8,
              left: AppSpacing.horizontal4,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (roleIconPath != null) ...[
                  SvgPicture.asset(roleIconPath, width: 12.w, height: 12.w),
                  SizedBox(width: AppSpacing.horizontal4),
                ],
                Text(
                  message.sender.nickname,
                  style: AppTextStyles.tag_12.copyWith(
                    color: isDarkMode ? AppColors.black400 : AppColors.black600,
                  ),
                ),
              ],
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Builder(
                builder: (bubbleCtx) => GestureDetector(
                  onLongPress: onLongPress != null
                      ? () => onLongPress!(bubbleCtx)
                      : null,
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 240.w),
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.horizontal12,
                      vertical: AppSpacing.vertical8,
                    ),
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
                      message.filteredMessage,
                      style: AppTextStyles.paragraph_14.copyWith(
                        color: isDarkMode ? AppColors.white : AppColors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (showTime)
              Padding(
                padding: EdgeInsets.only(
                  left: AppSpacing.horizontal4,
                  bottom: 2.h,
                ),
                child: Text(
                  _formattedTime,
                  style: AppTextStyles.tag_10.copyWith(
                    color: AppColors.black400,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
