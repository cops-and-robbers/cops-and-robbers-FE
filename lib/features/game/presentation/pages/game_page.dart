import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/services/location/device_location_service.dart';
import '../../../../core/widgets/buttons/svg_icon_button.dart';
import '../../../../core/widgets/dialogs/app_dialog.dart';
import '../../../../core/widgets/dialogs/app_popup.dart';
import '../../../../core/widgets/dialogs/countdown_timer_content.dart';
import '../../../../router/route_paths.dart';
import '../../../chat/presentation/providers/chat_provider.dart';
import '../../../chat/presentation/widgets/chat_overlay.dart';
import '../../../session/presentation/providers/game_participant_provider.dart';
import '../../../session/presentation/providers/session_provider.dart';
import '../../../session/presentation/widgets/game_rules_content.dart';
import '../../data/datasources/game_event_stomp_datasource.dart';
import '../../data/models/game_area_model.dart';
import '../providers/game_area_provider.dart';
import '../providers/game_event_provider.dart';
import '../../../../core/widgets/buttons/my_location_button.dart';
import '../widgets/game_timer_text.dart';
import '../widgets/location_reveal_countdown.dart';
import '../widgets/google_map_view.dart';
import '../widgets/naver_map_view.dart';
import '../widgets/participant_overlay.dart';
import '../widgets/police_start_countdown.dart';

/// 인게임 지도 화면
///
/// 게임 진행 중 사용되는 메인 화면
class GamePage extends ConsumerStatefulWidget {
  const GamePage({
    required this.sessionId,
    required this.mapType,
    required this.team,
    required this.participantId,
    this.isDummy = false,
    super.key,
  });

  /// 게임 세션 ID
  final String sessionId;

  /// 지도 타입 ('google' 또는 'naver')
  final String mapType;

  /// 플레이어 팀 ('POLICE' 또는 'ROBBER')
  final String team;

  /// 플레이어 참가자 ID
  final int participantId;

  /// 더미 모드 (서버 미연동 시 UI 테스트용)
  final bool isDummy;

  @override
  ConsumerState<GamePage> createState() => _GamePageState();
}

class _GamePageState extends ConsumerState<GamePage> {
  final _googleMapKey = GlobalKey<GoogleMapViewState>();
  final _naverMapKey = GlobalKey<NaverMapViewState>();
  bool _showParticipants = false;
  bool _gameOverDialogShown = false;
  bool _isLocationFocused = true;
  bool _isProgrammaticMove = true; // 초기 카메라 이동(onMapCreated) 보호

  /// dispose()에서 ref 사용 불가이므로 사전에 저장
  ChatNotifier? _chatNotifier;
  GameEventNotifier? _gameEventNotifier;
  GameEventStompDatasource? _gameEventDatasource;

  Timer? _locationTimer;
  Position? _lastSentPosition;

  /// 더미 모드 전용 타이머 시작 시각
  DateTime? _dummyStartTime;

  int get _gameId => int.tryParse(widget.sessionId) ?? 0;
  bool get _isDarkMode => widget.team == 'ROBBER';

  @override
  void initState() {
    super.initState();
    if (widget.isDummy) _dummyStartTime = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _connectChat();
      _connectGameEvents();
      _loadGameArea();
      _showPoliceTimerIfNeeded();
      // TODO: GPS 위치 추적 서비스 시작 (백엔드 스펙 확정 후)
      //       BackgroundLocationService.start(gameId: _gameId, ...)
    });
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    // dispose() 중 provider 상태 수정은 Riverpod이 차단하므로 다음 프레임으로 지연.
    // gameEventNotifier.disconnect()는 내부에서 ref.read()를 호출하므로
    // provider가 dispose된 후 호출 시 에러 가능. datasource를 직접 참조해 우회.
    final chatNotifier = _chatNotifier;
    final gameEventDatasource = _gameEventDatasource;
    final isDummy = widget.isDummy;
    Future.microtask(() {
      chatNotifier?.disconnectChat();
      if (!isDummy) gameEventDatasource?.disconnect();
    });
    super.dispose();
  }

  /// 경찰 대기 타이머 팝업 (경찰 팀만, 서버 startTime 기준 남은 시간)
  void _showPoliceTimerIfNeeded() {
    if (widget.isDummy || widget.team != 'POLICE') return;

    final info = ref.read(gameParticipantNotifierProvider);
    final startTimeStr = info?.gameStartTime;
    final waitMinutes = info?.policeWaitMinutes;
    if (startTimeStr == null || waitMinutes == null || waitMinutes <= 0) return;

    final startTime = DateTime.tryParse(startTimeStr);
    if (startTime == null) return;

    final waitEndTime = startTime.add(Duration(minutes: waitMinutes));
    final remaining = waitEndTime.difference(DateTime.now());
    if (remaining <= Duration.zero) return;

    AppPopup.show(
      context: context,
      autoCloseDuration: remaining,
      content: CountdownTimerContent(
        duration: remaining,
        subtitle: '도둑이 도망치는 중이에요!',
      ),
    );
  }

  /// 도둑팀 전용: 경찰 시작 시각 계산
  ///
  /// gameStartTime + policeWaitMinutes. 경찰팀이거나 대기 시간이 없으면 null.
  DateTime? _computePoliceStartTime() {
    if (widget.team != 'ROBBER') return null;

    final info = ref.read(gameParticipantNotifierProvider);
    final waitMinutes = info?.policeWaitMinutes;
    if (waitMinutes == null || waitMinutes <= 0) return null;

    final startTimeStr = info?.gameStartTime;
    final startTime = startTimeStr != null
        ? DateTime.tryParse(startTimeStr)
        : null;
    // 더미 모드 시 _dummyStartTime 사용
    final effectiveStartTime = _dummyStartTime ?? startTime;
    if (effectiveStartTime == null) return null;

    return effectiveStartTime.add(Duration(minutes: waitMinutes));
  }

  /// 채팅 연결 및 구독
  void _connectChat() {
    final team = widget.team.toLowerCase();
    _chatNotifier = ref.read(chatNotifierProvider.notifier);

    if (widget.isDummy) {
      _chatNotifier!.enableDummyMode(
        participantId: widget.participantId,
        team: team,
      );
    } else {
      _chatNotifier!.connectAndSubscribe(gameId: _gameId, team: team);
    }
  }

  /// 게임 이벤트 STOMP 연결
  void _connectGameEvents() {
    if (widget.isDummy) return;
    _gameEventNotifier = ref.read(gameEventNotifierProvider.notifier);
    _gameEventDatasource = ref.read(gameEventStompDatasourceProvider);
    _gameEventNotifier!.connectAndSubscribe(_gameId);
    if (widget.team == 'ROBBER') _startLocationSending();
  }

  /// 게임 맵 영역 로드 (FutureProvider 트리거)
  void _loadGameArea() {
    if (widget.isDummy) return;
    ref.read(gameAreaProvider(_gameId));
  }

  /// 도둑 팀 GPS 위치 서버 전송 시작 (10초 주기, 10m 이상 변화 시만 전송)
  Future<void> _startLocationSending() async {
    // GPS 조회 (STOMP 연결 대기와 병렬 수행)
    final initial = await DeviceLocationService.getCurrentPosition();
    if (!mounted || initial == null) return;

    // STOMP가 아직 connecting 중이면 connected 될 때까지 대기 (최대 15초)
    const maxWait = Duration(seconds: 15);
    final deadline = DateTime.now().add(maxWait);
    while (mounted && DateTime.now().isBefore(deadline)) {
      final connState = ref.read(gameEventNotifierProvider).connectionState;
      if (connState == StompConnectionState.connected) break;
      if (connState == StompConnectionState.error) return;
      await Future.delayed(const Duration(milliseconds: 300));
    }
    if (!mounted) return;

    // 최초 위치 무조건 1번 전송 (STOMP connected 보장 후)
    _gameEventDatasource?.publishLocation(
      _gameId,
      initial.latitude,
      initial.longitude,
    );
    _lastSentPosition = initial;

    // 10초 주기 타이머: 현재 위치 조회 → 이전 위치와 비교 → 10m 이상 변화 시 전송
    // ⚠️ 포그라운드 전용: 백그라운드 전환 시 타이머 일시 정지됨.
    //    전체 백그라운드 지원은 flutter_background_service 구현 시 대응 예정.
    _locationTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      if (!mounted) return;
      final pos = await DeviceLocationService.getCurrentPosition();
      if (!mounted || pos == null) return;

      final last = _lastSentPosition;
      if (last != null) {
        final distance = Geolocator.distanceBetween(
          last.latitude,
          last.longitude,
          pos.latitude,
          pos.longitude,
        );
        if (distance < 10) return; // 10m 미만 변화 → 스킵
      }

      _gameEventDatasource?.publishLocation(
        _gameId,
        pos.latitude,
        pos.longitude,
      );
      _lastSentPosition = pos;
    });
  }

  /// 현재 위치를 거리 무관하게 즉시 1회 전송
  Future<void> _sendPositionNow() async {
    final pos = await DeviceLocationService.getCurrentPosition();
    if (!mounted || pos == null) return;
    _gameEventDatasource?.publishLocation(_gameId, pos.latitude, pos.longitude);
    _lastSentPosition = pos;
  }

  void _moveToCurrentLocation() {
    _isProgrammaticMove = true;
    setState(() => _isLocationFocused = true);
    if (widget.mapType == 'naver') {
      _naverMapKey.currentState?.moveCameraToCurrentLocation();
    } else {
      _googleMapKey.currentState?.moveCameraToCurrentLocation();
    }
  }

  void _onMapCameraMoved() {
    if (_isProgrammaticMove) {
      _isProgrammaticMove = false;
      return;
    }
    if (_isLocationFocused) {
      setState(() => _isLocationFocused = false);
    }
  }

  /// 게임 규칙 다이얼로그 (앱바 우측 info 버튼)
  ///
  /// 대기실과 동일한 GameRulesContent를 표시합니다.
  void _showGameRulesDialog() {
    final interval = ref
        .read(gameParticipantNotifierProvider)
        ?.locationRevealIntervalMinutes;
    GameRulesContent.showAsDialog(
      context,
      isDarkMode: _isDarkMode,
      locationRevealIntervalMinutes: interval,
    );
  }

  /// 맵 영역 원 빌드 (Google Map용)
  Set<Circle> _buildGoogleCircles(GameAreaModel area) {
    return {
      Circle(
        circleId: const CircleId('playground'),
        center: LatLng(
          area.playgroundCenter.latitude,
          area.playgroundCenter.longitude,
        ),
        radius: area.playgroundRadiusInMeters,
        fillColor: Colors.transparent,
        strokeColor: AppColors.blue800,
        strokeWidth: 2,
        consumeTapEvents: false,
      ),
      Circle(
        circleId: const CircleId('jail'),
        center: LatLng(area.jailCenter.latitude, area.jailCenter.longitude),
        radius: area.jailRadiusInMeters,
        fillColor: Colors.transparent,
        strokeColor: AppColors.red500,
        strokeWidth: 2,
        consumeTapEvents: false,
      ),
    };
  }

  /// 맵 영역 원 빌드 (Naver Map용)
  Set<NCircleOverlay> _buildNaverOverlays(GameAreaModel area) {
    return {
      NCircleOverlay(
        id: 'playground',
        center: NLatLng(
          area.playgroundCenter.latitude,
          area.playgroundCenter.longitude,
        ),
        radius: area.playgroundRadiusInMeters,
        color: Colors.transparent,
        outlineColor: AppColors.blue800,
        outlineWidth: 2,
      ),
      NCircleOverlay(
        id: 'jail',
        center: NLatLng(area.jailCenter.latitude, area.jailCenter.longitude),
        radius: area.jailRadiusInMeters,
        color: Colors.transparent,
        outlineColor: AppColors.red500,
        outlineWidth: 2,
      ),
    };
  }

  /// LOCATION_REVEAL 수신 시 도둑 위치 원 갱신
  void _updateRobberMarkers(Map<int, LatLngModel> locations) {
    if (widget.mapType == 'naver') {
      _naverMapKey.currentState?.updateRobberOverlays(
        _buildNaverRobberOverlays(locations),
      );
    } else {
      _googleMapKey.currentState?.updateRobberCircles(
        _buildGoogleRobberCircles(locations),
      );
    }
  }

  /// 도둑 위치 빨간 원 빌드 (Google Map용)
  Set<Circle> _buildGoogleRobberCircles(Map<int, LatLngModel> locations) {
    return locations.entries
        .map(
          (e) => Circle(
            circleId: CircleId('robber_${e.key}'),
            center: LatLng(e.value.latitude, e.value.longitude),
            radius: 15,
            fillColor: AppColors.red,
            strokeColor: AppColors.red,
            strokeWidth: 0,
            consumeTapEvents: false,
          ),
        )
        .toSet();
  }

  /// 도둑 위치 빨간 원 빌드 (Naver Map용)
  Set<NCircleOverlay> _buildNaverRobberOverlays(
    Map<int, LatLngModel> locations,
  ) {
    return locations.entries
        .map(
          (e) => NCircleOverlay(
            id: 'robber_${e.key}',
            center: NLatLng(e.value.latitude, e.value.longitude),
            radius: 15,
            color: AppColors.red,
            outlineColor: AppColors.red,
            outlineWidth: 0,
          ),
        )
        .toSet();
  }

  /// 게임 종료 → 결과 팝업 2단계 시퀀스
  ///
  /// 1단계: "게임 종료" 알림 팝업 (3초 자동 닫힘)
  /// 2단계: 결과 팝업 (커스텀 타이틀 스타일, "홈으로" 버튼)
  Future<void> _showGameOverDialog(String? winnerTeam, String? reason) async {
    if (_gameOverDialogShown) return;
    _gameOverDialogShown = true;
    // STOMP 구독 즉시 해제 (늦게 도달하는 이벤트 차단)
    ref.read(gameEventNotifierProvider.notifier).disconnect();
    // 혹시 열려있는 다른 팝업/다이얼로그 모두 닫기
    if (mounted) {
      Navigator.of(context).popUntil((route) => route is! PopupRoute);
    }

    // 1단계: 게임 종료 알림 팝업 (3초 자동 닫힘)
    await AppPopup.show(
      context: context,
      autoCloseDuration: const Duration(seconds: 3),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '게임 종료',
            style: AppTextStyles.heading_20.copyWith(color: AppColors.black),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.vertical8),
          Text(
            reason == 'ALL_ARRESTED' ? '도둑이 모두 체포되었습니다!' : '제한 시간이 종료되었습니다!',
            style: AppTextStyles.paragraph_14.copyWith(
              color: AppColors.black600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

    if (!mounted) return;

    // 2단계: 게임 결과 팝업 (커스텀 타이틀 스타일, 2버튼)
    final isWin = winnerTeam == widget.team;
    final winnerTeamLabel = winnerTeam == 'POLICE' ? '경찰팀' : '도둑팀';
    final gameId = int.tryParse(widget.sessionId);

    AppDialog.show(
      context: context,
      title: isWin ? '승리!' : '패배...',
      message: '$winnerTeamLabel의 승리입니다!',
      titleStyle: AppTextStyles.heading_20.copyWith(
        color: isWin ? AppColors.blue : AppColors.red,
      ),
      cancelText: '홈으로',
      confirmText: '다시하기',
      confirmColor: AppColors.blue,
      confirmTextColor: AppColors.white,
      barrierDismissible: false,
      onCancel: () {
        // 방 나가기 API (fire-and-forget) + 상태 초기화 후 홈 이동
        if (gameId != null) ref.read(leaveGameProvider(gameId).future);
        ref.read(gameParticipantNotifierProvider.notifier).clear();
        context.go(RoutePaths.home);
      },
      onConfirm: () {
        // leave API 미호출 (서버에서 방 유지) + 상태 초기화 후 대기실 이동
        ref.read(gameParticipantNotifierProvider.notifier).clear();
        context.go(RoutePaths.waitingRoomWithId(widget.sessionId));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 게임 이벤트 감지 → 게임 종료 다이얼로그
    ref.listen(gameEventNotifierProvider, (prev, next) {
      if (!(prev?.isGameOver ?? false) && next.isGameOver) {
        _showGameOverDialog(next.winnerTeam, next.gameOverReason);
      }
    });

    final showBanner = ref.watch(
      gameEventNotifierProvider.select((s) => s.showLocationRevealBanner),
    );

    // 도둑팀 경찰 시작 카운트다운용 시각 계산
    final policeStartTime = _computePoliceStartTime();

    // 재연결 감지 → 도둑 팀 위치 즉시 재전송
    ref.listen(gameEventNotifierProvider.select((s) => s.connectionState), (
      prev,
      next,
    ) {
      if (next == StompConnectionState.connected &&
          prev != StompConnectionState.connected &&
          widget.team == 'ROBBER' &&
          !widget.isDummy) {
        if (_lastSentPosition != null) {
          _sendPositionNow();
        } else if (_locationTimer == null) {
          _startLocationSending();
        }
      }
    });

    // LOCATION_REVEAL 수신 시 경찰 팀에게 도둑 위치 원 표시
    ref.listen(gameEventNotifierProvider.select((s) => s.robberLocations), (
      prev,
      next,
    ) {
      if (widget.team == 'POLICE' && next.isNotEmpty) {
        _updateRobberMarkers(next);
      }
    });

    // 게임 맵 영역 로드 완료 시 지도에 원 추가
    ref.listen(gameAreaProvider(_gameId), (prev, next) {
      next.whenData((area) {
        if (widget.mapType == 'naver') {
          _naverMapKey.currentState?.updateAreaOverlays(
            _buildNaverOverlays(area),
          );
        } else {
          _googleMapKey.currentState?.updateAreaCircles(
            _buildGoogleCircles(area),
          );
        }
      });
    });

    return Scaffold(
      body: Stack(
        children: [
          /// index 0: 지도 (항상 존재)
          Positioned.fill(
            child: widget.mapType == 'naver'
                ? NaverMapView(key: _naverMapKey, isDarkMode: _isDarkMode)
                : GoogleMapView(
                    key: _googleMapKey,
                    onCameraMoveStarted: _onMapCameraMoved,
                    isDarkMode: _isDarkMode,
                  ),
          ),

          /// index 1: 참가자 목록 오버레이 (if/else로 개수 고정)
          if (_showParticipants)
            Positioned.fill(
              child: Container(
                color: _isDarkMode ? AppColors.black900 : AppColors.white,
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      _buildAppBar(),
                      Expanded(
                        child: ParticipantOverlay(
                          onClose: () =>
                              setState(() => _showParticipants = false),
                          gameId: _gameId,
                          myTeam: widget.team,
                          myParticipantId: widget.participantId,
                          isDarkMode: _isDarkMode,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            const SizedBox.shrink(),

          /// index 2: 상단 앱바 (if/else로 개수 고정, 지도 모드일 때만 표시)
          if (!_showParticipants)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: _isDarkMode ? AppColors.black900 : AppColors.white,
                child: SafeArea(bottom: false, child: _buildAppBar()),
              ),
            )
          else
            const SizedBox.shrink(),

          /// index 3: 알림 배너 (if/else로 개수 고정)
          ///
          /// showBanner가 true일 때만 배너 표시.
          /// if/else로 항상 동일한 개수의 children을 유지해
          /// ChatOverlay가 항상 동일한 index(5)에 위치하도록 보장함.
          if (!_showParticipants && showBanner)
            SafeArea(
              bottom: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 64.h + 8.h),
                  _buildAlertBanner(),
                ],
              ),
            )
          else
            const SizedBox.shrink(),

          /// index 4: 도둑팀 경찰 시작 카운트다운 (if/else로 개수 고정)
          if (!_showParticipants && policeStartTime != null)
            SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.only(top: 64.h + 24.h),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: PoliceStartCountdown(policeStartTime: policeStartTime),
                ),
              ),
            )
          else
            const SizedBox.shrink(),

          /// index 5: 우측 버튼 (if/else로 개수 고정)
          if (_showParticipants)
            Positioned(
              right: 20.w,
              bottom: 145.h,
              child: SvgIconButton(
                assetPath: 'assets/icons/icon_map.svg',
                onPressed: () => setState(() => _showParticipants = false),
                containerSize: 48,
                iconSize: 24,
                iconColor: _isDarkMode ? AppColors.green : AppColors.blue,
                backgroundColor: _isDarkMode ? AppColors.black : null,
              ),
            )
          else
            Positioned(
              right: 20.w,
              bottom: 145.h,
              child: Column(
                children: [
                  SvgIconButton(
                    assetPath: 'assets/icons/icon_person.svg',
                    onPressed: () => setState(() => _showParticipants = true),
                    containerSize: 48,
                    iconSize: 24,
                    iconColor: _isDarkMode ? AppColors.green : AppColors.blue,
                    backgroundColor: _isDarkMode ? AppColors.black : null,
                  ),
                  SizedBox(height: AppSpacing.vertical8),
                  MyLocationButton(
                    onPressed: _moveToCurrentLocation,
                    isFocused: _isLocationFocused,
                    containerSize: 48,
                    iconSize: 24,
                    focusedColor: _isDarkMode ? AppColors.green500 : null,
                    unfocusedColor: _isDarkMode ? AppColors.green500 : null,
                    backgroundColor: _isDarkMode ? AppColors.black : null,
                  ),
                ],
              ),
            ),

          /// index 6: 하단 채팅 오버레이 (항상 마지막 고정)
          ///
          /// Stack children 개수가 변하면 ChatOverlay의 index가 바뀌어
          /// Flutter가 기존 State를 dispose하고 새로 생성해버린다.
          /// 위의 if/else 구조로 항상 index 6에 고정해 State를 보존한다.
          ChatOverlay(
            gameId: _gameId,
            myParticipantId: widget.participantId,
            myTeam: widget.team,
            isDarkMode: _isDarkMode,
          ),
        ],
      ),
    );
  }

  /// 상단 앱바 (흰색 배경, 높이 64px)
  ///
  /// 대기실 등 다른 페이지 앱바 스타일과 동일.
  Widget _buildAppBar() {
    // ref.watch는 항상 무조건 호출해야 Riverpod 구독이 올바르게 등록됨
    final stompGameStartTime = ref.watch(
      gameEventNotifierProvider.select((s) => s.gameStartTime),
    );
    final participantInfo = ref.watch(gameParticipantNotifierProvider);
    final participantStartTime = participantInfo?.gameStartTime != null
        ? DateTime.tryParse(participantInfo!.gameStartTime!)
        : null;
    // 우선순위: 더미 시작 시각 → STOMP START 이벤트 시각 → 대기실 게임 시작 시각
    final gameStartTime =
        _dummyStartTime ?? stompGameStartTime ?? participantStartTime;
    final roundMinutes = participantInfo?.roundTimeMinutes;
    final totalDuration = roundMinutes != null
        ? Duration(minutes: roundMinutes)
        : null;
    final lastReveal = ref.watch(
      gameEventNotifierProvider.select((s) => s.lastLocationRevealTime),
    );
    final interval = participantInfo?.locationRevealIntervalMinutes;

    final policeMoveStartTime = ref.watch(
      gameEventNotifierProvider.select((s) => s.policeMoveStartTime),
    );

    DateTime? nextRevealTime;
    if (interval != null && interval > 0) {
      // policeWaitMinutes == 0이면 서버가 POLICE_MOVE_START를 보내지 않으므로
      // gameStartTime을 fallback으로 사용
      final policeWaitMinutes = participantInfo?.policeWaitMinutes;
      final effectiveMoveStartTime =
          policeMoveStartTime ??
          (policeWaitMinutes == 0 ? gameStartTime : null);
      final base = lastReveal ?? effectiveMoveStartTime;
      if (base != null) nextRevealTime = base.add(Duration(minutes: interval));
    }

    return Container(
      height: 64.h,
      color: _isDarkMode ? AppColors.black900 : AppColors.white,
      padding: AppPadding.horizontal24,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 중앙: 타이머 + 서브 타이머
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // START 이벤트 수신 후 경과 시간 표시
              gameStartTime != null && totalDuration != null
                  ? GameTimerText(
                      startTime: gameStartTime,
                      totalDuration: totalDuration,
                      isDarkMode: _isDarkMode,
                    )
                  : Text(
                      '--:--',
                      style: _isDarkMode
                          ? AppTextStyles.robber_heading.copyWith(
                              color: AppColors.white,
                            )
                          : AppTextStyles.heading_20.copyWith(
                              color: AppColors.black,
                            ),
                    ),
              SizedBox(height: 6.h),
              LocationRevealCountdown(
                nextRevealTime: nextRevealTime,
                isDarkMode: _isDarkMode,
              ),
            ],
          ),
          // 우측: info 버튼 (24x24)
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: _showGameRulesDialog,
              child: SvgPicture.asset(
                'assets/icons/icon_info.svg',
                width: 24.w,
                height: 24.w,
                colorFilter: ColorFilter.mode(
                  _isDarkMode ? AppColors.black200 : AppColors.black800,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 알림 배너 (353x44) — LOCATION_REVEAL 이벤트 수신 시 5초간 표시
  Widget _buildAlertBanner() {
    return Padding(
      padding: AppPadding.horizontal20,
      child: Container(
        height: 44.h,
        decoration: BoxDecoration(
          color: AppColors.red,
          borderRadius: AppRadius.large,
        ),
        padding: EdgeInsets.only(left: 16.w),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/Loudspeaker.svg',
              width: 20.w,
              height: 20.w,
              colorFilter: const ColorFilter.mode(
                AppColors.white,
                BlendMode.srcIn,
              ),
            ),
            SizedBox(width: AppSpacing.horizontal8),
            Text(
              '현재 도둑의 위치가 공개됩니다!',
              style: AppTextStyles.paragraph14Semibold.copyWith(
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
