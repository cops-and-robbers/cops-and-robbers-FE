# AppPopup 자동 닫힘 + 터치 차단 설계

## 배경

`AppPopup`은 버튼 없이 콘텐츠만 표시하는 팝업으로, 타이머/게임 종료/카운트다운 등에 사용된다.
현재는 배경 터치로 닫을 수 있고, 자동 닫힘 기능이 없어 게임 중 의도치 않은 dismiss가 발생할 수 있다.

## 요구사항

1. 팝업이 떠 있는 동안 **화면 터치 완전 차단** (배경 터치 + Android 뒤로가기)
2. 지정된 시간 후 **자동 닫힘**
3. 닫힌 후 **호출 쪽에서 자유롭게 후속 처리** (GoRouter 이동, 이벤트 등)
4. 기존 호출부 하위 호환 유지

## 설계

### 변경 대상

`lib/core/widgets/dialogs/app_popup.dart`

### API 변경

```dart
static Future<T?> show<T>({
  required BuildContext context,
  required Widget content,
  bool barrierDismissible = true,
  Duration? autoCloseDuration, // 신규: null이면 자동 닫힘 없음
})
```

### 동작 정리

| autoCloseDuration | barrierDismissible | 결과 |
|---|---|---|
| null | true | 기존과 동일 (배경 터치로 닫기 가능) |
| null | false | 수동 닫힘 필요 |
| 5초 | false | 5초 후 자동 닫힘, 터치/뒤로가기 차단 |

### 구현 상세

1. `AppPopup`을 `StatefulWidget`으로 변경
2. `initState`에서 `autoCloseDuration`이 있으면 `Future.delayed` → `Navigator.pop()`
3. `dispose`에서 타이머 정리 (팝업이 외부에서 먼저 닫힌 경우 대비)
4. `PopScope(canPop: false)`로 Android 뒤로가기 차단 (autoCloseDuration 지정 시)
5. `show()`의 `Future<T?>` 완료로 후속 처리 가능

### 사용 예시

```dart
// 타이머 팝업 (서버에서 받은 duration)
await AppPopup.show(
  context: context,
  content: TimerWidget(),
  autoCloseDuration: Duration(seconds: serverValue),
  barrierDismissible: false,
);

// 게임 종료 팝업 (상수)
await AppPopup.show(
  context: context,
  content: GameOverWidget(),
  autoCloseDuration: kGameOverPopupDuration,
  barrierDismissible: false,
);
context.go('/game/result');

// 기존 사용법 (변경 없음)
AppPopup.show(context: context, content: SomeWidget());
```
