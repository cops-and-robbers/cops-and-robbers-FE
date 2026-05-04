import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/agreement_error_handler.dart';
import '../../../../core/services/tutorial/tutorial_keys.dart';
import '../../../../core/services/tutorial/tutorial_service.dart';
import '../../../../core/tutorial/app_tutorial_style.dart';
import '../../../../core/widgets/dialogs/app_popup.dart';
import '../../../../core/services/loading_message_service.dart';
import '../../../../core/widgets/snackbars/app_snackbar.dart';
import '../../../../core/services/storage/session_draft_storage_service.dart';
import '../../../../core/services/vibration_service.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/buttons/previous_button.dart';
import '../../../../core/widgets/indicators/step_indicator.dart';
import '../../../../router/route_paths.dart';
import '../../domain/entities/create_session_result.dart';
import '../../data/models/session_creation_draft_model.dart';
import '../../domain/entities/session_settings.dart';
import '../../domain/entities/zone_info.dart';
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
  final _tutorialKeyRoundDuration = GlobalKey();
  final _tutorialKeyLocationShare = GlobalKey();
  final _tutorialKeyPoliceWait = GlobalKey();
  // Step 3

  // Step 0: 구역 선택
  LatLng? _playgroundCenter;
  double? _playgroundRadiusMeters;
  LatLng? _prisonCenter;
  double? _prisonRadiusMeters;

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
    switch (step) {
      case 0:
        return [
          AppTutorialStyle.target(
            keyTarget: _tutorialKeyPlayground,
            description: '게임할 구역을 설정해요.\n먼저 플레이그라운드를 지정하세요',
          ),
        ];
      case 2:
        return [
          AppTutorialStyle.target(
            keyTarget: _tutorialKeyRoundDuration,
            description: '한 라운드의 제한 시간이에요\n숫자를 탭하면 직접 입력할 수 있어요',
          ),
          AppTutorialStyle.target(
            keyTarget: _tutorialKeyLocationShare,
            description: '도둑 위치가 경찰에게 공개되는 주기에요',
          ),
          AppTutorialStyle.target(
            keyTarget: _tutorialKeyPoliceWait,
            description: '게임 시작 후 경찰이 출발할 때까지 기다리는 시간이에요',
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
    VibrationService.instance().buttonTap();
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
    if (_playgroundCenter == null ||
        _playgroundRadiusMeters == null ||
        _prisonCenter == null ||
        _prisonRadiusMeters == null) {
      if (kDebugMode) {
        debugPrint('❌ [SessionCreationFlow] 구역 정보가 없습니다');
      }
      return;
    }

    setState(() => _isLoading = true);
    final navigator = Navigator.of(context);

    await AppPopup.showRandomLoading(
      context: context,
      category: LoadingCategory.createRoom,
    );

    await ref
        .read(sessionCreationNotifierProvider.notifier)
        .createGame(
          playgroundLatitude: _playgroundCenter!.latitude,
          playgroundLongitude: _playgroundCenter!.longitude,
          playgroundRadiusInMeters: _playgroundRadiusMeters!.toInt(),
          jailLatitude: _prisonCenter!.latitude,
          jailLongitude: _prisonCenter!.longitude,
          jailRadiusInMeters: _prisonRadiusMeters!.toInt(),
          roundDurationMinutes: _roundDurationMinutes,
          locationRevealIntervalMinutes: _locationShareMinutes,
          policeWaitMinutes: _policeWaitMinutes,
          maxParticipants: _maxParticipants,
        );

    if (!mounted) return;

    // 로딩 팝업 닫기
    if (navigator.canPop()) navigator.pop();

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

      // 게임 참가 정보 설정 (방장은 기본적으로 POLICE 팀)
      // authNotifierProvider는 signInWithGoogle/Apple 직후 서버 닉네임으로 설정되므로
      // 이 시점에 읽으면 정확한 게임 닉네임을 가져올 수 있음
      final myNickname = ref.read(authNotifierProvider).value?.nickname ?? '';
      ref
          .read(gameParticipantNotifierProvider.notifier)
          .setGameInfo(
            gameId: result.gameId,
            nickname: myNickname,
            team: 'POLICE',
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
        final errorMessage = _getErrorMessage(sessionState.error!);
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
  String _getErrorMessage(Object error) {
    if (error is AppException) {
      return error.message;
    }
    return '게임 방 생성에 실패했습니다. 다시 시도해주세요.';
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
        AppSnackbar.show(
          context,
          message: '이미 참가 중인 게임이 있습니다.',
          backgroundColor: AppColors.red,
        );
        setState(() => _isLoading = false);
        return;
      }

      final info = status.participationInfo!;

      if (info.gameStatus == 'WAITING') {
        context.go(RoutePaths.waitingRoomWithId(info.gameId.toString()));
      } else if (info.gameStatus == 'IN_PROGRESS') {
        context.go(
          '${RoutePaths.gameWithId(info.gameId.toString())}'
          '?team=${info.team}&pid=${info.participantId}',
        );
      } else {
        debugPrint(
          '⚠️ 알 수 없는 게임 상태: ${info.gameStatus} (gameId=${info.gameId})',
        );
        AppSnackbar.show(
          context,
          message: '알 수 없는 게임 상태입니다.',
          backgroundColor: AppColors.red,
        );
        setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) {
        AppSnackbar.show(
          context,
          message: '이미 참가 중인 게임이 있습니다.',
          backgroundColor: AppColors.red,
        );
        setState(() => _isLoading = false);
      }
    }
  }

  // ============================================
  // Step Callbacks
  // ============================================

  void _onPlaygroundSet(LatLng center, double radius) {
    setState(() {
      _playgroundCenter = center;
      _playgroundRadiusMeters = radius;
      // 플레이그라운드 변경 시 감옥 초기화 (새 범위 내에서 재설정 필요)
      _prisonCenter = null;
      _prisonRadiusMeters = null;
    });
  }

  void _onPrisonSet(LatLng center, double radius) {
    setState(() {
      _prisonCenter = center;
      _prisonRadiusMeters = radius;
    });
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

  /// 각 단계별 제목
  static const _stepTitles = [
    '구역 선택을 먼저 설정할까요?',
    '인원을 설정해요',
    '기본 정보를 설정해요',
    '최종 설정을 확인해요',
  ];

  /// 각 단계별 설명
  static const _stepDescriptions = [
    '게임에 필요한 구역을 설정해요',
    '최소 2명부터 게임 진행이 가능해요',
    '게임을 진행할 때, 꼭 필요한 정보들이에요',
    '방 생성 전 마지막으로 설정을 확인할까요?',
  ];

  /// 각 단계별 버튼 텍스트
  String get _buttonText {
    switch (_currentStep) {
      case 0:
      case 1:
      case 2:
        return '다음';
      case 3:
        return '방 생성하기';
      default:
        return '다음';
    }
  }

  /// 다음 버튼 활성화 여부
  bool get _isNextButtonEnabled {
    switch (_currentStep) {
      case 0:
        return _playgroundCenter != null &&
            _playgroundRadiusMeters != null &&
            _prisonCenter != null &&
            _prisonRadiusMeters != null;
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
                _buildHeader(),
                SizedBox(height: AppSpacing.vertical28),
                Expanded(child: _buildPageView()),
                _buildBottomButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// AppBar (StepIndicator + PreviousButton)
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppColors.black800),
      automaticallyImplyLeading: false,
      leading: PreviousButton(onPressed: _goToPreviousStep),
      title: StepIndicator(totalSteps: 4, currentStep: _currentStep),
      centerTitle: false,
      titleSpacing: 0,
      actions: [SizedBox(width: AppSpacing.horizontal20)],
    );
  }

  /// Header (제목 + 설명)
  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.horizontal4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _stepTitles[_currentStep],
            style: AppTextStyles.heading_24.copyWith(color: AppColors.black),
          ),
          SizedBox(height: AppSpacing.vertical16),
          Text(
            _stepDescriptions[_currentStep],
            style: AppTextStyles.paragraph_14_100.copyWith(
              color: AppColors.black600,
            ),
          ),
        ],
      ),
    );
  }

  /// PageView (4개 스텝 콘텐츠)
  Widget _buildPageView() {
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
            playgroundCenter: _playgroundCenter,
            playgroundRadiusMeters: _playgroundRadiusMeters,
            prisonCenter: _prisonCenter,
            prisonRadiusMeters: _prisonRadiusMeters,
            onPlaygroundSet: _onPlaygroundSet,
            onPrisonSet: _onPrisonSet,
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
            roundDurationKey: _tutorialKeyRoundDuration,
            locationShareKey: _tutorialKeyLocationShare,
            policeWaitKey: _tutorialKeyPoliceWait,
          ),
        ),

        // Step 3: 최종 설정 확인
        SingleChildScrollView(
          child: _playgroundRadiusMeters != null && _prisonRadiusMeters != null
              ? Step3InviteCodeContent(
                  zones: [
                    ZoneInfo(
                      id: 'playground',
                      name: '플레이그라운드',
                      radiusMeters: _playgroundRadiusMeters!.toInt(),
                    ),
                    ZoneInfo(
                      id: 'prison',
                      name: '감옥',
                      radiusMeters: _prisonRadiusMeters!.toInt(),
                    ),
                  ],
                  settings: SessionSettings(
                    maxPlayers: _maxParticipants,
                    roundTimeMinutes: _roundDurationMinutes,
                    locationShareMinutes: _locationShareMinutes,
                    policeStartDelayMinutes: _policeWaitMinutes,
                  ),
                )
              : const Center(child: Text('구역 정보를 먼저 설정해주세요')),
        ),
      ],
    );
  }

  /// 하단 버튼
  Widget _buildBottomButton() {
    return AppButton(
      text: _buttonText,
      onPressed: _isNextButtonEnabled && !_isLoading ? _goToNextStep : null,
      isLoading: _isLoading,
      showBorder: false,
    );
  }
}
