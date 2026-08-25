import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/spacing_and_radius.dart';

/// 채팅 말풍선 본체 — 게임 채팅과 커뮤니티 채팅이 함께 쓴다
///
/// 레이아웃만 안다: 닉네임 줄 → 말풍선(최대 275, 패딩 12/8, 모서리 12에 아래
/// 한쪽만 4) ← 시각. 색·서체·아이콘은 전부 밖에서 받는다 — 게임은 팀 테마와
/// 직업 아이콘([leading]), 커뮤니티는 흰/파랑과 아바타([avatar])를 꽂는다.
/// 시스템 메시지는 여기서 그리지 않는다(두 화면의 모양이 다르다).
class ChatBubble extends StatelessWidget {
  const ChatBubble({
    required this.isMe,
    required this.bubbleColor,
    this.text,
    this.textStyle,
    this.child,
    this.nickname,
    this.timeLabel,
    this.showNickname = true,
    this.showTime = true,
    this.nicknameStyle,
    this.timeStyle,
    this.leading,
    this.avatar,
    this.avatarSize = 36,
    this.onLongPress,
    this.borderRadius,
    super.key,
  }) : assert(child != null || text != null, 'text 또는 child 중 하나는 필요하다');

  final bool isMe;
  final Color bubbleColor;

  /// 말풍선 안쪽 기본 내용. [child]가 있으면 무시된다.
  final String? text;
  final TextStyle? textStyle;

  /// 말풍선 안쪽 내용을 통째로 바꿀 때(예: 커뮤니티 게임 초대 카드) 쓴다.
  final Widget? child;

  /// 닉네임. null이면 [showNickname]과 무관하게 닉네임 줄이 없다(내 말풍선 등).
  final String? nickname;
  final String? timeLabel;

  /// 묶음 첫 말풍선만 true — 닉네임(과 아바타)을 그린다.
  final bool showNickname;

  /// 묶음 마지막 말풍선만 true — 시각을 그린다.
  final bool showTime;
  final TextStyle? nicknameStyle;
  final TextStyle? timeStyle;

  /// 닉네임 앞 장식 (게임: 직업 아이콘)
  final Widget? leading;

  /// 상대 말풍선 왼쪽 아바타. 묶음의 첫 줄에만 그리고, 나머지 줄은 같은 폭만큼
  /// 비워 말풍선 왼쪽 선을 맞춘다.
  final Widget? avatar;
  final double avatarSize;

  /// 롱프레스 콜백 (말풍선 Container의 BuildContext 전달 — 컨텍스트 메뉴 위치용)
  final void Function(BuildContext bubbleContext)? onLongPress;

  /// 말풍선 모서리. null이면 기본값(상단 12, 하단은 isMe 쪽 꼬리 4) 사용.
  final BorderRadius? borderRadius;

  bool get _hasNicknameRow => showNickname && nickname != null;

  @override
  Widget build(BuildContext context) {
    final column = Column(
      crossAxisAlignment: isMe
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        if (_hasNicknameRow) _buildNicknameRow(),
        Row(
          mainAxisAlignment: isMe
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (isMe && showTime) _buildTime(right: true),
            Flexible(child: _buildBubble()),
            if (!isMe && showTime) _buildTime(right: false),
          ],
        ),
      ],
    );

    final body = avatar == null || isMe
        ? column
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 묶음 첫 줄에만 아바타, 나머지 줄은 자리만 지킨다.
              showNickname
                  ? SizedBox(width: avatarSize.w, child: avatar)
                  : SizedBox(width: avatarSize.w),
              SizedBox(width: AppSpacing.horizontal8),
              Expanded(child: column),
            ],
          );

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.horizontal16,
        right: AppSpacing.horizontal16,
        top: _hasNicknameRow ? AppSpacing.vertical8 : 2.h,
        bottom: 2.h,
      ),
      child: body,
    );
  }

  Widget _buildNicknameRow() {
    return Padding(
      padding: EdgeInsets.only(
        bottom: AppSpacing.vertical8,
        left: isMe ? 0 : AppSpacing.horizontal4,
        right: isMe ? AppSpacing.horizontal4 : 0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[
            leading!,
            SizedBox(width: AppSpacing.horizontal4),
          ],
          Text(nickname!, style: nicknameStyle),
        ],
      ),
    );
  }

  Widget _buildTime({required bool right}) {
    return Padding(
      padding: EdgeInsets.only(
        right: right ? AppSpacing.horizontal4 : 0,
        left: right ? 0 : AppSpacing.horizontal4,
        bottom: 2.h,
      ),
      child: Text(timeLabel ?? '', style: timeStyle),
    );
  }

  Widget _buildBubble() {
    return Builder(
      builder: (bubbleCtx) => GestureDetector(
        onLongPress: onLongPress != null ? () => onLongPress!(bubbleCtx) : null,
        child: Container(
          constraints: BoxConstraints(maxWidth: 275.w),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.horizontal12,
            vertical: AppSpacing.vertical8,
          ),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius:
                borderRadius ??
                BorderRadius.only(
                  topLeft: Radius.circular(12.r),
                  topRight: Radius.circular(12.r),
                  bottomLeft: Radius.circular(isMe ? 12.r : 4.r),
                  bottomRight: Radius.circular(isMe ? 4.r : 12.r),
                ),
          ),
          child: child ?? Text(text!, style: textStyle),
        ),
      ),
    );
  }
}
