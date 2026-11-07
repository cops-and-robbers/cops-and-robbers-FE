import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/character_assets.dart';
import '../../../../core/constants/game_team.dart';
import '../../../../core/constants/participant_status.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../lobby/data/models/lobby_event_dto.dart';

/// 참가자 카드 위젯
///
/// 대기실 팀 섹션 내 참가자를 표시합니다.
/// 아바타(72x84) + 닉네임, 방장은 왕관 아이콘 표시.
///
/// SVG 매핑 규칙:
/// - 게임방 도둑 수감([gameStatus] == `"JAILED"`) → `jailed.svg`
/// - 게임방 그 외 (ALIVE / POLICE_WAITING) → `ready.svg`
/// - 대기방 ([gameStatus] == null) → `ready.svg`
///
/// 대기방에는 준비 상태가 없어(#661) 모두 같은 모습으로 보인다.
class ParticipantCard extends StatelessWidget {
  const ParticipantCard({
    required this.participant,
    this.isHost = false,
    this.isMe = false,
    this.onTap,
    this.isDarkMode = false,
    this.gameStatus,
    super.key,
  });

  final LobbyParticipantInfo participant;
  final bool isHost;

  /// 현재 사용자 여부 (닉네임 볼드 처리)
  final bool isMe;

  /// 카드 탭 콜백 (null이면 탭 비활성화)
  final VoidCallback? onTap;

  /// 다크 모드 여부
  final bool isDarkMode;

  /// 게임방 참가자 상태 (`"ALIVE"`, `"JAILED"`, `"POLICE_WAITING"`).
  ///
  /// null 이면 대기방 컨텍스트. 값이 있으면 게임방 컨텍스트로,
  /// 도둑의 `JAILED` 상태일 때만 jailed SVG 사용.
  final String? gameStatus;

  @override
  Widget build(BuildContext context) {
    // 수감 상태(JAILED 도둑)는 시각적으로 흐릿하게 처리해 활성 참가자와 구분
    final isJailed =
        gameStatus == ParticipantStatus.jailed &&
        GameTeam.isRobber(participant.team);
    final characterOpacity = isJailed ? (isDarkMode ? 0.7 : 0.5) : 1.0;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 캐릭터 영역 (72x84) — 배경 없이 SVG 만 표시
          SizedBox(
            width: 72.w,
            height: 84.h,
            child: Opacity(
              opacity: characterOpacity,
              child: SvgPicture.asset(
                _resolveCharacterAssetPath(),
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(height: AppSpacing.vertical4),
          // 닉네임 (방장은 왕관 아이콘)
          SizedBox(
            width: 72.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isHost) ...[
                  SvgPicture.asset(AppIcons.crown, width: 12.w, height: 12.w),
                  SizedBox(width: 4.w),
                ],
                Flexible(
                  child: Text(
                    participant.nickname,
                    style:
                        (isMe ? AppTextStyles.tag10Bold : AppTextStyles.tag_10)
                            .copyWith(
                              color: isMe
                                  ? (isDarkMode
                                        ? AppColors.black100
                                        : AppColors.black600)
                                  : (isDarkMode
                                        ? AppColors.black100
                                        : AppColors.black800),
                            ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 팀과 상태에 맞는 캐릭터 SVG 경로.
  ///
  /// JAILED 도둑만 수감 에셋이고, 나머지는 대기방과 게임방 모두 활성 모습이다.
  String _resolveCharacterAssetPath() {
    final team = GameTeam.toLowerKey(participant.team);
    if (gameStatus == ParticipantStatus.jailed && GameTeam.isRobber(team)) {
      return characterAssetPath(
        team: GameTeam.toLowerKey(GameTeam.robber),
        state: 'jailed',
      );
    }
    return characterAssetPath(team: team, state: 'ready');
  }
}

/// + 버튼 슬롯 카드 위젯
///
/// 대기실 팀 섹션 첫 번째 칸에 표시되며, 탭 시 해당 팀으로 변경합니다.
class AddSlotCard extends StatelessWidget {
  const AddSlotCard({this.onTap, this.isDarkMode = false, super.key});

  /// 카드 탭 콜백 (팀 변경 트리거)
  final VoidCallback? onTap;

  /// 다크 모드 여부
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final labelColor = isDarkMode ? AppColors.black600 : AppColors.black400;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 72.w,
            height: 84.h,
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.black800 : AppColors.black100,
                borderRadius: BorderRadius.circular(8.r),
              ),
              // 아이콘만으로는 팀을 옮기는 칸인지 몰라 라벨을 붙인다(#661 피그마 9085:24787)
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    AppIcons.change,
                    width: 24.w,
                    height: 24.w,
                    colorFilter: ColorFilter.mode(labelColor, BlendMode.srcIn),
                  ),
                  SizedBox(height: 5.h),
                  // 칸 높이가 고정이라 큰 글씨 설정에서도 한 줄로 두고 넘치면 줄인다
                  Text(
                    AppLocalizations.of(context).addSlotChangeRole,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.tag10Semibold.copyWith(
                      color: labelColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: AppSpacing.vertical4),
          // 닉네임 영역 높이 맞춤용
          SizedBox(width: 72.w, height: AppTextStyles.tag_10.fontSize),
        ],
      ),
    );
  }
}
