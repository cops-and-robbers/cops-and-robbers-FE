# 닉네임 변경 플로우 수정 및 /api/user/me 연동

**Goal:** 설정에서 닉네임 변경 시 nickname_setup_page로 이동 후 정상 동작하도록 수정하고, `/api/user/me` API를 연동하여 정확한 사용자 정보를 사용

**Architecture:** nickname_setup_page에서 `context.canPop()` 기반 분기로 첫 로그인 vs 설정 플로우를 자동 구분. User feature에 `/api/user/me` 데이터 소스/리포지토리/엔티티 추가.

**Tech Stack:** Flutter, Riverpod, Freezed, Retrofit, GoRouter

---

## 배경 및 근본 원인 분석

### 현재 문제

설정 > 닉네임 변경 클릭 시 `/nickname-setup` 으로 이동하지 않고 바로 홈으로 간다.

### 근본 원인

`nickname_setup_page.dart`의 `_onConfirm()` 메서드가 항상 `context.go(RoutePaths.home)` 을 호출한다. 이는 첫 로그인 플로우용으로 설계된 것이며, 설정에서 진입한 경우에는 `context.pop()` 으로 돌아가야 한다.

또한, 라우터 리다이렉트에서 가드가 제거되었더라도 **앱을 핫 리스타트하지 않으면 라우터 변경이 반영되지 않을 수 있다** (GoRouter는 앱 초기화 시 생성).

### 해결 전략

`context.canPop()` 을 활용하여 자동 분기:

- 설정에서 `context.push()` → 스택에 이전 페이지 존재 → `canPop() == true` → `context.pop()`
- 첫 로그인 리다이렉트 → 스택 없음 → `canPop() == false` → `context.go(home)`

이 방식은 `from` 쿼리 파라미터 없이도 깔끔하게 동작한다.

---

### Task 1: `/api/user/me` 응답 Model 추가

**Files:**

- Create: `lib/features/user/data/models/my_page_response_model.dart`

**Step 1: MyPageResponseModel 생성**

API 응답 스키마 (`GET /api/user/me`):

```json
{
  "userId": 1,
  "nickname": "도둑잡는경찰",
  "socialPlatform": "GOOGLE",
  "allowGamePush": true,
  "allowMarketingPush": false
}
```

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'my_page_response_model.freezed.dart';
part 'my_page_response_model.g.dart';

/// 내 정보 조회 응답 DTO
///
/// `GET /api/user/me` 응답 (200)
@freezed
class MyPageResponseModel with _$MyPageResponseModel {
  const factory MyPageResponseModel({
    required int userId,
    required String nickname,
    required String socialPlatform,
    required bool allowGamePush,
    required bool allowMarketingPush,
  }) = _MyPageResponseModel;

  factory MyPageResponseModel.fromJson(Map<String, dynamic> json) =>
      _$MyPageResponseModelFromJson(json);
}
```

**Step 2: build_runner 실행**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`

**Step 3: Commit**

```bash
git add lib/features/user/data/models/my_page_response_model.dart
git add lib/features/user/data/models/my_page_response_model.freezed.dart
git add lib/features/user/data/models/my_page_response_model.g.dart
git commit -m "feat: add MyPageResponseModel for /api/user/me endpoint"
```

---

### Task 2: User Domain Entity 추가

**Files:**

- Create: `lib/features/user/domain/entities/user_profile_entity.dart`

**Step 1: UserProfileEntity 생성**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile_entity.freezed.dart';

/// 사용자 프로필 엔티티
///
/// `/api/user/me` 에서 가져온 사용자 정보를 나타냅니다.
@freezed
class UserProfileEntity with _$UserProfileEntity {
  const factory UserProfileEntity({
    required int userId,
    required String nickname,
    required String socialPlatform,
    required bool allowGamePush,
    required bool allowMarketingPush,
  }) = _UserProfileEntity;
}
```

**Step 2: build_runner 실행**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`

**Step 3: Commit**

```bash
git add lib/features/user/domain/entities/user_profile_entity.dart
git add lib/features/user/domain/entities/user_profile_entity.freezed.dart
git commit -m "feat: add UserProfileEntity for user profile data"
```

---

### Task 3: UserRemoteDataSource에 getMyPage 추가

**Files:**

- Modify: `lib/features/user/data/datasources/user_remote_datasource.dart`

**Step 1: getMyPage 메서드 추가**

기존 코드에 추가:

```dart
// import 추가
import '../models/my_page_response_model.dart';

// 클래스 내부에 메서드 추가:
/// 내 정보 조회
///
/// 현재 로그인한 사용자의 프로필 정보를 조회합니다.
///
/// - 200: 사용자 정보 (MyPageResponseModel)
@GET(ApiEndpoints.myPage)
Future<MyPageResponseModel> getMyPage();
```

**Step 2: build_runner 실행**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`

**Step 3: Commit**

```bash
git add lib/features/user/data/datasources/user_remote_datasource.dart
git add lib/features/user/data/datasources/user_remote_datasource.g.dart
git commit -m "feat: add getMyPage to UserRemoteDataSource"
```

---

### Task 4: UserRepository에 getMyProfile 추가

**Files:**

- Modify: `lib/features/user/domain/repositories/user_repository.dart`
- Modify: `lib/features/user/data/repositories/user_repository_impl.dart`

**Step 1: 인터페이스에 메서드 추가**

`user_repository.dart`:

```dart
// import 추가
import '../entities/user_profile_entity.dart';

// 메서드 추가:
/// 내 프로필 조회
///
/// 현재 로그인한 사용자의 프로필 정보를 반환합니다.
Future<UserProfileEntity> getMyProfile();
```

**Step 2: 구현체에 메서드 추가**

`user_repository_impl.dart`:

```dart
// import 추가
import '../../domain/entities/user_profile_entity.dart';

// 메서드 구현:
@override
Future<UserProfileEntity> getMyProfile() async {
  try {
    final response = await _dataSource.getMyPage();

    if (kDebugMode) {
      debugPrint('✅ 내 정보 조회 성공: ${response.nickname}');
    }

    return UserProfileEntity(
      userId: response.userId,
      nickname: response.nickname,
      socialPlatform: response.socialPlatform,
      allowGamePush: response.allowGamePush,
      allowMarketingPush: response.allowMarketingPush,
    );
  } on DioException catch (e) {
    throw DioExceptionHandler.handle(e);
  } catch (e) {
    throw ServerException(
      message: '사용자 정보 조회 중 오류가 발생했습니다.',
      originalException: e,
    );
  }
}
```

**Step 3: Commit**

```bash
git add lib/features/user/domain/repositories/user_repository.dart
git add lib/features/user/data/repositories/user_repository_impl.dart
git commit -m "feat: add getMyProfile to UserRepository"
```

---

### Task 5: nickname_setup_page 완료 동작 수정

**Files:**

- Modify: `lib/features/auth/presentation/pages/nickname_setup_page.dart`

**Step 1: \_onConfirm에서 canPop 기반 분기 적용**

`_onConfirm()` 메서드의 `context.go(RoutePaths.home)` 을 `_navigateAfterComplete()` 헬퍼로 교체:

```dart
/// 닉네임 설정/변경 완료 후 네비게이션
///
/// - 설정에서 진입 (push): canPop == true → pop으로 설정 페이지로 복귀
/// - 첫 로그인 (redirect): canPop == false → go로 홈 이동
void _navigateAfterComplete() {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(RoutePaths.home);
  }
}
```

`_onConfirm()` 내부 두 곳의 `context.go(RoutePaths.home)` → `_navigateAfterComplete()` 교체:

- 라인 150: 닉네임 미변경 시
- 라인 167: 닉네임 변경 성공 시

**Step 2: flutter analyze 확인**

Run: `flutter analyze`
Expected: No new errors

**Step 3: Commit**

```bash
git add lib/features/auth/presentation/pages/nickname_setup_page.dart
git commit -m "feat: nickname_setup_page navigates back to settings when pushed, home when redirected"
```

---

### Task 6: 설정 페이지에서 닉네임을 /api/user/me 기반으로 전달 (선택사항)

**Files:**

- Modify: `lib/features/settings/presentation/pages/settings_page.dart`

**현재**: `authState.value?.nickname` (Firebase displayName 기반, 부정확할 수 있음)
**변경**: 그대로 유지 — 현재는 authState의 nickname을 사용. 추후 settings 페이지에서 `/api/user/me`를 직접 호출하여 정확한 닉네임을 표시하는 것은 별도 이슈로 처리.

> Note: 지금은 authState.value?.nickname으로 충분. settings 페이지에서 userProfile provider를 watch하는 것은 settings 페이지 전체 리팩토링 시 함께 작업.

---

### Task 7: 핫 리스타트 후 동작 확인

**확인 항목:**

1. 앱 핫 리스타트 (R, 대문자)
2. 설정 > 닉네임 변경 클릭 → nickname_setup_page 정상 진입 확인
3. 닉네임 미변경 → 확인 클릭 → 설정 페이지로 복귀 (pop)
4. 닉네임 변경 + 중복확인 → 확인 클릭 → 설정 페이지로 복귀 (pop)
5. 신규 회원 로그인 → 닉네임 설정 → 확인 클릭 → 홈 이동 (go)

---

## 파일 변경 요약

| 파일                                                | 작업   | 설명                    |
| --------------------------------------------------- | ------ | ----------------------- |
| `user/data/models/my_page_response_model.dart`      | Create | API 응답 DTO            |
| `user/domain/entities/user_profile_entity.dart`     | Create | 프로필 엔티티           |
| `user/data/datasources/user_remote_datasource.dart` | Modify | getMyPage 추가          |
| `user/domain/repositories/user_repository.dart`     | Modify | getMyProfile 인터페이스 |
| `user/data/repositories/user_repository_impl.dart`  | Modify | getMyProfile 구현       |
| `auth/presentation/pages/nickname_setup_page.dart`  | Modify | canPop 기반 네비게이션  |
