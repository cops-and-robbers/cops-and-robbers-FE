# MyLocationButton 공통 컴포넌트 설계

## 배경

game_page.dart와 zone_setting_widget.dart에서 "현재 위치로 이동" 버튼이 각각 다른 방식으로 구현되어 있음. 동일 기능을 공통 컴포넌트로 추출하고, 포커스 상태에 따른 색상 변경 기능을 추가.

## 컴포넌트: MyLocationButton

**위치:** `lib/core/widgets/buttons/my_location_button.dart`

### API

```dart
MyLocationButton({
  required VoidCallback onPressed,
  required bool isFocused,
  double containerSize = 48,
  double iconSize = 24,
  Color focusedColor = AppColors.blue,
  Color unfocusedColor = AppColors.blue500,
})
```

- SVG 아이콘: `assets/icons/mage_location-fill.svg` 고정
- `SvgIconButton` 기반, `iconColor`를 `isFocused`에 따라 전환

### 포커스 상태 흐름

- 버튼 탭 → 부모가 `isFocused = true` 설정 → focused 색상
- 사용자가 지도 드래그 → 부모가 `isFocused = false` 설정 → unfocused 색상

## 사용처별 변경

### game_page.dart

- 기존 `SvgIconButton` → `MyLocationButton(containerSize: 48, iconSize: 24)`
- `_moveToCurrentLocation` 호출 시 `isFocused = true`
- 지도 카메라 이동 감지 시 `isFocused = false`
- 색상: focused=`AppColors.blue`, unfocused=`AppColors.blue500`

### zone_setting_widget.dart

- 기존 `_buildMyLocationButton()` → `MyLocationButton(containerSize: 40, iconSize: 24)`
- `resetToCurrentLocation` 호출 시 `isFocused = true`
- 카메라 이동 감지 시 `isFocused = false`
- 색상: `locationButtonColor` 파라미터에 따라 focused/unfocused 결정 (blue→blue500, red→red500)
