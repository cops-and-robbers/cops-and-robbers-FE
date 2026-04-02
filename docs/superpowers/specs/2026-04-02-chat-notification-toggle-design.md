# 채팅 알림 토글 (Bell Icon) 설계

**날짜:** 2026-04-02
**이슈:** #156 (앱 전체 진동 피드백 추가의 연장)

---

## 목적

게임 중 채팅 오버레이에서 알림(진동 + 프리뷰 카드)을 끌 수 있는 벨 아이콘 토글을 제공한다.
읽지 않은 메시지 카운트는 알림 off 상태에서도 계속 증가하여 힌트 텍스트로 표시된다.

---

## 설계 원칙

- **SRP**: 알림 on/off 상태는 전용 provider가 관리. VibrationService는 진동만 책임.
- **게임당 1회성**: 인메모리 상태. 게임 종료 시 자동 초기화 (기본값: ON).
- **SharedPreferences 불사용**: 게임 간 상태 유지 불필요.

---

## 1. 새로운 Provider

### `chat_notification_provider.dart`

```dart
/// 채팅 알림 on/off — 게임당 1회성 인메모리 상태
final chatNotificationEnabledProvider = StateProvider<bool>((ref) => true);
```

- 기본값: `true` (게임 시작 시 알림 ON)
- 토글: `ref.read(provider.notifier).state = !current`
- 초기화: `ref.invalidate(chatNotificationEnabledProvider)`

---

## 2. VibrationService 정리

### 제거 대상

- `_isChatVibrationEnabled` 필드
- `_chatVibrationKey` 상수
- `isChatVibrationEnabled` getter
- `setChatVibrationEnabled()` 메서드
- `init()` 내 SharedPreferences 로딩 코드
- `messageReceived()` 내부의 on/off 체크 (`if (!_isChatVibrationEnabled) return;`)

### 변경 후 `messageReceived()`

```dart
/// 채팅 메시지 수신 진동 (호출자가 on/off 판단)
void messageReceived() {
  _vibrateSingle(
    VibrationPatterns.messageReceivedDuration,
    VibrationPatterns.messageReceivedAmplitude,
  );
}
```

---

## 3. ChatNotifier 변경 (`chat_provider.dart`)

### `_handleUnreadUpdate()` 수정

```
메시지 수신
  → 필터링 (자기 메시지, 차단 유저)
  → 현재 보고 있는 탭이면 return
  → unread count 증가 (항상 — 알림 상태 무관)
  → chatNotificationEnabledProvider 체크
    → true:  VibrationService.messageReceived() + lastPreviewMessage 설정
    → false: 진동 X, preview X (카운트만 증가된 상태 유지)
```

ChatNotifier가 `@riverpod` 코드 생성 기반이므로, `Ref`를 통해 provider를 읽는다:
```dart
final isNotificationOn = ref.read(chatNotificationEnabledProvider);
```

---

## 4. ChatOverlay UI 변경 (`chat_overlay.dart`)

### `_buildTitle()` → Row 구조로 변경

```
Row(
  children: [
    Text('전체 채팅' / '팀 채팅'),
    Spacer(),
    GestureDetector(            ← 벨 아이콘 (NEW)
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 48.w, height: 48.w,
        child: Center(
          child: SvgPicture.asset(
            isOn ? 'assets/icons/icon_bell_on.svg'
                 : 'assets/icons/icon_bell_off.svg',
            width: 24.w, height: 24.w,
            colorFilter: ColorFilter.mode(
              _resolveColor(isOn, isDarkMode),
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    ),
  ],
)
```

### 색상 매핑

| 상태 | 다크 모드 (도둑) | 라이트 모드 (경찰) |
|------|------------------|-------------------|
| ON   | AppColors.green  | AppColors.blue    |
| OFF  | AppColors.green500 | AppColors.blue500 |

### 탭 동작

```dart
onTap: () {
  VibrationService.instance().buttonTap();
  final current = ref.read(chatNotificationEnabledProvider);
  ref.read(chatNotificationEnabledProvider.notifier).state = !current;
}
```

---

## 5. 프리뷰 카드 표시 조건 변경 (`chat_overlay.dart`)

기존:
```dart
if (chatState.lastPreviewMessage != null)
  Positioned(... ChatPreviewCard ...)
```

변경:
```dart
final isNotificationOn = ref.watch(chatNotificationEnabledProvider);
if (isNotificationOn && chatState.lastPreviewMessage != null)
  Positioned(... ChatPreviewCard ...)
```

---

## 6. 게임 종료 시 초기화

### 위치: `game_page.dart` → `_showGameOverDialog()`

게임 종료 다이얼로그 표시 직전에 provider 초기화:

```dart
ref.invalidate(chatNotificationEnabledProvider);
```

이미 `_gameOverDialogShown` 가드가 있어 1회만 실행됨.

---

## 7. 힌트 텍스트 (변경 없음)

`chat_input_bar.dart`의 `_buildUnreadHint()`는 알림 상태와 무관하게
unread count만 참조하므로 수정 불필요. 알림 off여도 카운트 증가 → 힌트 자연스럽게 표시.

---

## 변경 파일 요약

| 파일 | 변경 유형 |
|------|-----------|
| `lib/features/chat/presentation/providers/chat_notification_provider.dart` | **신규** |
| `lib/core/services/vibration_service.dart` | 채팅 설정 로직 제거 |
| `lib/features/chat/presentation/providers/chat_provider.dart` | 알림 상태 체크 분기 |
| `lib/features/chat/presentation/widgets/chat_overlay.dart` | 벨 아이콘 + preview 조건 |
| `lib/features/game/presentation/pages/game_page.dart` | 게임 종료 시 invalidate |
