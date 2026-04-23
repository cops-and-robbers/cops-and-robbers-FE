# 재연결 모달 종료 후 구역 이탈 팝업 복구 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 게임 화면에서 구역 이탈 팝업이 떠 있는 상태로 웹소켓이 끊겨 재연결 모달이 올라왔을 때, 재연결 모달이 닫힌 후에도 여전히 구역 밖이라면 이탈 경고 팝업이 자동으로 복구되도록 수정한다.

**Architecture:**
재연결 모달 진입 시점의 판정 로직(`이탈 팝업 표시 중 || detector.isOutside → 보류 플래그 세팅`)을 `zone_exit_detector.dart` 같은 위치에 순수 함수로 추출한다. 순수 함수는 단위 테스트로 4가지 진리표 조합을 TDD 방식으로 검증한다. `_GamePageState._showReconnectModalIfNeeded()` 는 해당 함수를 호출하여 `_pendingZoneExit` 에 세팅한다. 재연결 모달 종료 후의 복구 경로(`_processPendingZoneExit`)는 기존 로직을 그대로 재사용한다.

**Tech Stack:** Flutter / Dart / 기존 `ZoneExitDetector` + `AppPopup` + `ReconnectModal` + `flutter_test`

**Spec:** `docs/superpowers/specs/2026-04-19-zone-exit-popup-reconnect-restoration-design.md`

---

## File Structure

### Modify
- `lib/features/game/domain/zone_exit_detector.dart`
  - 파일 하단에 순수 함수 `shouldMarkZoneExitAsPendingOnReconnect({required bool isPopupShown, required bool isDetectorOutside})` 추가
- `lib/features/game/presentation/pages/game_page.dart`
  - `_GamePageState._pendingZoneExit` 필드 dartdoc 주석 업데이트 (의미 확장 반영)
  - `_GamePageState._showReconnectModalIfNeeded()` 에서 추출된 함수를 사용해 보류 플래그 세팅

### Modify (Tests)
- `test/features/game/domain/zone_exit_detector_test.dart`
  - 신규 function `shouldMarkZoneExitAsPendingOnReconnect` 에 대한 group 추가 (진리표 4조합)

### Verify Unchanged
- `test/core/widgets/dialogs/zone_exit_popup_dismiss_test.dart` — 회귀 없음 확인용
- 기존 `ZoneExitDetector` 단위 테스트 7개 — 회귀 없음 확인용

---

## Task 1: 판정 로직 추출 + TDD로 검증 + game_page 에 연결

**Files:**
- Modify: `lib/features/game/domain/zone_exit_detector.dart`
- Modify: `test/features/game/domain/zone_exit_detector_test.dart`
- Modify: `lib/features/game/presentation/pages/game_page.dart`

이 Task 는 하나의 작업 단위로 "테스트 작성 + 구현 + 연결 + 검증"을 함께 수행한다 (RED/GREEN 분리 없음).

- [ ] **Step 1: 순수 함수 시그니처 작성 (구현은 단순 반환으로 시작)**

`lib/features/game/domain/zone_exit_detector.dart` 파일 맨 아래(클래스 닫는 `}` 뒤)에 아래 함수를 추가한다.

```dart
/// 재연결 모달 진입 시점에 구역 이탈 팝업 복구 예약이 필요한지 판단.
///
/// ZoneExitDetector는 상태 전환(안↔밖)에서만 콜백을 발화하므로,
/// 재연결 모달이 이탈 팝업을 강제로 닫은 뒤 위치 스트림이 돌아와도
/// 자동으로 다시 이탈 콜백이 울리지 않는다. 이 함수는 그 간극을 메우기 위해
/// 재연결 모달 진입 시점에 "복구 예약(pending)"이 필요한지 판정한다.
///
/// - [isPopupShown]: 이탈 팝업이 현재 표시 중인가.
/// - [isDetectorOutside]: detector의 현재 `isOutside` 값.
///
/// 둘 중 하나라도 `true`이면 재연결 모달이 닫힌 뒤 팝업 복구가 필요하다.
bool shouldMarkZoneExitAsPendingOnReconnect({
  required bool isPopupShown,
  required bool isDetectorOutside,
}) {
  return isPopupShown || isDetectorOutside;
}
```

- [ ] **Step 2: TDD 테스트 작성 — 진리표 4조합**

`test/features/game/domain/zone_exit_detector_test.dart` 파일 맨 아래의 `main()` 함수 안, 기존 `group('ZoneExitDetector', ...)` 의 **바로 다음에** 아래 group 을 추가한다.

```dart
  group('shouldMarkZoneExitAsPendingOnReconnect', () {
    test('팝업 숨김 + 구역 안 → false (재연결 후 복구 불필요)', () {
      final result = shouldMarkZoneExitAsPendingOnReconnect(
        isPopupShown: false,
        isDetectorOutside: false,
      );

      expect(result, isFalse);
    });

    test('팝업 숨김 + 구역 밖 → true (팝업이 아직 안 떴어도 이탈 중이면 복구)', () {
      final result = shouldMarkZoneExitAsPendingOnReconnect(
        isPopupShown: false,
        isDetectorOutside: true,
      );

      expect(result, isTrue);
    });

    test('팝업 표시 중 + 구역 안 → true (팝업이 떠 있으면 일단 복구 예약)', () {
      // detector가 안으로 갱신된 직후 팝업이 아직 정리 중인 경계 케이스.
      final result = shouldMarkZoneExitAsPendingOnReconnect(
        isPopupShown: true,
        isDetectorOutside: false,
      );

      expect(result, isTrue);
    });

    test('팝업 표시 중 + 구역 밖 → true (이번 버그의 핵심 시나리오)', () {
      final result = shouldMarkZoneExitAsPendingOnReconnect(
        isPopupShown: true,
        isDetectorOutside: true,
      );

      expect(result, isTrue);
    });
  });
```

- [ ] **Step 3: 추가한 테스트 실행해서 모두 통과하는지 확인**

Run:
```bash
cd /Users/luca/workspace/Flutter_Project/cops_and_robbers && flutter test test/features/game/domain/zone_exit_detector_test.dart
```

Expected:
- 기존 `ZoneExitDetector` group 7개 테스트 PASS
- 신규 `shouldMarkZoneExitAsPendingOnReconnect` group 4개 테스트 PASS
- 총 11 tests passed

실패 시:
- import 가 누락되었는지 확인: 테스트 파일 상단의 `import 'package:cops_and_robbers/features/game/domain/zone_exit_detector.dart';` 는 이미 존재하므로 함수도 같이 export 됨
- 함수명/파라미터 이름이 Step 1과 정확히 일치하는지 확인

- [ ] **Step 4: `_GamePageState._pendingZoneExit` 필드 주석을 의미 확장에 맞게 수정**

`lib/features/game/presentation/pages/game_page.dart` 의 현재 라인 147-149 부근.

Before:
```dart
  /// 재연결 모달 중 발생한 구역 이탈 보류 플래그
  /// (모달 닫힘 후 여전히 구역 밖이면 팝업 및 진동 처리)
  bool _pendingZoneExit = false;
```

After:
```dart
  /// 재연결 모달 종료 후 구역 이탈 팝업을 복구해야 함을 표시하는 보류 플래그.
  ///
  /// 다음 두 경로에서 `true` 로 세팅된다:
  /// 1) 재연결 모달 표시 중 새로 구역을 벗어난 경우 (`_zoneExitDetector.onExitZone`)
  /// 2) 재연결 모달 진입 시점에 이미 구역 밖이거나 이탈 팝업이 떠 있던 경우
  ///    (`_showReconnectModalIfNeeded` → `shouldMarkZoneExitAsPendingOnReconnect`)
  ///
  /// 모달이 닫히면 `_processPendingZoneExit()` 이 `_zoneExitDetector.isOutside`
  /// 를 재확인한 뒤 이탈 팝업과 진동을 복구한다. 구역으로 복귀하면
  /// `onEnterZone` 에서 `false` 로 리셋된다.
  bool _pendingZoneExit = false;
```

- [ ] **Step 5: `_showReconnectModalIfNeeded()` 에서 추출된 함수를 사용해 보류 플래그 세팅**

`lib/features/game/presentation/pages/game_page.dart` 의 현재 라인 801-804 부근 (`_dismissZoneExitPopup();` 호출 직전).

Before:
```dart
    // 구역 이탈 팝업이 떠 있으면 먼저 닫음
    // (재연결 모달이 스택 하단에 깔리면 pop()이 잘못된 다이얼로그를 닫는 버그 방지)
    _dismissZoneExitPopup();
    _reconnectStateNotifier = ValueNotifier(currentState.connectionState);
```

After:
```dart
    // 이탈 팝업이 떠 있거나 현재 구역 밖이라면, 재연결 모달이 닫힌 뒤
    // 팝업을 복구해야 함을 보류 플래그로 기록한다.
    // (ZoneExitDetector 는 상태 전환에만 콜백이 발화하므로 모달 종료 후
    //  위치 업데이트만으로는 자동 복구되지 않음)
    if (shouldMarkZoneExitAsPendingOnReconnect(
      isPopupShown: _isZoneExitPopupShown,
      isDetectorOutside: _zoneExitDetector.isOutside,
    )) {
      _pendingZoneExit = true;
    }

    // 구역 이탈 팝업이 떠 있으면 먼저 닫음
    // (재연결 모달이 스택 하단에 깔리면 pop()이 잘못된 다이얼로그를 닫는 버그 방지)
    _dismissZoneExitPopup();
    _reconnectStateNotifier = ValueNotifier(currentState.connectionState);
```

함수는 `zone_exit_detector.dart` 와 동일한 파일에서 export 되므로 `game_page.dart` 상단의 기존 import

```dart
import '../../domain/zone_exit_detector.dart';
```

한 줄로 참조 가능하다. 추가 import 필요 없음.

- [ ] **Step 6: `flutter analyze` 실행하여 정적 분석 경고 없는지 확인**

Run:
```bash
cd /Users/luca/workspace/Flutter_Project/cops_and_robbers && flutter analyze lib/features/game/domain/zone_exit_detector.dart lib/features/game/presentation/pages/game_page.dart test/features/game/domain/zone_exit_detector_test.dart
```

Expected: `No issues found!` 또는 이번 변경과 무관한 기존 경고만 표시.

신규 경고가 있다면:
- `shouldMarkZoneExitAsPendingOnReconnect` 의 파라미터 이름과 호출부 이름이 일치하는지 확인
- `_zoneExitDetector.isOutside` getter 존재 여부 재확인 (`lib/features/game/domain/zone_exit_detector.dart` 라인 19)

- [ ] **Step 7: 추가한 신규 테스트 + 기존 회귀 테스트 한 번 더 통과 확인**

Run:
```bash
cd /Users/luca/workspace/Flutter_Project/cops_and_robbers && flutter test test/features/game/domain/zone_exit_detector_test.dart test/core/widgets/dialogs/zone_exit_popup_dismiss_test.dart
```

Expected:
- `zone_exit_detector_test.dart`: 11 tests passed (기존 7 + 신규 4)
- `zone_exit_popup_dismiss_test.dart`: 기존 2 tests passed
- 총 13 tests passed

---

## Task 2: 전체 테스트 스위트 회귀 확인

**Files:** 수정 없음. 전체 회귀 검증만 수행.

- [ ] **Step 1: 프로젝트 전체 테스트 실행**

Run:
```bash
cd /Users/luca/workspace/Flutter_Project/cops_and_robbers && flutter test
```

Expected: 모든 테스트 통과. 이번 변경은 신규 함수 추가 + 1개 조건문 추가이므로 기존 실패가 없어야 함.

실패 시 확인:
- 실패한 테스트가 이번 변경과 연관되는지 분리
- 환경 문제(캐시 등)라면 `flutter clean && flutter pub get` 후 재실행

- [ ] **Step 2: `dart run build_runner build` 불필요 확인**

이번 변경은 `@riverpod` / `@freezed` / `@RestApi` / `@JsonSerializable` 어노테이션을 건드리지 않으므로 코드 생성 불필요.

확인: `git status` 에서 `*.g.dart` / `*.freezed.dart` 변경이 없는지 점검. 있으면 의도치 않은 변경이므로 원복.

---

## Task 3: 수동 QA 체크리스트

**Files:** 수정 없음. 실기기 또는 시뮬레이터로 통합 동작 검증.

단위 테스트가 판정 로직을 검증하지만, "재연결 모달 닫힘 → 이탈 팝업 복구" 라는 실제 UI 시퀀스는 수동 확인이 필요하다.

- [ ] **Step 1: 실기기 또는 에뮬레이터에서 게임 화면 진입**

준비: 실제 게임 방 생성 또는 더미 모드(`widget.isDummy == true`)로 게임 화면 진입.

- [ ] **Step 2: 시나리오 A (이번 버그의 핵심) — "구역 밖 + 이탈 팝업 → 웹소켓 끊김 → 재연결 성공"**

절차:
1. 플레이그라운드 밖으로 이동 (또는 가짜 위치 주입)
2. "플레이그라운드를 벗어났어요!" 팝업 표시 확인
3. 기기 네트워크 비활성화 (기내모드 토글 또는 Wi-Fi 끊기)
4. 재연결 모달이 올라오면서 이탈 팝업이 자동으로 사라지는지 확인
5. 네트워크 복구
6. 재연결 모달이 닫힌 직후 **이탈 팝업이 다시 표시되는지 확인** ← 이번 수정 목표
7. 구역으로 복귀 → 이탈 팝업 자동 닫힘 확인

기대 결과: Step 6에서 이탈 팝업이 복구되어야 하고, 진동도 함께 발화되어야 함.

- [ ] **Step 3: 시나리오 B — "구역 안 + 웹소켓 끊김 + 재연결" (회귀 확인)**

절차:
1. 플레이그라운드 안에 있는 상태 유지
2. 네트워크 비활성화 → 재연결 모달 표시 확인
3. 네트워크 복구 → 재연결 모달 닫힘

기대 결과: 이탈 팝업이 뜨지 않아야 함 (기존과 동일 동작).

- [ ] **Step 4: 시나리오 C — "재연결 모달 중 새로 이탈" (회귀 확인)**

절차:
1. 구역 안 상태 유지
2. 네트워크 비활성화 → 재연결 모달 표시
3. 모달이 떠 있는 동안 플레이그라운드 밖으로 이동
4. 네트워크 복구 → 재연결 모달 닫힘

기대 결과: 모달 닫힘 직후 이탈 팝업 + 진동 발화 (기존 기능, 회귀 없음 확인).

- [ ] **Step 5: 시나리오 D — "구역 밖 → 모달 중 구역 복귀 → 재연결 성공" (회귀 확인)**

절차:
1. 구역 밖으로 이동 → 이탈 팝업 표시
2. 네트워크 비활성화 → 재연결 모달 표시 (이탈 팝업 닫힘, 내부적으로 `_pendingZoneExit = true`)
3. 모달이 떠 있는 동안 구역으로 복귀 → `onEnterZone` 에서 `_pendingZoneExit = false` 리셋
4. 네트워크 복구 → 재연결 모달 닫힘

기대 결과: 이탈 팝업이 뜨지 않아야 함.

---

## Self-Review Checklist

### 1. Spec Coverage

| Spec 요구사항 | Task |
|-|-|
| 판정 로직 추출 및 단위 테스트 | Task 1 Step 1-3 |
| `_pendingZoneExit` 주석 의미 확장 | Task 1 Step 4 |
| `_showReconnectModalIfNeeded` 에 판정 함수 사용 | Task 1 Step 5 |
| 기존 로직(`_processPendingZoneExit`, `onEnterZone`) 재사용 | 코드 변경 없음 (회귀 검증은 Task 1 Step 7 + Task 2) |
| 엣지 케이스 검증 (7가지 시나리오) | 진리표 4조합: Task 1 Step 2 / UI 시나리오 4개: Task 3 Step 2-5 |
| 정적 분석 & 전체 테스트 통과 | Task 1 Step 6-7, Task 2 |

### 2. Placeholder 스캔

- TBD / TODO 없음
- "적절히 처리" / "에러 핸들링 추가" 식 문구 없음
- 모든 코드 블록에 실제 코드 표시

### 3. Type/Identifier 일관성

- `shouldMarkZoneExitAsPendingOnReconnect` 함수명 — Step 1 (정의), Step 2 (테스트), Step 5 (사용) 모두 동일
- 파라미터 이름 `isPopupShown`, `isDetectorOutside` — 정의/테스트/사용 모두 동일
- `_isZoneExitPopupShown` — 현재 코드 라인 139의 필드와 동일
- `_zoneExitDetector.isOutside` — `ZoneExitDetector` 클래스 라인 19의 getter 와 동일
- `_pendingZoneExit` — 라인 149의 필드, 의미만 확장
- `_dismissZoneExitPopup()` — 라인 763에 존재
- `_processPendingZoneExit()` — 라인 775에 존재

모두 일치.

---

## 참고

- Spec: `docs/superpowers/specs/2026-04-19-zone-exit-popup-reconnect-restoration-design.md`
- 이슈: `.issues/20260419_버그_게임스크린_팝업_중첩_사라짐.md`
- 관련 기존 파일:
  - `lib/features/game/domain/zone_exit_detector.dart`
  - `test/features/game/domain/zone_exit_detector_test.dart`
  - `lib/features/game/presentation/pages/game_page.dart`
  - `lib/core/widgets/dialogs/reconnect_modal.dart`
  - `lib/core/widgets/dialogs/app_popup.dart`
- 커밋은 사용자가 직접 트리거하므로 본 Plan에는 `git commit` 단계를 포함하지 않음.
