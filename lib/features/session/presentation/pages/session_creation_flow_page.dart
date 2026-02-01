import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/services/storage/session_draft_storage_service.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/buttons/previous_button.dart';
import '../../../../core/widgets/indicators/step_indicator.dart';
import '../../../../router/route_paths.dart';
import '../../data/models/create_session_request.dart';
import '../../data/models/session_creation_draft_model.dart';
import '../../domain/entities/session_settings.dart';
import '../../domain/entities/zone_info.dart';
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
/// - Step 3: 초대 코드 확인
///
/// 특징:
/// - 좌우 슬라이드 애니메이션으로 단계 전환
/// - 뒤로가기 시 이전 단계로 이동 (Step 0에서는 홈으로)
/// - 임시 저장 기능 (SessionDraftStorageService)
/// - Step 2→3 전환 시 세션 생성 API 호출
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

  // Step 0: 구역 선택
  LatLng? _playgroundCenter;
  double? _playgroundRadiusMeters;
  LatLng? _prisonCenter;
  double? _prisonRadiusMeters;

  // Step 1: 인원 설정
  int _maxParticipants = 10;

  // Step 2: 게임 설정
  int _roundDurationMinutes = 30;
  int _locationShareMinutes = 3;
  int _policeWaitMinutes = 5;

  // Step 3: 초대 코드
  String? _inviteCode;

  // ============================================
  // Lifecycle
  // ============================================

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _storageService = SessionDraftStorageService();
    _loadDraftData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
        _locationShareMinutes = draft.locationShareMinutes ?? 3;
        _policeWaitMinutes = draft.policeWaitMinutes ?? 5;
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

  /// 다음 단계로 이동 (Step 0~2: "다음" 버튼)
  Future<void> _goToNextStep() async {
    if (_currentStep < 3) {
      await _saveDraft();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Step 3: "방 생성하기" 버튼 → 세션 생성 API 호출
      await _createSessionAndNavigate();
    }
  }

  /// 세션 생성 및 대기실 이동
  Future<void> _createSessionAndNavigate() async {
    await _createSession();

    if (_inviteCode != null) {
      // 세션 생성 성공 → Draft 삭제 후 대기실로 이동
      await _storageService.clearDraft();
      if (mounted) {
        // TODO: 대기실로 이동 (현재는 게임으로)
        context.go(RoutePaths.waitingRoom);
      }
    }
  }

  /// 세션 생성 API 호출
  Future<void> _createSession() async {
    if (_playgroundCenter == null ||
        _playgroundRadiusMeters == null ||
        _prisonCenter == null ||
        _prisonRadiusMeters == null) {
      debugPrint('❌ [SessionCreationFlow] 구역 정보가 없습니다');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final request = CreateSessionRequest(
        playgroundLatitude: _playgroundCenter!.latitude,
        playgroundLongitude: _playgroundCenter!.longitude,
        playgroundRadiusInMeters: _playgroundRadiusMeters!,
        jailLatitude: _prisonCenter!.latitude,
        jailLongitude: _prisonCenter!.longitude,
        jailRadiusInMeters: _prisonRadiusMeters!,
        maxParticipants: _maxParticipants,
        roundDurationMinutes: _roundDurationMinutes,
        locationShareMinutes: _locationShareMinutes,
        policeWaitMinutes: _policeWaitMinutes,
      );

      debugPrint('🔧 [SessionCreationFlow] 세션 생성 요청: ${request.toJson()}');

      // TODO: API 연동 후 실제 코드로 교체 필요
      // final session = await ref.read(sessionNotifierProvider.notifier).createSession(request);
      // setState(() => _inviteCode = session.inviteCode);

      // 임시 하드코딩된 초대 코드 (API 연동 전)
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() => _inviteCode = 'ABC123');

      debugPrint('✅ [SessionCreationFlow] 세션 생성 완료: $_inviteCode');
    } catch (e, stack) {
      debugPrint('❌ [SessionCreationFlow] 세션 생성 실패: $e');
      debugPrint('Stack trace: $stack');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('세션 생성에 실패했습니다: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
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
  final _stepTitles = const [
    '구역 선택을 먼저 설정할까요?',
    '인원을 설정해요',
    '기본 정보를 설정해요',
    '최종 설정을 확인해요',
  ];

  /// 각 단계별 설명
  final _stepDescriptions = const [
    '게임에 필요한 구역을 설정해요',
    '최소 5명부터 게임 진행이 가능해요',
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
