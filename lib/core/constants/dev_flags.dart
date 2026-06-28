import 'package:flutter/foundation.dart';

/// 개발 전용 플래그 모음.
///
/// 이벤트 게임 모드를 백엔드 응답 없이 강제 활성화한다(디버그 검증용).
/// 사용: `flutter run --dart-define=EVENT_GAME_DEV=true`
/// 디버그 빌드 전용 — kDebugMode로 게이팅해 릴리스/프로파일에서는 define이 섞여도
/// 항상 false. (이 플래그는 일반 게임 조인의 로비 스킵 동선까지 바꾸므로,
/// 배포 파이프라인 사고 방지를 위해 빌드 타입에서부터 차단한다.)
const bool kEventGameDevOverride =
    kDebugMode && bool.fromEnvironment('EVENT_GAME_DEV');
