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

  /// 경찰 팀 무전(#697) 중 화면이 꺼져도 마이크를 유지한다.
  ///
  /// Android는 위치와 분리된 microphone 타입 서비스를 띄운다 — 앱이 화면에 있고
  /// 마이크 권한을 받은 뒤에만 불러야 한다(백그라운드 시작은 Android 14+에서 거절).
  /// iOS는 `audio` 배경 모드로 OS가 처리해 할 일이 없다.
  Future<void> startRadio();

  Future<void> stopRadio();
}
