import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/dialogs/app_dialog.dart';
import '../../../../router/route_paths.dart';
import '../../../lobby/data/models/lobby_event_dto.dart';
import '../../../lobby/presentation/providers/lobby_provider.dart';
import '../providers/game_participant_provider.dart';
import '../providers/session_provider.dart';
import '../providers/waiting_room_participants_provider.dart';
import '../widgets/game_rules_content.dart';
import '../widgets/team_section.dart';

/// 대기실 화면
///
/// 게임 시작 전 참가자들이 팀을 선택하고 준비 완료를 표시합니다.
class WaitingRoomPage extends ConsumerStatefulWidget {
  const WaitingRoomPage({
    required this.sessionId,
    this.inviteCode,
    this.showInviteDialog = false,
    super.key,
  });

  /// 게임 세션 ID
  final String sessionId;

  /// 초대 코드 (앱바 표시용, 예: "HJRVBD")
  final String? inviteCode;

  /// 방 생성 직후 초대코드 모달 표시 여부
  final bool showInviteDialog;

  @override
  ConsumerState<WaitingRoomPage> createState() => _WaitingRoomPageState();
}

class _WaitingRoomPageState extends ConsumerState<WaitingRoomPage>
    with WidgetsBindingObserver {
  /// 팀 섹션 펼침 상태
  bool _isPoliceExpanded = false;
  bool _isRobberExpanded = false;

  /// 준비 상태
  bool _isReady = false;
  bool _isUpdatingReady = false;

  /// 더미 모드 여부
  bool get _isDummyMode => int.tryParse(widget.sessionId) == null;

  /// 더미 모드에서 "나"의 participantId
  static const _dummyMyId = 3;

  /// 선택된 지도 타입 (방장이 게임 시작 시 사용)
  // TODO: 지도 선택 UI 추가 시 변경 가능하도록
  final String _selectedMapType = 'google';

  /// 로비 이벤트 구독 (dispose 시 명시적 해제)
  ProviderSubscription<LobbyState>? _lobbyEventSub;

  /// 팀당 최대 인원 (maxParticipants 기반, 홀수 시 도둑 +1)
  ///
  /// TODO(로비 조회 API): 현재 참가자(isHost=false)는 joinGame 응답에 maxParticipants가 없어
  /// 기본값 10이 적용됨. 로비 조회 API 연동 후 실제 값으로 교체 필요.
  int get _maxPolice {
    final max =
        ref.read(gameParticipantNotifierProvider)?.maxParticipants ?? 10;
    return max ~/ 2;
  }

  int get _maxRobber {
    final max =
        ref.read(gameParticipantNotifierProvider)?.maxParticipants ?? 10;
    return (max + 1) ~/ 2;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 페이지 전환 타이밍에 따라 이전 로비의 state가 남아있을 수 있으므로
      // 연결 시작 전 반드시 먼저 초기화
      // TODO(전체 조회 API): API 연동 후에는 이 clear()가 필요 없어지므로 제거하고
      // API 응답으로 초기 참가자 목록을 채우도록 변경
      ref.read(waitingRoomParticipantsProvider.notifier).clear();
      _connectLobby();
      _listenLobbyEvents();
      if (widget.showInviteDialog && widget.inviteCode != null) {
        _showInviteCodeDialog();
      }
    });
  }

  @override
  void dispose() {
    _lobbyEventSub?.close();
    _lobbyEventSub = null;
    WidgetsBinding.instance.removeObserver(this);
    ref.read(lobbyNotifierProvider.notifier).disconnectLobby();
    ref.read(waitingRoomParticipantsProvider.notifier).clear();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      // 앱 종료 시 best-effort로 퇴장 시도
      final gameId = int.tryParse(widget.sessionId);
      if (gameId != null) {
        ref.read(leaveGameProvider(gameId).future);
      }
    }
  }

  /// Lobby STOMP 연결 및 구독
  ///
  /// TODO(전체 조회 API): STOMP 연결 후 즉시 API를 호출하여 초기 상태를 세팅하도록 교체.
  /// 교체 후에는 _listenLobbyEvents()의 "방장 participantId 자동 감지" 블록이
  /// pInfo?.participantId != null 조건으로 자동 스킵되므로 별도 제거 없이 무해.
  ///
  /// 교체 코드 (async로 변경 필요):
  /// ```dart
  /// await ref.read(lobbyNotifierProvider.notifier).connectAndSubscribe(...);
  ///
  /// final result = await ref.read(fetchLobbyInfoProvider(gameId).future);
  ///
  /// ref.read(waitingRoomParticipantsProvider.notifier).initFromApi(
  ///   participants: result.participants,
  ///   hostParticipantId: result.hostParticipantId,
  /// );
  /// ref.read(gameParticipantNotifierProvider.notifier).initFromLobby(
  ///   participantId: result.myParticipantId,
  ///   maxParticipants: result.maxParticipants,
  ///   locationRevealIntervalMinutes: result.locationRevealIntervalMinutes,
  /// );
  /// ```
  void _connectLobby() {
    final gameId = int.tryParse(widget.sessionId);
    if (gameId == null) {
      // 숫자가 아닌 sessionId (임시 UI 확인용) → 더미 데이터 + 방장으로 세팅
      ref.read(waitingRoomParticipantsProvider.notifier).loadDummyData();
      ref
          .read(gameParticipantNotifierProvider.notifier)
          .setGameInfo(
            gameId: 0,
            nickname: '포근포근곰...',
            participantId: _dummyMyId,
            isHost: true,
          );
      return;
    }

    ref
        .read(lobbyNotifierProvider.notifier)
        .connectAndSubscribe(gameId: gameId, onGameStart: _onGameStartEvent);
  }

  /// 로비 이벤트 → 참가자 목록 업데이트
  void _listenLobbyEvents() {
    _lobbyEventSub = ref.listenManual(lobbyNotifierProvider, (prev, next) {
      final event = next.lastEvent;
      if (event != null && event != prev?.lastEvent) {
        // ── 방장 participantId 자동 감지 (전체 조회 API 연동 전 임시) ──
        // 전체 조회 API 연동 후에는 pInfo?.participantId가 null이 아니므로 자동 스킵됨.
        //
        // 원리: 방장은 자신의 ENTER 이벤트를 받지 않아 participants 목록에 없음.
        //       handleLobbyEvent() 호출 전 목록을 확인하여,
        //       ENTER 없이 처음 등장하는 TEAM_UPDATE/READY_UPDATE 발신자 = 방장.
        final pInfo = ref.read(gameParticipantNotifierProvider);
        if (pInfo?.isHost == true && pInfo?.participantId == null) {
          if (event.type == LobbyEventType.teamUpdate ||
              event.type == LobbyEventType.readyUpdate) {
            final participant = _extractEventParticipant(event.data);
            final eventPid = participant['participantId'] as int?;
            if (eventPid != null) {
              final alreadyKnown = ref
                  .read(waitingRoomParticipantsProvider)
                  .participants
                  .any((p) => p.participantId == eventPid);
              if (!alreadyKnown) {
                ref
                    .read(gameParticipantNotifierProvider.notifier)
                    .setParticipantId(eventPid);
                ref
                    .read(waitingRoomParticipantsProvider.notifier)
                    .setHost(eventPid);
              }
            }
          }
        }

        // 이벤트 처리 (참가자 목록 업데이트)
        ref
            .read(waitingRoomParticipantsProvider.notifier)
            .handleLobbyEvent(event);

        final myPid = ref.read(gameParticipantNotifierProvider)?.participantId;

        // 팀 변경 이벤트 시 gameParticipantNotifier 동기화
        if (event.type == LobbyEventType.teamUpdate) {
          final participant = _extractEventParticipant(event.data);
          final changedPid = participant['participantId'] as int?;
          if (myPid != null && myPid == changedPid) {
            final newTeam = participant['team'] as String?;
            if (newTeam != null) {
              ref
                  .read(gameParticipantNotifierProvider.notifier)
                  .setTeam(newTeam);
            }
          }
        }

        // 방장 변경 이벤트 시 isHost 동기화
        if (event.type == LobbyEventType.hostChanged) {
          final participant = _extractEventParticipant(event.data);
          final newHostId = participant['participantId'] as int?;
          if (newHostId != null && myPid != null) {
            ref
                .read(gameParticipantNotifierProvider.notifier)
                .setIsHost(myPid == newHostId);
            // hostParticipantId도 동기화
            ref
                .read(waitingRoomParticipantsProvider.notifier)
                .setHost(newHostId);
          }
        }
      }
    });
  }

  /// 이벤트 data에서 participant 정보 추출
  ///
  /// 서버 이벤트별 키: newParticipant(ENTER), newHost(HOST_CHANGED), participant(기타)
  Map<String, dynamic> _extractEventParticipant(Map<String, dynamic> data) {
    for (final key in ['newParticipant', 'newHost', 'participant']) {
      if (data.containsKey(key) && data[key] is Map) {
        return data[key] as Map<String, dynamic>;
      }
    }
    return data;
  }

  /// GAME_START 이벤트 수신 시 호출
  void _onGameStartEvent(LobbyEventDto event) {
    final participantInfo = ref.read(gameParticipantNotifierProvider);
    final team = participantInfo?.team ?? 'POLICE';
    final participantId = participantInfo?.participantId ?? 0;
    final mapType = _selectedMapType;

    final route =
        '${RoutePaths.gameWithId(widget.sessionId)}?mapType=$mapType&team=$team&pid=$participantId';

    if (mounted) {
      context.go(route);
    }
  }

  /// 팀 변경
  Future<void> _changeTeam(String targetTeam) async {
    // 더미 모드
    if (_isDummyMode) {
      ref
          .read(waitingRoomParticipantsProvider.notifier)
          .changeDummyTeam(_dummyMyId, targetTeam);
      return;
    }

    final gameId = int.tryParse(widget.sessionId);
    if (gameId == null) return;

    final success = await ref.read(
      changeTeamProvider(gameId, targetTeam: targetTeam).future,
    );

    if (!success && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('팀 변경에 실패했습니다.')));
    }
  }

  /// 준비 상태 토글
  Future<void> _toggleReady() async {
    // 더미 모드: 로컬에서 즉시 토글
    if (_isDummyMode) {
      ref
          .read(waitingRoomParticipantsProvider.notifier)
          .toggleDummyReady(_dummyMyId);
      setState(() => _isReady = !_isReady);
      return;
    }

    final gameId = int.tryParse(widget.sessionId);
    if (gameId == null) return;

    setState(() => _isUpdatingReady = true);

    final newReadyState = !_isReady;
    final success = await ref.read(
      updateReadyProvider(gameId, isReady: newReadyState).future,
    );

    if (success) {
      setState(() => _isReady = newReadyState);
    } else if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('준비 상태 변경에 실패했습니다.')));
    }

    setState(() => _isUpdatingReady = false);
  }

  /// 게임 시작 (방장 전용)
  Future<void> _startGame() async {
    if (_isDummyMode) {
      if (mounted) {
        context.go(
          '${RoutePaths.gameWithId('1')}?mapType=$_selectedMapType&team=POLICE&pid=$_dummyMyId&dummy=true',
        );
      }
      return;
    }

    final gameId = int.tryParse(widget.sessionId);
    if (gameId == null) return;

    // TODO: 지도 선택 UI 추가 시 _selectedMapType 변경
    final success = await ref.read(startGameProvider(gameId).future);

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('게임 시작에 실패했습니다. 모든 참가자가 준비되었는지 확인해주세요.')),
      );
    }
  }

  /// 방 나가기
  Future<void> _leaveRoom() async {
    final gameId = int.tryParse(widget.sessionId);
    if (gameId != null) {
      await ref.read(leaveGameProvider(gameId).future);
    }
    ref.read(gameParticipantNotifierProvider.notifier).clear();
    if (mounted) {
      context.go(RoutePaths.home);
    }
  }

  /// 게임 규칙 다이얼로그
  ///
  /// TODO(로비 조회 API): 현재 참가자(isHost=false)는 locationRevealIntervalMinutes가 null.
  /// 로비 조회 API 연동 후 실제 값이 채워지면 다이얼로그에 정상 표시됨.
  void _showGameRulesDialog() {
    final interval = ref
        .read(gameParticipantNotifierProvider)
        ?.locationRevealIntervalMinutes;
    AppDialog.show(
      context: context,
      title: '게임 규칙',
      customContent: GameRulesContent(locationRevealIntervalMinutes: interval),
      confirmText: '확인했어요!',
      confirmColor: AppColors.blue,
      confirmTextColor: AppColors.white,
    );
  }

  /// 초대코드 모달 (방 생성 직후 표시)
  void _showInviteCodeDialog() {
    final code = widget.inviteCode!;

    AppDialog.show(
      context: context,
      title: '초대코드를 생성했어요',
      message: '친구에게 코드를 공유하고 게임에 참여해 보세요!',
      customContent: Container(
        height: 64.h,
        decoration: BoxDecoration(
          color: AppColors.black100,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              code,
              style: AppTextStyles.heading_20.copyWith(color: AppColors.black),
            ),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: code));
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('초대코드가 복사되었습니다')));
              },
              child: SvgPicture.asset(
                'assets/icons/icon_copy.svg',
                width: 20.w,
                height: 20.w,
                colorFilter: const ColorFilter.mode(
                  AppColors.black400,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ],
        ),
      ),
      cancelText: '닫기',
      confirmText: '공유하기',
      confirmColor: AppColors.blue,
      confirmTextColor: AppColors.white,
      onConfirm: () {
        SharePlus.instance.share(ShareParams(text: '같이 경도해요! 초대코드: $code'));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // lobby provider watch (autoDispose 방지)
    ref.watch(lobbyNotifierProvider);

    final participantsState = ref.watch(waitingRoomParticipantsProvider);
    final participantInfo = ref.watch(gameParticipantNotifierProvider);
    final isHost = participantInfo?.isHost ?? false;

    final policeMembers = participantsState.byTeam('POLICE');
    final robberMembers = participantsState.byTeam('ROBBER');

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // AppBar
            _buildAppBar(),

            // 팀 섹션 (스크롤 가능)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // 경찰팀
                    TeamSection(
                      team: 'POLICE',
                      members: policeMembers,
                      maxPerTeam: _maxPolice,
                      isExpanded: _isPoliceExpanded,
                      onToggle: () => setState(
                        () => _isPoliceExpanded = !_isPoliceExpanded,
                      ),
                      hostParticipantId: participantsState.hostParticipantId,
                      onEmptySlotTap: !_isReady
                          ? () => _changeTeam('POLICE')
                          : null,
                    ),
                    // 구분선
                    Padding(
                      padding: AppPadding.horizontal20,
                      child: Divider(height: 1, color: AppColors.black100),
                    ),
                    // 도둑팀
                    TeamSection(
                      team: 'ROBBER',
                      members: robberMembers,
                      maxPerTeam: _maxRobber,
                      isExpanded: _isRobberExpanded,
                      onToggle: () => setState(
                        () => _isRobberExpanded = !_isRobberExpanded,
                      ),
                      hostParticipantId: participantsState.hostParticipantId,
                      onEmptySlotTap: !_isReady
                          ? () => _changeTeam('ROBBER')
                          : null,
                    ),
                  ],
                ),
              ),
            ),

            // 하단 버튼
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.horizontal20,
                AppSpacing.vertical12,
                AppSpacing.horizontal20,
                AppSpacing.vertical20,
              ),
              child: _buildBottomButton(isHost),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 24.w,
        vertical: AppSpacing.vertical12,
      ),
      child: SizedBox(
        height: 44.h,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 초대코드 (정중앙)
            Text(
              widget.inviteCode ?? '',
              style: AppTextStyles.heading_20.copyWith(color: AppColors.black),
            ),
            // 좌측: 뒤로가기
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: _leaveRoom,
                child: SvgPicture.asset(
                  'assets/icons/icon_previous.svg',
                  width: 24.w,
                  height: 24.w,
                  colorFilter: const ColorFilter.mode(
                    AppColors.black,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            // 우측: 정보 + 설정
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: _showGameRulesDialog,
                    child: SvgPicture.asset(
                      'assets/icons/icon_info.svg',
                      width: 24.w,
                      height: 24.w,
                      colorFilter: const ColorFilter.mode(
                        AppColors.black800,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.horizontal12),
                  GestureDetector(
                    onTap: () => context.push(RoutePaths.settings),
                    child: SvgPicture.asset(
                      'assets/icons/icon_settiing_2.svg',
                      width: 24.w,
                      height: 24.w,
                      colorFilter: const ColorFilter.mode(
                        AppColors.black800,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton(bool isHost) {
    if (isHost) {
      final participantsState = ref.watch(waitingRoomParticipantsProvider);
      final hostPid = participantsState.hostParticipantId;
      // 방장 제외 참가자 중 전원 레디 여부 확인
      final nonHostParticipants = participantsState.participants
          .where((p) => p.participantId != hostPid)
          .toList();
      final allReady =
          nonHostParticipants.isNotEmpty &&
          nonHostParticipants.every((p) => p.isReady);

      return AppButton(
        text: '게임 시작',
        onPressed: allReady ? _startGame : null,
        backgroundColor: allReady ? AppColors.blue : AppColors.black200,
        foregroundColor: allReady ? AppColors.white : AppColors.black400,
        showBorder: false,
      );
    }

    if (_isReady) {
      return AppButton(
        text: '준비 완료',
        onPressed: _isUpdatingReady ? null : _toggleReady,
        backgroundColor: AppColors.blue100,
        foregroundColor: AppColors.blue,
        showBorder: false,
        isLoading: _isUpdatingReady,
      );
    }

    return AppButton(
      text: '준비',
      onPressed: _isUpdatingReady ? null : _toggleReady,
      backgroundColor: AppColors.blue,
      foregroundColor: AppColors.white,
      showBorder: false,
      isLoading: _isUpdatingReady,
    );
  }
}
