import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/character_assets.dart';
import '../../../../core/constants/game_team.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../l10n/app_localizations.dart';

/// 게임 시작 확인창 본문. 두 팀 캐릭터를 나란히 두고 아래에 인원을 적는다.
///
/// 준비 단계가 없어져(#661) 방장이 시작 전에 마지막으로 팀 구성을 훑어보는 자리다.
/// 확인창 바로 뒤가 역할 배너라, 캐릭터를 먼저 보여 줘 출발하는 느낌을 잇는다.
class StartGameTeamPreview extends StatelessWidget {
  const StartGameTeamPreview({
    required this.policeCount,
    required this.robberCount,
    this.isDarkMode = false,
    super.key,
  });

  final int policeCount;
  final int robberCount;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        _TeamSide(
          team: GameTeam.police,
          label: l10n.dialogStartGamePoliceCount(policeCount),
          isEmpty: policeCount == 0,
          isDarkMode: isDarkMode,
        ),
        Container(
          width: 1,
          height: 64.h,
          color: isDarkMode ? AppColors.black800 : AppColors.black100,
        ),
        _TeamSide(
          team: GameTeam.robber,
          label: l10n.dialogStartGameRobberCount(robberCount),
          isEmpty: robberCount == 0,
          isDarkMode: isDarkMode,
        ),
      ],
    );
  }
}

class _TeamSide extends StatelessWidget {
  const _TeamSide({
    required this.team,
    required this.label,
    required this.isEmpty,
    required this.isDarkMode,
  });

  final String team;
  final String label;

  /// 이벤트 게임은 한 팀이 0명이어도 시작한다. 빈 팀은 흐리게 둬서 인원이 있는 팀과 구분한다.
  final bool isEmpty;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Opacity(
        opacity: isEmpty ? 0.4 : 1,
        child: Column(
          children: [
            SvgPicture.asset(
              characterAssetPath(
                team: GameTeam.toLowerKey(team),
                state: 'ready',
              ),
              width: 56.w,
              height: 64.w,
            ),
            SizedBox(height: AppSpacing.vertical8),
            Text(
              label,
              textAlign: TextAlign.center,
              style:
                  (isDarkMode
                          ? AppTextStyles.robberLabel
                          : AppTextStyles.label_16)
                      .copyWith(
                        fontSize: 14.sp,
                        color: isDarkMode
                            ? AppColors.white
                            : AppColors.black800,
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
