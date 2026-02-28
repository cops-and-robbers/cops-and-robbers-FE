import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../lobby/data/models/lobby_event_dto.dart';
import '../../../session/data/models/in_game_participants_response.dart';
import '../../../session/presentation/providers/game_participant_provider.dart';
import '../../../session/presentation/providers/session_provider.dart';
import '../../../session/presentation/widgets/team_section.dart';

/// 게임 중 참가자 목록 오버레이
///
/// 사람 버튼 클릭 시 지도 위에 표시되는 참가자 목록.
/// 대기실과 동일한 TeamSection + ParticipantCard 스타일.
/// 하단 우측에 지도 버튼으로 복귀.
class ParticipantOverlay extends ConsumerStatefulWidget {
  const ParticipantOverlay({required this.onClose, super.key});

  final VoidCallback onClose;

  @override
  ConsumerState<ParticipantOverlay> createState() => _ParticipantOverlayState();
}

class _ParticipantOverlayState extends ConsumerState<ParticipantOverlay> {
  bool _isPoliceExpanded = false;
  bool _isRobberExpanded = true;

  InGameParticipantsResponse? _participants;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadParticipants());
  }

  Future<void> _loadParticipants() async {
    if (!mounted) return;
    final gameInfo = ref.read(gameParticipantNotifierProvider);
    if (gameInfo == null) return;
    try {
      final result = await ref.read(
        fetchGameParticipantsProvider(gameInfo.gameId).future,
      );
      if (!mounted) return;
      setState(() => _participants = result);
    } catch (e) {
      debugPrint('[ParticipantOverlay] 참가자 조회 실패: $e');
    }
  }

  /// [InGameParticipant] → [LobbyParticipantInfo] 변환
  ///
  /// - 경찰 (POLICE_WAITING): isReady: true
  /// - 도둑 ALIVE: isReady: false (도주 중)
  /// - 도둑 JAILED: isReady: true (레디 카드 색상으로 수감 표시)
  LobbyParticipantInfo _toParticipantInfo(
    InGameParticipant p, {
    required bool isPolice,
  }) {
    final isReady = isPolice || p.status == 'JAILED';
    return LobbyParticipantInfo(
      participantId: p.participantId,
      nickname: p.nickname,
      team: isPolice ? 'POLICE' : 'ROBBER',
      isReady: isReady,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(gameParticipantNotifierProvider);

    final policeMembers =
        _participants?.police
            .map((p) => _toParticipantInfo(p, isPolice: true))
            .toList() ??
        const [];
    final robberMembers =
        _participants?.robbers
            .map((p) => _toParticipantInfo(p, isPolice: false))
            .toList() ??
        const [];

    // ALIVE 도둑 수 (도주 중)
    final aliveCount =
        _participants?.robbers.where((p) => p.status == 'ALIVE').length ?? 0;

    return Container(
      color: AppColors.white,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 경찰팀 섹션 (인원 카운트·빈 슬롯 미표시)
            TeamSection(
              team: 'POLICE',
              members: policeMembers,
              maxPerTeam: policeMembers.length,
              isExpanded: _isPoliceExpanded,
              onToggle: () =>
                  setState(() => _isPoliceExpanded = !_isPoliceExpanded),
              badge: const SizedBox.shrink(),
            ),
            Divider(height: 1, color: AppColors.black200),
            // 도둑팀 섹션 (도주 중 배지 표시, 빈 슬롯 미표시)
            TeamSection(
              team: 'ROBBER',
              members: robberMembers,
              maxPerTeam: robberMembers.length,
              isExpanded: _isRobberExpanded,
              onToggle: () =>
                  setState(() => _isRobberExpanded = !_isRobberExpanded),
              badge: _participants != null
                  ? _buildRobberBadge(aliveCount)
                  : null,
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
