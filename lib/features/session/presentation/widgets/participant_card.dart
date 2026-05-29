import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/character_assets.dart';
import '../../../../core/constants/game_team.dart';
import '../../../../core/constants/participant_status.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/theme/character_skin_provider.dart';
import '../../../lobby/data/models/lobby_event_dto.dart';

/// 참가자 카드 위젯
///
/// 대기실 팀 섹션 내 참가자를 표시합니다.
/// 아바타(72x84) + 닉네임, 방장은 왕관 아이콘 표시.
///
/// SVG 매핑 규칙:
/// - 게임방 도둑 수감([gameStatus] == `"JAILED"`) → `jailed.svg`
/// - 게임방 그 외 (ALIVE / POLICE_WAITING) → `ready.svg`
/// - 대기방 ([gameStatus] == null) → `isReady` 기반 `ready.svg` / `not_ready.svg`
///
/// 레디/비레디의 시각 구분은 SVG 파일 자체가 담당 (Opacity 미사용).
class ParticipantCard extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final skinId = ref.watch(characterSkinProvider);
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
                _resolveCharacterAssetPath(skinId),
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
                  SvgPicture.asset(
                    'assets/icons/icon_crown.svg',
                    width: 12.w,
                    height: 12.w,
                  ),
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
  /// 게임 시작 후에는 백엔드가 `isReady` 를 리셋(혹은 무의미해짐)하므로
  /// 게임방 컨텍스트(gameStatus != null)에서는 `isReady` 를 보지 않는다.
  /// JAILED 도둑만 수감 에셋, 나머지(ALIVE/POLICE_WAITING)는 활성으로 표시.
  ///
  /// 대기방에서는 방장이 레디 버튼이 없으므로 항상 레디로 취급한다.
  ///
  /// [skinId] 는 `characterSkinProvider` 가 제공하는 글로벌 스킨.
  String _resolveCharacterAssetPath(String skinId) {
    final team = GameTeam.toLowerKey(participant.team);

    // 게임방 컨텍스트
    if (gameStatus != null) {
      if (gameStatus == ParticipantStatus.jailed && GameTeam.isRobber(team)) {
        return characterAssetPath(
          team: GameTeam.toLowerKey(GameTeam.robber),
          skinId: skinId,
          state: 'jailed',
        );
      }
      return characterAssetPath(team: team, skinId: skinId, state: 'ready');
    }

    // 대기방 컨텍스트 — isReady 기반 분기
    final isReady = isHost || participant.isReady;
    final state = isReady ? 'ready' : 'not_ready';
    return characterAssetPath(team: team, skinId: skinId, state: state);
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
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/icon_change.svg',
                  width: 24.w,
                  height: 24.w,
                  colorFilter: ColorFilter.mode(
                    isDarkMode ? AppColors.black600 : AppColors.black400,
                    BlendMode.srcIn,
                  ),
                ),
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
