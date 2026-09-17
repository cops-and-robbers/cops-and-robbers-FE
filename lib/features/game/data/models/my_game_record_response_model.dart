import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/my_game_record_entity.dart';

part 'my_game_record_response_model.freezed.dart';
part 'my_game_record_response_model.g.dart';

/// 내 개인 기록 조회 응답 DTO
///
/// `GET /api/game-results/{gameResultId}/me` 응답 (200, v2.36.0)
///
/// 경찰은 잡히지 않고 도둑은 체포하지 않으므로(서버 `validateArrest`) 반대편 카운트는
/// 항상 0으로 온다. 화면은 팀에 맞는 값만 골라 쓴다.
///
/// **응답 예시**:
/// ```json
/// {
///   "nickname": "살금살금고슴도치",
///   "team": "POLICE",
///   "status": "ALIVE",
///   "arrestCount": 3,
///   "arrestedCount": 2,
///   "leftAt": "2026-09-16T14:30:00+09:00"
/// }
/// ```
@freezed
class MyGameRecordResponseModel with _$MyGameRecordResponseModel {
  const factory MyGameRecordResponseModel({
    /// 게임 시작 시점 닉네임
    required String nickname,

    /// 팀 ("POLICE" | "ROBBER")
    required String team,

    /// 종료 시점 상태 ("WAITING" | "ALIVE" | "JAILED" | "POLICE_WAITING")
    required String status,

    /// 내가 체포한 횟수 (경찰 행만 증가)
    required int arrestCount,

    /// 내가 잡힌 횟수 (도둑 행만 증가)
    required int arrestedCount,

    /// 게임 중 퇴장한 시각. 끝까지 있었으면 null
    String? leftAt,
  }) = _MyGameRecordResponseModel;

  factory MyGameRecordResponseModel.fromJson(Map<String, dynamic> json) =>
      _$MyGameRecordResponseModelFromJson(json);
}

/// DTO → Entity. 화면이 안 쓰는 `leftAt`은 여기서 떨어진다
/// (퇴장자는 결과 다이얼로그를 보지 않아 항상 null이다).
extension MyGameRecordResponseModelX on MyGameRecordResponseModel {
  MyGameRecordEntity toEntity() => MyGameRecordEntity(
    nickname: nickname,
    // 화면은 team을 안 쓰고 widget.myTeam으로 팀을 가르지만, 서버 응답이
    // myTeam과 일치하는지 계약 확인·디버깅용으로 Entity에 남겨 둔다.
    team: team,
    status: status,
    arrestCount: arrestCount,
    arrestedCount: arrestedCount,
  );
}
