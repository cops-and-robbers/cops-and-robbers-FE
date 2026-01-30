import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/services/storage/session_draft_storage_service.dart';
import '../../../../core/widgets/buttons/zone_setting_button.dart';
import '../../../../router/route_paths.dart';
import '../../../session/data/models/session_creation_draft_model.dart';
import '../widgets/session_step_layout.dart';

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
    return SessionStepLayout(
      currentStep: 0,
      title: '구역을 먼저 설정할까요?',
      description: '게임에 필요한 구역을 설정해요',
      content: _buildZoneButtons(),
      isButtonEnabled: isComplete,
      onNext: _onNextPressed,
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
}
