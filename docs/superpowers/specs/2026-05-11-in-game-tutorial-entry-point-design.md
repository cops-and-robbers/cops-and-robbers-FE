# 인게임 튜토리얼 자동 진입점 설계

**작성일**: 2026-05-11
**브랜치**: `20260507_#336_별도_튜토리얼_페이지_신설_및_기존_코치마크_시스템_대체`
**관련 이슈**: #336

---

## 1. 목표

`/tutorial/in-game` 페이지가 카탈로그·설정 메뉴를 통한 수동 접근만 가능한 상태다. 신규 사용자가 인게임 화면에서 헤매는 일을 막기 위해 **대기방에서 자동으로 안내 다이얼로그를 띄워 한 번만 강제 노출**하는 진입점을 추가한다.

## 2. 핵심 결정

### 노출 시점

**대기방 코치마크가 처음 끝난 직후 1회**.

- 이미 학습 모드에 진입한 타이밍이라 추가 다이얼로그가 자연스럽다
- 코치마크 진행 중에는 사용자가 "준비 완료" 버튼을 못 누름 → 호스트가 게임 시작 못함 → "튜토리얼 보는 도중 GAME_START 도착" 시나리오가 구조적으로 차단된다
- 학습-실전 간격이 짧다 (튜토리얼 끝내기 → 대기방 복귀 → 준비 완료 → 게임 시작)

### UX 형태

- `AppDialog.show()` 1버튼 모드 (취소 버튼 없음, "보러 가기"만)
- `barrierDismissible: false` → 밖 영역 탭으로 닫기 불가
- 확인 시 `context.push('/tutorial/in-game')`
- 튜토리얼 페이지의 완료 다이얼로그는 이미 "튜토리얼 끝내기" 1버튼이라 caller-agnostic → `context.pop()`으로 대기방 복귀

### 1회 보장

`SharedPreferences` 키 `TutorialKeys.inGamePrompt` 신설. `all` 리스트에 포함시켜 "튜토리얼 초기화" 시 함께 reset (재노출됨).

### 거절 정책

거절 버튼 없음 → 의도적으로 강제. 사용자는 "보러 가기"만 누를 수 있고 그 즉시 키가 mark된다.

## 3. 흐름

```
[처음 대기방 진입]
   ↓
대기방 코치마크 시작
   ↓
모든 step 통과
   ↓
onFinish 콜백:
   1. TutorialService.markCompleted(TutorialKeys.waitingRoom)   ← 기존
   2. TutorialKeys.inGamePrompt 미완료인지 확인                  ← 신규
   3. 미완료 → mark 먼저 → AppDialog 노출 ("보러 가기")
                ↓ (확인 탭)
                context.push('/tutorial/in-game')
                ↓ (튜토리얼 끝내기 탭)
                context.pop() → 대기방 복귀
   4. 이미 완료 → 다이얼로그 안 띄움
```

## 4. 구현 단위

### 4.1 키 추가

`lib/core/services/tutorial/tutorial_keys.dart`:
```dart
/// 대기방 코치마크 완료 후 인게임 튜토리얼 안내 다이얼로그 1회 노출용
static const inGamePrompt = 'tutorial_in_game_prompt';
```
`all` 리스트에 포함.

### 4.2 대기방 페이지 콜백 확장

`lib/features/session/presentation/pages/waiting_room_page.dart`의 기존 `AppTutorialStyle.show(..., onFinish: ...)` 콜백을 비동기로 바꾸고 다이얼로그 호출 추가:

```dart
onFinish: () async {
  TutorialService.markCompleted(TutorialKeys.waitingRoom);
  _tutorialController = null;
  _isTutorialShowing = false;
  if (!mounted) return;
  await _showInGameTutorialPromptIfNeeded();
},

Future<void> _showInGameTutorialPromptIfNeeded() async {
  final shown = await TutorialService.isCompleted(TutorialKeys.inGamePrompt);
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

`mark`를 다이얼로그 표시 **전에** 한다 — 다이얼로그가 어떤 이유로 중단돼도 영구 재노출 방지.

기존 `onFinish` cleanup 2줄(`_tutorialController = null`·`_isTutorialShowing = false`)을 그대로 유지한다. 누락하면 dispose 경로에서 dangling reference + 재진입 가드 깨짐.

## 5. Edge Case

| 시나리오 | 처리 |
|---|---|
| **S1: 튜토리얼 중 GAME_START** | 구조적 차단. 사용자가 "준비 완료" 안 눌렀으므로 호스트가 게임 시작 불가. 추가 코드 불필요. |
| **S2: 튜토리얼 중 KICKED** | 인게임 튜토리얼 페이지는 외부 이벤트 listen 안 함. 사용자가 "튜토리얼 끝내기"로 대기방 복귀 시점에 기존 KICKED 처리 발동. 추가 코드 불필요. |
| **S3: 시스템 뒤로가기** | `context.pop()` 허용. 대기방으로 자연 복귀. 이미 동작. |
| **S4: 다이얼로그 중 백그라운드** | `AppDialog`의 자체 lifecycle. mark가 이미 됐으므로 복귀 시 재노출 없음. |
| **S5: 호스트가 본인 대기방 코치마크 도중 게임 시작 시도** | 동일 — 본인 미준비 상태라 시작 불가. |
| **S6: 대기방 재진입 시 다시 다이얼로그?** | `inGamePrompt` 키가 영구 mark되어 있어 안 뜸. 사용자가 설정 → "튜토리얼 초기화" 누르면 재노출. |

## 6. 비포함 (Out of Scope)

- 인게임 튜토리얼 페이지에서 외부 이벤트(GAME_START·KICKED) 직접 listen — 의존성 폭증, 현재 디자인은 자연 차단으로 해결됨
- 거절 버튼 / "다음에 보기" 옵션 — 강제 노출 정책으로 명시 결정
- 백엔드 API 동기화 — 로컬 SharedPreferences로 충분, 기기 변경 시 재노출은 무해
- 대기방이 아닌 다른 화면(홈, 세션 생성, 게임 시작 직전)에서 자동 노출

## 7. 테스트 (위젯 테스트)

대기방의 코치마크 onFinish 콜백 분기 검증:

| 케이스 | 기대 동작 |
|---|---|
| `inGamePrompt` 미완료 → 코치마크 onFinish 호출 | "인게임 화면 미리 보기" 다이얼로그 가시 |
| 다이얼로그 "보러 가기" 탭 | `/tutorial/in-game` 라우트로 push |
| `inGamePrompt` 이미 완료 → 코치마크 onFinish 호출 | 다이얼로그 안 뜸 |
| 다이얼로그 노출 직전에 mark 완료됐는지 검증 | SharedPreferences에 `tutorial_in_game_prompt`=true |

코치마크 자체 동작(GlobalKey 타깃 표시 등)은 테스트 대상 아님 (외부 라이브러리). `barrierDismissible: false` 등 dialog 옵션도 별도 테스트 안 함 (`AppDialog` 자체 책임).

## 8. 디자인 시스템 준수

- 다이얼로그는 `AppDialog.show()` 표준 진입점 사용 — `AppColors`·`AppTextStyles`·`AppRadius` 자동 적용
- 추가 색상·텍스트 스타일 정의 없음

## 9. 작업 항목 체크리스트

- [ ] `TutorialKeys.inGamePrompt` 추가 + `all` 리스트 갱신
- [ ] `WaitingRoomPage._showInGameTutorialPromptIfNeeded` 메서드 추가
- [ ] 기존 코치마크 `onFinish` 콜백 → 비동기로 변경, `_showInGameTutorialPromptIfNeeded` 호출 체인
- [ ] 위젯 테스트 추가 (`test/features/session/presentation/pages/waiting_room_page_in_game_prompt_test.dart` 등)
- [ ] `flutter analyze lib/features/session/ lib/core/services/tutorial/` clean
- [ ] `flutter test test/features/session/` 신규 테스트 통과
