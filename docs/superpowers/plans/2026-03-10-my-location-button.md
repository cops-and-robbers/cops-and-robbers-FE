# MyLocationButton 공통 컴포넌트 구현 계획

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** "현재 위치로 이동" 버튼을 공통 컴포넌트로 추출하고, 포커스 상태에 따른 색상 변경 기능 추가

**Architecture:** `SvgIconButton`을 래핑하는 `MyLocationButton` 위젯 생성. `isFocused` 상태는 부모가 관리하며, 버튼 탭 시 focused, 지도 드래그 시 unfocused로 전환. 각 지도 뷰(Google/Naver)에 카메라 이동 콜백을 추가하여 부모에게 전달.

**Tech Stack:** Flutter, flutter_svg, SvgIconButton, GoogleMap/NaverMap 카메라 콜백

---

## Chunk 1: 공통 컴포넌트 생성 및 적용

### Task 1: MyLocationButton 위젯 생성

**Files:**

- Create: `lib/core/widgets/buttons/my_location_button.dart`

- [ ] **Step 1: MyLocationButton 위젯 작성**

```dart
import 'package:flutter/material.dart';

import 'svg_icon_button.dart';

/// 현재 위치로 이동하는 지도 버튼
///
/// [isFocused]에 따라 아이콘 색상이 전환됨:
/// - focused: [focusedColor] (현재 위치에 포커싱된 상태)
/// - unfocused: [unfocusedColor] (지도를 드래그하여 포커싱 해제)
class MyLocationButton extends StatelessWidget {
  const MyLocationButton({
    super.key,
    required this.onPressed,
    required this.isFocused,
    this.containerSize = 48,
    this.iconSize = 24,
    this.focusedColor = const Color(0xFF3F63D9),   // AppColors.blue
    this.unfocusedColor = const Color(0xFF9FB1EC),  // AppColors.blue500
  });

  /// 버튼 클릭 시 실행될 콜백 (현재 위치로 카메라 이동)
  final VoidCallback onPressed;

  /// 현재 위치에 포커싱된 상태 여부
  final bool isFocused;

  /// 컨테이너 크기 (기본값: 48)
  final double containerSize;

  /// 아이콘 크기 (기본값: 24)
  final double iconSize;

  /// 포커싱 시 아이콘 색상 (기본: AppColors.blue)
  final Color focusedColor;

  /// 포커싱 해제 시 아이콘 색상 (기본: AppColors.blue500)
  final Color unfocusedColor;

  @override
  Widget build(BuildContext context) {
    return SvgIconButton(
      assetPath: 'assets/icons/mage_location-fill.svg',
      onPressed: onPressed,
      containerSize: containerSize,
      iconSize: iconSize,
      iconColor: isFocused ? focusedColor : unfocusedColor,
    );
  }
}
```

- [ ] **Step 2: 커밋**

```bash
git add lib/core/widgets/buttons/my_location_button.dart
git commit -m "feat : MyLocationButton 공통 컴포넌트 생성"
```

---

### Task 2: GoogleMapView에 카메라 이동 콜백 추가

**Files:**

- Modify: `lib/features/game/presentation/widgets/google_map_view.dart`

GoogleMapView에 `onCameraMoveStarted` 콜백을 외부에서 주입받을 수 있도록 추가. 사용자가 지도를 드래그하면 부모에게 알림.

- [ ] **Step 1: GoogleMapView에 onCameraMoveStarted 콜백 파라미터 추가**

`GoogleMapView` 생성자에 `VoidCallback? onCameraMoveStarted` 파라미터 추가:

```dart
class GoogleMapView extends StatefulWidget {
  const GoogleMapView({super.key, this.onCameraMoveStarted});

  /// 사용자가 지도를 드래그하여 카메라 이동 시 호출
  final VoidCallback? onCameraMoveStarted;

  @override
  State<GoogleMapView> createState() => GoogleMapViewState();
}
```

- [ ] **Step 2: GoogleMap 위젯에 onCameraMoveStarted 전달**

`build()` 메서드의 `GoogleMap(...)` 내부에 추가:

```dart
onCameraMoveStarted: widget.onCameraMoveStarted,
```

`myLocationEnabled: true,` 바로 위에 추가.

- [ ] **Step 3: 커밋**

```bash
git add lib/features/game/presentation/widgets/google_map_view.dart
git commit -m "feat : GoogleMapView에 onCameraMoveStarted 콜백 추가"
```

---

### Task 3: NaverMapView에 카메라 이동 콜백 추가

**Files:**

- Modify: `lib/features/game/presentation/widgets/naver_map_view.dart`

NaverMapView에 `onCameraChange` 콜백을 외부에서 주입받을 수 있도록 추가.

- [ ] **Step 1: NaverMapView에 onCameraMoveStarted 콜백 파라미터 추가**

```dart
class NaverMapView extends StatefulWidget {
  const NaverMapView({super.key, this.onCameraMoveStarted});

  /// 사용자가 지도를 드래그하여 카메라 이동 시 호출
  final VoidCallback? onCameraMoveStarted;

  @override
  State<NaverMapView> createState() => NaverMapViewState();
}
```

- [ ] **Step 2: NaverMap 위젯에 onCameraChange 콜백 추가**

`onMapReady` 콜백 아래에 추가. NaverMap의 `onCameraChange`는 `NCameraUpdateReason`을 전달하므로, 사용자 제스처(`gesture`)인 경우에만 콜백 호출:

```dart
onCameraChange: (reason, animated) {
  if (reason == NCameraUpdateReason.gesture) {
    widget.onCameraMoveStarted?.call();
  }
},
```

- [ ] **Step 3: 커밋**

```bash
git add lib/features/game/presentation/widgets/naver_map_view.dart
git commit -m "feat : NaverMapView에 onCameraMoveStarted 콜백 추가"
```

---

### Task 4: game_page.dart에 MyLocationButton 적용

**Files:**

- Modify: `lib/features/game/presentation/pages/game_page.dart`

기존 `SvgIconButton(mage_location-fill)` → `MyLocationButton`으로 교체. 포커스 상태 관리 추가.

- [ ] **Step 1: `_isLocationFocused` 상태 변수 추가**

`_GamePageState` 클래스 상단에 추가:

```dart
bool _isLocationFocused = true;
```

- [ ] **Step 2: `_moveToCurrentLocation` 호출 시 포커스 설정**

`_moveToCurrentLocation()` 메서드 시작 부분에 추가:

```dart
void _moveToCurrentLocation() {
  setState(() => _isLocationFocused = true);
  if (widget.mapType == 'naver') {
    ...
```

- [ ] **Step 3: 카메라 이동 시 포커스 해제 핸들러 추가**

`_GamePageState`에 메서드 추가:

```dart
void _onMapCameraMoved() {
  if (_isLocationFocused) {
    setState(() => _isLocationFocused = false);
  }
}
```

- [ ] **Step 4: 지도 뷰에 onCameraMoveStarted 콜백 전달**

`build()` 메서드에서 지도 위젯 생성 부분 수정:

```dart
// 기존:
widget.mapType == 'naver'
    ? NaverMapView(key: _naverMapKey)
    : GoogleMapView(key: _googleMapKey),

// 변경:
widget.mapType == 'naver'
    ? NaverMapView(
        key: _naverMapKey,
        onCameraMoveStarted: _onMapCameraMoved,
      )
    : GoogleMapView(
        key: _googleMapKey,
        onCameraMoveStarted: _onMapCameraMoved,
      ),
```

- [ ] **Step 5: SvgIconButton을 MyLocationButton으로 교체**

`build()` 메서드에서 기존 위치 버튼 (약 line 583):

```dart
// 기존:
SvgIconButton(
  assetPath: 'assets/icons/mage_location-fill.svg',
  onPressed: _moveToCurrentLocation,
  containerSize: 48,
  iconSize: 24,
),

// 변경:
MyLocationButton(
  onPressed: _moveToCurrentLocation,
  isFocused: _isLocationFocused,
  containerSize: 48,
  iconSize: 24,
),
```

import 추가:

```dart
import '../../../../core/widgets/buttons/my_location_button.dart';
```

- [ ] **Step 6: 커밋**

```bash
git add lib/features/game/presentation/pages/game_page.dart
git commit -m "refactor : game_page 현재위치 버튼을 MyLocationButton으로 교체"
```

---

### Task 5: zone_setting_widget.dart에 MyLocationButton 적용

**Files:**

- Modify: `lib/core/widgets/map/zone_setting_widget.dart`

기존 `_buildMyLocationButton()` → `MyLocationButton`으로 교체. 포커스 상태 관리 추가.

- [ ] **Step 1: `_isLocationFocused` 상태 변수 추가**

`ZoneSettingWidgetState` 클래스 상단에 추가:

```dart
bool _isLocationFocused = true;
```

- [ ] **Step 2: `resetToCurrentLocation` 호출 시 포커스 설정**

`resetToCurrentLocation()` 메서드의 카메라 이동 직전에 추가:

```dart
setState(() {
  _isLocationFocused = true;
  _currentCenter = currentLocation;
  _shape.setCenter(currentLocation);
});
```

기존 setState에 `_isLocationFocused = true`를 합침.

- [ ] **Step 3: `_updateCenterFromScreenCenter`에서 포커스 해제**

`_updateCenterFromScreenCenter()` 메서드의 setState에 추가:

```dart
setState(() {
  _isLocationFocused = false;
  _currentCenter = screenCenterLatLng;
  _shape.setCenter(screenCenterLatLng);
});
```

기존 setState에 `_isLocationFocused = false`를 합침.

- [ ] **Step 4: `_buildMyLocationButton` 메서드를 `MyLocationButton`으로 교체**

```dart
// 기존 _buildMyLocationButton() 메서드 전체 삭제하고,
// build() 메서드에서 직접 MyLocationButton 사용:

// 기존 (build 내):
child: _buildMyLocationButton(),

// 변경:
child: MyLocationButton(
  onPressed: resetToCurrentLocation,
  isFocused: _isLocationFocused,
  containerSize: 40,
  iconSize: 24,
  focusedColor: widget.locationButtonColor ?? AppColors.blue,
  unfocusedColor: _unfocusedLocationColor(),
),
```

- [ ] **Step 5: unfocused 색상 헬퍼 메서드 추가**

`ZoneSettingWidgetState`에 추가:

```dart
/// locationButtonColor에 대응하는 unfocused 색상 반환
Color _unfocusedLocationColor() {
  final color = widget.locationButtonColor;
  if (color == AppColors.red || color == AppColors.red800) {
    return AppColors.red500;
  }
  return AppColors.blue500;
}
```

- [ ] **Step 6: `_buildMyLocationButton` 메서드 삭제**

기존 `_buildMyLocationButton()` 메서드(line 385-401) 전체 삭제.

import 추가:

```dart
import '../../widgets/buttons/my_location_button.dart';
```

기존 import 중 불필요해진 것이 없는지 확인 (Material Icons는 다른 곳에서도 사용 가능하므로 유지).

- [ ] **Step 7: 커밋**

```bash
git add lib/core/widgets/map/zone_setting_widget.dart
git commit -m "refactor : zone_setting_widget 현재위치 버튼을 MyLocationButton으로 교체"
```

---

### Task 6: 빌드 검증

- [ ] **Step 1: flutter analyze 실행**

```bash
flutter analyze
```

Expected: No errors (warnings/info OK)

- [ ] **Step 2: 최종 커밋 (필요 시)**

분석에서 발견된 미사용 import 등 정리 후 커밋.
