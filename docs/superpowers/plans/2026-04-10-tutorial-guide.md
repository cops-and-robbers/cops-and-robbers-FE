# 게임 화면 튜토리얼 가이드 구현 계획

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 앱을 처음 사용하는 유저에게 화면별 코치마크 튜토리얼을 제공한다.

**Architecture:** `TutorialService`(SharedPreferences)로 화면별 완료 상태를 관리하고, 각 화면의 `initState` → `addPostFrameCallback`에서 미완료 시 `TutorialCoachMark`를 실행한다. 설정 페이지에서 전체 초기화가 가능하다.

**Tech Stack:** tutorial_coach_mark ^1.3.3, SharedPreferences, GlobalKey

---

## 파일 구조

```
lib/core/services/tutorial/
├── tutorial_service.dart          # SharedPreferences 기반 완료 상태 관리
└── tutorial_keys.dart             # 키 상수 정의

lib/core/tutorial/
└── app_tutorial_style.dart        # 코치마크 공통 스타일 (TargetFocus 생성 헬퍼)
```

튜토리얼 대상 화면:

- `lib/features/session/presentation/pages/home_page.dart` (수정)
- `lib/features/session/presentation/pages/session_creation_flow_page.dart` (수정)
- `lib/features/session/presentation/widgets/session_creation_steps/step_0_select_area_content.dart` (수정)
- `lib/features/session/presentation/widgets/session_creation_steps/step_1_participant_settings_content.dart` (수정)
- `lib/features/session/presentation/widgets/session_creation_steps/step_2_game_settings_content.dart` (수정)
- `lib/features/session/presentation/widgets/session_creation_steps/step_3_invite_code_content.dart` (수정)
- `lib/features/session/presentation/pages/waiting_room_page.dart` (수정)
- `lib/features/game/presentation/pages/game_page.dart` (수정)
- `lib/features/settings/presentation/pages/settings_page.dart` (수정)

---

### Task 1: 패키지 교체

**Files:**

- Modify: `pubspec.yaml`

- [ ] **Step 1: pubspec.yaml에서 showcaseview 제거, tutorial_coach_mark 추가**

`dependencies:` 섹션에서:

```yaml
# 제거
showcaseview: ^5.0.1

# 추가
tutorial_coach_mark: ^1.3.3
```

- [ ] **Step 2: 의존성 설치**

Run: `flutter pub get`

---

### Task 2: TutorialService + 키 상수

**Files:**

- Create: `lib/core/services/tutorial/tutorial_keys.dart`
- Create: `lib/core/services/tutorial/tutorial_service.dart`

- [ ] **Step 1: tutorial_keys.dart 생성**

```dart
/// 튜토리얼 화면별 SharedPreferences 키 상수
class TutorialKeys {
  TutorialKeys._();

  static const home = 'tutorial_home';
  static const createStep0 = 'tutorial_create_step0';
  static const createStep1 = 'tutorial_create_step1';
  static const createStep2 = 'tutorial_create_step2';
  static const createStep3 = 'tutorial_create_step3';
  static const waitingRoom = 'tutorial_waiting_room';
  static const game = 'tutorial_game';

  /// 전체 키 목록 (초기화 시 사용)
  static const all = [
    home,
    createStep0,
    createStep1,
    createStep2,
    createStep3,
    waitingRoom,
    game,
  ];
}
```

- [ ] **Step 2: tutorial_service.dart 생성**

```dart
import 'package:shared_preferences/shared_preferences.dart';
import 'tutorial_keys.dart';

/// 화면별 튜토리얼 완료 상태를 SharedPreferences로 관리
class TutorialService {
  TutorialService._();

  /// 해당 화면의 튜토리얼을 완료했는지 확인
  static Future<bool> isCompleted(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false;
  }

  /// 해당 화면의 튜토리얼을 완료 처리
  static Future<void> markCompleted(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, true);
  }

  /// 모든 튜토리얼 초기화 (설정 페이지에서 호출)
  static Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in TutorialKeys.all) {
      await prefs.remove(key);
    }
  }
}
```

---

### Task 3: 코치마크 공통 스타일 헬퍼

**Files:**

- Create: `lib/core/tutorial/app_tutorial_style.dart`

- [ ] **Step 1: app_tutorial_style.dart 생성**

`tutorial_coach_mark` 패키지의 `TargetFocus`와 `TutorialCoachMark`를 래핑하는 헬퍼.

```dart
import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../constants/app_colors.dart';
import '../constants/text_styles.dart';

/// 튜토리얼 코치마크 공통 스타일 및 헬퍼
class AppTutorialStyle {
  AppTutorialStyle._();

  /// 단일 TargetFocus 생성
  ///
  /// [keyTarget] — 하이라이트할 위젯의 GlobalKey
  /// [description] — 안내 텍스트
  /// [alignSkip] — 텍스트 정렬 위치 (기본: bottom)
  /// [shape] — 하이라이트 형태 (기본: RRect)
  static TargetFocus createTarget({
    required GlobalKey keyTarget,
    required String description,
    ContentAlign align = ContentAlign.bottom,
    ShapeLightFocus shape = ShapeLightFocus.RRect,
  }) {
    return TargetFocus(
      keyTarget: keyTarget,
      alignSkip: Alignment.topRight,
      shape: shape,
      radius: 8,
      contents: [
        TargetContent(
          align: align,
          builder: (context, controller) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                description,
                style: AppTextStyles.paragraph_14.copyWith(
                  color: AppColors.white,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// TutorialCoachMark 생성 및 즉시 표시
  ///
  /// [context] — BuildContext
  /// [targets] — TargetFocus 목록
  /// [onFinish] — 튜토리얼 완료 콜백 (완료 처리용)
  static void show({
    required BuildContext context,
    required List<TargetFocus> targets,
    VoidCallback? onFinish,
  }) {
    TutorialCoachMark(
      targets: targets,
      colorShadow: AppColors.black,
      opacityShadow: 0.8,
      hideSkip: true,
      onFinish: onFinish,
    ).show(context: context);
  }
}
```

---

### Task 4: 홈 화면 튜토리얼

**Files:**

- Modify: `lib/features/session/presentation/pages/home_page.dart`

현재 `HomePage`는 `ConsumerWidget`(Stateless)이다. `GlobalKey`와 `initState`가 필요하므로 `ConsumerStatefulWidget`으로 변환해야 한다.

- [ ] **Step 1: HomePage를 ConsumerStatefulWidget으로 변환**

기존 `ConsumerWidget` → `ConsumerStatefulWidget` + `ConsumerState<HomePage>`로 변경.
기존 `build(BuildContext context, WidgetRef ref)` → `build(BuildContext context)`로 변경 (ref는 State에서 접근).
기존 static 필드(`_safetyNoticePrefKey`, `_safetyNoticeShown`, `_activeGameChecked`)와 메서드들은 State 클래스로 이동.

- [ ] **Step 2: GlobalKey 추가 + 튜토리얼 스텝 정의**

State 클래스에 추가:

```dart
// 튜토리얼 대상 키
final _tutorialKeyCreateRoom = GlobalKey();
final _tutorialKeyJoinRoom = GlobalKey();
```

방만들기 버튼의 `AppButton`에 `key: _tutorialKeyCreateRoom` 추가.
방참여하기 버튼의 `AppButton`에 `key: _tutorialKeyJoinRoom` 추가.

- [ ] **Step 3: initState에서 튜토리얼 트리거**

```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _showTutorialIfNeeded();
  });
}

Future<void> _showTutorialIfNeeded() async {
  final completed = await TutorialService.isCompleted(TutorialKeys.home);
  if (completed || !mounted) return;

  AppTutorialStyle.show(
    context: context,
    targets: [
      AppTutorialStyle.createTarget(
        keyTarget: _tutorialKeyCreateRoom,
        description: '새로운 게임을 만들 수 있어요',
      ),
      AppTutorialStyle.createTarget(
        keyTarget: _tutorialKeyJoinRoom,
        description: '초대 코드를 입력하면 게임에 참가할 수 있어요',
      ),
    ],
    onFinish: () => TutorialService.markCompleted(TutorialKeys.home),
  );
}
```

---

### Task 5: 방만들기 플로우 튜토리얼 (Step 0~3)

**Files:**

- Modify: `lib/features/session/presentation/pages/session_creation_flow_page.dart`
- Modify: `lib/features/session/presentation/widgets/session_creation_steps/step_0_select_area_content.dart`
- Modify: `lib/features/session/presentation/widgets/session_creation_steps/step_1_participant_settings_content.dart`
- Modify: `lib/features/session/presentation/widgets/session_creation_steps/step_2_game_settings_content.dart`
- Modify: `lib/features/session/presentation/widgets/session_creation_steps/step_3_invite_code_content.dart`

방만들기 플로우는 `SessionCreationFlowPage`가 `PageView`로 4개 Step 위젯을 관리한다. 각 Step 위젯은 `StatelessWidget`이다.

**접근 방식:** `SessionCreationFlowPage`(StatefulWidget)에서 모든 GlobalKey를 관리하고, 페이지 전환 시 해당 Step의 튜토리얼을 트리거한다.

- [ ] **Step 1: SessionCreationFlowPage에 GlobalKey 추가**

```dart
// Step 0 튜토리얼 키
final _tutorialKeyPlayground = GlobalKey();
final _tutorialKeyPrison = GlobalKey();

// Step 1 튜토리얼 키
final _tutorialKeyMaxParticipants = GlobalKey();

// Step 2 튜토리얼 키
final _tutorialKeyRoundDuration = GlobalKey();
final _tutorialKeyLocationShare = GlobalKey();
final _tutorialKeyPoliceWait = GlobalKey();

// Step 3 튜토리얼 키
final _tutorialKeySettingSummary = GlobalKey();
final _tutorialKeyCreateButton = GlobalKey();
```

- [ ] **Step 2: 각 Step 위젯에 GlobalKey를 전달**

각 Step 컨텐츠 위젯에 `GlobalKey` 파라미터 추가. 예시 (Step 0):

`Step0SelectAreaContent`에 파라미터 추가:

```dart
final GlobalKey? playgroundKey;
final GlobalKey? prisonKey;
```

해당 위젯 내부의 `ZoneSettingButton`에 `key: widget.playgroundKey` 적용.

나머지 Step도 동일 패턴.

- [ ] **Step 3: 페이지 전환 시 튜토리얼 트리거**

`PageView`의 `onPageChanged` 또는 `_pageController` 리스너에서 튜토리얼 트리거:

```dart
Future<void> _showStepTutorial(int step) async {
  final String key;
  final List<TargetFocus> targets;

  switch (step) {
    case 0:
      key = TutorialKeys.createStep0;
      targets = [
        AppTutorialStyle.createTarget(
          keyTarget: _tutorialKeyPlayground,
          description: '게임할 구역을 설정해요.\n먼저 플레이그라운드를 지정하세요',
        ),
        // 감옥 키는 플레이그라운드 설정 후 노출되므로
        // 플레이그라운드 설정 완료 후 별도 트리거 필요할 수 있음
      ];
    case 1:
      key = TutorialKeys.createStep1;
      targets = [
        AppTutorialStyle.createTarget(
          keyTarget: _tutorialKeyMaxParticipants,
          description: '게임에 참여할 수 있는 최대 인원을 설정해요',
        ),
      ];
    case 2:
      key = TutorialKeys.createStep2;
      targets = [
        AppTutorialStyle.createTarget(
          keyTarget: _tutorialKeyRoundDuration,
          description: '한 라운드의 제한 시간이에요',
        ),
        AppTutorialStyle.createTarget(
          keyTarget: _tutorialKeyLocationShare,
          description: '도둑 위치가 경찰에게 공개되는 주기에요',
        ),
        AppTutorialStyle.createTarget(
          keyTarget: _tutorialKeyPoliceWait,
          description: '게임 시작 후 경찰이 출발할 때까지 기다리는 시간이에요',
        ),
      ];
    case 3:
      key = TutorialKeys.createStep3;
      targets = [
        AppTutorialStyle.createTarget(
          keyTarget: _tutorialKeySettingSummary,
          description: '설정한 내용을 확인하세요',
        ),
        AppTutorialStyle.createTarget(
          keyTarget: _tutorialKeyCreateButton,
          description: '버튼을 누르면 게임 방이 만들어져요',
        ),
      ];
    default:
      return;
  }

  final completed = await TutorialService.isCompleted(key);
  if (completed || !mounted) return;

  // 페이지 전환 애니메이션 완료 후 트리거
  await Future<void>.delayed(const Duration(milliseconds: 400));
  if (!mounted) return;

  AppTutorialStyle.show(
    context: context,
    targets: targets,
    onFinish: () => TutorialService.markCompleted(key),
  );
}
```

`initState`에서 Step 0 튜토리얼 트리거:

```dart
WidgetsBinding.instance.addPostFrameCallback((_) {
  _showStepTutorial(0);
});
```

페이지 전환 시:

```dart
_pageController.addListener(() {
  final page = _pageController.page?.round();
  if (page != null && page != _currentStep) {
    _currentStep = page;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showStepTutorial(page);
    });
  }
});
```

---

### Task 6: 대기실 튜토리얼

**Files:**

- Modify: `lib/features/session/presentation/pages/waiting_room_page.dart`

`WaitingRoomPage`는 이미 `ConsumerStatefulWidget`이다.

- [ ] **Step 1: GlobalKey 추가**

`_WaitingRoomPageState`에 추가:

```dart
final _tutorialKeyTeamSection = GlobalKey();
final _tutorialKeyReadyButton = GlobalKey();
final _tutorialKeyInviteCode = GlobalKey();
final _tutorialKeyGameRules = GlobalKey();
```

- [ ] **Step 2: 대상 위젯에 key 적용**

팀 선택 영역, 준비 완료 버튼, 초대 코드/공유 영역, 게임 규칙 버튼에 각각 GlobalKey 적용.

- [ ] **Step 3: 튜토리얼 트리거**

`initState`의 `addPostFrameCallback`에서:

```dart
Future<void> _showTutorialIfNeeded() async {
  final completed = await TutorialService.isCompleted(TutorialKeys.waitingRoom);
  if (completed || !mounted) return;

  AppTutorialStyle.show(
    context: context,
    targets: [
      AppTutorialStyle.createTarget(
        keyTarget: _tutorialKeyTeamSection,
        description: '경찰 또는 도둑 팀을 선택하세요',
        align: ContentAlign.bottom,
      ),
      AppTutorialStyle.createTarget(
        keyTarget: _tutorialKeyReadyButton,
        description: '준비가 되면 눌러주세요',
        align: ContentAlign.top,
      ),
      AppTutorialStyle.createTarget(
        keyTarget: _tutorialKeyInviteCode,
        description: '친구에게 초대 코드를 공유할 수 있어요',
      ),
      AppTutorialStyle.createTarget(
        keyTarget: _tutorialKeyGameRules,
        description: '게임 규칙을 확인할 수 있어요',
      ),
    ],
    onFinish: () => TutorialService.markCompleted(TutorialKeys.waitingRoom),
  );
}
```

---

### Task 7: 게임 화면 튜토리얼

**Files:**

- Modify: `lib/features/game/presentation/pages/game_page.dart`

`GamePage`는 이미 `ConsumerStatefulWidget`이다. Stack 기반 레이아웃에서 주요 요소에 GlobalKey를 부착한다.

**주의:** 게임 화면은 위치 권한 확인 후 초기화되므로, 튜토리얼은 `_initGameConnections()` 완료 후 트리거해야 한다.

- [ ] **Step 1: GlobalKey 추가**

`_GamePageState`에 추가:

```dart
final _tutorialKeyMap = GlobalKey();
final _tutorialKeyTimer = GlobalKey();
final _tutorialKeyParticipants = GlobalKey();
final _tutorialKeyChat = GlobalKey();
final _tutorialKeyQrButton = GlobalKey();
```

- [ ] **Step 2: 대상 위젯에 key 적용**

- 지도 (`GoogleMapView`) — 이미 `_googleMapKey`가 있지만 타입이 `GlobalKey<GoogleMapViewState>`. 튜토리얼용 별도 `GlobalKey`를 감싸는 Container/SizedBox에 부착
- 타이머 (`GameTimerText`) — key 적용
- 참가자 버튼 (`icon_person` SvgIconButton) — key 적용
- 채팅 (`ChatOverlay`) — key 적용
- QR 버튼 (`_buildQrButton()`) — key 적용

- [ ] **Step 3: 튜토리얼 트리거**

`_initGameConnections()` 끝에 튜토리얼 트리거 추가:

```dart
void _initGameConnections() {
  // ... 기존 코드 ...

  // 게임 초기화 완료 후 튜토리얼
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _showTutorialIfNeeded();
  });
}

Future<void> _showTutorialIfNeeded() async {
  final completed = await TutorialService.isCompleted(TutorialKeys.game);
  if (completed || !mounted) return;

  AppTutorialStyle.show(
    context: context,
    targets: [
      AppTutorialStyle.createTarget(
        keyTarget: _tutorialKeyMap,
        description: '게임 맵이에요. 내 위치와 구역이 표시돼요',
        shape: ShapeLightFocus.RRect,
      ),
      AppTutorialStyle.createTarget(
        keyTarget: _tutorialKeyTimer,
        description: '남은 게임 시간이에요',
      ),
      AppTutorialStyle.createTarget(
        keyTarget: _tutorialKeyParticipants,
        description: '현재 참가자 상태를 확인할 수 있어요',
      ),
      AppTutorialStyle.createTarget(
        keyTarget: _tutorialKeyChat,
        description: '팀원과 채팅할 수 있어요',
        align: ContentAlign.top,
      ),
      AppTutorialStyle.createTarget(
        keyTarget: _tutorialKeyQrButton,
        description: '상대방의 QR을 스캔하여 체포/탈옥해요',
      ),
    ],
    onFinish: () => TutorialService.markCompleted(TutorialKeys.game),
  );
}
```

---

### Task 8: 설정 페이지 — 튜토리얼 초기화 메뉴

**Files:**

- Modify: `lib/features/settings/presentation/pages/settings_page.dart`

- [ ] **Step 1: "이용 안내" 섹션에 튜토리얼 초기화 메뉴 추가**

"버그 제보" 항목 아래에 추가:

```dart
_buildItemDivider(),
_buildMenuItem(
  text: '튜토리얼 초기화',
  onTap: _onResetTutorial,
),
```

- [ ] **Step 2: 초기화 핸들러 구현**

```dart
Future<void> _onResetTutorial() async {
  final result = await AppDialog.confirm(
    context: context,
    title: '튜토리얼 초기화',
    message: '모든 화면의 튜토리얼을\n다시 볼 수 있도록 초기화할까요?',
    confirmText: '초기화',
  );
  if (result != true || !mounted) return;

  await TutorialService.resetAll();
  if (!mounted) return;

  AppSnackbar.show(context, message: '튜토리얼이 초기화되었어요');
}
```

- [ ] **Step 3: import 추가**

```dart
import '../../../../core/services/tutorial/tutorial_service.dart';
```

---

### Task 9: 통합 테스트

**Files:**

- 각 화면에서 수동 확인

- [ ] **Step 1: 앱 최초 실행 시뮬레이션**

SharedPreferences 클리어 후 앱 실행:

1. 홈 화면 → 방만들기/참여하기 튜토리얼 표시 확인
2. 방만들기 진입 → Step 0 튜토리얼 표시 확인
3. Step 1~3 순서대로 튜토리얼 표시 확인
4. 대기실 진입 → 튜토리얼 표시 확인
5. 게임 화면 진입 → 튜토리얼 표시 확인

- [ ] **Step 2: 재진입 시 튜토리얼 미표시 확인**

각 화면을 나갔다 다시 들어갔을 때 튜토리얼이 표시되지 않는지 확인.

- [ ] **Step 3: 설정에서 초기화 후 재표시 확인**

설정 → 튜토리얼 초기화 → 각 화면 재진입 시 튜토리얼 다시 표시 확인.
