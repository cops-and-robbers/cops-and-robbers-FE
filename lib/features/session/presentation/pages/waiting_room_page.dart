import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/api_error_response.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/utils/share_util.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/dialogs/app_dialog.dart';
import '../../../../core/theme/role_theme_provider.dart';
import '../../../../router/route_paths.dart';
import '../../../lobby/data/datasources/lobby_stomp_datasource.dart'
    show StompConnectionState;
import '../../../lobby/data/models/lobby_event_dto.dart';
import '../../../lobby/presentation/providers/lobby_provider.dart';
import '../../data/models/game_settings_response.dart';
import '../../data/models/lobby_info_response.dart';
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

  /// 참가자 초기화 중복 실행 방지
  bool _isFetchingParticipants = false;

  /// 초대코드 다이얼로그 대기 여부 (API 응답 후 1회 표시)
  bool _pendingInviteDialog = false;

  /// 더미 모드 여부
  bool get _isDummyMode => int.tryParse(widget.sessionId) == null;

  /// 더미 모드에서 "나"의 participantId
  static const _dummyMyId = 3;

  /// 선택된 지도 타입 (방장이 게임 시작 시 사용)
  // TODO: 지도 선택 UI 추가 시 변경 가능하도록
  final String _selectedMapType = 'google';

  /// 로비 이벤트 구독 (dispose 시 명시적 해제)
  ProviderSubscription<LobbyState>? _lobbyEventSub;

  /// dispose 여부 (microtask 큐에 남은 이벤트가 dispose 후 처리되는 것을 방지)
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 대기방 진입 시 현재 팀 기준으로 역할 테마 동기화
      final team = ref.read(gameParticipantNotifierProvider)?.team;
      ref.read(roleThemeProvider.notifier).setDarkMode(team == 'ROBBER');

      // 초대코드 다이얼로그는 API 응답 후 팀 정보가 확정된 시점에 표시
      _pendingInviteDialog =
          widget.showInviteDialog && widget.inviteCode != null;

      _listenLobbyEvents();
      _connectLobby();
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _lobbyEventSub?.close();
    _lobbyEventSub = null;
    WidgetsBinding.instance.removeObserver(this);
    // ref.read()는 ConsumerStatefulElement.unmount() 이후 호출 불가.
    // lobbyNotifierProvider / waitingRoomParticipantsProvider 모두 @riverpod
    // (autoDispose)이므로 WaitingRoomPage가 사라지면 자동으로 정리됨.
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

  /// Lobby STOMP 연결
  Future<void> _connectLobby() async {
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
      // 더미 모드에서도 초대코드 다이얼로그 표시
      if (_pendingInviteDialog && mounted) {
        _pendingInviteDialog = false;
        _showInviteCodeDialog();
      }
      return;
    }

    // STOMP 연결 시작 (초기 참가자 목록은 connected 이벤트 시 로드)
    await ref
        .read(lobbyNotifierProvider.notifier)
        .connectAndSubscribe(gameId: gameId, onGameStart: _onGameStartEvent);
  }

  /// REST API로 초기 참가자 목록 및 게임 설정 로드
  ///
  /// STOMP connected 이벤트 발생 시 호출하여 서버의 최신 상태를 가져옵니다.
  /// 로비 조회와 게임 설정 조회를 병렬로 실행하며, 각각 독립적으로 에러를 처리합니다.
  /// fetchGameSettings가 실패해도 참가자 목록은 정상 표시됩니다.
  /// 재연결 루프에서 동시에 여러 번 호출되는 것을 방지하기 위해
  /// [_isFetchingParticipants] 가드를 사용합니다.
  Future<void> _fetchAndInitParticipants() async {
    if (_isFetchingParticipants || _isDisposed) return;

    final gameId = int.tryParse(widget.sessionId);
    if (gameId == null) return;

    _isFetchingParticipants = true;
    try {
      // 두 API를 병렬로 시작
      final lobbyFuture = ref.read(fetchLobbyInfoProvider(gameId).future);
      final settingsFuture = ref.read(fetchGameSettingsProvider(gameId).future);

      // 각 API 독립 에러 처리 (한쪽 실패가 다른 쪽을 막지 않음)
      LobbyInfoResponse? lobbyInfo;
      GameSettingsResponse? settings;

      try {
        lobbyInfo = await lobbyFuture;
      } catch (e) {
        debugPrint('[WaitingRoomPage] 로비 조회 실패: $e');
      }
      try {
        settings = await settingsFuture;
      } catch (e) {
        debugPrint('[WaitingRoomPage] 게임 설정 조회 실패: $e');
      }

      // await 후 위젯이 dispose됐을 수 있으므로 mounted로 이중 확인
      if (_isDisposed || !mounted || lobbyInfo == null) return;

      // 로비 참가자 목록에서 내 정보 추출
      final myPid = lobbyInfo.myParticipantId;
      final isHost = myPid == lobbyInfo.hostParticipantId;
      final myTeam = lobbyInfo.participants
          .where((p) => p.participantId == myPid)
          .map((p) => p.team)
          .firstOrNull;

      ref
          .read(waitingRoomParticipantsProvider.notifier)
          .initFromApi(
            participants: lobbyInfo.participants,
            hostParticipantId: lobbyInfo.hostParticipantId,
          );

      if (_isDisposed || !mounted) return;

      // 다시하기로 재진입 시 clear()로 state가 null이면 initFromLobby()가 early return함.
      // 먼저 setGameInfo()로 state를 초기화하여 이후 initFromLobby()가 정상 동작하도록 보장.
      if (ref.read(gameParticipantNotifierProvider) == null) {
        final myNickname =
            lobbyInfo.participants
                .where((p) => p.participantId == myPid)
                .map((p) => p.nickname)
                .firstOrNull ??
            '';
        ref
            .read(gameParticipantNotifierProvider.notifier)
            .setGameInfo(gameId: gameId, nickname: myNickname, isHost: isHost);
      }

      ref
          .read(gameParticipantNotifierProvider.notifier)
          .initFromLobby(
            participantId: myPid,
            team: myTeam,
            maxParticipants: settings?.maxParticipants,
            locationRevealIntervalMinutes:
                settings?.locationRevealIntervalMinutes,
            policeWaitMinutes: settings?.policeWaitMinutes,
            roundTimeMinutes: settings?.roundDurationMinutes,
          );

      // isHost는 initFromLobby()에서 갱신되지 않으므로 항상 서버 기준으로 명시적 설정
      ref.read(gameParticipantNotifierProvider.notifier).setIsHost(isHost);

      // 역할 기반 다크/라이트 모드 동기화
      ref.read(roleThemeProvider.notifier).setDarkMode(myTeam == 'ROBBER');

      // 방 생성 직후 초대코드 다이얼로그 표시 (팀 확정 후)
      if (_pendingInviteDialog && mounted) {
        _pendingInviteDialog = false;
        _showInviteCodeDialog();
      }
    } finally {
      _isFetchingParticipants = false;
    }
  }

  /// 로비 이벤트 → 참가자 목록 업데이트
  void _listenLobbyEvents() {
    _lobbyEventSub = ref.listenManual(lobbyNotifierProvider, (prev, next) {
      // dispose 후 microtask 큐에 남은 이벤트 방어
      if (_isDisposed) return;

      // STOMP 연결 완료 시 REST API로 초기 참가자 목록 로드
      // connectAndSubscribe()는 연결 시작만 하므로, 실제 connected 시점에 호출해야 함
      if (next.connectionState == StompConnectionState.connected &&
          prev?.connectionState != StompConnectionState.connected) {
        _fetchAndInitParticipants();
      }

      final event = next.lastEvent;
      if (event != null && event != prev?.lastEvent) {
        // 방장 participantId 보완 (로비 조회 API 응답 전 STOMP 이벤트가 먼저 도착할 때 방어)
        // initFromLobby() 호출 후에는 participantId != null이므로 자동 스킵됨.
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
              ref
                  .read(roleThemeProvider.notifier)
                  .setDarkMode(newTeam == 'ROBBER');
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

  /// GAME_START 이벤트 재시도 최대 횟수 (300ms × 10 = 3초)
  static const int _maxGameStartRetries = 10;
  int _gameStartRetryCount = 0;

  /// GAME_START 이벤트 수신 시 호출
  void _onGameStartEvent(LobbyEventDto event) {
    final participantInfo = ref.read(gameParticipantNotifierProvider);
    if (participantInfo == null || participantInfo.participantId == null) {
      _gameStartRetryCount++;
      if (_gameStartRetryCount > _maxGameStartRetries) {
        debugPrint('[WaitingRoom] ❌ participantInfo 준비 실패 - 최대 재시도 초과');
        return;
      }
      debugPrint(
        '[WaitingRoom] ⚠️ participantInfo 미준비 - 라우팅 지연 ($_gameStartRetryCount/$_maxGameStartRetries)',
      );
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!_isDisposed && mounted) _onGameStartEvent(event);
      });
      return;
    }
    _gameStartRetryCount = 0;
    final team = participantInfo.team;
    final participantId = participantInfo.participantId!;
    final mapType = _selectedMapType;

    // startTime을 직접 추출 (GameStartData.fromJson은 message 필드 누락 시 예외 발생 가능)
    final startTimeStr = event.data['startTime'] as String?;
    if (startTimeStr != null) {
      ref
          .read(gameParticipantNotifierProvider.notifier)
          .setGameStartTime(startTimeStr);
    }

    final route =
        '${RoutePaths.gameWithId(widget.sessionId)}?mapType=$mapType&team=$team&pid=$participantId';

    if (mounted) {
      context.go(route);
    }
  }

  /// 팀 변경
  Future<void> _changeTeam(String targetTeam) async {
    // 이미 같은 팀이면 무시
    final currentTeam = ref.read(gameParticipantNotifierProvider)?.team;
    if (currentTeam == targetTeam) return;

    // 더미 모드
    if (_isDummyMode) {
      ref
          .read(waitingRoomParticipantsProvider.notifier)
          .changeDummyTeam(_dummyMyId, targetTeam);
      return;
    }

    final gameId = int.tryParse(widget.sessionId);
    if (gameId == null) return;

    try {
      await ref.read(changeTeamProvider(gameId, targetTeam: targetTeam).future);
      ref.read(roleThemeProvider.notifier).setDarkMode(targetTeam == 'ROBBER');
    } on DioException catch (e) {
      if (mounted) {
        final apiError = ApiErrorResponse.tryParse(e.response?.data);
        final message = apiError?.detail ?? '팀 변경에 실패했습니다.';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
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
    try {
      await ref.read(
        updateReadyProvider(gameId, isReady: newReadyState).future,
      );
      if (!mounted) return;
      setState(() => _isReady = newReadyState);
    } on DioException catch (e) {
      if (mounted) {
        final apiError = ApiErrorResponse.tryParse(e.response?.data);
        final message = apiError?.detail ?? '준비 상태 변경에 실패했습니다.';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdatingReady = false);
      }
    }
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
    try {
      await ref.read(startGameProvider(gameId).future);
    } on DioException catch (e) {
      if (mounted) {
        final apiError = ApiErrorResponse.tryParse(e.response?.data);
        final message = apiError?.detail ?? '게임 시작에 실패했습니다.';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }

  /// 방 나가기
  Future<void> _leaveRoom() async {
    // ① STOMP 먼저 끊기 (EXIT 이벤트 자기 수신 방지)
    _lobbyEventSub?.close();
    _lobbyEventSub = null;
    ref.read(lobbyNotifierProvider.notifier).disconnectLobby();

    // ② 그 다음 REST API 퇴장
    final gameId = int.tryParse(widget.sessionId);
    if (gameId != null) {
      try {
        await ref.read(leaveGameProvider(gameId).future);
      } on DioException catch (e) {
        if (mounted) {
          final apiError = ApiErrorResponse.tryParse(e.response?.data);
          final message = apiError?.detail ?? '퇴장 처리 중 오류가 발생했습니다.';
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        }
      }
    }

    // ③ await 이후 위젯이 dispose됐을 수 있으므로 mounted 확인 후 상태 초기화
    if (!mounted) return;
    ref.read(gameParticipantNotifierProvider.notifier).clear();
    ref.read(waitingRoomParticipantsProvider.notifier).clear();
    context.go(RoutePaths.home);
  }

  /// 게임 규칙 다이얼로그
  void _showGameRulesDialog() {
    final interval = ref
        .read(gameParticipantNotifierProvider)
        ?.locationRevealIntervalMinutes;
    final isDark = ref.read(roleThemeProvider);
    GameRulesContent.showAsDialog(
      context,
      isDarkMode: isDark,
      locationRevealIntervalMinutes: interval,
    );
  }

  /// 초대코드 모달 (방 생성 직후 표시)
  void _showInviteCodeDialog() {
    final code = widget.inviteCode!;
    final messenger = ScaffoldMessenger.of(context);
    final isDark = ref.read(roleThemeProvider);

    AppDialog.show(
      context: context,
      isDarkMode: isDark,
      backgroundColor: isDark ? AppColors.black : null,
      title: '초대코드를 생성했어요',
      titleStyle: isDark
          ? AppTextStyles.robberHeading.copyWith(color: AppColors.white)
          : null,
      message: '친구에게 코드를 공유하고 게임에 참여해 보세요!',
      customContent: GestureDetector(
        onTap: () async {
          await Clipboard.setData(ClipboardData(text: code));
          messenger.clearSnackBars();
          messenger.showSnackBar(
            SnackBar(
              content: Text('코드가 복사되었습니다', style: AppTextStyles.paragraph_14),
              duration: const Duration(seconds: 2),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: AppSpacing.vertical20,
            horizontal: AppSpacing.horizontal16,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: isDark ? AppColors.black800 : AppColors.black100,
            ),
            borderRadius: AppRadius.medium,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                code,
                style: isDark
                    ? AppTextStyles.robberHeading.copyWith(
                        color: AppColors.white,
                      )
                    : AppTextStyles.heading_20.copyWith(color: AppColors.black),
              ),
              SizedBox(width: AppSpacing.horizontal4),
              SvgPicture.asset(
                'assets/icons/icon_copy.svg',
                width: 20.w,
                height: 20.w,
                colorFilter: ColorFilter.mode(
                  isDark ? AppColors.black500 : AppColors.black300,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
        ),
      ),
      cancelText: '닫기',
      confirmText: '공유하기',
      confirmColor: isDark ? null : AppColors.blue,
      confirmTextColor: isDark ? null : AppColors.white,
      onConfirm: () {
        shareText(code);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final participantsState = ref.watch(waitingRoomParticipantsProvider);
    final participantInfo = ref.watch(gameParticipantNotifierProvider);
    final isHost = participantInfo?.isHost ?? false;
    final isDark = ref.watch(roleThemeProvider);

    final policeMembers = participantsState.byTeam('POLICE');
    final robberMembers = participantsState.byTeam('ROBBER');

    return Scaffold(
      backgroundColor: isDark ? AppColors.black900 : AppColors.white,
      appBar: _buildAppBar(isDark),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // 팀 섹션 (스크롤 가능)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // 경찰팀
                    TeamSection(
                      team: 'POLICE',
                      members: policeMembers,
                      maxPerTeam: policeMembers.length + 1,
                      isExpanded: _isPoliceExpanded,
                      onToggle: () => setState(
                        () => _isPoliceExpanded = !_isPoliceExpanded,
                      ),
                      hostParticipantId: participantsState.hostParticipantId,
                      onAddSlotTap: !_isReady
                          ? () => _changeTeam('POLICE')
                          : null,
                      isDarkMode: isDark,
                    ),
                    // 구분선
                    Padding(
                      padding: AppPadding.horizontal20,
                      child: Divider(
                        height: 1,
                        color: isDark ? AppColors.black800 : AppColors.black100,
                      ),
                    ),
                    // 도둑팀
                    TeamSection(
                      team: 'ROBBER',
                      members: robberMembers,
                      maxPerTeam: robberMembers.length + 1,
                      isExpanded: _isRobberExpanded,
                      onToggle: () => setState(
                        () => _isRobberExpanded = !_isRobberExpanded,
                      ),
                      hostParticipantId: participantsState.hostParticipantId,
                      onAddSlotTap: !_isReady
                          ? () => _changeTeam('ROBBER')
                          : null,
                      isDarkMode: isDark,
                    ),
                  ],
                ),
              ),
            ),

            // 하단 버튼
            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.horizontal20,
                  AppSpacing.vertical12,
                  AppSpacing.horizontal20,
                  AppSpacing.vertical20,
                ),
                child: _buildBottomButton(isHost, isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: isDark ? AppColors.black900 : AppColors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: GestureDetector(
        onTap: _leaveRoom,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: SvgPicture.asset(
            'assets/icons/icon_previous.svg',
            width: 24.w,
            height: 24.w,
            colorFilter: ColorFilter.mode(
              isDark ? AppColors.black200 : AppColors.black,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
      title: widget.inviteCode != null
          ? GestureDetector(
              onTap: _showInviteCodeDialog,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.inviteCode!,
                    style: isDark
                        ? AppTextStyles.robberHeading.copyWith(
                            color: AppColors.white,
                          )
                        : AppTextStyles.heading_20.copyWith(
                            color: AppColors.black,
                          ),
                  ),
                  SizedBox(width: AppSpacing.horizontal4),
                  SvgPicture.asset(
                    'assets/icons/icon_copy.svg',
                    width: 20.w,
                    height: 20.w,
                    colorFilter: ColorFilter.mode(
                      isDark ? AppColors.black500 : AppColors.black300,
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ),
            )
          : null,
      actions: [
        GestureDetector(
          onTap: _showGameRulesDialog,
          behavior: HitTestBehavior.opaque,
          child: SvgPicture.asset(
            'assets/icons/icon_info.svg',
            width: 24.w,
            height: 24.w,
            colorFilter: ColorFilter.mode(
              isDark ? AppColors.black200 : AppColors.black800,
              BlendMode.srcIn,
            ),
          ),
        ),
        SizedBox(width: AppSpacing.horizontal12),
        GestureDetector(
          onTap: () =>
              context.push(RoutePaths.gameSettingsWithId(widget.sessionId)),
          behavior: HitTestBehavior.opaque,
          child: SvgPicture.asset(
            'assets/icons/icon_settiing_2.svg',
            width: 24.w,
            height: 24.w,
            colorFilter: ColorFilter.mode(
              isDark ? AppColors.black200 : AppColors.black800,
              BlendMode.srcIn,
            ),
          ),
        ),
        SizedBox(width: 24.w),
      ],
    );
  }

  Widget _buildBottomButton(bool isHost, bool isDark) {
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
        backgroundColor: isDark ? AppColors.green : AppColors.blue,
        foregroundColor: isDark ? AppColors.black : AppColors.white,
        disabledBackgroundColor: isDark
            ? AppColors.black800
            : AppColors.black200,
        disabledForegroundColor: isDark ? AppColors.green : AppColors.black400,
        textStyle: isDark ? AppTextStyles.robberLabel : null,
        showBorder: false,
      );
    }

    if (_isReady) {
      return AppButton(
        text: '준비 완료',
        onPressed: _isUpdatingReady ? null : _toggleReady,
        backgroundColor: isDark ? AppColors.black800 : AppColors.blue100,
        foregroundColor: isDark ? AppColors.green : AppColors.blue,
        textStyle: isDark ? AppTextStyles.robberLabel : null,
        showBorder: false,
        isLoading: _isUpdatingReady,
      );
    }

    return AppButton(
      text: '준비',
      onPressed: _isUpdatingReady ? null : _toggleReady,
      backgroundColor: isDark ? AppColors.green : AppColors.blue,
      foregroundColor: isDark ? AppColors.black : AppColors.white,
      textStyle: isDark ? AppTextStyles.robberLabel : null,
      showBorder: false,
      isLoading: _isUpdatingReady,
    );
  }
}
