import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/chat_constants.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../l10n/app_localizations.dart';
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
    this.unreadCount = 0,
    super.key,
  });

  final ChatMessageDto message;
  final bool isDarkMode;
  final VoidCallback onTap;

  /// 3초 후 자동 퇴장 완료 시 호출
  final VoidCallback onDismissed;

  /// 읽지 않은 메시지 총 수 (전체 + 팀)
  final int unreadCount;

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

    // 카드 배경/테두리
    final bgColor = dark ? AppColors.black900 : AppColors.white;
    final borderColor = dark ? AppColors.black800 : AppColors.black100;

    // 태그 색상: 전체=black, 팀=blue(라이트)/green(다크), 공지=red
    final Color tagBg;
    final Color tagText;
    final String tagLabel;

    if (isSystem) {
      tagBg = AppColors.red;
      tagText = AppColors.white;
      tagLabel = l10n.chat_chatPreviewCard_L116;
    } else if (isTeam) {
      tagBg = dark ? AppColors.green : AppColors.blue;
      tagText = dark ? AppColors.black : AppColors.white;
      tagLabel = l10n.chat_chatPreviewCard_L120;
    } else {
      tagBg = AppColors.black;
      tagText = AppColors.white;
      tagLabel = l10n.chat_chatPreviewCard_L124;
    }

    // 닉네임/메시지 색상 (채팅 버블과 동일)
    final nicknameColor = dark ? AppColors.black400 : AppColors.black600;
    final messageColor = dark ? AppColors.white : AppColors.black;

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
                // 스코프 태그 (전체/팀/공지)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.horizontal8,
                    vertical: AppSpacing.vertical4,
                  ),
                  decoration: BoxDecoration(
                    color: tagBg,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    tagLabel,
                    style: AppTextStyles.tag12Semibold.copyWith(color: tagText),
                  ),
                ),
                SizedBox(width: AppSpacing.horizontal8),
                // 닉네임 : 메시지 (공지는 빨간 텍스트)
                Expanded(
                  child: isSystem
                      ? Text(
                          widget.message.filteredMessage,
                          style: AppTextStyles.paragraph_14_100.copyWith(
                            color: AppColors.red,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        )
                      : Text.rich(
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
                // +N 읽지 않은 메시지 배지 (공지에는 미표시)
                if (!isSystem && widget.unreadCount > 0) ...[
                  SizedBox(width: AppSpacing.horizontal8),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.horizontal8,
                      vertical: AppSpacing.vertical4,
                    ),
                    decoration: BoxDecoration(
                      color: dark ? AppColors.green : AppColors.blue,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      '+${widget.unreadCount}',
                      style: AppTextStyles.tag12Semibold.copyWith(
                        color: dark ? AppColors.black : AppColors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
