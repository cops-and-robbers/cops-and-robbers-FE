import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/constants/chat_constants.dart';
import '../../data/models/chat_message_dto.dart';

/// 새 채팅 메시지 프리뷰 카드
///
/// 입력바 위에 슬라이드-인으로 나타나며 3초 후 자동으로 사라집니다.
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

  @override
  Widget build(BuildContext context) {
    final isTeamScope = widget.message.scope == ChatScope.team;
    final dark = widget.isDarkMode;

    final bgColor = dark ? AppColors.black900 : AppColors.white;
    final borderColor = dark ? AppColors.black800 : AppColors.black100;
    final nicknameColor = dark ? AppColors.green : AppColors.blue;
    final messageColor = dark ? AppColors.white : AppColors.black;
    final badgeBg = dark ? AppColors.green : AppColors.blue;
    final badgeText = dark ? AppColors.black : AppColors.white;

    return AnimatedSlide(
      offset: _visible ? Offset.zero : const Offset(0, 0.5),
      duration: _visible
          ? const Duration(milliseconds: 300)
          : const Duration(milliseconds: 200),
      curve: _visible ? Curves.easeOut : Curves.easeIn,
      child: AnimatedOpacity(
        opacity: _visible ? 1.0 : 0.0,
        duration: _visible
            ? const Duration(milliseconds: 300)
            : const Duration(milliseconds: 200),
        onEnd: () {
          // 페이드아웃 완료 후 dismissed 콜백 (탭 시에는 onTap에서 이미 처리됨)
          if (!_visible && mounted && !_tappedByUser) {
            widget.onDismissed();
          }
        },
        child: GestureDetector(
          onTap: _handleTap,
          child: Container(
            width: double.infinity,
            height: 48.h,
            margin: EdgeInsets.symmetric(horizontal: AppSpacing.horizontal16),
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.horizontal16),
            decoration: BoxDecoration(
              color: bgColor,
              border: Border.all(color: borderColor),
              borderRadius: AppRadius.medium,
            ),
            child: Row(
              children: [
                // [전체] 또는 [팀] 스코프 배지
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.horizontal8,
                    vertical: AppSpacing.vertical4,
                  ),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: AppRadius.medium,
                  ),
                  child: Text(
                    isTeamScope ? '팀' : '전체',
                    style: AppTextStyles.tag_12.copyWith(color: badgeText),
                  ),
                ),
                SizedBox(width: AppSpacing.horizontal8),
                // 닉네임 : 메시지
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${widget.message.sender.nickname} : ',
                          style: AppTextStyles.paragraph_14.copyWith(
                            color: nicknameColor,
                          ),
                        ),
                        TextSpan(
                          text: widget.message.filteredMessage,
                          style: AppTextStyles.paragraph_14.copyWith(
                            color: messageColor,
                          ),
                        ),
                      ],
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
