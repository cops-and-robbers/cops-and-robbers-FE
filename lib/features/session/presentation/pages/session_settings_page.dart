import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/services/storage/session_draft_storage_service.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/buttons/previous_button.dart';
import '../../../../core/widgets/indicators/step_indicator.dart';
import '../../../../core/widgets/inputs/app_slider.dart';
import '../../../../router/route_paths.dart';

/// 인원 설정 화면 (2단계)
///
/// 게임 세션의 최대 참가자 수를 설정합니다.
/// AppSlider를 통해 5명부터 50명까지 설정 가능하며,
/// 설정 완료 시 데이터를 로컬 저장소에 저장한 후 다음 단계로 진행합니다.
class SessionSettingsPage extends StatefulWidget {
  const SessionSettingsPage({super.key});

  @override
  State<SessionSettingsPage> createState() => _SessionSettingsPageState();
}

class _SessionSettingsPageState extends State<SessionSettingsPage> {
  // ============================================
  // State Variables
  // ============================================

  /// 최대 참가자 수
  int _maxParticipants = 30; // 기본값: 30명

  /// 로딩 상태 (데이터 로드 중 여부)
  bool _isLoading = true;

  /// 로컬 저장소 서비스
  final _storageService = SessionDraftStorageService();

  // ============================================
  // Lifecycle Methods
  // ============================================

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  /// 기존에 저장된 데이터 불러오기 (재설정 시)
  Future<void> _loadExistingData() async {
    final draft = await _storageService.loadDraft();
    if (mounted) {
      setState(() {
        _maxParticipants = draft?.maxParticipants ?? 30;
        _isLoading = false;
      });
    }
  }

  // ============================================
  // Event Handlers
  // ============================================

  /// 다음 버튼 클릭 시
  Future<void> _onNextPressed() async {
    // 로컬 저장소에 저장
    await _storageService.updateMaxParticipants(_maxParticipants);

    // 다음 페이지로 이동 (3단계: 기본정보 설정)
    if (mounted) {
      context.go(RoutePaths.gameSettingsPath);
    }
  }

  // ============================================
  // Build Methods
  // ============================================

  @override
  Widget build(BuildContext context) {
    // 로딩 중일 때는 로딩 인디케이터 표시
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.black800),
          title: const StepIndicator(totalSteps: 4, currentStep: 1),
          centerTitle: false,
          actions: [SizedBox(width: AppSpacing.horizontal4)],
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // 로딩 완료 후 정상 UI 렌더링
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.black800),
        title: const StepIndicator(totalSteps: 4, currentStep: 1),
        centerTitle: false,
        titleSpacing: 0,
        leading: PreviousButton(
          onPressed: () => context.go(RoutePaths.selectArea),
        ),
        actions: [SizedBox(width: AppSpacing.horizontal20)],
      ),
      body: SafeArea(
        child: Padding(
          padding: AppPadding.all20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppSpacing.vertical16),

              // 제목 및 설명
              _buildHeader(),

              SizedBox(height: AppSpacing.vertical28),

              // 최대 참가자 수 슬라이더
              _buildMaxParticipantsSlider(),

              const Spacer(),

              // 다음 버튼
              _buildNextButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// 헤더 섹션 (제목 + 설명)
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목
          Text(
            '인원을 설정해요',
            style: AppTextStyles.heading_24.copyWith(color: AppColors.black),
          ),
          SizedBox(height: AppSpacing.vertical16),

          // 설명
          Text(
            '최소 5명부터 게임 진행이 가능해요',
            style: AppTextStyles.paragraph_14_100.copyWith(
              color: AppColors.black600,
            ),
          ),
        ],
      ),
    );
  }

  /// 최대 참가자 수 슬라이더
  Widget _buildMaxParticipantsSlider() {
    return AppSlider(
      label: '최대 참가자',
      value: _maxParticipants.toDouble(),
      min: 5,
      max: 50,
      unit: '명',
      divisions: 45, // 5~50, 1명 단위
      onChanged: (value) {
        setState(() {
          _maxParticipants = value.toInt();
        });
      },
    );
  }

  /// 다음 버튼
  Widget _buildNextButton() {
    return AppButton(text: '다음', onPressed: _onNextPressed, showBorder: false);
  }
}
