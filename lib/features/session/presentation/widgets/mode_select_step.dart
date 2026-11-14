import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/game_mode.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/i18n/role_names.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../l10n/app_localizations.dart';

/// 방 생성 첫 단계 — 모드 고르기 (#658 시안 1번)
///
/// 제목·부제는 다른 단계와 같은 머리말을 쓰도록 흐름 페이지가 그린다.
/// 여기서는 모드 카드와 "다음"만 맡는다. 방 생성은 실제 모드 두 개만 고르게 하므로
/// `GameMode.unknown`은 카드가 없다.
class ModeSelectStep extends StatelessWidget {
  const ModeSelectStep({
    super.key,
    required this.selected,
    required this.onSelected,
    required this.onNext,
  });

  final GameMode selected;
  final ValueChanged<GameMode> onSelected;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.horizontal20),
            child: Column(
              children: [
                _ModeCard(
                  title: modeName(l10n, GameMode.copsAndRobbers),
                  description: l10n.modeCardCopsAndRobbersDescription,
                  selected: selected == GameMode.copsAndRobbers,
                  onTap: () => onSelected(GameMode.copsAndRobbers),
                ),
                SizedBox(height: AppSpacing.vertical12),
                _ModeCard(
                  title: modeName(l10n, GameMode.hideAndSeek),
                  description: l10n.modeCardHideAndSeekDescription,
                  selected: selected == GameMode.hideAndSeek,
                  onTap: () => onSelected(GameMode.hideAndSeek),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: AppPadding.all20,
          child: AppButton(text: l10n.buttonNext, onPressed: onNext),
        ),
      ],
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.horizontal24,
          vertical: AppSpacing.vertical20,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.blue100 : AppColors.white,
          borderRadius: AppRadius.xl20,
          // 선택은 연한 파랑 바탕과 파란 테두리로 구분한다
          border: Border.all(
            color: selected ? AppColors.blue : AppColors.black100,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.label_16.copyWith(color: AppColors.black),
            ),
            SizedBox(height: AppSpacing.vertical8),
            Text(
              description,
              style: AppTextStyles.paragraph_14_100.copyWith(
                color: AppColors.black600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
