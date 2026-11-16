import 'dart:async';

import 'package:livekit_client/livekit_client.dart';

/// 무전 방에서 앱이 알아야 하는 일 — 원격 경찰의 mute 해제/mute, 연결 끊김
sealed class RadioRoomEvent {
  const RadioRoomEvent();
}

class RemoteUnmuted extends RadioRoomEvent {
  const RemoteUnmuted(this.identity);
  final String identity;
}

class RemoteMuted extends RadioRoomEvent {
  const RemoteMuted(this.identity);
  final String identity;
}

class RoomDisconnected extends RadioRoomEvent {
  const RoomDisconnected();
}

/// 음성 서버(LiveKit)와의 경계. 테스트는 이 인터페이스를 가짜로 바꾼다.
abstract class RadioRoomPort {
  Future<void> connect(String url, String token);

  /// 마이크 트랙을 올리고 바로 mute — 누를 때마다 publish하면 협상 지연으로 첫 음절이 잘린다.
  /// 마이크 권한이 없으면 예외를 던진다.
  Future<void> publishMutedMic();

  Future<void> setMicMuted(bool muted);

  Stream<RadioRoomEvent> get events;

  Future<void> disconnect();
}

/// [RadioRoomPort]의 LiveKit 구현 — 로직 없이 SDK 호출과 이벤트 변환만 한다.
class LiveKitRadioRoom implements RadioRoomPort {
  // mute 때 캡처를 멈추지 않는다 — 멈추면 unmute마다 마이크를 다시 열어 첫 음절이 잘린다.
  // 대가로 방에 있는 동안 OS 마이크 표시가 켜져 있다.
  static const _capture = AudioCaptureOptions(stopAudioCaptureOnMute: false);

  final _room = Room();
  final _events = StreamController<RadioRoomEvent>.broadcast();
  EventsListener<RoomEvent>? _listener;

  @override
  Stream<RadioRoomEvent> get events => _events.stream;

  @override
  Future<void> connect(String url, String token) async {
    _listener ??= _room.createListener()
      ..on<TrackUnmutedEvent>((e) {
        if (e.participant is RemoteParticipant) {
          _events.add(RemoteUnmuted(e.participant.identity));
        }
      })
      ..on<TrackMutedEvent>((e) {
        if (e.participant is RemoteParticipant) {
          _events.add(RemoteMuted(e.participant.identity));
        }
      })
      // 방에 들어온 경찰이 이미 말하는 중이면 mute 해제 이벤트가 오지 않아 첫 구독 때 상태를 본다
      ..on<TrackSubscribedEvent>((e) {
        if (!e.publication.muted) {
          _events.add(RemoteUnmuted(e.participant.identity));
        }
      })
      ..on<ParticipantDisconnectedEvent>(
        (e) => _events.add(RemoteMuted(e.participant.identity)),
      )
      ..on<RoomDisconnectedEvent>((_) => _events.add(const RoomDisconnected()));
    await _room.connect(url, token);
  }

  @override
  Future<void> publishMutedMic() async {
    final local = _room.localParticipant!;
    await local.setMicrophoneEnabled(true, audioCaptureOptions: _capture);
    await local.setMicrophoneEnabled(false, audioCaptureOptions: _capture);
  }

  @override
  Future<void> setMicMuted(bool muted) async {
    await _room.localParticipant?.setMicrophoneEnabled(
      !muted,
      audioCaptureOptions: _capture,
    );
  }

  @override
  Future<void> disconnect() async {
    await _listener?.dispose();
    _listener = null;
    await _room.disconnect();
    await _room.dispose();
    await _events.close();
  }
}
