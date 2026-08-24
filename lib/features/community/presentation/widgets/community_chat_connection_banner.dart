import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/community_chat_event.dart';

/// 상단 띠 — 자동 재연결 중 / 포기(다시 연결 버튼). 붙어 있으면 안 보인다.
class CommunityChatConnectionBanner extends StatelessWidget {
  const CommunityChatConnectionBanner({
    required this.connection,
    required this.exhausted,
    required this.onReconnect,
    super.key,
  });

  final CommunityChatConnectionState connection;
  final bool exhausted;
  final VoidCallback onReconnect;

  @override
  Widget build(BuildContext context) {
    if (connection == CommunityChatConnectionState.connected) {
      return const SizedBox.shrink();
    }
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      color: AppColors.blueVer2_70,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.horizontal16,
        vertical: 8.h,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              exhausted
                  ? l10n.communityChatConnectionLost
                  : l10n.communityChatReconnecting,
              style: AppTextStyles.tag_12.copyWith(color: AppColors.black700),
            ),
          ),
          if (exhausted)
            GestureDetector(
              onTap: onReconnect,
              behavior: HitTestBehavior.opaque,
              child: Text(
                l10n.communityChatReconnect,
                style: AppTextStyles.tag12Semibold.copyWith(
                  color: AppColors.blueVer2Strong,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
