import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/sns_channels.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/utils/url_launcher_util.dart';
import '../../../../l10n/app_localizations.dart';

/// 설정 화면 하단 공식 SNS 채널 아이콘 행
///
/// 안내 문구 + 인스타/유튜브/틱톡을 균일한 슬레이트 원 안에 슬레이트색 글리프로 노출하고,
/// 탭 시 외부 브라우저로 채널을 연다. 채널 목록은 [officialSnsChannels]에서 가져온다.
class SnsChannelRow extends StatelessWidget {
  const SnsChannelRow({super.key});

  /// 원형 배경 지름
  static const double _circleSize = 44;

  /// 원 안 글리프 한 변 크기
  static const double _glyphSize = 22;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: AppPadding.all24,
      child: Column(
        children: [
          Text(
            l10n.settingsSnsPrompt,
            style: AppTextStyles.paragraph14Semibold.copyWith(
              color: AppColors.black500,
            ),
            textAlign: TextAlign.center,
          ),
          // 안내 문구와 채널 아이콘을 시각적으로 한 묶음으로 보이도록 좁게 둔다
          SizedBox(height: AppSpacing.vertical24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < officialSnsChannels.length; i++) ...[
                if (i > 0) SizedBox(width: AppSpacing.horizontal24),
                _ChannelChip(channel: officialSnsChannels[i]),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// SNS 채널 단일 원형 칩 (슬레이트 원 배경 + 슬레이트 글리프)
///
/// 시각적 라벨이 없으므로 [Semantics]로 스크린리더용 채널명을 제공한다.
class _ChannelChip extends StatelessWidget {
  const _ChannelChip({required this.channel});

  final SnsChannel channel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: channel.label,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => launchExternalUrl(channel.url),
        child: Container(
          width: SnsChannelRow._circleSize.w,
          height: SnsChannelRow._circleSize.w,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.slate100,
            shape: BoxShape.circle,
          ),
          child: SvgPicture.asset(
            channel.svgAsset,
            width: SnsChannelRow._glyphSize.w,
            height: SnsChannelRow._glyphSize.w,
            colorFilter: const ColorFilter.mode(
              AppColors.slate500,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}
