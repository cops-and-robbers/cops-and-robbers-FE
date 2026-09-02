import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/dialogs/app_dialog.dart';
import '../../../../core/widgets/dialogs/dialog_spacing.dart';
import '../../../../l10n/app_localizations.dart';

/// 게임 초대 카드 — "게임이 열렸어요!" + 초대 문구 + 초대코드 + 참가 버튼
///
/// [ChatBubble]의 [ChatBubble.child]로 꽂혀 다른 채팅과 같은 말풍선(닉네임·아바타·
/// 꼬리) 안에 그려진다 — 카드 자체는 배경·테두리 없이 내용만 담당한다.
/// 이름은 본문이 아니라 `senderNickname`에서 온다(서버가 본문에 이름을 안 넣는다 —
/// 닉네임을 바꾸면 과거 초대장도 따라온다). 참가는 기존 초대코드 흐름으로 넘긴다.
class CommunityChatInviteCard extends StatelessWidget {
  const CommunityChatInviteCard({
    required this.nickname,
    required this.roomTitle,
    required this.inviteCode,
    required this.onJoin,
    super.key,
  });

  final String nickname;
  final String roomTitle;
  final String inviteCode;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(AppIcons.gameConsole, width: 24.w, height: 24.w),
            SizedBox(width: AppSpacing.horizontal8),
            Text(
              l10n.communityChatInviteOpened,
              style: AppTextStyles.label_16.copyWith(color: AppColors.black),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.vertical8),
        Text(
          l10n.communityChatInviteTitle(nickname, roomTitle),
          style: AppTextStyles.paragraph_14.copyWith(color: AppColors.black),
        ),
        SizedBox(height: AppSpacing.vertical8),
        Text(
          l10n.communityChatInviteCode(inviteCode),
          style: AppTextStyles.tag_14.copyWith(color: AppColors.black600),
        ),
        SizedBox(height: AppSpacing.vertical12),
        AppButton(
          width: double.infinity,
          height: 36.h,
          text: l10n.communityChatInviteJoin,
          textStyle: AppTextStyles.tag_14,
          borderRadius: BorderRadius.circular(6.r),
          onPressed: () => _confirmJoin(context, l10n),
        ),
      ],
    );
  }

  /// 참가 전 확인 — 초대장 다이얼로그(거절/입장). 입장을 눌러야 기존 초대코드
  /// 흐름([onJoin])으로 넘어간다.
  void _confirmJoin(BuildContext context, AppLocalizations l10n) {
    AppDialog.show<void>(
      context: context,
      title: l10n.communityChatInviteDialogTitle,
      // 초대장 캡션 — 이 다이얼로그만 작은 캡션으로 낸다(다른 곳은 heading_20 기본).
      titleStyle: AppTextStyles.tag_12.copyWith(color: AppColors.black300),
      // 본문 색이 message 슬롯 기본(black600)과 달라 customContent로 낸다.
      spacing: DialogSpacing(toContent: AppSpacing.vertical12),
      customContent: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.communityChatInviteDialogBody(nickname),
            textAlign: TextAlign.center,
            style: AppTextStyles.paragraph_14.copyWith(color: AppColors.black),
          ),
          SizedBox(height: AppSpacing.vertical12),
          // 방 코드는 라벨과 값의 간격을 잡아야 해 한 문장으로 못 합친다.
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.communityChatInviteDialogCodeLabel,
                style: AppTextStyles.paragraph_14.copyWith(
                  color: AppColors.black600,
                ),
              ),
              SizedBox(width: AppSpacing.horizontal8),
              Text(
                inviteCode,
                style: AppTextStyles.paragraph_14.copyWith(
                  color: AppColors.black600,
                ),
              ),
            ],
          ),
        ],
      ),
      cancelText: l10n.communityChatInviteDialogDecline,
      confirmText: l10n.communityChatInviteDialogEnter,
      onConfirm: onJoin,
    );
  }
}
