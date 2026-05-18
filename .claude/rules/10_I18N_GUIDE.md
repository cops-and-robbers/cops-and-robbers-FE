# 국제화 (i18n) 가이드

> **대상**: UI에 텍스트가 노출되는 모든 작업
> **지원 로케일**: 한국어(ko), 영어(en), 일본어(ja) — ISO 639-1
> **기본 로케일**: ko (시스템 로케일이 지원 외이거나 첫 실행 시)
> **방식**: Flutter 공식 `flutter_localizations` + `intl` + ARB

---

## 핵심 원칙

1. **UI 텍스트는 ARB가 정본** — Dart 코드에 한국어 하드코딩 금지
2. **자동 생성 파일 직접 편집 금지** — `lib/l10n/app_localizations*.dart`
3. **3개 로케일 동시 추가** — `app_ko.arb`, `app_en.arb`, `app_ja.arb` 모두 키 추가
4. **`flutter gen-l10n` 실행** — ARB 수정 후 반드시 (hot reload 불가)
5. **단복수/용어 일관성** — Cops(타이틀, 복수) / Cop·Robber(라벨, 단수) / 警察·泥棒(일본어) / 경찰·도둑(한국어)

---

## 한국어 하드코딩 허용 범위

| 위치 | i18n? | 비고 |
|---|---|---|
| `Text()`, `SnackBar` 메시지, 다이얼로그 등 UI | ✅ 필수 | 사용자에게 보임 |
| 백엔드 RFC 7807 식별자 (`'필수 약관 미동의'`) | ❌ 금지 | 백엔드가 보내는 고정 식별자 |
| 의도된 도메인 데이터 (비속어 필터, 탈퇴 키워드 등) | ❌ 금지 | 한국어 입력만 검출 목적 |
| `debugPrint`, `AppLogger.*` | ❌ 허용 | 개발자용 로그 |
| 코드 주석, DartDoc | ❌ 허용 | 한국어 주석 권장 (CLAUDE.md 규칙) |
| `assert` 메시지 | ❌ 허용 | debug 빌드 전용 |
| `throw Exception('...')` 메시지 | ⚠️ 케이스별 | UI 노출되면 `AppException.messageKey` 패턴 사용 |
| Riverpod state의 `errorMessage` (UI 소비됨) | ✅ 필수 | `errorMessageKey` 동반 필드로 i18n |
| `AppException.message` | ✅ 권장 | `messageKey`도 같이 set (UI에서 변환) |

---

## 파일 구조

```text
lib/l10n/
├── app_ko.arb              # ✅ 정본 (template) — description 포함
├── app_en.arb              # ✅ 영어 번역
├── app_ja.arb              # ✅ 일본어 번역
├── app_localizations.dart  # ❌ 자동 생성 — 편집 금지
├── app_localizations_ko.dart  # ❌ 자동 생성
├── app_localizations_en.dart  # ❌ 자동 생성
└── app_localizations_ja.dart  # ❌ 자동 생성

l10n.yaml                   # gen-l10n 설정
pubspec.yaml                # flutter: generate: true
```

---

## 워크플로

### 1. 새 텍스트 추가 절차

```text
ARB 3개 파일에 동일 키 추가
  ↓
flutter gen-l10n
  ↓
AppLocalizations.dart 갱신 확인
  ↓
Widget/Notifier에서 사용
  ↓
flutter analyze
```

### 2. ARB 키 추가 예시

**`app_ko.arb`** (정본, description 필수):
```json
{
  "@@locale": "ko",
  ...
  "buttonStartGame": "게임 시작",
  "@buttonStartGame": {
    "description": "메인 화면 게임 시작 버튼"
  },
  "messageGameOver": "{winner}팀이 승리했습니다!",
  "@messageGameOver": {
    "description": "게임 종료 다이얼로그 메시지",
    "placeholders": {
      "winner": {
        "type": "String"
      }
    }
  }
}
```

**`app_en.arb`** (번역만):
```json
{
  "@@locale": "en",
  ...
  "buttonStartGame": "Start Game",
  "messageGameOver": "{winner} team wins!"
}
```

**`app_ja.arb`** (번역만):
```json
{
  "@@locale": "ja",
  ...
  "buttonStartGame": "ゲーム開始",
  "messageGameOver": "{winner}チームの勝利です！"
}
```

### 3. 코드 생성 실행

```bash
flutter gen-l10n
```

설정은 `l10n.yaml` 참조. `pubspec.yaml`의 `flutter: generate: true`로 `flutter pub get`·`flutter run` 시 자동 실행되지만, **ARB 수정 직후 명시적으로 한 번 돌리는 게 안전**.

### 4. 키 네이밍 컨벤션

```text
{용도prefix}{도메인/대상}{세부사항}
```

용도 prefix는 **메시지의 역할**로 정한다. 파일명이나 화면명을 넣지 않는다.

| 패턴 | 예시 | 비고 |
|---|---|---|
| `button*` | `buttonConfirm`, `buttonStartGame`, `buttonReport` | 버튼 라벨 |
| `dialog*Title` / `dialog*Message` | `dialogReconnectMessage`, `dialogSafetyWarningTitle` | 다이얼로그 제목/본문 |
| `error*` | `errorNetworkTimeout`, `errorBugReportFailed` | 에러 메시지 (Exception 노출 포함) |
| `message*` | `messageBugReportSubmitted`, `messageAccountDeleted` | 안내/성공 메시지 (스낵바 등) |
| `field*Hint` / `field*Label` | `fieldBugReportHint`, `fieldNicknameLabel` | 입력 필드 |
| `title*` / `section*` / `label*` | `titleGameRules`, `sectionTitleSettings`, `labelArrestCount` | 화면 구성 요소 |
| `link*` | `linkPrivacyPolicy`, `linkTermsOfService` | 약관/외부 링크 |
| `chatSystem*` | `chatSystemGameStartReady` | 채팅 시스템 메시지 |
| `gameEvent*` | `gameEventPoliceMove`, `gameEventArrestNotice` | 게임 이벤트 배너 |
| `settings*` | `settingsLanguageLabel` | 설정 화면 도메인 |
| `asset_*` | `asset_loading_joinRoom` | 외부 데이터 매핑 (스네이크 케이스 유지) |

### 5. 금지 패턴 (재발 방지)

마이그레이션 도구가 자동 생성하는 다음 패턴은 **사용 금지**. 신규 작업에 발견되면 즉시 의미 기반 키로 교체한다.

| ❌ 금지 패턴 | 문제점 | ✅ 대체 |
|---|---|---|
| `{feature}_{filename}_L{line}` | 라인 번호는 파일 수정 시 의미 깨짐 | 의미 기반 (예: `chatSystemGameStartGo`) |
| `{prefix}{Name}{hex4}` (예: `dialogTutorialPromptF6a8`) | hex suffix는 키 충돌 회피용으로 자동 생성, 의미 0 | 의미 기반 (예: `dialogTutorialPromptMessage`) |
| `{prefix}{filename}{Purpose}` (예: `dialogsettingsPageMessage`) | 파일 rename 시 키 의미 깨짐, 같은 파일에 여러 dialog 있으면 모호 | 의미 기반 (예: `dialogGamePushUpdateFailed`) |

### 6. 중복 키 재사용 우선

신규 키 만들기 전에 ARB 전체에서 같은 의미의 키가 있는지 검색한다. 있으면 **무조건 재사용**.

자주 재사용되는 공용 키:
- `buttonConfirm`, `buttonCancel`, `buttonClose`, `buttonRetry`
- `errorNetworkTimeout`, `errorNetworkOffline`, `errorTemporaryRetry`
- `linkPrivacyPolicy`, `linkTermsOfService`

```bash
# 새 키 추가 전 검색 예시
grep -n '"확인"' lib/l10n/app_ko.arb   # 같은 한국어 메시지가 이미 있나?
grep -n 'buttonConfirm' lib/l10n/app_ko.arb  # 공용 키 존재 여부
```

---

## 사용 패턴

### 패턴 1: Widget (BuildContext 있음)

가장 일반적. `AppLocalizations.of(context)`로 직접 호출.

```dart
import '../../../../l10n/app_localizations.dart';

class GameStartButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ElevatedButton(
      onPressed: () => _startGame(),
      child: Text(l10n.buttonStartGame),
    );
  }
}
```

### 패턴 2: Placeholder 포함

```dart
// ARB: "messageGameOver": "{winner}팀이 승리했습니다!"
Text(l10n.messageGameOver(winnerTeamName))
```

### 패턴 3: Notifier (BuildContext 없음)

Notifier에서 state에 localized string을 set해야 할 때:
`appLocaleProvider`로 현재 locale 읽고 `lookupAppLocalizations(locale)`로 sync 변환.

```dart
import '../../../../core/i18n/locale_provider.dart';
import '../../../../l10n/app_localizations.dart';

@riverpod
class GameEventNotifier extends _$GameEventNotifier {
  @override
  GameEventState build() => const GameEventState();

  void handleArrest(String robberNickname) {
    state = state.copyWith(
      bannerMessage: _localize((l10n) => l10n.gameEventArrest(robberNickname)),
    );
  }

  String _localize(String Function(AppLocalizations) f) {
    final locale = ref.read(appLocaleProvider);
    return f(lookupAppLocalizations(locale));
  }
}
```

**주의**: locale 변경 후 set된 stale 메시지는 갱신되지 않음. 배너처럼 자동 해제되는 경우는 무시 가능.

### 패턴 4: Custom Exception (`messageKey` 동반)

`AppException`은 `message` (fallback) + `messageKey` (i18n 키) 두 필드.
Repository/UseCase에서 throw 시 `messageKey` 필수 동봉.

```dart
// lib/core/errors/app_exception.dart
abstract class AppException implements Exception {
  final String message;       // fallback (한국어)
  final String? messageKey;   // ARB 키
  // ...
}

// Repository에서 throw
throw ServerException(
  message: '버그 제보 처리 중 오류가 발생했습니다.',
  messageKey: 'dialogBugRepositoryImplMessage',
  originalException: e,
);

// UI에서 변환
catch (e) {
  if (e is AppException) {
    final msg = AppLocalizations.of(context).errorByException(e);
    AppSnackbar.show(context, message: msg);
  }
}
```

`AppLocalizations.errorByException(e)`는 `lib/core/i18n/error_message_mapper.dart`의 extension. 키로 lookup하고 없으면 `message` fallback.

### 패턴 5: DioException 자동 변환

`DioExceptionHandler.handle(e)`가 HTTP 상태 코드별로 적절한 `AppException` + `messageKey` 자동 매핑.
Repository는 단지 한 줄:

```dart
on DioException catch (e) {
  throw DioExceptionHandler.handle(e);
}
```

---

## 단복수 / 용어 통일 규칙

게임 도메인 명사는 다음 컨벤션 사용:

| 카테고리 | en | ja | ko |
|---|---|---|---|
| **게임 타이틀** (고유명사) | `Cops and Robbers` | `Cops and Robbers` (브랜드명 유지) | `경찰과도둑` |
| **역할 라벨/팀명** (Among Us 톤) | `Cop` / `Robber`, `Cop team` / `Robber team` | `警察` / `泥棒`, `警察チーム` / `泥棒チーム` | `경찰` / `도둑`, `경찰팀` / `도둑팀` |
| **본문 영어** (자연스러운 문법) | "A Robber escaped", "All Robbers arrested" 등 | 동일 패턴 | 동일 |

**원칙**:
- 게임 타이틀 외에는 **역할 명사 단수형** (Among Us, Mafia, Werewolf 등 게임 업계 관례)
- 일본어/한국어는 단복수 구분 없음 → 영어 결정과 무관
- 일본어는 **영어와 일본어 혼용 금지** (`Cops` + `泥棒` ❌ → `警察` + `泥棒` ✅)

---

## 고유명사 (사람 이름 / 캐릭터 이름) 정책

사람 이름·캐릭터 이름은 음역하지 않고 **영문 표기를 모든 비한국어 로케일에 그대로 사용**한다.

| 카테고리 | ko | en | ja | 새 언어 추가 시 |
|---|---|---|---|---|
| **크레딧 멤버** | `홍의민` | `Hong Eui-min` | `Hong Eui-min` (영문 그대로) | 영문 사용 |
| **튜토리얼 캐릭터** | `도둑킹` | `RobberKing` | `RobberKing` (영문 그대로) | 영문 사용 |

**왜?**
- 이름은 본인의 고유 식별자라 음역(`ホン・ウィミン`)하면 원본이 흐려진다
- 새 언어 추가 시마다 음역본 추가는 비현실적 → 영문 표기를 기본값으로
- 한국어 사용자만 한글 이름, 그 외는 모두 영문

**적용 케이스**:
- `credits_creditMember_*`: 한국어만 한글, en/ja 및 이후 추가 로케일은 영문 표기
- 튜토리얼 더미 캐릭터 이름 (`tutorial_inGameTutorialPage_L72` 등 `RobberKing`, `RobberOrNot`, `CapturedRobber`): 모든 로케일에서 영문 그대로

---

## locale 변경 즉시 반영 (Hot Switch)

설정 화면에서 언어 변경 시 앱 재시작 없이 즉시 반영되어야 함.

**구현**: `lib/main.dart`의 `_LocalizedApp` ConsumerWidget이 `appLocaleProvider`를 watch.
`MaterialApp.router`에 `ValueKey(locale.languageCode)` 부여 → locale 변경 시 트리 강제 재구성.

```dart
class _LocalizedApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(appLocaleProvider);
    return MaterialApp.router(
      key: ValueKey(locale.languageCode),  // 강제 재구성
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // ...
    );
  }
}
```

`ScreenUtilInit` 같은 캐싱 래퍼 내부에 `_LocalizedApp`를 두어야 함 (외부에서 watch하면 child 캐싱으로 반영 안 됨).

---

## 자주 하는 실수

### ❌ 1. `app_localizations*.dart` 직접 편집
자동 생성 파일이라 `flutter gen-l10n` 시 덮어쓰여진다. **ARB만 수정**.

### ❌ 2. ARB 한 개에만 키 추가
ko에만 추가하면 en/ja에서 `untranslated.txt`에 기록되고 fallback으로 동작. 3개 동시 추가 필수.

### ❌ 3. Placeholder 이름에 한글/일본어 사용
ARB placeholder는 ASCII identifier만 허용. `{이름}` ❌ → `{name}` ✅.

### ❌ 4. `Cops` 영어 + `泥棒` 일본어 혼용
일본어 ARB에서 영어 단어 섞으면 어색. `警察` + `泥棒`으로 통일.

### ❌ 5. `MessageKey` 누락된 Exception
UI에서 i18n 변환 불가 → 한국어가 영어 사용자에게 노출됨.

### ❌ 6. Notifier에서 `AppLocalizations.of(context)` 사용 시도
BuildContext 없음. `lookupAppLocalizations(ref.read(appLocaleProvider))` 사용.

### ❌ 7. ARB 수정 후 `flutter gen-l10n` 누락
IDE 자동완성에는 보이지만 빌드/런타임에는 미반영.

---

## 테스트 작성 시 주의

i18n을 쓰는 Widget을 테스트할 때 `MaterialApp`에 다음 셋업 필수:

```dart
import 'package:cops_and_robbers/l10n/app_localizations.dart';

MaterialApp(
  locale: const Locale('ko'),  // 텍스트 매칭 안정성
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: const MyWidget(),
)
```

누락 시 `AppLocalizations.of(context)`가 null → "Null check operator" 에러.

영어 디폴트 로케일은 텍스트 길이가 달라 RenderFlex overflow 가능 → `locale: Locale('ko')`로 강제.

---

## 핵심 파일 위치

| 역할 | 경로 |
|---|---|
| ARB 정본 | `lib/l10n/app_ko.arb`, `app_en.arb`, `app_ja.arb` |
| 자동 생성 (편집 금지) | `lib/l10n/app_localizations*.dart` |
| 설정 | `l10n.yaml`, `pubspec.yaml` (`generate: true`) |
| Locale Provider | `lib/core/i18n/locale_provider.dart` |
| Exception → i18n 헬퍼 | `lib/core/i18n/error_message_mapper.dart` |
| Dio 에러 매핑 | `lib/core/network/dio_exception_handler.dart` |
| MaterialApp wiring | `lib/main.dart` (`_LocalizedApp`) |
| 언어 선택 UI | `lib/features/settings/presentation/pages/language_settings_page.dart` |

---

## 체크리스트 (PR 전)

- [ ] 새 UI 텍스트가 ARB 3개 파일에 모두 추가됨
- [ ] `flutter gen-l10n` 실행 후 `app_localizations*.dart` 갱신됨
- [ ] Widget은 `AppLocalizations.of(context).key` 사용
- [ ] Notifier·Exception은 `messageKey` 또는 `lookupAppLocalizations` 패턴
- [ ] 자동 생성 파일 직접 편집 없음
- [ ] 영어 ARB에서 "Cops" 단/복수 일관성 유지 (라벨은 단수, 게임 타이틀만 복수)
- [ ] 일본어 ARB에서 영어/일본어 혼용 없음
- [ ] Widget 테스트에 `localizationsDelegates` 셋업
- [ ] `flutter analyze` 통과
- [ ] **금지 패턴 0건 확인** (자동완성 도구 출력 재발 방지):
  ```bash
  # 셋 다 0이어야 함
  grep -cE '"[a-z]+_[a-zA-Z]+_L[0-9]+":' lib/l10n/app_ko.arb
  grep -cE '"[a-z]+[A-Z][a-zA-Z0-9]*[a-fA-F0-9]{4}":' lib/l10n/app_ko.arb
  grep -cE '"(field|dialog)[a-z]+[A-Z]' lib/l10n/app_ko.arb
  ```
