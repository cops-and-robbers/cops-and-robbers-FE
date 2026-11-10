import 'dart:async';
import 'dart:math';

import 'package:clock/clock.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/network/dio_exception_handler.dart';
import '../../../../core/services/background/background_service.dart';
import '../../../../core/services/background/background_service_provider.dart';
import '../../../../core/services/sound_service.dart';
import '../../data/datasources/radio_api_datasource.dart';
import '../../data/datasources/radio_room_port.dart';
import '../../data/models/radio_token_model.dart';
import '../../domain/radio_rules.dart';

part 'radio_session_provider.freezed.dart';
part 'radio_session_provider.g.dart';

@riverpod
RadioApi radioApi(Ref ref) => RadioApi(ref.watch(dioProvider));

/// 연결이 끊기면 방 객체를 새로 만든다 — LiveKit Room은 끊긴 뒤 다시 쓰지 않는다
@riverpod
RadioRoomPort Function() radioRoomFactory(Ref ref) => LiveKitRadioRoom.new;

@riverpod
Random radioRandom(Ref ref) => Random();

/// 다른 경찰이 말을 시작·끝낼 때 울리는 삑 소리
@riverpod
void Function() radioBeep(Ref ref) =>
    () => unawaited(SoundService.instance().radioBeep());

/// 앱이 화면에 떠 있는지 — 백그라운드에서는 마이크와 microphone 서비스를 열 수 없다(Android 14+)
@riverpod
bool Function() radioAppInForeground(Ref ref) => () {
  final lifecycle = WidgetsBinding.instance.lifecycleState;
  return lifecycle == null || lifecycle == AppLifecycleState.resumed;
};

/// 이 기기에서 무전 마이크를 허용한 적이 있는지.
///
/// 처음엔 버튼을 누를 때 권한을 묻고, 한 번 허용한 뒤로는 출동 때 마이크를 미리 올려
/// 첫 마디가 잘리지 않게 한다. 권한 자체는 OS가 들고 있고 이건 "물어봐도 팝업이 안 뜬다"는 표시다.
class RadioMicMemory {
  static const _key = 'radio_mic_granted';

  Future<bool> wasGranted() async =>
      (await SharedPreferences.getInstance()).getBool(_key) ?? false;

  Future<void> rememberGranted() async =>
      (await SharedPreferences.getInstance()).setBool(_key, true);
}

@riverpod
RadioMicMemory radioMicMemory(Ref ref) => RadioMicMemory();

enum RadioStatus { off, waitingPolice, connecting, ready, micDenied, reconnecting }

@freezed
class RadioSessionState with _$RadioSessionState {
  const factory RadioSessionState({
    @Default(RadioStatus.off) RadioStatus status,

    /// 내가 버튼을 누르고 말하는 중
    @Default(false) bool isTalking,

    /// 다른 경찰이 발언권을 쥐고 있으면 그 참가자 ID
    String? speakerIdentity,

    /// 마이크가 올라가 있어 누르면 바로 말할 수 있다. false면 첫 누름에 권한을 묻는다.
    @Default(false) bool isMicReady,
  }) = _RadioSessionState;
}

/// 경찰 팀 무전 연결 수명 (#697)
///
/// 출동 시각에 토큰을 받아 방에 들어가 마이크를 mute 상태로 올려 두고, 누르는 동안만 mute를 푼다.
/// 토큰은 수명의 70~90% 지점에서 다시 받는다 — 서버는 이 요청으로 자격을 다시 보고 사용 시간을 센다.
@riverpod
class RadioSession extends _$RadioSession {
  /// 거절이 아닌 실패(네트워크 등) 뒤 다시 시도할 간격
  static const _retryAfter = Duration(seconds: 10);

  /// 이 코드로 거절되면 이 게임에서 무전은 끝이다
  static const _endCodes = {
    'GAME_NOT_IN_PROGRESS',
    'PARTICIPANT_NOT_FOUND',
    'GAME_NOT_FOUND',
    'ONLY_POLICE_CAN_USE_RADIO',
    'RADIO_NOT_ALLOWED_IN_EVENT_GAME',
  };

  RadioRoomPort? _room;
  StreamSubscription<RadioRoomEvent>? _sub;
  Timer? _timer;
  RadioFloor _floor = const RadioFloor();
  bool _isActive = false;

  /// 방을 떠나거나 다시 붙을 때마다 올린다 — await 뒤 돌아온 옛 흐름이 새 세션을 건드리지 않게
  int _gen = 0;

  /// 출동 시각이 백그라운드에서 지나 입장을 미뤄 둔 상태
  bool _isJoinPending = false;

  /// 내 참가자 ID (토큰의 identity) — 내 발언도 발언권 순서에 넣는다
  String? _me;

  /// 손가락이 버튼 위에 있다 — 권한 팝업·마이크 준비가 끝났을 때 아직 누르고 있으면 바로 말한다
  bool _isHolding = false;
  bool _isPreparingMic = false;
  late BackgroundService _background;

  @override
  RadioSessionState build(int gameId) {
    // dispose 중에는 ref.read를 못 써서 미리 잡아 둔다
    _background = ref.read(backgroundServiceProvider);
    ref.onDispose(shutdown);
    return const RadioSessionState();
  }

  /// 출동 전이면 그 시각까지 기다렸다가 들어간다.
  void start({required DateTime policeReleaseAt}) {
    if (_isActive) return;
    _isActive = true;
    SoundService.instance().isRadioActive = true;
    final wait = policeReleaseAt.difference(clock.now());
    if (wait > Duration.zero) {
      state = state.copyWith(status: RadioStatus.waitingPolice);
      _timer = Timer(wait, _connect);
    } else {
      _connect();
    }
  }

  Future<void> press() async {
    final room = _room;
    final me = _me;
    if (room == null ||
        me == null ||
        state.status != RadioStatus.ready ||
        state.isTalking ||
        _floor.lockedFor(me)) {
      return;
    }
    _isHolding = true;
    if (!state.isMicReady) {
      // 처음 누름 — 여기서 OS 마이크 권한을 묻는다
      if (_isPreparingMic) return;
      final gen = _gen;
      final ok = await _prepareMic(gen);
      if (!ok ||
          _stale(gen) ||
          !_isHolding ||
          state.status != RadioStatus.ready ||
          _floor.lockedFor(me)) {
        return;
      }
    }
    // 내 발언도 순서에 넣는다 — 바로 뒤에 누른 경찰의 mute 해제가 와도 발언권은 나다
    _floor = _floor.onUnmuted(me);
    state = state.copyWith(isTalking: true);
    await room.setMicMuted(false);
  }

  Future<void> release() async {
    _isHolding = false;
    if (!state.isTalking) return;
    final me = _me;
    if (me != null) _floor = _floor.onMuted(me);
    // 내가 떼는 동안 계속 말하던 경찰이 있으면 그 사람이 발언권을 넘겨받는다
    state = state.copyWith(isTalking: false, speakerIdentity: _visibleSpeaker);
    await _room?.setMicMuted(true);
  }

  /// 누른 채 앱이 내려가면(전화 등) 손을 뗀 것으로 본다 — 열린 마이크가 남으면 안 된다
  Future<void> onAppPaused() => release();

  /// 백그라운드에서 출동 시각이 지났거나 끊겼으면 화면에 돌아온 지금 들어간다
  void onAppResumed() {
    if (_isActive && _isJoinPending) _connect();
  }

  Future<void> stop() async {
    _gen++;
    _isActive = false;
    _isJoinPending = false;
    _timer?.cancel();
    SoundService.instance().isRadioActive = false;
    unawaited(_background.stopRadio());
    _floor = const RadioFloor();
    state = const RadioSessionState();
    await _closeRoom();
  }

  /// 내가 아닌 발언권 주인 — 알약에 보일 사람
  String? get _visibleSpeaker {
    final holder = _floor.holder;
    return holder == _me ? null : holder;
  }

  bool _stale(int gen) => gen != _gen || !_isActive;

  Future<void> _connect() async {
    if (!_isActive) return;
    if (!ref.read(radioAppInForegroundProvider)()) {
      _isJoinPending = true;
      return;
    }
    _isJoinPending = false;
    final gen = _gen;
    if (state.status != RadioStatus.reconnecting) {
      state = state.copyWith(status: RadioStatus.connecting);
    }
    final token = await _issue();
    if (_stale(gen)) return;
    if (token == null) {
      if (state.status != RadioStatus.off) _retry(_connect);
      return;
    }
    _me = token.identity;
    final room = ref.read(radioRoomFactoryProvider)();
    _room = room;
    _sub = room.events.listen(_onEvent);
    try {
      await room.connect(token.url, token.token);
    } catch (e) {
      if (_stale(gen)) return;
      debugPrint('[Radio] ❌ 무전 방 접속 실패: $e');
      await _closeRoom();
      _retry(_connect);
      return;
    }
    if (_stale(gen)) return;
    // 듣기는 바로 된다. 마이크는 예전에 허용한 기기만 지금 올리고, 아니면 첫 누름에 묻는다.
    state = state.copyWith(status: RadioStatus.ready, isMicReady: false);
    _scheduleRefresh(token.lifetime);
    if (await ref.read(radioMicMemoryProvider).wasGranted() && !_stale(gen)) {
      await _prepareMic(gen);
    }
  }

  /// 마이크를 mute로 올린다. 처음이면 OS 권한 팝업이 뜬다.
  ///
  /// 거부해도 방에서 나가지 않는다 — 말하기만 막고 다른 경찰 무전은 계속 듣는다.
  Future<bool> _prepareMic(int gen) async {
    final room = _room;
    if (room == null) return false;
    _isPreparingMic = true;
    try {
      await room.publishMutedMic();
    } catch (e) {
      if (_stale(gen) || !identical(room, _room)) return false;
      debugPrint('[Radio] ⚠️ 마이크 사용 불가: $e');
      state = state.copyWith(status: RadioStatus.micDenied, isTalking: false);
      return false;
    } finally {
      _isPreparingMic = false;
    }
    if (_stale(gen) || !identical(room, _room)) return false;
    unawaited(ref.read(radioMicMemoryProvider).rememberGranted());
    state = state.copyWith(isMicReady: true);
    // 마이크를 받은 뒤에만 — 권한 없이 microphone 서비스를 띄우면 Android 14+가 거절한다
    unawaited(_background.startRadio());
    return true;
  }

  void _scheduleRefresh(Duration lifetime) {
    if (!_isActive) return;
    _timer?.cancel();
    _timer = Timer(
      radioRefreshDelay(lifetime, ref.read(radioRandomProvider)),
      _refresh,
    );
  }

  Future<void> _refresh() async {
    final gen = _gen;
    final token = await _issue();
    if (_stale(gen)) return;
    if (token != null) {
      _scheduleRefresh(token.lifetime);
    } else if (state.status != RadioStatus.off) {
      _retry(_refresh);
    }
  }

  /// 토큰을 받는다. 거절 코드에 따라 방을 떠나거나 대기 상태로 돌린다.
  Future<RadioTokenModel?> _issue() async {
    try {
      return await ref.read(radioApiProvider).issueToken(gameId);
    } on DioException catch (e) {
      final code = DioExceptionHandler.handle(e).code;
      if (_endCodes.contains(code)) {
        await stop();
      } else if (code == 'RADIO_POLICE_WAITING_TIME') {
        // 폰 시계가 서버보다 빨라 출동 전에 요청했다 — 잠시 뒤 다시
        state = state.copyWith(status: RadioStatus.waitingPolice);
      }
      return null;
    }
  }

  void _retry(Future<void> Function() action) {
    _timer?.cancel();
    _timer = Timer(_retryAfter, action);
  }

  void _onEvent(RadioRoomEvent event) {
    final before = _visibleSpeaker;
    switch (event) {
      case RemoteUnmuted(:final identity):
        _floor = _floor.onUnmuted(identity);
      case RemoteMuted(:final identity):
        _floor = _floor.onMuted(identity);
      case RoomDisconnected():
        _reconnect();
        return;
    }
    final after = _visibleSpeaker;
    if (after != before) {
      ref.read(radioBeepProvider)();
      state = state.copyWith(speakerIdentity: after);
    }
  }

  /// 끊긴 뒤에는 새 토큰부터 받는다 — 만료된 토큰으로 다시 붙으면 실패한다
  Future<void> _reconnect() async {
    if (!_isActive) return;
    _gen++; // 아직 진행 중인 옛 접속 흐름은 여기서 손을 뗀다
    _timer?.cancel();
    await _closeRoom();
    _floor = const RadioFloor();
    state = state.copyWith(
      status: RadioStatus.reconnecting,
      isTalking: false,
      speakerIdentity: null,
      isMicReady: false,
    );
    await _connect();
  }

  Future<void> _closeRoom() async {
    // 구독 해제는 기다리지 않는다 — 끊김 이벤트 콜백 안에서도 불리고, 기다릴 결과가 없다
    unawaited(_sub?.cancel());
    _sub = null;
    final room = _room;
    _room = null;
    await room?.disconnect();
  }

  /// 게임 화면이 닫힐 때 — 상태는 건드리지 않고 타이머·방·마이크 서비스만 즉시 정리한다.
  ///
  /// 화면 dispose 중에는 provider 상태를 바꿀 수 없고, autoDispose 정리는 다음 프레임이라
  /// 그 사이 출동 대기·재시도 타이머가 남지 않게 화면이 직접 부른다.
  void shutdown() {
    if (_isActive) unawaited(_background.stopRadio());
    _gen++;
    _isActive = false;
    _isJoinPending = false;
    SoundService.instance().isRadioActive = false;
    _timer?.cancel();
    _sub?.cancel();
    _sub = null;
    _room?.disconnect();
    _room = null;
  }
}
