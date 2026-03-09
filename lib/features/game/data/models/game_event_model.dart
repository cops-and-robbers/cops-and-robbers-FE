import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_event_model.freezed.dart';
part 'game_event_model.g.dart';

/// 게임 이벤트 타입
@JsonEnum()
enum GameEventType {
  @JsonValue('ARREST')
  arrest,
  @JsonValue('ESCAPE')
  escape,
  @JsonValue('GAME_OVER')
  gameOver,
  @JsonValue('START')
  start,
  @JsonValue('POLICE_MOVE_START')
  policeMoveStart,
  @JsonValue('LOCATION_REVEAL')
  locationReveal,
  @JsonValue('ROBBER_LOCATION_REVEAL')
  robberLocationReveal,
  @JsonValue('UNKNOWN')
  unknown,
}

/// 게임 시스템 이벤트 DTO
///
/// `/subscribe/game/{gameId}/system` STOMP 채널에서 수신하는 이벤트.
/// [data] 필드는 이벤트 타입별로 구조가 다릅니다.
@freezed
class GameEventModel with _$GameEventModel {
  const factory GameEventModel({
    @Default('') String eventId,
    @JsonKey(unknownEnumValue: GameEventType.unknown)
    required GameEventType type,
    @Default('') String timestamp,
    @Default({}) Map<String, dynamic> data,
  }) = _GameEventModel;

  factory GameEventModel.fromJson(Map<String, dynamic> json) =>
      _$GameEventModelFromJson(json);
}
