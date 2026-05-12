# 인게임 튜토리얼 자동 진입점 구현 계획

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 대기방 코치마크가 끝나는 시점에 인게임 튜토리얼 페이지를 안내하는 1버튼 다이얼로그를 추가한다. 신규 사용자가 게임 시작 전에 인게임 화면 동작을 학습할 수 있도록 강제 노출하되, 한 번 노출되면 다시 뜨지 않는다.

**Architecture:** `WaitingRoomPage`의 기존 코치마크 `onFinish` 콜백을 확장한다. `SharedPreferences` 키 1개(`tutorial_in_game_prompt`)로 1회 노출을 보장하고, `AppDialog.show()` 1버튼 모드(`barrierDismissible: false`, "보러 가기")로 다이얼로그를 띄운 뒤 확인 시 `context.push('/tutorial/in-game')`로 이동한다. 인게임 튜토리얼 페이지의 완료 다이얼로그는 이미 caller-agnostic("튜토리얼 끝내기" → `context.pop()`)이라 자동으로 대기방으로 복귀한다.

**Tech Stack:** Flutter, SharedPreferences, go_router, 기존 `TutorialService` / `AppDialog`.

**Spec:** [docs/superpowers/specs/2026-05-11-in-game-tutorial-entry-point-design.md](../specs/2026-05-11-in-game-tutorial-entry-point-design.md)

---

## File Structure

| 파일 | 책임 |
|---|---|
| `lib/core/services/tutorial/tutorial_keys.dart` (수정) | `inGamePrompt` 상수 + `all` 리스트 갱신 |
| `lib/features/session/presentation/pages/waiting_room_page.dart` (수정) | 기존 코치마크 `onFinish` 콜백 → 비동기 + `_showInGameTutorialPromptIfNeeded` 호출 / 신규 private 메서드 추가 |
| `test/core/services/tutorial/tutorial_keys_test.dart` (수정) | 신규 키가 `all` 리스트에 포함되는지 단위 테스트 추가 |

`waiting_room_page.dart` 자체에 대한 위젯 테스트는 추가하지 않는다 — 코치마크 라이브러리의 GlobalKey 마운트 + 다수 Riverpod provider mock이 필요해 비용 대비 가치가 낮다. 다이얼로그 분기 로직은 단순 SharedPreferences 체크 1번 + 1개의 새 메서드이므로 수동 스모크 테스트로 충분히 검증 가능. 키 관리·`all` 포함 여부는 단위 테스트로 보장.

---

## Task 1: SharedPreferences 키 추가 + 단위 테스트

**Files:**
- Modify: `lib/core/services/tutorial/tutorial_keys.dart`
- Modify: `test/core/services/tutorial/tutorial_keys_test.dart`

- [ ] **Step 1 (RED): 실패 테스트 추가**

`test/core/services/tutorial/tutorial_keys_test.dart`의 `void main()` 내부에 새 group 추가:

```dart
  group('TutorialKeys.inGamePrompt', () {
    test('단일 키 상수 값', () {
      expect(TutorialKeys.inGamePrompt, 'tutorial_in_game_prompt');
    });

    test('TutorialKeys.all 에 포함된다', () {
      expect(TutorialKeys.all, contains(TutorialKeys.inGamePrompt));
    });
  });
```

- [ ] **Step 2: 테스트 실행 — 실패 확인**

```bash
flutter test test/core/services/tutorial/tutorial_keys_test.dart
```
Expected: 새 테스트 2건 FAIL (`The getter 'inGamePrompt' isn't defined`)

- [ ] **Step 3 (GREEN): 키 추가**

`lib/core/services/tutorial/tutorial_keys.dart` 전체 교체:

```dart
/// 튜토리얼 화면별 SharedPreferences 키 상수
class TutorialKeys {
  TutorialKeys._();

  static const home = 'tutorial_home';
  static const createStep0 = 'tutorial_create_step0';
  static const setupPlayground = 'tutorial_setup_playground';
  static const createStep2 = 'tutorial_create_step2';

  // 대기실 튜토리얼: 역할(경찰/도둑) 무관 사용자당 1회만 노출.
  // 모든 스텝(팀 변경·초대 코드·게임 설정·준비 버튼)이 양 팀에서 동일한
  // 안내이므로 팀별 분리가 불필요. 1번 스텝 타겟만 "현재 팀의 반대 팀 첫
  // 빈 슬롯"으로 호출 시점의 team 값으로 결정된다(키와 무관).
  static const waitingRoom = 'tutorial_waiting_room';

  // 대기방 코치마크 완료 후 인게임 튜토리얼 페이지 안내 다이얼로그를
  // 1회만 노출하기 위한 키. "튜토리얼 초기화" 시 함께 reset되어 재노출됨.
  static const inGamePrompt = 'tutorial_in_game_prompt';

  /// 전체 키 목록 (초기화 시 사용)
  static const all = [
    home,
    createStep0,
    setupPlayground,
    createStep2,
    waitingRoom,
    inGamePrompt,
  ];
}
```

- [ ] **Step 4: 테스트 실행 — 통과 확인**

```bash
flutter test test/core/services/tutorial/tutorial_keys_test.dart
```
Expected: `+4: All tests passed!` (기존 2건 + 신규 2건)

- [ ] **Step 5: analyze**

```bash
flutter analyze lib/core/services/tutorial/ test/core/services/tutorial/
```
Expected: `No issues found!`

- [ ] **Step 6: Commit**

```bash
git add lib/core/services/tutorial/tutorial_keys.dart \
        test/core/services/tutorial/tutorial_keys_test.dart
git commit -m "feat : 인게임 튜토리얼 안내 1회 노출용 inGamePrompt 키 추가 #336"
```

---

## Task 2: 대기방 코치마크 onFinish 확장

**Files:**
- Modify: `lib/features/session/presentation/pages/waiting_room_page.dart`

이 태스크에서:
1. 기존 코치마크 `onFinish` 콜백을 비동기로 바꾸고 신규 메서드 호출
2. `_showInGameTutorialPromptIfNeeded` private 메서드 추가
3. 기존 cleanup 2줄(`_tutorialController = null` / `_isTutorialShowing = false`)을 그대로 유지

- [ ] **Step 1: 현재 `onFinish` 위치 확인**

```bash
grep -n "onFinish: ()" lib/features/session/presentation/pages/waiting_room_page.dart
```
Expected: 1개 매치 (line 564 부근)

- [ ] **Step 2: onFinish 콜백 교체**

기존 코드(line 561-569 부근):

```dart
    _tutorialController = AppTutorialStyle.show(
      context: context,
      targets: targets,
      onFinish: () {
        TutorialService.markCompleted(key);
        _tutorialController = null;
        _isTutorialShowing = false;
      },
    );
```

위 코드를 다음으로 교체:

```dart
    _tutorialController = AppTutorialStyle.show(
      context: context,
      targets: targets,
      onFinish: () async {
        TutorialService.markCompleted(key);
        _tutorialController = null;
        _isTutorialShowing = false;
        if (!mounted) return;
        await _showInGameTutorialPromptIfNeeded();
      },
    );
```

변경 포인트:
- `() {` → `() async {`
- 기존 3줄 cleanup 그대로 유지
- 끝에 `if (!mounted) return;` + `await _showInGameTutorialPromptIfNeeded();` 2줄 추가

- [ ] **Step 3: `_showInGameTutorialPromptIfNeeded` 메서드 추가**

`_showTutorialIfNeeded` 메서드 바로 아래(즉 `_showTutorialIfNeeded`의 닫는 `}` 다음 줄)에 다음 메서드를 삽입한다:

```dart
  /// 대기방 코치마크가 처음 끝난 직후 1회 노출되는 인게임 튜토리얼 안내.
  ///
  /// 키가 이미 mark되어 있으면 아무 동작도 하지 않는다.
  /// 다이얼로그 표시 **전에** mark를 수행해 어떤 이유로 다이얼로그가
  /// 중단되더라도 영구 재노출을 방지한다.
  Future<void> _showInGameTutorialPromptIfNeeded() async {
    final shown = await TutorialService.isCompleted(
      TutorialKeys.inGamePrompt,
    );
    if (shown || !mounted) return;

    await TutorialService.markCompleted(TutorialKeys.inGamePrompt);
    if (!mounted) return;

    await AppDialog.show<void>(
      context: context,
      title: '인게임 화면 미리 보기',
      message: '게임이 시작되면 어떻게 동작하는지\n한 번 확인하고 시작해볼까요?',
      confirmText: '보러 가기',
      barrierDismissible: false,
      onConfirm: () => context.push('/tutorial/in-game'),
    );
  }
```

- [ ] **Step 4: analyze**

```bash
flutter analyze lib/features/session/presentation/pages/waiting_room_page.dart
```
Expected: `No issues found!`

- [ ] **Step 5: 기존 테스트 영향 없는지 확인**

```bash
flutter test test/features/session/ test/core/services/tutorial/
```
Expected: 기존 테스트 모두 통과 (회귀 없음)

- [ ] **Step 6: Commit**

```bash
git add lib/features/session/presentation/pages/waiting_room_page.dart
git commit -m "$(cat <<'EOF'
feat : 대기방 코치마크 완료 시 인게임 튜토리얼 안내 다이얼로그 #336

- onFinish 콜백을 async로 확장, _showInGameTutorialPromptIfNeeded 호출
- 1버튼 다이얼로그 ('보러 가기'), barrierDismissible: false
- mark 먼저 수행 후 다이얼로그 표시 — 중단되어도 영구 재노출 방지
- 기존 cleanup 2줄(_tutorialController, _isTutorialShowing) 유지
EOF
)"
```

---

## Task 3: 수동 검증 체크리스트

자동화 어려운 부분을 수동으로 확인. 시뮬레이터/디바이스에서 진행.

- [ ] **케이스 A — 신규 사용자 정상 흐름**

1. 설정 → "튜토리얼 초기화" 탭 → 확인 → 홈으로 이동
2. 방 만들기 또는 참여하기 → 대기방 진입
3. 대기방 코치마크가 자동 표시되는지 확인
4. 코치마크 마지막 스텝까지 진행
5. "인게임 화면 미리 보기" 다이얼로그가 자동으로 뜨는지 확인
6. 다이얼로그 밖 영역 탭 → 닫히지 않아야 함 (`barrierDismissible: false`)
7. "보러 가기" 탭 → `/tutorial/in-game` 페이지로 이동 확인
8. 인게임 튜토리얼 3스텝 미션 진행 → "튜토리얼 끝내기" 탭 → 대기방으로 복귀 확인

- [ ] **케이스 B — 이미 본 사용자**

1. 케이스 A 완료 직후, 대기방에서 나가서 다시 진입
2. 코치마크가 안 뜨는지 확인 (기존 동작)
3. "인게임 화면 미리 보기" 다이얼로그도 안 뜨는지 확인

- [ ] **케이스 C — 초기화 후 재노출**

1. 설정 → "튜토리얼 초기화" 탭 → 확인
2. 대기방 재진입 → 코치마크 다시 뜸 확인
3. 코치마크 완료 → 다이얼로그도 다시 뜸 확인

- [ ] **케이스 D — KICKED 동시 발생**

1. 호스트와 게스트 2명 디바이스 준비
2. 게스트가 대기방 입장 → 코치마크 진행 중 호스트가 강퇴
3. 게스트 화면에서 코치마크 중단 + 강퇴 다이얼로그 → 홈으로 이동 확인
4. (튜토리얼 페이지 전이 후 강퇴 시뮬레이션도 동일하게 확인)

---

## Self-Review

### Spec 커버리지

| Spec 요구사항 | 매핑 태스크 |
|---|---|
| `TutorialKeys.inGamePrompt` 추가 + `all` 갱신 | Task 1 |
| `WaitingRoomPage._showInGameTutorialPromptIfNeeded` 메서드 추가 | Task 2 Step 3 |
| 기존 코치마크 `onFinish` async + 신규 호출 체인 | Task 2 Step 2 |
| 기존 cleanup 2줄 유지 | Task 2 Step 2 (명시) |
| `barrierDismissible: false` + 1버튼 모드 | Task 2 Step 3 |
| mark 먼저 / 다이얼로그 나중 | Task 2 Step 3 (코드 + 주석) |
| 위젯 테스트 — 키 단위 테스트로 대체 (스코프 결정 명시) | File Structure 섹션 |
| 수동 케이스 (A~D) | Task 3 |
| `flutter analyze` clean | Task 1 Step 5 + Task 2 Step 4 |
| 단위 테스트 통과 | Task 1 Step 4 + Task 2 Step 5 |

### Placeholder 스캔

- "TBD"·"TODO"·"implement later" 패턴 0건
- 모든 코드 스니펫이 완전 (직접 붙여넣기 가능)
- 명령어 + 기대 출력 명시

### 타입 일관성

- `TutorialKeys.inGamePrompt`: `String` 상수 (`'tutorial_in_game_prompt'`)
- `TutorialKeys.all`: `List<String>`, `inGamePrompt` 추가
- `_showInGameTutorialPromptIfNeeded`: `Future<void>` 반환, `_CreateRoomTutorialPageState` 아닌 `_WaitingRoomPageState` 내부 메서드
- `AppDialog.show<void>`: 시그니처는 `context` (required), `title`/`message` (String?), `confirmText` (String 기본 '확인'), `barrierDismissible` (bool 기본 true), `onConfirm` (VoidCallback?). 모든 인자 호출 시 명시.
- `context.push('/tutorial/in-game')`: 기존 등록된 라우트와 일치 (`app_router.dart`에 등록 확인 완료)

이슈 없음.

---

**작성자**: Claude (writing-plans skill)
**브랜치**: `20260507_#336_별도_튜토리얼_페이지_신설_및_기존_코치마크_시스템_대체`
