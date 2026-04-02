# 인게임 시스템 공지 메시지 업데이트 구현 계획

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** `GameEventMessages`를 확장하여 체포/탈옥/경찰출동/위치공개/게임종료 5분전 공지 메시지를 추가하고, 체포 공지 시스템 채팅에 경찰·도둑 인라인 아이콘을 표시한다.

**Architecture:** `GameEventMessages` 상수 클래스에 새 메시지를 추가하고, 동적 파라미터가 필요한 메시지는 static 메서드로 구현한다. 체포 공지 메시지에 `@icon_police`/`@icon_robber` 마커를 삽입하고, `_buildSystemMessage`에서 마커를 파싱하여 SVG 아이콘 `WidgetSpan`으로 렌더링한다.

**Tech Stack:** Dart, Flutter (RichText + WidgetSpan), Riverpod, STOMP WebSocket

---

## 변경 대상 파일

| 파일 | 작업 | 설명 |
|------|------|------|
| `lib/core/constants/game_event_messages.dart` | 수정 | 메시지 상수 수정 + 동적 메서드 추가 |
| `lib/features/game/presentation/providers/game_event_provider.dart` | 수정 | 체포/탈옥 배너 메시지 + 경찰 닉네임 파싱 |
| `lib/features/game/presentation/pages/game_page.dart` | 수정 | 체포/탈옥/게임시작 시스템 채팅 메시지 주입 |
| `lib/features/chat/presentation/widgets/chat_message_bubble.dart` | 수정 | 시스템 메시지 인라인 아이콘 렌더링 |

---

## 메시지 변경 명세

### 기존 메시지 수정

| 기존 | 변경 후 | 비고 |
|------|---------|------|
| `게임이 곧 시작됩니다. 모든 플레이어는 준비하세요!` | 3단계 시퀀스로 분리 (아래 참조) | START 이벤트 |
| `경찰이 출동합니다!` | `경찰 출동! 도둑은 도망치세요!` | POLICE_MOVE_START 이벤트 |
| `현재 도둑의 위치가 공개됩니다!` | 유지 + 도주 인원 메시지 추가 | LOCATION_REVEAL 이벤트 |
| `게임이 종료되었습니다!` | 삭제 (모달로 대체, 별도 공지 X) | GAME_OVER 이벤트 |

### 새 메시지 추가

| 이벤트 | 메시지 | 타입 |
|--------|--------|------|
| 게임 시작 1 | `제한 시간은 {n}분입니다. 잠시 후 게임이 시작됩니다. 모든 플레이어는 준비하세요!` | 메서드 (동적 n) |
| 게임 시작 2 | `게임 중 채팅을 길게 눌러 불편한 유저를 신고 및 차단할 수 있습니다.` | 상수 |
| 게임 시작 3 | `게임 시작! 행운을 빕니다!` | 상수 |
| 경찰 출동 예고 | `경찰이 곧 출동합니다. 도둑은 서둘러 이동하세요!` | 상수 |
| 경찰 출동 | `경찰 출동! 도둑은 도망치세요!` | 상수 |
| 위치 공개 도주인원 | `현재 {n}명 도주 중!` | 메서드 (동적 n) |
| 체포 공지 | `@icon_police {경찰닉네임}님이 @icon_robber {도둑닉네임}님을 체포했습니다!` | 메서드 (동적, 아이콘 마커 포함) |
| 탈옥 공지 | `도둑이 탈옥했습니다! 지금 바로 체포하세요!` | 상수 |
| 게임 종료 5분 전 | `게임 종료까지 5분 남았습니다. 마지막 기회를 놓치지 마세요!` | 상수 |

### 인라인 아이콘 마커 규칙

체포 공지 문자열에 `@icon_police`, `@icon_robber` 마커를 삽입한다.
`_buildSystemMessage`에서 정규식으로 마커를 파싱하여 해당 위치에 SVG 아이콘 `WidgetSpan`을 렌더링한다.

- `@icon_police` → `assets/icons/icon_police_darkmode.svg` (다크) / `icon_police_lightmode.svg` (라이트)
- `@icon_robber` → `assets/icons/mdi_robber_darkmode.svg` (다크) / `mdi_robber_lightmode.svg` (라이트)
- 아이콘 크기: 16x16 (기존 Loudspeaker와 동일)
- **색상 변경 없음** — `colorFilter` 적용하지 않고 원본 SVG 색상 그대로 사용

---

## Task 1: GameEventMessages 상수 클래스 수정

**Files:**
- Modify: `lib/core/constants/game_event_messages.dart`

- [ ] **Step 1: 기존 메시지 수정 및 새 메시지 추가**

`lib/core/constants/game_event_messages.dart` 전체를 아래로 교체:

```dart
/// 게임 이벤트 배너 및 시스템 채팅 메시지 상수
///
/// 배너(game_event_provider)와 전체채팅 시스템 메시지(game_page)에서
/// 동일한 문자열을 사용하기 위한 단일 소스.
/// 체포 공지 등 일부 메시지에는 @icon_police / @icon_robber 마커가 포함되며,
/// chat_message_bubble의 _buildSystemMessage에서 인라인 SVG로 치환된다.
abstract final class GameEventMessages {
  // ── START 이벤트 (3단계 시퀀스) ──

  /// START 1단계 — 제한 시간 안내 (동적 n분)
  static String gameStartCountdown(int minutes) =>
      '제한 시간은 $minutes분입니다. 잠시 후 게임이 시작됩니다. 모든 플레이어는 준비하세요!';

  /// START 2단계 — 신고/차단 안내
  static const gameStartReportTip =
      '게임 중 채팅을 길게 눌러 불편한 유저를 신고 및 차단할 수 있습니다.';

  /// START 3단계 — 게임 시작 확정
  static const gameStartGo = '게임 시작! 행운을 빕니다!';

  // ── POLICE_MOVE_START 이벤트 (2단계 시퀀스) ──

  /// 경찰 출동 예고
  static const policeMoveWarning =
      '경찰이 곧 출동합니다. 도둑은 서둘러 이동하세요!';

  /// 경찰 출동 확정
  static const policeMove = '경찰 출동! 도둑은 도망치세요!';

  // ── LOCATION_REVEAL 이벤트 ──

  /// 도둑 위치 공개 안내
  static const locationReveal = '현재 도둑의 위치가 공개됩니다!';

  /// 도주 중인 도둑 인원 (동적 n명)
  static String remainingRobbers(int count) => '현재 $count명 도주 중!';

  // ── ARREST 이벤트 ──

  /// 체포 공지 (동적 — 경찰·도둑 닉네임 + 인라인 아이콘 마커)
  static String arrestNotice(String policeNickname, String robberNickname) =>
      '@icon_police $policeNickname님이 @icon_robber $robberNickname님을 체포했습니다!';

  // ── ESCAPE 이벤트 ──

  /// 탈옥 공지
  static const escapeNotice = '도둑이 탈옥했습니다! 지금 바로 체포하세요!';

  // ── 게임 종료 5분 전 ──

  /// 게임 종료 5분 전 경고
  static const fiveMinutesLeft =
      '게임 종료까지 5분 남았습니다. 마지막 기회를 놓치지 마세요!';
}
```

- [ ] **Step 2: 정적 분석 확인**

Run: `cd /Users/luca/workspace/Flutter_Project/cops_and_robbers && flutter analyze lib/core/constants/game_event_messages.dart`
Expected: 에러 없음 (단, 사용처에서 삭제된 `gameStart`/`gameOver` 참조 에러는 Task 2에서 수정)

- [ ] **Step 3: 커밋**

```bash
git add lib/core/constants/game_event_messages.dart
git commit -m "feat : 시스템 공지 메시지 상수 추가 및 기존 문구 수정 #211"
```

---

## Task 2: game_event_provider 배너 메시지 연동

**Files:**
- Modify: `lib/features/game/presentation/providers/game_event_provider.dart`

- [ ] **Step 1: GameEventState에 `lastArrestPoliceNickname` 필드 추가**

`GameEventState` 클래스에 새 필드 추가:

```dart
/// 가장 최근 체포한 경찰 닉네임 (ARREST 이벤트 공지용)
final String? lastArrestPoliceNickname;
```

생성자 파라미터에 `this.lastArrestPoliceNickname,` 추가.
`copyWith` 메서드에도 반영 (기존 패턴 따라 sentinel 방식 사용).

- [ ] **Step 2: _handleStart 수정 — `GameEventMessages.gameStart` → `gameStartGo`**

```dart
void _handleStart(Map<String, dynamic> data) {
  final startTimeStr = data['startTime'] as String?;
  final startTime = _parseTimestamp(startTimeStr);
  state = state.copyWith(
    gameStartTime: startTime ?? DateTime.now(),
    bannerMessage: GameEventMessages.gameStartGo,
  );
  _startBannerTimer();
  debugPrint(
    '[GameEventNotifier] ✅ START 이벤트 → 게임 시작 시각: ${state.gameStartTime}',
  );
}
```

- [ ] **Step 3: _handleArrest 수정 — 경찰 닉네임 파싱 + 배너 메시지 추가**

```dart
void _handleArrest(Map<String, dynamic> data) {
  final robber = data['robber'] as Map<String, dynamic>?;
  final robberPid = (robber?['participantId'] as num?)?.toInt();
  final robberNickname = robber?['nickname'] as String?;
  final remaining = (data['remainingThieves'] as num?)?.toInt();
  if (robberPid == null) return;

  // 경찰 정보 파싱
  final police = data['police'] as Map<String, dynamic>?;
  final policeNickname = police?['nickname'] as String?;

  // race condition 방어: STOMP가 API 응답보다 먼저 도착한 경우 pending 해제
  if (robberPid == _pendingArrestId) {
    _pendingArrestId = null;
  }

  state = state.copyWith(
    arrestedParticipantIds: {...state.arrestedParticipantIds, robberPid},
    escapedParticipantIds: state.escapedParticipantIds.difference({robberPid}),
    remainingThieves: remaining,
    lastArrestNickname: robberNickname,
    lastArrestPoliceNickname: policeNickname,
    isApiLoading: false,
    bannerMessage: GameEventMessages.arrestNotice(
      policeNickname ?? '경찰',
      robberNickname ?? '도둑',
    ),
  );
  _startBannerTimer();
  VibrationService.instance().arrested();
  debugPrint(
    '[GameEventNotifier] ✅ ARREST 이벤트 → robberPid: $robberPid, 남은: $remaining',
  );
}
```

- [ ] **Step 4: _handleEscape 수정 — 배너 메시지 추가**

```dart
void _handleEscape(Map<String, dynamic> data) {
  final escapedThief = data['escapedThief'] as Map<String, dynamic>?;
  if (escapedThief == null) return;
  final escapedId = (escapedThief['participantId'] as num?)?.toInt();
  if (escapedId == null) return;
  final firstNickname = escapedThief['nickname'] as String?;

  state = state.copyWith(
    arrestedParticipantIds: state.arrestedParticipantIds.difference({escapedId}),
    escapedParticipantIds: {...state.escapedParticipantIds, escapedId},
    lastEscapeNickname: firstNickname,
    isApiLoading: false,
    bannerMessage: GameEventMessages.escapeNotice,
  );
  _startBannerTimer();
  VibrationService.instance().escaped();
  debugPrint('[GameEventNotifier] ✅ ESCAPE 이벤트 → escaped: $escapedId');
}
```

- [ ] **Step 5: policeMoveStart 배너 메시지 — 문구 자동 변경 확인**

`_handleEvent`의 `policeMoveStart` 케이스는 이미 `GameEventMessages.policeMove`를 참조하고 있으므로, Task 1에서 문구만 변경되면 자동 반영됨 ("경찰 출동! 도둑은 도망치세요!"). 코드 수정 불필요.

- [ ] **Step 6: 정적 분석 확인**

Run: `cd /Users/luca/workspace/Flutter_Project/cops_and_robbers && flutter analyze lib/features/game/presentation/providers/game_event_provider.dart`
Expected: 에러 없음

- [ ] **Step 7: 커밋**

```bash
git add lib/features/game/presentation/providers/game_event_provider.dart
git commit -m "feat : 체포/탈옥/경찰출동 배너 공지 메시지 연동 #211"
```

---

## Task 3: game_page 시스템 채팅 메시지 연동

**Files:**
- Modify: `lib/features/game/presentation/pages/game_page.dart`

- [ ] **Step 1: 체포 시스템 채팅 메시지 리스너 추가**

기존 `ref.listen` 패턴을 따라 체포 이벤트 시 시스템 채팅 메시지 주입:

```dart
// 체포 이벤트 → 전체채팅 시스템 메시지 (인라인 아이콘 마커 포함)
ref.listen(
  gameEventNotifierProvider.select(
    (s) => (s.lastArrestNickname, s.lastArrestPoliceNickname, s.arrestedParticipantIds.length),
  ),
  (prev, next) {
    final (robberNick, policeNick, count) = next;
    final (_, _, prevCount) = prev ?? (null, null, 0);
    if (robberNick != null && count > prevCount) {
      ref.read(chatNotifierProvider.notifier).addSystemMessage(
        gameId: _gameId,
        message: GameEventMessages.arrestNotice(
          policeNick ?? '경찰',
          robberNick,
        ),
      );
    }
  },
);
```

- [ ] **Step 2: 탈옥 시스템 채팅 메시지 리스너 추가**

```dart
// 탈옥 이벤트 → 전체채팅 시스템 메시지
ref.listen(
  gameEventNotifierProvider.select(
    (s) => (s.lastEscapeNickname, s.escapedParticipantIds.length),
  ),
  (prev, next) {
    final (_, count) = next;
    final (_, prevCount) = prev ?? (null, 0);
    if (count > prevCount) {
      ref.read(chatNotifierProvider.notifier).addSystemMessage(
        gameId: _gameId,
        message: GameEventMessages.escapeNotice,
      );
    }
  },
);
```

- [ ] **Step 3: 기존 gameOver 시스템 채팅 리스너 제거**

`GameEventMessages.gameOver` 참조하는 리스너 블록과 `_lastHandledIsGameOver` 변수를 삭제.

- [ ] **Step 4: START 이벤트 시스템 채팅 — 3단계 시퀀스 주입**

게임 시작 시 시스템 채팅에 3개 메시지를 순서대로 주입:

```dart
// 게임 시작 → 전체채팅 시스템 메시지 3단계 시퀀스
ref.listen(gameEventNotifierProvider.select((s) => s.gameStartTime), (prev, next) {
  if (next != null && next != _lastHandledGameStart) {
    _lastHandledGameStart = next;
    final chatNotifier = ref.read(chatNotifierProvider.notifier);
    final participantInfo = ref.read(gameParticipantInfoProvider).valueOrNull;
    final gameDuration = participantInfo?.gameDurationMinutes;
    if (gameDuration != null) {
      chatNotifier.addSystemMessage(
        gameId: _gameId,
        message: GameEventMessages.gameStartCountdown(gameDuration),
      );
    }
    chatNotifier.addSystemMessage(
      gameId: _gameId,
      message: GameEventMessages.gameStartReportTip,
    );
    chatNotifier.addSystemMessage(
      gameId: _gameId,
      message: GameEventMessages.gameStartGo,
    );
  }
});
```

> `_lastHandledGameStart` 변수를 `DateTime?` 타입으로 선언 필요. `gameDurationMinutes` 필드명은 `GameParticipantInfo` 실제 필드명으로 확인 후 맞출 것.

- [ ] **Step 5: 정적 분석 확인**

Run: `cd /Users/luca/workspace/Flutter_Project/cops_and_robbers && flutter analyze lib/features/game/presentation/pages/game_page.dart`
Expected: 에러 없음

- [ ] **Step 6: 커밋**

```bash
git add lib/features/game/presentation/pages/game_page.dart
git commit -m "feat : 체포/탈옥/게임시작 시스템 채팅 메시지 연동 #211"
```

---

## Task 4: 시스템 채팅 메시지 인라인 아이콘 렌더링

**Files:**
- Modify: `lib/features/chat/presentation/widgets/chat_message_bubble.dart`

- [ ] **Step 1: `_buildSystemMessage` 수정 — 마커 파싱 + RichText 렌더링**

기존 `_buildSystemMessage`의 `Text(message.message)` 부분을 `RichText` + `WidgetSpan`으로 교체.
`@icon_police`와 `@icon_robber` 마커를 정규식으로 파싱하여 인라인 SVG 아이콘으로 치환한다.

```dart
/// 시스템 메시지 텍스트에 포함된 아이콘 마커를 파싱하여 InlineSpan 리스트로 변환
///
/// `@icon_police`, `@icon_robber` 마커를 SVG WidgetSpan으로 치환한다.
/// 마커가 없는 일반 시스템 메시지는 텍스트만 반환한다.
List<InlineSpan> _parseSystemMessageSpans(String text) {
  final style = AppTextStyles.paragraph_14.copyWith(
    color: isDarkMode ? AppColors.green : AppColors.blue,
  );
  final iconRegex = RegExp(r'@icon_(police|robber)');
  final spans = <InlineSpan>[];
  var lastEnd = 0;

  for (final match in iconRegex.allMatches(text)) {
    // 마커 앞 텍스트
    if (match.start > lastEnd) {
      spans.add(TextSpan(text: text.substring(lastEnd, match.start), style: style));
    }
    // 아이콘 WidgetSpan
    final isPolice = match.group(1) == 'police';
    final iconPath = isPolice
        ? (isDarkMode ? 'assets/icons/icon_police_darkmode.svg' : 'assets/icons/icon_police_lightmode.svg')
        : (isDarkMode ? 'assets/icons/mdi_robber_darkmode.svg' : 'assets/icons/mdi_robber_lightmode.svg');
    spans.add(
      WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Padding(
          padding: EdgeInsets.only(right: 2.w),
          child: SvgPicture.asset(iconPath, width: 16.w, height: 16.w),
        ),
      ),
    );
    lastEnd = match.end;
  }

  // 마지막 남은 텍스트
  if (lastEnd < text.length) {
    spans.add(TextSpan(text: text.substring(lastEnd), style: style));
  }

  // 마커가 없었으면 전체 텍스트 반환
  if (spans.isEmpty) {
    spans.add(TextSpan(text: text, style: style));
  }

  return spans;
}
```

- [ ] **Step 2: `_buildSystemMessage` 위젯 변경**

기존 `Text` → `RichText`로 교체:

```dart
/// 시스템 메시지 (중앙 정렬, 파란색 텍스트 + Loudspeaker 16x16)
Widget _buildSystemMessage() {
  return Padding(
    padding: EdgeInsets.symmetric(
      horizontal: AppSpacing.horizontal16,
      vertical: 6.h,
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          'assets/icons/Loudspeaker.svg',
          width: 16.w,
          height: 16.w,
          colorFilter: ColorFilter.mode(
            isDarkMode ? AppColors.green : AppColors.blue,
            BlendMode.srcIn,
          ),
        ),
        SizedBox(width: AppSpacing.horizontal4),
        Flexible(
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: _parseSystemMessageSpans(message.message),
            ),
          ),
        ),
      ],
    ),
  );
}
```

- [ ] **Step 3: 정적 분석 확인**

Run: `cd /Users/luca/workspace/Flutter_Project/cops_and_robbers && flutter analyze lib/features/chat/presentation/widgets/chat_message_bubble.dart`
Expected: 에러 없음

- [ ] **Step 4: 커밋**

```bash
git add lib/features/chat/presentation/widgets/chat_message_bubble.dart
git commit -m "feat : 시스템 채팅 메시지 인라인 아이콘 렌더링 #211"
```

---

## 참고: 서버 이벤트 미확정 메시지

아래 메시지들은 **서버에서 별도 이벤트를 보내줘야** 클라이언트에서 처리 가능:

| 메시지 | 필요한 서버 이벤트 | 현재 상태 |
|--------|-------------------|-----------|
| `fiveMinutesLeft` | 게임 종료 5분 전 이벤트 또는 클라이언트 타이머 | 서버 이벤트 미정 |
| `policeMoveWarning` | 경찰 출동 예고 이벤트 (출동 전 별도 이벤트) | 현재 POLICE_MOVE_START 하나만 존재 |
| `remainingRobbers(n)` | LOCATION_REVEAL data에 도주 인원 수 포함 | data에 포함 여부 확인 필요 |

→ 이 메시지들은 `GameEventMessages`에 상수/메서드로 **미리 정의만** 해두고, 실제 연동은 서버 이벤트가 확정된 후 별도 이슈에서 처리.
