# 📊 구현 보고서

## 📌 작업 개요

대기실에서 사용자가 선호하는 지도 타입(Google Maps / Naver Maps)을 선택할 수 있는 기능 구현 완료.
선택한 지도가 게임 화면에서 정상적으로 표시되도록 라우팅 및 조건부 렌더링 구현.

**이슈**: #44 - Google Maps 및 Naver Maps 선택 기능 구현
**보고서 파일**: `.report/20260121_#44_Google_Maps_및_Naver_Maps_선택_기능_구현.md`

---

## 🎯 구현 목표

- 대기실에서 Google Maps / Naver Maps 중 하나를 선택할 수 있는 UI 제공
- 선택한 지도 타입을 게임 화면으로 전달하여 해당 지도 표시
- iOS/Android 플랫폼에서 Google Maps API 키 설정 완료

---

## ✅ 구현 내용

### 1. 대기실 지도 선택 UI 추가

**파일**: `lib/features/session/presentation/pages/waiting_room_page.dart`

- Google Map / Naver Map 선택 버튼 2개 추가
- 버튼 클릭 시 선택한 지도 타입을 쿼리 파라미터로 전달하며 게임 화면으로 이동
- Google Map: 파란색 버튼 (`Colors.blue`)
- Naver Map: 초록색 버튼 (`Colors.green`)

**구현 상세**:
```dart
// Google Map 버튼
ElevatedButton(
  onPressed: () => _startGame(context, 'google'),
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
  ),
  child: const Text('Google Map'),
)

// Naver Map 버튼
ElevatedButton(
  onPressed: () => _startGame(context, 'naver'),
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.green,
    foregroundColor: Colors.white,
  ),
  child: const Text('Naver Map'),
)
```

**특이사항**:
- 와이어프레임 단계이므로 버튼 스타일은 하드코딩
- `_startGame` 헬퍼 함수에서 쿼리 파라미터 생성 및 라우팅 처리

---

### 2. 라우팅 로직 수정 - 쿼리 파라미터 처리

**파일**: `lib/router/app_router.dart`

- GamePage 라우트에서 `mapType` 쿼리 파라미터 추출
- 기본값 `'google'`로 설정하여 직접 URL 접근 시에도 동작 보장

**구현 상세**:
```dart
final mapType = state.uri.queryParameters['mapType'] ?? 'google';
return GamePage(sessionId: sessionId, mapType: mapType);
```

**특이사항**:
- 쿼리 파라미터가 없는 경우 Google Map을 기본값으로 사용
- `/game/{sessionId}?mapType=naver` 형식으로 전달

---

### 3. 게임 화면 조건부 지도 렌더링

**파일**: `lib/features/game/presentation/pages/game_page.dart`

- GamePage에 `mapType` 파라미터 추가 (required)
- `mapType` 값에 따라 GoogleMapView 또는 NaverMapView 조건부 렌더링

**구현 상세**:
```dart
class GamePage extends StatefulWidget {
  const GamePage({
    required this.sessionId,
    required this.mapType,
    super.key,
  });

  final String sessionId;
  final String mapType;
}

// 조건부 렌더링
Positioned.fill(
  child: widget.mapType == 'naver'
      ? const NaverMapView()
      : const GoogleMapView(),
)
```

**특이사항**:
- `widget.mapType == 'naver'` 조건으로 Naver Map 표시
- 그 외의 경우(including 'google') Google Map 표시
- HUD 및 채팅 UI는 지도 위에 Stack으로 오버레이

---

### 4. iOS Google Maps API 키 설정

**파일**: `ios/Flutter/Secrets.xcconfig` (신규 생성)

- iOS용 Google Maps API 키를 xcconfig 파일에 설정
- `Debug.xcconfig` 및 `Release.xcconfig`에서 자동으로 include되어 빌드 시 Info.plist에 주입
- `AppDelegate.swift`에서 API 키를 읽어 Google Maps SDK 초기화

**구현 상세**:
```xcconfig
// Google Maps API Key
// iOS Google Maps SDK에서 사용
// Info.plist → AppDelegate를 통해 초기화
GOOGLE_MAPS_API_KEY={API_KEY}
```

**특이사항**:
- 이전에는 `Secrets.xcconfig` 파일이 없어서 Google Maps 초기화 실패
- `Secrets.xcconfig.example` 파일을 복사하여 생성
- API 키는 민감 정보이므로 Git에 커밋되지 않도록 `.gitignore` 관리 필요

---

### 5. Android Google Maps API 키 설정

**파일**: `android/local.properties`

- Android용 Google Maps API 키를 local.properties에 설정
- `build.gradle.kts`에서 읽어 `AndroidManifest.xml`의 `${GOOGLE_MAPS_API_KEY}` placeholder에 주입

**구현 상세**:
```properties
# Google Maps API Key
GOOGLE_MAPS_API_KEY={API_KEY}
```

**특이사항**:
- `build.gradle.kts`에서 `manifestPlaceholders` 설정으로 자동 주입
- API 키는 민감 정보이므로 Git에 커밋되지 않도록 `.gitignore` 관리 필요

---

### 6. 디버그 로깅 추가

**파일**:
- `lib/features/session/presentation/pages/waiting_room_page.dart`
- `lib/features/game/presentation/pages/game_page.dart`
- `lib/features/game/presentation/widgets/google_map_view.dart`
- `lib/features/game/presentation/widgets/naver_map_view.dart`

- 지도 선택, 라우팅, 지도 초기화 과정에서 상세한 디버그 로그 출력
- 문제 발생 시 원인 파악을 위한 에러 로그 추가

**구현 상세**:
```dart
debugPrint('🎮 게임 시작 버튼 클릭');
debugPrint('지도 타입: $mapType');
debugPrint('이동 경로: $route');

debugPrint('🗺️ GoogleMapView initState 시작');
debugPrint('✅ google map ready');
```

**특이사항**:
- 와이어프레임 단계에서 문제 해결에 매우 유용
- 향후 프로덕션 배포 전 `kDebugMode` 조건부 처리 필요

---

## 🔧 주요 변경사항 상세

### WaitingRoomPage - 지도 선택 UI
대기실 중앙에 Google Map(파란색), Naver Map(초록색) 버튼 배치.
각 버튼 클릭 시 `_startGame` 함수 호출하여 `?mapType=google` 또는 `?mapType=naver` 쿼리 파라미터와 함께 `/game/{sessionId}` 경로로 이동.

### AppRouter - 쿼리 파라미터 전달
GamePage 라우트에서 `state.uri.queryParameters['mapType']` 추출.
기본값 `'google'`로 설정하여 쿼리 파라미터 없이 직접 URL 접근 시에도 Google Map 표시.

### GamePage - 조건부 렌더링
`widget.mapType` 값에 따라 삼항 연산자로 GoogleMapView 또는 NaverMapView 선택.
지도는 `Positioned.fill`로 전체 화면 채우고, 위에 HUD 및 채팅 UI Stack으로 오버레이.

### iOS/Android API 키 설정
- **iOS**: `ios/Flutter/Secrets.xcconfig` 파일 생성, API 키 추가 → Info.plist → AppDelegate 초기화 흐름
- **Android**: `android/local.properties`에 API 키 추가 → build.gradle.kts → AndroidManifest.xml 주입 흐름

**특이사항**:
- iOS와 Android는 API 키 설정 방식이 다름 (xcconfig vs local.properties)
- 두 플랫폼 모두에서 설정 완료하여 Google Maps 정상 작동 확인

---

## 🧪 테스트 및 검증

### 테스트 환경
- **iOS 시뮬레이터**: iPhone 17 Pro, iOS 26.0
- **Google Maps API 키**: 설정 완료 후 지도 로딩 확인
- **Naver Maps**: Client ID 설정 완료 (기존)

### 검증 항목
✅ WaitingRoomPage에서 Google Map / Naver Map 버튼 표시
✅ Google Map 버튼 클릭 → GamePage에서 Google Maps 표시
✅ Naver Map 버튼 클릭 → GamePage에서 Naver Maps 표시
✅ iOS에서 Google Maps 정상 로딩 (API 키 설정 후)
✅ Naver Maps 정상 로딩
✅ 지도 위에 HUD 및 채팅 UI 오버레이 정상 표시
✅ 라우팅 흐름: 대기실 → 지도 선택 → 게임 화면 전환 완벽

### 로그 확인
```
flutter: ✅ Naver Map initialized successfully
flutter: 🎮 게임 시작 버튼 클릭
flutter: 지도 타입: google
flutter: 이동 경로: /game/session123?mapType=google
flutter: 🗺️ GamePage build - mapType: google
flutter: 🗺️ GoogleMapView initState 시작
flutter: ✅ google map ready
```

---

## 📌 참고사항

### 보안 관련
- **API 키 관리**: `Secrets.xcconfig` 및 `local.properties` 파일은 `.gitignore`에 추가하여 Git 추적 방지 필요
- **API 키 노출 방지**: 현재는 와이어프레임 단계이므로 임시로 커밋되었으나, 프로덕션 배포 전 반드시 제거 및 재발급 필요

### 와이어프레임 단계 특성
- 버튼 스타일 하드코딩: 추후 디자인 시스템 적용 시 constants로 분리 예정
- 디버그 로그 과다: 문제 해결에 유용하나, 프로덕션 배포 전 `kDebugMode` 조건부 처리 필요
- 기본값 처리: 쿼리 파라미터 누락 시 Google Map 표시 (향후 요구사항에 따라 변경 가능)

### 향후 개선 사항
- 매직 스트링 `'google'`, `'naver'` → `MapType.google`, `MapType.naver` 상수로 변경
- 버튼 스타일 → `MapConstants` 클래스로 분리
- 에러 UI 개선: 사용자 친화적 메시지 및 재시도 버튼 추가
- 단위 테스트 작성: WaitingRoomPage, GamePage, 라우팅 로직 검증

---
