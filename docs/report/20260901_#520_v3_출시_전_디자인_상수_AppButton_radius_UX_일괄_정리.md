# v3 출시 전 디자인 상수·AppButton·radius·UX 일괄 정리 (#520)

### 📌 작업 개요

v3 전면 개편(#470) 출시 전 최종 점검. 디자인 상수와 공용 버튼·다이얼로그의 기본값을
실사용 분포에 맞춰 바로잡고, 그로 인해 불필요해진 호출부 오버라이드를 걷어냈다.
작업 중 발견한 역할 테마(도둑=다크) 잔존 버그를 함께 수정했다.

브랜치 `20260831_#520_v3_출시_전_디자인_상수_AppButton_radius_UX_일괄_정리`,
base `20260812_#470_v3_앱_전면_개편` 위 12커밋.

### 🎯 구현 목표

1. `AppColors`·`AppTextStyles`·`AppRadius` 등 디자인 상수 정리
2. `AppButton` 색상 점검·통일
3. radius 값 통일
4. 화면을 순회하며 발견되는 UX 개선

### ✅ 구현 내용

#### 1. AppButton 기본값 변경과 호출부 중복 제거

- **파일**: `lib/core/widgets/buttons/app_button.dart` 외 31파일 (+32 / −118)
- **변경 내용**: 기본값을 배경 `AppColors.blue`(#0088FF) · radius `AppRadius.large`(12) ·
  `showBorder: false`로 변경. 그 결과 중복이 된 오버라이드 67개를 28파일에서 제거
- **이유**: 기본값을 바꾸기 전 호출부를 전수 조사(괄호 매칭 파싱, 57곳 중 테스트 페이지
  제외 44곳)한 결과가 **기본값이 틀렸음**을 가리켰다

| 항목 | 이전 기본값 | 실사용 분포 | 이후 기본값 |
|---|---|---|---|
| 배경 | `black` | `AppColors.blue`를 9곳이 명시, 다크 분기 4곳 | `blue` |
| radius | `xlarge`(16) | 다이얼로그 버튼은 이미 `large`(12) | `large`(12) |
| `showBorder` | `true` | **46곳 중 45곳이 `false`를 명시** | `false` |
| 텍스트 | `label_16` | — | 변동 없음 |

radius 명시 17곳 중 `medium`(8) 7곳·`large`(12) 6곳·`xlarge`(16) 2곳을 기본값 12로 흡수.
모양이 실제로 다른 2곳만 남겼다 — 커뮤니티 정렬 칩(`pill`), 채팅 초대 카드 버튼(`6.r`).

라이트 기본 CTA가 아직 `black`이던 `text_submit_page.dart`도 `blue`로 맞췄다
(`isDestructive`는 `red` 유지).

**특이사항**:
- 테두리가 필요한 2곳에는 `showBorder: true`를 명시했다. 그중
  `community_chat_room_info_page.dart`는 `borderColor`만 주고 기본값에 기대던 곳이라,
  잡지 않았으면 테두리가 조용히 사라진다
- 기본값에 기대 테두리를 그리던 3곳(커뮤니티 채팅방 재시도, 채팅방 목록 액션,
  로그아웃)에서는 `black100` 1px 테두리가 **의도적으로** 사라진다

#### 2. 다이얼로그 패딩 원복과 버튼 기본값 위임

- **파일**: `lib/core/widgets/dialogs/app_dialog.dart`
- **변경 내용**: 내부 패딩을 균일 14에서 상 24 / 좌우 12 / 하 16으로 되돌리고, 확인 버튼
  라이트 기본색을 `black` → `blue`로. 버튼에 명시돼 있던 `borderRadius`·`showBorder`를
  지워 `AppButton` 기본값에 위임
- **이유**: 다이얼로그가 자체 스타일을 들고 있으면 공용 버튼 기본값이 바뀔 때 갈린다

호출부의 `confirmColor: isDarkMode ? null : AppColors.blue` 5곳도 함께 제거했다. 남은
`confirmTextColor: white` 3곳은 중복이 아니다 — `isDestructive` + 다크 조합에서 red 배경
위에 검은 글씨가 되는 것을 막는다. 다크 기본값(green/black)은 그대로다.

#### 3. 초대 카드 참가 확인 다이얼로그를 AppDialog 슬롯 패턴으로

- **파일**: `lib/features/community/presentation/widgets/community_chat_invite_card.dart` (−31 / +14)
- **변경 내용**: `customContent` 안에 제목·본문·방 코드를 직접 그리던 것을
  `title:` / `customContent:` 슬롯으로 이전. 캡션 `tag_12`/`black300`, 본문
  `paragraph_14`/`black`, 방 코드 `paragraph_14`/`black600`
- **이유**: 이 다이얼로그만 제목이 다른 다이얼로그와 다르게 보였다

#### 4. 역할 테마 잔존 버그 수정

- **파일**: `role_theme_provider.dart`, `waiting_room_page.dart`,
  `setup_playground_page.dart`, `setup_prison_page.dart`, `app_router.dart`
- **문제**: 도둑으로 한 판 하고 대기방을 나온 뒤 게임을 다시 만들면 생성 화면이 다크로 떴다
- **원인**: 두 결함이 겹쳐야 재현된다
  1. `roleThemeProvider`가 `gameParticipantNotifierProvider.team`의 **수동 미러**였다.
     쓰기는 `waiting_room_page` 4곳뿐인데 원본을 비우는 `clear()`는 9곳이라, 미러가
     원본의 소멸을 따라가지 못했다. `keepAlive: true`라 폐기되지도 않는다
  2. 구역 설정 화면의 다크 판정이 `_isEditMode`(= 초기 도형을 받았나)에 걸려 있었는데,
     라우터가 **생성 흐름 라우트에도 같은 인자를 꽂는다**. 생성 흐름도 되돌아올 때 초기
     도형을 넘기고, 감옥은 `PrisonEditArgs`를 첫 진입부터 항상 넘긴다
- **해결**: 미러를 없애고 참가 정보에서 파생시켰다. 다크 판정은 진입 라우트가 내려주는
  `isInGameEdit`(기본 `false`)으로 옮겼다

```dart
@Riverpod(keepAlive: true)
bool roleTheme(Ref ref) {
  final info = ref.watch(gameParticipantNotifierProvider);
  return GameTeam.isRobber(info?.team);
}
```

퇴장 경로마다 리셋을 심지 않았다 — 이미 있는 `clear()` 9곳이 원본을 비우므로 테마가
자동으로 따라온다. 이 한 변경으로 `AppLoading` 오염 7곳(게임 생성·홈 방참가·마이페이지
3종·모집글 등록·버그 제보)이 함께 닫혔다. `AppLoading`이 불투명 풀스크린 배리어를
깔면서 진입 시 `roleThemeProvider`를 직접 읽기 때문이다.

코드 리뷰에서 `_handleNotParticipating`(404 안내 → 홈)이 참가 정보를 비우지 않는 유일한
경로임이 발견돼, 대기방 퇴장 4경로를 `_goHomeClearingSession()` 하나로 모았다. 이제
이 파일에서 `RoutePaths.home`은 그 헬퍼 안에만 존재한다.

`_isEditMode`는 `_hasInitialShape`로 이름을 바꾸고 "편집 모드" 문구를 전부 걷었다.
같은 오해가 이 버그를 만들었다.

#### 5. 기타 UX 개선

- **채팅방 목록 탭으로 키보드 내리기** — 모집글 상세와 같은 패턴으로 메시지 목록을
  `GestureDetector(translucent)`로 감싸 빈 곳 탭에 `unfocus`
- **홈 상단바를 공용 AppTopBar로 교체** (+82 / −127) — 높이 125 커스텀 `HomeHeader`를
  걷어내 툴바 높이를 커뮤니티·마이페이지와 같은 56으로. 탭 전환 시 우측 공지 아이콘이
  세로로 64px 튀던 문제 해소(아이콘 세로 중심 92 → 28). 참조가 사라진 `home_header.dart` 삭제
- **상단바 액션 아이콘 우측 여백 16 통일** — 커뮤니티 18→16, 검색 20→16. `SizedBox`
  값만으로는 맞지 않는다. `IconButton` 최소 폭 48에서 왼쪽 패딩과 아이콘 24의 합이
  모자라면 그만큼 좌우로 나뉘어 붙으므로, 왼쪽 패딩을 24로 올려 합을 정확히 48로 맞췄다.
  탭 영역 48×48은 유지(#171)

### 🧪 테스트 및 검증

- `flutter analyze` 0건
- `flutter test` **1088개 전부 통과** (브랜치 시작 시점 1079 → 신규 회귀 테스트 9개)
- 신규 테스트 3파일
  - `test/core/widgets/buttons/app_button_defaults_test.dart` (2) — 배경 blue·radius 12·
    테두리 없음, 다이얼로그 라이트 확인 버튼 blue
  - `test/core/theme/role_theme_derives_from_participant_test.dart` (3) — 참가 없음→라이트 /
    도둑→다크·경찰→라이트 / 도둑 참가 후 `clear()`→라이트
  - `test/features/session/presentation/pages/setup_pages_dark_only_in_game_test.dart` (4) —
    도둑으로 참가 중인 상태에서 생성 흐름 2화면은 라이트, 대기방 수정 2화면은 다크
- 세 파일 모두 수정을 되돌리면 실패하는 것을 실행으로 확인
- 역할 테마 수정은 별도 코드 리뷰를 거쳤다 — Critical 0건, Important 2건 중 1건은 코드로
  반영, 1건(불변식 테스트 추가)은 저장소에 선례가 없어 구조 통합으로 대체

### 📌 참고사항

- **시각 변화 범위가 넓다.** 공용 버튼·다이얼로그 기본값 변경이라 명시 오버라이드가 없던
  호출부는 자동으로 새 스펙을 따른다. 리뷰 시 스크린샷 대조 권장
- **미착수(후속 후보)**: `AppRadius`를 안 거치는 원시 `BorderRadius.circular(N)` 27곳.
  9곳은 토큰이 있는데 숫자로 재작성한 것(8·12·16·20)이라 무손실 치환 가능. 나머지
  18곳(2·4·6·9·10)은 값 자체를 정해야 하고, 특히 **10은 7곳 전부 채팅 말풍선 계열**로
  꼬리 쪽만 0인 비대칭이라 토큰으로 못 옮긴다 — `AppRadius.chatBubble(isMe)` 같은 헬퍼가
  필요하고 값 10을 12로 올릴지는 디자인 판단 사항
- `game_page.dart`의 더미 모드 퇴장이 세션 상태를 비우지 않는다 (개발 전용 경로, 미수정)
- 초대 다이얼로그에서 닉네임만 굵게 하는 안은 구현 후 철회했다. 로케일마다 조사·어순이
  달라 전용 분할 로직이 필요한데, 앱 전체에 한 문장 안의 일부만 굵게 하는 선례가 없다
