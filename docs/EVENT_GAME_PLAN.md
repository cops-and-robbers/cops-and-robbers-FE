# 이벤트 게임 모드 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 행사장용 이벤트 게임 모드(운영진=도둑 고정타겟, 사용자=경찰, QR 로비 스킵 인게임 직행, 도둑 ALIVE, 증거 수집·결과 보드)를 프론트엔드에 구현한다.

**Architecture:** 인게임 분기의 단일 소스는 `GameParticipantInfo.isEventGame`. 경찰의 검거 카운트/재체포는 전역 수감 집합과 분리된 로컬 집합(`myArrestedRobberIds`)으로 처리하고 `shared_preferences` 단일 레코드로 영속화한다. 백엔드 미구현분은 `--dart-define=EVENT_GAME_DEV=true` dev 플래그로 강제해 선개발한다.

**Tech Stack:** Flutter / Riverpod(코드생성) / Freezed / Retrofit / shared_preferences / flutter_svg / flutter_screenutil.

**설계 근거:** [EVENT_GAME_DESIGN.md](EVENT_GAME_DESIGN.md), [EVENT_GAME_spec.md](EVENT_GAME_spec.md)

## Global Constraints

- **커밋 자동 금지**: 각 Task 끝 commit 스텝은 체크포인트 표시. **실제 `git commit`은 사용자가 명시적으로 요청할 때만** 실행한다. `git push` 절대 금지. **Co-Authored-By 태그 금지**.
- **UI 텍스트 i18n 필수**: 사용자 노출 문자열은 `lib/l10n/app_{ko,en,ja}.arb`에 추가 후 `AppLocalizations.of(context).key`로 사용. `lib/l10n/app_localizations*.dart` 직접 편집 금지. ARB placeholder 메타(`@key`)는 **템플릿 ARB(`app_ko.arb`)** 에 둔다. 변경 후 `flutter gen-l10n`.
- **메시지 끝 마침표 금지** (사용자 노출 문자열).
- **컬러/타이포/간격**: `AppColors`·`AppTextStyles`·`AppSpacing`/`AppPadding`/`AppRadius` 상수만. `withOpacity`/`withValues`/`Color(0xFF…)`/`Colors.x` 금지(흐림 표현은 `Opacity` 위젯 사용). ScreenUtil `.w/.h/.r/.sp` 필수.
- **코드 생성**: `@freezed`·`@riverpod` 추가/수정 후 `dart run build_runner build --delete-conflicting-outputs`.
- **테스트 룰**([Agents.md]): 시스템 경계만 모킹(`shared_preferences`는 `SharedPreferences.setMockInitialValues`, REST는 fake), 동작 검증, 명명 `<subject>_<expected>_when_<condition>`(snake_case).
- **에러 처리**: try-catch + Custom Exception (Either 금지).
- 실서비스 빌드에서 `kEventGameDevOverride`는 false(영향 없음).

---

## 파일 구조 (생성/수정)

**생성:**
- `lib/core/constants/dev_flags.dart` — dev 플래그 상수
- `lib/features/game/data/services/event_arrest_storage.dart` — 로컬 검거 영속화 + provider
- `lib/features/game/domain/arrest_lock_visibility.dart` — 잠금 표시 여부 순수 함수
- `lib/features/game/presentation/widgets/event_arrest_success_dialog.dart` — 체포 성공(증거 공개) 다이얼로그
- `lib/features/game/presentation/widgets/event_result_board.dart` — 결과 증거 보드
- 대응 테스트 파일들

**수정:**
- `lib/features/session/data/models/join_game_response.dart`, `domain/entities/game_join_result.dart`, `data/repositories/session_repository_impl.dart`, `data/models/game_settings_response.dart`
- `lib/features/session/presentation/providers/game_participant_provider.dart`, `providers/deeplink_join_notifier.dart`, `pages/deeplink_join_page.dart`, `pages/home_page.dart`
- `lib/features/game/presentation/providers/game_event_provider.dart`, `pages/game_page.dart`
- `lib/l10n/app_{ko,en,ja}.arb`, `pubspec.yaml`

---

## Task 1: Join/Settings 모델에 `isEventGame` 추가 + Repository 매핑

**Files:**
- Modify: `lib/features/session/data/models/join_game_response.dart`
- Modify: `lib/features/session/domain/entities/game_join_result.dart`
- Modify: `lib/features/session/data/models/game_settings_response.dart`
- Modify: `lib/features/session/data/repositories/session_repository_impl.dart`
- Test: `test/features/session/data/models/join_game_response_test.dart`

**Interfaces:**
- Produces: `JoinGameResponse.isEventGame: bool`(default false), `GameJoinResult.isEventGame: bool`(default false), `GameSettingsResponse.isEventGame: bool`(default false).

- [ ] **Step 1: 실패 테스트 작성** — `join_game_response_test.dart`

```dart
import 'package:cops_and_robbers/features/session/data/models/join_game_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('JoinGameResponse.fromJson', () {
    test('isEventGame_defaults_to_false_when_absent', () {
      final r = JoinGameResponse.fromJson({'gameId': 1, 'participantId': 2});
      expect(r.isEventGame, isFalse);
    });

    test('isEventGame_is_true_when_present', () {
      final r = JoinGameResponse.fromJson(
        {'gameId': 1, 'participantId': 2, 'isEventGame': true},
      );
      expect(r.isEventGame, isTrue);
    });
  });
}
```

- [ ] **Step 2: 테스트 실패 확인**

Run: `flutter test test/features/session/data/models/join_game_response_test.dart`
Expected: FAIL — `isEventGame` getter 없음(컴파일 에러).

- [ ] **Step 3: 모델/엔티티/매핑 구현**

`join_game_response.dart` — factory에 필드 추가:
```dart
  const factory JoinGameResponse({
    /// 게임 ID
    required int gameId,

    /// 참여자 ID
    required int participantId,

    /// 이벤트 게임 여부 (백엔드 신규 필드, 미포함 시 false)
    @Default(false) bool isEventGame,
  }) = _JoinGameResponse;
```

`game_join_result.dart` — factory에 필드 추가:
```dart
  const factory GameJoinResult({
    /// 참여한 게임의 고유 ID
    required int gameId,

    /// 해당 게임에서 부여받은 참여자 고유 ID
    required int participantId,

    /// 이벤트 게임 여부 (true면 로비 스킵 인게임 직행)
    @Default(false) bool isEventGame,
  }) = _GameJoinResult;
```

`game_settings_response.dart` — `gameStartTime` 다음에 필드 추가:
```dart
    /// 게임 시작 시각 (ISO 8601, IN_PROGRESS 상태일 때만 non-null)
    String? gameStartTime,

    /// 이벤트 게임 여부 (백엔드 신규 필드, 미포함 시 false) — 콜드 재진입 복원용
    @Default(false) bool isEventGame,
  }) = _GameSettingsResponse;
```

`session_repository_impl.dart` — `joinGameByInvite`의 변환에 매핑 추가:
```dart
      return GameJoinResult(
        gameId: response.gameId,
        participantId: response.participantId,
        isEventGame: response.isEventGame,
      );
```

- [ ] **Step 4: 코드 생성**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: `*.freezed.dart`/`*.g.dart` 재생성, 에러 없음.

- [ ] **Step 5: 테스트 통과 확인**

Run: `flutter test test/features/session/data/models/join_game_response_test.dart`
Expected: PASS (2 tests).

- [ ] **Step 6: Commit (체크포인트 — 사용자 승인 시에만 실행)**

```bash
git add lib/features/session/data/models/join_game_response.dart lib/features/session/domain/entities/game_join_result.dart lib/features/session/data/models/game_settings_response.dart lib/features/session/data/repositories/session_repository_impl.dart test/features/session/data/models/join_game_response_test.dart
git commit -m "feat: join/settings 모델에 isEventGame 필드 추가"
```

---

## Task 2: `GameParticipantInfo.isEventGame` + dev 플래그 상수

**Files:**
- Create: `lib/core/constants/dev_flags.dart`
- Modify: `lib/features/session/presentation/providers/game_participant_provider.dart`
- Test: `test/features/session/presentation/providers/game_participant_info_test.dart`

**Interfaces:**
- Consumes: (없음)
- Produces: `const bool kEventGameDevOverride`; `GameParticipantInfo.isEventGame: bool`(default false); `setGameInfo({..., bool isEventGame = false})`; `initFromLobby({..., bool? isEventGame})`.

- [ ] **Step 1: 실패 테스트 작성** — `game_participant_info_test.dart`

```dart
import 'package:cops_and_robbers/features/session/presentation/providers/game_participant_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GameParticipantInfo.isEventGame', () {
    test('defaults_to_false', () {
      const info = GameParticipantInfo(gameId: 1, team: 'POLICE', nickname: 'a');
      expect(info.isEventGame, isFalse);
    });

    test('copyWith_updates_is_event_game', () {
      const info = GameParticipantInfo(gameId: 1, team: 'POLICE', nickname: 'a');
      expect(info.copyWith(isEventGame: true).isEventGame, isTrue);
    });

    test('copyWith_preserves_is_event_game_when_omitted', () {
      const info = GameParticipantInfo(
          gameId: 1, team: 'POLICE', nickname: 'a', isEventGame: true);
      expect(info.copyWith(nickname: 'b').isEventGame, isTrue);
    });
  });
}
```

- [ ] **Step 2: 테스트 실패 확인**

Run: `flutter test test/features/session/presentation/providers/game_participant_info_test.dart`
Expected: FAIL — `isEventGame` 파라미터 없음.

- [ ] **Step 3: dev 플래그 + GameParticipantInfo 구현**

`lib/core/constants/dev_flags.dart` (신규):
```dart
/// 개발 전용 플래그 모음.
///
/// 이벤트 게임 모드를 백엔드 응답 없이 강제 활성화한다(디버그 검증용).
/// 사용: `flutter run --dart-define=EVENT_GAME_DEV=true`
/// 실서비스 빌드에서는 미지정 → false 라 영향 없음.
const bool kEventGameDevOverride = bool.fromEnvironment('EVENT_GAME_DEV');
```

`game_participant_provider.dart` — `GameParticipantInfo`에 필드/생성자/copyWith 추가:
```dart
  /// 방장 participantId (참가자 오버레이 정렬용)
  final int? hostParticipantId;

  /// 이벤트 게임 여부 (인게임 분기 단일 소스 — 도둑 ALIVE UI / 체포 / 결과)
  final bool isEventGame;

  const GameParticipantInfo({
    required this.gameId,
    required this.team,
    required this.nickname,
    this.participantId,
    this.maxParticipants,
    this.locationRevealIntervalMinutes,
    this.policeWaitMinutes,
    this.roundTimeMinutes,
    this.gameStartTime,
    this.isHost = false,
    this.hostParticipantId,
    this.isEventGame = false,
  });
```
copyWith — 파라미터 추가 및 본문 추가:
```dart
    bool? isHost,
    int? hostParticipantId,
    bool? isEventGame,
  }) {
    return GameParticipantInfo(
      // ...기존 필드 동일...
      isHost: isHost ?? this.isHost,
      hostParticipantId: hostParticipantId ?? this.hostParticipantId,
      isEventGame: isEventGame ?? this.isEventGame,
    );
  }
```
`setGameInfo` — 파라미터 추가 및 생성자 전달:
```dart
  void setGameInfo({
    required int gameId,
    required String nickname,
    String team = GameTeam.police,
    int? participantId,
    int? maxParticipants,
    int? locationRevealIntervalMinutes,
    bool isHost = false,
    bool isEventGame = false,
  }) {
    state = GameParticipantInfo(
      gameId: gameId,
      nickname: nickname,
      team: team,
      participantId: participantId,
      maxParticipants: maxParticipants,
      locationRevealIntervalMinutes: locationRevealIntervalMinutes,
      isHost: isHost,
      isEventGame: isEventGame,
    );
  }
```
`initFromLobby` — 파라미터 추가 및 copyWith 전달:
```dart
  void initFromLobby({
    required int participantId,
    String? team,
    int? maxParticipants,
    int? locationRevealIntervalMinutes,
    int? policeWaitMinutes,
    int? roundTimeMinutes,
    int? hostParticipantId,
    bool? isEventGame,
  }) {
    if (state == null) return;
    state = state!.copyWith(
      participantId: participantId,
      team: team,
      maxParticipants: maxParticipants,
      locationRevealIntervalMinutes: locationRevealIntervalMinutes,
      policeWaitMinutes: policeWaitMinutes,
      roundTimeMinutes: roundTimeMinutes,
      hostParticipantId: hostParticipantId,
      isEventGame: isEventGame,
    );
  }
```

- [ ] **Step 4: 테스트 통과 확인**

Run: `flutter test test/features/session/presentation/providers/game_participant_info_test.dart`
Expected: PASS (3 tests). (plain class라 build_runner 불필요.)

- [ ] **Step 5: Commit (체크포인트)**

```bash
git add lib/core/constants/dev_flags.dart lib/features/session/presentation/providers/game_participant_provider.dart test/features/session/presentation/providers/game_participant_info_test.dart
git commit -m "feat: GameParticipantInfo.isEventGame + dev 플래그 추가"
```

---

## Task 3: `EventArrestStorage` (로컬 검거 영속화)

**Files:**
- Create: `lib/features/game/data/services/event_arrest_storage.dart`
- Test: `test/features/game/data/services/event_arrest_storage_test.dart`

**Interfaces:**
- Produces: `class EventArrestStorage { Future<Set<int>> load(int gameId); Future<void> save(int gameId, Set<int> robberIds); }`; `eventArrestStorageProvider` (keepAlive).

- [ ] **Step 1: 실패 테스트 작성** — `event_arrest_storage_test.dart`

```dart
import 'package:cops_and_robbers/features/game/data/services/event_arrest_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('load_returns_empty_when_no_record', () async {
    expect(await EventArrestStorage().load(1), isEmpty);
  });

  test('save_then_load_restores_set_for_same_game', () async {
    final storage = EventArrestStorage();
    await storage.save(1, {7, 8});
    expect(await storage.load(1), {7, 8});
  });

  test('different_game_load_clears_record_so_it_does_not_revive', () async {
    final storage = EventArrestStorage();
    await storage.save(1, {7, 8});
    expect(await storage.load(2), isEmpty); // 다른 게임 진입 → 리셋
    expect(await storage.load(1), isEmpty); // 부활하지 않음(레코드 제거됨)
  });

  test('save_persists_for_current_game_after_reset', () async {
    final storage = EventArrestStorage();
    await storage.save(1, {7});
    await storage.load(2); // 게임 2 진입 → 게임1 레코드 제거
    await storage.save(2, {9}); // 게임 2 검거
    expect(await storage.load(2), {9});
  });
}
```

- [ ] **Step 2: 테스트 실패 확인**

Run: `flutter test test/features/game/data/services/event_arrest_storage_test.dart`
Expected: FAIL — `EventArrestStorage` 없음.

- [ ] **Step 3: 구현** — `event_arrest_storage.dart`

```dart
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'event_arrest_storage.g.dart';

/// 이벤트 게임 — 경찰이 검거한 운영진(도둑) ID 로컬 영속화.
///
/// 단일 레코드(키 1개)에 `{gameId, arrestedRobberIds}`를 저장한다.
/// 같은 gameId 재진입 시 복원, 다른 gameId면 빈 집합(자동 리셋).
/// 기기(=경찰)별 저장이라 경찰 간 공유되지 않는다.
class EventArrestStorage {
  static const String _key = 'event_game_arrest';

  /// 저장된 gameId가 현재 [gameId]와 같으면 검거 집합 복원, 아니면 빈 집합.
  ///
  /// 다른 게임/손상 레코드면 **제거**해 부활을 막는다(자동 리셋 보장).
  /// 이 제거 부수효과는 game_page 진입 시 loadMyArrests가 **체포 가능 시점 이전에
  /// await**되므로(§Task 9) 신규 체포 저장과 경쟁하지 않는다.
  Future<Set<int>> load(int gameId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        if ((map['gameId'] as num?)?.toInt() == gameId) {
          return (map['arrestedRobberIds'] as List<dynamic>? ?? const [])
              .map((e) => (e as num).toInt())
              .toSet();
        }
      } catch (_) {
        // 손상 레코드 → 아래에서 제거
      }
      // 다른 게임/손상 → 기존 레코드 제거(부활 방지)
      await prefs.remove(_key);
    }
    return <int>{};
  }

  /// 현재 [gameId] 기준으로 검거 집합을 덮어쓴다.
  Future<void> save(int gameId, Set<int> robberIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode({'gameId': gameId, 'arrestedRobberIds': robberIds.toList()}),
    );
  }
}

/// 앱 생애주기 동안 단일 인스턴스 유지.
@Riverpod(keepAlive: true)
EventArrestStorage eventArrestStorage(Ref ref) => EventArrestStorage();
```

- [ ] **Step 4: 코드 생성**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: `event_arrest_storage.g.dart` 생성.

- [ ] **Step 5: 테스트 통과 확인**

Run: `flutter test test/features/game/data/services/event_arrest_storage_test.dart`
Expected: PASS (4 tests).

- [ ] **Step 6: Commit (체크포인트)**

```bash
git add lib/features/game/data/services/event_arrest_storage.dart test/features/game/data/services/event_arrest_storage_test.dart
git commit -m "feat: EventArrestStorage 로컬 검거 영속화 추가"
```

---

## Task 4: `GameEventState.myArrestedRobberIds` + Notifier 이벤트 체포/복원

**Files:**
- Modify: `lib/features/game/presentation/providers/game_event_provider.dart`
- Test: `test/features/game/presentation/providers/game_event_provider_test.dart` (기존 파일에 추가, `_container`/`_FakeGameSystemApi` 재사용)

**Interfaces:**
- Consumes: `eventArrestStorageProvider` (Task 3), `ArrestRequestModel`/`ArrestResponseModel`(기존).
- Produces: `GameEventState.myArrestedRobberIds: Set<int>`(default `{}`); `GameEventNotifier.loadMyArrests(int gameId): Future<void>`; `GameEventNotifier.arrestRobberForEvent(int gameId, int robberId): Future<({int evidenceIndex, String robberNickname})?>`.

- [ ] **Step 1: 실패 테스트 작성** — 기존 테스트 파일 main()에 group 추가

기존 파일 상단 import에 추가:
```dart
import 'package:shared_preferences/shared_preferences.dart';
```
main() 안에 group 추가:
```dart
  group('GameEventNotifier event-mode arrest', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('arrestForEvent_adds_local_set_returns_index_and_leaves_global_empty',
        () async {
      final api = _FakeGameSystemApi();
      final c = _container(api: api);
      final notifier = c.read(gameEventNotifierProvider.notifier);

      final result = await notifier.arrestRobberForEvent(1, 7);

      expect(result?.evidenceIndex, 1);
      expect(result?.robberNickname, '도둑');
      final s = c.read(gameEventNotifierProvider);
      expect(s.myArrestedRobberIds, {7});
      expect(s.arrestedParticipantIds, isEmpty); // 전역 수감 집합 미변경(도둑 ALIVE)
    });

    test('arrestForEvent_returns_null_and_keeps_set_when_api_fails', () async {
      final api = _FakeGameSystemApi()..arrestError = Exception('boom');
      final c = _container(api: api);
      final notifier = c.read(gameEventNotifierProvider.notifier);

      final result = await notifier.arrestRobberForEvent(1, 7);

      expect(result, isNull);
      expect(c.read(gameEventNotifierProvider).myArrestedRobberIds, isEmpty);
    });

    test('loadMyArrests_restores_persisted_set_for_same_game', () async {
      SharedPreferences.setMockInitialValues({
        'event_game_arrest': '{"gameId":1,"arrestedRobberIds":[7,8]}',
      });
      final c = _container(api: _FakeGameSystemApi());
      final notifier = c.read(gameEventNotifierProvider.notifier);

      await notifier.loadMyArrests(1);

      expect(c.read(gameEventNotifierProvider).myArrestedRobberIds, {7, 8});
    });

    test('loadMyArrests_merges_without_overwriting_in_flight_arrest', () async {
      // 영속값 {7} 이 있는데, 복원 전에 신규 체포 8이 반영된 상태에서 복원이 늦게 완료돼도
      // 8이 유실되지 않고 {7,8} 로 병합돼야 한다.
      SharedPreferences.setMockInitialValues({
        'event_game_arrest': '{"gameId":1,"arrestedRobberIds":[7]}',
      });
      final c = _container(api: _FakeGameSystemApi());
      final notifier = c.read(gameEventNotifierProvider.notifier);
      await notifier.arrestRobberForEvent(1, 8); // 신규 체포 먼저 반영

      await notifier.loadMyArrests(1); // 늦은 복원

      expect(c.read(gameEventNotifierProvider).myArrestedRobberIds, {7, 8});
    });

    test('arrestForEvent_ignores_second_call_while_first_in_flight', () async {
      final api = _FakeGameSystemApi()..arrestGate = Completer<void>();
      final c = _container(api: api);
      final notifier = c.read(gameEventNotifierProvider.notifier);

      final first = notifier.arrestRobberForEvent(1, 7); // gate에서 대기
      final second = await notifier.arrestRobberForEvent(1, 8); // pending → 즉시 null

      expect(second, isNull);
      expect(api.arrestCount, 1); // 두 번째는 API 호출 자체가 차단됨

      api.arrestGate!.complete();
      expect((await first)?.evidenceIndex, 1);
      expect(c.read(gameEventNotifierProvider).myArrestedRobberIds, {7});
    });
  });
```

- [ ] **Step 2: 테스트 실패 확인**

Run: `flutter test test/features/game/presentation/providers/game_event_provider_test.dart`
Expected: FAIL — `myArrestedRobberIds`/`arrestRobberForEvent`/`loadMyArrests` 없음.

- [ ] **Step 3: GameEventState 필드 추가**

`game_event_provider.dart` — `GameEventState` 필드/생성자/copyWith에 추가:
```dart
  /// 경찰이 검거한 운영진(도둑) ID 집합 (이벤트 모드 전용, 로컬 영속).
  /// 전역 arrestedParticipantIds와 분리 — 재동기화/도둑 ALIVE에 영향 없음.
  final Set<int> myArrestedRobberIds;
```
생성자 기본값:
```dart
    this.robberLocations = const {},
    this.myArrestedRobberIds = const {},
  });
```
copyWith 파라미터/본문:
```dart
    Map<int, LatLngModel>? robberLocations,
    Set<int>? myArrestedRobberIds,
  }) {
    return GameEventState(
      // ...기존 동일...
      robberLocations: robberLocations ?? this.robberLocations,
      myArrestedRobberIds: myArrestedRobberIds ?? this.myArrestedRobberIds,
    );
  }
```

- [ ] **Step 4: Notifier 메서드 추가**

`game_event_provider.dart` 상단 import에 추가:
```dart
import '../../data/services/event_arrest_storage.dart';
import '../../../session/presentation/providers/game_participant_provider.dart';
```
`GameEventNotifier`에 메서드 추가(arrestRobber 인근):
```dart
  /// 이벤트 모드 — 인게임 진입 시 로컬 검거 집합 복원.
  ///
  /// 복원과 동시 체포가 겹쳐도 신규 검거가 유실되지 않도록 **union 병합**한다
  /// (덮어쓰기 금지). 호출자(game_page)는 체포 가능 시점 이전에 이 메서드를 await한다.
  Future<void> loadMyArrests(int gameId) async {
    final ids = await ref.read(eventArrestStorageProvider).load(gameId);
    if (_isDisposed) return;
    state = state.copyWith(
      myArrestedRobberIds: {...state.myArrestedRobberIds, ...ids},
    );
  }

  /// 이벤트 모드 — 운영진 체포.
  ///
  /// 전역 수감 집합([arrestedParticipantIds])은 건드리지 않아 도둑이 ALIVE로 유지된다.
  /// 로컬 검거 집합만 갱신·영속화하고, 증거 인덱스(=누적 검거 수)와 도둑 닉네임을 반환한다.
  /// 실패 시 null.
  Future<({int evidenceIndex, String robberNickname})?> arrestRobberForEvent(
    int gameId,
    int robberParticipantId,
  ) async {
    if (_pendingArrestId != null) return null; // 재진입 방어
    _pendingArrestId = robberParticipantId;
    state = state.copyWith(isApiLoading: true);
    try {
      final res = await ref.read(gameSystemApiProvider).arrest(
            gameId,
            ArrestRequestModel(robberParticipantId: robberParticipantId),
          );
      final next = {...state.myArrestedRobberIds, robberParticipantId};
      state = state.copyWith(myArrestedRobberIds: next, isApiLoading: false);
      await ref.read(eventArrestStorageProvider).save(gameId, next);
      _pendingArrestId = null;
      return (evidenceIndex: next.length, robberNickname: res.robberNickname);
    } catch (e) {
      debugPrint('[GameEventNotifier] ❌ 이벤트 체포 실패: $e');
      _pendingArrestId = null;
      state = state.copyWith(isApiLoading: false, errorMessage: '체포 요청 실패');
      return null;
    }
  }
```

- [ ] **Step 5: `_handleArrest` 이벤트 모드 가드 추가**

`_handleArrest`에서 `if (robberPid == null) return;` 다음, 닉네임 파싱 이후에 가드 삽입:
```dart
    if (robberPid == null) return;

    // 경찰 정보 파싱
    final police = data['police'] as Map<String, dynamic>?;
    final policeNickname = police?['nickname'] as String?;

    // 이벤트 모드: 도둑 ALIVE 유지 — 전역 수감 집합/remainingThieves 미변경, 배너/진동만.
    final isEvent =
        ref.read(gameParticipantNotifierProvider)?.isEventGame ?? false;
    if (isEvent) {
      // _pendingArrestId는 arrestRobberForEvent가 HTTP+영속화 완료 후 직접 해제한다.
      // 여기서 조기 해제하면 STOMP가 HTTP보다 먼저 도착할 때 저장 중 두 번째 체포가
      // 시작돼 SharedPreferences 저장 순서에 따라 최신 검거 집합이 유실될 수 있다.
      state = state.copyWith(
        bannerMessage: _localizeGameEvent(GameEventMessageKey.arrestNotice, [
          policeNickname ?? _localizePoliceLabel(),
          robberNickname ?? _localizeRobberLabel(),
        ]).replaceAll(RegExp(r'@icon_(police|robber)\s*'), ''),
      );
      _startBannerTimer();
      VibrationService.instance().arrested();
      return;
    }

    // race condition 방어: STOMP가 API 응답보다 먼저 도착한 경우 pending 해제
    if (robberPid == _pendingArrestId) {
      _pendingArrestId = null;
    }
    // ...기존 일반 모드 state.copyWith(...) 로직 유지...
```

- [ ] **Step 6: 스테일 주석 정정**

`GameEventState.gameOverReason` 주석을 4개 값으로:
```dart
  /// 게임 종료 이유 ("TIME_OVER" | "ALL_ARRESTED" | "ROBBER_FORFEITED" | "POLICE_FORFEITED")
  final String? gameOverReason;
```

- [ ] **Step 7: 테스트 통과 확인**

Run: `flutter test test/features/game/presentation/providers/game_event_provider_test.dart`
Expected: PASS (기존 + 신규 5 tests). (hand-written state라 build_runner 불필요.)

- [ ] **Step 8: Commit (체크포인트)**

```bash
git add lib/features/game/presentation/providers/game_event_provider.dart test/features/game/presentation/providers/game_event_provider_test.dart
git commit -m "feat: 이벤트 모드 로컬 검거 집합/체포 로직 추가"
```

---

## Task 5: 도둑 ALIVE UI 분기 (`shouldShowArrestLock`)

**Files:**
- Create: `lib/features/game/domain/arrest_lock_visibility.dart`
- Modify: `lib/features/game/presentation/pages/game_page.dart` (isArrestedNow 블록)
- Test: `test/features/game/domain/arrest_lock_visibility_test.dart`

**Interfaces:**
- Produces: `bool shouldShowArrestLock({required bool isRobber, required bool isEventGame, required bool isArrested, required bool isEscaped})`.

- [ ] **Step 1: 실패 테스트 작성** — `arrest_lock_visibility_test.dart`

```dart
import 'package:cops_and_robbers/features/game/domain/arrest_lock_visibility.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('shouldShowArrestLock', () {
    test('true_when_robber_arrested_and_not_escaped_in_normal_mode', () {
      expect(
        shouldShowArrestLock(
            isRobber: true, isEventGame: false, isArrested: true, isEscaped: false),
        isTrue,
      );
    });

    test('false_in_event_mode_even_if_arrested', () {
      expect(
        shouldShowArrestLock(
            isRobber: true, isEventGame: true, isArrested: true, isEscaped: false),
        isFalse, // 이벤트 모드 도둑은 잡혀도 ALIVE
      );
    });

    test('false_when_escaped', () {
      expect(
        shouldShowArrestLock(
            isRobber: true, isEventGame: false, isArrested: true, isEscaped: true),
        isFalse,
      );
    });

    test('false_when_not_robber', () {
      expect(
        shouldShowArrestLock(
            isRobber: false, isEventGame: false, isArrested: true, isEscaped: false),
        isFalse,
      );
    });
  });
}
```

- [ ] **Step 2: 테스트 실패 확인**

Run: `flutter test test/features/game/domain/arrest_lock_visibility_test.dart`
Expected: FAIL — 함수 없음.

- [ ] **Step 3: 순수 함수 구현** — `arrest_lock_visibility.dart`

```dart
/// 도둑 잠금(감옥) 오버레이를 띄울지 판단.
///
/// 이벤트 모드에서는 도둑이 잡혀도 ALIVE로 유지되므로 항상 false.
/// 일반 모드에서는 "체포됨 && 탈옥 안 함"일 때만 true.
bool shouldShowArrestLock({
  required bool isRobber,
  required bool isEventGame,
  required bool isArrested,
  required bool isEscaped,
}) {
  if (!isRobber || isEventGame) return false;
  return isArrested && !isEscaped;
}
```

- [ ] **Step 4: game_page.dart 적용**

상단 import 추가:
```dart
import '../../domain/arrest_lock_visibility.dart';
```
기존 `isArrestedNow` 블록을 교체:
```dart
    final isEventGame = ref.watch(
      gameParticipantNotifierProvider.select((p) => p?.isEventGame ?? false),
    );
    final isArrested = ref.watch(
      gameEventNotifierProvider.select(
        (s) => s.arrestedParticipantIds.contains(widget.participantId),
      ),
    );
    final isEscaped = ref.watch(
      gameEventNotifierProvider.select(
        (s) => s.escapedParticipantIds.contains(widget.participantId),
      ),
    );
    final isArrestedNow = shouldShowArrestLock(
      isRobber: GameTeam.isRobber(widget.team),
      isEventGame: isEventGame,
      isArrested: isArrested,
      isEscaped: isEscaped,
    );
```

- [ ] **Step 5: 테스트 통과 + 정적 분석**

Run: `flutter test test/features/game/domain/arrest_lock_visibility_test.dart && flutter analyze lib/features/game/presentation/pages/game_page.dart`
Expected: PASS (4 tests), analyze 무경고.

- [ ] **Step 6: Commit (체크포인트)**

```bash
git add lib/features/game/domain/arrest_lock_visibility.dart lib/features/game/presentation/pages/game_page.dart test/features/game/domain/arrest_lock_visibility_test.dart
git commit -m "feat: 이벤트 모드 도둑 ALIVE UI 분기(잠금 오버레이 비활성)"
```

---

## Task 6: i18n 키 + pubspec 에셋 등록

**Files:**
- Modify: `lib/l10n/app_ko.arb`, `lib/l10n/app_en.arb`, `lib/l10n/app_ja.arb`
- Modify: `pubspec.yaml`

**Interfaces:**
- Produces: `l10n.gameEventArrestSuccessTitle`, `l10n.gameEventArrestSuccessMessage(String nickname)`, `l10n.gameEventArrestSuccessConfirm`, `l10n.gameEventResultTitle`, `l10n.gameEventResultArrestCount(int count)`.

- [ ] **Step 1: ARB 키 추가**

`app_ko.arb` (템플릿 — placeholder 메타 포함):
```json
  "gameEventArrestSuccessTitle": "운영진 검거",
  "gameEventArrestSuccessMessage": "{nickname} 검거 성공",
  "@gameEventArrestSuccessMessage": {
    "description": "이벤트 모드 — 체포 성공 메시지",
    "placeholders": { "nickname": { "type": "String" } }
  },
  "gameEventArrestSuccessConfirm": "확인",
  "gameEventResultTitle": "수사 종료",
  "gameEventResultArrestCount": "운영진 {count}명 검거",
  "@gameEventResultArrestCount": {
    "description": "이벤트 모드 결과 — 검거한 운영진 수",
    "placeholders": { "count": { "type": "int" } }
  },
```
`app_en.arb`:
```json
  "gameEventArrestSuccessTitle": "Suspect Caught",
  "gameEventArrestSuccessMessage": "Caught {nickname}",
  "gameEventArrestSuccessConfirm": "OK",
  "gameEventResultTitle": "Investigation Closed",
  "gameEventResultArrestCount": "{count} staff caught",
```
`app_ja.arb`:
```json
  "gameEventArrestSuccessTitle": "確保",
  "gameEventArrestSuccessMessage": "{nickname}を確保",
  "gameEventArrestSuccessConfirm": "確認",
  "gameEventResultTitle": "捜査終了",
  "gameEventResultArrestCount": "運営{count}名を確保",
```

- [ ] **Step 2: pubspec 에셋 등록**

`pubspec.yaml`의 `flutter: assets:` 목록에 추가:
```yaml
    - assets/events/
```

- [ ] **Step 3: l10n 생성 + 검증**

Run: `flutter gen-l10n && flutter analyze lib/l10n`
Expected: `app_localizations*.dart` 재생성, 무경고. (생성 파일 직접 편집 금지.)

- [ ] **Step 4: Commit (체크포인트)**

```bash
git add lib/l10n/app_ko.arb lib/l10n/app_en.arb lib/l10n/app_ja.arb pubspec.yaml
git commit -m "chore: 이벤트 모드 i18n 키 + assets/events 에셋 등록"
```

---

## Task 7: 체포 성공(증거 공개) 다이얼로그

**Files:**
- Create: `lib/features/game/presentation/widgets/event_arrest_success_dialog.dart`
- Test: `test/features/game/presentation/widgets/event_arrest_success_dialog_test.dart`

**Interfaces:**
- Consumes: i18n 키(Task 6), `assets/events/evidence{1,2,3}.svg`(Task 6 등록).
- Produces: `EventArrestSuccessDialog.show({required BuildContext context, required int evidenceIndex, required String robberNickname})`.

- [ ] **Step 1: 실패 테스트 작성** — `event_arrest_success_dialog_test.dart`

```dart
import 'package:cops_and_robbers/features/game/presentation/widgets/event_arrest_success_dialog.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(1125, 2436);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, _) => MaterialApp(
        locale: const Locale('ko'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('shows_evidence_slot_for_given_index_and_nickname', (tester) async {
    await _pump(
      tester,
      const EventArrestSuccessDialog(evidenceIndex: 2, robberNickname: '도둑1'),
    );

    expect(find.byKey(const ValueKey('event_evidence_2')), findsOneWidget);
    final l10n = AppLocalizations.of(
      tester.element(find.byType(EventArrestSuccessDialog)),
    );
    expect(find.text(l10n.gameEventArrestSuccessMessage('도둑1')), findsOneWidget);
  });

  testWidgets('caps_evidence_index_at_three', (tester) async {
    await _pump(
      tester,
      const EventArrestSuccessDialog(evidenceIndex: 5, robberNickname: 'x'),
    );
    expect(find.byKey(const ValueKey('event_evidence_3')), findsOneWidget);
  });
}
```

- [ ] **Step 2: 테스트 실패 확인**

Run: `flutter test test/features/game/presentation/widgets/event_arrest_success_dialog_test.dart`
Expected: FAIL — 위젯 없음.

- [ ] **Step 3: 구현** — `event_arrest_success_dialog.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/dialogs/dialog_animation.dart';

/// 이벤트 모드 — 운영진 체포 성공 피드백 다이얼로그(증거 공개).
///
/// 체포 순서(=누적 검거 수)로 `assets/events/evidence{N}.svg`를 공개한다.
/// 에셋은 evidence1~3 고정이라 인덱스를 3으로 cap. 경찰 화면 전용(라이트 테마).
class EventArrestSuccessDialog extends StatelessWidget {
  const EventArrestSuccessDialog({
    required this.evidenceIndex,
    required this.robberNickname,
    super.key,
  });

  /// 공개할 증거 인덱스 (1부터).
  final int evidenceIndex;

  /// 체포된 운영진 닉네임.
  final String robberNickname;

  static Future<void> show({
    required BuildContext context,
    required int evidenceIndex,
    required String robberNickname,
  }) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'EventArrestSuccess',
      barrierColor: DialogAnimation.barrierColor,
      transitionDuration: DialogAnimation.duration,
      pageBuilder: (_, _, _) => EventArrestSuccessDialog(
        evidenceIndex: evidenceIndex,
        robberNickname: robberNickname,
      ),
      transitionBuilder: DialogAnimation.buildTransition,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final slot = evidenceIndex.clamp(1, 3);
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: AppPadding.horizontal36,
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.xxlarge,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.gameEventArrestSuccessTitle,
              style: AppTextStyles.heading_20.copyWith(color: AppColors.black),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.vertical12),
            SizedBox(
              key: ValueKey('event_evidence_$slot'),
              width: 160.w,
              height: 160.w,
              child: SvgPicture.asset(
                'assets/events/evidence$slot.svg',
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: AppSpacing.vertical12),
            Text(
              l10n.gameEventArrestSuccessMessage(robberNickname),
              style:
                  AppTextStyles.paragraph_14.copyWith(color: AppColors.black600),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.vertical20),
            AppButton(
              text: l10n.gameEventArrestSuccessConfirm,
              onPressed: () => Navigator.of(context).pop(),
              backgroundColor: AppColors.blue,
              foregroundColor: AppColors.white,
              borderRadius: AppRadius.medium,
              showBorder: false,
              height: 48.h,
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: 테스트 통과 확인**

Run: `flutter test test/features/game/presentation/widgets/event_arrest_success_dialog_test.dart`
Expected: PASS (2 tests).

> SVG 파싱이 테스트에서 문제되면 슬롯은 `ValueKey`로 검증하므로 영향 없음(렌더 결과가 아닌 위젯 트리 확인).

- [ ] **Step 5: Commit (체크포인트)**

```bash
git add lib/features/game/presentation/widgets/event_arrest_success_dialog.dart test/features/game/presentation/widgets/event_arrest_success_dialog_test.dart
git commit -m "feat: 이벤트 모드 체포 성공(증거 공개) 다이얼로그"
```

---

## Task 8: 결과 증거 보드 위젯

**Files:**
- Create: `lib/features/game/presentation/widgets/event_result_board.dart`
- Test: `test/features/game/presentation/widgets/event_result_board_test.dart`

**Interfaces:**
- Consumes: i18n 키(Task 6), `assets/events/evidence{1,2,3}.svg`.
- Produces: `EventResultBoard.show({required BuildContext context, required int arrestCount, required VoidCallback onGoHome})`.

- [ ] **Step 1: 실패 테스트 작성** — `event_result_board_test.dart`

```dart
import 'package:cops_and_robbers/features/game/presentation/widgets/event_result_board.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(1125, 2436);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, _) => MaterialApp(
        locale: const Locale('ko'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('collected_slots_unlocked_and_remaining_slots_locked', (tester) async {
    await _pump(tester, EventResultBoard(arrestCount: 2, onGoHome: () {}));

    // 3개 슬롯 모두 존재
    expect(find.byKey(const ValueKey('event_result_slot_1')), findsOneWidget);
    expect(find.byKey(const ValueKey('event_result_slot_2')), findsOneWidget);
    expect(find.byKey(const ValueKey('event_result_slot_3')), findsOneWidget);
    // 미수집(3번)만 자물쇠
    expect(find.byKey(const ValueKey('event_result_lock_1')), findsNothing);
    expect(find.byKey(const ValueKey('event_result_lock_2')), findsNothing);
    expect(find.byKey(const ValueKey('event_result_lock_3')), findsOneWidget);
  });

  testWidgets('shows_arrest_count_text_and_only_home_button', (tester) async {
    await _pump(tester, EventResultBoard(arrestCount: 2, onGoHome: () {}));
    final l10n =
        AppLocalizations.of(tester.element(find.byType(EventResultBoard)));

    expect(find.text(l10n.gameEventResultArrestCount(2)), findsOneWidget);
    expect(find.text(l10n.buttonGoHome), findsOneWidget);
    expect(find.text(l10n.buttonPlayAgain), findsNothing); // 한 번 더 숨김
  });
}
```

- [ ] **Step 2: 테스트 실패 확인**

Run: `flutter test test/features/game/presentation/widgets/event_result_board_test.dart`
Expected: FAIL — 위젯 없음.

- [ ] **Step 3: 구현** — `event_result_board.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/dialogs/dialog_animation.dart';

/// 이벤트 모드 — 게임 종료 결과 증거 보드.
///
/// 수집한 증거(1..arrestCount)는 선명, 미수집은 50% 흐림 + 가운데 자물쇠로 표시.
/// "운영진 N명 검거" + "홈으로" 버튼(이벤트 모드는 rematch 없음).
class EventResultBoard extends StatelessWidget {
  const EventResultBoard({
    required this.arrestCount,
    required this.onGoHome,
    super.key,
  });

  final int arrestCount;
  final VoidCallback onGoHome;

  /// 고정 증거 에셋 수(evidence1~3).
  static const int _total = 3;

  /// 슬롯별 위치/회전 — 핀보드 콜라주(시각 QA 시 미세조정 가능).
  static const List<({double left, double top, double angle})> _slots = [
    (left: 16, top: 8, angle: -0.09),
    (left: 120, top: 20, angle: 0.09),
    (left: 70, top: 92, angle: -0.04),
  ];

  static Future<void> show({
    required BuildContext context,
    required int arrestCount,
    required VoidCallback onGoHome,
  }) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'EventResultBoard',
      barrierColor: DialogAnimation.barrierColor,
      transitionDuration: DialogAnimation.duration,
      pageBuilder: (_, _, _) => PopScope(
        canPop: false,
        child: EventResultBoard(arrestCount: arrestCount, onGoHome: onGoHome),
      ),
      transitionBuilder: DialogAnimation.buildTransition,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: AppPadding.horizontal36,
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.xxlarge,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.gameEventResultTitle,
              style: AppTextStyles.heading_20.copyWith(color: AppColors.black),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.vertical16),
            SizedBox(
              width: double.infinity,
              height: 190.h,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  for (int i = 1; i <= _total; i++)
                    _slot(i, i <= arrestCount),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.vertical16),
            Text(
              l10n.gameEventResultArrestCount(arrestCount),
              style: AppTextStyles.heading_20.copyWith(color: AppColors.blue),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.vertical20),
            AppButton(
              text: l10n.buttonGoHome,
              onPressed: onGoHome,
              backgroundColor: AppColors.blue,
              foregroundColor: AppColors.white,
              borderRadius: AppRadius.medium,
              showBorder: false,
              height: 48.h,
            ),
          ],
        ),
      ),
    );
  }

  Widget _slot(int index, bool collected) {
    final cfg = _slots[index - 1];
    final evidence = SvgPicture.asset(
      'assets/events/evidence$index.svg',
      width: 96.w,
      height: 80.w,
      fit: BoxFit.contain,
    );
    return Positioned(
      key: ValueKey('event_result_slot_$index'),
      left: cfg.left.w,
      top: cfg.top.h,
      child: Transform.rotate(
        angle: cfg.angle,
        child: collected
            ? evidence
            : Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(opacity: 0.5, child: evidence), // 50% 흐림
                  Container(
                    key: ValueKey('event_result_lock_$index'),
                    padding: EdgeInsets.all(6.w),
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.lock, size: 16.w, color: AppColors.black400),
                  ),
                ],
              ),
      ),
    );
  }
}
```

- [ ] **Step 4: 테스트 통과 확인**

Run: `flutter test test/features/game/presentation/widgets/event_result_board_test.dart`
Expected: PASS (2 tests).

- [ ] **Step 5: Commit (체크포인트)**

```bash
git add lib/features/game/presentation/widgets/event_result_board.dart test/features/game/presentation/widgets/event_result_board_test.dart
git commit -m "feat: 이벤트 모드 결과 증거 보드 위젯"
```

---

## Task 9: game_page 통합 — 진입 복원 + QR 체포 분기 + 결과 분기

**Files:**
- Modify: `lib/features/game/presentation/pages/game_page.dart`
  - `_initSettingsFromApiIfNeeded` (isEventGame 주입)
  - `_initGameConnections` (loadMyArrests)
  - QR 스캔 후 체포 블록 (이벤트 분기)
  - `_showGameOverDialog` (이벤트 결과 보드 분기)

**Interfaces:**
- Consumes: `kEventGameDevOverride`(Task 2), `GameSettingsResponse.isEventGame`(Task 1), `loadMyArrests`/`arrestRobberForEvent`/`myArrestedRobberIds`(Task 4), `EventArrestSuccessDialog`(Task 7), `EventResultBoard`(Task 8).

> 이 Task는 거대한 위젯에 대한 통합 와이어링이라 단위 테스트 대신 `flutter analyze` + dev 플래그 수동 검증으로 게이트한다(Agents.md: 프레임워크/통합 와이어링은 단위 테스트 비대상). 분기 핵심 로직은 Task 4/5/7/8에서 이미 단위 검증됨.

- [ ] **Step 1: import 추가**

```dart
import '../../../../core/constants/dev_flags.dart';
import '../widgets/event_arrest_success_dialog.dart';
import '../widgets/event_result_board.dart';
```

- [ ] **Step 2: `_initSettingsFromApiIfNeeded` — isEventGame 주입**

`final settings = await ...;` 이후, `setGameInfo`/`initFromLobby` 호출에 isEventGame 전달:
```dart
      final isEvent = settings.isEventGame || kEventGameDevOverride;

      // state가 null이면 (splash 재접속) 기본값으로 초기화
      if (ref.read(gameParticipantNotifierProvider) == null) {
        ref.read(gameParticipantNotifierProvider.notifier).setGameInfo(
              gameId: _gameId,
              nickname: '',
              team: widget.team,
              participantId: widget.participantId,
              isEventGame: isEvent,
            );
      }

      ref.read(gameParticipantNotifierProvider.notifier).initFromLobby(
            participantId: widget.participantId,
            maxParticipants: settings.maxParticipants,
            locationRevealIntervalMinutes: settings.locationRevealIntervalMinutes,
            policeWaitMinutes: settings.policeWaitMinutes,
            roundTimeMinutes: settings.roundDurationMinutes,
            isEventGame: isEvent,
          );
```

- [ ] **Step 3: `_initGameConnections` — 이벤트 모드 로컬 검거 복원**

`await _initSettingsFromApiIfNeeded(); if (!mounted) return;` 다음, **`_connectGameEvents()` 호출 이전**에 추가:
```dart
    // 이벤트 모드: 로컬 검거 집합 복원이 끝나야 재체포 차단/카운트/증거 인덱스가 정확하다.
    // 반드시 await — unawaited면 복원 전 QR 체포가 가능해 재체포/유실 위험(코드리뷰 P1).
    // (loadMyArrests는 union 병합이라 만약의 겹침에도 신규 검거를 잃지 않는다.)
    if (ref.read(gameParticipantNotifierProvider)?.isEventGame ?? false) {
      await ref.read(gameEventNotifierProvider.notifier).loadMyArrests(_gameId);
      if (!mounted) return;
    }
```

- [ ] **Step 4: QR 스캔 후 체포 블록 — 이벤트 분기**

기존 "이미 체포된 도둑 체크 + arrestRobber" 블록 앞에 이벤트 분기를 추가. (해당 메서드가 `async`인지 확인하고, 아니면 `async`로 전환.)
```dart
    final isEvent =
        ref.read(gameParticipantNotifierProvider)?.isEventGame ?? false;
    if (isEvent) {
      // 이벤트 모드: 내가 이미 검거한 운영진이면 차단
      if (ref
          .read(gameEventNotifierProvider)
          .myArrestedRobberIds
          .contains(participantId)) {
        AppSnackbar.show(
          context,
          message: AppLocalizations.of(context).errorAlreadyArrested,
        );
        return;
      }
      final result = await ref
          .read(gameEventNotifierProvider.notifier)
          .arrestRobberForEvent(_gameId, participantId);
      if (result != null && mounted) {
        await EventArrestSuccessDialog.show(
          context: context,
          evidenceIndex: result.evidenceIndex,
          robberNickname: result.robberNickname,
        );
      }
      return;
    }

    // --- 이하 기존 일반 모드 로직(전역 arrestedParticipantIds 기반) ---
    final arrestedIds = ref.read(gameEventNotifierProvider).arrestedParticipantIds;
    // ...기존 코드 유지...
```

- [ ] **Step 5: `_showGameOverDialog` — 이벤트 결과 보드 분기**

`final gameId = int.tryParse(widget.sessionId);` 다음, gameResultId null fallback **앞**에 추가:
```dart
    // 이벤트 모드: 서버 통계 대신 로컬 검거 카운트 + 증거 보드.
    if (ref.read(gameParticipantNotifierProvider)?.isEventGame ?? false) {
      final arrestCount =
          ref.read(gameEventNotifierProvider).myArrestedRobberIds.length;
      await EventResultBoard.show(
        context: context,
        arrestCount: arrestCount,
        onGoHome: () {
          if (GameOverGuard.shouldSkipDialogCallback(isMounted: mounted)) return;
          if (GameOverGuard.shouldRequestLeaveGameAfterGameOver() &&
              gameId != null) {
            _requestLeaveGameSilently(gameId);
          }
          ref.read(gameParticipantNotifierProvider.notifier).clear();
          _exitGameAfterAd(choice: 'home', destination: _homeAfterGameExit);
        },
      );
      return;
    }

    // gameResultId가 null인 경우 기존 방식으로 fallback
    if (gameResultId == null || winnerTeam == null) {
      // ...기존 유지...
```

- [ ] **Step 6: 정적 분석 + 빌드 확인**

Run: `flutter analyze lib/features/game/presentation/pages/game_page.dart`
Expected: 무경고.

- [ ] **Step 7: dev 플래그 수동 검증 (증거 — 단순 서술 금지, 실제 실행)**

Run: `flutter run --dart-define=EVENT_GAME_DEV=true` (또는 기존 게임 진입)
확인: ① 도둑팀이어도 잠금 오버레이 미표시 ② 경찰 QR 체포 시 증거 다이얼로그 등장 ③ 종료 시 증거 보드 + "운영진 N명 검거".
(에뮬레이터 미가용 시: 위 분기들이 모두 Task 4/5/7/8 단위 테스트로 커버됨을 근거로 명시.)

- [ ] **Step 8: Commit (체크포인트)**

```bash
git add lib/features/game/presentation/pages/game_page.dart
git commit -m "feat: game_page 이벤트 모드 통합(진입 복원/QR 체포/결과 보드)"
```

---

## Task 10: 라우팅 — 로비 스킵 인게임 직행

**Files:**
- Modify: `lib/features/session/presentation/providers/deeplink_join_notifier.dart` (`JoinedRoomOutcome`, `handle`)
- Modify: `lib/features/session/presentation/pages/deeplink_join_page.dart` (switch 분기)
- Modify: `lib/features/session/presentation/pages/home_page.dart` (`_joinRoom`)
- Test: `test/features/session/presentation/providers/deeplink_join_notifier_test.dart` (이벤트 분기 케이스 추가 또는 신규)

**Interfaces:**
- Consumes: `GameJoinResult.isEventGame`(Task 1), `GameTeam.police`, `RoutePaths.gameWithId`, `kEventGameDevOverride`.
- Produces: `JoinedRoomOutcome({required int gameId, required int participantId, @Default(false) bool isEventGame})`.

> ⚠️ `JoinedRoomOutcome`에 `participantId` 필수 추가 = union 시그니처 변경. `grep -rn "JoinedRoomOutcome(" lib test` 로 모든 생성 지점을 찾아 함께 갱신한다(현재 생산자는 `handle()` 1곳).

- [ ] **Step 1: 실패 테스트 작성** — `deeplink_join_notifier_test.dart` (이벤트 케이스)

```dart
import 'package:cops_and_robbers/features/session/domain/entities/game_join_result.dart';
import 'package:cops_and_robbers/features/session/presentation/providers/deeplink_join_notifier.dart';
// ... 기존 테스트 import(usecase override 등) 동일 패턴 사용 ...

test('handle_returns_joinedRoom_with_event_flag_and_participant', () async {
  // joinGameByInviteUseCaseProvider를 override해 isEventGame=true 결과 반환하도록 설정
  // (기존 테스트의 fake/override 패턴 재사용)
  final container = _containerWithJoinResult(
    const GameJoinResult(gameId: 9, participantId: 42, isEventGame: true),
    loggedIn: true,
  );
  final outcome =
      await container.read(deepLinkJoinNotifierProvider.notifier).handle('ABC');

  expect(
    outcome,
    const DeepLinkJoinOutcome.joinedRoom(
        gameId: 9, participantId: 42, isEventGame: true),
  );
});
```
> `_containerWithJoinResult`는 기존 테스트 파일의 헬퍼를 따른다(인증·usecase override). 기존 테스트 파일이 없으면 `authNotifierProvider`/`joinGameByInviteUseCaseProvider` override를 구성하는 최소 헬퍼를 작성한다.

- [ ] **Step 2: 테스트 실패 확인**

Run: `flutter test test/features/session/presentation/providers/deeplink_join_notifier_test.dart`
Expected: FAIL — `joinedRoom`에 `participantId`/`isEventGame` 인자 없음.

- [ ] **Step 3: `DeepLinkJoinOutcome.joinedRoom` 확장 + handle 전파**

`deeplink_join_notifier.dart`:
```dart
  /// join 성공 — [isEventGame]이면 인게임 직행, 아니면 [gameId] 대기실.
  const factory DeepLinkJoinOutcome.joinedRoom({
    required int gameId,
    required int participantId,
    @Default(false) bool isEventGame,
  }) = JoinedRoomOutcome;
```
handle()의 성공 반환:
```dart
      final result = await ref
          .read(joinGameByInviteUseCaseProvider)
          .execute(inviteCode);
      return DeepLinkJoinOutcome.joinedRoom(
        gameId: result.gameId,
        participantId: result.participantId,
        isEventGame: result.isEventGame,
      );
```

- [ ] **Step 4: 코드 생성**

Run: `dart run build_runner build --delete-conflicting-outputs`

- [ ] **Step 5: `deeplink_join_page.dart` 분기**

상단 import 추가:
```dart
import 'package:cops_and_robbers/core/constants/game_team.dart';
import 'package:cops_and_robbers/core/constants/dev_flags.dart';
```
switch의 `JoinedRoomOutcome` case 교체:
```dart
      case JoinedRoomOutcome(:final gameId, :final participantId, :final isEventGame):
        unawaited(
          ref.read(analyticsServiceProvider).logGameJoin(method: 'deeplink'),
        );
        if (isEventGame || kEventGameDevOverride) {
          // 이벤트 모드 — 로비 스킵, 경찰로 인게임 직행
          context.go(
            '${RoutePaths.gameWithId(gameId.toString())}'
            '?team=${GameTeam.police}&pid=$participantId',
          );
        } else {
          context.go(RoutePaths.waitingRoomWithId(gameId.toString()));
        }
```

- [ ] **Step 6: `home_page.dart` `_joinRoom` 분기**

상단 import 추가(미존재 시):
```dart
import 'package:cops_and_robbers/core/constants/game_team.dart';
import 'package:cops_and_robbers/core/constants/dev_flags.dart';
```
`setGameInfo` 호출에 isEventGame 전달:
```dart
      ref.read(gameParticipantNotifierProvider.notifier).setGameInfo(
            gameId: response.gameId,
            nickname: myNickname,
            participantId: response.participantId,
            isHost: false,
            isEventGame: response.isEventGame || kEventGameDevOverride,
          );
```
네비게이션 분기:
```dart
      if (mounted) {
        if (response.isEventGame || kEventGameDevOverride) {
          context.go(
            '${RoutePaths.gameWithId('${response.gameId}')}'
            '?team=${GameTeam.police}&pid=${response.participantId}',
          );
        } else {
          context.go(
            '${RoutePaths.waitingRoomWithId('${response.gameId}')}?inviteCode=$code',
          );
        }
      }
```

- [ ] **Step 6b: 활성 게임 복귀 경로 검토 (코드리뷰 P2 — 프론트 변경 없음, 근거 명시)**

`_checkActiveGameAndRedirect`(`home_page.dart:186-219`)와 `_redirectToActiveGame`(409 복귀, `:225-260`)는 `getMyActiveGameUsecase` 결과의 `gameStatus`로 분기한다:
- `IN_PROGRESS` → `gameWithId(...)?team=...&pid=...` (게임 직행) — **이벤트 참가자는 IN_PROGRESS로 join하므로 복귀도 IN_PROGRESS → 이미 게임 직행. 인게임 `isEventGame`는 설정 API로 복원(§Task 9)되어 로비 스킵이 보장된다.**
- `WAITING` → `waitingRoomWithId(...)` (대기실)

따라서 **현실적 이벤트 복귀(IN_PROGRESS)는 기존 코드로 이미 충족**된다. `WAITING` 분기를 이벤트로 전환하려면 `getMyActiveGameUsecase` 응답(`UserGameParticipationEntity`)에 `isEventGame`이 필요한데 현재 없고, `kEventGameDevOverride`를 여기 쓰면 **일반 게임 복귀까지 로비를 스킵**해 잘못된다. 그리고 이벤트 게임은 참가자 관점에서 WAITING 단계가 없다(로비 없음). → **프론트 변경 없음**, 아래 백엔드/기획 항목으로 이관:
- 백엔드 dep: 활성 게임 조회 응답에 `isEventGame` 추가(이벤트 게임이 참가자에게 WAITING으로 조회될 수 있는 경우에 한해).
- §9 확인: 이벤트 참가자가 WAITING 상태로 조회되는 시나리오가 실제 존재하는가.

- [ ] **Step 7: 테스트 + 정적 분석**

Run: `flutter test test/features/session/presentation/providers/deeplink_join_notifier_test.dart && flutter analyze lib/features/session`
Expected: PASS, 무경고.

- [ ] **Step 8: Commit (체크포인트)**

```bash
git add lib/features/session/presentation/providers/deeplink_join_notifier.dart lib/features/session/presentation/pages/deeplink_join_page.dart lib/features/session/presentation/pages/home_page.dart test/features/session/presentation/providers/deeplink_join_notifier_test.dart
git commit -m "feat: 이벤트 모드 로비 스킵 인게임 직행 라우팅"
```

---

## 최종 검증 (전체)

- [ ] **전체 테스트 + 분석**

Run: `flutter test && flutter analyze`
Expected: 전체 PASS, analyze 무경고.

- [ ] **백엔드 연동 대기 항목 (구현 후, 별도)**

dev 플래그(`kEventGameDevOverride`)는 백엔드(`join`·`GET /{id}`의 `isEventGame`, 엔진 룰 분기, 이벤트 방 생성 경로)가 준비되면 제거/검증한다. [EVENT_GAME_DESIGN.md §8](EVENT_GAME_DESIGN.md) 참조.

---

## Self-Review 결과 (작성자 점검)

- **Spec 커버리지**: 라우팅(T10)·부트스트랩/전파(T1·T2·T9)·영속화/체포(T3·T4)·도둑 ALIVE UI(T5)·체포 다이얼로그(T7)·결과 보드(T8·T9)·i18n/에셋(T6)·GameResultReason(이미 존재 → 변경 없음, T4에서 주석만 정정) 모두 매핑됨.
- **미해결(설계 §9)**: 운영진 도둑 앱 진입 경로 / 증거 고정3 vs 가변 / GAME_OVER `gameResultId` null / FORFEITED 조건 — 백엔드·기획 확인 후 반영(본 계획은 고정 3 증거·로컬 전용 결과·`team=POLICE` 가정으로 진행).
- **타입 일관성**: `isEventGame:bool`, `myArrestedRobberIds:Set<int>`, `arrestRobberForEvent → ({int evidenceIndex, String robberNickname})?`, `JoinedRoomOutcome(gameId, participantId, isEventGame)` 전 Task 일치.
- **플레이스홀더 스캔**: 통합 Task(T9) 외 모든 Task에 실제 코드/테스트 포함. T9는 통합 와이어링 특성상 단위 테스트 대신 정적분석+수동검증으로 게이트(분기 로직은 T4/T5/T7/T8에서 단위 검증).
