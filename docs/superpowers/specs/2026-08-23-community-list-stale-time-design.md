# 커뮤니티 목록 캐시 유효 시간 적용 설계 (#479)

## 배경

#477이 목록을 캐시해 재조회를 없앴다. 스코프를 오갈 때마다 목록·GPS·`/country`를 다시 타던 것을 화면당 1회로 줄인 개선이었고, 계량 결과 토글 왕복 3회 기준 4회 → 1회였다.

그 부작용으로 **낡은 목록을 되돌릴 기준이 사라졌다.** provider가 앱 루트 `ProviderScope`에 살고 목록 인스턴스가 `keepAlive`라, 화면을 나갔다 돌아와도 다시 부르지 않는다. 게임은 끝나면 `context.go(RoutePaths.home)`으로 홈 탭에 내려놓으므로 셸도 폐기되지 않는다. 결과적으로 갱신 경로는 셋뿐이다 — 당겨서 새로고침, 글을 직접 쓰거나 고치거나 지웠을 때, 앱 재시작.

즉 게임 한 판을 하고 돌아와도, 몇 시간이 지나도 처음 받아온 목록 그대로다. 그 사이 남이 올린 글은 보이지 않는다.

## 목표

1. 목록에 유효 시간을 둔다. 마지막으로 받아온 지 **3분**이 지나면 낡은 것으로 보고, 커뮤니티 화면에 다시 들어올 때 조용히 새로 받는다.
2. 3분 안에 돌아오면 캐시를 그대로 쓴다 — 탭을 잠깐 오가는 정도로는 재조회가 일어나지 않는다.
3. 최근 검색어를 타이핑에 맞춰 좁혀 보여준다. 서버 요청은 늘지 않는다.

## 범위 제외

- **본 검색의 디바운싱.** 백엔드가 명시적으로 반대했다 — 검색이 `LIKE '%키워드%'`라 인덱스를 타지 못해 사실상 전체 스캔이고, 그래서 "타이핑마다가 아니라 검색 버튼을 눌렀을 때" 부르라는 지침이 있다. 2자 미만을 400으로 막는 것도 같은 이유다. 실시간 추천 검색어를 하려면 인덱스를 탈 수 있는 전용 API가 먼저 필요한데, 이 제품은 검색 엔진 도입을 이미 기각했다(`PRD_2.md`). 따라서 FE만으로는 만들 수 없다.
- **검색 결과의 유효 시간.** 검색 결과 인스턴스는 화면을 나가면 폐기되므로 다시 검색하면 어차피 새로 받는다. 남는 경우는 검색 화면에 머문 채 3분 이상 백그라운드에 다녀오는 것뿐인데, 드물고 영향이 작다. 이것까지 덮으려면 `CommunityPage`가 검색어를 알아야 해서 경계가 지저분해진다.
- **낡음을 사용자에게 알리는 UI.** 배너나 인디케이터 없이 조용히 갱신한다.

---

## 1. 무엇을 "다시 들어옴"으로 볼 것인가

이것이 이 작업의 유일한 설계 갈림길이다. 제약이 하나 있다 — **상세 글을 열었다 닫는 것으로는 갱신되면 안 된다.** 글 하나를 4분 읽고 나왔더니 목록이 초기화되고 스크롤이 맨 위로 튀면 최악이다.

**채택: 셸의 브랜치 인덱스 변화**

바텀 네비의 탭 전환은 `StatefulShellRoute`의 브랜치 인덱스를 바꾼다. 반면 상세(`/community/:postId`)와 검색(`/community/search`)은 `parentNavigatorKey: rootNavigatorKey`로 셸 **위에** 뜨므로 인덱스를 건드리지 않는다. 이 신호는 탭을 오간 경우에만 정확히 울리고 커뮤니티 내부 이동에는 침묵한다.

게임도 끝나면 홈 탭으로 가므로 커뮤니티로 돌아올 때 탭 전환으로 잡힌다.

**검토하고 버린 대안**

- **현재 경로(GoRouter location)를 본다** — 의존성도 새 위젯도 없이 이미 있는 것을 읽는 점이 매력적이나, `/community` → `/community/123` → `/community`도 "돌아옴"으로 읽혀 위 제약에 정면으로 걸린다.
- **`VisibilityDetector` 패키지** — 셸 구조와 무관하게 "실제로 보이는가"로 판정해 가장 튼튼하지만, 상세 화면이 덮었다 걷힐 때도 똑같이 울려 같은 문제가 있고 의존성이 하나 늘어난다.
- **`StatefulNavigationShell.of(context)`로 화면이 직접 관찰** — `findAncestorStateOfType`을 쓰는 조회라 의존성이 등록되지 않는다. `didChangeDependencies`가 인덱스 변화에 발화하지 않아 성립하지 않는다.

### 1.1 인덱스 변화는 `MainScaffold`가 알린다

`StatefulNavigationShell.currentIndex`는 **위젯의 `final` 필드**이고 생성자에서 계산된다(go_router 17.2.3 `route.dart:1242,1262`). 브랜치가 바뀌면 새 위젯 인스턴스가 만들어지므로, `MainScaffold`를 `ConsumerStatefulWidget`으로 바꾸면 `didUpdateWidget`에서 이전 값과 정확히 비교할 수 있다.

```dart
@override
void didUpdateWidget(covariant MainScaffold oldWidget) {
  super.didUpdateWidget(oldWidget);
  final next = widget.navigationShell.currentIndex;
  if (oldWidget.navigationShell.currentIndex == next) return;
  // didUpdateWidget도 initState(mount)와 마찬가지로 BuildOwner.buildScope의
  // 빌드 락 구간 안에서 불린다 — 여기서 바로 쓰면 Riverpod의 "빌드 중 provider
  // 수정" 어서션에 걸린다. 그래서 발행을 다음 프레임으로 미룬다.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!mounted) return;
    ref.read(currentBranchIndexProvider.notifier).select(next);
  });
}
```

`build` 중에는 provider를 쓸 수 없다 — `didUpdateWidget`도 `initState`도 위젯 트리 빌드 락
구간 안에서 호출되므로 둘 다 안전하지 않다. 두 곳 모두 `addPostFrameCallback` + `mounted`
확인으로 발행을 다음 프레임으로 미룬다. 첫 진입 값은 `initState`에서, 이후 전환은
`didUpdateWidget`에서 같은 방식으로 넣는다.

브랜치 인덱스 상수는 `RoutePaths`에 둔다. 라우터의 브랜치 순서(홈 0 · 커뮤니티 1 · 마이페이지 2)와 짝을 이루는 값이라 한 곳에서 관리한다.

## 2. 낡음 판정

`CommunityFeedState`에 `required DateTime fetchedAt`을 더한다(nullable이 아니다 — 상태가 존재한다는 것은 이미 한 번 받아왔다는 뜻이다). `build()`가 응답을 받은 시각으로 채우고, `loadMore`의 `copyWith`는 건드리지 않는다 — 이어붙이기는 "다시 받아온 것"이 아니다.

`CommunityFeedNotifier`에 판정과 실행을 함께 둔다. TTL은 정책이므로 이 클래스의 상수다.

```dart
/// 마지막 조회로부터 이 시간이 지나면 낡은 것으로 본다.
///
/// 목록은 실시간 데이터가 아니라 잠깐 낡은 화면을 보는 것은 허용한다. 다만
/// 게임 한 판이 보통 이보다 길어, 끝내고 돌아오면 새로 받게 된다.
static const _staleAfter = Duration(minutes: 3);

/// 낡았으면 다시 받는다. 화면이 다시 보이는 순간 호출한다.
Future<void> refreshIfStale() async {
  final current = state.valueOrNull;
  // 첫 로드 중이거나 에러 상태면 건드리지 않는다 — 곧 최신이 되거나,
  // 사용자가 다시 시도로 직접 다룰 상태다.
  if (current == null) return;
  // 페이지를 이어붙이는 중이면 그 요청을 버리게 된다.
  if (current.isLoadingMore) return;
  if (ref.read(clockProvider)().difference(current.fetchedAt) < _staleAfter) {
    return;
  }
  await refresh();
}
```

`refresh()`는 실패하면 던진다. 호출부(트리거)는 그것을 삼킨다 — 실패는 provider의 에러 상태로 이미 화면에 반영되고, 사용자가 부른 동작이 아니라 스낵바를 띄울 자리도 아니다.

### 2.1 시계

`DateTime.now()`를 직접 부르면 유효 시간 판정을 테스트할 수 없다. 함수를 담는 provider로 감싼다 — `currentPositionResolverProvider`·`ensureLocationPermissionProvider`가 이미 쓰는 패턴이고 같은 파일에 둔다.

```dart
/// 현재 시각. 시간은 시스템 경계라 갈아끼울 자리가 필요하다 —
/// 유효 시간 판정을 테스트하려면 시계를 앞으로 돌릴 수 있어야 한다.
///
/// 값이 아니라 함수를 담는다. 호출하는 시점의 시각을 원하기 때문이다.
@riverpod
DateTime Function() clock(Ref ref) => DateTime.now;
```

세 번째 사용처가 생기면 `core`로 옮긴다. 지금은 이 기능 하나만 쓴다.

## 3. 트리거

둘 다 `CommunityPage`(탭 루트)에 건다. `CommunityFeedList`가 아니라 여기인 이유는, 검색 결과 화면도 그 위젯을 쓰기 때문이다 — 트리거를 위젯에 걸면 보이지도 않는 검색 인스턴스까지 갱신하게 된다.

**탭 전환**

```dart
ref.listen(currentBranchIndexProvider, (previous, next) {
  if (next != RoutePaths.communityBranchIndex) return;
  if (previous == next) return;
  unawaited(_refreshIfStale());
});
```

**앱 포그라운드 복귀**

```dart
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
```

`_refreshIfStale()`은 `selectedCommunityScopeProvider`·`selectedCommunitySortProvider`를 읽어 그 조합의 인스턴스를 집고 `refreshIfStale()`을 부른 뒤 예외를 삼킨다. 검색어 자리에는 항상 `null`을 넘긴다 — 목록 인스턴스만 대상이다.

```dart
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

`ref.listen`은 `build` 안에서 호출해야 한다. `CommunityPage.build`가 이미 `Consumer`로 부분 구독하고 있으므로, 트리거 등록은 `build` 최상단에 둔다.

## 4. 최근 검색어 좁히기

`community_search_page.dart`가 이미 최근 검색어 최대 10개를 `_recent`에 들고 있다. 입력이 바뀔 때마다 그 목록을 걸러 보여준다. **저장소는 건드리지 않는다 — 표시만 좁힌다.**

```dart
/// 입력에 맞춰 좁힌 최근 검색어. 입력이 비면 전부 보여준다.
///
/// 로컬에 이미 있는 목록을 거르는 것이라 서버 요청이 없다. 본 검색은
/// 여전히 실행 시점에 한 번만 부른다 — 타이핑마다 부르면 인덱스를 타지
/// 못하는 전체 스캔을 반복하게 된다.
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

`initState`에서 `_controller`에 리스너를 달아 `setState`로 다시 그리고, `dispose`에서 뗀다. 빈 상태 판정(`_recent.isEmpty`)도 좁힌 결과 기준으로 바꾼다 — 입력과 일치하는 최근 검색어가 없으면 목록 자리를 비운다.

## 5. 에러 처리

| 상황 | 동작 |
|---|---|
| 낡음 판정 시 아직 첫 로드 중 | 건드리지 않는다 (곧 최신이 된다) |
| 낡음 판정 시 첫 로드가 실패한 상태 | 건드리지 않는다 (되살릴 목록이 없다) |
| 낡음 판정 시 한 번 성공한 뒤 실패한 상태 | 다시 받는다 — 화면 복귀는 일시 장애를 재시도하기 좋은 때다 |
| 낡음 판정 시 페이지 이어붙이는 중 | 건드리지 않는다 (진행 중인 요청을 버리게 된다) |
| 재조회가 실패 | provider의 에러 상태로 화면에 반영. 트리거는 예외를 삼킨다 |

## 6. 파일

**수정 6**

| 파일 | 변경 |
|---|---|
| `providers/community_feed_state.dart` | `fetchedAt` 필드 |
| `providers/community_provider.dart` | `clockProvider`, `refreshIfStale()`, `build()`에서 `fetchedAt` 기록 |
| `pages/community_page.dart` | 트리거 둘 등록, `_refreshIfStale()` |
| `router/main_scaffold.dart` | `ConsumerStatefulWidget` 전환, 인덱스 변화 발행 |
| `router/route_paths.dart` | 브랜치 인덱스 상수 |
| `pages/community_search_page.dart` | 최근 검색어 좁히기 |

**신규 1** — `lib/router/current_branch_index_provider.dart`. 셸이 발행하고 탭 화면들이 읽는 값이라 `router/` 아래, 셸과 같은 계층에 둔다.

```dart
/// 현재 선택된 바텀 네비 브랜치 인덱스.
///
/// `MainScaffold`가 브랜치 전환을 감지해 발행하고, 탭 화면이 "내가 다시
/// 보이게 됐다"를 판정하는 데 쓴다. 상세·검색처럼 셸 위에 뜨는 화면은 이
/// 값을 바꾸지 않으므로, 그런 이동에는 반응하지 않는다.
/// 앱 셸이 살아 있는 동안 유지된다 — 셸이 쓰고 탭 화면이 읽는 값이라
/// 그 사이 리스너가 잠깐 비어도 0으로 되돌아가면 안 된다.
@Riverpod(keepAlive: true)
class CurrentBranchIndex extends _$CurrentBranchIndex {
  @override
  int build() => 0;

  /// 메서드 이름이 `select`인 것은 `SelectedCommunityScope`·`SelectedCommunitySort`와
  /// 맞춘 것이다. `set`은 Dart의 setter 문법과 충돌한다.
  void select(int index) => state = index;
}
```

## 7. 테스트

| 대상 | 확인할 동작 |
|---|---|
| `refreshIfStale` | TTL 미만이면 재조회하지 않는다 / 초과면 한다 / 첫 로드 중이면 하지 않는다 / 이어붙이는 중이면 하지 않는다 |
| 탭 전환 트리거 | 인덱스가 커뮤니티로 바뀌면 부르고, 다른 탭으로 바뀔 때는 부르지 않는다 |
| 앱 복귀 트리거 | 커뮤니티 탭일 때만 부른다 |
| `MainScaffold` | 브랜치 인덱스가 바뀔 때만 발행한다 (같은 값 재빌드에는 발행하지 않는다) |
| 최근 검색어 좁히기 | 입력과 일치하는 것만 남는다 / 입력이 비면 전부 / 대소문자를 무시한다 / 저장소는 바뀌지 않는다 |

시계는 `clockProvider`를 고정 시각으로 갈아끼워 조작한다. 관측 가능한 결과(가짜 Repository의 조회 횟수, 목록 내용)를 단언하고 호출 기록만을 유일한 단언으로 삼지 않는다.

## 미해결

- 3분은 첫 값이다. 실사용에서 "돌아올 때마다 새로 받는 느낌"이거나 반대로 "여전히 낡다"면 조정한다.
- 목록을 보고 있는 동안에는 갱신되지 않는다. 화면에 머문 채 3분이 지나도 당기기 전까지는 그대로다. 이번 범위에서는 다루지 않는다 — 보고 있는 화면이 스스로 바뀌는 것은 별개의 UX 결정이다.
- `currentBranchIndexProvider`는 커뮤니티만 쓴다. 다른 탭이 같은 신호를 필요로 하면 그때 쓰임새가 늘어난다.
