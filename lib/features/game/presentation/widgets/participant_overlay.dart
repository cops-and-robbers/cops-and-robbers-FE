import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../lobby/data/models/lobby_event_dto.dart';
import '../../../session/presentation/widgets/team_section.dart';

/// 게임 중 참가자 목록 오버레이
///
/// 사람 버튼 클릭 시 지도 위에 표시되는 참가자 목록.
/// 대기실과 동일한 TeamSection + ParticipantCard 스타일.
/// 하단 우측에 지도 버튼으로 복귀.
class ParticipantOverlay extends StatefulWidget {
  const ParticipantOverlay({required this.onClose, super.key});

  final VoidCallback onClose;

  @override
  State<ParticipantOverlay> createState() => _ParticipantOverlayState();
}

class _ParticipantOverlayState extends State<ParticipantOverlay> {
  bool _isPoliceExpanded = false;
  bool _isRobberExpanded = true;

  // TODO: 게임 상태(GameParticipantProvider 또는 인게임 이벤트) 기반으로
  //   실제 참가자 목록으로 교체. ConsumerStatefulWidget으로 전환 필요.
  static final List<LobbyParticipantInfo> _dummyPolice = [
    const LobbyParticipantInfo(
      participantId: 1,
      nickname: '경찰1',
      team: 'POLICE',
      isReady: true,
    ),
    const LobbyParticipantInfo(
      participantId: 2,
      nickname: '경찰2',
      team: 'POLICE',
      isReady: true,
    ),
    const LobbyParticipantInfo(
      participantId: 3,
      nickname: '경찰3',
      team: 'POLICE',
      isReady: true,
    ),
  ];

  static final List<LobbyParticipantInfo> _dummyRobber = [
    const LobbyParticipantInfo(
      participantId: 101,
      nickname: '도둑1',
      team: 'ROBBER',
      isReady: true,
    ),
    const LobbyParticipantInfo(
      participantId: 102,
      nickname: '도둑2',
      team: 'ROBBER',
      isReady: true,
    ),
    const LobbyParticipantInfo(
      participantId: 103,
      nickname: '도둑3',
      team: 'ROBBER',
      isReady: true,
    ),
    const LobbyParticipantInfo(
      participantId: 104,
      nickname: '도둑4',
      team: 'ROBBER',
      isReady: true,
    ),
    const LobbyParticipantInfo(
      participantId: 105,
      nickname: '도둑5',
      team: 'ROBBER',
      isReady: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 경찰팀 섹션
            TeamSection(
              team: 'POLICE',
              // TODO: 인게임 게임 상태 기반 실제 경찰 참가자 목록으로 교체
              members: _dummyPolice,
              maxPerTeam: _dummyPolice.length,
              isExpanded: _isPoliceExpanded,
              onToggle: () =>
                  setState(() => _isPoliceExpanded = !_isPoliceExpanded),
            ),
            Divider(height: 1, color: AppColors.black200),
            // 도둑팀 섹션 (도주 중 배지 표시)
            TeamSection(
              team: 'ROBBER',
              // TODO: 인게임 이벤트 기반으로 실제 도둑 참가자 목록으로 교체
              members: _dummyRobber,
              maxPerTeam: _dummyRobber.length,
              isExpanded: _isRobberExpanded,
              onToggle: () =>
                  setState(() => _isRobberExpanded = !_isRobberExpanded),
              badge: _buildRobberBadge(_dummyRobber.length),
            ),
          ],
        ),
      ),
    );
  }

  /// 도둑팀 헤더 배지: "현재 X명 도주 중!"
  Widget _buildRobberBadge(int count) {
    return RichText(
      text: TextSpan(
        style: AppTextStyles.tag_12.copyWith(color: AppColors.blue),
        children: [
          const TextSpan(text: '현재 '),
          TextSpan(
            // TODO: 인게임 이벤트 기반으로 실제 도주 중인 도둑 수 표시
            text: '$count명',
            style: AppTextStyles.tag_12.copyWith(
              color: AppColors.blue800,
              fontWeight: FontWeight.w700,
            ),
          ),
          const TextSpan(text: ' 도주 중!'),
        ],
      ),
    );
  }
}
