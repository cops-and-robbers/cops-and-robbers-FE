import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/loading/shimmer_participant_skeleton.dart';
import '../../../../core/widgets/snackbars/app_snackbar.dart';
import '../../../../core/constants/text_styles.dart';
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

  /// 체포/탈옥 낙관적 업데이트를 반영한 도둑의 유효 상태.
  /// STOMP 이벤트 도착 전에 UI 가 즉시 반영되도록 보정된 값을 반환한다.
  String _effectiveRobberStatus(
    InGameParticipant p, {
    required bool isArrested,
    required bool isEscaped,
  }) {
    if (isEscaped) return 'ALIVE';
    if (isArrested) return 'JAILED';
    return p.status;
  }

  /// 경찰 역할 → ALIVE 도둑 카드 탭 시 체포 모달 표시
  ///
  /// 실제 게임에서는 QR 스캔(대면 확인)으로만 체포 가능하다.
  /// 카드 탭 체포는 디버그 빌드 전용 — 시뮬레이터/에뮬레이터로 흐름을 검증하기 위함.
  void _onRobberCardTap(LobbyParticipantInfo member) {
    if (widget.myTeam != 'POLICE') return;
    if (!kDebugMode) return;

    final gameEventState = ref.read(gameEventNotifierProvider);
    final participantInfo = ref.read(gameParticipantNotifierProvider);

    if (!gameEventState.canPoliceArrest(participantInfo: participantInfo)) {
      AppSnackbar.show(
        context,
        message: AppLocalizations.of(context).dialogparticipantOverlayMessage,
      );
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

    FocusScope.of(context).unfocus();
    final l10n = AppLocalizations.of(context);
    GameActionModal.show(
      context: context,
      title: l10n.dialogparticipantOverlayTitle,
      message: '',
      confirmLabel: l10n.buttonYes,
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

      // 모달 닫힘 시 채팅 입력 TextField로 포커스가 복원되어
      // 채팅 시트가 올라오는 현상 방지
      FocusScope.of(context).unfocus();
      final l10n = AppLocalizations.of(context);
      GameActionModal.show(
        context: context,
        title: l10n.dialogparticipantOverlayTitle4167,
        message: l10n.dialogparticipantOverlayMessage9497,
        confirmLabel: l10n.buttonEscape,
        isDarkMode: widget.isDarkMode,
        onConfirm: () => ref
            .read(gameEventNotifierProvider.notifier)
            .escape(widget.gameId, widget.myParticipantId),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameInfo = ref.watch(gameParticipantNotifierProvider);
    final hostParticipantId = gameInfo?.hostParticipantId;

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

    // 게임방 컨텍스트에서 ParticipantCard 의 SVG 선택을 위한 상태 맵.
    // 낙관적 체포/탈옥 업데이트를 반영한 유효 상태 사용.
    final gameStatusMap = <int, String>{
      for (final p in _participants?.police ?? const <InGameParticipant>[])
        p.participantId: p.status,
      for (final p in _participants?.robbers ?? const <InGameParticipant>[])
        p.participantId: _effectiveRobberStatus(
          p,
          isArrested: arrestedIds.contains(p.participantId),
          isEscaped: escapedIds.contains(p.participantId),
        ),
    };

    // 참가자 데이터 로딩 중 → shimmer 스켈레톤 표시
    if (_participants == null) {
      return Container(
        color: widget.isDarkMode ? AppColors.black900 : AppColors.white,
        child: ShimmerParticipantSkeleton(isDarkMode: widget.isDarkMode),
      );
    }

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
              isExpanded: _isPoliceExpanded,
              onToggle: () =>
                  setState(() => _isPoliceExpanded = !_isPoliceExpanded),
              hostParticipantId: hostParticipantId,
              myParticipantId: widget.myParticipantId,
              badge: const SizedBox.shrink(),
              isDarkMode: widget.isDarkMode,
              gameStatusByParticipantId: gameStatusMap,
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
              isExpanded: _isRobberExpanded,
              onToggle: () =>
                  setState(() => _isRobberExpanded = !_isRobberExpanded),
              hostParticipantId: hostParticipantId,
              myParticipantId: widget.myParticipantId,
              badge: _participants != null
                  ? _buildRobberBadge(aliveCount)
                  : null,
              onMemberTap: _onRobberTeamCardTap,
              isDarkMode: widget.isDarkMode,
              gameStatusByParticipantId: gameStatusMap,
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
    final l10n = AppLocalizations.of(context);
    return RichText(
      text: TextSpan(
        style: AppTextStyles.tag_12.copyWith(color: badgeColor),
        children: [
          TextSpan(text: '${l10n.gameParticipantOverlayCurrent} '),
          TextSpan(
            text: l10n.gameParticipantOverlayCount(count),
            style: AppTextStyles.tag_12.copyWith(
              color: badgeBoldColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(text: ' ${l10n.gameRobberStatusEscaping}'),
        ],
      ),
    );
  }
}
