import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/role_theme_provider.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/services/storage/session_draft_storage_service.dart';
import '../../../../core/services/tutorial/tutorial_keys.dart';
import '../../../../core/services/tutorial/tutorial_service.dart';
import '../../../../core/tutorial/app_tutorial_style.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/buttons/previous_button.dart';
import '../../../../core/constants/game_config.dart';
import '../../../../core/widgets/map/pin_zone_setting_widget.dart';
import '../../../../core/widgets/map/zone_setting_widget.dart';
import '../../../game/data/models/game_area_model.dart';
import '../../../game/domain/entities/area_shape.dart';
import '../../../game/domain/polygon_geometry.dart';
import '../widgets/area_type_toggle.dart';
import '../../../../l10n/app_localizations.dart';

/// 플레이그라운드 구역 설정 화면
///
/// 지도에서 게임이 진행될 플레이그라운드 범위를 지정합니다.
/// ZoneSettingWidget을 통해 중심점과 반경을 설정하고,
/// 설정 완료 시 데이터를 로컬 저장소에 저장한 후 이전 페이지로 반환합니다.
///
/// **편집 모드**: [editInitialShape]이 제공되면
/// 로컬 저장소(SessionDraftStorage) 대신 전달받은 초기값을 사용하고,
/// 완료 시 저장소에 쓰지 않고 pop 결과만 반환합니다.
class SetupPlaygroundPage extends ConsumerStatefulWidget {
  const SetupPlaygroundPage({super.key, this.editInitialShape});

  /// 편집 모드 초기 구역 (null이면 생성 모드)
  final AreaShape? editInitialShape;

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

  /// 현재 선택된 구역 설정 방식 (거리=원형 / 핀=폴리곤)
  GameAreaType _areaType = GameAreaType.circle;

  /// 실제로 진입한 적 있는 구역 방식.
  ///
  /// 토글 시 지도 위젯을 교체하면 GoogleMap이 dispose→재생성되어 매번
  /// Maps SDK map-load가 발생한다. IndexedStack으로 위젯을 유지하되,
  /// 방문한 모드만 실제 렌더링해 불필요한 지도 로드를 막는다.
  final Set<GameAreaType> _visitedAreaTypes = {};

  /// 핀 모드 정렬된 꼭짓점 목록 (PinZoneSettingWidget 콜백으로 갱신)
  List<LatLng> _pinPoints = [];

  /// 로딩 상태 (데이터 로드 중 여부)
  bool _isLoading = true;

  /// 지도 초기화 완료 상태 (ZoneSettingWidget이 _onZoneChanged를 호출했는지 여부)
  bool _isMapReady = false;

  /// 로컬 저장소 서비스
  final _storageService = SessionDraftStorageService();

  // ============================================
  // Tutorial Keys
  // ============================================

  /// 지도 영역(Expanded) 튜토리얼 타겟 키
  final _tutorialKeyMap = GlobalKey();

  /// 반경 칩 튜토리얼 타겟 키
  final _tutorialKeyRadiusChip = GlobalKey();

  // ============================================
  // Lifecycle Methods
  // ============================================

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  /// 편집 모드 여부
  bool get _isEditMode => widget.editInitialShape != null;

  /// 기존에 저장된 데이터 불러오기 (재설정 시)
  Future<void> _loadExistingData() async {
    // 편집 모드: 전달받은 초기값 사용
    if (_isEditMode) {
      if (mounted) {
        setState(() {
          final initialShape = widget.editInitialShape!;
          if (initialShape is PolygonShape) {
            _areaType = GameAreaType.polygon;
            _pinPoints = [
              for (final point in initialShape.points)
                LatLng(point.latitude, point.longitude),
            ];
          } else if (initialShape is CircleShape) {
            _currentCenter = LatLng(
              initialShape.center.latitude,
              initialShape.center.longitude,
            );
            _currentRadius = initialShape.radiusInMeters;
          }
          _isLoading = false;
        });
      }
      return;
    }

    // 생성 모드: 로컬 저장소에서 복원
    final draft = await _storageService.loadDraft();
    if (mounted) {
      setState(() {
        _areaType = draft?.areaType ?? GameAreaType.circle;
        _pinPoints = List.of(draft?.playgroundPinPoints ?? const []);
        _currentCenter = draft?.playgroundCenter;
        _currentRadius = draft?.playgroundRadiusInMeters ?? 500.0;
        _isLoading = false;
      });

      // 로딩 완료 후 다음 프레임에서 튜토리얼 트리거
      // ZoneSettingWidget이 렌더된 뒤에 실행해야 GlobalKey가 유효함
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showTutorialIfNeeded();
      });
    }
  }

  /// 처음 방문한 사용자에게 튜토리얼 표시
  Future<void> _showTutorialIfNeeded() async {
    final completed = await TutorialService.isCompleted(
      TutorialKeys.setupPlayground,
    );
    if (completed || !mounted) return;

    // ZoneSettingWidget 내부 초기화(위치 조회 등)를 기다리기 위한 지연
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    final l10n = AppLocalizations.of(context);
    AppTutorialStyle.show(
      context: context,
      targets: [
        AppTutorialStyle.target(
          keyTarget: _tutorialKeyRadiusChip,
          description: l10n.setupPlaygroundRadiusInputHint,
          align: TutorialAlign.bottom,
        ),
      ],
      onFinish: () =>
          TutorialService.markCompleted(TutorialKeys.setupPlayground),
    );
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

  /// 핀 모드 완료 가능 여부
  bool get _isPinComplete {
    if (_pinPoints.length < GameConfig.minPolygonVertexCount) return false;
    final geo = [
      for (final p in _pinPoints)
        GeoPoint(latitude: p.latitude, longitude: p.longitude),
    ];
    return isValidPolygon(geo);
  }

  /// 완료 버튼 활성화 여부
  bool get _canComplete =>
      _areaType == GameAreaType.polygon ? _isPinComplete : _isMapReady;

  /// 설정 완료 버튼 클릭 시
  Future<void> _onComplete() async {
    // 핀 모드: 정렬된 꼭짓점 목록 반환
    if (_areaType == GameAreaType.polygon) {
      if (!_isEditMode) {
        await _storageService.updatePlaygroundPinZone(_pinPoints);
      }
      if (mounted) {
        context.pop<AreaShape>(
          AreaShape.polygon(
            points: [
              for (final point in _pinPoints)
                GeoPoint(latitude: point.latitude, longitude: point.longitude),
            ],
          ),
        );
      }
      return;
    }

    // 원형 모드
    final center = _currentCenter;
    if (center == null) return;

    // 생성 모드에서만 로컬 저장소에 저장
    if (!_isEditMode) {
      await _storageService.updatePlaygroundZone(center, _currentRadius);
    }

    if (mounted) {
      context.pop<AreaShape>(
        AreaShape.circle(
          center: GeoPoint(
            latitude: center.latitude,
            longitude: center.longitude,
          ),
          radiusInMeters: _currentRadius,
        ),
      );
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
    final l10n = AppLocalizations.of(context);

    // 로딩 중일 때는 로딩 인디케이터 표시
    if (_isLoading) {
      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          title: Text(l10n.zonePlayground, style: titleStyle),
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

    // 현재 모드를 방문 처리 — IndexedStack이 해당 지도 위젯을 실제 렌더링한다.
    _visitedAreaTypes.add(_areaType);

    // 로딩 완료 후 정상 UI 렌더링
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(l10n.zonePlayground, style: titleStyle),
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

            // 구역 설정 방식 토글 (거리/핀)
            Center(
              child: AreaTypeToggle(
                selected: _areaType,
                isDarkMode: isDark,
                onChanged: (type) {
                  // 각 모드의 입력값은 유지 — 완료 시 선택된 모드 것만 사용
                  setState(() => _areaType = type);
                },
              ),
            ),

            // 간격 20px
            SizedBox(height: AppSpacing.vertical20),

            // 설명 텍스트
            Padding(
              padding: AppPadding.horizontal24,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _areaType == GameAreaType.polygon
                      ? l10n.setupPlaygroundPinDescription
                      : l10n.setupPlaygroundDescription,
                  style: AppTextStyles.label16Medium.copyWith(color: textColor),
                ),
              ),
            ),

            // 간격 20px
            SizedBox(height: AppSpacing.vertical20),

            // 지도 영역 (모드에 따라 원형/핀 위젯 스위칭)
            //
            // IndexedStack으로 두 위젯을 유지해 토글 시 GoogleMap이
            // dispose→재생성되며 매번 지도를 다시 로드하는 것을 막는다.
            // 방문하지 않은 모드는 빈 위젯으로 두어 최초 지도 로드도 지연시킨다.
            Expanded(
              key: _tutorialKeyMap,
              child: IndexedStack(
                sizing: StackFit.expand,
                index: _areaType == GameAreaType.polygon ? 1 : 0,
                children: [
                  // 0: 원형(거리) 모드
                  _visitedAreaTypes.contains(GameAreaType.circle)
                      ? ZoneSettingWidget(
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
                          valueTextStyle: isDark
                              ? AppTextStyles.robberLabel
                              : null,
                          radiusChipKey: _tutorialKeyRadiusChip,
                        )
                      : const SizedBox.shrink(),
                  // 1: 핀(폴리곤) 모드
                  _visitedAreaTypes.contains(GameAreaType.polygon)
                      ? PinZoneSettingWidget(
                          initialPoints: _pinPoints,
                          pinColor: AppColors.blue,
                          fillColor: AppColors.blue500Alpha20,
                          strokeColor: AppColors.blue800,
                          locationButtonColor: AppColors.blue,
                          isDarkMode: isDark,
                          onPointsChanged: (points) {
                            setState(() => _pinPoints = points);
                          },
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            ),

            // 하단 버튼 영역
            Padding(
              padding: AppPadding.all20,
              child: AppButton(
                text: l10n.buttonDone,
                onPressed: _canComplete ? _onComplete : null,
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
