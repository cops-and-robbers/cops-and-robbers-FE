---
name: ui-design-system
description: UI 디자인 시스템 — AppColors/AppTextStyles/AppSpacing/AppRadius/AppShadows 토큰 값과 사용 규칙, 경찰(라이트)/도둑(다크) 팀 테마 isDarkMode 전파 패턴, 금지 사항. 위젯 작성·수정 시 사용.
---

# UI 디자인 시스템 가이드 (UI Design System Guide)

> **작성일**: 2026-04-15 (최종 갱신 2026-09-28 — 상수 파일 실측 반영)
> **대상 독자**: 개발자, 신규 팀원, 디자이너
> **문서 버전**: 1.1.0
> **범위**: cops_and_robbers 프로젝트의 컬러·타이포·테마·스페이싱·래디우스·쉐도우 사용 규칙

---

## 📋 목차

1. [개요](#개요)
2. [테마 철학: 경찰/도둑 팀 테마](#1-테마-철학-경찰도둑-팀-테마)
3. [컬러 시스템 (AppColors)](#2-컬러-시스템-appcolors)
4. [타이포그래피 (AppTextStyles)](#3-타이포그래피-apptextstyles)
5. [Spacing, Radius & Shadow](#4-spacing-radius--shadow)
6. [팀 테마 (Role Theme) 사용 패턴](#5-팀-테마-role-theme-사용-패턴)
7. [Theme.of(context) vs AppColors](#6-themeofcontext-vs-appcolors)
8. [금지 사항 & 안티패턴](#7-금지-사항--안티패턴)
9. [체크리스트](#8-체크리스트)
10. [리팩토링 TODO](#9-리팩토링-todo)

---

## 개요

이 문서는 `cops_and_robbers` 프로젝트에서 **실제로 사용 중인** UI 디자인 시스템 규칙을 정리합니다.
본 문서의 규칙은 "더 나은 방식"이 아닌 **현재 코드베이스의 일관성 유지**를 최우선으로 합니다.

### 핵심 원칙

- ✅ **일관성 > 베스트 프랙티스** — 기존 패턴 100% 준수
- ✅ **AppColors 상수만 사용** — `Color(0xFF...)` 하드코딩 금지
- ✅ **AppTextStyles만 사용** — `TextStyle()` 직접 생성 금지, weight/fontSize 임의 조절 금지
- ✅ **팀 테마 = 경찰(라이트) / 도둑(다크)** — 시스템 테마가 아닌 도메인 테마
- ✅ **ScreenUtil 필수** — `.w/.h/.r/.sp` 생략 금지

---

## 1. 테마 철학: 경찰/도둑 팀 테마

이 앱의 다크/라이트 모드는 **시스템 설정이 아닌 팀 역할**에 따라 전환됩니다.

| 팀 | 테마 | 기본 배경 | 기본 텍스트 | 타입페이스 |
| --- | --- | --- | --- | --- |
| **경찰 (POLICE)** | 라이트 모드 | `AppColors.white` | `AppColors.black` 계열 | Pretendard |
| **도둑 (ROBBER)** | 다크 모드 | `AppColors.black` | `AppColors.white` 계열 | Pretendard + Moneygraphy |

### 왜 시스템 다크모드를 쓰지 않는가?

- 게임 몰입감: 팀이 결정되는 순간(대기실 입장) 즉시 UI가 전환되어야 함
- 앱 시작 시점에는 항상 라이트 모드(경찰 기본값)
- `MaterialApp`의 `darkTheme` / `ThemeMode.system`을 **사용하지 않음**

> 사용자 단말의 다크모드 설정과 무관하게 동작합니다. 이는 의도된 설계입니다.

---

## 2. 컬러 시스템 (AppColors)

### 2.1 파일 위치

`lib/core/constants/app_colors.dart`

### 2.2 팔레트 구조

**Brightness-agnostic 단일 팔레트** — light/dark 분리 없이 동일한 상수를 양 테마에서 사용합니다.

값은 `app_colors.dart`가 정본이다. 아래는 2026-09-28 기준 전체 목록이다.

| 계열 | 상수 = HEX |
| --- | --- |
| 기본 | `white` #FFFFFF · `black` #080A0C (순흑 아님) · `transparent` #00000000 · `background` #F4FAFF (연한 하늘색) |
| 흑백 (숫자 클수록 어두움) | `black100` #EDF0F2 · `black200` #CFD6DD · `black300` #B1BCC8 · `black400` #93A2B3 · `black500` #76899E · `black600` #5D6F83 · `black700` #485665 · `black800` #333D48 · `black900` #1E232A |
| 슬레이트 (웹 톤, SNS 칩 전용) | `slate100` #F1F5F9 · `slate500` #64748B |
| 초록 (도둑 강조) | `green` #38F55B · `green800` #7AF391 · `green500` #ACF8BA · `green100` #EFFEF2 |
| 파랑 (경찰 강조) | `blue` #0088FF · `blue800` #6582E1 · `blue500` #9FB1EC · `blue100` #ECF0FC |
| 파랑 ver2 (v3 개편) | `logo` #4D63FF · `blueVer2Strong` #2264FF · `blueVer2Basic` #339DFF · `blueVer2Rich` #69B6FF · `blueVer2Vague` #C4E3FF · `blueVer2_70` #D3EAFF · `blueVer2_50` #E7F4FF |
| 빨강 | `red` #FF383C · `red900` #E64C4F · `red800` #E76062 · `red500` #FA9C9E · `red100` #FEECEC |
| 노랑 | `yellow` #FFCC00 · `yellow900` #F7F260 |
| 진한 초록 | `deepGreen` #00CE75 · `deepGreen900` #33D890 |
| 투명도 내장 | `blue500Alpha20` · `red500Alpha20` · `yellowAlpha20` (각 20%) · `blackAlpha60` / `blackAlpha0` (창살 오버레이 그라데이션 양 끝) |

### 2.3 컬러 사용 규칙

#### ✅ 규칙 1: AppColors 상수만 참조

```dart
// ✅ 올바른 예
Container(color: AppColors.white)
Icon(Icons.check, color: AppColors.blue500)
BoxDecoration(color: AppColors.blue100)
// 텍스트는 AppTextStyles를 기반으로 색상만 override (§2.3의 AppTextStyles 원칙 준수)
Text('안녕', style: AppTextStyles.paragraph_14.copyWith(color: AppColors.black600))

// ❌ 잘못된 예
Container(color: Color(0xFFFFFFFF))           // 하드코딩 금지
Container(color: Colors.white)                 // Material 기본 색상 금지
Text('안녕', style: TextStyle(color: AppColors.black600))  // TextStyle 직접 생성 금지
Text('안녕', style: TextStyle(color: Color(0xFF4A90E2)))  // HEX + TextStyle 직접 생성 금지
```

#### ✅ 규칙 2: 투명도는 흑백 계열 상수로 대체

`withOpacity()`, `withValues(alpha:)` **사용 금지**. 투명도가 필요한 경우 이미 정의된 `black100 ~ black900` 또는 `white` 계열 상수, 투명도 내장 상수(`blue500Alpha20` 등), `AppColors.transparent`(`Colors.transparent` 대신)를 선택하세요. 다이얼로그 배리어는 `DialogAnimation.barrierColor`(black 50%)를 쓴다.

```dart
// ❌ 잘못된 예
Container(color: AppColors.black.withOpacity(0.4))
Container(color: AppColors.white.withValues(alpha: 0.8))

// ✅ 올바른 예 — 적절한 명도의 상수 선택
Container(color: AppColors.black400)  // 회색 배경이 필요한 경우
Container(color: AppColors.black100)  // 흐린 배경이 필요한 경우
```

> 만약 기존 팔레트로 표현 불가능한 투명도 요구가 있다면, 디자이너와 상의 후 `app_colors.dart`에 새 상수를 추가하세요.

#### ✅ 규칙 3: 도메인 의미로 이름 붙이지 않기

`AppColors.policeBackground` 같은 도메인 래퍼는 **만들지 않습니다**. 팀 테마 전환은 `isDarkMode` 분기로 처리합니다(섹션 5 참조).

```dart
// ❌ 잘못된 예 — 팔레트 오염
static const Color policeBackground = Color(0xFFFFFFFF);

// ✅ 올바른 예 — 소비 시점에 분기
color: isDarkMode ? AppColors.black : AppColors.white
```

### 2.4 컬러 사용 예시

`isDarkMode ? A : B` 분기를 코드에서 센 실제 사용 쌍 기준이다 (2026-09-28, 괄호는 사용 횟수).

| 용도 | 경찰(라이트) | 도둑(다크) |
| --- | --- | --- |
| 게임 화면 배경 (대기방·구역/설정 페이지) | `white` | `black900` (19) |
| 다이얼로그·모달·로딩·채팅 입력 배경 | `white` | `black` (16) |
| 카드·입력 필드·슬라이더 트랙 배경 | `black100` | `black800` (14) |
| 본문/제목 텍스트 | `black` | `white` (22) |
| 보조 텍스트 | `black600` | `black400` (12) |
| 구분선 | `black200` | `black800` (6) |
| 주요 액션 (CTA 버튼 배경) | `blue` | `green` (16) — 버튼 글자는 경찰 `white` / 도둑 `black` |
| 경고/에러 | `red` | `red900` |
| 팀 무관 화면 배경 (홈·커뮤니티·공지) | `background` | — (항상 라이트) |

> 위 매핑은 현재 코드의 다수 패턴입니다. 실제 디자인 시안을 우선하되, 팔레트 외 값은 쓰지 마세요.

---

## 3. 타이포그래피 (AppTextStyles)

### 3.1 파일 위치

`lib/core/constants/text_styles.dart`

### 3.2 ⚠️ 절대 원칙: TextStyle을 직접 수정하지 않는다

**폰트 weight / fontSize / fontFamily / height / letterSpacing 값은 절대 변경하지 마세요.**
이 값들은 디자인 시스템의 단일 진실 공급원(Single Source of Truth)이며, 수정하려면 디자이너와 협의 후 `text_styles.dart` 자체를 업데이트해야 합니다.

```dart
// ❌ 절대 금지 — weight 변경
Text('제목', style: AppTextStyles.heading_24.copyWith(
  fontWeight: FontWeight.w900,
))

// ❌ 절대 금지 — fontSize 변경
Text('제목', style: AppTextStyles.heading_24.copyWith(fontSize: 30))

// ❌ 절대 금지 — fontFamily 변경
Text('제목', style: AppTextStyles.heading_24.copyWith(
  fontFamily: 'Pretendard-Bold',
))

// ❌ 절대 금지 — TextStyle 직접 생성
Text('제목', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600))
```

**허용되는 유일한 `copyWith` 사용**: `color`, `decoration`, `decorationColor` 같은 비(非)타입 속성 변경뿐입니다.

```dart
// ✅ 허용 — color만 변경
Text('제목', style: AppTextStyles.heading_24.copyWith(
  color: AppColors.black600,
))

// ✅ 허용 — decoration 추가
Text('링크', style: AppTextStyles.paragraph_14.copyWith(
  color: AppColors.blue,
  decoration: TextDecoration.underline,
))
```

### 3.3 스타일 카탈로그

`text_styles.dart`가 정본이다. 아래는 2026-09-28 기준 전체 목록이다.
**자간은 전 스타일 공통 `-0.32` 고정값**(비율 아님)이며, 행간은 표에 적은 스타일만 140%이고 나머지는 100%다.

#### Pretendard 계열 (기본)

| Getter | 크기 | Weight | 행간 | 용도 |
| --- | --- | --- | --- | --- |
| `semibold_56` | 56.sp | SemiBold | 100% | 초대형 숫자 (게임 결과 이동 거리) |
| `semibold_44` | 44.sp | SemiBold | 100% | 대형 숫자/스코어 |
| `semibold_28` | 28.sp | SemiBold | 100% | 초대 코드, 강조 숫자 |
| `heading_24` | 24.sp | SemiBold | 100% | 메인 타이틀 |
| `heading_20` | 20.sp | SemiBold | 100% | 섹션 제목 |
| `subHeading_18` | 18.sp | SemiBold | 100% | 서브 제목 |
| `label_18` | 18.sp | SemiBold | 100% | `AppButton` 기본 텍스트 |
| `label_16` | 16.sp | SemiBold | 100% | 라벨, 강조 텍스트 |
| `label16Medium` | 16.sp | Medium | 100% | 일반 라벨 |
| `paragraph_16` | 16.sp | Medium | **140%** | 큰 본문 |
| `paragraph_14` | 14.sp | Medium | **140%** | 본문 |
| `paragraph_14_100` | 14.sp | Medium | 100% | 한 줄 본문 |
| `paragraph14Regular` | 14.sp | Regular | 100% | 약한 본문 |
| `paragraph14Semibold` | 14.sp | SemiBold | 100% | 강조 본문 |
| `paragraph14bold` | 14.sp | Bold | 100% | 굵은 본문 |
| `chatroom_text_14` | 14.sp | Medium | **140%** | 커뮤니티 채팅 말풍선 본문 |
| `tag_14` | 14.sp | Medium | 100% | 큰 태그 |
| `tag12Semibold` | 12.sp | SemiBold | 100% | 강조 태그/배지 |
| `tag_12` | 12.sp | Medium | 100% | 태그, 캡션 |
| `tag_10` | 10.sp | Medium | 100% | 최소 캡션 |
| `tag10Bold` | 10.sp | Bold | 100% | 강조 최소 태그 |

#### Moneygraphy 계열 (도둑 전용, 행간 100%)

| Getter | 크기 | 용도 |
| --- | --- | --- |
| `robberHeading24` | 24.sp | 도둑 메인 타이틀 |
| `robberHeading` | 20.sp | 도둑 섹션 제목 |
| `robberSubHeading` | 18.sp | 도둑 서브 제목 |
| `robberLabel` | 16.sp | 도둑 라벨 |
| `robberParagraph` | 14.sp | 도둑 본문 |

> **Moneygraphy는 도둑 테마 전용**입니다. 경찰 화면에서는 사용하지 마세요.

### 3.4 스타일 선택 규칙

#### ✅ 규칙 1: 가장 가까운 스타일을 선택한다

디자인 시안의 크기/weight가 카탈로그와 다르더라도, **가장 가까운 스타일을 선택**하고 임의로 조절하지 않습니다. 차이가 크다면 디자이너와 상의하여 카탈로그를 확장하세요.

#### ✅ 규칙 2: 팀 테마별 타입페이스 분기

도둑 화면에서 제목을 쓸 때:

```dart
// 팀 의존 타이포
Text(
  '체포됨',
  style: isDarkMode
      ? AppTextStyles.robberHeading        // 도둑: Moneygraphy
      : AppTextStyles.heading_20,          // 경찰: Pretendard
)
```

#### ✅ 규칙 3: 색상은 반드시 copyWith로

색상을 지정하지 않으면 플랫폼 기본색(Material의 검정)이 적용되어 다크모드에서 보이지 않을 수 있습니다.

```dart
// ❌ 위험 — 색상 미지정
Text('제목', style: AppTextStyles.heading_24)

// ✅ 안전 — 팀 테마 색상 명시
Text(
  '제목',
  style: AppTextStyles.heading_24.copyWith(
    color: isDarkMode ? AppColors.white : AppColors.black,
  ),
)
```

---

## 4. Spacing, Radius & Shadow

### 4.1 파일 위치

- `lib/core/constants/spacing_and_radius.dart` — `AppSpacing` · `AppPadding` · `AppRadius`
- `lib/core/constants/app_shadows.dart` — `AppShadows`

### 4.2 토큰 카탈로그 (2026-09-28 기준)

모든 getter는 ScreenUtil이 내장되어 있다 (가로 `.w` · 세로 `.h` · 래디우스 `.r`).

**`AppSpacing`** — `double`, `SizedBox`·`EdgeInsets.only` 등에 쓴다

| 방향 | getter (숫자 = px) |
| --- | --- |
| 가로 `horizontalN` (`.w`) | 2 · 4 · 6 · 8 · 10 · 12 · 14 · 16 · 18 · 20 · 21 · 22 · 24 · 26 |
| 세로 `verticalN` (`.h`) | 4 · 6 · 8 · 10 · 12 · 14 · 16 · 18 · 20 · 24 · 26 · 28 · 32 · 40 · 48 · 50 · 58 · 64 |

**`AppPadding`** — `EdgeInsets` 프리셋

| getter | 값 |
| --- | --- |
| `all16` · `all20` · `all24` | 사방 16 / 20 / 24 (`.w`) |
| `horizontal16` · `horizontal20` · `horizontal24` · `horizontal36` | 좌우 16 / 20 / 24 / 36 (`.w`) |

> 현재 가장 많이 쓰는 화면 좌우 여백은 `AppPadding.horizontal20`이다.

**`AppRadius`** — `BorderRadius` 프리셋

| getter | 값 | 주 용도 |
| --- | --- | --- |
| `medium` | 8 | 바텀시트 내부 선택 셀, 핑 선택 카드 |
| `large` | 12 | **기본값** — `AppButton` 기본, 홈·공지·알림 카드 (최다 사용) |
| `xlarge` | 16 | 커뮤니티 게시글 카드, QR 화면, `AppDialog` |
| `xl18` | 18 | 바텀시트 상단 |
| `xl20` | 20 | `InfoCard`, `AppSlider`, 신고 카테고리 |
| `xxlarge` | 24 | 게임 다이얼로그(결과·재접속·이벤트), 대형 패널 |
| `pill` | 9999 | 완전 원형 — 플로팅 바, 태그 |

**`AppShadows`** — `List<BoxShadow>`, `boxShadow:`에 바로 대입

| getter | 스펙 | 비고 |
| --- | --- | --- |
| `ver2` | x0 y0 blur10, black 7% | 카드·버튼 기본 (최다 사용) |
| `vague` | x0 y0 blur4, black 10% | 은은한 확산 |
| `soft` | x1 y1 blur8, black 10% | 우하단 쉐도우 |
| `softThemed(isDarkMode)` | `soft`와 동일, 다크에선 white 20% 글로우 | 팀 테마 대응 |
| `topLift` | x0 y-2 blur10, black 10% | 하단 시트 위쪽 쉐도우 |
| `topLiftThemed(isDarkMode)` | `topLift`와 동일, 색 black200 / 다크 black | 팀 테마 대응 |
| `card` | x0 y1 blur4, black100 | 리스트 카드 |

> 쉐도우는 새 값을 만들지 않고 위 토큰 중 하나를 고른다. 토큰 내부의 `withValues(alpha:)`는 정본 정의라 허용된다.

### 4.3 사용 규칙

#### ✅ 규칙 1: `AppSpacing` / `AppPadding` / `AppRadius` / `AppShadows` 강제 사용

```dart
// ✅ 올바른 예
Padding(padding: AppPadding.horizontal20)
SizedBox(height: AppSpacing.vertical16)
BorderRadius: AppRadius.large
BoxDecoration(boxShadow: AppShadows.ver2)

// ❌ 잘못된 예
Padding(padding: EdgeInsets.symmetric(horizontal: 16.w))  // 상수 미사용
SizedBox(height: 16.h)                                     // 상수 미사용
BorderRadius.circular(20.r)                                // 상수 미사용
```

#### ✅ 규칙 2: ScreenUtil 생략 금지

직접 값을 쓸 때도 `.w / .h / .r / .sp`를 반드시 붙입니다. 단, **대부분의 경우 `AppSpacing` getter에 이미 내장**되어 있으므로 직접 쓸 일이 적어야 정상입니다.

```dart
// ✅ AppSpacing이 없으면 어쩔 수 없이 ScreenUtil 직접 사용
SizedBox(height: 7.h)

// ❌ 고정 픽셀 금지
SizedBox(height: 7)
```

---

## 5. 팀 테마 (Role Theme) 사용 패턴

### 5.1 Provider

`lib/core/theme/role_theme_provider.dart`

```dart
@Riverpod(keepAlive: true)
bool roleTheme(Ref ref) {
  final info = ref.watch(gameParticipantNotifierProvider);
  return GameTeam.isRobber(info?.team);
}
```

- `true` = 다크 모드 = **도둑으로 게임에 참가 중**
- `false` = 라이트 모드 = **경찰이거나, 게임에 참가 중이 아님** (앱 시작 시 기본값)
- `keepAlive: true` — 세션 전체에서 상태 유지

### 5.2 참가 정보에서 파생된다 — 직접 쓰지 않는다

`roleTheme`은 쓰기 API(`setDarkMode`)가 없는 **파생 값**입니다. 참가 정보(`gameParticipantNotifierProvider`)의
팀이 바뀌거나 참가 정보가 비워지면(퇴장·게임 종료) 자동으로 따라갑니다.

- 팀 배정·변경·퇴장 시 테마를 되돌리는 코드를 따로 넣지 않는다.
- 예전에는 별도 플래그를 대기방에서 손으로 맞췄는데, 퇴장 시 참가 정보만 비워지고 플래그가 `true`로 남아
  다음 게임 생성 화면이 다크로 뜨는 버그가 있었다(#520). 그래서 파생으로 바꿨다.

### 5.3 소비: `isDarkMode` prop 전파 패턴

팀 의존 위젯은 **생성자 파라미터로 `bool isDarkMode`를 받는 것**이 프로젝트 표준입니다. `ref.watch`로 위젯 내부에서 직접 구독하지 않습니다.

**왜 prop drilling인가?**

1. `core/widgets/` 공통 컴포넌트는 Riverpod 의존성을 갖지 않음 (재사용성)
2. 리스트 아이템 등 대량 렌더링 시 구독 수 최소화
3. 테스트 용이성 — 위젯 단독 테스트 시 Provider 세팅 불필요

#### 최상위(Page)에서 한 번만 watch

```dart
class GameLobbyPage extends ConsumerWidget {
  const GameLobbyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Page 레벨에서 한 번만 구독
    final isDarkMode = ref.watch(roleThemeProvider);

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.black : AppColors.white,
      body: ParticipantCard(
        nickname: '홍길동',
        isDarkMode: isDarkMode,  // prop으로 전달
      ),
    );
  }
}
```

#### 하위 위젯은 StatelessWidget + 생성자 파라미터

```dart
class ParticipantCard extends StatelessWidget {
  const ParticipantCard({
    super.key,
    required this.nickname,
    required this.isDarkMode,
  });

  final String nickname;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppPadding.all16,
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.black900 : AppColors.black100,
        borderRadius: AppRadius.xl20,
      ),
      child: Text(
        nickname,
        style: AppTextStyles.label_16.copyWith(
          color: isDarkMode ? AppColors.white : AppColors.black800,
        ),
      ),
    );
  }
}
```

### 5.4 조건부 컬러/타이포 패턴

조건부 선택은 **삼항 연산자 한 줄**로 표현합니다.

```dart
// 컬러 분기
color: isDarkMode ? AppColors.black100 : AppColors.black600

// 타이포 분기 (도둑은 Moneygraphy)
style: (isDarkMode ? AppTextStyles.robberHeading : AppTextStyles.heading_20)
    .copyWith(
      color: isDarkMode ? AppColors.white : AppColors.black,
    )
```

복잡해지면 **private getter**로 추출합니다.

```dart
TextStyle get _titleStyle {
  final base = isDarkMode
      ? AppTextStyles.robberHeading
      : AppTextStyles.heading_20;
  return base.copyWith(
    color: isDarkMode ? AppColors.white : AppColors.black,
  );
}
```

### 5.5 에셋(아이콘·이미지) 분기

팀 테마에 따라 시각적 톤이 달라져야 하는 SVG/PNG는 **파일 두 개**로 제공합니다.

```
assets/icons/icon_police_darkmode.svg
assets/icons/icon_police_lightmode.svg
```

```dart
SvgPicture.asset(
  isDarkMode
      ? 'assets/icons/icon_police_darkmode.svg'
      : 'assets/icons/icon_police_lightmode.svg',
)
```

---

## 6. Theme.of(context) vs AppColors

### 현재 표준: **AppColors 직접 참조**

이 프로젝트는 `Theme.of(context).colorScheme`를 **사용하지 않습니다**.

| 항목 | 선택 | 이유 |
| --- | --- | --- |
| `MaterialApp.theme` | 기본값 + `ColorScheme.fromSeed` | 팀 테마가 MaterialApp과 독립 동작 |
| `MaterialApp.darkTheme` | 미설정 | 시스템 다크모드 무시 |
| `Theme.of(context).colorScheme` | **사용 금지** | `AppColors` 직접 참조가 표준 |
| `Theme.of(context).textTheme` | **사용 금지** | `AppTextStyles` 직접 참조가 표준 |

```dart
// ❌ 사용 금지
Container(color: Theme.of(context).colorScheme.surface)
Text('본문', style: Theme.of(context).textTheme.bodyMedium)

// ✅ 프로젝트 표준
Container(color: isDarkMode ? AppColors.black900 : AppColors.white)
Text('본문', style: AppTextStyles.paragraph_14.copyWith(
  color: isDarkMode ? AppColors.white : AppColors.black800,
))
```

> Material 위젯(`ElevatedButton`, `Switch` 등)의 기본 테마색이 앱 전체 톤과 맞지 않을 수 있으므로, 항상 `style:` 프로퍼티로 `AppColors`를 주입하세요.

---

## 7. 금지 사항 & 안티패턴

### 🚫 컬러 금지 사항

```dart
// ❌ HEX/Color() 하드코딩
Color(0xFF4A90E2)
Color.fromRGBO(255, 0, 0, 1.0)

// ❌ Material 기본 색상
Colors.white
Colors.blue
Colors.grey[300]

// ❌ 투명도 헬퍼
AppColors.black.withOpacity(0.4)
AppColors.white.withValues(alpha: 0.8)

// ❌ Theme 참조
Theme.of(context).colorScheme.primary
Theme.of(context).primaryColor
```

### 🚫 타이포 금지 사항

```dart
// ❌ TextStyle 직접 생성
TextStyle(fontSize: 16, fontWeight: FontWeight.bold)

// ❌ weight/fontSize/fontFamily/height/letterSpacing copyWith
AppTextStyles.heading_24.copyWith(fontWeight: FontWeight.w900)
AppTextStyles.heading_24.copyWith(fontSize: 30)
AppTextStyles.heading_24.copyWith(fontFamily: 'Pretendard-Bold')

// ❌ Material 텍스트 테마
Theme.of(context).textTheme.headlineLarge
```

### 🚫 Spacing/Radius 금지 사항

```dart
// ❌ 고정 픽셀
SizedBox(height: 16)
EdgeInsets.all(20)

// ❌ ScreenUtil만 사용 (AppSpacing 상수 무시)
SizedBox(height: 16.h)
EdgeInsets.symmetric(horizontal: 20.w)

// ❌ BorderRadius.circular 직접 사용
BorderRadius.circular(20.r)
```

### 🚫 팀 테마 금지 사항

```dart
// ❌ 하위 위젯에서 직접 watch
class ParticipantCard extends ConsumerWidget {
  Widget build(context, ref) {
    final isDarkMode = ref.watch(roleThemeProvider);  // 금지!
    // ...
  }
}

// ❌ 팀 테마용 상태를 따로 만들어 손으로 동기화 — #520 회귀
final isRobberTheme = StateProvider<bool>((ref) => false);
```

---

## 8. 체크리스트

### 새 위젯 작성 시

- [ ] 모든 색상이 `AppColors` 상수인가?
- [ ] `Color(0xFF...)`, `Colors.xxx`, `withOpacity`, `withValues`가 없는가?
- [ ] 모든 텍스트에 `AppTextStyles.xxx` 스타일이 지정되었는가?
- [ ] `TextStyle()` 직접 생성이 없는가?
- [ ] `fontWeight/fontSize/fontFamily`를 `copyWith`로 변경하지 않았는가?
- [ ] 텍스트 색상이 팀 테마에 따라 분기되는가?
- [ ] Spacing/Padding/Radius/Shadow가 `AppSpacing`/`AppPadding`/`AppRadius`/`AppShadows` 상수인가?
- [ ] 고정 픽셀(`16` 대신 `16.h`) 없이 모두 ScreenUtil을 거쳤는가?
- [ ] 팀 의존 위젯이라면 `isDarkMode` 생성자 파라미터를 받는가?
- [ ] `Theme.of(context)` 참조가 없는가?
- [ ] 팀별 아이콘/이미지가 필요한 경우 `_darkmode` / `_lightmode` 2개 파일이 있는가?

### 기존 위젯 수정 시

- [ ] 수정 범위 내에 하드코딩 컬러가 있다면 `AppColors`로 교체했는가?
- [ ] `TextStyle()` 직접 생성을 `AppTextStyles`로 교체했는가?
- [ ] 팀 테마 분기가 누락된 위치는 없는가?

---

## 9. 리팩토링 TODO

현재 코드베이스에 남아있는 규칙 위반 사례입니다 (2026-09-28 `lib/` 실측, 생성 파일 제외). 관련 작업 시 함께 수정하세요.

- [x] ~~`arrest_lock_overlay.dart` / `game_action_modal.dart`의 `Color(0xFFB1BCC8)`~~ — `AppColors.black300`으로 교체 완료
- [x] ~~`credit_member.dart` 소셜 브랜드색~~ — 파일 제거됨
- [ ] **TODO**: `withValues(alpha:)` 17곳 — 대부분 배리어·딤 `AppColors.black.withValues(alpha: 0.4 / 0.7)` (`arrest_lock_overlay.dart`, `community_sheet_scaffold.dart`, `community_sort_sheet.dart`, `chat_context_menu.dart`, `game_page.dart`, `home_page.dart`, `waiting_room_page.dart`). 반복되는 값이라 `app_colors.dart`에 `blackAlphaNN` 상수를 추가하는 쪽이 맞다 (디자이너 확인 후)
- [ ] **TODO**: `Color(0x...)` 2곳 — `credits_page.dart` `_nightMap`(#22262B), `social_login_button.dart` 전경색 #000000 (소셜 로그인 브랜드 가이드)
- [ ] **TODO**: `Colors.transparent` 25곳 → `AppColors.transparent`. 그 외 `Colors.*`는 개발용 `lifecycle_test` 화면·로그와 `main.dart` seed, `speech_bubble.dart` 그림자 1곳
- [ ] **TODO**: `BorderRadius.circular()` 직접 사용 18곳 — 8/12/16/20처럼 토큰이 있는 값(`participant_card.dart`, `setting_field_card.dart`, `app_text_field.dart`, `arrest_lock_overlay.dart`, `pin_zone_setting_widget.dart`)은 `AppRadius`로 교체. 2·4·6·9는 토큰이 없다 (ISS-0166에서 보류)

> 이 TODO들은 "당장 막아야 할 핫픽스"가 아니라, 해당 파일을 다음에 수정할 때 **함께 정리**할 항목입니다. 독립적으로 전체 리팩토링 PR을 만들지는 마세요.

---

## 참고 문서

- `flutter-architecture` 스킬 — 계층 구조·의존성 규칙과 설계 결정 근거
- `code-conventions` 스킬 — 코드 작성 규칙
- `design-patterns` 스킬 — 디자인 패턴 카탈로그
- `lib/core/constants/app_colors.dart` — 컬러 팔레트 정본
- `lib/core/constants/text_styles.dart` — 타이포 정본
- `lib/core/constants/spacing_and_radius.dart` — 스페이싱/래디우스 정본
- `lib/core/constants/app_shadows.dart` — 쉐도우 정본
- `lib/core/theme/role_theme_provider.dart` — 팀 테마 Provider

---

**문서 작성**: Development Team
**최종 업데이트**: 2026-09-28
