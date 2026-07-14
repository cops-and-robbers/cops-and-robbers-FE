import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/models/game_area_model.dart';

part 'player_game_record.freezed.dart';

/// 게임 중 내(로컬 플레이어) 활동을 누적하는 휘발성 기록.
///
/// 백엔드에 저장하지 않으며, 다음 게임 시작 시 초기화된다.
/// 경로는 `LatLngModel`(data 모델)을 재사용한다(좌표 전용, 신규 모델 미생성).
@freezed
class PlayerGameRecord with _$PlayerGameRecord {
  const factory PlayerGameRecord({
    /// 누적 이동 경로 (2m 미만 이동은 노이즈로 제외)
    @Default(<LatLngModel>[]) List<LatLngModel> route,

    /// 누적 이동 거리(미터)
    @Default(0.0) double distanceMeters,

    /// 경찰: 내가 잡은 도둑 수 (STOMP 확정 기준)
    @Default(0) int myArrestCount,

    /// 도둑: 내가 탈옥한 횟수 (STOMP 확정 기준)
    @Default(0) int myEscapeCount,

    /// 경찰: 내가 도둑을 잡은 위치들 (체포 확정 순간의 내 위치)
    @Default(<LatLngModel>[]) List<LatLngModel> arrestLocations,

    /// 도둑: 내가 잡힌 위치들 (내가 체포 확정된 순간의 내 위치)
    @Default(<LatLngModel>[]) List<LatLngModel> caughtLocations,

    /// 게임 종료 시각 (날짜·시간 헤더용)
    DateTime? endedAt,
  }) = _PlayerGameRecord;
}
