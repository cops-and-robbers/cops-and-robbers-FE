import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/game_status.dart';
import '../../../../core/constants/game_team.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/services/analytics/analytics_service.dart';
import '../../../../core/utils/agreement_error_handler.dart';
import '../../../../core/services/tutorial/tutorial_keys.dart';
import '../../../../core/services/tutorial/tutorial_service.dart';
import '../../../../core/tutorial/app_tutorial_style.dart';
import '../../../../core/services/loading_message_service.dart';
import '../../../../core/widgets/loading/app_loading.dart';
import '../../../../core/widgets/snackbars/app_snackbar.dart';
import '../../../../core/services/storage/session_draft_storage_service.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/navigation/app_top_bar.dart';
import '../../../../core/widgets/indicators/step_indicator.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../router/route_paths.dart';
import '../../../../core/constants/game_config.dart';
import '../../../game/data/models/game_area_model.dart';
import '../../../game/domain/entities/area_shape.dart';
import '../../../game/domain/polygon_geometry.dart';
import '../../domain/entities/create_session_result.dart';
import '../../data/models/session_creation_draft_model.dart';
import '../../domain/entities/session_settings.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/game_participant_provider.dart';
import '../providers/session_provider.dart';
import '../widgets/session_creation_steps/step_0_select_area_content.dart';
import '../widgets/session_creation_steps/step_1_participant_settings_content.dart';
import '../widgets/session_creation_steps/step_2_game_settings_content.dart';
import '../widgets/session_creation_steps/step_3_invite_code_content.dart';

/// 세션 생성 플로우 페이지
///
/// PageView 기반으로 4단계 세션 생성 과정을 관리합니다:
/// - Step 0: 구역 선택 (플레이그라운드, 감옥)
/// - Step 1: 인원 설정 (최대 참가자)
/// - Step 2: 게임 설정 (라운드 시간, 위치 공유 간격, 경찰 대기 시간)
/// - Step 3: 최종 설정 확인 → "방 생성하기" → API 호출 → 대기실 이동
///
/// 특징:
/// - 좌우 슬라이드 애니메이션으로 단계 전환
/// - 뒤로가기 시 이전 단계로 이동 (Step 0에서는 홈으로)
/// - 임시 저장 기능 (SessionDraftStorageService)
/// - Step 3에서 "방 생성하기" 버튼 클릭 시 세션 생성 API 호출
class SessionCreationFlowPage extends ConsumerStatefulWidget {
  const SessionCreationFlowPage({super.key});

  @override
  ConsumerState<SessionCreationFlowPage> createState() =>
      _SessionCreationFlowPageState();
}

class _SessionCreationFlowPageState
    extends ConsumerState<SessionCreationFlowPage> {
  // ============================================
  // Controllers & State
  // ============================================

  late final PageController _pageController;
  late final SessionDraftStorageService _storageService;
  int _currentStep = 0;
  bool _isLoading = false;

  // ============================================
  // Tutorial GlobalKeys
  // ============================================

  // Step 0
  final _tutorialKeyPlayground = GlobalKey();
  // Step 1
  // Step 2
  final _tutorialKeySettings = GlobalKey();
  // Step 3

  // Step 0: 구역 선택
  LatLng? _playgroundCenter;
  double? _playgroundRadiusMeters;
  LatLng? _prisonCenter;
  double? _prisonRadiusMeters;

  /// 구역 설정 방식 (거리=원형 / 핀=폴리곤)
  GameAreaType _areaType = GameAreaType.circle;

  /// 폴리곤 핀 목록 (정렬된 경계 순서)
  List<LatLng>? _playgroundPinPoints;
  List<LatLng>? _prisonPinPoints;

  // Step 1: 인원 설정
  int _maxParticipants = 10;

  // Step 2: 게임 설정
  int _roundDurationMinutes = 30;
  int _locationShareMinutes = 5;
  int _policeWaitMinutes = 5;

  // ============================================
  // Lifecycle
  // ============================================

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _storageService = SessionDraftStorageService();
    _loadDraftData();
    // Step 0 튜토리얼은 첫 프레임 렌더링 후 표시
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showStepTutorial(0);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ============================================
  // Tutorial
  // ============================================

  /// 단계별 튜토리얼 표시
  ///
  /// 이미 완료된 단계는 건너뜁니다.
  /// 페이지 전환 애니메이션(300ms) 완료 후 렌더링이 안정될 때까지 추가 대기합니다.
  Future<void> _showStepTutorial(int step) async {
    final String key;

    switch (step) {
      case 0:
        key = TutorialKeys.createStep0;
      case 2:
        key = TutorialKeys.createStep2;
      default:
        return;
    }

    final completed = await TutorialService.isCompleted(key);
    if (completed || !mounted) return;

    // 페이지 전환 애니메이션(300ms) + 렌더링 안정 대기
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    final targets = _buildTutorialTargets(step);
    if (targets.isEmpty) return;

    AppTutorialStyle.show(
      context: context,
      targets: targets,
      onFinish: () => TutorialService.markCompleted(key),
    );
  }

  /// 단계별 튜토리얼 타겟 목록 생성
  List<TutorialTarget> _buildTutorialTargets(int step) {
    final l10n = AppLocalizations.of(context);
    switch (step) {
      case 0:
        return [
          AppTutorialStyle.target(
            keyTarget: _tutorialKeyPlayground,
            description: l10n.sessionCreationStepZoneSubtitle,
          ),
        ];
      case 2:
        return [
          AppTutorialStyle.target(
            keyTarget: _tutorialKeySettings,
            description: l10n.sessionCreationStepRulesSubtitle,
          ),
        ];
      default:
        return [];
    }
  }

  // ============================================
  // Data Management
  // ============================================

  /// 임시 저장된 데이터 불러오기
  Future<void> _loadDraftData() async {
    final draft = await _storageService.loadDraft();
    if (draft != null && mounted) {
      setState(() {
        _areaType = draft.areaType;
        _playgroundPinPoints = draft.playgroundPinPoints == null
            ? null
            : List.of(draft.playgroundPinPoints!);
        _prisonPinPoints = draft.jailPinPoints == null
            ? null
            : List.of(draft.jailPinPoints!);
        _playgroundCenter = draft.playgroundCenter;
        _playgroundRadiusMeters = draft.playgroundRadiusInMeters;
        _prisonCenter = draft.jailCenter;
        _prisonRadiusMeters = draft.jailRadiusInMeters;
        _maxParticipants = draft.maxParticipants ?? 10;
        _roundDurationMinutes = draft.roundDurationMinutes ?? 30;
        _locationShareMinutes = draft.locationShareMinutes ?? 5;
        _policeWaitMinutes = (draft.policeWaitMinutes ?? 5).clamp(1, 10);
      });
    }
  }

  /// 임시 저장
  Future<void> _saveDraft() async {
    final draft = SessionCreationDraftModel(
      areaType: _areaType,
      playgroundPinPoints: _playgroundPinPoints,
      jailPinPoints: _prisonPinPoints,
      playgroundCenter: _playgroundCenter,
      playgroundRadiusInMeters: _playgroundRadiusMeters,
      jailCenter: _prisonCenter,
      jailRadiusInMeters: _prisonRadiusMeters,
      maxParticipants: _maxParticipants,
      roundDurationMinutes: _roundDurationMinutes,
      locationShareMinutes: _locationShareMinutes,
      policeWaitMinutes: _policeWaitMinutes,
    );
    await _storageService.saveDraft(draft);
  }

  // ============================================
  // Navigation & Step Management
  // ============================================

  /// 이전 단계로 이동
  void _goToPreviousStep() {
    // AppSlider 숫자 편집용 키패드 잔존 방지 (숫자 전용 키패드에 완료 키가 없음)
    FocusScope.of(context).unfocus();
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Step 0에서 뒤로가기 → 홈으로
      context.pop();
    }
  }

  /// 다음 단계로 이동 (Step 0~2: "다음" / Step 3: "방 생성하기")
  Future<void> _goToNextStep() async {
    // AppSlider 숫자 편집용 키패드 잔존 방지 (숫자 전용 키패드에 완료 키가 없음)
    FocusScope.of(context).unfocus();
    if (_currentStep < 3) {
      await _saveDraft();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Step 3: "방 생성하기" → API 호출 → 대기실 이동
      await _createSessionAndNavigate();
    }
  }

  /// 세션 생성 API 호출 후 대기실로 이동
  Future<void> _createSessionAndNavigate() async {
    final area = _buildAreaEntity();
    if (area == null) {
      if (kDebugMode) {
        debugPrint('❌ [SessionCreationFlow] 구역 정보가 없습니다');
      }
      return;
    }

    setState(() => _isLoading = true);

    final loading = AppLoading.show(context, LoadingCategory.createRoom);

    try {
      await ref
          .read(sessionCreationNotifierProvider.notifier)
          .createGame(
            area: area,
            roundDurationMinutes: _roundDurationMinutes,
            locationRevealIntervalMinutes: _locationShareMinutes,
            policeWaitMinutes: _policeWaitMinutes,
            maxParticipants: _maxParticipants,
          );
    } finally {
      // 성공/실패 무관하게 로딩 종료 보장 (최소 표시 시간은 핸들이 처리)
      await loading.close();
    }

    if (!mounted) return;

    final sessionState = ref.read(sessionCreationNotifierProvider);

    if (sessionState is AsyncData<CreateSessionResult?> &&
        sessionState.value != null) {
      final result = sessionState.value!;
      if (kDebugMode) {
        debugPrint(
          '✅ [SessionCreationFlow] 세션 생성 완료: '
          'gameId=${result.gameId}, inviteCode=${result.inviteCode}',
        );
      }

      // 세션 생성 성공 → Draft 삭제
      try {
        await _storageService.clearDraft();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️ [SessionCreationFlow] Draft 삭제 실패 (무시): $e');
        }
      }

      if (!mounted) return;

      // 방 생성 퍼널 이벤트
      unawaited(
        ref
            .read(analyticsServiceProvider)
            .logGameCreate(
              participantLimit: _maxParticipants,
              roundMinutes: _roundDurationMinutes,
            ),
      );

      // 게임 참가 정보 설정 (방장은 기본적으로 POLICE 팀)
      // authNotifierProvider는 signInWithGoogle/Apple 직후 서버 닉네임으로 설정되므로
      // 이 시점에 읽으면 정확한 게임 닉네임을 가져올 수 있음
      final myNickname = ref.read(authNotifierProvider).value?.nickname ?? '';
      ref
          .read(gameParticipantNotifierProvider.notifier)
          .setGameInfo(
            gameId: result.gameId,
            nickname: myNickname,
            team: GameTeam.police,
            maxParticipants: result.maxParticipants,
            locationRevealIntervalMinutes: result.locationRevealIntervalMinutes,
            isHost: true,
          );

      context.go(
        '${RoutePaths.waitingRoomWithId('${result.gameId}')}?inviteCode=${result.inviteCode}&showInvite=true',
      );
      return; // 네비게이션 후 setState 불필요
    } else if (sessionState is AsyncError) {
      if (kDebugMode) {
        debugPrint('❌ [SessionCreationFlow] 세션 생성 실패: ${sessionState.error}');
      }

      // 필수 약관 미동의 차단 → 스낵바 + /agreement 리디렉트
      if (mounted &&
          handleRequiredTermsErrorIfNeeded(
            context: context,
            ref: ref,
            error: sessionState.error,
          )) {
        setState(() => _isLoading = false);
        return;
      }

      // 409: 이미 참가 중인 게임 → 해당 게임으로 자동 이동 시도
      if (_is409Conflict(sessionState.error) && mounted) {
        await _redirectToActiveGame();
        return;
      }

      if (mounted) {
        final l10n = AppLocalizations.of(context);
        final errorMessage = _getErrorMessage(l10n, sessionState.error!);
        AppSnackbar.show(
          context,
          message: errorMessage,
          backgroundColor: AppColors.red,
        );
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  /// 에러 타입별 사용자 메시지 반환
  ///
  /// [AppException]인 경우 백엔드의 RFC 7807 `detail` 메시지를 그대로 표시합니다.
  /// (예: 409 → "이미 게임에 참가하고 있습니다.")
  String _getErrorMessage(AppLocalizations l10n, Object error) {
    if (error is AppException) {
      return error.message;
    }
    return l10n.errorCreateRoomFailed;
  }

  /// 에러가 409 Conflict인지 확인
  ///
  /// DioExceptionHandler가 변환한 AppException의 originalException에서
  /// HTTP 상태 코드를 추출합니다.
  bool _is409Conflict(Object? error) {
    if (error is AppException && error.originalException is DioException) {
      final dioError = error.originalException as DioException;
      return dioError.response?.statusCode == 409;
    }
    return false;
  }

  /// 409 에러 시 활성 게임으로 자동 이동
  ///
  /// `/api/user/me/game` 조회 → 게임 상태에 따라 대기실/게임 화면 이동.
  /// 조회 실패 시 fallback 스낵바를 표시하고 로딩 상태를 복원합니다.
  Future<void> _redirectToActiveGame() async {
    try {
      final status = await ref.read(getMyActiveGameUsecaseProvider).execute();
      if (!mounted) return;

      if (!status.isParticipating || status.participationInfo == null) {
        final l10n = AppLocalizations.of(context);
        AppSnackbar.show(
          context,
          message: l10n.errorAlreadyInGame,
          backgroundColor: AppColors.red,
        );
        setState(() => _isLoading = false);
        return;
      }

      final info = status.participationInfo!;

      if (info.gameStatus == GameStatus.waiting) {
        context.go(RoutePaths.waitingRoomWithId(info.gameId.toString()));
      } else if (info.gameStatus == GameStatus.inProgress) {
        context.go(
          '${RoutePaths.gameWithId(info.gameId.toString())}'
          '?team=${info.team}&pid=${info.participantId}',
        );
      } else {
        debugPrint(
          '⚠️ 알 수 없는 게임 상태: ${info.gameStatus} (gameId=${info.gameId})',
        );
        final l10n = AppLocalizations.of(context);
        AppSnackbar.show(
          context,
          message: l10n.errorUnknownGameState,
          backgroundColor: AppColors.red,
        );
        setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        AppSnackbar.show(
          context,
          message: l10n.errorAlreadyInGame,
          backgroundColor: AppColors.red,
        );
        setState(() => _isLoading = false);
      }
    }
  }

  // ============================================
  // Step Callbacks
  // ============================================

  /// 플레이그라운드 설정 결과 처리
  void _onPlaygroundResult(AreaShape result) {
    setState(() {
      if (result is PolygonShape) {
        _areaType = GameAreaType.polygon;
        _playgroundPinPoints = [
          for (final point in result.points)
            LatLng(point.latitude, point.longitude),
        ];
        _playgroundCenter = null;
        _playgroundRadiusMeters = null;
      } else if (result is CircleShape) {
        _areaType = GameAreaType.circle;
        _playgroundCenter = LatLng(
          result.center.latitude,
          result.center.longitude,
        );
        _playgroundRadiusMeters = result.radiusInMeters;
        _playgroundPinPoints = null;
      }
      // 플레이그라운드 변경 시 감옥 초기화 (새 범위 내에서 재설정 필요)
      _prisonCenter = null;
      _prisonRadiusMeters = null;
      _prisonPinPoints = null;
    });
  }

  /// 감옥 설정 결과 처리
  void _onPrisonResult(AreaShape result) {
    setState(() {
      if (result is PolygonShape) {
        _prisonPinPoints = [
          for (final point in result.points)
            LatLng(point.latitude, point.longitude),
        ];
        _prisonCenter = null;
        _prisonRadiusMeters = null;
      } else if (result is CircleShape) {
        _prisonCenter = LatLng(result.center.latitude, result.center.longitude);
        _prisonRadiusMeters = result.radiusInMeters;
        _prisonPinPoints = null;
      }
    });
  }

  /// 플레이그라운드 도형 — 현재 모드 입력이 유효할 때만 non-null
  ///
  /// 원형/폴리곤 분기를 이 게터 안에 가두어, 완료 판정·버튼 표시·엔티티 조립이
  /// 같은 판단을 각자 반복하지 않게 한다.
  AreaShape? get _playgroundShape => _areaType == GameAreaType.polygon
      ? (_isValidPolygonPoints(_playgroundPinPoints)
            ? AreaShape.polygon(points: _toGeoPoints(_playgroundPinPoints!))
            : null)
      : (_playgroundCenter != null && _playgroundRadiusMeters != null
            ? AreaShape.circle(
                center: GeoPoint(
                  latitude: _playgroundCenter!.latitude,
                  longitude: _playgroundCenter!.longitude,
                ),
                radiusInMeters: _playgroundRadiusMeters!,
              )
            : null);

  /// 감옥 도형 — 현재 모드 입력이 유효할 때만 non-null
  AreaShape? get _prisonShape => _areaType == GameAreaType.polygon
      ? (_isValidPolygonPoints(_prisonPinPoints)
            ? AreaShape.polygon(points: _toGeoPoints(_prisonPinPoints!))
            : null)
      : (_prisonCenter != null && _prisonRadiusMeters != null
            ? AreaShape.circle(
                center: GeoPoint(
                  latitude: _prisonCenter!.latitude,
                  longitude: _prisonCenter!.longitude,
                ),
                radiusInMeters: _prisonRadiusMeters!,
              )
            : null);

  /// 구역 설정 전체 완료 여부 (Step3 표시·방 생성 가능 조건)
  bool get _isAreaComplete => _buildAreaEntity() != null;

  bool _isValidPolygonPoints(List<LatLng>? points) {
    if (points == null || points.length < GameConfig.minPolygonVertexCount) {
      return false;
    }
    return isValidPolygon(_toGeoPoints(points));
  }

  List<GeoPoint> _toGeoPoints(List<LatLng> points) => [
    for (final point in points)
      GeoPoint(latitude: point.latitude, longitude: point.longitude),
  ];

  /// 현재 입력이 유효하면 도메인 구역 엔티티로 조립한다.
  ///
  /// 도형 조립은 [_playgroundShape]·[_prisonShape]가 담당하고, 여기서는 두 구역의
  /// 포함 관계만 검증한다.
  GameAreaEntity? _buildAreaEntity() {
    final playground = _playgroundShape;
    final jail = _prisonShape;
    if (playground == null || jail == null) return null;

    if (playground is PolygonShape && jail is PolygonShape) {
      if (!isPolygonInsidePolygon(jail.points, playground.points)) return null;
      return GameAreaEntity(playground: playground, jail: jail);
    }

    if (playground is CircleShape && jail is CircleShape) {
      final centerDistance = Geolocator.distanceBetween(
        playground.center.latitude,
        playground.center.longitude,
        jail.center.latitude,
        jail.center.longitude,
      );
      if (centerDistance + jail.radiusInMeters >
          playground.radiusInMeters +
              GameConfig.zoneContainmentToleranceInMeters) {
        return null;
      }
      return GameAreaEntity(playground: playground, jail: jail);
    }

    // 타입 혼합은 서버 제약상 불가 — 도달 시 미완성으로 취급한다
    return null;
  }

  void _onMaxParticipantsChanged(int value) {
    setState(() => _maxParticipants = value);
  }

  void _onRoundDurationChanged(int value) {
    setState(() => _roundDurationMinutes = value);
  }

  void _onLocationShareChanged(int value) {
    setState(() => _locationShareMinutes = value);
  }

  void _onPoliceWaitChanged(int value) {
    setState(() => _policeWaitMinutes = value);
  }

  // ============================================
  // Step Configuration
  // ============================================

  /// 각 단계별 제목 (l10n 기반)
  List<String> _stepTitles(AppLocalizations l10n) => [
    l10n.sessionCreationZoneFirstQuestion,
    l10n.sessionCreationStepParticipantsTitle,
    l10n.sessionCreationStepBasicTitle,
    l10n.sessionCreationStepReviewTitle,
  ];

  /// 각 단계별 설명 (l10n 기반)
  List<String> _stepDescriptions(AppLocalizations l10n) => [
    l10n.sessionCreationStepZoneIntro,
    l10n.sessionCreationStepParticipantsHint,
    l10n.sessionCreationStepBasicHint,
    l10n.sessionCreationStepReviewHint,
  ];

  /// 각 단계별 버튼 텍스트 (l10n 기반)
  String _buttonText(AppLocalizations l10n) {
    switch (_currentStep) {
      case 0:
      case 1:
      case 2:
        return l10n.buttonNext;
      case 3:
        return l10n.buttonCreateRoom;
      default:
        return l10n.buttonNext;
    }
  }

  /// 다음 버튼 활성화 여부
  bool get _isNextButtonEnabled {
    switch (_currentStep) {
      case 0:
        return _isAreaComplete;
      case 1:
        return true; // 항상 활성화 (슬라이더 기본값 존재)
      case 2:
        return true; // 항상 활성화 (슬라이더 기본값 존재)
      case 3:
        return true; // 항상 활성화 (모든 데이터는 이미 검증됨)
      default:
        return false;
    }
  }

  // ============================================
  // Build Methods
  // ============================================

  @override
  Widget build(BuildContext context) {
    // autoDispose provider를 유지하기 위해 watch (401 토큰 재발급 중 dispose 방지)
    ref.watch(sessionCreationNotifierProvider);
    final l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _goToPreviousStep();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: _buildAppBar(context),
        body: SafeArea(
          child: Padding(
            padding: AppPadding.all20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: AppSpacing.vertical16),
                _buildHeader(l10n),
                SizedBox(height: AppSpacing.vertical28),
                Expanded(child: _buildPageView(l10n)),
                _buildBottomButton(l10n),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// AppBar (StepIndicator + PreviousButton)
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppTopBar(
      titleWidget: StepIndicator(totalSteps: 4, currentStep: _currentStep),
      centerTitle: false,
      titleSpacing: 0,
      onBack: _goToPreviousStep,
      actions: [SizedBox(width: AppSpacing.horizontal20)],
    );
  }

  /// Header (제목 + 설명)
  Widget _buildHeader(AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.horizontal4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _stepTitles(l10n)[_currentStep],
            style: AppTextStyles.heading_24.copyWith(color: AppColors.black),
          ),
          SizedBox(height: AppSpacing.vertical16),
          Text(
            _stepDescriptions(l10n)[_currentStep],
            style: AppTextStyles.paragraph_14_100.copyWith(
              color: AppColors.black600,
            ),
          ),
        ],
      ),
    );
  }

  /// PageView (4개 스텝 콘텐츠)
  Widget _buildPageView(AppLocalizations l10n) {
    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(), // 스와이프 비활성화 (버튼으로만 이동)
      onPageChanged: (index) {
        setState(() => _currentStep = index);
        // Step 0은 initState에서 처리, 1~3은 페이지 전환 완료 후 트리거
        if (index > 0) {
          _showStepTutorial(index);
        }
      },
      children: [
        // Step 0: 구역 선택
        SingleChildScrollView(
          child: Step0SelectAreaContent(
            playgroundShape: _playgroundShape,
            prisonShape: _prisonShape,
            onPlaygroundResult: _onPlaygroundResult,
            onPrisonResult: _onPrisonResult,
            playgroundKey: _tutorialKeyPlayground,
          ),
        ),

        // Step 1: 인원 설정
        SingleChildScrollView(
          child: Step1ParticipantSettingsContent(
            maxParticipants: _maxParticipants,
            onChanged: _onMaxParticipantsChanged,
          ),
        ),

        // Step 2: 게임 설정
        SingleChildScrollView(
          child: Step2GameSettingsContent(
            roundDurationMinutes: _roundDurationMinutes,
            locationShareMinutes: _locationShareMinutes,
            policeWaitMinutes: _policeWaitMinutes,
            onRoundDurationChanged: _onRoundDurationChanged,
            onLocationShareChanged: _onLocationShareChanged,
            onPoliceWaitChanged: _onPoliceWaitChanged,
            settingsKey: _tutorialKeySettings,
          ),
        ),

        // Step 3: 최종 설정 확인
        SingleChildScrollView(
          child: _isAreaComplete
              ? Step3InviteCodeContent(
                  area: _buildAreaEntity()!,
                  settings: SessionSettings(
                    maxPlayers: _maxParticipants,
                    roundTimeMinutes: _roundDurationMinutes,
                    locationShareMinutes: _locationShareMinutes,
                    policeStartDelayMinutes: _policeWaitMinutes,
                  ),
                )
              : Center(child: Text(l10n.errorZoneNotConfigured)),
        ),
      ],
    );
  }

  /// 하단 버튼
  Widget _buildBottomButton(AppLocalizations l10n) {
    return AppButton(
      text: _buttonText(l10n),
      onPressed: _isNextButtonEnabled && !_isLoading ? _goToNextStep : null,
      isLoading: _isLoading,
      showBorder: false,
    );
  }
}
