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

  test('carries_is_mvp_into_entity_when_response_marks_me_mvp', () {
    final model = MyGameRecordResponseModel.fromJson({...json, 'isMvp': true});

    expect(model.toEntity().isMvp, isTrue);
  });

  // BE #212 이전 서버는 isMvp를 내려주지 않는다 — 파싱이 깨지면 개인 탭 전체가 '-'가 된다.
  test('treats_me_as_not_mvp_when_older_server_omits_is_mvp', () {
    final model = MyGameRecordResponseModel.fromJson(json);

    expect(model.toEntity().isMvp, isFalse);
  });
}
