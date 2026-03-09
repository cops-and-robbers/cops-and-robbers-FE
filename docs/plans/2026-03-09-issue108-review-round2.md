# #108 2차 리뷰 개선 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 2차 종합 리뷰에서 발견된 Critical 2건, Major 7건, Minor 8건 중 즉시 수정 가능한 이슈 해결

**Architecture:** 기존 Clean Architecture + Riverpod 코드 생성 패턴 유지. STOMP 재연결 로직 DRY 개선, nullable 필드 안전성 확보, 캐스팅 방어 코드 통일

**Tech Stack:** Flutter 3.9.2+ / Dart 3.9.2+ / Riverpod / Freezed / STOMP

---

## 범위 결정

### 이번 계획에 포함 (즉시 수정 가능)

| # | 이슈 | 심각도 | 예상 복잡도 |
|---|------|--------|------------|
| C1 | `GameEventState.copyWith` nullable 필드 리셋 불가 | Critical | 중 |
| C2 | `_handleEscape`/`_handleLocationReveal` 미가드 캐스팅 | Critical | 하 |
| M2 | `AuthNotifier.build()` userId: 0 fallback | Major | 하 |
| M3 | `arrestRobber` 낙관적 업데이트 race condition | Major | 중 |
| M7 | `gameSystemApiProvider` Data 레이어에 정의 | Major | 하 |
| m1 | 에러 fallback UI 하드코딩 (디자인 시스템) | Minor | 하 |
| m2 | 에러 fallback UI 중복 → 공통 위젯 추출 | Minor | 하 |
| m4 | `SizedBox`에 `const` 누락 | Minor | 하 |
| m5 | hot-path `debugPrint` 미가드 | Minor | 하 |
| m7 | `ArrestResponseModel` 기본값 → required 전환 | Minor | 하 |
| m8 | `SecureTokenStorage` 미사용 메서드 제거 | Minor | 하 |

### 이번 계획에서 제외 (별도 리팩터링 필요)

| # | 이슈 | 제외 사유 |
|---|------|----------|
| M1 | STOMP 재연결 로직 3중 복제 → mixin 추출 | 3개 Notifier 대규모 리팩터링, 별도 브랜치 권장 |
| M4 | session_provider DataSource 직접 호출 | SessionRepository 인터페이스 확장 + 8개 메서드 추가, 별도 이슈 |
| M5 | game/chat feature Repository 계층 부재 | 아키텍처 대규모 변경, 별도 이슈 |
| M6 | `GameEventNotifier` 책임 과다 | M1/M5와 연관, 함께 진행해야 효과적 |
| m3 | 미사용 앱 상수 8건 | 영향 적음, 추후 정리 |
| m6 | `tokenProviderProvider` 이중 네이밍 | 영향 범위 넓음(import 경로 변경), 별도 정리 |

---

## Task 1: [C2] _handleEscape / _handleLocationReveal 캐스팅 방어 코드 통일

**Files:**
- Modify: `lib/features/game/presentation/providers/game_event_provider.dart`

**Context:** `_handleArrest`는 `as num?` + `?.toInt()` null-safe 패턴을 사용하지만, `_handleEscape`와 `_handleLocationReveal`은 `as num` + `.toInt()` 직접 캐스팅으로 서버 데이터 누락 시 런타임 크래시 발생.

**Step 1: `_handleEscape` 방어 코드 추가**

현재 코드 (약 line 401-419):
```dart
final escapedThieves = (data['escapedThieves'] as List?) ?? [];
final escapedIds = escapedThieves
    .map((e) => (e['participantId'] as num).toInt())
    .toSet();
```

변경:
```dart
final escapedThieves = (data['escapedThieves'] as List?) ?? [];
final escapedIds = escapedThieves
    .map((e) => (e['participantId'] as num?)?.toInt())
    .whereType<int>()
    .toSet();
```

**Step 2: `_handleLocationReveal` 방어 코드 추가**

현재 코드 (약 line 352-381):
```dart
newLocations = {
  for (final loc in locationsList)
    (loc['participantId'] as num).toInt(): LatLngModel(
      latitude: (loc['latitude'] as num).toDouble(),
      longitude: (loc['longitude'] as num).toDouble(),
    ),
};
```

변경: try-catch로 개별 항목 보호하거나, null-guard 적용:
```dart
final entries = <int, LatLngModel>{};
for (final loc in locationsList) {
  final pid = (loc['participantId'] as num?)?.toInt();
  final lat = (loc['latitude'] as num?)?.toDouble();
  final lng = (loc['longitude'] as num?)?.toDouble();
  if (pid != null && lat != null && lng != null) {
    entries[pid] = LatLngModel(latitude: lat, longitude: lng);
  }
}
if (entries.isNotEmpty) {
  newLocations = entries;
}
```

**Step 3: 커밋**

```bash
git add lib/features/game/presentation/providers/game_event_provider.dart
git commit -m "fix : _handleEscape/_handleLocationReveal null-safe 캐스팅 적용 #108"
```

---

## Task 2: [M2] AuthNotifier userId: 0 fallback 제거

**Files:**
- Modify: `lib/features/auth/presentation/providers/auth_provider.dart`

**Context:** `getUserId() ?? 0`은 userId가 null일 때 0으로 인증된 것처럼 동작하게 만든다. userId가 없으면 미인증으로 처리해야 함.

**Step 1: userId null이면 미인증 반환**

현재 코드 (약 line 120-126):
```dart
return AuthResultEntity(
  userId: await tokenStorage.getUserId() ?? 0,
  nickname: currentUser.displayName ?? '',
  isNewUser: false,
);
```

변경:
```dart
final userId = await tokenStorage.getUserId();
if (userId == null) {
  debugPrint('[AuthNotifier] ⚠️ userId 없음 → 미인증 처리');
  return null;
}
return AuthResultEntity(
  userId: userId,
  nickname: currentUser.displayName ?? '',
  isNewUser: false,
);
```

**Step 2: 커밋**

```bash
git add lib/features/auth/presentation/providers/auth_provider.dart
git commit -m "fix : AuthNotifier userId null fallback 제거 — 미인증 처리 #108"
```

---

## Task 3: [C1] GameEventState nullable 필드 리셋 가능하도록 개선

**Files:**
- Modify: `lib/features/game/presentation/providers/game_event_provider.dart`

**Context:** `copyWith`에서 `??` 연산자로 nullable 필드를 처리하면 `null`로 리셋 불가. `clearError` 패턴을 다른 필드에도 확장하거나, `Object? sentinel` 패턴으로 변경.

**Step 1: sentinel 패턴으로 copyWith 변경**

nullable 필드에 "값을 설정했는가" 여부를 구분할 수 있도록 `_sentinel` 상수 도입:

```dart
/// copyWith에서 "이 필드를 명시적으로 null로 설정"과 "이 필드를 생략" 구분용
const _sentinel = Object();

GameEventState copyWith({
  // ... non-nullable 필드들은 그대로 ...
  Object? errorMessage = _sentinel,
  Object? remainingThieves = _sentinel,
  Object? lastArrestNickname = _sentinel,
  Object? lastEscapeNickname = _sentinel,
  Object? winnerTeam = _sentinel,
  Object? gameOverReason = _sentinel,
  Object? gameResultId = _sentinel,
  Object? gameStartTime = _sentinel,
  Object? policeMoveStartTime = _sentinel,
  Object? lastLocationRevealTime = _sentinel,
}) {
  return GameEventState(
    // ... non-nullable 필드들 ...
    errorMessage: errorMessage == _sentinel
        ? this.errorMessage
        : errorMessage as String?,
    lastArrestNickname: lastArrestNickname == _sentinel
        ? this.lastArrestNickname
        : lastArrestNickname as String?,
    // ... 나머지 nullable 필드 동일 패턴 ...
  );
}
```

**Step 2: 기존 `clearError` 파라미터 제거**

sentinel 패턴이면 `copyWith(errorMessage: null)` 로 직접 클리어 가능하므로 `clearError` 불필요. 기존 `clearError: true` 호출부를 `errorMessage: null`로 변경.

호출부 검색: `clearError: true` → `errorMessage: null`

**Step 3: ChatState, LobbyState에도 동일 패턴 적용**

`chat_provider.dart`의 `ChatState.copyWith`와 `lobby_provider.dart`의 `LobbyState.copyWith`도 sentinel 패턴으로 변경. 이 두 클래스는 nullable 필드가 적어 (`errorMessage`, `lastEvent`) 변경 범위 작음.

**Step 4: 커밋**

```bash
git add lib/features/game/presentation/providers/game_event_provider.dart \
        lib/features/chat/presentation/providers/chat_provider.dart \
        lib/features/lobby/presentation/providers/lobby_provider.dart
git commit -m "fix : State.copyWith sentinel 패턴 적용 — nullable 필드 null 리셋 가능 #108"
```

---

## Task 4: [M3] arrestRobber 낙관적 업데이트 race condition 방어

**Files:**
- Modify: `lib/features/game/presentation/providers/game_event_provider.dart`

**Context:** API 호출 중 STOMP ARREST 이벤트가 먼저 도착하면 `_handleArrest`가 `isApiLoading: false`로 설정. 이후 catch 블록 rollback이 서버 확정 체포를 되돌린다.

**Step 1: API 호출 중인 robberParticipantId 추적**

```dart
/// 현재 API 호출 중인 체포 대상 ID (race condition 방어)
int? _pendingArrestId;
```

**Step 2: arrestRobber에서 추적 설정**

```dart
Future<void> arrestRobber(int gameId, int robberParticipantId) async {
  _pendingArrestId = robberParticipantId;
  // ... 기존 낙관적 업데이트 ...
  try {
    // ... API 호출 ...
    _pendingArrestId = null;
  } catch (e) {
    // STOMP에서 이미 확정된 경우 rollback 스킵
    if (_pendingArrestId == null) {
      debugPrint('[GameEventNotifier] STOMP 확정 후 API 실패 — rollback 스킵');
      state = state.copyWith(isApiLoading: false);
    } else {
      // 기존 rollback 로직
      _pendingArrestId = null;
    }
  }
}
```

**Step 3: _handleArrest에서 pending 클리어**

```dart
void _handleArrest(Map<String, dynamic> data) {
  // ... 기존 파싱 ...
  if (robberPid != null && robberPid == _pendingArrestId) {
    _pendingArrestId = null;  // STOMP 확정 → API catch에서 rollback 방지
  }
  // ... 기존 state 업데이트 ...
}
```

**Step 4: 커밋**

```bash
git add lib/features/game/presentation/providers/game_event_provider.dart
git commit -m "fix : arrestRobber STOMP/API race condition 방어 — _pendingArrestId 추적 #108"
```

---

## Task 5: [M7] gameSystemApiProvider를 Presentation 레이어로 이동

**Files:**
- Modify: `lib/features/game/data/datasources/game_system_api_datasource.dart`
- Modify: `lib/features/game/presentation/providers/game_event_provider.dart`

**Context:** `gameSystemApiProvider`가 Data 레이어 datasource 파일에 `@riverpod`로 정의되어 있음. Provider는 Presentation 레이어에 위치해야 함.

**Step 1: game_system_api_datasource.dart에서 Provider 제거**

```dart
// 삭제:
// @riverpod
// GameSystemApi gameSystemApi(Ref ref) { ... }
```

`riverpod_annotation` import와 `flutter_riverpod` import도 더 이상 필요 없으면 제거.
`dio_client.dart` import도 제거 (dioProvider는 이제 provider 파일에서만 참조).

**Step 2: game_event_provider.dart에 Provider 추가**

```dart
/// GameSystemApi Provider
@riverpod
GameSystemApi gameSystemApi(Ref ref) {
  final dio = ref.watch(dioProvider);
  return GameSystemApi(dio);
}
```

import 추가: `import '../../../../core/network/dio_client.dart';` (이미 있으면 생략)
import 추가: `import '../../data/datasources/game_system_api_datasource.dart';` (이미 있으면 생략)

**Step 3: 다른 파일에서 `gameSystemApiProvider` import 확인 및 수정**

`gameSystemApiProvider`를 사용하는 파일 확인 (`game_area_provider.dart` 등). import 경로가 바뀌면 수정.

**Step 4: build_runner 실행**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Step 5: 커밋**

```bash
git add lib/features/game/data/datasources/game_system_api_datasource.dart \
        lib/features/game/data/datasources/game_system_api_datasource.g.dart \
        lib/features/game/presentation/providers/game_event_provider.dart \
        lib/features/game/presentation/providers/game_event_provider.g.dart \
        lib/features/game/presentation/providers/game_area_provider.dart \
        lib/features/game/presentation/providers/game_area_provider.g.dart
git commit -m "refactor : gameSystemApiProvider를 presentation 레이어로 이동 #108"
```

---

## Task 6: [m1/m2/m4] 에러 fallback UI 개선 — 공통 위젯 + 디자인 시스템

**Files:**
- Create: `lib/features/game/presentation/widgets/map_error_widget.dart`
- Modify: `lib/features/game/presentation/widgets/google_map_view.dart`
- Modify: `lib/features/game/presentation/widgets/naver_map_view.dart`

**Step 1: 공통 MapErrorWidget 생성**

```dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';

/// 지도 로드 실패 시 표시하는 공통 에러 위젯
class MapErrorWidget extends StatelessWidget {
  const MapErrorWidget({
    super.key,
    required this.mapName,
    required this.error,
  });

  final String mapName;
  final Object error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.red),
          const SizedBox(height: AppSpacing.vertical16),
          Text('$mapName 로드 실패'),
          const SizedBox(height: AppSpacing.vertical8),
          Text('Error: $error', style: AppTextStyles.tag_12),
        ],
      ),
    );
  }
}
```

**Step 2: google_map_view.dart 에러 UI 교체**

기존 에러 fallback `Column` 코드를 `MapErrorWidget(mapName: 'Google Map', error: e)`로 교체.

**Step 3: naver_map_view.dart 에러 UI 교체**

기존 에러 fallback `Column` 코드를 `MapErrorWidget(mapName: 'Naver Map', error: e)`로 교체.

**Step 4: 커밋**

```bash
git add lib/features/game/presentation/widgets/map_error_widget.dart \
        lib/features/game/presentation/widgets/google_map_view.dart \
        lib/features/game/presentation/widgets/naver_map_view.dart
git commit -m "refactor : 지도 에러 fallback UI 공통 위젯 추출 + 디자인 시스템 적용 #108"
```

---

## Task 7: [m5] hot-path debugPrint에 kDebugMode 가드 추가

**Files:**
- Modify: `lib/features/game/data/datasources/game_event_stomp_datasource.dart`
- Modify: 기타 hot-path 파일 (위치 전송 등 3-5초 주기 호출)

**Context:** `publishLocation` 등 고빈도 호출 경로의 `debugPrint`가 `kDebugMode` 가드 없이 문자열 보간을 수행. 릴리즈 빌드에서 불필요한 문자열 할당 발생.

**Step 1: game_event_stomp_datasource.dart의 publishLocation 내 debugPrint 가드**

```dart
if (kDebugMode) {
  debugPrint('[$logTag] 📤 위치 전송: ($latitude, $longitude)');
}
```

**Step 2: 다른 고빈도 경로 확인 및 동일 가드 적용**

STOMP 메시지 수신 콜백 등 이벤트 기반 로그도 가드 적용.

**Step 3: 커밋**

```bash
git add lib/features/game/data/datasources/game_event_stomp_datasource.dart
git commit -m "chore : hot-path debugPrint에 kDebugMode 가드 추가 #108"
```

---

## Task 8: [m7/m8] ArrestResponseModel required 전환 + SecureTokenStorage 미사용 메서드 제거

**Files:**
- Modify: `lib/features/game/data/models/arrest_response_model.dart`
- Modify: `lib/core/storage/secure_token_storage.dart`

**Step 1: ArrestResponseModel 필드를 required로 변경**

```dart
@freezed
class ArrestResponseModel with _$ArrestResponseModel {
  const factory ArrestResponseModel({
    required String robberNickname,
    required int remainingThieves,
  }) = _ArrestResponseModel;

  factory ArrestResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ArrestResponseModelFromJson(json);
}
```

**Step 2: SecureTokenStorage 미사용 메서드 제거**

`saveAccessToken()`과 `saveRefreshToken()` 개별 메서드 제거. `saveTokens()`만 유지.

**Step 3: build_runner 실행**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Step 4: 커밋**

```bash
git add lib/features/game/data/models/arrest_response_model.dart \
        lib/features/game/data/models/arrest_response_model.freezed.dart \
        lib/features/game/data/models/arrest_response_model.g.dart \
        lib/core/storage/secure_token_storage.dart \
        lib/core/storage/secure_token_storage.g.dart
git commit -m "chore : ArrestResponseModel required 전환 + SecureTokenStorage dead code 제거 #108"
```

---

## Task 9: 포맷팅 및 최종 확인

**Step 1: dart format**

```bash
dart format lib/
```

**Step 2: flutter analyze**

```bash
flutter analyze
```

**Step 3: flutter test**

```bash
flutter test
```

**Step 4: 커밋 (포맷팅 변경 있을 경우)**

```bash
git add -A
git commit -m "style : 포맷팅 수정 #108"
```

---

## 실행 순서 요약

| Task | 이슈 | 내용 | 의존성 |
|------|------|------|--------|
| 1 | C2 | 캐스팅 방어 코드 | 없음 |
| 2 | M2 | userId fallback 제거 | 없음 |
| 3 | C1 | copyWith sentinel 패턴 | 없음 |
| 4 | M3 | arrest race condition | Task 3 이후 (copyWith 변경 반영) |
| 5 | M7 | gameSystemApiProvider 이동 | 없음 |
| 6 | m1/m2/m4 | 에러 UI 공통 위젯 | 없음 |
| 7 | m5 | debugPrint 가드 | 없음 |
| 8 | m7/m8 | required 전환 + dead code | 없음 |
| 9 | - | 포맷팅 + 검증 | 전체 완료 후 |

---

## 별도 이슈로 분리할 항목

다음 항목들은 이번 계획 범위 밖이며, 별도 GitHub 이슈로 생성 권장:

1. **STOMP 재연결 로직 mixin 추출** (M1) — 3개 Notifier ~393줄 중복 제거
2. **SessionRepository 인터페이스 확장** (M4) — 8개 메서드 추가
3. **Game/Chat Repository 계층 도입** (M5) — Domain Entity + Repository 신규 생성
4. **GameEventNotifier 책임 분리** (M6) — API + STOMP + 타이머 분리
