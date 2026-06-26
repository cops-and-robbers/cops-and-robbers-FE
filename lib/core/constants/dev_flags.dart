/// 개발 전용 플래그 모음.
///
/// 이벤트 게임 모드를 백엔드 응답 없이 강제 활성화한다(디버그 검증용).
/// 사용: `flutter run --dart-define=EVENT_GAME_DEV=true`
/// 실서비스 빌드에서는 미지정 → false 라 영향 없음.
const bool kEventGameDevOverride = bool.fromEnvironment('EVENT_GAME_DEV');
