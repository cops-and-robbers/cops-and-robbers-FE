### 📌 작업 개요

Google Play Console에서 Android 15(API 35) 관련 경고 2건 발생. `enableEdgeToEdge()` 미호출 및 지원 중단 API 사용 경고를 해소하고, 디버그 빌드 개발 편의성과 설정 화면 UX를 함께 개선

**이슈**: [#359](https://github.com/cops-and-robbers/cops-and-robbers/issues/359)

---

### 🔍 문제 분석

**경고 1 — enableEdgeToEdge() 미호출**
- Android 15부터 SDK 35 타겟 앱은 edge-to-edge가 강제 적용됨
- `enableEdgeToEdge()` 미호출 시 Play Console 권장 조치 경고 발생
- `enableEdgeToEdge()`는 `androidx.activity-ktx:1.8.0+` 전용 Kotlin extension으로, Flutter 프로젝트의 명시 의존성에 포함되지 않아 직접 호출 불가
- `androidx.core`의 `WindowCompat.setDecorFitsSystemWindows(window, false)`로 동일 효과 구현

**경고 2 — 지원 중단 API**
- `Window.setStatusBarColor`, `setNavigationBarColor`, `setNavigationBarDividerColor` 사용 감지
- Flutter 프레임워크 내부에서 호출하는 것으로 확인 — 앱 코드 수정 불가
- edge-to-edge 적용 후 경고 완화 여부를 추후 릴리즈로 확인

---

### ✅ 구현 내용

#### 1. Android 15 edge-to-edge 대응
- **파일**: `android/app/src/main/kotlin/com/elipair/copsandrobbers/MainActivity.kt`
- **변경**: `onCreate()` override 추가, `WindowCompat.setDecorFitsSystemWindows(window, false)` 호출
- **이유**: Flutter는 자체적으로 inset을 처리하므로 decorView가 시스템 바 inset을 직접 처리하지 않도록 설정해야 함. `super.onCreate()` 이전에 호출하여 창 설정 초기화보다 먼저 적용

#### 2. 디버그 빌드 배터리 최적화 체크 생략
- **파일**: `lib/features/session/presentation/pages/home_page.dart`
- **변경**: `_ensureBatteryOptimization()` 앞에 `kDebugMode` 분기 추가
- **이유**: 방 만들기 / 방 참가 시 배터리 최적화 무시 권한이 없으면 진행 차단됨. 개발·테스트 중 매번 설정 변경하는 번거로움 해소. 릴리즈 빌드에는 영향 없음

#### 3. 설정 페이지 하단 여백 확대
- **파일**: `lib/features/settings/presentation/pages/settings_page.dart`
- **변경**: 스크롤 영역 최하단 `SizedBox` 높이를 `AppSpacing.vertical32` → `AppSpacing.vertical64`로 변경
- **이유**: 홈 인디케이터(iOS) 또는 제스처 영역(Android)에 마지막 항목이 가려지는 UX 문제 개선

---

### 🔧 주요 변경사항 상세

#### MainActivity.kt — WindowCompat 적용

`onCreate()` override를 `configureFlutterEngine()` 위에 추가. `WindowCompat.setDecorFitsSystemWindows(window, false)`를 `super.onCreate()` 이전에 호출하여 시스템 바 inset이 decorView에 의해 소비되지 않도록 처리.

```kotlin
override fun onCreate(savedInstanceState: Bundle?) {
    WindowCompat.setDecorFitsSystemWindows(window, false)
    super.onCreate(savedInstanceState)
}
```

**특이사항**:
- `enableEdgeToEdge()`가 아닌 `WindowCompat` 사용 — Flutter 프로젝트에서 `androidx.activity-ktx:1.8.0+`가 명시 의존성에 없어 Kotlin extension 미사용
- UI 변화 없음 — Flutter는 이미 내부적으로 edge-to-edge를 처리하고 있었으므로 시각적 차이 발생하지 않음
- Play Console 경고 해소 목적의 설정 변경

#### home_page.dart — kDebugMode 분기

배터리 최적화 체크 함수(`_ensureBatteryOptimization`) 진입 시점에 `kDebugMode` 검사 추가. 디버그 빌드에서는 권한 체크 없이 `onGranted()`를 즉시 호출하여 방 생성/참가 플로우 계속 진행.

```dart
if (kDebugMode) {
  onGranted();
  return;
}
```

---

### 🧪 테스트 및 검증

- Android 15 기기 / 에뮬레이터: 기존 화면과 동일하게 렌더링 확인
- 디버그 빌드: 배터리 최적화 미설정 상태에서 방 만들기·참가 정상 진행 확인
- 릴리즈 빌드: 기존 배터리 최적화 체크 로직 그대로 동작

---

### 📌 참고사항

- `Window.setStatusBarColor` 등 지원 중단 API 경고는 Flutter 프레임워크 내부 호출 — 앱 수정 범위 밖. 향후 Flutter 엔진 버전 업데이트로 해소될 것으로 기대
- `kDebugMode` bypass는 개발·QA 전용이며 프로덕션 빌드에는 적용되지 않음 (`const bool.fromEnvironment('dart.vm.product')` 기반)
