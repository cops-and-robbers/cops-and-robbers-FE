import 'lock_screen_status.dart';

/// 게임 진행 중 백그라운드 위치 추적/STOMP 유지, 잠금 화면 현황, 무전 마이크 유지를 맡는 native 인프라 추상화
///
/// 역할:
/// - Android: Foreground Service start/stop (영구 알림) + 알림 내용 갱신(Live Update),
///   무전용 microphone 서비스는 위치 서비스와 따로 start/stop
/// - iOS: 백그라운드 위치는 OS가 처리(UIBackgroundModes=location). 잠금 화면 현황만 Live Activity로
///
/// 멱등성: start()는 이미 실행 중이면 no-op. stop()도 마찬가지.
abstract class BackgroundService {
  /// 백그라운드 service 시작
  ///
  /// [gameId] iOS에서 재실행 전 Live Activity와 현재 게임을 대조하는 식별자.
  Future<void> start({required int gameId});

  /// 잠금 화면 현황 갱신. 시작 전에 불려도 버리지 않고 시작 직후 보낸다.
  Future<void> update(LockScreenStatus status);

  /// 백그라운드 service 종료
  Future<void> stop();

  /// 현재 실행 중인지
  bool get isRunning;

  /// 경찰 팀 무전(#697) 중 화면이 꺼져도 마이크를 유지한다. 앱이 화면에 있고 마이크 권한을
  /// 받은 뒤에만 부른다 — Android 14+는 백그라운드 시작을 거절한다. iOS는 `audio` 배경 모드가 맡는다.
  Future<void> startRadio();

  Future<void> stopRadio();
}
