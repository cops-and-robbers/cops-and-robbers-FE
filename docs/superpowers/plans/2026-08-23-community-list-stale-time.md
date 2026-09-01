# 커뮤니티 목록 캐시 유효 시간 구현 계획 (#479)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 커뮤니티 목록을 받아온 지 3분이 지나면 낡은 것으로 보고, 화면에 다시 들어올 때 조용히 새로 받는다.

**Architecture:** `CommunityFeedState`에 받아온 시각을 기록하고 Notifier가 `refreshIfStale()`로 판정·실행한다. "다시 들어옴"은 셸의 브랜치 인덱스 변화로 잡는다 — 상세·검색은 셸 **위에** 뜨므로 인덱스를 바꾸지 않아, 글 하나를 오래 읽고 나와도 목록이 초기화되지 않는다. 트리거는 탭 전환과 앱 포그라운드 복귀 둘이고 모두 `CommunityPage`에 건다.

**Tech Stack:** Flutter 3.9.2+ / Riverpod(riverpod_generator) / Freezed / go_router 17.2.3

**Spec:** `docs/superpowers/specs/2026-08-23-community-list-stale-time-design.md`

## Global Constraints

- 주석은 한국어로, WHY 중심. **현재 코드에 대해 참이어야 한다.**
- UI 문자열 한국어 하드코딩 금지 — 이 작업은 새 문구가 없다. 문구를 추가하게 되면 `lib/l10n/app_{ko,en,ja}.arb` 셋 모두에 넣고 `flutter gen-l10n`.
- 색·타이포는 `AppColors`·`AppTextStyles` 직접 참조. `Theme.of(context)` 금지.
- 에러 처리는 try-catch + Custom Exception. Either 패턴 금지.
- `@riverpod`·`@freezed` 어노테이션을 건드린 뒤에는 `dart run build_runner build --delete-conflicting-outputs`.
- 테스트는 `.claude/rules/Agents.md`를 따른다 — 시스템 경계(Repository·GPS·권한·**시계**)만 가짜로 두고 내부 협력자는 실물. 호출 기록만을 유일한 단언으로 삼지 않는다. 이름은 `<subject>_<expected>_when_<condition>`.
- 커밋 메시지는 `<type> : <설명> #479` 형식. 원격 반영은 하지 않는다(CLAUDE.md 금지 규칙). Co-Authored-By 금지.
- **TTL은 3분.** `Duration(minutes: 3)`.
- 브랜치 인덱스: 홈 0 · 커뮤니티 1 · 마이페이지 2 (`app_router.dart`의 `StatefulShellBranch` 순서).

---

## File Structure

**신규 1**

| 파일 | 책임 |
|---|---|
| `lib/router/current_branch_index_provider.dart` | 현재 선택된 바텀 네비 브랜치 인덱스. 셸이 발행하고 탭 화면이 읽는다. |

**수정 6** — `community_feed_state.dart`(시각 필드), `community_provider.dart`(시계·판정), `community_page.dart`(트리거), `main_scaffold.dart`(발행), `route_paths.dart`(인덱스 상수), `community_search_page.dart`(검색어 좁히기).

---

## Task 1: 낡음 판정과 시계

**Files:**
- Modify: `lib/features/community/presentation/providers/community_feed_state.dart`
- Modify: `lib/features/community/presentation/providers/community_provider.dart`
- Test: `test/features/community/presentation/providers/community_feed_notifier_test.dart`

**Interfaces:**
- Produces:
  - `CommunityFeedState.fetchedAt` — `required DateTime`
  - `clockProvider` — `DateTime Function()`을 담는 provider (`@riverpod DateTime Function() clock(Ref ref)`)
  - `CommunityFeedNotifier.refreshIfStale()` — `Future<void>`. 낡았을 때만 `refresh()`를 부른다

- [ ] **Step 1: 테스트 헬퍼에 시계를 뚫는다**

`test/features/community/presentation/providers/community_feed_notifier_test.dart`의 `_containerWith`에 `now` 파라미터를 더한다. **기존 override 셋은 그대로 두고 하나만 추가한다.**

```dart
ProviderContainer _containerWith(
  CommunityRepository repo, {
  String countryCode = 'KR',
  DateTime Function()? now,
}) {
  final container = ProviderContainer(
    overrides: [
      communityRepositoryProvider.overrideWithValue(repo),
      // 국가 판별은 GPS·권한·벤더를 거친다 — 전부 시스템 경계라 여기서 끊는다.
      communityCountryCodeProvider.overrideWith((ref) async => countryCode),
      // GPS는 시스템 경계다 — 고정 좌표로 갈아끼운다.
      currentPositionResolverProvider.overrideWithValue(
        () async => (latitude: 37.4979, longitude: 127.0276),
      ),
      // 시계도 시스템 경계다 — 유효 시간 판정을 검증하려면 앞으로 돌릴 수 있어야 한다.
      if (now != null) clockProvider.overrideWithValue(now),
    ],
  );
  addTearDown(container.dispose);
  return container;
}
```

- [ ] **Step 2: 실패하는 테스트 넷을 쓴다**

같은 파일에 group을 추가한다. `_post(int id)` 헬퍼와 `_FakeCommunityRepository`는 파일에 이미 있으니 그대로 쓴다.

```dart
  group('CommunityFeedNotifier.refreshIfStale', () {
    /// 시계를 원하는 시각으로 고정한다. `advance`를 바꿔 시간을 앞으로 돌린다.
    ({DateTime Function() clock, void Function(Duration) advance}) _fakeClock() {
      var now = DateTime(2026, 8, 23, 12);
      return (clock: () => now, advance: (d) => now = now.add(d));
    }

    test('keeps_the_cached_list_when_refetched_within_the_stale_window', () async {
      final repo = _FakeCommunityRepository({
        null: (items: [_post(1)], next: null),
      });
      final fake = _fakeClock();
      final container = _containerWith(repo, now: fake.clock);
      final provider = communityFeedNotifierProvider(
        CommunityScope.all,
        CommunitySortOption.latest,
        null,
      );
      await container.read(provider.future);

      fake.advance(const Duration(minutes: 2, seconds: 59));
      await container.read(provider.notifier).refreshIfStale();

      // 3분이 안 지났으면 캐시를 그대로 쓴다 — 서버를 다시 부르지 않는다.
      expect(repo.requestedCursors, hasLength(1));
      expect(container.read(provider).value!.items.single.id, 1);
    });

    test('refetches_from_the_first_page_when_the_stale_window_has_passed', () async {
      final repo = _FakeCommunityRepository({
        null: (items: [_post(1)], next: null),
      });
      final fake = _fakeClock();
      final container = _containerWith(repo, now: fake.clock);
      final provider = communityFeedNotifierProvider(
        CommunityScope.all,
        CommunitySortOption.latest,
        null,
      );
      await container.read(provider.future);

      fake.advance(const Duration(minutes: 3, seconds: 1));
      await container.read(provider.notifier).refreshIfStale();

      // 커서 없이 첫 페이지부터 다시 받는다.
      expect(repo.requestedCursors, [null, null]);
      expect(container.read(provider).value!.items.single.id, 1);
    });

    test('does_not_refetch_when_another_page_is_still_loading', () async {
      final repo = _FakeCommunityRepository({
        null: (items: [_post(1)], next: 'cursor-1'),
        'cursor-1': (items: [_post(2)], next: null),
      });
      final fake = _fakeClock();
      final container = _containerWith(repo, now: fake.clock);
      final provider = communityFeedNotifierProvider(
        CommunityScope.all,
        CommunitySortOption.latest,
        null,
      );
      await container.read(provider.future);

      fake.advance(const Duration(minutes: 5));
      // 이어붙이기를 기다리지 않고 그 사이에 낡음 판정을 걸어 본다.
      final pending = container.read(provider.notifier).loadMore();
      await container.read(provider.notifier).refreshIfStale();
      await pending;

      // 진행 중인 요청을 버리지 않는다 — 두 페이지가 그대로 이어붙는다.
      expect(container.read(provider).value!.items.map((e) => e.id), [1, 2]);
      expect(repo.requestedCursors, [null, 'cursor-1']);
    });

    test('records_the_fetch_time_when_the_first_page_arrives', () async {
      final repo = _FakeCommunityRepository({
        null: (items: [_post(1)], next: null),
      });
      final fake = _fakeClock();
      final container = _containerWith(repo, now: fake.clock);

      final state = await container.read(
        communityFeedNotifierProvider(
          CommunityScope.all,
          CommunitySortOption.latest,
          null,
        ).future,
      );

      expect(state.fetchedAt, DateTime(2026, 8, 23, 12));
    });
  });
```

- [ ] **Step 3: 실패 확인**

Run: `flutter test test/features/community/presentation/providers/community_feed_notifier_test.dart`
Expected: FAIL — `clockProvider`·`refreshIfStale`·`fetchedAt`이 없어 컴파일되지 않는다.

- [ ] **Step 4: 상태에 받아온 시각을 더한다**

`community_feed_state.dart`의 `CommunityFeedState`에 필드를 추가한다. 기존 필드와 주석은 그대로 둔다.

```dart
    /// 이 목록을 서버에서 받아온 시각.
    ///
    /// 유효 시간이 지났는지 판정하는 기준이다. `loadMore`로 페이지를 이어붙이는
    /// 것은 "다시 받아온 것"이 아니므로 갱신하지 않는다.
    required DateTime fetchedAt,
```

- [ ] **Step 5: 시계 provider를 더한다**

`community_provider.dart`의 `checkLocationPermissionProvider` 선언 **바로 뒤에** 추가한다. 그 자리가 시스템 경계를 감싸는 provider들이 모여 있는 곳이다.

```dart
/// 현재 시각.
///
/// 시간은 시스템 경계라 갈아끼울 자리가 필요하다 — 유효 시간 판정을 테스트하려면
/// 시계를 앞으로 돌릴 수 있어야 한다. 값이 아니라 함수를 담는 이유는 호출하는
/// 시점의 시각을 원하기 때문이다.
///
/// 세 번째 사용처가 생기면 `core`로 옮긴다. 지금은 목록 유효 시간만 쓴다.
@riverpod
DateTime Function() clock(Ref ref) => DateTime.now;
```

- [ ] **Step 6: `build()`의 두 반환 지점에 시각을 채운다**

`community_provider.dart`에는 `CommunityFeedState`를 만드는 곳이 둘이다. **`scope != all` 조기 반환이 `const`라 그대로 두면 컴파일되지 않는다** — `const`를 떼고 시각을 넣는다.

```dart
    if (scope != CommunityScope.all) {
      return CommunityFeedState(
        items: const [],
        nextCursor: null,
        hasMore: false,
        // 서버를 부르지 않았지만 "이 시점의 판정 결과"라 시각을 남긴다.
        // 이 스코프는 어차피 낡음 판정 대상이 아니다(항상 비어 있다).
        fetchedAt: ref.read(clockProvider)(),
      );
    }
```

그리고 정상 반환에도 더한다.

```dart
    return CommunityFeedState(
      items: page.items,
      nextCursor: page.nextCursor,
      hasMore: page.hasNext,
      latitude: coordinates?.latitude,
      longitude: coordinates?.longitude,
      fetchedAt: ref.read(clockProvider)(),
    );
```

- [ ] **Step 7: `refreshIfStale()`을 더한다**

`CommunityFeedNotifier` 안, `refresh()` 바로 뒤에 놓는다. `_pageSize` 옆에 상수를 더한다.

```dart
  /// 마지막 조회로부터 이 시간이 지나면 낡은 것으로 본다.
  ///
  /// 모집글은 실시간 데이터가 아니라 잠깐 낡은 화면을 보는 것은 허용한다.
  /// 다만 게임 한 판이 보통 이보다 길어, 끝내고 돌아오면 새로 받게 된다.
  static const _staleAfter = Duration(minutes: 3);
```

```dart
  /// 낡았으면 첫 페이지부터 다시 받는다. 화면이 다시 보이는 순간 호출한다.
  ///
  /// 사용자가 부른 동작이 아니므로 조용히 갱신하고, 아래 세 경우에는 손대지
  /// 않는다 — 건드려 봐야 이득이 없거나 진행 중인 일을 망친다.
  Future<void> refreshIfStale() async {
    final current = state.valueOrNull;
    // 첫 로드 중이거나 에러 상태다. 전자는 곧 최신이 되고, 후자는 사용자가
    // '다시 시도'로 직접 다룰 화면이다.
    if (current == null) return;
    // 페이지를 이어붙이는 중이면 그 요청을 버리게 된다.
    if (current.isLoadingMore) return;
    if (ref.read(clockProvider)().difference(current.fetchedAt) < _staleAfter) {
      return;
    }
    await refresh();
  }
```

- [ ] **Step 8: 코드 생성 후 통과 확인**

```bash
dart run build_runner build --delete-conflicting-outputs
flutter test test/features/community/ && flutter analyze
```
Expected: PASS · 커뮤니티 코드에 analyze 이슈 0건.

- [ ] **Step 9: 커밋**

```bash
git add lib/features/community/ test/features/community/
git commit -m "feat : 목록 캐시 유효 시간 판정 추가 #479"
```

---

## Task 2: 브랜치 인덱스 발행

**Files:**
- Create: `lib/router/current_branch_index_provider.dart`
- Modify: `lib/router/main_scaffold.dart`
- Modify: `lib/router/route_paths.dart`
- Test: `test/router/main_scaffold_test.dart` (신규)

**Interfaces:**
- Produces:
  - `currentBranchIndexProvider` — `int`. `.notifier`의 `select(int)`로 갱신한다
  - `RoutePaths.communityBranchIndex` — `int` 상수, 값은 `1`

- [ ] **Step 1: 실패하는 테스트를 쓴다**

`test/router/main_scaffold_test.dart`를 만든다. `MainScaffold`는 `StatefulNavigationShell`을 요구하는데 위젯 테스트에서 진짜 셸을 세우기는 무겁다. **대신 `didUpdateWidget`의 판정 자체를 검증한다** — 같은 인덱스로 다시 그리면 발행하지 않고, 다른 인덱스면 발행하는 것.

`GoRouter`로 실제 `StatefulShellRoute`를 구성해 두 브랜치를 오가며 확인한다.

```dart
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:cops_and_robbers/router/current_branch_index_provider.dart';
import 'package:cops_and_robbers/router/main_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// 브랜치 둘짜리 최소 셸. 실제 앱 라우터를 끌어오지 않고 MainScaffold의
/// 인덱스 발행만 확인한다.
GoRouter _shellRouter() {
  final rootKey = GlobalKey<NavigatorState>();
  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: '/a',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainScaffold(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/a', builder: (_, _) => const Text('A')),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/b', builder: (_, _) => const Text('B')),
            ],
          ),
        ],
      ),
    ],
  );
}

Widget _wrap(GoRouter router) => ProviderScope(
  child: ScreenUtilInit(
    designSize: const Size(393, 852),
    builder: (_, _) => MaterialApp.router(
      routerConfig: router,
      locale: const Locale('ko'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  ),
);

void main() {
  testWidgets('publishes_the_branch_index_when_the_tab_changes', (tester) async {
    final router = _shellRouter();
    await tester.pumpWidget(_wrap(router));
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(MainScaffold)),
    );
    expect(container.read(currentBranchIndexProvider), 0);

    router.go('/b');
    await tester.pumpAndSettle();

    expect(container.read(currentBranchIndexProvider), 1);
  });

  testWidgets('keeps_the_published_index_when_rebuilt_without_a_tab_change', (
    tester,
  ) async {
    final router = _shellRouter();
    await tester.pumpWidget(_wrap(router));
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(MainScaffold)),
    );
    var publishCount = 0;
    container.listen(currentBranchIndexProvider, (_, _) => publishCount++);

    // 같은 브랜치로 다시 이동해도 인덱스는 그대로다.
    router.go('/a');
    await tester.pumpAndSettle();

    expect(publishCount, 0);
    expect(container.read(currentBranchIndexProvider), 0);
  });
}
```

- [ ] **Step 2: 실패 확인**

Run: `flutter test test/router/main_scaffold_test.dart`
Expected: FAIL — `current_branch_index_provider.dart`가 없어 컴파일되지 않는다.

- [ ] **Step 3: provider를 만든다**

`lib/router/current_branch_index_provider.dart`:

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'current_branch_index_provider.g.dart';

/// 현재 선택된 바텀 네비 브랜치 인덱스.
///
/// `MainScaffold`가 브랜치 전환을 감지해 발행하고, 탭 화면이 "내가 다시 보이게
/// 됐다"를 판정하는 데 쓴다. 상세·검색처럼 셸 **위에** 뜨는 화면은 이 값을
/// 바꾸지 않으므로, 그런 이동에는 반응하지 않는다 — 글 하나를 오래 읽고 나와도
/// 목록이 초기화되지 않는 것이 이 신호를 고른 이유다.
///
/// 앱 셸이 살아 있는 동안 유지된다. 셸이 쓰고 탭 화면이 읽는 값이라 그 사이
/// 리스너가 잠깐 비어도 0으로 되돌아가면 안 된다.
@Riverpod(keepAlive: true)
class CurrentBranchIndex extends _$CurrentBranchIndex {
  @override
  int build() => 0;

  /// 메서드 이름이 `select`인 것은 `SelectedCommunityScope`·`SelectedCommunitySort`와
  /// 맞춘 것이다. `set`은 Dart의 setter 문법과 충돌한다.
  void select(int index) => state = index;
}
```

- [ ] **Step 4: 브랜치 인덱스 상수를 더한다**

`lib/router/route_paths.dart`의 `community` 상수 근처에 추가한다.

```dart
  /// 바텀 네비에서 커뮤니티가 몇 번째 브랜치인가 (`app_router.dart`의
  /// `StatefulShellBranch` 순서 — 홈 0 · 커뮤니티 1 · 마이페이지 2).
  ///
  /// 탭 화면이 "지금 내가 보이는가"를 판정할 때 쓴다. 브랜치 순서를 바꾸면
  /// 여기도 함께 고쳐야 한다.
  static const int communityBranchIndex = 1;
```

- [ ] **Step 5: `MainScaffold`를 전환한다**

`lib/router/main_scaffold.dart`를 `ConsumerStatefulWidget`으로 바꾼다. `build`의 내용(Scaffold·AppBottomNav·items 3개)은 **한 글자도 바꾸지 않고** 그대로 옮긴다.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/navigation/app_bottom_nav.dart';
import '../l10n/app_localizations.dart';
import 'current_branch_index_provider.dart';

/// StatefulShellRoute의 쉘
///
/// 탭 전환 시 각 브랜치(홈/커뮤니티/마이페이지)의 네비게이션 스택을
/// 독립적으로 보존한 채 바텀 네비게이션 바를 함께 그린다.
///
/// 전환을 [currentBranchIndexProvider]로 발행한다 — 탭 화면이 "다시 보이게
/// 됐다"를 알아야 낡은 데이터를 갱신할 수 있기 때문이다.
class MainScaffold extends ConsumerStatefulWidget {
  const MainScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  @override
  void initState() {
    super.initState();
    // 첫 진입 값. build 중이 아니라 여기서 넣어야 provider 쓰기가 안전하다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(currentBranchIndexProvider.notifier)
          .select(widget.navigationShell.currentIndex);
    });
  }

  @override
  void didUpdateWidget(covariant MainScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    // `currentIndex`는 위젯의 final 필드고 브랜치가 바뀌면 새 인스턴스가 온다
    // (go_router `route.dart`의 StatefulNavigationShell). 그래서 이전 값과
    // 정확히 비교할 수 있다.
    final next = widget.navigationShell.currentIndex;
    if (oldWidget.navigationShell.currentIndex == next) return;
    ref.read(currentBranchIndexProvider.notifier).select(next);
  }

  @override
  Widget build(BuildContext context) {
    // 기존 build 본문(Scaffold · AppBottomNav · BottomNavItem 3개)을 그대로
    // 옮긴다. 로직·문구·에셋 경로를 하나도 바꾸지 않는다.
    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: AppBottomNav(
        currentIndex: widget.navigationShell.currentIndex,
        onTap: (index) => widget.navigationShell.goBranch(
          index,
          initialLocation: index == widget.navigationShell.currentIndex,
        ),
        items: [
          // (기존 BottomNavItem 3개를 그대로 둔다 — 홈 · 커뮤니티 · 마이페이지)
        ],
      ),
    );
  }
}
```

`StatelessWidget`이던 때의 `navigationShell` 참조가 전부 `widget.navigationShell`로 바뀌는 것이 유일한 차이다. `items`의 `BottomNavItem` 셋은 `navigationShell`을 쓰지 않으므로 손대지 않는다.

- [ ] **Step 6: 코드 생성 후 통과 확인**

```bash
dart run build_runner build --delete-conflicting-outputs
flutter test test/router/ && flutter analyze
```
Expected: PASS · analyze 신규 이슈 0건.

- [ ] **Step 7: 전체 테스트로 회귀 확인**

Run: `flutter test`
Expected: 실패 0. `MainScaffold`는 앱 셸이라 다른 화면 테스트가 함께 걸릴 수 있다 — 깨지면 그 원인을 보고하고 임의로 테스트를 고치지 않는다.

- [ ] **Step 8: 커밋**

```bash
git add lib/router/ test/router/
git commit -m "feat : 바텀 네비 브랜치 인덱스 발행 추가 #479"
```

---

## Task 3: 트리거 연결

**Files:**
- Modify: `lib/features/community/presentation/pages/community_page.dart`
- Test: `test/features/community/presentation/pages/community_page_test.dart`

**Interfaces:**
- Consumes: `CommunityFeedNotifier.refreshIfStale()` (Task 1), `clockProvider` (Task 1), `currentBranchIndexProvider` · `RoutePaths.communityBranchIndex` (Task 2), 기존 `lifecycleStateProvider`(`lib/core/services/lifecycle/lifecycle_provider.dart`, `Stream<AppLifecycleState>`)

- [ ] **Step 1: 실패하는 테스트 셋을 쓴다**

`community_page_test.dart`에 group을 추가한다. 이 파일의 `_pumpCommunityPage` 하네스와 `_FakeCommunityRepository`를 쓴다. 하네스는 이미 `List<Override> overrides = const []`를 받으므로(#478에서 넓혔다) 그대로 쓰면 된다 — 시그니처를 고칠 필요가 없다.

```dart
  group('CommunityPage 낡은 목록 갱신', () {
    testWidgets('refetches_when_returning_to_the_community_tab_after_the_stale_window', (
      tester,
    ) async {
      var now = DateTime(2026, 8, 23, 12);
      final repo = _FakeCommunityRepository([_post(1)]);
      await _pumpCommunityPage(
        tester,
        repo,
        overrides: [clockProvider.overrideWithValue(() => now)],
      );
      final container = ProviderScope.containerOf(
        tester.element(find.byType(CommunityPage)),
      );
      expect(repo.callCount, 1);

      now = now.add(const Duration(minutes: 4));
      // 다른 탭에 갔다가 커뮤니티로 돌아온 상황.
      container.read(currentBranchIndexProvider.notifier).select(0);
      container
          .read(currentBranchIndexProvider.notifier)
          .select(RoutePaths.communityBranchIndex);
      await tester.pumpAndSettle();

      expect(repo.callCount, 2);
    });

    testWidgets('keeps_the_cached_list_when_returning_within_the_stale_window', (
      tester,
    ) async {
      var now = DateTime(2026, 8, 23, 12);
      final repo = _FakeCommunityRepository([_post(1)]);
      await _pumpCommunityPage(
        tester,
        repo,
        overrides: [clockProvider.overrideWithValue(() => now)],
      );
      final container = ProviderScope.containerOf(
        tester.element(find.byType(CommunityPage)),
      );

      now = now.add(const Duration(minutes: 1));
      container.read(currentBranchIndexProvider.notifier).select(0);
      container
          .read(currentBranchIndexProvider.notifier)
          .select(RoutePaths.communityBranchIndex);
      await tester.pumpAndSettle();

      // 3분이 안 지났으면 그대로 쓴다.
      expect(repo.callCount, 1);
    });

    testWidgets('does_not_refetch_when_switching_to_another_tab', (tester) async {
      var now = DateTime(2026, 8, 23, 12);
      final repo = _FakeCommunityRepository([_post(1)]);
      await _pumpCommunityPage(
        tester,
        repo,
        overrides: [clockProvider.overrideWithValue(() => now)],
      );
      final container = ProviderScope.containerOf(
        tester.element(find.byType(CommunityPage)),
      );

      now = now.add(const Duration(minutes: 4));
      // 마이페이지로 이동 — 커뮤니티는 보이지 않는다.
      container.read(currentBranchIndexProvider.notifier).select(2);
      await tester.pumpAndSettle();

      // 안 보이는 화면을 위해 네트워크를 쓰지 않는다.
      expect(repo.callCount, 1);
    });
  });
```

- [ ] **Step 2: 실패 확인**

Run: `flutter test test/features/community/presentation/pages/community_page_test.dart`
Expected: FAIL — 갱신이 일어나지 않아 `callCount`가 1에 머문다.

- [ ] **Step 3: 트리거를 등록한다**

`community_page.dart`의 `_CommunityPageState.build` **맨 위**, `final l10n = ...` 앞에 넣는다. `ref.listen`은 `build` 안에서 불러야 한다.

```dart
  @override
  Widget build(BuildContext context) {
    // 다른 탭이나 게임에 갔다가 돌아왔을 때. 상세·검색은 셸 위에 떠서 이 값을
    // 바꾸지 않으므로, 글을 오래 읽고 나와도 목록이 초기화되지 않는다.
    ref.listen(currentBranchIndexProvider, (previous, next) {
      if (previous == next) return;
      if (next != RoutePaths.communityBranchIndex) return;
      unawaited(_refreshIfStale());
    });

    // 앱이 백그라운드에서 돌아왔을 때.
    ref.listen(lifecycleStateProvider, (previous, next) {
      if (next.valueOrNull != AppLifecycleState.resumed) return;
      // 커뮤니티 탭이 아니면 보이지 않는 화면이다. 안 보이는 것을 위해
      // 네트워크를 쓰지 않는다.
      if (ref.read(currentBranchIndexProvider) !=
          RoutePaths.communityBranchIndex) {
        return;
      }
      unawaited(_refreshIfStale());
    });

    final l10n = AppLocalizations.of(context);
```

같은 클래스에 메서드를 더한다.

```dart
  /// 지금 보고 있는 목록이 낡았으면 조용히 다시 받는다.
  ///
  /// 검색어 자리에 항상 `null`을 넘기는 이유: 검색 결과는 화면을 나가면
  /// 폐기되므로 유효 시간을 따질 대상이 아니다.
  Future<void> _refreshIfStale() async {
    try {
      await ref
          .read(
            communityFeedNotifierProvider(
              ref.read(selectedCommunityScopeProvider),
              ref.read(selectedCommunitySortProvider),
              null,
            ).notifier,
          )
          .refreshIfStale();
    } on AppException catch (_) {
      // 사용자가 부른 동작이 아니다. 실패는 provider의 에러 상태로 이미 화면에
      // 반영되므로 여기서 스낵바를 띄우지 않는다.
    }
  }
```

`import 'package:flutter/material.dart';`가 `AppLifecycleState`를 준다. `lifecycleStateProvider`는 `../../../../core/services/lifecycle/lifecycle_provider.dart`에서, `currentBranchIndexProvider`는 `../../../../router/current_branch_index_provider.dart`에서 가져온다.

- [ ] **Step 4: 통과 확인**

```bash
flutter test test/features/community/ && flutter analyze
```
Expected: PASS · analyze 신규 이슈 0건.

- [ ] **Step 5: 커밋**

```bash
git add lib/features/community/ test/features/community/
git commit -m "feat : 탭 복귀·앱 복귀 시 낡은 목록 갱신 #479"
```

---

## Task 4: 최근 검색어 좁히기

**Files:**
- Modify: `lib/features/community/presentation/pages/community_search_page.dart`
- Test: `test/features/community/presentation/pages/community_search_page_test.dart`

**Interfaces:** 없음 (이 화면 안에서 닫힌다)

- [ ] **Step 1: 실패하는 테스트 셋을 쓴다**

`community_search_page_test.dart`에 추가한다. 이 파일의 `_pumpSearchPage` 하네스를 쓴다. 최근 검색어는 `SharedPreferences.setMockInitialValues`로 미리 심는다 — 키는 `community_recent_keywords`다.

```dart
    testWidgets('narrows_recent_keywords_to_the_typed_text', (tester) async {
      SharedPreferences.setMockInitialValues({
        'community_recent_keywords': ['서울숲', '광진구', '서울역'],
      });
      await _pumpSearchPage(tester, _FakeCommunityRepository([]));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '서울');
      await tester.pumpAndSettle();

      expect(find.text('서울숲'), findsOneWidget);
      expect(find.text('서울역'), findsOneWidget);
      expect(find.text('광진구'), findsNothing);
    });

    testWidgets('shows_every_recent_keyword_when_the_input_is_empty', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'community_recent_keywords': ['서울숲', '광진구'],
      });
      await _pumpSearchPage(tester, _FakeCommunityRepository([]));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '서울');
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();

      expect(find.text('서울숲'), findsOneWidget);
      expect(find.text('광진구'), findsOneWidget);
    });

    testWidgets('ignores_letter_case_when_narrowing_recent_keywords', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'community_recent_keywords': ['Seoul Forest', '광진구'],
      });
      await _pumpSearchPage(tester, _FakeCommunityRepository([]));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'seoul');
      await tester.pumpAndSettle();

      expect(find.text('Seoul Forest'), findsOneWidget);
      expect(find.text('광진구'), findsNothing);
    });

    testWidgets('leaves_the_stored_keywords_untouched_while_narrowing', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'community_recent_keywords': ['서울숲', '광진구'],
      });
      await _pumpSearchPage(tester, _FakeCommunityRepository([]));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '서울');
      await tester.pumpAndSettle();

      // 표시만 좁힐 뿐 저장소는 그대로다.
      expect(
        await CommunityRecentKeywordStorage().load(),
        ['서울숲', '광진구'],
      );
    });
```

- [ ] **Step 2: 실패 확인**

Run: `flutter test test/features/community/presentation/pages/community_search_page_test.dart`
Expected: FAIL — 입력과 무관하게 최근 검색어가 전부 보여 `findsNothing`이 깨진다.

- [ ] **Step 3: 좁힌 목록을 만든다**

`community_search_page.dart`의 `_CommunitySearchPageState`에 getter를 더한다.

```dart
  /// 입력에 맞춰 좁힌 최근 검색어. 입력이 비면 전부 보여준다.
  ///
  /// 로컬에 이미 있는 목록을 거르는 것이라 서버 요청이 없다. 본 검색은 여전히
  /// 실행 시점에 한 번만 부른다 — 타이핑마다 부르면 인덱스를 타지 못하는
  /// 전체 스캔을 반복하게 된다(백엔드 지침).
  List<String> get _visibleRecent {
    final typed = _controller.text.trim();
    if (typed.isEmpty) return _recent;
    final lowered = typed.toLowerCase();
    return [
      for (final keyword in _recent)
        if (keyword.toLowerCase().contains(lowered)) keyword,
    ];
  }
```

- [ ] **Step 4: 입력 변화에 다시 그린다**

`initState`에서 리스너를 달고 `dispose`에서 뗀다. 기존 `unawaited(_loadRecent());`는 그대로 둔다.

```dart
  @override
  void initState() {
    super.initState();
    // 타이핑에 맞춰 최근 검색어를 좁혀 보여준다. 서버는 부르지 않는다.
    _controller.addListener(_onTypedChanged);
    unawaited(_loadRecent());
  }

  void _onTypedChanged() => setState(() {});

  @override
  void dispose() {
    _controller.removeListener(_onTypedChanged);
    _controller.dispose();
    super.dispose();
  }
```

- [ ] **Step 5: 표시를 좁힌 목록으로 바꾼다**

`_buildRecent`의 두 곳을 바꾼다.

```dart
  Widget _buildRecent(AppLocalizations l10n) {
    final recent = _visibleRecent;
    if (recent.isEmpty) return const SizedBox.shrink();
```

그리고 `Wrap`의 순회를 바꾼다.

```dart
              for (final keyword in recent)
```

- [ ] **Step 6: 통과 확인**

```bash
flutter test test/features/community/ && flutter analyze
```
Expected: PASS · analyze 신규 이슈 0건.

- [ ] **Step 7: 전체 검증**

```bash
flutter test
flutter analyze
```
Expected: 전체 통과 · 신규 이슈 0건. 실패가 남으면 그 출력을 그대로 보고한다.

- [ ] **Step 8: 커밋**

```bash
git add lib/features/community/ test/features/community/
git commit -m "feat : 최근 검색어를 입력에 맞춰 좁혀 표시 #479"
```

---

## 검증 요약

| 확인 | 명령 |
|---|---|
| 코드 생성 | `dart run build_runner build --delete-conflicting-outputs` |
| 테스트 | `flutter test` |
| 정적 분석 | `flutter analyze` |

ARB를 건드리지 않으므로 `flutter gen-l10n`·톤 검사는 이 작업에 해당하지 않는다.
