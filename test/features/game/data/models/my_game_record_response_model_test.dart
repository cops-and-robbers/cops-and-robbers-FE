import 'package:cops_and_robbers/features/game/data/models/my_game_record_response_model.dart';
import 'package:cops_and_robbers/features/game/domain/entities/my_game_record_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // docs/api-docs.json v2.36.0 GameResultParticipantResponse 예시 그대로
  const json = {
    'nickname': '살금살금고슴도치',
    'team': 'POLICE',
    'status': 'ALIVE',
    'arrestCount': 3,
    'arrestedCount': 2,
    'leftAt': '2026-09-16T14:30:00+09:00',
  };

  test(
    'parses_all_fields_and_drops_left_at_in_entity_when_given_swagger_example',
    () {
      final model = MyGameRecordResponseModel.fromJson(json);

      expect(
        model,
        const MyGameRecordResponseModel(
          nickname: '살금살금고슴도치',
          team: 'POLICE',
          status: 'ALIVE',
          arrestCount: 3,
          arrestedCount: 2,
          leftAt: '2026-09-16T14:30:00+09:00',
        ),
      );
      expect(
        model.toEntity(),
        const MyGameRecordEntity(
          nickname: '살금살금고슴도치',
          team: 'POLICE',
          status: 'ALIVE',
          arrestCount: 3,
          arrestedCount: 2,
        ),
      );
    },
  );
}
