import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/character_assets.dart';
import '../../../../core/constants/game_mode.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/i18n/role_names.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../l10n/app_localizations.dart';

/// 모드 고르기 — 방 생성 첫 단계(#658 시안 1번)와 대기실 모드 변경 화면이 같이 쓴다
///
/// 제목·부제는 쓰는 페이지가 그린다. 여기서는 모드 카드와 하단 버튼만 맡는다. 방 생성은 실제 모드 두 개만 고르게 하므로
/// `GameMode.unknown`은 카드가 없다.
class ModeSelectStep extends StatelessWidget {
  const ModeSelectStep({
    super.key,
    required this.selected,
    required this.onSelected,
    required this.onNext,
    this.buttonText,
  });

  final GameMode selected;
  final ValueChanged<GameMode> onSelected;

  /// null이면 버튼이 비활성 — 모드 변경에서 지금 모드를 그대로 골랐을 때
  final VoidCallback? onNext;

  /// 하단 버튼 문구. 없으면 "다음"
  final String? buttonText;

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
                  // 잡히면 갇히는 모드라 철창 속 도둑을 보여 준다
                  assetPath: characterAssetPath(
                    team: 'robber',
                    state: 'jailed',
                  ),
                  title: modeName(l10n, GameMode.copsAndRobbers),
                  description: l10n.modeCardCopsAndRobbersDescription,
                  selected: selected == GameMode.copsAndRobbers,
                  onTap: () => onSelected(GameMode.copsAndRobbers),
                ),
                SizedBox(height: AppSpacing.vertical12),
                _ModeCard(
                  // 감옥 없이 쫓고 쫓기는 모드라 달아나는 도둑을 보여 준다
                  assetPath: startChaseCharacterAssetPath(team: 'robber'),
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
          child: AppButton(
            text: buttonText ?? l10n.buttonNext,
            onPressed: onNext,
          ),
        ),
      ],
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.assetPath,
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  /// 카드 왼쪽 캐릭터 그림. 모드를 글보다 먼저 알아보게 하는 장식이라 읽어 주지 않는다
  final String assetPath;
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
          horizontal: AppSpacing.horizontal20,
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
        child: Row(
          children: [
            // 그림마다 가로세로 비율이 달라(철창 140×116, 달아나는 쥐 248×243) 칸을 고정해야
            // 두 카드의 제목이 같은 줄에서 시작한다
            SizedBox.square(
              dimension: 64.w,
              child: SvgPicture.asset(
                assetPath,
                fit: BoxFit.contain,
                excludeFromSemantics: true,
              ),
            ),
            SizedBox(width: AppSpacing.horizontal16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.subHeading_18.copyWith(
                      color: AppColors.black,
                    ),
                  ),
                  // 그림 옆이라 글 칸이 좁아 영어·일본어 설명은 두 줄이 된다.
                  // 줄 간격 140% 스타일을 써서 두 줄이 붙지 않게 하고, 그만큼 위 간격을 줄인다
                  SizedBox(height: AppSpacing.vertical4),
                  Text(
                    description,
                    style: AppTextStyles.paragraph_14.copyWith(
                      color: AppColors.black600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
