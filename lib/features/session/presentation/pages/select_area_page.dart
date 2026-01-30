import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/services/storage/session_draft_storage_service.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/buttons/previous_button.dart';
import '../../../../core/widgets/buttons/zone_setting_button.dart';
import '../../../../core/widgets/indicators/step_indicator.dart';
import '../../../../router/route_paths.dart';
import '../../../session/data/models/session_creation_draft_model.dart';

/// 구역 선택/확인 화면
///
/// 플레이그라운드와 감옥 구역 설정을 위한 진입점입니다.
/// ZoneSettingButton을 통해 각 구역 설정 페이지로 이동하며,
/// 두 구역 모두 설정 완료 시 다음 단계로 진행할 수 있습니다.
class SelectAreaPage extends StatefulWidget {
  const SelectAreaPage({super.key});

  @override
  State<SelectAreaPage> createState() => _SelectAreaPageState();
}

class _SelectAreaPageState extends State<SelectAreaPage> {
  // ============================================
  // State Variables
  // ============================================

  /// 플레이그라운드 중심 좌표
  LatLng? playgroundCenter;

  /// 플레이그라운드 반경 (미터)
  double? playgroundRadiusMeters;

  /// 감옥 중심 좌표
  LatLng? prisonCenter;

  /// 감옥 반경 (미터)
  double? prisonRadiusMeters;

  /// 로컬 저장소 서비스
  final _storageService = SessionDraftStorageService();

  /// 두 구역 모두 설정 완료 여부
  bool get isComplete =>
      playgroundCenter != null &&
      playgroundRadiusMeters != null &&
      prisonCenter != null &&
      prisonRadiusMeters != null;

  // ============================================
  // Lifecycle Methods
  // ============================================

  @override
  void initState() {
    super.initState();
    _loadDraftData();
  }

  /// 로컬 저장소에서 기존 데이터 불러오기
  Future<void> _loadDraftData() async {
    final draft = await _storageService.loadDraft();
    if (draft != null && mounted) {
      setState(() {
        playgroundCenter = draft.playgroundCenter;
        playgroundRadiusMeters = draft.playgroundRadiusInMeters;
        prisonCenter = draft.jailCenter;
        prisonRadiusMeters = draft.jailRadiusInMeters;
      });
    }
  }

  // ============================================
  // Event Handlers
  // ============================================

  /// 플레이그라운드 설정 버튼 클릭 시
  Future<void> _onPlaygroundPressed() async {
    final result = await context.push(RoutePaths.setupPlaygroundPath);

    if (result is Map<String, dynamic>) {
      final center = result['center'] as LatLng;
      final radius = result['radius'] as double;

      setState(() {
        playgroundCenter = center;
        playgroundRadiusMeters = radius;
      });
    }
  }

  /// 감옥 설정 버튼 클릭 시
  Future<void> _onPrisonPressed() async {
    final result = await context.push(RoutePaths.setupPrisonPath);

    if (result is Map<String, dynamic>) {
      final center = result['center'] as LatLng;
      final radius = result['radius'] as double;

      setState(() {
        prisonCenter = center;
        prisonRadiusMeters = radius;
      });
    }
  }

  /// 다음 버튼 클릭 시
  Future<void> _onNextPressed() async {
    if (!isComplete) return;

    // 로컬 저장소에 최종 저장
    await _storageService.saveDraft(
      SessionCreationDraftModel(
        playgroundCenter: playgroundCenter,
        playgroundRadiusInMeters: playgroundRadiusMeters,
        jailCenter: prisonCenter,
        jailRadiusInMeters: prisonRadiusMeters,
      ),
    );

    // 다음 페이지로 이동 (2단계: 인원 설정)
    if (mounted) {
      context.go(RoutePaths.sessionSettingsPath);
    }
  }

  // ============================================
  // Build Methods
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: AppColors.black800, // 뒤로가기 아이콘 색상
        ),
        // title 영역에 StepIndicator 배치
        title: const StepIndicator(
          totalSteps: 4,
          currentStep: 0, // 0: 구역설정 (현재), 1: 인원설정, 2: 기본정보, 3: 초대코드
        ),
        centerTitle: false, // 좌측 정렬로 더 많은 공간 확보
        titleSpacing: 0, // 뒤로가기 버튼과 title 사이 간격 제거
        leading: PreviousButton(onPressed: () => context.pop()),
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

              // ZoneSettingButton 두 개
              _buildZoneButtons(),

              const Spacer(),

              // 확인 버튼 (NicknameSetupPage와 동일한 위치)
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
            '구역을 먼저 설정할까요?',
            style: AppTextStyles.heading_24.copyWith(color: AppColors.black),
          ),
          SizedBox(height: AppSpacing.vertical16),

          // 설명
          Text(
            '게임에 필요한 구역을 설정해요',
            style: AppTextStyles.paragraph_14_100.copyWith(
              color: AppColors.black600,
            ),
          ),
        ],
      ),
    );
  }

  /// ZoneSettingButton 섹션
  Widget _buildZoneButtons() {
    return Column(
      children: [
        // 플레이그라운드 버튼
        ZoneSettingButton(
          zoneType: ZoneType.playground,
          title: '플레이그라운드',
          radiusMeters: playgroundRadiusMeters,
          onPressed: _onPlaygroundPressed,
        ),

        SizedBox(height: AppSpacing.vertical8),

        // 감옥 버튼
        ZoneSettingButton(
          zoneType: ZoneType.prison,
          title: '감옥',
          radiusMeters: prisonRadiusMeters,
          onPressed: _onPrisonPressed,
        ),
      ],
    );
  }

  /// 다음 버튼 (NicknameSetupPage 스타일)
  Widget _buildNextButton() {
    return AppButton(
      text: '다음',
      onPressed: isComplete ? _onNextPressed : null,
      showBorder: false,
    );
  }
}
