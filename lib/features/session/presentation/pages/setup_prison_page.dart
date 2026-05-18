import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/role_theme_provider.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/services/storage/session_draft_storage_service.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/buttons/previous_button.dart';
import '../../../../core/widgets/map/models/circle_zone_shape.dart';
import '../../../../core/widgets/map/zone_setting_widget.dart';
import '../../../../l10n/app_localizations.dart';

/// 감옥 구역 설정 화면
///
/// 지도에서 잡힌 도둑이 갇히는 감옥 범위를 지정합니다.
/// ZoneSettingWidget을 통해 중심점과 반경을 설정하고,
/// 설정 완료 시 데이터를 로컬 저장소에 저장한 후 이전 페이지로 반환합니다.
///
/// **편집 모드**: [editInitialCenter]와 [editInitialRadius]가 제공되면
/// 로컬 저장소(SessionDraftStorage) 대신 전달받은 초기값을 사용하고,
/// 완료 시 저장소에 쓰지 않고 pop 결과만 반환합니다.
class SetupPrisonPage extends ConsumerStatefulWidget {
  const SetupPrisonPage({
    super.key,
    this.editInitialCenter,
    this.editInitialRadius,
    this.editPlaygroundCenter,
    this.editPlaygroundRadius,
  });

  /// 편집 모드 초기 중심 좌표 (null이면 생성 모드)
  final LatLng? editInitialCenter;

  /// 편집 모드 초기 반경 (미터)
  final double? editInitialRadius;

  /// 편집 모드 플레이그라운드 중심 좌표 (검증용)
  final LatLng? editPlaygroundCenter;

  /// 편집 모드 플레이그라운드 반경 (검증용)
  final double? editPlaygroundRadius;

  @override
  ConsumerState<SetupPrisonPage> createState() => _SetupPrisonPageState();
}

class _SetupPrisonPageState extends ConsumerState<SetupPrisonPage> {
  // ============================================
  // State Variables
  // ============================================

  /// 현재 설정 중인 구역 중심 좌표
  LatLng? _currentCenter;

  /// 현재 설정 중인 구역 반경 (미터)
  double _currentRadius = 100.0; // 기본값: 100m (감옥은 플레이그라운드보다 작음)

  /// 로딩 상태 (데이터 로드 중 여부)
  bool _isLoading = true;

  /// 지도 초기화 완료 상태 (ZoneSettingWidget이 _onZoneChanged를 호출했는지 여부)
  bool _isMapReady = false;

  /// 플레이그라운드 구역 정보 (참조용)
  LatLng? _playgroundCenter;
  double? _playgroundRadius;

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
  ///
  /// 감옥 초기값 또는 플레이그라운드 편집값이 전달되면 편집 모드로 동작합니다.
  /// 플레이그라운드 변경 후 감옥 재설정 시에는 editInitialCenter가 null이지만
  /// editPlaygroundCenter가 전달되므로 편집 모드로 판단해야 합니다.
  bool get _isEditMode =>
      widget.editInitialCenter != null || widget.editPlaygroundCenter != null;

  /// 기존에 저장된 데이터 불러오기 (재설정 시)
  Future<void> _loadExistingData() async {
    // 편집 모드: 전달받은 초기값 사용
    if (_isEditMode) {
      if (mounted) {
        setState(() {
          _currentCenter = widget.editInitialCenter;
          _currentRadius = widget.editInitialRadius ?? 100.0;
          _playgroundCenter = widget.editPlaygroundCenter;
          _playgroundRadius = widget.editPlaygroundRadius;
          _isLoading = false;
        });
      }
      return;
    }

    // 생성 모드: 로컬 저장소에서 복원
    final draft = await _storageService.loadDraft();
    if (mounted) {
      setState(() {
        _currentCenter = draft?.jailCenter;
        _currentRadius = draft?.jailRadiusInMeters ?? 100.0;
        _playgroundCenter = draft?.playgroundCenter;
        _playgroundRadius = draft?.playgroundRadiusInMeters;
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
      await _storageService.updatePrisonZone(center, _currentRadius);
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

  /// 플레이그라운드 참조 구역 생성
  CircleZoneShape? _buildPlaygroundReferenceZone() {
    if (_playgroundCenter == null || _playgroundRadius == null) return null;
    return CircleZoneShape(
      center: _playgroundCenter!,
      radius: _playgroundRadius!,
      fillColor: AppColors.blue500,
      strokeColor: AppColors.blue800,
      strokeWidth: 2,
      circleId: 'reference_zone',
    );
  }

  /// 부동소수점 오차 방지를 위한 허용 오차 (미터)
  static const double _epsilonMeters = 1.0;

  /// 감옥이 플레이그라운드 안에 있는지 검증
  bool _isJailInsidePlayground() {
    final center = _currentCenter;
    final playgroundCenter = _playgroundCenter;
    final playgroundRadius = _playgroundRadius;

    // 플레이그라운드 미설정 시 완료 불가
    if (playgroundCenter == null || playgroundRadius == null) return false;
    if (center == null) return false;

    final distance = Geolocator.distanceBetween(
      center.latitude,
      center.longitude,
      playgroundCenter.latitude,
      playgroundCenter.longitude,
    );

    // 감옥 중심 ~ 플레이그라운드 중심 거리 + 감옥 반경 ≤ 플레이그라운드 반경
    return (distance + _currentRadius) <= (playgroundRadius + _epsilonMeters);
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
    final l10n = AppLocalizations.of(context);

    // 로딩 중일 때는 로딩 인디케이터 표시
    if (_isLoading) {
      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          title: Text(l10n.session_setupPrisonPage_L210, style: titleStyle),
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
        title: Text(l10n.session_setupPrisonPage_L227, style: titleStyle),
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
                  l10n.session_setupPrisonPage_L248,
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
                minRadius: 5,
                maxRadius: 300,
                // 감옥 색상 (빨간색 계열)
                centerColor: AppColors.red,
                borderColor: AppColors.red800,
                fillColor: AppColors.red500,
                inactiveTrackColor: AppColors.red100,
                radiusChipBackgroundColor: AppColors.red,
                locationButtonColor: AppColors.red,
                referenceZone: _buildPlaygroundReferenceZone(),
                onZoneChanged: _onZoneChanged,
                isDarkMode: isDark,
                valueTextStyle: isDark ? AppTextStyles.robberLabel : null,
              ),
            ),

            // 검증 실패 안내 문구
            if (_isMapReady && !_isJailInsidePlayground())
              Padding(
                padding: AppPadding.horizontal24,
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    _playgroundCenter == null
                        ? l10n.session_setupPrisonPage_L286
                        : l10n.session_setupPrisonPage_L287,
                    style: AppTextStyles.label16Medium.copyWith(
                      color: AppColors.red,
                    ),
                  ),
                ),
              ),

            // 하단 버튼 영역
            Padding(
              padding: AppPadding.all20,
              child: AppButton(
                text: l10n.session_setupPrisonPage_L299,
                onPressed: _isMapReady && _isJailInsidePlayground()
                    ? _onComplete
                    : null,
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
