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
    this.onEmptySlotTap,
    this.badge,
    this.onMemberTap,
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

  /// 빈 슬롯 탭 콜백 (더미 모드 팀 변경용)
  final VoidCallback? onEmptySlotTap;

  /// 팀명 옆 배지 위젯 (null이면 인원 카운트 표시)
  ///
  /// 예: "현재 X명 도주 중!" 텍스트 (인게임 참가자 오버레이용)
  final Widget? badge;

  /// 참가자 카드 탭 콜백 (null이면 탭 비활성화)
  ///
  /// 인게임 오버레이에서 체포/탈옥 액션 트리거에 사용됩니다.
  final void Function(LobbyParticipantInfo)? onMemberTap;

  bool get _isPolice => team.toUpperCase() == 'POLICE';

  String get _teamName => _isPolice ? '경찰팀' : '도둑팀';

  String get _iconPath => _isPolice
      ? 'assets/icons/icon_police.svg'
      : 'assets/icons/icon_robber.svg';

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
            // 팀 아이콘 (28x28)
            SvgPicture.asset(
              _iconPath,
              width: 28.w,
              height: 28.w,
              colorFilter: ColorFilter.mode(
                _isPolice ? AppColors.blue : AppColors.black900,
                BlendMode.srcIn,
              ),
            ),
            // 팀명 (아이콘에서 8px)
            SizedBox(width: 8.w),
            Text(
              _teamName,
              style: AppTextStyles.label_16.copyWith(color: AppColors.black),
            ),
            // 배지 또는 정원 카운트 (팀명에서 4~8px)
            if (badge != null) ...[
              SizedBox(width: 8.w),
              badge!,
            ] else ...[
              SizedBox(width: 4.w),
              Text(
                '(${members.length}/$maxPerTeam)',
                style: AppTextStyles.label_16.copyWith(
                  color: AppColors.black400,
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipants() {
    return Padding(
      // 첫 카드 좌측 29px
      padding: EdgeInsets.only(left: 29.w, right: 24.w, bottom: 20.h),
      child: Wrap(
        spacing: 16.w, // 카드 간 가로 여백 16px
        runSpacing: 16.h, // 줄 간 세로 여백
        children: List.generate(maxPerTeam, (index) {
          if (index < members.length) {
            final member = members[index];
            return ParticipantCard(
              participant: member,
              isHost: member.participantId == hostParticipantId,
              onTap: onMemberTap != null ? () => onMemberTap!(member) : null,
            );
          }
          return EmptySlotCard(onTap: onEmptySlotTap);
        }),
      ),
    );
  }
}
