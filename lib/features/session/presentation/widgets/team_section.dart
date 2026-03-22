import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../lobby/data/models/lobby_event_dto.dart';
import 'participant_card.dart';

/// 팀 섹션 위젯
///
/// 대기실에서 경찰팀/도둑팀 섹션을 표시합니다.
/// 헤더 탭으로 접기/펼치기, 참가자 카드를 Wrap으로 표시.
class TeamSection extends StatelessWidget {
  const TeamSection({
    required this.team,
    required this.members,
    required this.maxPerTeam,
    required this.isExpanded,
    required this.onToggle,
    this.hostParticipantId,
    this.myParticipantId,
    this.onAddSlotTap,
    this.badge,
    this.onMemberTap,
    this.isDarkMode = false,
    super.key,
  });

  /// "POLICE" 또는 "ROBBER"
  final String team;

  /// 해당 팀 참가자 목록
  final List<LobbyParticipantInfo> members;

  /// 팀당 최대 인원
  final int maxPerTeam;

  /// 펼침 상태
  final bool isExpanded;

  /// 접기/펼치기 콜백
  final VoidCallback onToggle;

  /// 방장 participantId
  final int? hostParticipantId;

  /// 현재 사용자 participantId (닉네임 볼드 처리용)
  final int? myParticipantId;

  /// + 버튼 카드 탭 콜백 (팀 변경용)
  final VoidCallback? onAddSlotTap;

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

  bool get _isPolice => team.toUpperCase() == 'POLICE';

  String get _teamName => _isPolice ? '경찰팀' : '도둑팀';

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
    return Column(
      children: [
        _buildHeader(),
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

  Widget _buildHeader() {
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
              _teamName,
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
                '현재 ${members.length}명',
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
    final hasAddSlot = onAddSlotTap != null;
    final emptyCount = maxPerTeam - members.length - (hasAddSlot ? 1 : 0);
    // 방장을 맨 앞으로 정렬
    final sorted = [...members]
      ..sort((a, b) {
        if (a.participantId == hostParticipantId) return -1;
        if (b.participantId == hostParticipantId) return 1;
        return 0;
      });

    return Padding(
      // 첫 카드 좌측 29px
      padding: EdgeInsets.only(left: 29.w, right: 24.w, bottom: 20.h),
      child: Wrap(
        spacing: 16.w, // 카드 간 가로 여백 16px
        runSpacing: 16.h, // 줄 간 세로 여백
        children: [
          // 첫 번째 칸: + 버튼 카드 (대기실에서만 표시)
          if (hasAddSlot)
            AddSlotCard(onTap: onAddSlotTap, isDarkMode: isDarkMode),
          // 참가자 카드 (방장 우선)
          ...sorted.map(
            (member) => ParticipantCard(
              participant: member,
              isHost: member.participantId == hostParticipantId,
              isMe: member.participantId == myParticipantId,
              isDarkMode: isDarkMode,
              onTap: onMemberTap != null ? () => onMemberTap!(member) : null,
            ),
          ),
          // 나머지 빈 슬롯 (탭 비활성화)
          if (emptyCount > 0)
            ...List.generate(
              emptyCount,
              (_) => EmptySlotCard(isDarkMode: isDarkMode),
            ),
        ],
      ),
    );
  }
}
