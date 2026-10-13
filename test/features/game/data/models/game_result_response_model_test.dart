import 'package:cops_and_robbers/features/game/data/models/game_result_response_model.dart';
import 'package:cops_and_robbers/features/game/domain/entities/game_result_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const base = {
    'winnerTeam': 'POLICE',
    'durationSeconds': 1800,
    'totalArrestCount': 12,
    'remainingRobberCount': 0,
  };

  test('maps_team_mvp_nicknames_to_entity_when_both_present', () {
    final model = GameResultResponseModel.fromJson({
      ...base,
      'policeMvp': {'nickname': '번개경찰'},
      'robberMvp': {'nickname': '그림자'},
    });

    expect(
      model.toEntity(),
      const GameResultEntity(
        winnerTeam: 'POLICE',
        durationSeconds: 1800,
        totalArrestCount: 12,
        remainingRobberCount: 0,
        policeMvpNickname: '번개경찰',
        robberMvpNickname: '그림자',
      ),
    );
  });

  // 도둑이 전원 중도 퇴장해 후보가 없으면 서버는 그 팀만 null로 준다.
  test('keeps_police_mvp_and_drops_robber_mvp_when_every_robber_left', () {
    final model = GameResultResponseModel.fromJson({
      ...base,
      'policeMvp': {'nickname': '번개경찰'},
      'robberMvp': null,
    });

    expect(model.toEntity().policeMvpNickname, '번개경찰');
    expect(model.toEntity().robberMvpNickname, isNull);
  });

  // 앱이 BE #212보다 먼저 배포되면 서버는 두 필드를 아예 내려주지 않는다.
  test('parses_without_mvp_when_server_predates_mvp_fields', () {
    final model = GameResultResponseModel.fromJson(base);

    expect(
      model.toEntity(),
      const GameResultEntity(
        winnerTeam: 'POLICE',
        durationSeconds: 1800,
        totalArrestCount: 12,
        remainingRobberCount: 0,
      ),
    );
  });
}
