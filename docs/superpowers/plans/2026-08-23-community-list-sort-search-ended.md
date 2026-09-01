# 커뮤니티 목록 정렬·검색 및 종료 상태 연동 구현 계획 (#478)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 백엔드 v2.21.0이 연 목록 정렬·키워드 검색을 앱에 연결하고, 새로 생긴 `ENDED` 상태 때문에 목록·상세 파싱이 깨지는 것을 막는다.

**Architecture:** 목록 Notifier의 family 키를 `(scope, sort, keyword)` 셋으로 늘려 조건이 바뀌면 새 인스턴스가 커서 없이 첫 페이지를 부르게 한다 — 서버 커서에 국가·정렬·검색어가 봉인돼 있어 조건 변경 시 커서 재사용이 불가능하기 때문이다. `keyword == null`(목록)일 때만 `ref.keepAlive()`를 걸어 정렬·스코프 왕복에서 `/country`와 GPS를 다시 태우지 않고, 자유 텍스트인 검색은 화면을 나가면 폐기되게 둔다. 목록 화면과 검색 화면은 `CommunityFeedList` 위젯 하나를 공유한다.

**Tech Stack:** Flutter 3.9.2+ / Riverpod(riverpod_generator) / Freezed / Retrofit + Dio / SharedPreferences / go_router / flutter_screenutil

**Spec:** `docs/superpowers/specs/2026-08-23-community-list-sort-search-ended-design.md`

## Global Constraints

- UI 문자열은 한국어 하드코딩 금지 — `lib/l10n/app_{ko,en,ja}.arb`에 추가 후 `AppLocalizations.of(context).키`로 사용한다. `debugPrint`·주석·assert 메시지는 한국어 허용.
- `lib/l10n/app_localizations*.dart`는 자동 생성물이라 직접 편집 금지. ARB 수정 후 `flutter gen-l10n`.
- ARB 문구 추가·수정 후 `python3 docs/i18n/_lint_tone.py`로 톤(해요체·경어·마침표) 검사.
- 색·타이포는 `AppColors`·`AppTextStyles`를 직접 참조한다. `Theme.of(context)` 사용 금지.
- 에러 처리는 try-catch + Custom Exception. Either 패턴 금지.
- `@riverpod`·`@freezed`·`@RestApi` 어노테이션을 건드린 뒤에는 `dart run build_runner build --delete-conflicting-outputs`.
- 테스트는 `.claude/rules/Agents.md`를 따른다 — 시스템 경계(Dio·SharedPreferences·GPS·시계)만 가짜로 두고 내부 협력자는 실물. 호출 검증(`verify` 류)을 주 단언으로 쓰지 않는다. 테스트 이름은 `<subject>_<expected>_when_<condition>`.
- 커밋 메시지는 `<type> : <설명> #478` 형식. 원격 반영은 하지 않는다(CLAUDE.md 금지 규칙). Co-Authored-By 금지.
- 서버 계약(변경 금지 전제): 목록 허용 쿼리 파라미터는 `cursor`·`size`·`scope`·`countryCode`·`sort`·`keyword`·`latitude`·`longitude` 8개뿐이고 그 밖의 이름은 400. `sort=DISTANCE`일 때만 좌표 필수이며 다른 정렬에서 좌표를 보내면 400. `keyword`는 공백 제외 2자 이상. `POPULAR`·`NEARBY`·`MINE`은 400.

---

## File Structure

**신규**

| 파일 | 책임 |
|---|---|
| `lib/features/community/presentation/widgets/community_feed_list.dart` | 정렬 라벨 + 무한 스크롤 목록 + 당겨서 새로고침 + 카드 동작. 목록 화면과 검색 화면이 공유한다. |
| `lib/features/community/data/datasources/community_recent_keyword_storage.dart` | 최근 검색어 로컬 영속화 (SharedPreferences). |
| `lib/features/community/presentation/pages/community_search_page.dart` | 검색 입력 · 최근 검색어 · 검색 결과 화면. |
| `test/features/community/data/datasources/community_recent_keyword_storage_test.dart` | 위 저장소 단위 테스트. |
| `test/features/community/presentation/pages/community_search_page_test.dart` | 검색 화면 위젯 테스트. |

**수정** — 스펙 10절 참조. 계층별로 도메인(2) → 데이터(4) → 프레젠테이션(6) → 라우터(2) → ARB(3) 순.

---

## Task 1: `ENDED` 상태값 파싱과 폴백

**Files:**
- Modify: `lib/features/community/domain/entities/community_post_status.dart`
- Modify: `lib/features/community/data/models/community_wire.dart:5-25`
- Test: `test/features/community/data/models/community_wire_test.dart:7-27`
- Test: `test/features/community/data/repositories/community_repository_impl_test.dart:353-363`

**Interfaces:**
- Produces: `CommunityPostStatus.ended` (enum 값), `communityPostStatusFromWire(String) -> CommunityPostStatus` (알 수 없는 값은 `completed`로 폴백, 더 이상 던지지 않음), `CommunityPostStatusWire.wireValue` (세 값 모두 매핑)

- [ ] **Step 1: 실패하는 테스트로 교체**

`test/features/community/data/models/community_wire_test.dart`의 `maps_server_enum_names_exactly`에 한 줄을 더하고, `throws_format_exception_when_wire_status_is_unknown` 테스트를 통째로 아래 둘로 바꾼다.

```dart
    test('maps_server_enum_names_exactly', () {
      // 서버 계약 고정 — 값이 바뀌면 여기서 먼저 깨져야 한다.
      expect(CommunityPostStatus.recruiting.wireValue, 'RECRUITING');
      expect(CommunityPostStatus.completed.wireValue, 'COMPLETED');
      expect(CommunityPostStatus.ended.wireValue, 'ENDED');
    });

    test('maps_ended_to_ended_status_when_meeting_date_has_passed', () {
      // 서버가 저장하지 않고 조회 시점에 판정해 내려주는 값이다.
      expect(communityPostStatusFromWire('ENDED'), CommunityPostStatus.ended);
    });

    test('falls_back_to_completed_when_wire_status_is_unknown', () {
      // 모르는 상태를 모집중으로 보여 끝난 모임에 참여를 시도하게 두지 않는다.
      // 던지면 목록 한 장이 통째로 에러 화면이 된다 (ENDED 추가 때 실제로 그랬다).
      expect(
        communityPostStatusFromWire('CANCELLED'),
        CommunityPostStatus.completed,
      );
    });
```

- [ ] **Step 2: 실패 확인**

Run: `flutter test test/features/community/data/models/community_wire_test.dart`
Expected: FAIL — `ended` getter 없음(컴파일 에러), 그리고 `CANCELLED`에서 FormatException.

- [ ] **Step 3: enum에 `ended` 추가**

`lib/features/community/domain/entities/community_post_status.dart` 전체를 아래로 바꾼다.

```dart
/// 모집 게시글의 모집 상태 — 서버 와이어 포맷 비의존 (순수 도메인 타입)
///
/// [completed]는 작성자가 직접 마감한 것이고, [ended]는 모임 날짜가 지나
/// 서버가 조회 시점에 판정한 것이다. 서버는 [ended]를 저장하지 않으며, 날짜가
/// 작성자 마감보다 우선한다 — 마감된 글이라도 날짜가 지나면 [ended]로 온다.
///
/// 와이어 문자열 매핑은 data 계층(`community_wire.dart`)에 있다.
enum CommunityPostStatus { recruiting, completed, ended }
```

- [ ] **Step 4: 와이어 매핑 구현**

`lib/features/community/data/models/community_wire.dart`의 `CommunityPostStatusWire` 확장과 `communityPostStatusFromWire`를 아래로 바꾼다. (파일 상단의 `@JsonValue`를 쓰지 않는 이유 주석은 그대로 둔다.)

```dart
extension CommunityPostStatusWire on CommunityPostStatus {
  /// [CommunityPostStatus.ended]까지 매핑해 switch를 total로 둔다. 요청 스키마
  /// (`CommunityPostStatusRequest`)에도 `ENDED`가 있어 유효한 값이지만, 종료된
  /// 글은 화면이 상태 변경 자체를 막으므로 실제로 전송되지는 않는다.
  String get wireValue => switch (this) {
    CommunityPostStatus.recruiting => 'RECRUITING',
    CommunityPostStatus.completed => 'COMPLETED',
    CommunityPostStatus.ended => 'ENDED',
  };
}

/// 와이어 문자열 → 도메인 enum.
///
/// 모르는 값은 '마감'으로 본다. 모집중으로 보여 끝난 모임에 참여를 시도하게
/// 두느니 보수적으로 막는 쪽이 안전하고, 예외를 던지면 그 글 하나 때문에 목록
/// 한 장이 통째로 에러 화면이 된다 — `ENDED`가 추가됐을 때 실제로 그랬다.
CommunityPostStatus communityPostStatusFromWire(String wire) => switch (wire) {
  'RECRUITING' => CommunityPostStatus.recruiting,
  'COMPLETED' => CommunityPostStatus.completed,
  'ENDED' => CommunityPostStatus.ended,
  _ => CommunityPostStatus.completed,
};
```

- [ ] **Step 5: Repository 테스트도 새 계약으로 교체**

`test/features/community/data/repositories/community_repository_impl_test.dart`의 `wraps_unknown_wire_status_into_server_exception` 테스트를 아래로 바꾼다.

```dart
    test('falls_back_to_completed_when_wire_status_is_unknown', () async {
      // 알 수 없는 상태 하나가 목록 한 장을 통째로 날리지 않아야 한다.
      final fake = _FakeCommunityRemoteDataSource()
        ..responseToReturn = _listOf([_postJson(status: 'CANCELLED')]);
      final repo = CommunityRepositoryImpl(fake);

      final result = await repo.getPosts(size: 20, countryCode: 'KR');

      expect(result.items.single.status, CommunityPostStatus.completed);
    });

    test('maps_ended_status_when_server_marks_meeting_as_past', () async {
      final fake = _FakeCommunityRemoteDataSource()
        ..responseToReturn = _listOf([_postJson(status: 'ENDED')]);
      final repo = CommunityRepositoryImpl(fake);

      final result = await repo.getPosts(size: 20, countryCode: 'KR');

      expect(result.items.single.status, CommunityPostStatus.ended);
    });
```

- [ ] **Step 6: 통과 확인**

Run: `flutter test test/features/community/data/`
Expected: PASS (기존 `round_trips_every_status_through_wire_string`도 `ended`를 포함해 통과한다)

- [ ] **Step 7: 커밋**

```bash
git add lib/features/community/domain/entities/community_post_status.dart \
        lib/features/community/data/models/community_wire.dart \
        test/features/community/data/models/community_wire_test.dart \
        test/features/community/data/repositories/community_repository_impl_test.dart
git commit -m "fix : 모임 종료 상태 파싱 추가 및 알 수 없는 상태 폴백 #478"
```

---

## Task 2: 종료 상태 화면 표기

**Files:**
- Modify: `lib/l10n/app_ko.arb:407-409` · `lib/l10n/app_en.arb:189` · `lib/l10n/app_ja.arb:189`
- Modify: `lib/features/community/presentation/widgets/community_post_card.dart:48,67,244-266`
- Modify: `lib/features/community/presentation/pages/community_detail_page.dart:249,269-271`
- Modify: `lib/features/community/presentation/widgets/community_post_menu.dart:104-118`
- Modify: `lib/features/community/presentation/providers/community_provider.dart:272-274`
- Modify: `lib/features/community/presentation/providers/community_detail_provider.dart:171-173`
- Test: `test/features/community/presentation/widgets/community_post_card_test.dart`

**Interfaces:**
- Consumes: `CommunityPostStatus.ended` (Task 1)
- Produces: `l10n.communityStatusEnded` — 종료 배지 문구

- [ ] **Step 1: ARB에 종료 문구 추가**

`lib/l10n/app_ko.arb`의 `communityStatusCompleted` 블록 바로 뒤에 넣는다.

```json
  "communityStatusEnded": "종료",
  "@communityStatusEnded": {
    "description": "커뮤니티 카드 — 모임 날짜가 지나 끝난 게시글 배지"
  },
```

`lib/l10n/app_en.arb`의 `"communityStatusCompleted": "Closed",` 뒤:

```json
  "communityStatusEnded": "Ended",
```

`lib/l10n/app_ja.arb`의 `"communityStatusCompleted": "締切",` 뒤:

```json
  "communityStatusEnded": "終了",
```

- [ ] **Step 2: 코드 생성과 톤 검사**

```bash
flutter gen-l10n && python3 docs/i18n/_lint_tone.py
```
Expected: 생성 성공, 톤 위반 0건.

- [ ] **Step 3: 실패하는 위젯 테스트 작성**

`test/features/community/presentation/widgets/community_post_card_test.dart` 안의 기존 group 끝에 추가한다. `_post(...)`와 카드 펌프 헬퍼는 파일 상단에 이미 있는 이름을 그대로 쓴다(없으면 기존 테스트가 쓰는 구성 코드를 `_pumpCard`라는 이름의 헬퍼로 뽑는다).

```dart
    testWidgets('shows_ended_label_when_meeting_date_has_passed', (
      tester,
    ) async {
      await _pumpCard(
        tester,
        _post(1).copyWith(status: CommunityPostStatus.ended),
      );

      expect(find.text('종료'), findsOneWidget);
      expect(find.text('마감'), findsNothing);
    });

    testWidgets('dims_card_content_when_status_is_ended', (tester) async {
      await _pumpCard(
        tester,
        _post(1).copyWith(status: CommunityPostStatus.ended),
      );

      final opacity = tester.widget<Opacity>(
        find.byKey(CommunityPostCard.contentOpacityKey),
      );
      expect(opacity.opacity, 0.6);
    });
```

- [ ] **Step 4: 실패 확인**

Run: `flutter test test/features/community/presentation/widgets/community_post_card_test.dart`
Expected: FAIL — "종료"가 아니라 "마감"이 나오고, opacity가 1.0이다.

- [ ] **Step 5: 카드 배지와 흐림 구현**

`community_post_card.dart:48`을 바꾼다.

```dart
    // 마감·종료 둘 다 흐린다 — 참여할 수 없다는 점에서 같다.
    final isClosed = post.status != CommunityPostStatus.recruiting;
```

같은 파일 67행 `opacity: isCompleted ? 0.6 : 1.0,`을 `opacity: isClosed ? 0.6 : 1.0,`로 바꾼다.

`_StatusChip`의 `build`를 아래로 바꾼다.

```dart
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isRecruiting = status == CommunityPostStatus.recruiting;

    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.horizontal8,
        vertical: AppSpacing.vertical4,
      ),
      decoration: BoxDecoration(
        // 마감을 로고색으로 두면 끝난 모임이 모집중처럼 눈에 띈다.
        color: isRecruiting ? AppColors.logo : AppColors.black300,
        borderRadius: AppRadius.xlarge,
      ),
      child: Text(
        // 같은 매핑이 상세 화면(_buildHeader)에도 있다. 사용처가 둘뿐이라
        // 공통 위젯으로 뽑지 않았다 — 세 번째가 생기면 그때 추출한다.
        switch (status) {
          CommunityPostStatus.recruiting => l10n.communityStatusRecruiting,
          CommunityPostStatus.completed => l10n.communityStatusCompleted,
          CommunityPostStatus.ended => l10n.communityStatusEnded,
        },
        style: AppTextStyles.tag_10.copyWith(color: AppColors.white),
      ),
    );
  }
```

- [ ] **Step 6: 상세 화면 배지 구현**

`community_detail_page.dart`의 `_buildHeader`에서 배지 Container의 `child: Text(...)` 부분을 아래로 바꾼다.

```dart
              child: Text(
                // 카드의 _StatusChip과 같은 매핑이다 (사용처 2곳 — 세 번째가
                // 생기면 공통 위젯으로 뽑는다).
                switch (state.post.status) {
                  CommunityPostStatus.recruiting =>
                    l10n.communityStatusRecruiting,
                  CommunityPostStatus.completed =>
                    l10n.communityStatusCompleted,
                  CommunityPostStatus.ended => l10n.communityStatusEnded,
                },
                style: AppTextStyles.tag_10.copyWith(color: AppColors.white),
              ),
```

- [ ] **Step 7: 종료된 글은 상태 변경 항목을 감춘다**

`community_post_menu.dart`의 작성자 분기(`return [ ... ]`)에서 상태 변경 `CommunityMenuItem`을 조건부로 만든다.

```dart
    return [
      CommunityMenuItem(
        iconPath: 'assets/icons/icon_write.svg',
        label: l10n.communityMenuEdit,
        onTap: () => onAction(CommunityPostMenuAction.edit),
      ),
      // 종료된 글은 상태를 바꿔도 서버가 조회 시 다시 ENDED로 판정한다 —
      // 눌러도 아무 변화가 없어 사용자 눈에는 버그로 보인다.
      if (post.status != CommunityPostStatus.ended)
        CommunityMenuItem(
          iconPath: 'assets/icons/icon_check.svg',
          // 체크는 단색(#333D48) 선 아이콘이다. 쓰기 아이콘의 파랑(#339DFF)에
          // 맞춰 칠해 두 항목이 같은 계열로 읽히게 한다.
          iconColor: AppColors.blueVer2Basic,
          // 라벨은 "지금 누르면 무엇이 되는지"를 쓴다 — 현재 상태를 쓰면
          // 모집중인 글에서 "모집중"이 보여 눌러도 될지 알 수 없다.
          label: post.status == CommunityPostStatus.recruiting
              ? l10n.communityMenuMarkCompleted
              : l10n.communityMenuMarkRecruiting,
          onTap: () => onAction(CommunityPostMenuAction.toggleStatus),
        ),
      CommunityMenuItem(
        iconPath: 'assets/icons/icon_trash.svg',
        label: l10n.communityMenuDelete,
        onTap: () => onAction(CommunityPostMenuAction.delete),
        isDestructive: true,
      ),
    ];
```

- [ ] **Step 8: Notifier 두 곳에 방어 가드 추가**

`community_provider.dart`의 `CommunityFeedNotifier.toggleStatus` 첫머리에 추가한다.

```dart
  Future<void> toggleStatus(CommunityPostEntity post) async {
    // 메뉴가 이미 감추지만, 종료 글은 서버가 조회 시 다시 ENDED로 판정하므로
    // 여기까지 왔다면 왕복만 낭비하는 요청이다.
    if (post.status == CommunityPostStatus.ended) return;

    final next = post.status == CommunityPostStatus.recruiting
```

`community_detail_provider.dart`의 `toggleStatus`에도 같은 가드를 넣는다.

```dart
  Future<void> toggleStatus() async {
    final current = state.valueOrNull;
    if (current == null) return;
    // 종료 글은 서버가 조회 시 다시 ENDED로 판정한다 — 왕복만 낭비다.
    if (current.post.status == CommunityPostStatus.ended) return;

    final next = current.post.status == CommunityPostStatus.recruiting
```

- [ ] **Step 9: 통과 확인**

Run: `flutter test test/features/community/ && flutter analyze`
Expected: PASS · 이슈 0건.

- [ ] **Step 10: 커밋**

```bash
git add lib/l10n/ lib/features/community/presentation/ test/features/community/
git commit -m "feat : 모임 종료 상태 배지 표기 및 상태 변경 차단 #478"
```

---

## Task 3: 목록 API에 정렬·검색어·좌표 파라미터 연결

**Files:**
- Modify: `lib/features/community/data/models/community_wire.dart` (하단에 확장 추가)
- Modify: `lib/features/community/data/datasources/community_remote_datasource.dart:17-40`
- Modify: `lib/features/community/domain/repositories/community_repository.dart:10-25`
- Modify: `lib/features/community/data/repositories/community_repository_impl.dart:24-45`
- Modify: `test/features/community/community_fakes.dart:18-25`
- Test: `test/features/community/data/models/community_wire_test.dart`
- Test: `test/features/community/data/repositories/community_repository_impl_test.dart:11-35`

**Interfaces:**
- Consumes: `CommunitySortOption` (기존 도메인 enum), `CommunityPostStatus.ended` (Task 1)
- Produces:
  - `CommunitySortOptionWire.wireValue` — `latest→'LATEST'`, `deadline→'DEADLINE'`, `distance→'DISTANCE'`, `popular→'POPULAR'`
  - `CommunityRepository.getPosts({String? cursor, required int size, CommunityScope scope, required String countryCode, CommunitySortOption sort, String? keyword, double? latitude, double? longitude})`
  - `CommunityRemoteDataSource.getPosts({..., String? sort, String? keyword, double? latitude, double? longitude})`

- [ ] **Step 1: 실패하는 테스트 작성 (와이어)**

`test/features/community/data/models/community_wire_test.dart`에 group을 추가하고, 상단에 `import 'package:cops_and_robbers/features/community/domain/entities/community_sort_option.dart';`를 더한다.

```dart
  group('CommunitySortOption 와이어 매핑', () {
    test('maps_server_enum_names_exactly', () {
      expect(CommunitySortOption.latest.wireValue, 'LATEST');
      expect(CommunitySortOption.deadline.wireValue, 'DEADLINE');
      expect(CommunitySortOption.distance.wireValue, 'DISTANCE');
      // 서버가 400을 주는 값이지만 switch를 total로 두기 위해 매핑은 해 둔다.
      expect(CommunitySortOption.popular.wireValue, 'POPULAR');
    });
  });
```

- [ ] **Step 2: 실패하는 테스트 작성 (Repository)**

`test/features/community/data/repositories/community_repository_impl_test.dart`의 `_FakeCommunityRemoteDataSource`에 목록 요청 기록 필드를 더한다. `lastLatitude`/`lastLongitude`는 이미 `getCountry`·`getAddress`가 쓰고 있으므로 이름을 따로 둔다.

```dart
  String? lastSort;
  String? lastKeyword;
  double? lastListLatitude;
  double? lastListLongitude;

  @override
  Future<CommunityPostListResponseModel> getPosts({
    String? cursor,
    required int size,
    String? scope,
    required String countryCode,
    String? sort,
    String? keyword,
    double? latitude,
    double? longitude,
  }) async {
    called = true;
    lastCursor = cursor;
    lastScope = scope;
    lastCountryCode = countryCode;
    lastSort = sort;
    lastKeyword = keyword;
    lastListLatitude = latitude;
    lastListLongitude = longitude;
    if (errorToThrow != null) throw errorToThrow!;
    return responseToReturn!;
  }
```

같은 파일 `CommunityRepositoryImpl.getPosts` group에 테스트 셋을 더하고, 상단에 `community_sort_option.dart` import를 더한다.

```dart
    test('sends_coordinates_only_when_sort_is_distance', () async {
      final fake = _FakeCommunityRemoteDataSource()
        ..responseToReturn = _listOf([]);
      final repo = CommunityRepositoryImpl(fake);

      await repo.getPosts(
        size: 20,
        countryCode: 'KR',
        sort: CommunitySortOption.distance,
        latitude: 37.4979,
        longitude: 127.0276,
      );

      expect(fake.lastSort, 'DISTANCE');
      expect(fake.lastListLatitude, 37.4979);
      expect(fake.lastListLongitude, 127.0276);
    });

    test('omits_coordinates_when_sort_is_not_distance', () async {
      // 거리순이 아닌데 좌표를 실으면 서버가 400을 준다.
      final fake = _FakeCommunityRemoteDataSource()
        ..responseToReturn = _listOf([]);
      final repo = CommunityRepositoryImpl(fake);

      await repo.getPosts(
        size: 20,
        countryCode: 'KR',
        sort: CommunitySortOption.deadline,
        latitude: 37.4979,
        longitude: 127.0276,
      );

      expect(fake.lastSort, 'DEADLINE');
      expect(fake.lastListLatitude, isNull);
      expect(fake.lastListLongitude, isNull);
    });

    test('sends_keyword_when_search_term_is_given', () async {
      final fake = _FakeCommunityRemoteDataSource()
        ..responseToReturn = _listOf([]);
      final repo = CommunityRepositoryImpl(fake);

      await repo.getPosts(size: 20, countryCode: 'KR', keyword: '서울');

      expect(fake.lastKeyword, '서울');
    });
```

- [ ] **Step 3: 실패 확인**

Run: `flutter test test/features/community/data/`
Expected: FAIL — `wireValue` 없음, `getPosts`에 `sort`/`keyword`/`latitude` 인자 없음(컴파일 에러).

- [ ] **Step 4: 와이어 확장 구현**

`lib/features/community/data/models/community_wire.dart` 맨 아래에 추가하고, 상단 import에 `import '../../domain/entities/community_sort_option.dart';`를 더한다.

```dart
/// `GET /api/community-posts`의 `sort` 쿼리 값.
///
/// [CommunitySortOption.popular]까지 매핑해 switch를 total로 둔다 — 서버가
/// `UNSUPPORTED_LIST_SORT`(400)를 주는 값이라 정렬 시트가 노출하지 않으므로
/// 실제로 전송되지는 않는다.
extension CommunitySortOptionWire on CommunitySortOption {
  String get wireValue => switch (this) {
    CommunitySortOption.latest => 'LATEST',
    CommunitySortOption.popular => 'POPULAR',
    CommunitySortOption.distance => 'DISTANCE',
    CommunitySortOption.deadline => 'DEADLINE',
  };
}
```

- [ ] **Step 5: DataSource 쿼리 확장**

`community_remote_datasource.dart`의 `getPosts` 선언과 그 위 DartDoc을 아래로 바꾼다.

```dart
  /// 모집 게시글 목록 조회 (커서 페이지네이션, 국가별 분리)
  ///
  /// 응답: `{ content: CommunityPostResponse[], cursor: CursorInfo }`
  ///
  /// 서버가 허용하는 파라미터는 여덟(`cursor·size·scope·countryCode·sort·
  /// keyword·latitude·longitude`)뿐이고 그 외에는 400(`INVALID_QUERY_PARAMETER`)을
  /// 준다. Retrofit은 여기 선언된 것만 보내며, null인 값은 생성된 `removeWhere`가
  /// 빼므로 "첫 요청 = 커서 없음", "전체 = scope 생략"이 그대로 표현된다.
  ///
  /// [countryCode]는 필수다 — 목록은 DB만 보고 국가로 나뉜다(DEC-0021). 국가는
  /// [getCountry]로 먼저 구한다. 빈 문자열을 보내면 400(`COUNTRY_NOT_SPECIFIED`).
  ///
  /// [sort]는 `LATEST`·`DEADLINE`·`DISTANCE`만 동작하고 `POPULAR`는 400이다.
  /// [latitude]·[longitude]는 `sort=DISTANCE`일 때만 필수이며, 다른 정렬에서
  /// 보내면 400이다 — Repository가 그 분기를 진다.
  /// [keyword]는 공백을 제외하고 2자 이상이어야 하며 미만이면 400이다.
  ///
  /// 커서에는 국가·정렬·검색어가 봉인돼 있어, 셋 중 하나라도 직전 요청과 다르면
  /// 커서를 재사용할 수 없다(400).
  ///
  /// 주의: `scope`는 `ALL` 외 값이 아직 400이다. 확정 실패를 왕복시키지 않도록
  /// Notifier가 전체 외 범위로는 호출하지 않는다.
  @GET(ApiEndpoints.communityPosts)
  Future<CommunityPostListResponseModel> getPosts({
    @Query('cursor') String? cursor,
    @Query('size') required int size,
    @Query('scope') String? scope,
    @Query('countryCode') required String countryCode,
    @Query('sort') String? sort,
    @Query('keyword') String? keyword,
    @Query('latitude') double? latitude,
    @Query('longitude') double? longitude,
  });
```

- [ ] **Step 6: Repository 인터페이스 확장**

`lib/features/community/domain/repositories/community_repository.dart`의 `getPosts` 선언과 DartDoc을 아래로 바꾸고, 상단 import에 `import '../entities/community_sort_option.dart';`를 더한다.

```dart
  /// 모집 게시글 목록을 커서 단위로 조회한다.
  ///
  /// [cursor]는 직전 응답의 `nextCursor`를 그대로 넘긴다 — 첫 요청은 null.
  /// [size]는 한 번에 가져올 개수(1~100).
  /// 실패 시 `AppException` 계열 예외를 던진다.
  ///
  /// 목록이 국가별로 나뉘므로 [countryCode]는 필수다(DEC-0021). 국가는
  /// [getCountryCode]로 먼저 구한다.
  ///
  /// [sort]가 [CommunitySortOption.distance]면 [latitude]·[longitude]가
  /// 필수다. 그 밖의 정렬에서는 좌표를 보내면 서버가 400을 주므로 구현체가
  /// 걸러낸다 — 호출자는 좌표를 항상 넘겨도 된다.
  ///
  /// [keyword]는 공백을 제외하고 2자 이상이어야 한다. 그보다 짧으면 서버가
  /// 400을 주므로 호출자가 미리 막는다.
  ///
  /// 커서에 국가·정렬·검색어가 봉인돼 있어, 셋 중 하나라도 직전 요청과 다르면
  /// [cursor]를 재사용할 수 없다(400).
  ///
  /// [scope]는 [CommunityScope.all] 외 값을 백엔드가 아직 400으로 막는다.
  Future<CommunityPostPageEntity> getPosts({
    String? cursor,
    required int size,
    CommunityScope scope = CommunityScope.all,
    required String countryCode,
    CommunitySortOption sort = CommunitySortOption.latest,
    String? keyword,
    double? latitude,
    double? longitude,
  });
```

- [ ] **Step 7: Repository 구현**

`community_repository_impl.dart`의 `getPosts`를 아래로 바꾸고, 상단 import에 `import '../../domain/entities/community_sort_option.dart';`를 더한다.

```dart
  @override
  Future<CommunityPostPageEntity> getPosts({
    String? cursor,
    required int size,
    CommunityScope scope = CommunityScope.all,
    required String countryCode,
    CommunitySortOption sort = CommunitySortOption.latest,
    String? keyword,
    double? latitude,
    double? longitude,
  }) {
    // 거리순이 아닌데 좌표를 실으면 400이다 — 호출자가 항상 넘기더라도
    // 여기서 걸러 낸다 (DEC-0021 조항 주석: 좌표는 DISTANCE에 한해 허용).
    final isDistance = sort == CommunitySortOption.distance;

    return _guard(
      () async {
        final res = await _dataSource.getPosts(
          cursor: cursor,
          size: size,
          scope: scope.queryValue,
          countryCode: countryCode,
          sort: sort.wireValue,
          keyword: keyword,
          latitude: isDistance ? latitude : null,
          longitude: isDistance ? longitude : null,
        );
        return CommunityPostPageEntity(
          items: res.content.map(_toEntity).toList(),
          nextCursor: res.cursor.nextCursor,
          hasNext: res.cursor.hasNext,
        );
      },
      message: '모집글을 불러오는 중 오류가 발생했습니다',
      messageKey: 'errorCommunityPostsLoadGeneric',
    );
  }
```

- [ ] **Step 8: 테스트 픽스처 스텁 갱신**

`test/features/community/community_fakes.dart`의 `CommunityRepositoryListStubs`를 새 시그니처에 맞추고, 상단에 `import 'package:cops_and_robbers/features/community/domain/entities/community_sort_option.dart';`를 더한다.

```dart
mixin CommunityRepositoryListStubs implements CommunityRepository {
  @override
  Future<CommunityPostPageEntity> getPosts({
    String? cursor,
    required int size,
    CommunityScope scope = CommunityScope.all,
    required String countryCode,
    CommunitySortOption sort = CommunitySortOption.latest,
    String? keyword,
    double? latitude,
    double? longitude,
  }) => throw UnimplementedError('이 테스트는 목록 조회를 쓰지 않는다');
}
```

- [ ] **Step 9: 코드 생성 후 통과 확인**

```bash
dart run build_runner build --delete-conflicting-outputs
flutter test test/features/community/data/
```
Expected: 생성 성공, 데이터 계층 테스트 PASS.

이 시점에 `community_page_test.dart`·`community_feed_notifier_test.dart`의 가짜 Repository가 새 시그니처와 어긋나 컴파일에 실패한다 — Task 4에서 함께 고친다. 지금은 `test/features/community/data/`만 돌린다.

- [ ] **Step 10: 커밋**

```bash
git add lib/features/community/ test/features/community/
git commit -m "feat : 목록 API에 정렬·검색어·좌표 파라미터 추가 #478"
```

---

## Task 4: Notifier family를 (스코프, 정렬, 검색어)로 확장

**Files:**
- Modify: `lib/features/community/presentation/providers/community_feed_state.dart`
- Modify: `lib/features/community/presentation/providers/community_provider.dart:150-260`
- Modify: `lib/features/community/presentation/pages/community_page.dart:65-70,300-313`
- Test: `test/features/community/presentation/providers/community_feed_notifier_test.dart`
- Test: `test/features/community/presentation/pages/community_page_test.dart:38-58`

**Interfaces:**
- Consumes: `CommunityRepository.getPosts(...)` (Task 3)
- Produces:
  - `communityFeedNotifierProvider(CommunityScope scope, CommunitySortOption sort, String? keyword)` — family 인자 3개
  - `CommunityFeedState`에 `double? latitude` · `double? longitude` 추가

- [ ] **Step 1: 실패하는 테스트 작성**

`test/features/community/presentation/providers/community_feed_notifier_test.dart`의 `_FakeCommunityRepository.getPosts`를 새 시그니처로 바꾸고 요청 기록을 남긴다.

```dart
  final List<String?> requestedCursors = [];
  final List<String> requestedCountryCodes = [];
  final List<CommunitySortOption> requestedSorts = [];
  final List<({double? lat, double? lng})> requestedCoordinates = [];

  @override
  Future<CommunityPostPageEntity> getPosts({
    String? cursor,
    required int size,
    CommunityScope scope = CommunityScope.all,
    required String countryCode,
    CommunitySortOption sort = CommunitySortOption.latest,
    String? keyword,
    double? latitude,
    double? longitude,
  }) async {
    requestedCursors.add(cursor);
    requestedCountryCodes.add(countryCode);
    requestedSorts.add(sort);
    requestedCoordinates.add((lat: latitude, lng: longitude));
    final page =
        pagesByCursor[cursor] ?? (items: <CommunityPostEntity>[], next: null);
    return CommunityPostPageEntity(
      items: page.items,
      nextCursor: page.next,
      hasNext: page.next != null,
    );
  }
```

같은 파일의 기존 `communityFeedNotifierProvider(CommunityScope.all)` 호출을 전부 `communityFeedNotifierProvider(CommunityScope.all, CommunitySortOption.latest, null)`로 바꾼다. 컨테이너 구성은 아래 헬퍼로 모은다 — 기존 테스트가 쓰던 `overrides` 목록에 GPS 대체 하나를 더한 것이다.

```dart
ProviderContainer _containerWith(CommunityRepository repo) => ProviderContainer(
  overrides: [
    communityRepositoryProvider.overrideWithValue(repo),
    deviceCountryCodeProvider.overrideWithValue('KR'),
    // GPS는 시스템 경계다 — 고정 좌표로 갈아끼운다.
    currentPositionResolverProvider.overrideWithValue(
      () async => (latitude: 37.4979, longitude: 127.0276),
    ),
  ],
);
```

그리고 테스트 둘을 추가한다.

```dart
  test('starts_from_first_page_when_sort_changes', () async {
    final repo = _FakeCommunityRepository({
      null: (items: [_post(1)], next: 'cursor-1'),
    });
    final container = _containerWith(repo);
    addTearDown(container.dispose);

    await container.read(
      communityFeedNotifierProvider(
        CommunityScope.all,
        CommunitySortOption.latest,
        null,
      ).future,
    );
    await container.read(
      communityFeedNotifierProvider(
        CommunityScope.all,
        CommunitySortOption.deadline,
        null,
      ).future,
    );

    // 커서에 정렬이 봉인돼 있어 재사용하면 400이다 — 둘 다 커서 없이 시작한다.
    expect(repo.requestedCursors, [null, null]);
    expect(repo.requestedSorts, [
      CommunitySortOption.latest,
      CommunitySortOption.deadline,
    ]);
  });

  test('reuses_first_page_coordinates_when_loading_more_by_distance', () async {
    final repo = _FakeCommunityRepository({
      null: (items: [_post(1)], next: 'cursor-1'),
      'cursor-1': (items: [_post(2)], next: null),
    });
    final container = _containerWith(repo);
    addTearDown(container.dispose);

    final provider = communityFeedNotifierProvider(
      CommunityScope.all,
      CommunitySortOption.distance,
      null,
    );
    await container.read(provider.future);
    await container.read(provider.notifier).loadMore();

    // 페이지를 넘길 때마다 GPS를 다시 켜지 않는다.
    expect(repo.requestedCoordinates, [
      (lat: 37.4979, lng: 127.0276),
      (lat: 37.4979, lng: 127.0276),
    ]);
  });
```

- [ ] **Step 2: 실패 확인**

Run: `flutter test test/features/community/presentation/providers/community_feed_notifier_test.dart`
Expected: FAIL — `communityFeedNotifierProvider`가 인자를 하나만 받는다(컴파일 에러).

- [ ] **Step 3: 상태에 좌표 필드 추가**

`community_feed_state.dart`의 `CommunityFeedState`에 두 필드를 더한다.

```dart
@freezed
class CommunityFeedState with _$CommunityFeedState {
  const factory CommunityFeedState({
    required List<CommunityPostEntity> items,

    /// 다음 요청에 그대로 실을 커서. 첫 페이지만 받은 직후에는 서버가 준
    /// `nextCursor`가 들어 있고, 더 없으면 null이다.
    required String? nextCursor,
    required bool hasMore,
    @Default(false) bool isLoadingMore,

    /// 거리순 조회에 쓴 기준 좌표. 첫 페이지에서 한 번 구해 `loadMore`가
    /// 그대로 재사용한다 — 페이지를 넘길 때마다 GPS를 켜지 않기 위해서다.
    /// 서버가 커서에 좌표를 담지 않으므로(사용자가 이동해도 커서가 막히지
    /// 않게) 같은 값을 계속 써도 계약에 어긋나지 않는다.
    /// 거리순이 아니면 null이다.
    double? latitude,
    double? longitude,
  }) = _CommunityFeedState;
}
```

- [ ] **Step 4: Notifier family 확장**

`community_provider.dart`의 `CommunityFeedNotifier` 선언부와 `build`를 아래로 바꾼다.

```dart
/// 커뮤니티 목록 무한 스크롤 상태 관리 Notifier
///
/// **조회 조건(스코프·정렬·검색어)마다 인스턴스가 따로 살아 있다.** 서버 커서에
/// 국가·정렬·검색어가 봉인돼 있어 조건이 바뀌면 커서를 재사용할 수 없으므로
/// (400), 조건을 family 키로 두면 새 인스턴스가 커서 없이 첫 페이지를 부른다 —
/// 리셋 로직이 따로 필요 없고 커서 불일치가 구조적으로 발생하지 않는다.
///
/// 목록(`keyword == null`)만 `keepAlive`한다. 예전에는 하나의 인스턴스가 선택된
/// 스코프를 watch 해서, 전체 → 우리동네 → 전체로 토글할 때마다 목록을 다시
/// 불렀다. 그때 딸려 나가는 건 목록 하나가 아니다 — 유일한 watcher가 사라지면서
/// `communityCountryCodeProvider`도 함께 폐기돼, 돌아올 때 GPS 측정과
/// `/country`(Geoapify 일 3,000건 한도 공유)까지 다시 탄다.
///
/// 반대로 검색은 자유 텍스트라 살려 두면 인스턴스가 무한히 늘어난다. 화면을
/// 나가면 폐기되게 둔다.
///
/// 목록이 낡는 문제는 이미 다른 길로 해결돼 있다 — 당겨서 새로고침, 글 작성 시
/// 무효화, 수정·삭제 시 그 자리 갱신.
///
/// 주의: `MINE`이 열리면 그건 사용자별 목록이므로, 로그인·로그아웃 때
/// 무효화하는 처리가 함께 필요하다.
@riverpod
class CommunityFeedNotifier extends _$CommunityFeedNotifier {
  static const _pageSize = 20;

  @override
  FutureOr<CommunityFeedState> build(
    CommunityScope scope,
    CommunitySortOption sort,
    String? keyword,
  ) async {
    // 목록은 살려 둔다(위 주석). 검색은 화면을 나가면 폐기되게 둔다.
    if (keyword == null) ref.keepAlive();

    // 백엔드가 scope=NEARBY/MINE에 400을 준다. 확정 실패를 왕복시키지 않고
    // 호출 자체를 건너뛰어 빈 목록을 돌려준다 — 화면은 이 상태를 "준비 중"
    // 안내로 그린다.
    if (scope != CommunityScope.all) {
      return const CommunityFeedState(
        items: [],
        nextCursor: null,
        hasMore: false,
      );
    }

    final coordinates = await _resolveSortCoordinates(sort);
    // 거리순인데 좌표가 없으면 서버가 400을 준다. 화면이 권한을 확보한 뒤에만
    // 거리순을 고르게 하므로 정상 경로에서는 오지 않는다 — 권한이 나중에
    // 회수된 경우의 안전망이다.
    final effectiveSort =
        sort == CommunitySortOption.distance && coordinates == null
        ? CommunitySortOption.latest
        : sort;
    if (effectiveSort != sort) {
      debugPrint('[커뮤니티] ⚠️ 거리순 좌표 없음 → 최신순으로 조회');
    }

    // 첫 요청은 커서 없이, 대신 국가 코드를 실어 보낸다. 국가 판별은
    // communityCountryCodeProvider가 진입당 한 번만 하고 결과를 들고 있는다.
    final countryCode = await ref.watch(communityCountryCodeProvider.future);
    final page = await ref
        .watch(communityRepositoryProvider)
        .getPosts(
          size: _pageSize,
          countryCode: countryCode,
          sort: effectiveSort,
          keyword: keyword,
          latitude: coordinates?.latitude,
          longitude: coordinates?.longitude,
        );

    return CommunityFeedState(
      items: page.items,
      nextCursor: page.nextCursor,
      hasMore: page.hasNext,
      latitude: coordinates?.latitude,
      longitude: coordinates?.longitude,
    );
  }

  /// 거리순일 때만 좌표를 구한다. 권한이 없으면 null.
  Future<DeviceCoordinates?> _resolveSortCoordinates(
    CommunitySortOption sort,
  ) async {
    if (sort != CommunitySortOption.distance) return null;
    return ref.read(currentPositionResolverProvider)();
  }
```

- [ ] **Step 5: `loadMore`가 좌표와 조건을 이어받게 한다**

같은 파일 `loadMore`의 `getPosts` 호출을 아래로 바꾼다. 나머지 가드·`identical` 검사·주석은 그대로 둔다.

```dart
      final page = await ref
          .read(communityRepositoryProvider)
          .getPosts(
            cursor: current.nextCursor,
            size: _pageSize,
            countryCode: countryCode,
            // 커서에 봉인된 조건과 같아야 한다 — 다르면 서버가 400을 준다.
            sort: sort,
            keyword: keyword,
            // 첫 페이지에서 구한 좌표를 그대로 쓴다 (GPS 재측정 없음).
            latitude: current.latitude,
            longitude: current.longitude,
          );
```

`state = AsyncData(current.copyWith(...))` 블록은 좌표를 건드리지 않는다 — `copyWith`가 기존 값을 유지한다.

- [ ] **Step 6: 호출부 갱신**

`community_page.dart`의 `_feed` getter를 아래로 바꾼다.

```dart
  /// 지금 보고 있는 목록. 스코프·정렬마다 인스턴스가 따로라 동작마다 짚어 줘야 한다.
  CommunityFeedNotifier get _feed => ref.read(
    communityFeedNotifierProvider(
      ref.read(selectedCommunityScopeProvider),
      ref.read(selectedCommunitySortProvider),
      null,
    ).notifier,
  );
```

같은 파일 `_buildBody`의 `ref.watch(communityFeedNotifierProvider(scope))`를 `ref.watch(communityFeedNotifierProvider(scope, sort, null))`로 바꾼다.

`community_page_test.dart`의 `_FakeCommunityRepository.getPosts`와 `_ThrowingCommunityRepository.getPosts`도 Task 3 Step 8과 같은 시그니처로 맞추고, 두 파일 모두 `community_sort_option.dart` import를 더한다.

```dart
  @override
  Future<CommunityPostPageEntity> getPosts({
    String? cursor,
    required int size,
    CommunityScope scope = CommunityScope.all,
    required String countryCode,
    CommunitySortOption sort = CommunitySortOption.latest,
    String? keyword,
    double? latitude,
    double? longitude,
  }) async {
    callCount++;
    return CommunityPostPageEntity(
      items: items,
      nextCursor: null,
      hasNext: false,
    );
  }
```

- [ ] **Step 7: 코드 생성 후 통과 확인**

```bash
dart run build_runner build --delete-conflicting-outputs
flutter test test/features/community/ && flutter analyze
```
Expected: PASS · 이슈 0건.

- [ ] **Step 8: 커밋**

```bash
git add lib/features/community/ test/features/community/
git commit -m "refactor : 목록 상태를 스코프·정렬·검색어 단위로 분리 #478"
```

---

## Task 5: 무한 스크롤 목록을 공용 위젯으로 추출

**Files:**
- Create: `lib/features/community/presentation/widgets/community_feed_list.dart`
- Modify: `lib/features/community/presentation/pages/community_page.dart` (목록 관련 멤버 제거)
- Test: `test/features/community/presentation/pages/community_page_test.dart` (동작 불변 확인)

**Interfaces:**
- Consumes: `communityFeedNotifierProvider(scope, sort, keyword)` (Task 4), `CommunityPostCard`, `CommunitySortSheet`, `AppRefreshControl`
- Produces: `CommunityFeedList({required CommunityScope scope, required CommunitySortOption sort, required String emptyMessage, String? keyword, double bottomPadding})`

이 작업은 **동작 변경이 없다.** 기존 테스트가 그대로 통과하는 것이 성공 기준이다.

- [ ] **Step 1: 위젯 파일 생성**

`lib/features/community/presentation/widgets/community_feed_list.dart`를 만든다. `community_page.dart`에서 아래 멤버를 그대로 옮긴다 — `_scrollController`, `_loadMoreThreshold`, `initState`/`dispose`, `_onScroll`, `_loadMore`, `_refresh`, `_handleCardMenu`, `_confirmDelete`, `_runCardAction`, `_openDetail`, `_buildSortLabel`, `_sortLabel`, `_openSortSheet`, `_buildPlaceholder`, `_buildRefreshablePlaceholder`, `_buildList`. 옮기면서 `scope`·`sort`는 `widget.scope`·`widget.sort`로 바꾸고, 목록 하단 여백은 `widget.bottomPadding`을 쓴다.

```dart
/// 커뮤니티 모집글 무한 스크롤 목록
///
/// 정렬 라벨 + 카드 목록 + 당겨서 새로고침 + 카드 더보기 동작을 함께 소유한다.
/// 목록 화면과 검색 화면이 같은 동작을 필요로 해 하나로 둔다 — 스크롤 리스너,
/// `loadMore` 중복 요청 가드, 에러 스낵바, 새로고침이 묶여 있어 복제하면
/// 한쪽만 고치는 사고가 난다.
///
/// [keyword]가 null이면 목록, 값이 있으면 검색 결과다. 그 구분은 이 위젯이
/// 쓰지 않고 provider의 family 키로 그대로 넘어간다.
class CommunityFeedList extends ConsumerStatefulWidget {
  const CommunityFeedList({
    super.key,
    required this.scope,
    required this.sort,
    required this.emptyMessage,
    this.keyword,
    this.bottomPadding = 0,
  });

  final CommunityScope scope;
  final CommunitySortOption sort;

  /// null = 목록, 값 있음 = 검색 결과.
  final String? keyword;

  /// 조회 결과가 비었을 때 보여줄 문구. 목록과 검색이 다른 말을 쓴다.
  final String emptyMessage;

  /// 목록 하단에 비워 둘 높이. 목록 화면은 떠 있는 작성 버튼에 마지막 카드가
  /// 가리지 않도록 버튼 높이만큼 넘긴다. 검색 화면은 버튼이 없어 0이다.
  final double bottomPadding;

  @override
  ConsumerState<CommunityFeedList> createState() => _CommunityFeedListState();
}
```

`_feed` getter는 세 인자를 모두 위젯 prop에서 읽는다.

```dart
  CommunityFeedNotifier get _feed => ref.read(
    communityFeedNotifierProvider(
      widget.scope,
      widget.sort,
      widget.keyword,
    ).notifier,
  );
```

`build`는 기존 `_buildBody`의 `.when(...)` 블록을 그대로 쓰되 `_wrapWithCreateButton`은 걷어낸다 — 작성 버튼은 목록 화면이 자기 Stack으로 얹는다.

```dart
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ref
        .watch(
          communityFeedNotifierProvider(
            widget.scope,
            widget.sort,
            widget.keyword,
          ),
        )
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          // AuthInterceptor가 강제 로그아웃(→ 화면 전환)을 처리하므로 UI는 무반응.
          // 첫 로드라 화면에 아직 아무 데이터가 없어 무반응 = 빈 화면.
          error: (e, _) => e is AuthException
              ? const SizedBox.shrink()
              : _buildRefreshablePlaceholder(
                  e is AppException
                      ? l10n.errorByException(e)
                      : l10n.errorCommunityPostsLoadFailed,
                ),
          data: (feed) => feed.items.isEmpty
              ? _buildRefreshablePlaceholder(widget.emptyMessage)
              : _buildList(l10n, feed),
        );
  }
```

`_buildList`의 `padding`에서 하단 값만 바꾼다.

```dart
        padding: EdgeInsets.only(
          left: AppSpacing.horizontal16,
          right: AppSpacing.horizontal16,
          bottom: widget.bottomPadding + AppSpacing.vertical16,
        ),
```

`_buildList`의 시그니처에서 `CommunitySortOption sort` 인자는 뺀다 — `widget.sort`를 직접 읽는다. `_buildSortLabel(l10n, widget.sort)`도 같다.

- [ ] **Step 2: 목록 화면에서 옮긴 멤버 제거하고 위젯을 꽂는다**

`community_page.dart`에서 Step 1이 옮긴 멤버를 모두 지운다. 남는 것은 `build`, `_buildBody`, `_buildCreateButton`, `_wrapWithCreateButton`, `_buildAppBarIcon`, `_buildPlaceholder`(준비 중 안내용), `_buttonBottomOffset`, `_createButtonHeight`다. `_buildBody`를 아래로 바꾼다.

```dart
  Widget _buildBody(
    AppLocalizations l10n,
    CommunityScope scope,
    CommunitySortOption sort,
    Widget createButton,
  ) {
    // 우리 동네 / 내 모임은 백엔드가 아직 400을 주므로 provider를 부르지 않는다.
    // 작성 버튼은 새 글을 쓰는 진입점 자체라 어느 탭이든 동일하게 떠 있어야 한다.
    if (scope != CommunityScope.all) {
      return _wrapWithCreateButton(
        createButton,
        _buildPlaceholder(l10n.comingSoonMessage),
      );
    }

    return _wrapWithCreateButton(
      createButton,
      CommunityFeedList(
        scope: scope,
        sort: sort,
        emptyMessage: l10n.pageCommunityEmpty,
        // 마지막 카드가 떠 있는 작성 버튼에 가리지 않도록 비운다.
        bottomPadding: _buttonBottomOffset + _createButtonHeight,
      ),
    );
  }
```

`build`의 `Consumer`가 `ref`를 더 넘기지 않으므로 호출도 맞춘다.

```dart
            child: Consumer(
              builder: (context, ref, _) => _buildBody(
                l10n,
                ref.watch(selectedCommunityScopeProvider),
                ref.watch(selectedCommunitySortProvider),
                createButton,
              ),
            ),
```

클래스에 남은 상태가 없으면 `ConsumerStatefulWidget`을 `ConsumerWidget`으로 낮출 수 있으나, 이 작업의 목표가 아니다 — 확신이 서지 않으면 그대로 둔다.

- [ ] **Step 3: 기존 테스트가 그대로 통과하는지 확인**

Run: `flutter test test/features/community/ && flutter analyze`
Expected: PASS · 이슈 0건. 실패하면 추출 과정에서 동작이 바뀐 것이므로 되돌려 원인을 찾는다.

- [ ] **Step 4: 커밋**

```bash
git add lib/features/community/presentation/
git commit -m "refactor : 무한 스크롤 목록을 공용 위젯으로 추출 #478"
```

---

## Task 6: 정렬 연동과 거리순 위치 권한

**Files:**
- Modify: `lib/features/community/presentation/widgets/community_sort_sheet.dart:55-61`
- Modify: `lib/features/community/presentation/widgets/community_feed_list.dart` (`_openSortSheet`)
- Modify: `lib/features/community/presentation/providers/community_provider.dart` (`SelectedCommunitySort` DartDoc)
- Modify: `lib/l10n/app_{ko,en,ja}.arb`
- Test: `test/features/community/presentation/pages/community_page_test.dart`

**Interfaces:**
- Consumes: `LocationPermissionService.ensurePermission() -> Future<bool>`, `LocationPermissionService.checkPermission() -> Future<LocationPermission>`, `communityCountryCodeProvider`
- Produces: `l10n.communitySortNeedsLocation` · `l10n.communitySortLocationDenied`

- [ ] **Step 1: ARB에 위치 안내 문구 추가**

`lib/l10n/app_ko.arb`의 `communitySortSheetTitle` 뒤에 넣는다.

```json
  "communitySortNeedsLocation": "위치 권한이 있어야 거리순으로 볼 수 있어요",
  "@communitySortNeedsLocation": {
    "description": "커뮤니티 정렬 — 거리순 선택 시 위치 권한을 거부했을 때"
  },
  "communitySortLocationDenied": "설정에서 위치 권한을 켜주세요",
  "@communitySortLocationDenied": {
    "description": "커뮤니티 정렬 — 위치 권한이 영구 거부돼 다시 물을 수 없을 때"
  },
```

`app_en.arb`:

```json
  "communitySortNeedsLocation": "Location access is needed to sort by distance",
  "communitySortLocationDenied": "Turn on location access in Settings",
```

`app_ja.arb`:

```json
  "communitySortNeedsLocation": "距離順で見るには位置情報の許可が必要です",
  "communitySortLocationDenied": "設定で位置情報をオンにしてください",
```

```bash
flutter gen-l10n && python3 docs/i18n/_lint_tone.py
```

- [ ] **Step 2: 정렬 시트에서 인기순을 감춘다**

`community_sort_sheet.dart`의 `_order`를 아래로 바꾼다. `_label`의 `popular` 분기는 남겨 둔다 — enum이 그대로라 switch가 total이어야 한다.

```dart
  /// 표시 순서 — 인덱스 ↔ enum 변환의 단일 기준.
  ///
  /// 인기순은 뺀다. 서버가 `UNSUPPORTED_LIST_SORT`(400)를 주기 때문이다 —
  /// 좋아요·스크랩 테이블이 없어 셀 대상이 없다. enum 값은 남겨 둬야
  /// 서버가 열렸을 때 여기 한 줄만 되돌리면 된다(DEC-0020).
  static const List<CommunitySortOption> _order = [
    CommunitySortOption.latest,
    CommunitySortOption.distance,
    CommunitySortOption.deadline,
  ];
```

- [ ] **Step 3: 실패하는 테스트 작성**

`test/features/community/presentation/pages/community_page_test.dart`에 추가한다. 펌프 헬퍼는 파일에 이미 있는 이름을 쓰고, 없으면 기존 테스트의 구성 코드를 `_pumpCommunityPage`로 뽑는다.

```dart
    testWidgets('hides_popular_option_when_sort_sheet_opens', (tester) async {
      // 서버가 400을 주는 값이라 고를 수 없어야 한다.
      await _pumpCommunityPage(tester, _FakeCommunityRepository([_post(1)]));
      await tester.tap(find.text('최신순'));
      await tester.pumpAndSettle();

      expect(find.text('거리순'), findsOneWidget);
      expect(find.text('마감 임박순'), findsOneWidget);
      expect(find.text('인기순'), findsNothing);
    });
```

- [ ] **Step 4: 실패 확인**

Run: `flutter test test/features/community/presentation/pages/community_page_test.dart`
Expected: FAIL — "인기순"이 발견된다.

- [ ] **Step 5: 거리순 권한 흐름 구현**

`community_feed_list.dart`의 `_openSortSheet`를 아래로 바꾼다. 상단에 `import '../../../../core/services/permission/location_permission_service.dart';`와 `import 'package:geolocator/geolocator.dart' show LocationPermission;`을 더한다.

```dart
  /// 정렬 시트를 띄우고 고른 값을 반영한다.
  ///
  /// 거리순만 위치 좌표가 있어야 성립하므로, 그때만 권한을 확보한 뒤에 정렬을
  /// 바꾼다. 목록 자체는 권한 없이 계속 보이고 거부해도 이전 정렬로 쓰므로
  /// 진입을 막는 게이트가 아니다.
  Future<void> _openSortSheet(CommunitySortOption current) async {
    final picked = await CommunitySortSheet.show(context, selected: current);
    if (picked == null || picked == current || !mounted) return;

    if (picked == CommunitySortOption.distance &&
        !await _ensureLocationForDistance()) {
      return;
    }
    if (!mounted) return;

    ref.read(selectedCommunitySortProvider.notifier).select(picked);
  }

  /// 거리순에 쓸 위치 권한을 확보한다. 실패하면 안내만 하고 false.
  ///
  /// 영구 거부를 따로 가르는 이유: 안드로이드는 두 번 거부하면 시스템 팝업을
  /// 더 띄우지 않는다. 같은 문구를 반복해 봐야 아무 일도 일어나지 않으므로
  /// 설정으로 안내한다.
  Future<bool> _ensureLocationForDistance() async {
    final granted = await LocationPermissionService.ensurePermission();
    if (!mounted) return false;

    if (granted) {
      // 권한이 없던 동안 국가는 기기 로케일 폴백이었다. 좌표가 생겼으니 다시
      // 판정한다 — 아니면 해외에 있는 한국 로케일 사용자가 한국 목록을 현지
      // 좌표로 거리순 정렬하게 된다(DEC-0021).
      ref.invalidate(communityCountryCodeProvider);
      return true;
    }

    final deniedForever =
        await LocationPermissionService.checkPermission() ==
        LocationPermission.deniedForever;
    if (!mounted) return false;

    final l10n = AppLocalizations.of(context);
    AppSnackbar.show(
      context,
      message: deniedForever
          ? l10n.communitySortLocationDenied
          : l10n.communitySortNeedsLocation,
    );
    return false;
  }
```

- [ ] **Step 6: `SelectedCommunitySort` 주석 갱신**

`community_provider.dart`의 `SelectedCommunitySort` DartDoc을 아래로 바꾼다.

```dart
/// 현재 선택된 정렬 기준.
///
/// 목록 화면과 검색 화면이 이 하나를 공유한다 — "마감 임박순으로 보고 싶다"는
/// 화면에 따라 달라지는 선호가 아니다.
///
/// `CommunityFeedNotifier`의 family 키에 그대로 들어가므로, 값이 바뀌면 그 정렬의
/// 인스턴스가 커서 없이 첫 페이지를 부른다. 서버 커서에 정렬이 봉인돼 있어
/// 재사용하면 400이라, 이 구조가 곧 계약이다.
///
/// 인기순은 서버가 아직 400을 주므로 정렬 시트가 노출하지 않는다.
```

- [ ] **Step 7: 통과 확인**

Run: `flutter test test/features/community/ && flutter analyze`
Expected: PASS · 이슈 0건.

- [ ] **Step 8: 커밋**

```bash
git add lib/l10n/ lib/features/community/ test/features/community/
git commit -m "feat : 목록 정렬 서버 연동 및 거리순 위치 권한 처리 #478"
```

---

## Task 7: 최근 검색어 저장소

**Files:**
- Create: `lib/features/community/data/datasources/community_recent_keyword_storage.dart`
- Create: `test/features/community/data/datasources/community_recent_keyword_storage_test.dart`

**Interfaces:**
- Produces:
  - `CommunityRecentKeywordStorage` — `load() -> Future<List<String>>`, `add(String) -> Future<void>`, `remove(String) -> Future<void>`, `clear() -> Future<void>`
  - `communityRecentKeywordStorageProvider` — riverpod_generator가 만든 Provider

- [ ] **Step 1: 실패하는 테스트 작성**

`test/features/community/data/datasources/community_recent_keyword_storage_test.dart`를 만든다.

```dart
import 'package:cops_and_robbers/features/community/data/datasources/community_recent_keyword_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    // SharedPreferences는 시스템 경계다 — 인메모리 구현으로 갈아끼운다.
    SharedPreferences.setMockInitialValues({});
  });

  test('returns_empty_list_when_nothing_was_searched', () async {
    final storage = CommunityRecentKeywordStorage();

    expect(await storage.load(), isEmpty);
  });

  test('returns_newest_first_when_multiple_keywords_added', () async {
    final storage = CommunityRecentKeywordStorage();

    await storage.add('서울');
    await storage.add('광진구');

    expect(await storage.load(), ['광진구', '서울']);
  });

  test('moves_keyword_to_front_when_searched_again', () async {
    final storage = CommunityRecentKeywordStorage();

    await storage.add('서울');
    await storage.add('광진구');
    await storage.add('서울');

    // 중복으로 쌓이지 않고 맨 앞으로 올라온다.
    expect(await storage.load(), ['서울', '광진구']);
  });

  test('keeps_only_ten_most_recent_when_limit_exceeded', () async {
    final storage = CommunityRecentKeywordStorage();

    for (var i = 1; i <= 12; i++) {
      await storage.add('검색어$i');
    }

    final loaded = await storage.load();
    expect(loaded.length, 10);
    expect(loaded.first, '검색어12');
    expect(loaded.last, '검색어3');
  });

  test('drops_only_the_given_keyword_when_removed', () async {
    final storage = CommunityRecentKeywordStorage();
    await storage.add('서울');
    await storage.add('광진구');

    await storage.remove('서울');

    expect(await storage.load(), ['광진구']);
  });

  test('returns_empty_list_when_cleared', () async {
    final storage = CommunityRecentKeywordStorage();
    await storage.add('서울');

    await storage.clear();

    expect(await storage.load(), isEmpty);
  });
}
```

- [ ] **Step 2: 실패 확인**

Run: `flutter test test/features/community/data/datasources/community_recent_keyword_storage_test.dart`
Expected: FAIL — `community_recent_keyword_storage.dart` 없음.

- [ ] **Step 3: 저장소 구현**

`lib/features/community/data/datasources/community_recent_keyword_storage.dart`를 만든다.

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'community_recent_keyword_storage.g.dart';

/// 커뮤니티 검색의 최근 검색어 로컬 영속화.
///
/// 기기에만 남고 서버로 보내지 않는다 — 남에게 노출되는 값이 아니라 UGC
/// 안전장치(필터·신고·차단) 대상이 아니다.
///
/// 문자열 목록 하나라 `setStringList`로 충분하다. JSON으로 감쌀 구조가 없다.
class CommunityRecentKeywordStorage {
  static const String _key = 'community_recent_keywords';

  /// 최대 보관 개수. 넘으면 오래된 것부터 버린다.
  static const int _limit = 10;

  /// 최근 검색어를 최신순으로 돌려준다. 없으면 빈 목록.
  Future<List<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? const [];
  }

  /// 검색어를 맨 앞에 넣는다. 이미 있으면 거기서 빼고 앞으로 올린다 —
  /// 같은 말을 두 번 검색했다고 목록에 두 줄이 남으면 안 된다.
  Future<void> add(String keyword) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_key) ?? const <String>[];
    final next = [
      keyword,
      for (final each in current)
        if (each != keyword) each,
    ].take(_limit).toList();
    await prefs.setStringList(_key, next);
  }

  /// 검색어 하나를 뺀다 (목록의 ✕).
  Future<void> remove(String keyword) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_key) ?? const <String>[];
    await prefs.setStringList(_key, [
      for (final each in current)
        if (each != keyword) each,
    ]);
  }

  /// 전부 지운다 (모두 삭제).
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

/// 최근 검색어 저장소 Provider
///
/// SharedPreferences는 시스템 경계라 여기서 한 번 갈라 둔다 — 테스트는 이
/// provider만 갈아끼우면 플랫폼 채널을 건드리지 않는다.
@riverpod
CommunityRecentKeywordStorage communityRecentKeywordStorage(Ref ref) =>
    CommunityRecentKeywordStorage();
```

- [ ] **Step 4: 코드 생성 후 통과 확인**

```bash
dart run build_runner build --delete-conflicting-outputs
flutter test test/features/community/data/datasources/community_recent_keyword_storage_test.dart
```
Expected: PASS.

- [ ] **Step 5: 커밋**

```bash
git add lib/features/community/data/datasources/ test/features/community/data/datasources/
git commit -m "feat : 커뮤니티 최근 검색어 로컬 저장소 추가 #478"
```

---

## Task 8: 검색 화면과 라우트

**Files:**
- Create: `lib/features/community/presentation/pages/community_search_page.dart`
- Create: `test/features/community/presentation/pages/community_search_page_test.dart`
- Modify: `lib/router/route_paths.dart:61-67,184-185`
- Modify: `lib/router/app_router.dart:382-395`
- Modify: `lib/features/community/presentation/pages/community_page.dart:197-199`
- Modify: `lib/l10n/app_{ko,en,ja}.arb`

**Interfaces:**
- Consumes: `CommunityFeedList` (Task 5), `communityRecentKeywordStorageProvider` (Task 7), `selectedCommunitySortProvider`
- Produces: `RoutePaths.communitySearch` = `'/community/search'`, `RoutePaths.communitySearchName` = `'communitySearch'`, `CommunitySearchPage`

- [ ] **Step 1: ARB에 검색 문구 추가**

`lib/l10n/app_ko.arb`:

```json
  "communitySearchHint": "제목, 장소를 검색해보세요",
  "@communitySearchHint": {
    "description": "커뮤니티 검색 — 입력창 안내 문구"
  },
  "communitySearchRecent": "최근 검색어",
  "@communitySearchRecent": {
    "description": "커뮤니티 검색 — 최근 검색어 목록 제목"
  },
  "communitySearchClearAll": "모두 삭제",
  "@communitySearchClearAll": {
    "description": "커뮤니티 검색 — 최근 검색어 전체 삭제 버튼"
  },
  "communitySearchEmpty": "검색 결과가 없어요",
  "@communitySearchEmpty": {
    "description": "커뮤니티 검색 — 결과가 하나도 없을 때"
  },
  "communitySearchTooShort": "두 글자 이상 입력해주세요",
  "@communitySearchTooShort": {
    "description": "커뮤니티 검색 — 공백을 제외한 검색어가 2자 미만일 때"
  },
```

`app_en.arb`:

```json
  "communitySearchHint": "Search by title or place",
  "communitySearchRecent": "Recent searches",
  "communitySearchClearAll": "Clear all",
  "communitySearchEmpty": "No results found",
  "communitySearchTooShort": "Enter at least 2 characters",
```

`app_ja.arb`:

```json
  "communitySearchHint": "タイトル・場所で検索",
  "communitySearchRecent": "最近の検索",
  "communitySearchClearAll": "すべて削除",
  "communitySearchEmpty": "検索結果がありません",
  "communitySearchTooShort": "2文字以上入力してください",
```

```bash
flutter gen-l10n && python3 docs/i18n/_lint_tone.py
```

- [ ] **Step 2: 실패하는 위젯 테스트 작성**

`test/features/community/presentation/pages/community_search_page_test.dart`를 만든다. 펌프 구성은 `community_page_test.dart`의 방식(ScreenUtilInit + MaterialApp + localizationsDelegates + ProviderScope overrides)을 그대로 따르고, `_FakeCommunityRepository`는 그 파일의 것과 같되 `lastKeyword`를 기록한다.

```dart
    testWidgets('does_not_query_when_keyword_is_shorter_than_two_letters', (
      tester,
    ) async {
      final repo = _FakeCommunityRepository([]);
      await _pumpSearchPage(tester, repo);

      await tester.enterText(find.byType(TextField), '서');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      // 확정 400을 왕복시키지 않는다.
      expect(repo.callCount, 0);
      expect(find.text('두 글자 이상 입력해주세요'), findsOneWidget);
    });

    testWidgets('counts_only_non_space_letters_when_validating_keyword', (
      tester,
    ) async {
      final repo = _FakeCommunityRepository([]);
      await _pumpSearchPage(tester, repo);

      // 서버가 공백을 제거하고 재므로 앱도 같은 규칙으로 잰다.
      await tester.enterText(find.byType(TextField), '서 ');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      expect(repo.callCount, 0);
    });

    testWidgets('stores_keyword_in_recent_searches_when_search_runs', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final repo = _FakeCommunityRepository([]);
      await _pumpSearchPage(tester, repo);

      await tester.enterText(find.byType(TextField), '서울');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      expect(repo.lastKeyword, '서울');
      expect(await CommunityRecentKeywordStorage().load(), ['서울']);
    });
```

- [ ] **Step 3: 실패 확인**

Run: `flutter test test/features/community/presentation/pages/community_search_page_test.dart`
Expected: FAIL — `community_search_page.dart` 없음.

- [ ] **Step 4: 라우트 등록**

`lib/router/route_paths.dart`의 `communityCreate` 뒤, `communityDetail` 앞에 넣는다.

```dart
  /// 모집글 검색 화면 (커뮤니티 목록 상단 돋보기에서 진입)
  ///
  /// `:postId`보다 먼저 등록해야 한다 — 뒤에 두면 `/community/search`가
  /// postId="search"로 잡힌다 (`create`와 같은 이유).
  static const String communitySearch = '/community/search';
```

같은 파일 이름 상수 블록의 `communityCreateName` 뒤:

```dart
  static const String communitySearchName = 'communitySearch';
```

`lib/router/app_router.dart`의 커뮤니티 `routes: [` 안, `create` GoRoute 뒤이자 `:postId` GoRoute 앞에 넣는다. 파일 상단에 `import '../features/community/presentation/pages/community_search_page.dart';`를 더한다.

```dart
                  // ======================================================
                  // 모집글 검색 (바텀 네비 위 전체 화면)
                  //
                  // `:postId`보다 앞에 둔다 — 뒤에 두면 `/community/search`가
                  // postId="search"로 잡힌다.
                  // ======================================================
                  GoRoute(
                    path: 'search',
                    name: RoutePaths.communitySearchName,
                    parentNavigatorKey: rootNavigatorKey,
                    pageBuilder: (context, state) => buildSmoothFade(
                      key: state.pageKey,
                      child: const CommunitySearchPage(),
                    ),
                  ),
```

- [ ] **Step 5: 검색 화면 구현**

`lib/features/community/presentation/pages/community_search_page.dart`를 만든다.

```dart
/// 커뮤니티 모집글 검색 화면
///
/// 상태가 둘이다 — 입력 중에는 최근 검색어를, 검색을 실행한 뒤에는 결과 목록을
/// 보여준다. 실행된 검색어만 [_submitted]에 담아 provider의 family 키로 넘기므로,
/// 타이핑 도중에는 요청이 나가지 않는다. 서버가 `LIKE '%키워드%'`로 훑어
/// 인덱스를 타지 못해 "검색 버튼 시점에 한 번"이 백엔드 지침이다.
class CommunitySearchPage extends ConsumerStatefulWidget {
  const CommunitySearchPage({super.key});

  @override
  ConsumerState<CommunitySearchPage> createState() =>
      _CommunitySearchPageState();
}

class _CommunitySearchPageState extends ConsumerState<CommunitySearchPage> {
  final TextEditingController _controller = TextEditingController();

  /// 실행된 검색어. null이면 아직 검색하지 않았다.
  String? _submitted;

  /// 최근 검색어. 화면 진입 때 한 번 읽고 이후 갱신할 때마다 다시 읽는다.
  List<String> _recent = const [];

  /// 서버가 세는 방식과 같게 잰다 — 공백을 전부 제거하고 2자 이상.
  static bool _isLongEnough(String keyword) =>
      keyword.replaceAll(RegExp(r'\s'), '').length >= 2;

  @override
  void initState() {
    super.initState();
    unawaited(_loadRecent());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadRecent() async {
    final loaded = await ref.read(communityRecentKeywordStorageProvider).load();
    if (!mounted) return;
    setState(() => _recent = loaded);
  }

  /// 검색 실행 — 2자 미만은 서버에 보내기 전에 막는다(확정 400).
  ///
  /// 서버에는 원문을 그대로 보낸다. 공백 제거는 서버가 하고, 커서에 봉인되는
  /// 검색어 해시도 서버가 만든다.
  Future<void> _search(String raw) async {
    final keyword = raw.trim();
    if (!_isLongEnough(keyword)) {
      AppSnackbar.show(
        context,
        message: AppLocalizations.of(context).communitySearchTooShort,
      );
      return;
    }

    await ref.read(communityRecentKeywordStorageProvider).add(keyword);
    if (!mounted) return;

    _controller.text = keyword;
    setState(() => _submitted = keyword);
    await _loadRecent();
  }

  Future<void> _removeRecent(String keyword) async {
    await ref.read(communityRecentKeywordStorageProvider).remove(keyword);
    await _loadRecent();
  }

  Future<void> _clearRecent() async {
    await ref.read(communityRecentKeywordStorageProvider).clear();
    await _loadRecent();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/icon_exit.svg',
            width: 20.w,
            height: 20.h,
          ),
          onPressed: () => context.pop(),
        ),
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onSubmitted: (value) => unawaited(_search(value)),
          style: AppTextStyles.paragraph14.copyWith(color: AppColors.black),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: l10n.communitySearchHint,
            hintStyle: AppTextStyles.paragraph14.copyWith(
              color: AppColors.black500,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/icon_search.svg',
              width: 20.w,
              height: 20.h,
            ),
            onPressed: () => unawaited(_search(_controller.text)),
          ),
          SizedBox(width: AppSpacing.horizontal8),
        ],
      ),
      body: _submitted == null
          ? _buildRecent(l10n)
          : Consumer(
              builder: (context, ref, _) => CommunityFeedList(
                scope: CommunityScope.all,
                sort: ref.watch(selectedCommunitySortProvider),
                keyword: _submitted,
                emptyMessage: l10n.communitySearchEmpty,
              ),
            ),
    );
  }

  Widget _buildRecent(AppLocalizations l10n) {
    if (_recent.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: AppPadding.horizontal16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: AppSpacing.vertical16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.communitySearchRecent,
                style: AppTextStyles.label_16.copyWith(color: AppColors.black),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => unawaited(_clearRecent()),
                child: Text(
                  l10n.communitySearchClearAll,
                  style: AppTextStyles.tag_12.copyWith(
                    color: AppColors.black600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.vertical12),
          Wrap(
            spacing: AppSpacing.horizontal8,
            runSpacing: AppSpacing.vertical8,
            children: [
              for (final keyword in _recent)
                _RecentChip(
                  keyword: keyword,
                  onTap: () => unawaited(_search(keyword)),
                  onRemove: () => unawaited(_removeRecent(keyword)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 최근 검색어 한 칸 — 탭하면 그 말로 다시 검색하고, ✕는 그 항목만 지운다.
class _RecentChip extends StatelessWidget {
  const _RecentChip({
    required this.keyword,
    required this.onTap,
    required this.onRemove,
  });

  final String keyword;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.horizontal12,
          vertical: AppSpacing.vertical8,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.pill,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              keyword,
              style: AppTextStyles.tag_12.copyWith(color: AppColors.black700),
            ),
            SizedBox(width: AppSpacing.horizontal4),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onRemove,
              child: Icon(Icons.close, size: 12.w, color: AppColors.black500),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 6: 목록 화면의 돋보기를 연결**

`community_page.dart`의 AppBar `actions`를 아래로 바꾼다. `_buildAppBarIcon`이 이미 탭 처리를 갖고 있다면 그 안에 `onTap` 파라미터를 더해 같은 결과를 만든다 — 위젯을 이중으로 감싸지 않는다.

```dart
        actions: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              VibrationService.instance().buttonTap();
              context.pushNamed(RoutePaths.communitySearchName);
            },
            child: _buildAppBarIcon('assets/icons/icon_search.svg'),
          ),
          // 알림은 기능 자체가 없다. 후속 연결 전까지 탭 여부만 로그로 확인한다.
          _buildAppBarIcon('assets/icons/icon_bell_off.svg'),
          SizedBox(width: AppSpacing.horizontal16),
        ],
```

- [ ] **Step 7: 통과 확인**

Run: `flutter test test/features/community/ && flutter analyze`
Expected: PASS · 이슈 0건.

- [ ] **Step 8: 커밋**

```bash
git add lib/ test/
git commit -m "feat : 커뮤니티 모집글 검색 화면 추가 #478"
```

---

## Task 9: 지번 주소 주석 정합과 최종 검증

**Files:**
- Modify: `lib/features/community/data/models/community_post_model.dart:8,25`
- Modify: `lib/features/community/domain/entities/community_post_entity.dart:38-42`
- Modify: `lib/features/community/presentation/pages/community_detail_page.dart:296-307`

**Interfaces:** 없음 (주석만 바뀐다)

서버가 `LocationResponse.address`를 실제로 내려주기 시작했다. DTO·Entity·복사 로직은 이미 준비돼 있어 코드 변경이 없고, "백엔드 추가 예정"으로 남은 주석 셋만 사실과 어긋난다.

- [ ] **Step 1: DTO 주석 수정**

`community_post_model.dart`의 `address` 필드 주석에서 마지막 문장을 바꾼다.

```dart
    /// [region]의 동까지로는 안 된다. 역지오코딩이 실패한 글은 null이다.
```

같은 파일 상단의 `/// 백엔드 스키마: api-docs.json#LocationResponse (v2.18.0)`을 `(v2.21.0)`으로 고친다.

- [ ] **Step 2: Entity 주석 수정**

`community_post_entity.dart`의 `address` 필드 주석을 아래로 바꾼다.

```dart
    /// 번지까지 붙은 지번 주소 — `서울특별시 광진구 화양동 164-2`.
    ///
    /// 화면에 그리지 않고 복사에만 쓴다([locationLabel] 참고).
    /// 역지오코딩이 실패한 글은 null이다.
    String? address,
```

- [ ] **Step 3: 상세 화면 주석 수정**

`community_detail_page.dart`의 `_copyLocation` DartDoc에서 "백엔드가 …까지는 null이라" 문단을 아래로 바꾼다.

```dart
  /// 역지오코딩이 실패한 글은 [CommunityPostEntity.address]가 null이라 동 단위
  /// [CommunityPostEntity.region]이 대신 담긴다. 좌표로 `/address`를 따로 부르지는
  /// 않는다 — 목록·상세 응답에 이미 실려 오는 값을 벤더 한도까지 써 가며 다시
  /// 받아 올 이유가 없다.
```

- [ ] **Step 4: 전체 검증**

```bash
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
python3 docs/i18n/_lint_tone.py
flutter test
flutter analyze
```
Expected: 생성 성공 · 톤 위반 0건 · 전체 테스트 PASS · analyze 이슈 0건.

전부 통과하기 전에는 완료로 보고하지 않는다. 실패가 남으면 그 출력을 그대로 보고한다.

- [ ] **Step 5: 커밋**

```bash
git add lib/features/community/
git commit -m "docs : 지번 주소 관련 주석을 실제 응답에 맞게 정정 #478"
```

---

## 검증 요약

| 확인 | 명령 |
|---|---|
| 코드 생성 | `dart run build_runner build --delete-conflicting-outputs` |
| i18n 생성 | `flutter gen-l10n` |
| 문구 톤 | `python3 docs/i18n/_lint_tone.py` |
| 테스트 | `flutter test` |
| 정적 분석 | `flutter analyze` |
