import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/role_theme_provider.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/services/storage/session_draft_storage_service.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/buttons/previous_button.dart';
import '../../../../core/widgets/map/zone_setting_widget.dart';

/// 플레이그라운드 구역 설정 화면
///
/// 지도에서 게임이 진행될 플레이그라운드 범위를 지정합니다.
/// ZoneSettingWidget을 통해 중심점과 반경을 설정하고,
/// 설정 완료 시 데이터를 로컬 저장소에 저장한 후 이전 페이지로 반환합니다.
///
/// **편집 모드**: [editInitialCenter]와 [editInitialRadius]가 제공되면
/// 로컬 저장소(SessionDraftStorage) 대신 전달받은 초기값을 사용하고,
/// 완료 시 저장소에 쓰지 않고 pop 결과만 반환합니다.
class SetupPlaygroundPage extends ConsumerStatefulWidget {
  const SetupPlaygroundPage({
    super.key,
    this.editInitialCenter,
    this.editInitialRadius,
  });

  /// 편집 모드 초기 중심 좌표 (null이면 생성 모드)
  final LatLng? editInitialCenter;

  /// 편집 모드 초기 반경 (미터)
  final double? editInitialRadius;

  @override
  ConsumerState<SetupPlaygroundPage> createState() =>
      _SetupPlaygroundPageState();
}

class _SetupPlaygroundPageState extends ConsumerState<SetupPlaygroundPage> {
  // ============================================
  // State Variables
  // ============================================

  /// 현재 설정 중인 구역 중심 좌표
  LatLng? _currentCenter;

  /// 현재 설정 중인 구역 반경 (미터)
  double _currentRadius = 500.0; // 기본값: 500m

  /// 로딩 상태 (데이터 로드 중 여부)
  bool _isLoading = true;

  /// 지도 초기화 완료 상태 (ZoneSettingWidget이 _onZoneChanged를 호출했는지 여부)
  bool _isMapReady = false;

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

  /// 편집 모드 여부
  bool get _isEditMode => widget.editInitialCenter != null;

  /// 기존에 저장된 데이터 불러오기 (재설정 시)
  Future<void> _loadExistingData() async {
    // 편집 모드: 전달받은 초기값 사용
    if (_isEditMode) {
      if (mounted) {
        setState(() {
          _currentCenter = widget.editInitialCenter;
          _currentRadius = widget.editInitialRadius ?? 500.0;
          _isLoading = false;
        });
      }
      return;
    }

    // 생성 모드: 로컬 저장소에서 복원
    final draft = await _storageService.loadDraft();
    if (mounted) {
      setState(() {
        _currentCenter = draft?.playgroundCenter;
        _currentRadius = draft?.playgroundRadiusInMeters ?? 500.0;
        _isLoading = false;
      });
    }
  }

  // ============================================
  // Event Handlers
  // ============================================

  /// 구역 변경 시 호출되는 콜백
  void _onZoneChanged(LatLng center, double radius) {
    setState(() {
      _currentCenter = center;
      _currentRadius = radius;
      _isMapReady = true; // 지도 초기화 완료
    });
  }

  /// 설정 완료 버튼 클릭 시
  Future<void> _onComplete() async {
    final center = _currentCenter;
    if (center == null) return;

    // 생성 모드에서만 로컬 저장소에 저장
    if (!_isEditMode) {
      await _storageService.updatePlaygroundZone(center, _currentRadius);
    }

    // 데이터 반환 (Map 형태)
    if (mounted) {
      context.pop({
        'lat': center.latitude,
        'lng': center.longitude,
        'radius': _currentRadius,
      });
    }
  }

  // ============================================
  // Build Methods
  // ============================================

  @override
  Widget build(BuildContext context) {
    final isDark = _isEditMode && ref.watch(roleThemeProvider);
    final bgColor = isDark ? AppColors.black900 : AppColors.white;
    final textColor = isDark ? AppColors.white : AppColors.black;
    final titleStyle = isDark
        ? AppTextStyles.robberHeading.copyWith(color: AppColors.white)
        : AppTextStyles.heading_20.copyWith(color: AppColors.black);

    // 로딩 중일 때는 로딩 인디케이터 표시
    if (_isLoading) {
      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          title: Text('플레이그라운드', style: titleStyle),
          backgroundColor: bgColor,
          elevation: 0,
          centerTitle: true,
          leading: PreviousButton(
            onPressed: () => context.pop(),
            color: isDark ? AppColors.black200 : AppColors.black800,
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // 로딩 완료 후 정상 UI 렌더링
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('플레이그라운드', style: titleStyle),
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        leading: PreviousButton(
          onPressed: () => context.pop(),
          color: isDark ? AppColors.black200 : AppColors.black800,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 간격 20px
            SizedBox(height: AppSpacing.vertical20),

            // 설명 텍스트
            Padding(
              padding: AppPadding.horizontal24,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '게임이 진행될 전체 구역의 크기를 설정해요',
                  style: AppTextStyles.label16Medium.copyWith(color: textColor),
                ),
              ),
            ),

            // 간격 20px
            SizedBox(height: AppSpacing.vertical20),

            // ZoneSettingWidget (지도 + 슬라이더)
            Expanded(
              child: ZoneSettingWidget(
                initialCenter: _currentCenter,
                initialRadius: _currentRadius,
                minRadius: 100,
                maxRadius: 1000,
                // 플레이그라운드 색상 (파란색 계열)
                centerColor: AppColors.blue,
                borderColor: AppColors.blue800,
                fillColor: AppColors.blue500,
                locationButtonColor: AppColors.blue,
                onZoneChanged: _onZoneChanged,
                isDarkMode: isDark,
                valueTextStyle: isDark ? AppTextStyles.robberLabel : null,
              ),
            ),

            // 하단 버튼 영역
            Padding(
              padding: AppPadding.all20,
              child: AppButton(
                text: '완료',
                onPressed: _isMapReady ? _onComplete : null,
                backgroundColor: AppColors.blue,
                showBorder: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
