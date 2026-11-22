import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import 'setting_switch_card.dart';

/// 무전 켜고 끄기 카드 (#723)
///
/// 방 생성 확인 화면과 대기방 게임 설정이 같이 쓴다. [onChanged]가 null이면
/// 참가자용 읽기 전용이다. 문구에 역할어가 없어 게임 모드를 받지 않는다.
class RadioToggleCard extends StatelessWidget {
  const RadioToggleCard({
    super.key,
    required this.enabled,
    this.onChanged,
    this.isDarkMode = false,
  });

  final bool enabled;
  final ValueChanged<bool>? onChanged;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SettingSwitchCard(
      title: l10n.radioPttLabel,
      titleTrailing: _BetaChip(label: l10n.radioBetaChip),
      description: l10n.radioCardDesc,
      value: enabled,
      onChanged: onChanged,
      isDarkMode: isDarkMode,
    );
  }
}

/// 무전이 베타임을 알리는 칩 — 커뮤니티 모집 배지와 같은 토큰 구성 (#723 시안)
class _BetaChip extends StatelessWidget {
  const _BetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.horizontal8,
        vertical: AppSpacing.vertical4,
      ),
      decoration: BoxDecoration(
        color: AppColors.logo,
        borderRadius: AppRadius.xlarge,
      ),
      child: Text(
        label,
        style: AppTextStyles.tag_10.copyWith(color: AppColors.white),
      ),
    );
  }
}
