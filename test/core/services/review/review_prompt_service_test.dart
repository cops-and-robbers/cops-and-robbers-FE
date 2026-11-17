import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cops_and_robbers/core/services/review/review_prompt_service.dart';

void main() {
  // 스토어 리뷰 창은 시스템 경계 — 호출 횟수만 세는 fake로 대체한다.
  late int storeDialogRequests;
  late DateTime today;
  var nextResultId = 0;

  /// 새 판 하나가 끝난 상황 — 판마다 서버가 다른 결과 id를 준다
  Future<bool> finishGame(ReviewPromptService service, {required bool isWin}) =>
      service.recordFinishedGame(gameResultId: ++nextResultId, isWin: isWin);

  ReviewPromptService buildService() => ReviewPromptService(
    requestStoreReview: () async => storeDialogRequests++,
    now: () => today,
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    storeDialogRequests = 0;
    today = DateTime(2026, 11, 17, 21);
  });

  group('ReviewPromptService', () {
    test('is_not_due_when_first_game_is_won', () async {
      // 앱을 깔고 처음 한 판을 이긴 사람 — 아직 "충분히 써 본" 상태가 아니다
      final service = buildService();

      final due = await finishGame(service, isWin: true);

      expect(due, isFalse);
    });

    test('is_due_when_second_game_is_won', () async {
      // 첫 판은 지고, 같은 방에서 "한 번 더" 한 두 번째 판을 이긴 사람
      final service = buildService();
      await finishGame(service, isWin: false);

      final due = await finishGame(service, isWin: true);

      expect(due, isTrue);
    });

    test('is_not_due_when_game_is_lost', () async {
      // 여러 판을 했지만 방금 판은 진 사람 — 진 직후에는 묻지 않는다
      final service = buildService();
      await finishGame(service, isWin: true);
      await finishGame(service, isWin: true);

      final due = await finishGame(service, isWin: false);

      expect(due, isFalse);
    });

    test('is_not_due_when_asked_119_days_ago', () async {
      // 여름 행사 때 리뷰 창을 본 사람이 119일 뒤 다시 이긴 경우
      final service = buildService();
      await finishGame(service, isWin: true);
      await finishGame(service, isWin: true);
      await service.requestReview();
      today = today.add(const Duration(days: 119));

      final due = await finishGame(service, isWin: true);

      expect(due, isFalse);
    });

    test('is_due_again_when_asked_120_days_ago', () async {
      final service = buildService();
      await finishGame(service, isWin: true);
      await finishGame(service, isWin: true);
      await service.requestReview();
      today = today.add(const Duration(days: 120));

      final due = await finishGame(service, isWin: true);

      expect(due, isTrue);
    });

    test('stays_due_on_next_win_when_app_was_closed_before_request', () async {
      // 결과 화면에서 버튼을 누르지 않고 앱을 끈 사람 — 요청이 나가지 않았으니
      // 다음에 이긴 판에서 다시 대상이 된다
      final service = buildService();
      await finishGame(service, isWin: true);
      final dueBeforeClose = await finishGame(service, isWin: true);

      final relaunched = buildService();
      final dueAfterRelaunch = await finishGame(relaunched, isWin: true);

      expect([dueBeforeClose, dueAfterRelaunch], [true, true]);
    });

    test('counts_game_once_when_same_result_is_reported_twice', () async {
      // 결과 화면이 뜬 뒤 재접속 등으로 같은 판의 종료가 한 번 더 들어온 경우 —
      // 첫 판을 이긴 사람이 두 판을 한 것으로 세어지면 안 된다
      final service = buildService();
      await service.recordFinishedGame(gameResultId: 501, isWin: true);

      final due = await service.recordFinishedGame(
        gameResultId: 501,
        isWin: true,
      );

      expect(due, isFalse);
    });

    test('is_due_when_last_request_is_in_the_future', () async {
      // 기기 시계를 앞으로 돌려 둔 채 리뷰 창을 본 뒤 시계를 바로잡은 사람 —
      // 저장된 시각이 미래라서 영영 대상에서 빠지면 안 된다
      final service = buildService();
      today = DateTime(2030, 1, 1);
      await finishGame(service, isWin: true);
      await finishGame(service, isWin: true);
      await service.requestReview();
      today = DateTime(2026, 11, 17, 21);

      final due = await finishGame(service, isWin: true);

      expect(due, isTrue);
    });

    test('opens_store_dialog_once_per_request', () async {
      final service = buildService();

      await service.requestReview();

      expect(storeDialogRequests, 1);
    });

    test('keeps_interval_when_store_dialog_fails', () async {
      // Play 스토어가 없는 기기 등 — 실패해도 흐름을 막지 않고, 매 판 다시 시도하지도 않는다
      final service = ReviewPromptService(
        requestStoreReview: () async => throw StateError('no store'),
        now: () => today,
      );
      await finishGame(service, isWin: true);
      await finishGame(service, isWin: true);

      await service.requestReview();
      final due = await finishGame(service, isWin: true);

      expect(due, isFalse);
    });
  });
}
