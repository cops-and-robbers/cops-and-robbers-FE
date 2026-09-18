import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../features/game/domain/entities/area_shape.dart';
import '../../../features/game/domain/polygon_geometry.dart';
import '../../../l10n/app_localizations.dart';
import '../../constants/app_colors.dart';
import '../../constants/game_config.dart';
import '../../constants/map_styles.dart';
import '../../constants/spacing_and_radius.dart';
import '../../constants/text_styles.dart';
import '../../services/location/device_location_service.dart';
import '../../services/vibration_service.dart';
import '../../utils/path_simplifier.dart';
import '../../utils/zone_metric_formatter.dart';
import '../buttons/my_location_button.dart';
import '../chips/action_chip.dart' as custom_chip;
import '../chips/info_radius_chip.dart';
import '../snackbars/app_snackbar.dart';
import 'zone_draw_layer.dart';
import 'zone_slider_spacer.dart';
import 'zone_vertex_handle_icon.dart';

/// 핀 기반 폴리곤 구역 설정 위젯 (지도를 꾹 누른 채 그려서 편집)
///
/// 지도를 꾹 누르면 그리기가 시작되고, 손가락을 끌면 궤적이 그려지며, 손을 떼면
/// 그 궤적을 단순화한 꼭짓점이 구역이 된다. 그린 순서가 곧 경계 순서다.
/// 그린 뒤에는 꼭짓점 손잡이를 꾹 눌러 끌어 하나씩 옮길 수 있다.
/// 짧게 끌면 지도가 움직인다 — 롱프레스가 제스처 아레나에서 이기면 팬은 탈락한다.
/// 꼭짓점 목록은 [onPointsChanged]로 부모에 전달된다(전송·검증에 사용).
class PinZoneSettingWidget extends StatefulWidget {
  const PinZoneSettingWidget({
    super.key,
    required this.initialPoints,
    required this.pinColor,
    required this.fillColor,
    required this.strokeColor,
    required this.onPointsChanged,
    this.referencePolygon,
    this.locationButtonColor,
    this.areaChipBackgroundColor,
    this.isDarkMode = false,
    this.mapHeight,
    this.expandMap = false,
  });

  /// 초기 꼭짓점 목록 (편집/복원용, 경계 순서)
  final List<LatLng> initialPoints;

  /// 구역 색상 (플레이그라운드 blue / 감옥 red) — 칩·버튼 기본색
  final Color pinColor;

  /// 다각형 채움 색상 (미리보기·그리는 중 공통)
  final Color fillColor;

  /// 다각형 외곽선 색상 (미리보기·그리는 중 공통)
  final Color strokeColor;

  /// 꼭짓점 목록 콜백 (경계 순서)
  final void Function(List<LatLng> points) onPointsChanged;

  /// 읽기 전용 참조 다각형 (감옥 설정 시 플레이그라운드 표시용)
  final List<LatLng>? referencePolygon;

  /// 내 위치 버튼 아이콘 색상 (기본: pinColor)
  final Color? locationButtonColor;

  /// 면적 칩 배경색 (기본: pinColor)
  final Color? areaChipBackgroundColor;

  /// 다크 모드 여부 (지도 스타일)
  final bool isDarkMode;

  /// 지도 높이 (기본: 360)
  final double? mapHeight;

  /// 지도가 남는 높이를 전부 차지한다. 거리(원형) 편집과 지도 크기가 같도록 그쪽의
  /// 반경 슬라이더 자리만큼은 비워 둔다. 부모가 높이를 정해 줄 때만 켠다 — 켜면
  /// [mapHeight]는 무시된다.
  final bool expandMap;

  @override
  State<PinZoneSettingWidget> createState() => PinZoneSettingWidgetState();
}

class PinZoneSettingWidgetState extends State<PinZoneSettingWidget> {
  List<LatLng> _points = const [];

  /// 그리는 중인 궤적 (위젯 로컬 화면 좌표). 손을 떼면 비운다.
  /// setState가 아니라 notifier로 들고 있어 손가락이 움직일 때마다 지도(플랫폼 뷰)까지
  /// 리빌드하지 않는다 — 카메라 이동 중 매 프레임 setState가 프레임 드롭을 부른 #66의 교훈.
  final ValueNotifier<List<Offset>> _stroke = ValueNotifier(const []);

  BitmapDescriptor? _handleIcon;

  /// 꼭짓점 화면 좌표 캐시 (위젯 로컬, `_points`와 같은 순서). 롱프레스가 손잡이 근처인지
  /// 동기로 판정하는 데 쓴다. 카메라가 멈출 때와 구역이 바뀔 때만 다시 계산하고,
  /// 카메라가 움직이기 시작하면 비운다 — 매 프레임 좌표 추적을 하지 않는다(#66).
  List<Offset> _handles = const [];

  /// 겹친 _refreshHandles 호출 중 마지막 것만 반영하기 위한 요청 번호
  int _handleRequestId = 0;

  /// 꼭짓점을 끄는 동안 지도 위의 편집 다각형·손잡이를 숨긴다 — 레이어의 미리보기와
  /// 겹쳐 두 모양으로 보이지 않게.
  bool _isDraggingVertex = false;

  GoogleMapController? _mapController;
  LatLng? _locationFocusTarget;
  bool _isLocationFocused = false;
  bool _isProgrammaticMove = false;
  bool _isInitialized = false;

  /// 최근 카메라 위치 — 내 위치 포커스 판정에 쓴다
  CameraPosition? _lastCamera;

  // Fallback 위치 (어린이대공원)
  static const double _initialZoom = 15;
  static const double _locationFocusToleranceInMeters = 5;
  late LatLng _initialCamera;

  /// 궤적 단순화 허용오차 — 손 떨림은 버리고 의도한 꺾임만 남기는 폭
  double get _strokeTolerance => 6.w;

  @override
  void initState() {
    super.initState();
    _points = List.of(widget.initialPoints);
    _initialize();
  }

  @override
  void dispose() {
    _stroke.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    _handleIcon = await ZoneVertexHandleIcon.create(color: widget.pinColor);
    final currentLocation = await DeviceLocationService.getCurrentLatLng();
    _locationFocusTarget = currentLocation;

    // 초기 카메라: 기존 구역 있으면 그 중심, 없으면 현재 위치 → fallback
    if (_points.isNotEmpty) {
      _initialCamera = _centroidOf(_points);
    } else {
      _initialCamera =
          currentLocation ?? DeviceLocationService.fallbackLocation;
    }
    _lastCamera = CameraPosition(target: _initialCamera, zoom: _initialZoom);
    _isLocationFocused = _isCameraFocusedOnLocation(_lastCamera!);

    if (mounted) setState(() => _isInitialized = true);
  }

  LatLng _centroidOf(List<LatLng> pts) {
    final lat = pts.map((p) => p.latitude).reduce((a, b) => a + b) / pts.length;
    final lng =
        pts.map((p) => p.longitude).reduce((a, b) => a + b) / pts.length;
    return LatLng(lat, lng);
  }

  /// 지정된 꼭짓점 배치의 경계 반경 (중심 → 가장 먼 점, 미터)
  double _boundingRadius(List<LatLng> points) {
    final center = _centroidOf(points);
    var radius = 0.0;
    for (final p in points) {
      final d = Geolocator.distanceBetween(
        center.latitude,
        center.longitude,
        p.latitude,
        p.longitude,
      );
      if (d > radius) radius = d;
    }
    return radius;
  }

  /// 축소 하한 — 인게임(google_map_view)과 같은 반경 기반 동적 패턴.
  /// 값은 원형 편집(zone_setting_widget)과 동일한 완화 테이블 — 설정 편의.
  /// 표시할 점 2개 미만이면 반경 0으로 취급해 최저 하한(14)부터 시작한다 —
  /// 원형 편집이 기본 반경으로 진입 즉시 제한되는 것과 동일한 UX.
  /// 편집 구역과 참조 폴리곤이 벌어질수록 하한이 단계적으로 풀린다.
  double get _minZoom {
    final ref = widget.referencePolygon;
    final visiblePoints = [
      ..._points,
      // 렌더링(_buildPolygons)과 같은 조건 — 3점 미만의 미완성 참조 폴리곤은
      // 화면에 그리지 않으므로, 보이지 않는 점이 줌 하한을 정하지 않게 제외한다.
      if (ref != null && ref.length >= GameConfig.minPolygonVertexCount) ...ref,
    ];
    return _minZoomForRadius(
      visiblePoints.length < 2 ? 0 : _boundingRadius(visiblePoints),
    );
  }

  static double _minZoomForRadius(double radiusInMeters) =>
      switch (radiusInMeters) {
        <= 200 => 14.0,
        <= 500 => 13.0,
        <= 1000 => 12.0,
        _ => 11.0,
      };

  bool _isCameraFocusedOnLocation(CameraPosition camera) {
    final location = _locationFocusTarget;
    if (location == null) return false;
    return Geolocator.distanceBetween(
          camera.target.latitude,
          camera.target.longitude,
          location.latitude,
          location.longitude,
        ) <=
        _locationFocusToleranceInMeters;
  }

  void _updateLocationFocus(CameraPosition camera) {
    final isFocused = _isCameraFocusedOnLocation(camera);
    if (isFocused == _isLocationFocused) return;
    setState(() => _isLocationFocused = isFocused);
  }

  List<GeoPoint> get _geoPoints => [
    for (final p in _points)
      GeoPoint(latitude: p.latitude, longitude: p.longitude),
  ];

  /// Android의 getScreenCoordinate/getLatLng는 물리 픽셀, iOS는 논리 픽셀 기준이다(#405).
  /// await 전에 읽어 둔다(context 사용).
  double get _screenScale => defaultTargetPlatform == TargetPlatform.android
      ? MediaQuery.of(context).devicePixelRatio
      : 1.0;

  Future<LatLng> _toLatLng(
    GoogleMapController controller,
    Offset position,
    double scale,
  ) => controller.getLatLng(
    ScreenCoordinate(
      x: (position.dx * scale).round(),
      y: (position.dy * scale).round(),
    ),
  );

  /// 꼭짓점 화면 좌표 캐시를 다시 계산한다.
  Future<void> _refreshHandles() async {
    final requestId = ++_handleRequestId;
    final controller = _mapController;
    final points = _points;
    if (controller == null || points.isEmpty) {
      if (_handles.isNotEmpty) setState(() => _handles = const []);
      return;
    }
    final scale = _screenScale;
    final coordinates = await Future.wait([
      for (final p in points) controller.getScreenCoordinate(p),
    ]);
    // 변환하는 사이 구역이 바뀌었거나 더 최신 요청이 들어왔으면 낡은 결과다 — 버린다
    // (바꾼 쪽 또는 새 요청이 다시 채운다)
    if (!mounted ||
        requestId != _handleRequestId ||
        !identical(points, _points)) {
      return;
    }
    setState(
      () => _handles = [
        for (final c in coordinates) Offset(c.x / scale, c.y / scale),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 그리기
  // ---------------------------------------------------------------------------

  /// 손 뗌 → 궤적 단순화 → 올가미 닫기 → 지도 좌표 변환 → 구역 교체.
  /// 3점 미만이거나 닫는 변이 몸통을 가로지르면 이전 구역을 그대로 둔다.
  Future<void> _onDrawEnd(List<Offset> stroke) async {
    final controller = _mapController;
    if (controller == null) return;

    // 단순화한 뒤 첫 자기교차에서 고리를 닫는다(올가미) — 끝이 시작점을 지나쳐 겹쳐도
    // 다시 그리게 하지 않는다. 떨림 수준(허용오차의 4배 정사각형 미만)의 고리는 무시.
    final vertices = closeLoopAtFirstCrossing(
      simplifyPath(
        stroke,
        tolerance: _strokeTolerance,
        maxPoints: GameConfig.maxPolygonVertexCount,
      ),
      minLoopArea: 16 * _strokeTolerance * _strokeTolerance,
    );
    if (vertices.length < GameConfig.minPolygonVertexCount) return;

    final scale = _screenScale;
    final latLngs = await Future.wait([
      for (final v in vertices) _toLatLng(controller, v, scale),
    ]);
    if (!mounted) return;

    final geo = [
      for (final p in latLngs)
        GeoPoint(latitude: p.latitude, longitude: p.longitude),
    ];
    // 올가미 뒤에도 남는 경우는 하나 — 선은 안 만났는데 끝과 시작을 잇는 닫는 변이
    // 몸통을 가로지를 때(소용돌이형). 이때만 다시 그리게 한다.
    if (hasSelfIntersection(geo)) {
      AppSnackbar.show(
        context,
        message: AppLocalizations.of(context).zoneDrawCrossedMessage,
        backgroundColor: AppColors.red,
        isDarkMode: widget.isDarkMode,
      );
      return;
    }

    // 옛 구역의 화면 좌표를 한 왕복이라도 들고 있지 않게 캐시를 같이 비운다
    // (캐시 없음 = 그리기로 폴백). 바로 아래 _refreshHandles가 새로 채운다.
    setState(() {
      _points = List.unmodifiable(latLngs);
      _handles = const [];
    });
    widget.onPointsChanged(_points);
    _refreshHandles();
  }

  void _onVertexDragStart() => setState(() => _isDraggingVertex = true);

  /// 손 뗌 → 그 점 하나만 지도 좌표로 바꿔 교체. 유효한 다각형이 안 되면 되돌린다.
  /// 레이어는 이 Future가 끝날 때까지 미리보기를 유지한다.
  Future<void> _onVertexDragEnd(int index, Offset position) async {
    try {
      final controller = _mapController;
      if (controller == null || index >= _points.length) return;
      final latLng = await _toLatLng(controller, position, _screenScale);
      if (!mounted) return;

      final moved = moveVertex(
        _geoPoints,
        index,
        GeoPoint(latitude: latLng.latitude, longitude: latLng.longitude),
      );
      if (moved == null) {
        AppSnackbar.show(
          context,
          message: AppLocalizations.of(context).zoneVertexCrossedMessage,
          backgroundColor: AppColors.red,
          isDarkMode: widget.isDarkMode,
        );
        return;
      }
      setState(
        () => _points = List.unmodifiable([
          for (var i = 0; i < _points.length; i++)
            i == index ? latLng : _points[i],
        ]),
      );
      widget.onPointsChanged(_points);
    } finally {
      if (mounted) {
        setState(() => _isDraggingVertex = false);
        _refreshHandles();
      }
    }
  }

  /// 구역 제거 (전체 해제) — 햅틱은 호출하는 ActionChip이 내장한다.
  void _clearAll() {
    if (_points.isEmpty) return;
    setState(() {
      _points = const [];
      _handles = const [];
    });
    widget.onPointsChanged(const []);
  }

  Set<Polygon> _buildPolygons() {
    final polygons = <Polygon>{};

    // 참조 다각형 (감옥 설정 시 플레이그라운드) — 파란 계열 고정
    final ref = widget.referencePolygon;
    if (ref != null && ref.length >= GameConfig.minPolygonVertexCount) {
      polygons.add(
        Polygon(
          polygonId: const PolygonId('reference_polygon'),
          points: ref,
          fillColor: AppColors.blue500Alpha20,
          strokeColor: AppColors.blue800,
          strokeWidth: 2,
          consumeTapEvents: false,
        ),
      );
    }

    // 편집 중인 다각형 (꼭짓점 3개 이상일 때만). 꼭짓점을 끄는 동안은 레이어의
    // 미리보기가 대신 그린다.
    if (!_isDraggingVertex &&
        _points.length >= GameConfig.minPolygonVertexCount) {
      polygons.add(
        Polygon(
          polygonId: const PolygonId('editing_polygon'),
          points: _points,
          fillColor: widget.fillColor,
          strokeColor: widget.strokeColor,
          strokeWidth: 2,
          consumeTapEvents: false,
        ),
      );
    }
    return polygons;
  }

  /// 꼭짓점 손잡이 — 탭은 아무 일도 하지 않는다(consumeTapEvents로 마커 탭의
  /// 카메라 이동·정보창 기본 동작을 막는다). 이동은 그리기 레이어의 롱프레스가 처리한다.
  Set<Marker> _buildHandleMarkers() {
    final icon = _handleIcon;
    if (icon == null || _isDraggingVertex) return const {};
    return {
      for (var i = 0; i < _points.length; i++)
        Marker(
          markerId: MarkerId('zone_vertex_$i'),
          position: _points[i],
          icon: icon,
          anchor: ZoneVertexHandleIcon.anchor,
          consumeTapEvents: true,
        ),
    };
  }

  Future<void> _resetToCurrentLocation() async {
    final loc = await DeviceLocationService.getCurrentLatLng();
    if (loc == null || !mounted) return;
    _locationFocusTarget = loc;
    _isProgrammaticMove = true;
    setState(() => _isLocationFocused = true);
    await _mapController?.animateCamera(CameraUpdate.newLatLng(loc));
  }

  /// 지도 영역의 틀.
  ///
  /// expandMap: 남는 높이를 지도로 채우되, 거리(원형) 편집의 `간격 20 + 반경 슬라이더`
  /// 자리를 똑같이 비운다 — 토글할 때 지도 크기가 튀지 않게(DEC-0001).
  ///
  /// 고정 높이: 부모가 tight 높이 제약을 주면 `SizedBox`는 들어온 제약이 우선이라
  /// 그대로 늘어난다. `Align`이 자식에게 loose 제약을 넘겨 지정한 높이를 지킨다.
  Widget _fixedHeight(Widget child) {
    if (widget.expandMap) {
      return Column(
        children: [
          Expanded(child: child),
          SizedBox(height: AppSpacing.vertical20),
          const ZoneSliderSpacer(),
        ],
      );
    }
    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(height: widget.mapHeight ?? 360.h, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return _fixedHeight(const Center(child: CircularProgressIndicator()));
    }
    final l10n = AppLocalizations.of(context);

    return _fixedHeight(
      Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _initialCamera,
              zoom: _initialZoom,
            ),
            // 폴리곤이 화면 밖으로 벗어날 만큼 과도하게 축소되는 것을 막는다.
            // 꼭짓점 배치의 경계 반경으로 하한을 동적 계산 — 구역이 바뀌는 setState마다 갱신.
            minMaxZoomPreference: MinMaxZoomPreference(_minZoom, 20),
            style: widget.isDarkMode ? MapStyles.dark : null,
            onMapCreated: (controller) {
              _mapController = controller;
              // 생성 직후에는 onCameraIdle이 보장되지 않는다 — 복원된 구역의 손잡이 좌표를
              // 여기서 한 번 채운다. 안 채우면 보이는 손잡이를 꾹 눌러도 "새로 그리기"로
              // 빠져 저장된 구역을 덮어쓴다.
              _refreshHandles();
            },
            // 카메라가 움직이면 손잡이 화면 좌표는 낡는다 — 멈출 때 다시 계산한다
            onCameraMoveStarted: () {
              if (_handles.isNotEmpty) setState(() => _handles = const []);
            },
            onCameraMove: (pos) {
              _lastCamera = pos;
              if (_isProgrammaticMove) return;
              _updateLocationFocus(pos);
            },
            onCameraIdle: () {
              _isProgrammaticMove = false;
              final camera = _lastCamera;
              if (camera != null) _updateLocationFocus(camera);
              _refreshHandles();
            },
            polygons: _buildPolygons(),
            markers: _buildHandleMarkers(),
            // 탭 인식기는 두지 않는다 — 지도 탭이 더 이상 아무 일도 하지 않는다.
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<PanGestureRecognizer>(() => PanGestureRecognizer()),
              Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()),
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: false,
          ),

          // 그리기 레이어 — 롱프레스가 아닌 터치는 지도로 그대로 내려간다.
          // 그리는 동안은 화면 좌표만 쓰고, 지도 좌표 변환은 손을 뗄 때 한 번만 한다.
          Positioned.fill(
            child: ZoneDrawLayer(
              stroke: _stroke,
              fillColor: widget.fillColor,
              strokeColor: widget.strokeColor,
              handles: _handles,
              // 이 시점에 아레나가 롱프레스로 결정돼 지도 팬은 탈락한다.
              onLongPressRecognized: VibrationService.instance().longPress,
              onDrawEnd: _onDrawEnd,
              onVertexDragStart: _onVertexDragStart,
              onVertexDragEnd: _onVertexDragEnd,
              onVertexDragCancel: () =>
                  setState(() => _isDraggingVertex = false),
            ),
          ),

          // 빈 상태 힌트 (상단 중앙) — 구역도 궤적도 없을 때만. 터치는 통과시킨다.
          if (_points.isEmpty)
            Positioned(
              top: AppSpacing.vertical16,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: ValueListenableBuilder<List<Offset>>(
                  valueListenable: _stroke,
                  builder: (_, stroke, child) =>
                      stroke.isEmpty ? child! : const SizedBox.shrink(),
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.horizontal16,
                        vertical: AppSpacing.vertical8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.blackAlpha60,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        l10n.zoneDrawHint,
                        style: AppTextStyles.tag_12.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // 전체 해제 (우상단) — 구역이 있을 때만. 면적 칩과 동일하게 조건부로 두어
          // 쓸 수 없는 상태에서 지도를 가리지 않게 한다.
          // radius는 같은 오버레이의 내 위치 버튼·면적 칩(12.r)에 맞춘다.
          // ActionChip은 전달값에 .r을 적용하지 않으므로 12.r을 직접 넘긴다.
          if (_points.isNotEmpty)
            Positioned(
              top: AppSpacing.vertical16,
              right: AppSpacing.horizontal20,
              child: custom_chip.ActionChip(
                text: l10n.zoneClearAllPins,
                icon: Icons.close,
                onTap: _clearAll,
                backgroundColor: widget.pinColor,
                borderRadius: 12.r,
              ),
            ),

          // 내 위치 버튼 (좌하단)
          Positioned(
            bottom: AppSpacing.vertical16,
            left: AppSpacing.horizontal20,
            child: MyLocationButton(
              onPressed: _resetToCurrentLocation,
              isFocused: _isLocationFocused,
              containerSize: 40,
              iconSize: 24,
              borderRadius: 12,
              focusedColor: widget.locationButtonColor ?? widget.pinColor,
              unfocusedColor: AppColors.black400,
              backgroundColor: widget.isDarkMode ? AppColors.black : null,
              isDarkMode: widget.isDarkMode,
            ),
          ),

          // 면적 칩 (꼭짓점 3개 이상일 때만, 우하단)
          if (_points.length >= GameConfig.minPolygonVertexCount)
            Positioned(
              bottom: AppSpacing.vertical16,
              right: AppSpacing.horizontal20,
              child: InfoRadiusChip(
                prefix: l10n.zoneAreaLabel,
                value: formatAreaValue(polygonAreaInSquareMeters(_geoPoints)),
                backgroundColor:
                    widget.areaChipBackgroundColor ?? widget.pinColor,
                isDarkMode: widget.isDarkMode,
              ),
            ),
        ],
      ),
    );
  }
}
