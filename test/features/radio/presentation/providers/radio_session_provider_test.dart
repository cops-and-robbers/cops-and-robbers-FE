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

  @override
  Future<RadioTokenModel> issueToken(int gameId) async {
    requestedAt.add(clock.now());
    await hold?.future;
    if (rejectWith != null) throw rejectWith!;
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
      expect(h.state.talking, isFalse);
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
      expect(h.state.talking, isFalse);
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
      expect(h.state.talking, isTrue);
      h.session.release(); // 손가락이 버튼 밖으로 미끄러져 취소된 경우도 이 경로
      async.flushMicrotasks();
      expect(h.room.micMuted, isTrue);
      expect(h.state.talking, isFalse);
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
      expect(h.state.talking, isTrue);
    });
  });

  // 처음 무전을 쓰는 경찰 — 출동 때는 듣기만, 팝업은 버튼을 처음 누를 때 (#697)
  test('joins_listening_only_without_mic_popup_when_never_granted', () {
    inGame((async, h) {
      h.micMemory.granted = false;
      h.session.start(policeReleaseAt: gameStart);
      async.flushMicrotasks();
      expect(h.state.status, RadioStatus.ready);
      expect(h.state.micReady, isFalse);
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
      expect(h.state.talking, isTrue);
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
      expect(h.state.talking, isFalse);
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
}
