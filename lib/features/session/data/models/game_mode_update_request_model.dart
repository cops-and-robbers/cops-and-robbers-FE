import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/constants/game_mode.dart';
import 'game_create_request_model.dart';

part 'game_mode_update_request_model.freezed.dart';
part 'game_mode_update_request_model.g.dart';

/// 대기실 모드 변경 요청 DTO
///
/// `PUT /api/games/{gameId}/mode` 요청 본문. 모드에 맞는 구역 전체를 함께 보낸다
/// (술래잡기는 감옥 키 생략, `PUT /area`와 같은 [GameAreaRequestModel]).
@freezed
class GameModeUpdateRequestModel with _$GameModeUpdateRequestModel {
  const factory GameModeUpdateRequestModel({
    @JsonKey(fromJson: GameMode.fromJson, toJson: gameModeToJson)
    required GameMode gameMode,
    required GameAreaRequestModel area,
  }) = _GameModeUpdateRequestModel;

  factory GameModeUpdateRequestModel.fromJson(Map<String, dynamic> json) =>
      _$GameModeUpdateRequestModelFromJson(json);
}
