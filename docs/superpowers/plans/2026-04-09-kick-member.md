# 멤버 강제 퇴장 (Kick Member) 구현 계획

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 방장이 로비에서 특정 참가자를 강제 퇴장시키는 기능 구현

**Architecture:** `DELETE /api/games/{gameId}/lobby/{participantId}` API를 Retrofit datasource에 추가하고, waiting_room_page에서 방장 전용 onMemberTap 콜백으로 확인 다이얼로그 → API 호출 흐름을 연결한다. STOMP `KICKED` 이벤트를 lobby_event_dto에 추가하고, 강퇴당한 유저에게는 다이얼로그 + 홈 이동, 나머지에게는 스낵바 + 목록 제거를 처리한다.

**Tech Stack:** Flutter, Retrofit, Riverpod, Freezed, STOMP WebSocket

---

### Task 1: KICKED 이벤트 타입 추가

**Files:**
- Modify: `lib/features/lobby/data/models/lobby_event_dto.dart:34-58`

- [ ] **Step 1: LobbyEventType에 kicked 상수 추가**

```dart
/// 강제 퇴장
static const String kicked = 'KICKED';
```

`areaUpdated` 아래에 추가한다.

- [ ] **Step 2: 빌드 확인**

Run: `flutter analyze`
Expected: 에러 없음

- [ ] **Step 3: 커밋**

```bash
git add lib/features/lobby/data/models/lobby_event_dto.dart
git commit -m "feat : KICKED 이벤트 타입 추가 #235"
```

---

### Task 2: kickMember API 메서드 추가 (Retrofit)

**Files:**
- Modify: `lib/features/session/data/datasources/session_remote_datasource.dart`

- [ ] **Step 1: kickMember 메서드 추가**

`updateGameArea` 메서드 아래에 추가:

```dart
/// 멤버 강제 퇴장 (방장 전용)
///
/// 대기실에서 특정 참가자를 강제 퇴장시킵니다.
///
/// - 204: 강제 퇴장 성공
/// - 400: 자기 자신 강퇴 불가 / 이미 시작된 게임
/// - 403: 방장 권한 필요
/// - 404: 게임 또는 참가자 없음
@DELETE('/api/games/{gameId}/lobby/{participantId}')
Future<void> kickMember(
  @Path('gameId') int gameId,
  @Path('participantId') int participantId,
);
```

- [ ] **Step 2: build_runner 실행**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: `session_remote_datasource.g.dart` 재생성 성공

- [ ] **Step 3: 빌드 확인**

Run: `flutter analyze`
Expected: 에러 없음

- [ ] **Step 4: 커밋**

```bash
git add lib/features/session/data/datasources/session_remote_datasource.dart lib/features/session/data/datasources/session_remote_datasource.g.dart
git commit -m "feat : kickMember API 메서드 추가 (Retrofit) #235"
```

---

### Task 3: kickMember provider 추가

**Files:**
- Modify: `lib/features/session/presentation/providers/session_provider.dart`

- [ ] **Step 1: session_provider에 kickMember provider 추가**

기존 provider 패턴을 따라 추가 (leaveGame 아래):

```dart
/// 멤버 강제 퇴장 (방장 전용)
@riverpod
Future<void> kickMember(
  Ref ref, {
  required int gameId,
  required int participantId,
}) async {
  final dataSource = ref.read(sessionRemoteDataSourceProvider);
  await dataSource.kickMember(gameId, participantId);
}
```

- [ ] **Step 2: build_runner 실행**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: `session_provider.g.dart` 재생성 성공

- [ ] **Step 3: 빌드 확인**

Run: `flutter analyze`
Expected: 에러 없음

- [ ] **Step 4: 커밋**

```bash
git add lib/features/session/presentation/providers/session_provider.dart lib/features/session/presentation/providers/session_provider.g.dart
git commit -m "feat : kickMember provider 추가 #235"
```

---

### Task 4: KICKED 이벤트 핸들러 추가 (participants provider)

**Files:**
- Modify: `lib/features/session/presentation/providers/waiting_room_participants_provider.dart`

- [ ] **Step 1: handleLobbyEvent에 KICKED 케이스 추가**

`switch (event.type)` 블록의 `case LobbyEventType.hostChanged:` 아래에 추가:

```dart
case LobbyEventType.kicked:
  _handleKicked(event.data);
```

- [ ] **Step 2: _handleKicked 메서드 추가**

`_handleHostChanged` 아래에 추가:

```dart
void _handleKicked(Map<String, dynamic> data) {
  // 서버 KICKED data: { "kickedParticipantId": 3, "nickname": "도둑1" }
  final pid = data['kickedParticipantId'] as int?;
  if (pid == null) return;
  state = state.copyWith(
    participants: state.participants
        .where((p) => p.participantId != pid)
        .toList(),
  );
}
```

- [ ] **Step 3: 빌드 확인**

Run: `flutter analyze`
Expected: 에러 없음

- [ ] **Step 4: 커밋**

```bash
git add lib/features/session/presentation/providers/waiting_room_participants_provider.dart
git commit -m "feat : KICKED 이벤트 핸들러 추가 #235"
```

---

### Task 5: waiting_room_page에 강퇴 UI 로직 연결

**Files:**
- Modify: `lib/features/session/presentation/pages/waiting_room_page.dart`

- [ ] **Step 1: 강퇴 확인 다이얼로그 메서드 추가**

`_WaitingRoomPageState` 클래스 내에 추가:

```dart
/// 강퇴 확인 다이얼로그 → API 호출
Future<void> _showKickDialog(LobbyParticipantInfo member) async {
  final isDark = ref.read(roleThemeProvider);
  final confirmed = await AppDialog.confirm(
    context: context,
    title: '${member.nickname}님을 내보낼까요?',
    message: '강퇴된 유저는 방에서 즉시 내보내져요\n다시 방에 참가하려면 초대코드를 입력해야 해요',
    cancelText: '취소',
    confirmText: '내보내기',
    isDestructive: true,
    isDarkMode: isDark,
  );
  if (confirmed != true || !mounted) return;

  final gameId = ref.read(gameParticipantNotifierProvider)?.gameId;
  if (gameId == null) return;

  try {
    await ref.read(
      kickMemberProvider(
        gameId: gameId,
        participantId: member.participantId,
      ).future,
    );
  } on DioException catch (e) {
    if (!mounted) return;
    final message = DioExceptionHandler.handle(e).message;
    AppSnackbar.show(context, message: message, backgroundColor: AppColors.red);
  }
}
```

- [ ] **Step 2: TeamSection에 onMemberTap 콜백 전달**

경찰팀과 도둑팀 `TeamSection` 위젯 모두에 `onMemberTap` 추가:

```dart
onMemberTap: isHost
    ? (member) {
        // 자기 자신 탭은 무시
        final myPid = participantInfo?.participantId;
        if (member.participantId == myPid) return;
        _showKickDialog(member);
      }
    : null,
```

`isHost`는 기존에 이미 계산되어 있는 `myPid == lobbyInfo.hostParticipantId` 값을 사용.

- [ ] **Step 3: 빌드 확인**

Run: `flutter analyze`
Expected: 에러 없음

- [ ] **Step 4: 커밋**

```bash
git add lib/features/session/presentation/pages/waiting_room_page.dart
git commit -m "feat : 방장 강퇴 확인 다이얼로그 + API 호출 연결 #235"
```

---

### Task 6: KICKED 이벤트 수신 시 UI 피드백

**Files:**
- Modify: `lib/features/session/presentation/pages/waiting_room_page.dart`

- [ ] **Step 1: _listenLobbyEvents에 KICKED 이벤트 처리 추가**

기존 이벤트 리스너(`_listenLobbyEvents` 또는 lobby 이벤트를 처리하는 `ref.listen` 블록) 내에서 KICKED 이벤트 분기 추가:

```dart
case LobbyEventType.kicked:
  final kickedPid = event.data['kickedParticipantId'] as int?;
  final kickedNickname = event.data['nickname'] as String? ?? '';
  final myPid = ref.read(gameParticipantNotifierProvider)?.participantId;

  if (kickedPid == myPid) {
    // 강퇴당한 본인 → 다이얼로그 + 홈 이동
    if (!mounted) return;
    await AppDialog.show(
      context: context,
      title: '방에서 내보내졌어요',
      message: '다시 참가하려면 초대코드를 입력해야 해요',
      isDarkMode: ref.read(roleThemeProvider),
    );
    if (!mounted) return;
    ref.read(gameParticipantNotifierProvider.notifier).clear();
    GoRouter.of(context).go(RoutePaths.home);
  } else {
    // 다른 유저 강퇴 → 스낵바
    if (!mounted) return;
    AppSnackbar.show(
      context,
      message: '$kickedNickname님이 내보내졌어요',
    );
  }
```

- [ ] **Step 2: 빌드 확인**

Run: `flutter analyze`
Expected: 에러 없음

- [ ] **Step 3: 수동 테스트**

1. 방장으로 로비 입장 → 다른 유저 카드 탭 → 확인 다이얼로그 표시 확인
2. "내보내기" 탭 → API 호출 → 카드 사라짐 확인
3. 강퇴당한 유저 화면 → "방에서 내보내졌어요" 다이얼로그 확인 → 홈 이동
4. 나머지 유저 화면 → 스낵바 "{닉네임}님이 내보내졌어요" 확인
5. 방장 자기 카드 탭 → 무반응 확인
6. 일반 유저가 다른 카드 탭 → 무반응 확인
7. 다크모드(도둑팀 방장) → 다이얼로그 다크 테마 확인

- [ ] **Step 4: 커밋**

```bash
git add lib/features/session/presentation/pages/waiting_room_page.dart
git commit -m "feat : KICKED 이벤트 UI 피드백 — 강퇴 다이얼로그 + 스낵바 #235"
```
