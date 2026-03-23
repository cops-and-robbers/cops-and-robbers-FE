import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/snackbars/app_snackbar.dart';
import '../../../lobby/data/models/lobby_event_dto.dart';
import '../../../session/data/models/in_game_participants_response.dart';
import '../../../session/presentation/providers/game_participant_provider.dart';
import '../../../session/presentation/providers/session_provider.dart';
import '../../../session/presentation/widgets/team_section.dart';
import '../providers/game_event_provider.dart';
import 'game_action_modal.dart';

/// 게임 중 참가자 목록 오버레이
///
/// 사람 버튼 클릭 시 지도 위에 표시되는 참가자 목록.
/// 대기실과 동일한 TeamSection + ParticipantCard 스타일.
/// 하단 우측에 지도 버튼으로 복귀.
class ParticipantOverlay extends ConsumerStatefulWidget {
  const ParticipantOverlay({
    required this.onClose,
    required this.gameId,
    required this.myTeam,
    required this.myParticipantId,
    this.isDarkMode = false,
    super.key,
  });

  final VoidCallback onClose;

  /// 게임 ID
  final int gameId;

  /// 현재 플레이어 팀 ("POLICE" 또는 "ROBBER")
  final String myTeam;

  /// 현재 플레이어 참가자 ID
  final int myParticipantId;

  /// 다크 모드 여부 (도둑팀)
  final bool isDarkMode;

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

  /// 경찰 역할 → ALIVE 도둑 카드 탭 시 체포 모달 표시
  void _onRobberCardTap(LobbyParticipantInfo member) {
    if (widget.myTeam != 'POLICE') return;

    // 경찰 대기 시간 중에는 체포 불가
    // 1차: STOMP POLICE_MOVE_START 이벤트 수신 여부
    // 2차: gameStartTime + policeWaitMinutes 시간 비교 (재연결 fallback)
    final gameEventState = ref.read(gameEventNotifierProvider);
    final participantInfo = ref.read(gameParticipantNotifierProvider);
    final isPoliceMoving = gameEventState.isPoliceMoving;
    final policeWaitMinutes = participantInfo?.policeWaitMinutes;

    // 시간 기반 판단: gameStartTime + policeWaitMinutes < now
    final gameStartTimeStr = participantInfo?.gameStartTime;
    final gameStartTime =
        gameEventState.gameStartTime ??
        (gameStartTimeStr != null ? DateTime.tryParse(gameStartTimeStr) : null);
    final isWaitTimeOver =
        policeWaitMinutes != null &&
        gameStartTime != null &&
        !DateTime.now().isBefore(
          gameStartTime.add(Duration(minutes: policeWaitMinutes)),
        );

    final canArrest =
        isPoliceMoving || isWaitTimeOver || policeWaitMinutes == 0;
    if (!canArrest) {
      AppSnackbar.show(context, message: '경찰 대기 시간 중에는 도둑을 체포할 수 없습니다.');
      return;
    }

    // JAILED 상태는 체포 불가
    final participant = _participants?.robbers.firstWhere(
      (p) => p.participantId == member.participantId,
      orElse: () => InGameParticipant(
        participantId: member.participantId,
        nickname: member.nickname,
        status: 'JAILED',
      ),
    );
    if (participant?.status == 'JAILED') return;

    GameActionModal.show(
      context: context,
      title: '해당 플레이어를 체포하셨나요?',
      message: '',
      confirmLabel: '네',
      nickname: member.nickname,
      onConfirm: () => ref
          .read(gameEventNotifierProvider.notifier)
          .arrestRobber(widget.gameId, member.participantId),
    );
  }

  /// 도둑팀 카드 탭 통합 핸들러
  ///
  /// - 경찰 역할: ALIVE 도둑 체포 모달 표시
  /// - 도둑 역할 + 본인 카드 + JAILED 상태: 탈옥 모달 표시
  void _onRobberTeamCardTap(LobbyParticipantInfo member) {
    if (widget.myTeam == 'POLICE') {
      _onRobberCardTap(member);
    } else {
      // 도둑 역할: 본인 카드 + JAILED 상태일 때만 탈옥
      if (member.participantId != widget.myParticipantId) return;
      if (!member.isReady) return; // isReady == true이 JAILED 상태

      GameActionModal.show(
        context: context,
        title: '탈옥',
        message: '탈옥을 시도하시겠습니까?',
        confirmLabel: '탈옥',
        isDarkMode: widget.isDarkMode,
        onConfirm: () => ref
            .read(gameEventNotifierProvider.notifier)
            .escape(widget.gameId, widget.myParticipantId),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(gameParticipantNotifierProvider);

    // 게임 이벤트 상태 구독 (체포/탈옥 상태 반영용)
    final gameEventState = ref.watch(gameEventNotifierProvider);
    final arrestedIds = gameEventState.arrestedParticipantIds;
    // 탈옥 낙관적 업데이트 반영용 (STOMP 이벤트 도착 전 즉시 UI 반영)
    final escapedIds = gameEventState.escapedParticipantIds;

    // 체포 이벤트 수신 시 참가자 목록 갱신
    ref.listen(gameEventNotifierProvider, (prev, next) {
      if (prev?.arrestedParticipantIds != next.arrestedParticipantIds ||
          prev?.escapedParticipantIds != next.escapedParticipantIds) {
        _loadParticipants();
      }
    });

    final policeMembers =
        _participants?.police
            .map((p) => _toParticipantInfo(p, isPolice: true))
            .toList() ??
        const [];

    // 체포/탈옥 낙관적 업데이트 + 서버 상태 통합 반영
    // - isArrested: 체포 낙관적 업데이트 또는 API 상태 'JAILED'
    // - isEscaped: 탈옥 낙관적 업데이트 (STOMP 이벤트 전 즉시 반영)
    final robberMembers =
        _participants?.robbers.map((p) {
          final isArrested = arrestedIds.contains(p.participantId);
          final isEscaped = escapedIds.contains(p.participantId);
          return LobbyParticipantInfo(
            participantId: p.participantId,
            nickname: p.nickname,
            team: 'ROBBER',
            isReady: (isArrested || p.status == 'JAILED') && !isEscaped,
          );
        }).toList() ??
        const [];

    // ALIVE 도둑 수 (도주 중)
    final aliveCount = robberMembers.where((m) => !m.isReady).length;

    return Container(
      color: widget.isDarkMode ? AppColors.black900 : AppColors.white,
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
              isDarkMode: widget.isDarkMode,
            ),
            Divider(
              height: 1,
              color: widget.isDarkMode
                  ? AppColors.black800
                  : AppColors.black200,
            ),
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
              onMemberTap: _onRobberTeamCardTap,
              isDarkMode: widget.isDarkMode,
            ),
          ],
        ),
      ),
    );
  }

  /// 도둑팀 헤더 배지: "현재 X명 도주 중!"
  Widget _buildRobberBadge(int count) {
    final badgeColor = widget.isDarkMode
        ? AppColors.green800
        : AppColors.blue800;
    final badgeBoldColor = widget.isDarkMode ? AppColors.green : AppColors.blue;
    return RichText(
      text: TextSpan(
        style: AppTextStyles.tag_12.copyWith(color: badgeColor),
        children: [
          const TextSpan(text: '현재 '),
          TextSpan(
            text: '$count명',
            style: AppTextStyles.tag_12.copyWith(
              color: badgeBoldColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const TextSpan(text: ' 도주 중!'),
        ],
      ),
    );
  }
}
