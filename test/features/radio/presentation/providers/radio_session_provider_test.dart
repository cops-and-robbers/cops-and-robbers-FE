import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:clock/clock.dart';
import 'package:cops_and_robbers/core/services/background/background_service_provider.dart';
import 'package:cops_and_robbers/core/services/background/noop_background_service.dart';
import 'package:cops_and_robbers/features/radio/data/datasources/radio_api_datasource.dart';
import 'package:cops_and_robbers/features/radio/data/datasources/radio_room_port.dart';
import 'package:cops_and_robbers/features/radio/data/models/radio_token_model.dart';
import 'package:cops_and_robbers/features/radio/presentation/providers/radio_session_provider.dart';
import 'package:dio/dio.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// ── 시스템 경계 가짜: 게임 서버(토큰 API)와 음성 서버(LiveKit) ──

const _me = '101'; // 나(경찰 의민)의 참가자 ID
const _sanghee = '102';
const _changhee = '103';

String _jwt() {
  String part(Object json) =>
      base64Url.encode(utf8.encode(jsonEncode(json))).replaceAll('=', '');
  return '${part({'alg': 'HS256'})}.${part({'iat': 0, 'exp': 120})}.sig';
}

RadioTokenModel _token() => RadioTokenModel(
  url: 'wss://radio.test',
  room: 'game-7-police',
  identity: _me,
  token: _jwt(),
  expiresAt: '2026-11-10T21:30:00+09:00',
);

DioException _rejected(String code, int status) => DioException(
  requestOptions: RequestOptions(path: '/api/games/7/radio/token'),
  response: Response(
    requestOptions: RequestOptions(path: '/api/games/7/radio/token'),
    statusCode: status,
    data: {'errorCode': code, 'title': '', 'status': status, 'detail': ''},
  ),
  type: DioExceptionType.badResponse,
);

class _FakeRadioApi implements RadioApi {
  final requestedAt = <DateTime>[];

  /// null이면 정상 토큰, 아니면 그 예외로 거절한다
  DioException? rejectWith;

  /// 있으면 응답을 이 시점까지 붙잡아 둔다 — 요청 중에 화면이 닫히는 경우
  Completer<void>? hold;

  /// 요청마다 따로 정한 응답(null = 정상 토큰). 비어 있으면 [rejectWith]를 쓴다.
  /// 보낸 순서대로 소비해서, 붙잡혀 있던 두 요청이 서로 다른 답을 받게 한다.
  final queued = <DioException?>[];

  @override
  Future<RadioTokenModel> issueToken(int gameId) async {
    requestedAt.add(clock.now());
    final reject = queued.isNotEmpty ? queued.removeAt(0) : rejectWith;
    await hold?.future;
    if (reject != null) throw reject;
    return _token();
  }
}

class _FakeRoom implements RadioRoomPort {
  final _events = StreamController<RadioRoomEvent>.broadcast();
  String? connectedToken;
  bool published = false;
  bool micMuted = true;
  bool disconnected = false;
  bool micDenied = false;

  void emit(RadioRoomEvent e) => _events.add(e);

  @override
  Stream<RadioRoomEvent> get events => _events.stream;

  @override
  Future<void> connect(String url, String token) async => connectedToken = token;

  @override
  Future<void> publishMutedMic() async {
    if (micDenied) throw Exception('NotAllowedError: Permission denied');
    published = true;
    micMuted = true;
  }

  @override
  Future<void> setMicMuted(bool muted) async => micMuted = muted;

  @override
  Future<void> disconnect() async => disconnected = true;
}

/// 화면 꺼짐용 마이크 서비스 — 네이티브 경계
class _FakeBackground extends NoopBackgroundService {
  bool radioRunning = false;
  @override
  Future<void> startRadio() async => radioRunning = true;
  @override
  Future<void> stopRadio() async => radioRunning = false;
}

/// 이 기기에서 마이크를 허용한 적이 있는지 — 기기 저장소 경계
class _FakeMicMemory implements RadioMicMemory {
  _FakeMicMemory(this.granted);
  bool granted;
  @override
  Future<bool> wasGranted() async => granted;
  @override
  Future<void> rememberGranted() async => granted = true;
}

class _MidRandom implements Random {
  @override
  double nextDouble() => 0.5; // 수명 2분 → 96초 뒤 재발급
  @override
  int nextInt(int max) => 0;
  @override
  bool nextBool() => false;
}

class _Harness {
  _Harness() {
    container = ProviderContainer(
      overrides: [
        radioApiProvider.overrideWithValue(api),
        radioRoomFactoryProvider.overrideWithValue(() {
          final room = _FakeRoom()..micDenied = denyMic;
          rooms.add(room);
          return room;
        }),
        radioRandomProvider.overrideWithValue(_MidRandom()),
        radioBeepProvider.overrideWithValue(() => beeps++),
        backgroundServiceProvider.overrideWithValue(background),
        radioAppInForegroundProvider.overrideWithValue(() => foreground),
        radioMicMemoryProvider.overrideWithValue(micMemory),
      ],
    );
    container.listen(radioSessionProvider(7), (_, _) {});
  }

  final api = _FakeRadioApi();
  final background = _FakeBackground();
  final rooms = <_FakeRoom>[];
  bool denyMic = false;
  bool foreground = true;

  /// 기본은 예전 게임에서 마이크를 허용한 경찰 — 입장 때 바로 마이크를 준비한다
  final micMemory = _FakeMicMemory(true);
  int beeps = 0;
  late final ProviderContainer container;

  RadioSession get session => container.read(radioSessionProvider(7).notifier);
  RadioSessionState get state => container.read(radioSessionProvider(7));
  _FakeRoom get room => rooms.last;
}

/// 화면이 보는 것과 같은 무전 상태 전이 기록 — 스낵바는 화면이 이 전이를 보고 띄운다
List<RadioStatus> _watchStatus(_Harness h) {
  final seen = <RadioStatus>[];
  h.container.listen(
    radioSessionProvider(7).select((s) => s.status),
    (_, next) => seen.add(next),
  );
  return seen;
}

void main() {
  final gameStart = DateTime(2026, 11, 10, 20);
  final release = gameStart.add(const Duration(minutes: 3)); // 경찰 대기 3분

  void inGame(void Function(FakeAsync async, _Harness h) body) {
    fakeAsync((async) {
      final h = _Harness();
      body(async, h);
      h.container.dispose();
      async.flushMicrotasks();
    }, initialTime: gameStart);
  }

  test('stays_waiting_and_does_not_request_token_before_police_release', () {
    inGame((async, h) {
      h.session.start(policeReleaseAt: release);
      async.elapse(const Duration(minutes: 2));
      expect(h.state.status, RadioStatus.waitingPolice);
      expect(h.api.requestedAt, isEmpty);
    });
  });

  test('joins_muted_when_police_release_time_passes', () {
    inGame((async, h) {
      h.session.start(policeReleaseAt: release);
      async.elapse(const Duration(minutes: 3, seconds: 1));
      expect(h.state.status, RadioStatus.ready);
      expect(h.room.published, isTrue);
      expect(h.room.micMuted, isTrue);
    });
  });

  test('joins_within_seconds_when_server_releases_police_slightly_late', () {
    inGame((async, h) {
      // 서버의 출동 처리가 예정 시각보다 조금 늦어, 정각에 보낸 첫 요청은 대기 중으로 거절된다
      h.api.rejectWith = _rejected('RADIO_POLICE_WAITING_TIME', 400);
      h.session.start(policeReleaseAt: release);
      async.elapse(const Duration(minutes: 3));
      expect(h.state.status, RadioStatus.waitingPolice);

      h.api.rejectWith = null; // 그 사이 서버가 출동을 반영했다
      async.elapse(const Duration(seconds: 2));
      expect(h.state.status, RadioStatus.ready);
    });
  });

  test('reissues_token_96_seconds_after_previous_response', () {
    inGame((async, h) {
      h.session.start(policeReleaseAt: gameStart);
      async.flushMicrotasks();
      async.elapse(const Duration(seconds: 97));
      expect(h.api.requestedAt.length, 2);
      expect(
        h.api.requestedAt[1].difference(h.api.requestedAt[0]),
        const Duration(seconds: 96),
      );
    });
  });

  test('leaves_room_and_hides_radio_when_reissue_rejected_after_game_over', () {
    inGame((async, h) {
      h.session.start(policeReleaseAt: gameStart);
      async.flushMicrotasks();
      h.session.press(); // 말하는 중에 게임이 끝났다
      async.flushMicrotasks();
      h.api.rejectWith = _rejected('GAME_NOT_IN_PROGRESS', 400);
      async.elapse(const Duration(seconds: 97));
      expect(h.state.status, RadioStatus.off);
      expect(h.state.isTalking, isFalse);
      expect(h.room.disconnected, isTrue);
    });
  });

  test('fetches_new_token_before_reconnecting_after_network_drop', () {
    inGame((async, h) {
      h.session.start(policeReleaseAt: gameStart);
      async.flushMicrotasks();
      h.room.emit(const RoomDisconnected()); // WiFi → LTE
      async.flushMicrotasks();
      expect(h.api.requestedAt.length, 2);
      expect(h.rooms.length, 2);
      expect(h.state.status, RadioStatus.ready);
    });
  });

  test('press_is_ignored_while_another_police_holds_floor', () {
    inGame((async, h) {
      h.session.start(policeReleaseAt: gameStart);
      async.flushMicrotasks();
      h.room.emit(const RemoteUnmuted(_sanghee));
      async.flushMicrotasks();
      h.session.press();
      async.flushMicrotasks();
      expect(h.state.speakerIdentity, _sanghee);
      expect(h.state.isTalking, isFalse);
      expect(h.room.micMuted, isTrue);
    });
  });

  test('beeps_when_another_police_starts_and_stops_talking', () {
    inGame((async, h) {
      h.session.start(policeReleaseAt: gameStart);
      async.flushMicrotasks();
      h.room.emit(const RemoteUnmuted(_sanghee));
      h.room.emit(const RemoteUnmuted(_changhee)); // 거의 동시에 — 발언권은 상희
      async.flushMicrotasks();
      expect(h.state.speakerIdentity, _sanghee);
      h.room.emit(const RemoteMuted(_sanghee)); // 창희는 아직 말하는 중이라 넘어간다
      async.flushMicrotasks();
      expect(h.state.speakerIdentity, _changhee);
      h.room.emit(const RemoteMuted(_changhee));
      async.flushMicrotasks();
      expect(h.beeps, 3);
      expect(h.state.speakerIdentity, isNull);
    });
  });

  test('mic_opens_while_pressed_and_closes_on_release', () {
    inGame((async, h) {
      h.session.start(policeReleaseAt: gameStart);
      async.flushMicrotasks();
      h.session.press();
      async.flushMicrotasks();
      expect(h.room.micMuted, isFalse);
      expect(h.state.isTalking, isTrue);
      h.session.release(); // 손가락이 버튼 밖으로 미끄러져 취소된 경우도 이 경로
      async.flushMicrotasks();
      expect(h.room.micMuted, isTrue);
      expect(h.state.isTalking, isFalse);
    });
  });

  test('mutes_when_app_goes_background_while_talking', () {
    inGame((async, h) {
      h.session.start(policeReleaseAt: gameStart);
      async.flushMicrotasks();
      h.session.press();
      async.flushMicrotasks();
      h.session.onAppPaused(); // 전화가 왔다
      async.flushMicrotasks();
      expect(h.room.micMuted, isTrue);
    });
  });

  // 마이크 서비스는 방에 들어가 마이크를 받은 뒤에만 — 권한 없이 띄우면 Android 14+에서 거절된다
  test('keeps_radio_alive_with_screen_off_only_after_joining', () {
    inGame((async, h) {
      h.session.start(policeReleaseAt: release);
      async.elapse(const Duration(minutes: 1));
      expect(h.background.radioRunning, isFalse);
      async.elapse(const Duration(minutes: 3));
      expect(h.background.radioRunning, isTrue);
    });
  });

  test('stops_screen_off_radio_when_game_ends', () {
    inGame((async, h) {
      h.session.start(policeReleaseAt: gameStart);
      async.flushMicrotasks();
      h.api.rejectWith = _rejected('GAME_NOT_IN_PROGRESS', 400);
      async.elapse(const Duration(seconds: 97));
      expect(h.background.radioRunning, isFalse);
    });
  });

  // 게임 화면을 닫는 순간 기다리던 출동 타이머·재시도 타이머가 남으면 안 된다
  test('leaves_no_timer_when_game_screen_closes_while_waiting_for_dispatch', () {
    inGame((async, h) {
      h.session.start(policeReleaseAt: release);
      async.flushMicrotasks();
      h.session.shutdown();
      expect(async.pendingTimers, isEmpty);
      expect(h.background.radioRunning, isFalse);
    });
  });

  test('leaves_no_room_when_game_screen_closes_while_token_request_in_flight', () {
    inGame((async, h) {
      h.api.hold = Completer<void>();
      h.session.start(policeReleaseAt: gameStart);
      async.flushMicrotasks();
      h.session.shutdown(); // 토큰을 기다리는 사이 게임 화면을 나갔다
      h.api.hold!.complete();
      async.flushMicrotasks();
      expect(h.rooms, isEmpty);
      expect(h.background.radioRunning, isFalse);
      expect(async.pendingTimers, isEmpty);
    });
  });

  test('stops_refreshing_when_game_ends_while_reissue_in_flight', () {
    inGame((async, h) {
      h.session.start(policeReleaseAt: gameStart);
      async.flushMicrotasks();
      h.api.hold = Completer<void>();
      async.elapse(const Duration(seconds: 97)); // 재발급 요청이 나가 있다
      h.session.stop();
      h.api.hold!.complete();
      async.flushMicrotasks();
      expect(async.pendingTimers, isEmpty);
    });
  });

  // 출동 대기 중 폰을 잠갔다 — 백그라운드에서는 마이크·microphone 서비스를 열 수 없다(Android 14+)
  test('waits_for_app_to_return_before_joining_when_dispatch_passes_in_background', () {
    inGame((async, h) {
      h.foreground = false;
      h.session.start(policeReleaseAt: release);
      async.elapse(const Duration(minutes: 4));
      expect(h.rooms, isEmpty);
      expect(h.background.radioRunning, isFalse);
      h.foreground = true;
      h.session.onAppResumed();
      async.flushMicrotasks();
      expect(h.state.status, RadioStatus.ready);
      expect(h.background.radioRunning, isTrue);
    });
  });

  // 내가 먼저 눌렀고 상희가 수십 ms 뒤에 눌렀다 — 발언권은 나, 상희 알약·삑이 뜨면 안 된다
  test('keeps_my_floor_without_pill_when_another_cop_presses_right_after_me', () {
    inGame((async, h) {
      h.session.start(policeReleaseAt: gameStart);
      async.flushMicrotasks();
      h.session.press();
      async.flushMicrotasks();
      h.room.emit(const RemoteUnmuted(_sanghee));
      async.flushMicrotasks();
      expect(h.state.speakerIdentity, isNull);
      expect(h.beeps, 0);
      expect(h.state.isTalking, isTrue);
    });
  });

  // 처음 무전을 쓰는 경찰 — 출동 때는 듣기만, 팝업은 버튼을 처음 누를 때 (#697)
  test('joins_listening_only_without_mic_popup_when_never_granted', () {
    inGame((async, h) {
      h.micMemory.granted = false;
      h.session.start(policeReleaseAt: gameStart);
      async.flushMicrotasks();
      expect(h.state.status, RadioStatus.ready);
      expect(h.state.isMicReady, isFalse);
      expect(h.room.published, isFalse);
      expect(h.background.radioRunning, isFalse);
    });
  });

  test('asks_for_mic_on_first_press_and_talks_while_still_holding', () {
    inGame((async, h) {
      h.micMemory.granted = false;
      h.session.start(policeReleaseAt: gameStart);
      async.flushMicrotasks();
      h.session.press(); // 허용 팝업 → 허용, 손은 계속 누르고 있다
      async.flushMicrotasks();
      expect(h.room.published, isTrue);
      expect(h.room.micMuted, isFalse);
      expect(h.state.isTalking, isTrue);
      expect(h.micMemory.granted, isTrue);
      expect(h.background.radioRunning, isTrue);
    });
  });

  test('stays_muted_when_finger_lifted_while_mic_popup_was_open', () {
    inGame((async, h) {
      h.micMemory.granted = false;
      h.session.start(policeReleaseAt: gameStart);
      async.flushMicrotasks();
      h.session.press();
      h.session.release(); // 팝업이 뜨면서 손가락이 떨어졌다
      async.flushMicrotasks();
      expect(h.room.published, isTrue);
      expect(h.room.micMuted, isTrue);
      expect(h.state.isTalking, isFalse);
    });
  });

  // 거부해도 게임은 그대로, 말하기만 막히고 다른 경찰 무전은 계속 듣는다
  test('keeps_listening_when_mic_refused_on_first_press', () {
    inGame((async, h) {
      h.micMemory.granted = false;
      h.denyMic = true;
      h.session.start(policeReleaseAt: gameStart);
      async.flushMicrotasks();
      h.session.press();
      async.flushMicrotasks();
      expect(h.state.status, RadioStatus.micDenied);
      expect(h.room.disconnected, isFalse);
      expect(h.background.radioRunning, isFalse);
      h.room.emit(const RemoteUnmuted(_sanghee));
      async.flushMicrotasks();
      expect(h.state.speakerIdentity, _sanghee);
    });
  });

  // 첫 팝업에서 거부했다가 설정에서 마이크를 허용하고 게임으로 돌아와 다시 눌렀다
  test('talks_when_pressed_again_after_allowing_mic_in_settings', () {
    inGame((async, h) {
      h.micMemory.granted = false;
      h.denyMic = true;
      h.session.start(policeReleaseAt: gameStart);
      async.flushMicrotasks();
      h.session.press();
      async.flushMicrotasks();
      h.session.release();
      h.room.micDenied = false; // 설정에서 허용
      h.session.press();
      async.flushMicrotasks();
      expect(h.state.status, RadioStatus.ready);
      expect(h.state.isTalking, isTrue);
      expect(h.room.micMuted, isFalse);
    });
  });

  // 거부한 채로 다시 눌렀다 — 여전히 말할 수 없고, 화면이 설정 안내를 띄울 수 있게 거부 상태로 남는다
  test('stays_denied_when_pressed_again_without_allowing_mic', () {
    inGame((async, h) {
      h.micMemory.granted = false;
      h.denyMic = true;
      h.session.start(policeReleaseAt: gameStart);
      async.flushMicrotasks();
      h.session.press();
      async.flushMicrotasks();
      h.session.release();
      h.session.press();
      async.flushMicrotasks();
      expect(h.state.status, RadioStatus.micDenied);
      expect(h.state.isTalking, isFalse);
    });
  });

  // ── 무전 서버 혼잡 (#722, BE #253: 503 RADIO_SERVER_BUSY) ──

  // 무전 서버가 과부하인 중에 경찰이 출동했다 — 방에 못 들어가고 10초마다 다시 두드린다
  test('stays_busy_and_retries_every_10_seconds_when_police_released_during_congestion', () {
    inGame((async, h) {
      h.api.rejectWith = _rejected('RADIO_SERVER_BUSY', 503);
      h.session.start(policeReleaseAt: release);
      async.elapse(const Duration(minutes: 3));
      expect(h.state.status, RadioStatus.serverBusy);
      expect(h.rooms, isEmpty);

      async.elapse(const Duration(seconds: 25));
      final at = h.api.requestedAt;
      expect(at.length, 3);
      expect([at[1].difference(at[0]), at[2].difference(at[1])], [
        const Duration(seconds: 10),
        const Duration(seconds: 10),
      ]);
      expect(h.state.status, RadioStatus.serverBusy);
    });
  });

  // 혼잡이 35초 이어져 네 번 거절당했다 — 안내는 처음 한 번만 떠야 한다
  test('enters_busy_once_when_token_is_refused_on_every_10_second_retry', () {
    inGame((async, h) {
      final seen = _watchStatus(h);
      h.api.rejectWith = _rejected('RADIO_SERVER_BUSY', 503);
      h.session.start(policeReleaseAt: gameStart);
      async.elapse(const Duration(seconds: 35));
      expect(h.api.requestedAt.length, 4);
      expect(seen, [RadioStatus.connecting, RadioStatus.serverBusy]);
    });
  });

  // 혼잡이 풀렸다 — 다음 10초 시도에서 방에 들어가 바로 쓸 수 있다
  test('joins_muted_when_congestion_clears_on_next_retry', () {
    inGame((async, h) {
      final seen = _watchStatus(h);
      h.api.rejectWith = _rejected('RADIO_SERVER_BUSY', 503);
      h.session.start(policeReleaseAt: gameStart);
      async.flushMicrotasks();
      h.api.rejectWith = null;
      async.elapse(const Duration(seconds: 10));
      expect(seen, [
        RadioStatus.connecting,
        RadioStatus.serverBusy,
        RadioStatus.ready,
      ]);
      expect(h.room.published, isTrue);
      expect(h.room.micMuted, isTrue);
    });
  });

  // WiFi에서 LTE로 넘어가며 끊긴 경찰이 다시 붙으려는데 그 사이 서버가 혼잡해졌다
  test('turns_busy_when_cop_reconnects_during_congestion', () {
    inGame((async, h) {
      h.session.start(policeReleaseAt: gameStart);
      async.flushMicrotasks();
      expect(h.state.status, RadioStatus.ready);

      h.api.rejectWith = _rejected('RADIO_SERVER_BUSY', 503);
      h.room.emit(const RoomDisconnected());
      async.flushMicrotasks();
      expect(h.state.status, RadioStatus.serverBusy);
      expect(h.state.isMicReady, isFalse);
      expect(h.state.isTalking, isFalse);
      expect(h.rooms.length, 1);

      h.api.rejectWith = null;
      async.elapse(const Duration(seconds: 10));
      expect(h.state.status, RadioStatus.ready);
      expect(h.rooms.length, 2);
    });
  });

  // 이미 무전 중인 경찰 — 혼잡 중에도 서버는 재발급을 통과시킨다. 쓰던 무전은 그대로다
  test('connected_cop_stays_ready_when_token_reissue_passes_during_congestion', () {
    inGame((async, h) {
      final seen = _watchStatus(h);
      h.session.start(policeReleaseAt: gameStart);
      async.flushMicrotasks();
      async.elapse(const Duration(seconds: 97));
      expect(h.api.requestedAt.length, 2);
      expect(seen, [RadioStatus.connecting, RadioStatus.ready]);
      expect(h.rooms.length, 1);
    });
  });

  // 터널에서 재발급이 3분 넘게 밀린 경찰 — 신호가 돌아왔을 때 재발급이 혼잡으로 거절된다.
  // 듣고 말하던 무전은 그대로여야 한다 (버튼이 회색이 되면 안 된다)
  test('connected_cop_keeps_radio_when_token_reissue_is_refused_as_busy', () {
    inGame((async, h) {
      h.session.start(policeReleaseAt: gameStart);
      async.flushMicrotasks();
      h.api.rejectWith = _rejected('RADIO_SERVER_BUSY', 503);
      async.elapse(const Duration(seconds: 97));
      expect(h.state.status, RadioStatus.ready);
      expect(h.room.disconnected, isFalse);

      async.elapse(const Duration(seconds: 10)); // 10초 뒤 재발급을 다시 시도한다
      expect(h.api.requestedAt.length, 3);
    });
  });

  // 토큰 요청이 걸린 사이 게임이 끝났고, 늦게 온 응답이 혼잡 거절이다 — 결과 화면에 혼잡 안내가 뜨면 안 된다
  // 무전 중이던 경찰의 재발급 요청이 응답을 기다리는 사이 네트워크가 끊겨 다시 붙는다.
  // 늦게 도착한 옛 요청의 혼잡 거절이 새로 붙는 세션을 혼잡으로 바꾸면 안 된다 —
  // 바꾸면 혼잡 안내와 "연결됐어요"가 잘못 뜬다.
  test('ignores_busy_answer_of_old_reissue_when_cop_already_reconnecting_after_network_drop', () {
    inGame((async, h) {
      h.session.start(policeReleaseAt: gameStart);
      async.flushMicrotasks();
      final seen = _watchStatus(h);
      h.api.hold = Completer<void>();
      h.api.queued.addAll([_rejected('RADIO_SERVER_BUSY', 503), null]);
      async.elapse(const Duration(seconds: 97)); // 재발급 요청이 나가 응답 대기 중
      h.room.emit(const RoomDisconnected()); // 그 사이 WiFi → LTE
      async.flushMicrotasks();
      expect(h.api.requestedAt.length, 3);
      h.api.hold!.complete();
      async.flushMicrotasks();
      expect(seen, isNot(contains(RadioStatus.serverBusy)));
      expect(h.state.status, RadioStatus.ready);
    });
  });

  test('stays_off_when_busy_answer_arrives_after_game_ended', () {
    inGame((async, h) {
      h.api.hold = Completer<void>();
      h.api.rejectWith = _rejected('RADIO_SERVER_BUSY', 503);
      h.session.start(policeReleaseAt: gameStart);
      async.flushMicrotasks();
      h.session.stop();
      async.flushMicrotasks();
      h.api.hold!.complete();
      async.flushMicrotasks();
      expect(h.state.status, RadioStatus.off);
    });
  });

  // 혼잡한 채 화면을 껐다 켰다 — 돌아오자마자 다시 두드리고, 여전히 혼잡이면 조용하다
  test('retries_without_new_busy_transition_when_app_returns_during_congestion', () {
    inGame((async, h) {
      final seen = _watchStatus(h);
      h.api.rejectWith = _rejected('RADIO_SERVER_BUSY', 503);
      h.session.start(policeReleaseAt: gameStart);
      async.flushMicrotasks();
      h.foreground = false;
      async.elapse(const Duration(seconds: 10));
      expect(h.api.requestedAt.length, 1);

      h.foreground = true;
      h.session.onAppResumed();
      async.flushMicrotasks();
      expect(h.api.requestedAt.length, 2);
      expect(seen, [RadioStatus.connecting, RadioStatus.serverBusy]);
    });
  });

  // 혼잡 중 다음 시도는 신호가 끊겨 코드 없이 실패했다 — "연결 중"으로 돌아갔다가 다시 혼잡 안내가 뜨면 안 된다
  test('stays_busy_when_next_retry_fails_without_error_code', () {
    inGame((async, h) {
      final seen = _watchStatus(h);
      h.api.rejectWith = _rejected('RADIO_SERVER_BUSY', 503);
      h.session.start(policeReleaseAt: gameStart);
      async.flushMicrotasks();
      h.api.rejectWith = DioException(
        requestOptions: RequestOptions(path: '/api/games/7/radio/token'),
        type: DioExceptionType.connectionError,
      );
      async.elapse(const Duration(seconds: 10));
      expect(seen, [RadioStatus.connecting, RadioStatus.serverBusy]);

      h.api.rejectWith = null;
      async.elapse(const Duration(seconds: 10));
      expect(seen.last, RadioStatus.ready);
    });
  });
}
