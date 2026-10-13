import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_result_entity.freezed.dart';

/// 게임 결과 Entity
///
/// 게임 종료 API 응답을 Domain Layer에서 사용하는 순수 엔티티로 표현합니다.
/// Presentation Layer는 이 엔티티만 참조합니다.
/// DTO → Entity 변환은 `GameResultResponseModel.toEntity()`에서 수행합니다.
@freezed
class GameResultEntity with _$GameResultEntity {
  const factory GameResultEntity({
    /// 승리 팀 ("POLICE" | "ROBBER")
    required String winnerTeam,

    /// 게임 진행 시간(초)
    required int durationSeconds,

    /// 총 체포 횟수
    required int totalArrestCount,

    /// 남은 도둑 수
    required int remainingRobberCount,

    /// 경찰·도둑 팀 MVP 닉네임 — 없으면 null (MVP 공개 화면은 null 팀을 건너뛴다)
    String? policeMvpNickname,
    String? robberMvpNickname,
  }) = _GameResultEntity;
}
