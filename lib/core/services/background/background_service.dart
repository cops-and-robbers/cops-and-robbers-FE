import 'lock_screen_status.dart';

/// 게임 진행 중 백그라운드 위치 추적/STOMP 유지와 잠금 화면 현황을 맡는 native 인프라 추상화
///
/// 역할:
/// - Android: Foreground Service start/stop (영구 알림) + 알림 내용 갱신(Live Update)
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
}
