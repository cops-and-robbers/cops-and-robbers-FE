import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../l10n/app_localizations.dart';

/// "상희 무전 중" — 참가자 목록에 없으면 이름 대신 "경찰"
String radioSpeakerLabel(
  AppLocalizations l10n,
  String identity,
  Map<String, String> nicknamesByParticipantId,
) => l10n.radioSpeaking(
  nicknamesByParticipantId[identity] ?? l10n.radioSpeakerFallback,
);

/// 다른 경찰이 무전으로 말하는 동안 무전 버튼 위에 뜨는 파란 알약 (#697)
///
/// 채팅 미리보기(흰 말풍선 + 본문)와 헷갈리지 않게 파란 바탕·알약 모양·"무전 중" 문구로 구분한다.
/// 말이 끝날 때까지 떠 있고, 깜박이는 점이 지금 송신 중이라는 뜻이다.
class RadioSpeakerPill extends StatefulWidget {
  const RadioSpeakerPill({super.key, required this.label});

  final String label;

  @override
  State<RadioSpeakerPill> createState() => _RadioSpeakerPillState();
}

class _RadioSpeakerPillState extends State<RadioSpeakerPill>
    with SingleTickerProviderStateMixin {
  late final _blink = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
    lowerBound: 0.3,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _blink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 300.w),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.horizontal14,
          vertical: AppSpacing.vertical10,
        ),
        decoration: BoxDecoration(
          color: AppColors.blue,
          borderRadius: AppRadius.pill,
          boxShadow: AppShadows.soft,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FadeTransition(
              opacity: _blink,
              child: Container(
                width: 8.w,
                height: 8.w,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            SizedBox(width: AppSpacing.horizontal6),
            SvgPicture.asset(
              AppIcons.mic,
              width: 16.w,
              height: 16.w,
              colorFilter: const ColorFilter.mode(
                AppColors.white,
                BlendMode.srcIn,
              ),
            ),
            SizedBox(width: AppSpacing.horizontal6),
            Flexible(
              child: Text(
                widget.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.paragraph14Semibold.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
