/// 재연결 모달과 구역 이탈 팝업의 상호작용 정책을 판정하는 순수 함수.
///
/// 게임 화면은 세 가지 UI/도메인 상태(이탈 팝업 표시 여부, 재연결 모달 표시 여부,
/// ZoneExitDetector 의 `isOutside`)를 조합해 팝업 복구 흐름을 운영한다.
/// 이 파일은 그 중 "재연결 모달 진입 시점에 팝업 복구 예약이 필요한가"를 결정하는
/// 최소 단위의 Presentation 정책을 담는다.
///
/// 이 함수를 `zone_exit_detector.dart` (Domain) 에 두지 않는 이유:
/// 입력 파라미터 `isPopupShown` 이 UI 상태이기 때문.
/// Domain 파일은 순수 도메인 개념만 담는다는 Clean Architecture 원칙을 유지하기 위해
/// Presentation 계층 하위의 helper 로 분리한다.
library;

/// 재연결 모달 진입 시점에 구역 이탈 팝업 복구 예약이 필요한지 판단.
///
/// `ZoneExitDetector` 는 상태 전환(안↔밖)에서만 콜백을 발화하므로,
/// 재연결 모달이 이탈 팝업을 강제로 닫은 뒤 위치 스트림이 다시 돌아와도
/// 자동으로 이탈 콜백이 울리지 않는다. 이 함수는 그 간극을 메우기 위해
/// 재연결 모달 진입 시점에 "복구 예약(pending)" 이 필요한지 판정한다.
///
/// - [isPopupShown]: 이탈 팝업이 현재 표시 중인가 (UI 상태).
/// - [isDetectorOutside]: `ZoneExitDetector` 의 현재 `isOutside` 값 (도메인 상태).
///
/// 둘 중 하나라도 `true` 이면 재연결 모달이 닫힌 뒤 팝업 복구가 필요하다.
bool shouldMarkZoneExitAsPendingOnReconnect({
  required bool isPopupShown,
  required bool isDetectorOutside,
}) {
  return isPopupShown || isDetectorOutside;
}
