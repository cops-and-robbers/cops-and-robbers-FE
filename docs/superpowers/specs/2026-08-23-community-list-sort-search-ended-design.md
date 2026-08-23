# 커뮤니티 목록 정렬·검색 추가 및 변경된 API 연동 설계 (#478)

## 배경

백엔드 스웨거가 `v2.18.0 → v2.21.0`으로 올랐다. 엔드포인트 4개가 추가됐는데 전부 커뮤니티
채팅(BE #162)이라 이 작업에서는 다루지 않는다. 채팅을 뺀 변경은 셋이다.

| 변경 | 내용 | 앱 영향 |
|---|---|---|
| `CommunityPostResponse.status` | `ENDED` 추가 | 파싱이 깨진다 — 아래 1절 |
| `GET /api/community-posts` | `sort` 확장 + `keyword`·`latitude`·`longitude` 추가 | 정렬·검색 연동 |
| `LocationResponse.address` | 복사용 지번 주소 추가 | 코드 변경 없음 — 주석만 |

근거 문서는 브레인 볼트의 DOC-0036(커뮤니티 목록 정렬·검색·`ENDED`·QueryDSL, BE #166)이고,
확정된 결정은 DEC-0028(`ENDED` 조회 시점 판정)·DEC-0021(목록은 DB만·거리순 좌표 조항)·
DEC-0020(미구현 enum 400)·DEC-0016(목록 MVP)이다.

### 백엔드 계약 (v2.21.0)

```
GET /api/community-posts
  ?countryCode=KR                       (필수)
  &sort=LATEST|DEADLINE|DISTANCE        (POPULAR는 400 UNSUPPORTED_LIST_SORT)
  &keyword=서울                          (제목·placeName·region, 공백 제거 2자 이상 — 미만은 400)
  &latitude=&longitude=                 (sort=DISTANCE 일 때만 필수 — 그 외 정렬에서 보내면 400)
  &cursor=&size=

정렬 = 1차 마감 여부(모집중 먼저) · 2차 선택한 정렬
커서 = 국가·정렬·검색어가 봉인돼 있어, 요청과 하나라도 다르면 400 INVALID_QUERY_PARAMETER
허용 파라미터 8개 — 그 밖의 이름은 전역 400 (DEC-0020)
```

`scope`는 여전히 `ALL`만 동작한다(`NEARBY`·`MINE` 400).

## 목표

1. `ENDED` 상태를 연동하고, 앱이 모르는 상태값이 와도 화면이 깨지지 않게 한다.
2. 정렬 3종(최신순·마감 임박순·거리순)을 서버에 실제로 연결한다 — 지금은 라벨만 바뀐다.
3. 모집글 검색 화면을 신설한다.
4. `address` 관련 "백엔드 추가 예정" 주석을 사실과 맞춘다.

## 범위 제외

- 커뮤니티 채팅 4종 엔드포인트 — 별도 작업.
- 로그인 `Accept-Language`로 신규 회원 닉네임 언어 결정(DEC-0024) — 영역이 달라 별도 이슈.
- `POPULAR` 정렬, `NEARBY`·`MINE` 범위 — 서버 미지원.

---

## 1. `ENDED` — 왜 이것부터인가

서버는 `ENDED`를 **저장하지 않고 조회 시점에 판정**한다(DEC-0028). `meetingAt < now`면 `ENDED`이고,
**날짜가 작성자 마감보다 우선**한다 — `COMPLETED`로 저장돼 있어도 날짜가 지나면 `ENDED`로 내려온다.

현재 앱은 이 값에서 예외를 던진다. 응답 경계까지 추적한 경로는 다음과 같다.

```
communityPostStatusFromWire('ENDED')   → FormatException
  → _toEntity (community_repository_impl.dart)
  → _guard 의 catch-all           → ServerException
  → CommunityFeedNotifier         → AsyncError
  → community_page.dart _buildBody 의 error: 분기
  → 목록이 통째로 사라지고 에러 플레이스홀더
```

중간 계층 어디에도 폴백이 없다. 상세 화면도 같은 경로다.

**심각도.** 스토어 배포본(v2.4.11)에는 커뮤니티 기능 자체가 없다 — `main`에 라우트도
`features/community/` 파일도 0건이다. 따라서 이것은 스토어 클라이언트 호환 문제가 아니고
(LSN-0002 시나리오 아님), 서버에 이중 지원을 요청할 필요도 없다. 깨지는 대상은 **dev 서버를 보는
v3 개발 브랜치**다. 다만 BE dev는 그대로 prod로 올라가므로, v3 출시 전에 반드시 들어가야 한다.

**발생 빈도.** 마감·종료 글은 정렬과 무관하게 목록 맨 뒤로 가므로(DEC-0028) `ENDED`는 목록 끝에
몰린다. 전체 글이 `_pageSize`(20) 이하면 첫 페이지에서 즉시 깨지고, 그보다 많으면 끝까지 스크롤해야
깨진다. dev 서버의 실제 글 수는 확인하지 않았다. 상세는 해당 글을 직접 열면 즉시 깨진다.

### 1.1 알 수 없는 값은 마감으로 본다

지금 폴백을 두지 않는 근거는 주석에 *"마감된 글이 모집중으로 보이면 사용자가 끝난 모임에 참여를
시도하므로"*라고 적혀 있다. **`completed` 폴백은 그 취지를 그대로 지키면서** 다음 번 enum 추가 때
같은 사고를 막는다. 모르는 상태는 참여할 수 없는 것으로 보수적으로 취급한다.

```dart
CommunityPostStatus communityPostStatusFromWire(String wire) => switch (wire) {
  'RECRUITING' => CommunityPostStatus.recruiting,
  'COMPLETED' => CommunityPostStatus.completed,
  'ENDED' => CommunityPostStatus.ended,
  // 모르는 값은 '마감'으로 본다 — 모집중으로 보여 끝난 모임에 참여를 시도하게 두느니
  // 보수적으로 막는다. ENDED 추가 때 목록 전체가 에러 화면이 된 전례가 있다.
  _ => CommunityPostStatus.completed,
};
```

`CommunityPostStatus`에 `ended`를 추가한다. `wireValue`(`PATCH /status` 전송용)는 switch를 total로
두기 위해 `ended => 'ENDED'`까지 매핑한다 — 요청 스키마에도 `ENDED`가 있어 유효한 값이지만,
호출부가 종료된 글의 상태 변경을 막으므로 실제로 전송되지는 않는다.

## 2. 상태 표기 — 공통 위젯으로 뽑지 않는다

배지 매핑의 실사용처를 전수 조사했다.

| 위치 | 형태 |
|---|---|
| `community_post_card.dart` `_StatusChip` | 위젯 |
| `community_detail_page.dart` `_buildHeader` | 인라인 |

**2곳뿐이다.** LSN-0001("공유량이 얇고 실사용처가 3곳 미만이면 보류")에 걸리므로 추출하지 않고
두 곳에 각각 3분기를 넣는다. 대신 양쪽에 재검토 트리거를 주석으로 남긴다 — 세 번째 사용처가
생기면 그때 뽑는다. 그래야 이후 DRY 리팩토링에서 이 중복이 "정리 안 된 것"으로 오해받지 않는다.

표기 규칙:

| 상태 | 라벨 | 칩 색 | 카드 흐림 |
|---|---|---|---|
| `recruiting` | 모집중 | `AppColors.logo` | 없음 |
| `completed` | 마감 | `AppColors.black300` | 0.6 |
| `ended` | 종료 | `AppColors.black300` | 0.6 |

카드 흐림 조건은 `isCompleted`에서 `post.status != CommunityPostStatus.recruiting`으로 바꾼다.

`community_post_menu.dart`는 `ended`일 때 모집 상태 변경 항목 자체를 감춘다 — 서버가 무엇을 받든
조회 시 `ENDED`를 돌려주므로 눌러도 아무 변화가 없고, 사용자 눈에는 버그로 보인다.
`toggleStatus`(`community_provider.dart`·`community_detail_provider.dart` 2곳)도 `ended`면 호출하지
않는다.

## 3. 목록 상태 구조 — family 키를 셋으로

커서에 국가·정렬·검색어가 봉인돼 있어 셋 중 하나라도 바뀌면 커서를 재사용할 수 없다.
즉 "조건이 바뀌면 첫 페이지부터"가 서버 계약으로 강제된다.

```dart
@riverpod                       // ← @Riverpod(keepAlive: true) 에서 변경
class CommunityFeedNotifier extends _$CommunityFeedNotifier {
  @override
  FutureOr<CommunityFeedState> build(
    CommunityScope scope,
    CommunitySortOption sort,
    String? keyword,            // null = 목록, 값 있음 = 검색 결과
  ) async {
    // 목록은 살려 둔다 — 스코프·정렬을 오갈 때 /country와 GPS를 다시 태우지 않기 위해
    // (기존 keepAlive 근거 그대로). 검색은 자유 텍스트라 인스턴스가 무한히 늘어나므로
    // 화면을 나가면 폐기되게 둔다.
    if (keyword == null) ref.keepAlive();
    ...
  }
}
```

조건이 바뀌면 키가 바뀌어 **새 인스턴스가 커서 없이 첫 페이지를 부른다.** 리셋 로직이 따로 없고,
커서 불일치 400이 구조적으로 발생할 수 없다. 기존 스코프 전환이 이미 이 방식이라 새 개념이 없고,
목록과 검색이 무한 스크롤·에러·낙관적 갱신 로직을 한 벌만 쓴다.

검토했다가 버린 안:

- **정렬을 Notifier 내부 상태 + `changeSort()`** — `SelectedCommunitySort`와 진실 소스가 둘이 되고
  정렬 왕복 캐시를 잃는다. 얻는 것이 없다.
- **검색 전용 Notifier 신설** — `loadMore`·`replacePost`·`removePost`가 통째로 복제된다.

정렬 선택은 목록·검색이 `SelectedCommunitySort` 하나를 공유한다. "마감 임박순으로 보고 싶다"는
화면에 따라 달라지는 선호가 아니다.

### 3.1 거리순 좌표는 상태에 담아 재사용한다

`CommunityFeedState`에 `latitude`·`longitude`(nullable)를 추가한다. `build()`에서 한 번 구하고
`loadMore`가 그 값을 그대로 쓴다 — 페이지를 넘길 때마다 GPS를 켜지 않기 위해서다. 서버가 커서에
좌표를 일부러 담지 않았으므로(사용자가 이동해도 커서가 막히지 않게) 이렇게 해도 계약에 어긋나지
않는다. 이동 반영은 당겨서 새로고침이 담당한다.

### 3.2 권한을 새로 얻으면 국가 코드를 다시 판정한다

DEC-0021은 *"위치 권한을 거부한 사용자는 기기 국가 코드를 보낸다"*고 정했고 현재 구현도 그렇다.
그런데 권한이 없던 사용자가 거리순을 고르며 권한을 새로 허용하면,
`communityCountryCodeProvider`에는 여전히 기기 로케일 폴백값이 남는다. 해외에 있는 한국 로케일
사용자라면 `countryCode=KR` 목록을 현지 좌표로 거리순 정렬하게 된다.

→ 권한 확보에 성공하면 `ref.invalidate(communityCountryCodeProvider)`. 좌표가 생겼으니 `/country`로
다시 판정하고 목록도 그 국가로 새로 뜬다.

## 4. 데이터 계층

```dart
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

null인 값은 Retrofit이 생성한 `removeWhere`가 빼므로 "안 보냄"이 그대로 표현된다.

`community_wire.dart`에 `CommunitySortOption.wireValue` 확장을 추가한다. 네 값을 모두 매핑하되
(`popular => 'POPULAR'`) 정렬 시트가 인기순을 노출하지 않으므로 그 값은 전송되지 않는다 —
서버가 400을 주는 값이라 앱이 먼저 막는다.

**Repository가 `sort == distance`일 때만 좌표를 넘긴다.** 다른 정렬에서 좌표를 보내면 400이다
(DEC-0021 조항 주석 — #166이 거리순에 한해 되돌린 부분).

`address`는 DTO·Entity·`_copyLocation`이 이미 전부 준비돼 있어 **코드 변경이 없다.** "백엔드 추가
예정"으로 남은 주석 3곳만 고친다 — `community_post_model.dart`, `community_post_entity.dart`,
`community_detail_page.dart`.

## 5. 정렬

`CommunitySortSheet._order`에서 `popular`를 뺀다. **enum 값 자체는 남긴다** — DEC-0020이
"정책이 정해지면 앱 수정 없이 서버의 400 분기만 걷어내면 되게" 파라미터를 먼저 열어 둔 구조라,
앱도 값을 지우지 않고 노출만 막는 쪽이 그 설계와 맞는다.

거리순 선택 흐름은 **UI 계층에서 권한을 먼저 확보하고, 성공했을 때만** 정렬을 바꾼다.

```
정렬 시트에서 거리순 선택
  → LocationPermissionService.ensurePermission()
      성공  → invalidate(communityCountryCodeProvider) → select(distance)
      거부  → 스낵바 안내, 이전 정렬 유지
      영구거부 → "설정에서 위치 권한을 켜주세요" 안내, 이전 정렬 유지
```

이렇게 하면 Notifier는 "거리순이면 좌표가 있다"를 전제할 수 있고, provider 안에서 권한 팝업이 뜨는
구조를 피한다. 영구 거부를 따로 가르는 이유는 안드로이드가 2회 거부 후 팝업을 띄우지 않아 같은
문구를 반복해도 아무 일도 일어나지 않기 때문이다.

이것은 차단 게이트가 아니다(LSN-0006) — 목록은 권한 없이 계속 보이고, 거부해도 이전 정렬로 쓴다.
거리순은 좌표가 있어야 성립하는 기능 자체의 조건이다.

## 6. 검색 화면

**라우트는 `/community/search`이며 `/community/:postId`보다 먼저 등록해야 한다.** 나중에 두면
`search`가 `postId`로 잡힌다 — `route_paths.dart`에 `create`에 대해 같은 주의가 이미 적혀 있다.

화면은 상태가 둘이다.

```
입력 중        → 최근 검색어 목록 (개별 ✕ · 모두 삭제)
검색 실행 후   → 결과 목록 + 정렬 라벨
```

실행된 검색어만 state로 들고 family 키에 넘긴다. 타이핑마다 요청하지 않는 백엔드 지침
(`LIKE '%키워드%'`라 인덱스를 타지 못한다)이 구조로 강제된다.

**검증**: 공백을 전부 제거한 뒤 2자 이상. 미만이면 스낵바로 선차단해 확정 400을 왕복시키지 않는다.
백엔드와 같은 규칙(`replaceAll(RegExp(r'\s'), '')`)으로 길이를 재고, **서버에는 원문을 그대로**
보낸다 — 정규화는 백엔드 몫이고, 커서의 검색어 해시도 서버가 만든다.

**최근 검색어**: `community_recent_keyword_storage.dart`(data/datasources), SharedPreferences 키
`community_recent_keywords`, 최대 10개, 중복은 맨 앞으로 끌어올린다. 로컬 저장이고 남에게 노출되지
않으므로 UGC 안전장치(LSN-0012) 대상이 아니다.

## 7. 공용 무한 스크롤 목록 위젯

검색 결과도 무한 스크롤·`loadMore`·에러 스낵바·당겨서 새로고침이 필요해 목록 화면의 리스트부와
겹친다. `CommunityFeedList`로 추출한다.

2절에서 배지 추출을 보류한 것과 결론이 반대인데, 근거가 다르다. LSN-0001의 보류 조건은
*"공유량이 얇고 3곳 미만"*인데 여기는 스크롤 리스너·임계값·`loadMore`·에러 처리·새로고침까지
묶여 얇지 않고, 두 사용처의 동작 유형이 '읽기전용 무한 스크롤'로 동일해 규칙 1(동작이 다르면 통합
금지)에도 걸리지 않는다. 배지는 10줄·2곳이라 배관 비용이 절감을 넘어선다.

## 8. 에러 처리

| 서버 응답 | 앱 대응 |
|---|---|
| 커서 불일치 400 | 구조적으로 불가 — 조건이 바뀌면 family 키가 바뀌어 커서 없이 시작 |
| 검색어 2자 미만 400 | 앱에서 선차단 |
| `UNSUPPORTED_LIST_SORT` | 시트에서 인기순을 감춰 도달 불가 |
| 비거리순 좌표 400 | Repository가 `sort == distance`일 때만 실음 |
| 알 수 없는 `status` | 조용히 `completed` + `debugPrint` 경고 |

위치 권한은 거부·영구거부 2종 스낵바로 가른다.

## 9. 신규 ARB

| 키 | ko |
|---|---|
| `communityStatusEnded` | 종료 |
| `communitySearchHint` | 제목, 장소를 검색해보세요 |
| `communitySearchRecent` | 최근 검색어 |
| `communitySearchClearAll` | 모두 삭제 |
| `communitySearchEmpty` | 검색 결과가 없어요 |
| `communitySearchTooShort` | 두 글자 이상 입력해주세요 |
| `communitySortNeedsLocation` | 위치 권한이 있어야 거리순으로 볼 수 있어요 |
| `communitySortLocationDenied` | 설정에서 위치 권한을 켜주세요 |

ko/en/ja 3개 파일에 넣고 `flutter gen-l10n` 후 `python3 docs/i18n/_lint_tone.py`로 톤을 검사한다.

## 10. 파일

**신규**

- `lib/features/community/presentation/pages/community_search_page.dart`
- `lib/features/community/presentation/widgets/community_feed_list.dart`
- `lib/features/community/data/datasources/community_recent_keyword_storage.dart`

**수정**

- `domain/entities/community_post_status.dart` — `ended` 추가
- `domain/entities/community_sort_option.dart` — 주석 갱신
- `data/models/community_wire.dart` — `ENDED` 매핑·폴백, `CommunitySortOption.wireValue`
- `data/models/community_post_model.dart` — `address` 주석
- `data/datasources/community_remote_datasource.dart` — 쿼리 4개
- `data/repositories/community_repository_impl.dart` — 정렬·검색어·좌표 전달
- `domain/repositories/community_repository.dart` — 인터페이스
- `presentation/providers/community_provider.dart` — family 인자 3개, 조건부 `keepAlive`
- `presentation/providers/community_feed_state.dart` — 좌표 필드
- `presentation/providers/community_detail_provider.dart` — `ended` 토글 차단
- `presentation/pages/community_page.dart` — 검색 진입, 리스트 위젯 교체, 정렬 연결
- `presentation/pages/community_detail_page.dart` — 배지 3분기, `address` 주석
- `presentation/widgets/community_post_card.dart` — 배지 3분기, 흐림 조건
- `presentation/widgets/community_post_menu.dart` — `ended` 항목 숨김
- `presentation/widgets/community_sort_sheet.dart` — 인기순 제외
- `lib/router/route_paths.dart` · 라우터 — 검색 라우트(상세보다 먼저)
- `lib/l10n/app_{ko,en,ja}.arb`

빌드 순서: `dart run build_runner build --delete-conflicting-outputs` → `flutter gen-l10n` →
`flutter test && flutter analyze`.

## 11. 테스트

| 파일 | 확인할 동작 |
|---|---|
| `community_wire_test.dart` | `ENDED` 매핑 / 미지원 값이 `completed`로 폴백된다 |
| `community_repository_impl_test.dart` | 거리순에만 좌표를 싣는다 / 비거리순엔 싣지 않는다 / 검색어를 전달한다 |
| `community_feed_notifier_test.dart` | 정렬이 바뀌면 커서 없이 첫 페이지를 부른다 / `loadMore`가 같은 좌표를 재사용한다 |
| `community_post_card_test.dart` | 종료 배지 라벨과 흐림 처리 |
| `community_recent_keyword_storage_test.dart` (신규) | 중복이 맨 앞으로 온다 / 10개를 넘지 않는다 |
| `community_search_page_test.dart` (신규) | 2자 미만이면 조회하지 않는다 / 검색 실행 시 최근 검색어에 남는다 |

`.claude/rules/Agents.md`에 따라 시스템 경계(Dio·SharedPreferences·GPS)만 가짜로 두고 나머지는
실제 객체를 쓴다. 기존 `community_fakes.dart`를 확장한다.

## 미해결

- dev 서버의 실제 모집글 수를 확인하지 않아, `ENDED` 파싱 실패가 첫 페이지에서 바로 나는지
  마지막 페이지에서 나는지 단정하지 못했다.
- 거리순 정렬 중 사용자가 크게 이동했을 때 좌표를 언제 갱신할지 — 지금은 당겨서 새로고침 뿐이다.
- 인기순 산식은 백엔드 이슈 #165가 시작점만 남겼다(`(좋아요 + 스크랩×2 + 참여×3) / (경과시간 + 2)^1.5`).
  좋아요·스크랩 테이블이 생긴 뒤에 다시 본다.
- 검색 결과가 없을 때 추천 검색어를 줄지 — 이번 범위에서는 빈 상태 문구만 둔다.
