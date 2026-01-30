import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/services/storage/session_draft_storage_service.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/buttons/previous_button.dart';
import '../../../../core/widgets/map/zone_setting_widget.dart';

/// 감옥 구역 설정 화면
///
/// 지도에서 잡힌 도둑이 갇히는 감옥 범위를 지정합니다.
/// ZoneSettingWidget을 통해 중심점과 반경을 설정하고,
/// 설정 완료 시 데이터를 로컬 저장소에 저장한 후 이전 페이지로 반환합니다.
class SetupPrisonPage extends StatefulWidget {
  const SetupPrisonPage({super.key});

  @override
  State<SetupPrisonPage> createState() => _SetupPrisonPageState();
}

class _SetupPrisonPageState extends State<SetupPrisonPage> {
  // ============================================
  // State Variables
  // ============================================

  /// 현재 설정 중인 구역 중심 좌표
  LatLng? _currentCenter;

  /// 현재 설정 중인 구역 반경 (미터)
  double _currentRadius = 100.0; // 기본값: 100m (감옥은 플레이그라운드보다 작음)

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
        // 저장된 데이터가 있으면 복원, 없으면 null 유지
        _currentCenter = draft?.jailCenter;
        _currentRadius = draft?.jailRadiusInMeters ?? 100.0;
        _isLoading = false; // 로딩 완료
      });
    }
  }

  // ============================================
  // Event Handlers
  // ============================================

  /// 구역 변경 시 호출되는 콜백
  void _onZoneChanged(LatLng center, double radius) {
    _currentCenter = center;
    _currentRadius = radius;
  }

  /// 설정 완료 버튼 클릭 시
  Future<void> _onComplete() async {
    if (_currentCenter == null) {
      debugPrint('⚠️ 구역 중심이 설정되지 않았습니다');
      return;
    }

    // 로컬 저장소에 저장
    await _storageService.updatePrisonZone(_currentCenter!, _currentRadius);

    // 데이터 반환 (Map 형태)
    if (mounted) {
      context.pop({'center': _currentCenter, 'radius': _currentRadius});
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
          title: Text(
            '감옥 설정',
            style: AppTextStyles.heading_20.copyWith(color: AppColors.black),
          ),
          backgroundColor: AppColors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.black800),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // 로딩 완료 후 정상 UI 렌더링
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          '감옥 설정',
          style: AppTextStyles.heading_20.copyWith(color: AppColors.black),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: AppColors.black800, // 뒤로가기 아이콘 색상
        ),
        centerTitle: true,
        leading: PreviousButton(onPressed: () => context.pop()),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ZoneSettingWidget (지도 + 슬라이더)
            Expanded(
              child: ZoneSettingWidget(
                initialCenter: _currentCenter,
                initialRadius: _currentRadius,
                minRadius: 50,
                maxRadius: 500,
                // 감옥 색상 (빨간색 계열)
                centerColor: AppColors.red,
                borderColor: AppColors.red800,
                fillColor: AppColors.red500,
                onZoneChanged: _onZoneChanged,
              ),
            ),

            // 하단 버튼 영역
            Padding(
              padding: AppPadding.all20,
              child: AppButton(
                text: '완료',
                onPressed: _onComplete,
                backgroundColor: AppColors.red,
                showBorder: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
