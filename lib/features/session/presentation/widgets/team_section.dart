import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../lobby/data/models/lobby_event_dto.dart';
import 'participant_card.dart';

/// 대기실 / 게임방 참가자 정렬 규칙
///
/// 방장 → 본인 → 나머지(서버 수신 순서 유지) 순으로 정렬한다.
///
/// `where`를 세 번 사용해 각 그룹을 필터링 후 합치는 방식을 택한 이유:
/// `List.sort`는 Dart에서 stable이 보장되지 않아 "나머지" 그룹 내부 순서가
/// 뒤섞일 수 있다. 팀 변경 시 해당 유저가 "새 팀 맨 뒤"로 밀리는 기존 동작을
/// 유지하려면 원본 순서 보존이 필수.
///
/// `@visibleForTesting`: UI 렌더링 없이 순수 정렬 로직만 단위 테스트.
@visibleForTesting
List<LobbyParticipantInfo> sortParticipantsForDisplay(
  List<LobbyParticipantInfo> members, {
  required int? hostParticipantId,
  required int? myParticipantId,
}) {
  final host = members.where((p) => p.participantId == hostParticipantId);
  // 내가 방장이면 host 그룹에 이미 포함됐으므로 me 그룹에서 제외 (중복 방지)
  final me = members.where(
    (p) =>
        p.participantId == myParticipantId &&
        p.participantId != hostParticipantId,
  );
  final others = members.where(
    (p) =>
        p.participantId != hostParticipantId &&
        p.participantId != myParticipantId,
  );
  return [...host, ...me, ...others];
}

/// 팀 섹션 위젯
///
/// 대기실에서 경찰팀/도둑팀 섹션을 표시합니다.
/// 헤더 탭으로 접기/펼치기, 참가자 카드를 Wrap으로 표시.
class TeamSection extends StatelessWidget {
  const TeamSection({
    required this.team,
    required this.members,
    required this.isExpanded,
    required this.onToggle,
    this.hostParticipantId,
    this.myParticipantId,
    this.currentUserTeam,
    this.onAddSlotTap,
    this.addSlotKey,
    this.badge,
    this.onMemberTap,
    this.isDarkMode = false,
    this.gameStatusByParticipantId,
    super.key,
  });

  /// "POLICE" 또는 "ROBBER"
  final String team;

  /// 해당 팀 참가자 목록
  final List<LobbyParticipantInfo> members;

  /// 펼침 상태
  final bool isExpanded;

  /// 접기/펼치기 콜백
  final VoidCallback onToggle;

  /// 방장 participantId
  final int? hostParticipantId;

  /// 현재 사용자 participantId (닉네임 볼드 처리용)
  final int? myParticipantId;

  /// 현재 사용자가 속한 팀 ("POLICE" / "ROBBER").
  ///
  /// 대기실에서 내 팀 섹션의 `AddSlotCard`(팀 변경 카드) 를 숨기는 용도.
  /// null 이면 양쪽 모두 숨김 (참가자 정보 로딩 전).
  /// 인게임 오버레이처럼 팀 변경이 불가능한 컨텍스트에서는 전달하지 않아도 된다
  /// (`onAddSlotTap` 이 null 이므로 `AddSlotCard` 자체가 렌더링되지 않음).
  final String? currentUserTeam;

  /// + 버튼 카드 탭 콜백 (팀 변경용)
  final VoidCallback? onAddSlotTap;

  /// + 버튼 카드 GlobalKey (튜토리얼 하이라이트용)
  final GlobalKey? addSlotKey;

  /// 팀명 옆 배지 위젯 (null이면 인원 카운트 표시)
  ///
  /// 예: "현재 X명 도주 중!" 텍스트 (인게임 참가자 오버레이용)
  final Widget? badge;

  /// 참가자 카드 탭 콜백 (null이면 탭 비활성화)
  ///
  /// 인게임 오버레이에서 체포/탈옥 액션 트리거에 사용됩니다.
  final void Function(LobbyParticipantInfo)? onMemberTap;

  /// 다크 모드 여부 (도둑팀 = 다크)
  final bool isDarkMode;

  /// 게임방 컨텍스트에서 각 참가자의 상태(`"ALIVE"`/`"JAILED"`/`"POLICE_WAITING"`).
  ///
  /// null 이거나 특정 참가자 키가 없으면 해당 카드는 대기방 모드로 렌더링됨.
  /// 인게임 오버레이에서만 채워지고, 대기실 팀 섹션에서는 생략된다.
  final Map<int, String>? gameStatusByParticipantId;

  bool get _isPolice => team.toUpperCase() == 'POLICE';

  String _teamName(AppLocalizations l10n) =>
      _isPolice ? l10n.gameTeamCop : l10n.gameTeamRobber;

  String get _iconPath {
    if (_isPolice) {
      return isDarkMode
          ? 'assets/icons/icon_police_darkmode.svg'
          : 'assets/icons/icon_police_lightmode.svg';
    }
    return isDarkMode
        ? 'assets/icons/mdi_robber_darkmode.svg'
        : 'assets/icons/mdi_robber_lightmode.svg';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        _buildHeader(l10n),
        ClipRect(
          child: AnimatedAlign(
            alignment: Alignment.topLeft,
            heightFactor: isExpanded ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: _buildParticipants(),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        // 아이콘 좌측 24px, chevron 우측 24px, 앱바 아래 16px
        padding: EdgeInsets.only(
          left: 24.w,
          right: 24.w,
          top: 16.h,
          bottom: 16.h,
        ),
        child: Row(
          children: [
            // 팀 아이콘 (28x28) — SVG에 색상 내장, colorFilter 불필요
            SvgPicture.asset(_iconPath, width: 28.w, height: 28.w),
            // 팀명 (아이콘에서 8px)
            SizedBox(width: 8.w),
            Text(
              _teamName(l10n),
              style: isDarkMode
                  ? AppTextStyles.robberLabel.copyWith(color: AppColors.white)
                  : AppTextStyles.label_16.copyWith(color: AppColors.black),
            ),
            // 배지 또는 정원 카운트 (팀명에서 4~8px)
            if (badge != null) ...[
              SizedBox(width: 8.w),
              badge!,
            ] else ...[
              SizedBox(width: 4.w),
              Text(
                l10n.teamSectionCurrentCount(members.length),
                style: AppTextStyles.tag_12.copyWith(
                  color: isDarkMode ? AppColors.black400 : AppColors.black600,
                ),
              ),
            ],
            const Spacer(),
            // chevron (24x24, 우측 24px)
            AnimatedRotation(
              turns: isExpanded ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 250),
              child: SvgPicture.asset(
                'assets/icons/icon_down.svg',
                width: 24.w,
                height: 24.w,
                colorFilter: isDarkMode
                    ? const ColorFilter.mode(
                        AppColors.black400,
                        BlendMode.srcIn,
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipants() {
    // 팀 변경 카드는 "반대 팀 섹션" 에서만 표시한다.
    // currentUserTeam 이 null (참가자 로딩 전) 이면 양쪽 모두 숨김.
    final isOpponentSection =
        currentUserTeam != null && currentUserTeam != team;
    final hasAddSlot = onAddSlotTap != null && isOpponentSection;
    // 방장 → 본인 → 나머지(수신 순서 유지)
    final sorted = sortParticipantsForDisplay(
      members,
      hostParticipantId: hostParticipantId,
      myParticipantId: myParticipantId,
    );

    return Padding(
      // 첫 카드 좌측 29px
      padding: EdgeInsets.only(left: 30.w, right: 24.w, bottom: 20.h),
      child: Wrap(
        spacing: 16.w, // 카드 간 가로 여백 16px
        runSpacing: 16.h, // 줄 간 세로 여백
        children: [
          // 첫 번째 칸: + 버튼 카드 (대기실에서만 표시)
          if (hasAddSlot)
            AddSlotCard(
              key: addSlotKey,
              onTap: onAddSlotTap,
              isDarkMode: isDarkMode,
            ),
          // 참가자 카드 (방장 우선)
          ...sorted.map(
            (member) => ParticipantCard(
              participant: member,
              isHost: member.participantId == hostParticipantId,
              isMe: member.participantId == myParticipantId,
              isDarkMode: isDarkMode,
              gameStatus: gameStatusByParticipantId?[member.participantId],
              onTap: onMemberTap != null ? () => onMemberTap!(member) : null,
            ),
          ),
        ],
      ),
    );
  }
}
