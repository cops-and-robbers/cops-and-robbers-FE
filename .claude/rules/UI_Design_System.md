# UI 디자인 시스템 가이드 (UI Design System Guide)

> **작성일**: 2026-04-15
> **대상 독자**: 개발자, 신규 팀원, 디자이너
> **문서 버전**: 1.0.0
> **범위**: cops_and_robbers 프로젝트의 컬러·타이포·테마·스페이싱 사용 규칙

---

## 📋 목차

1. [개요](#개요)
2. [테마 철학: 경찰/도둑 팀 테마](#1-테마-철학-경찰도둑-팀-테마)
3. [컬러 시스템 (AppColors)](#2-컬러-시스템-appcolors)
4. [타이포그래피 (AppTextStyles)](#3-타이포그래피-apptextstyles)
5. [Spacing & Radius](#4-spacing--radius)
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

```
기본색         : white, black
흑백 계열      : black100, black200, ..., black900  (숫자가 클수록 어두움)
초록 계열      : green, green100/500/800
파랑 계열      : blue, blue100/500/800
빨강 계열      : red, red100/500/800/900
노랑 계열      : yellow, yellow900
진한 초록 계열 : deepGreen, deepGreen900
```

### 2.3 컬러 사용 규칙

#### ✅ 규칙 1: AppColors 상수만 참조

```dart
// ✅ 올바른 예
Container(color: AppColors.white)
Icon(Icons.check, color: AppColors.blue500)
BoxDecoration(color: AppColors.blue100)
// 텍스트는 AppTextStyles를 기반으로 색상만 override (§2.3의 AppTextStyles 원칙 준수)
Text('안녕', style: AppTextStyles.body1.copyWith(color: AppColors.black600))

// ❌ 잘못된 예
Container(color: Color(0xFFFFFFFF))           // 하드코딩 금지
Container(color: Colors.white)                 // Material 기본 색상 금지
Text('안녕', style: TextStyle(color: AppColors.black600))  // TextStyle 직접 생성 금지
Text('안녕', style: TextStyle(color: Color(0xFF4A90E2)))  // HEX + TextStyle 직접 생성 금지
```

#### ✅ 규칙 2: 투명도는 흑백 계열 상수로 대체

`withOpacity()`, `withValues(alpha:)` **사용 금지**. 투명도가 필요한 경우 이미 정의된 `black100 ~ black900` 또는 `white` 계열 상수를 선택하세요.

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

| 용도 | 경찰(라이트) | 도둑(다크) |
| --- | --- | --- |
| 화면 배경 | `AppColors.white` | `AppColors.black` |
| 카드 배경 | `AppColors.black100` | `AppColors.black900` |
| 본문 텍스트 | `AppColors.black800` | `AppColors.black100` |
| 보조 텍스트 | `AppColors.black600` | `AppColors.black400` |
| 구분선 | `AppColors.black200` | `AppColors.black800` |
| 주요 액션 | `AppColors.blue` | `AppColors.green` |
| 경고/에러 | `AppColors.red` | `AppColors.red900` |

> 위 매핑은 권장 기준입니다. 실제 디자인 시안을 우선하되, 팔레트 외 값은 쓰지 마세요.

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

전체 목록은 `text_styles.dart` 파일을 정본으로 참고하되, 주요 스타일은 아래와 같습니다.

#### Pretendard 계열 (기본)

| Getter | 크기 | Weight | 용도 |
| --- | --- | --- | --- |
| `semibold_44` | 44.sp | SemiBold | 대형 숫자/스코어 |
| `semibold_28` | 28.sp | SemiBold | 초대 코드, 강조 숫자 |
| `heading_24` | 24.sp | SemiBold | 메인 타이틀 |
| `heading_20` | 20.sp | SemiBold | 섹션 제목 |
| `subHeading_18` | 18.sp | SemiBold | 서브 제목 |
| `label_16` | 16.sp | SemiBold | 라벨, 강조 텍스트 |
| `label16Medium` | 16.sp | Medium | 일반 라벨 |
| `paragraph_14` | 14.sp | Medium | 본문 (line-height 140%) |
| `paragraph_14_100` | 14.sp | Medium | 본문 (line-height 100%) |
| `paragraph14Semibold` | 14.sp | SemiBold | 강조 본문 |
| `tag12Semibold` | 12.sp | SemiBold | 강조 태그/배지 |
| `tag_12` | 12.sp | Medium | 태그, 캡션 |
| `tag_10` | 10.sp | Medium | 최소 캡션 |
| `tag10Bold` | 10.sp | Bold | 강조 최소 태그 |

#### Moneygraphy 계열 (도둑 전용)

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

## 4. Spacing & Radius

### 4.1 파일 위치

`lib/core/constants/spacing_and_radius.dart`

### 4.2 사용 규칙

#### ✅ 규칙 1: `AppSpacing` / `AppPadding` / `AppRadius` 강제 사용

```dart
// ✅ 올바른 예
Padding(padding: AppPadding.horizontal16)
SizedBox(height: AppSpacing.v16)
BorderRadius: AppRadius.xl20

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
class RoleTheme extends _$RoleTheme {
  @override
  bool build() => false;  // 기본: 경찰(라이트)

  void setDarkMode(bool isDark) {
    state = isDark;
  }
}
```

- `true` = 다크 모드 = **도둑**
- `false` = 라이트 모드 = **경찰** (앱 시작 시 기본값)
- `keepAlive: true` — 세션 전체에서 상태 유지

### 5.2 진입점: 팀 배정 시점에만 호출

`roleThemeProvider.notifier.setDarkMode()`는 **팀이 결정/변경되는 순간에만** 호출합니다.

**호출해야 하는 시점:**

- 대기방 입장 시 본인 팀 확인 후
- 팀 변경 이벤트(`TEAM_UPDATE`) 수신 후
- 게임 종료/대기방 퇴장 시 `setDarkMode(false)`로 초기화

```dart
// 대기방에서 팀이 결정되었을 때
ref.read(roleThemeProvider.notifier).setDarkMode(team == 'ROBBER');
```

**호출하면 안 되는 시점:**

- 화면 진입 시마다(이미 설정된 값을 덮어쓰는 사이드 이펙트)
- 위젯 `build()` 내부(rebuild 루프 위험)

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

// ❌ build 내부에서 setDarkMode 호출
Widget build(BuildContext context, WidgetRef ref) {
  ref.read(roleThemeProvider.notifier).setDarkMode(true);  // 무한 rebuild!
  // ...
}
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
- [ ] Spacing/Padding/Radius가 `AppSpacing`/`AppPadding`/`AppRadius` 상수인가?
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

현재 코드베이스에 남아있는 규칙 위반 사례입니다. 관련 작업 시 함께 수정하세요.

- [ ] **TODO**: `lib/features/game/presentation/widgets/arrest_lock_overlay.dart:62` — `Color(0xFFB1BCC8)` 하드코딩 → `AppColors.black300`으로 교체
- [ ] **TODO**: `lib/features/game/presentation/widgets/arrest_lock_overlay.dart:36` — `withValues(alpha: 0.4)` → 적절한 `AppColors.blackXXX` 상수로 교체
- [ ] **TODO**: `lib/features/game/presentation/widgets/game_action_modal.dart:74` — `Color(0xFFB1BCC8)` 하드코딩 → `AppColors.black300`으로 교체
- [ ] **TODO**: `lib/features/*/credit_member.dart:42-44` — 소셜 브랜드색(`Color(0xFF4A90E2)`, `Color(0xFF03C75A)`) 하드코딩. `lib/core/constants/brand_colors.dart` 신설 후 상수로 분리 검토 (외부 브랜드 가이드라인 준수 필요)

> 이 TODO들은 "당장 막아야 할 핫픽스"가 아니라, 해당 파일을 다음에 수정할 때 **함께 정리**할 항목입니다. 독립적으로 전체 리팩토링 PR을 만들지는 마세요.

---

## 참고 문서

- [00_QUICK_REFERENCE.md](00_QUICK_REFERENCE.md) — 빠른 참조
- [01_ARCHITECTURE.md](01_ARCHITECTURE.md) — 아키텍처 상세
- [03_CODE_CONVENTIONS.md](03_CODE_CONVENTIONS.md) — 코드 컨벤션
- [Design.md](Design.md) — 디자인 패턴(아키텍처 레벨)
- `lib/core/constants/app_colors.dart` — 컬러 팔레트 정본
- `lib/core/constants/text_styles.dart` — 타이포 정본
- `lib/core/constants/spacing_and_radius.dart` — 스페이싱/래디우스 정본
- `lib/core/theme/role_theme_provider.dart` — 팀 테마 Provider

---

**문서 작성**: Development Team
**최종 업데이트**: 2026-04-15
