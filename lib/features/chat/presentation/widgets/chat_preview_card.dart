import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/chat_constants.dart';
import '../../../../core/constants/game_team.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/chat_message_dto.dart';

/// 새 채팅 메시지 프리뷰 — 채팅 버튼에서 튀어나오는 말풍선
///
/// 채팅 말풍선과 같은 모서리(내 말풍선: 우하만 4)로 우측 하단 채팅 버튼을
/// 가리키며, 버튼 자리에서 커지며 나타나고 3초 뒤 같은 자리로 사라진다.
/// 폭은 내용에 맞추고 오른쪽 정렬한다.
/// 정보 우선순위: 메시지 본문(2줄) > 발신자(직업 아이콘 + 닉네임) > 채널
/// (라벨 색). 미읽음 수는 채팅 버튼 배지가 맡으므로 그리지 않는다.
/// 탭하면 [onTap] 콜백이 호출됩니다.
class ChatPreviewCard extends StatefulWidget {
  const ChatPreviewCard({
    required this.message,
    required this.isDarkMode,
    required this.onTap,
    required this.onDismissed,
    super.key,
  });

  final ChatMessageDto message;
  final bool isDarkMode;
  final VoidCallback onTap;

  /// 3초 후 자동 퇴장 완료 시 호출
  final VoidCallback onDismissed;

  /// 말풍선 본체의 키 — 테스트에서 실제 그려진 영역을 잡을 때 쓴다
  static const bubbleKey = ValueKey('chat-preview-bubble');

  @override
  State<ChatPreviewCard> createState() => _ChatPreviewCardState();
}

class _ChatPreviewCardState extends State<ChatPreviewCard> {
  bool _visible = false;
  Timer? _autoDismissTimer;

  @override
  void initState() {
    super.initState();
    // 다음 프레임에서 애니메이션 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _visible = true);
        _startAutoDismiss();
      }
    });
  }

  @override
  void didUpdateWidget(covariant ChatPreviewCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 메시지가 바뀌면 타이머 리셋 + 다시 보이기
    if (oldWidget.message.id != widget.message.id) {
      _autoDismissTimer?.cancel();
      _tappedByUser = false;
      setState(() => _visible = true);
      _startAutoDismiss();
    }
  }

  void _startAutoDismiss() {
    _autoDismissTimer?.cancel();
    _autoDismissTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _visible = false);
      }
    });
  }

  /// 탭으로 닫힌 경우 onDismissed 중복 호출 방지
  bool _tappedByUser = false;

  void _handleTap() {
    _autoDismissTimer?.cancel();
    _tappedByUser = true;
    widget.onTap();
    setState(() => _visible = false);
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    super.dispose();
  }

  /// 메시지 타입 판별 (시스템 메시지 = 공지)
  bool get _isSystemMessage =>
      widget.message.sender.team.toUpperCase() == ChatTeam.system ||
      widget.message.sender.participantId == 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isTeam = widget.message.scope == ChatScope.team;
    final isSystem = _isSystemMessage;
    final dark = widget.isDarkMode;

    // 채팅방의 상대 말풍선(ChatMessageBubble)과 같은 색. 팀·공지 라벨만 팀 색.
    final accent = dark ? AppColors.green : AppColors.blue;
    final fill = dark ? AppColors.black : AppColors.white;
    final nameColor = dark ? AppColors.black400 : AppColors.black600;
    final channelColor = (isSystem || isTeam) ? accent : nameColor;
    final messageColor = isSystem
        ? accent
        : (dark ? AppColors.white : AppColors.black);

    final String headline;
    final String channel;
    final Widget leading;
    if (isSystem) {
      headline = l10n.chatPreviewTagNotice;
      channel = isTeam ? l10n.chatPreviewTagTeam : l10n.chatPreviewTagAll;
      leading = SvgPicture.asset(
        AppIcons.loudspeaker,
        width: 12.w,
        height: 12.w,
        colorFilter: ColorFilter.mode(accent, BlendMode.srcIn),
      );
    } else {
      headline = widget.message.sender.nickname;
      channel = isTeam ? l10n.chatPreviewTagTeam : l10n.chatPreviewTagAll;
      leading = SvgPicture.asset(
        AppIcons.role(
          isPolice: GameTeam.isPolice(widget.message.sender.team),
          isDark: dark,
        ),
        width: 12.w,
        height: 12.w,
      );
    }

    final inDuration = const Duration(milliseconds: 300);
    final outDuration = const Duration(milliseconds: 200);

    return Align(
      alignment: Alignment.bottomRight,
      child: AnimatedScale(
        scale: _visible ? 1.0 : 0.7,
        alignment: Alignment.bottomRight,
        duration: _visible ? inDuration : outDuration,
        curve: _visible ? Curves.easeOutBack : Curves.easeIn,
        child: AnimatedOpacity(
          opacity: _visible ? 1.0 : 0.0,
          duration: _visible ? inDuration : outDuration,
          curve: _visible ? Curves.easeOut : Curves.easeIn,
          onEnd: () {
            // 페이드아웃 완료 후 dismissed 콜백 (탭 시에는 onTap에서 이미 처리됨)
            if (!_visible && mounted && !_tappedByUser) {
              widget.onDismissed();
            }
          },
          child: Semantics(
            button: true,
            child: GestureDetector(
              onTap: _handleTap,
              child: Container(
                key: ChatPreviewCard.bubbleKey,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.horizontal12,
                  vertical: AppSpacing.vertical8,
                ),
                decoration: BoxDecoration(
                  color: fill,
                  // 채팅 내 말풍선(ChatBubble isMe)과 동일한 모서리
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.r),
                    topRight: Radius.circular(12.r),
                    bottomLeft: Radius.circular(12.r),
                    bottomRight: Radius.circular(4.r),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        leading,
                        SizedBox(width: AppSpacing.horizontal4),
                        Flexible(
                          child: Text(
                            headline,
                            style: AppTextStyles.tag_12.copyWith(
                              color: isSystem ? accent : nameColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: AppSpacing.horizontal4),
                        Text(
                          '· $channel',
                          style: AppTextStyles.tag_12.copyWith(
                            color: channelColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.vertical4),
                    Text(
                      widget.message.filteredMessage,
                      style: AppTextStyles.paragraph_14.copyWith(
                        color: messageColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
