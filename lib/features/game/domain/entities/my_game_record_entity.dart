import 'package:freezed_annotation/freezed_annotation.dart';

part 'my_game_record_entity.freezed.dart';

/// 내 개인 기록 Entity — 결과 다이얼로그 「개인」 탭이 읽는 값만 담는다.
@freezed
class MyGameRecordEntity with _$MyGameRecordEntity {
  const factory MyGameRecordEntity({
    /// 게임 시작 시점 닉네임 (개인 탭 1행)
    required String nickname,

    /// 팀 ("POLICE" | "ROBBER")
    required String team,

    /// 종료 시점 상태 ("ALIVE" | "JAILED" 등)
    required String status,

    /// 내가 체포한 횟수
    required int arrestCount,

    /// 내가 잡힌 횟수
    required int arrestedCount,
  }) = _MyGameRecordEntity;
}
