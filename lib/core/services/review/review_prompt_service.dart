import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 스토어 기본 리뷰 창을 띄우는 함수 — in_app_review SDK 경계.
/// 테스트에서는 fake로 대체한다.
typedef StoreReviewRequester = Future<void> Function();

/// 리뷰 요청 서비스 Provider
final reviewPromptServiceProvider = Provider<ReviewPromptService>(
  (ref) => ReviewPromptService(),
);

/// 게임이 끝난 뒤 스토어 리뷰 창을 띄울지 정하고 띄운다 (FE #706).
///
/// 기기 기준으로 센다 — 스토어 리뷰는 계정이 아니라 스토어 계정·기기에 묶인다.
/// 창이 실제로 떴는지, 리뷰를 남겼는지는 두 스토어 모두 알려 주지 않는다.
class ReviewPromptService {
  ReviewPromptService({
    StoreReviewRequester? requestStoreReview,
    DateTime Function()? now,
  }) : _requestStoreReview = requestStoreReview ?? _requestInAppReview,
       _now = now ?? DateTime.now;

  /// 이 판 수부터 요청한다. 공식 문서에 숫자는 없다 — Google의 "충분히 써 본 뒤"와
  /// 두 번째 실행부터 띄운 사례에서 유추한 값이라 출시 뒤 조정할 수 있다.
  static const int minFinishedGames = 2;

  /// 요청 사이 간격. Apple이 365일에 3번까지만 창을 띄우므로 365 ÷ 3 ≈ 122일.
  /// 더 자주 부르면 창은 안 뜨는데 그 판의 광고만 건너뛰게 된다.
  static const Duration minInterval = Duration(days: 120);

  static const _finishedGamesKey = 'review_prompt_finished_games';
  static const _lastRequestedAtKey = 'review_prompt_last_requested_at';
  static const _lastCountedResultIdKey = 'review_prompt_last_counted_result_id';

  final StoreReviewRequester _requestStoreReview;
  final DateTime Function() _now;

  /// 정상 종료한 판을 하나 세고, 이 판에서 리뷰를 요청할지 돌려준다.
  ///
  /// 결과 화면이 뜰 때 부른다 — 버튼을 누르지 않고 앱을 꺼도 판 수는 남는다.
  /// 같은 [gameResultId]가 다시 들어오면 판 수를 올리지 않는다 — 재접속 등으로
  /// 같은 판의 종료가 두 번 처리돼도 한 판은 한 번만 센다.
  Future<bool> recordFinishedGame({
    required int gameResultId,
    required bool isWin,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    var finishedGames = prefs.getInt(_finishedGamesKey) ?? 0;
    if (prefs.getInt(_lastCountedResultIdKey) != gameResultId) {
      finishedGames++;
      await prefs.setInt(_finishedGamesKey, finishedGames);
      await prefs.setInt(_lastCountedResultIdKey, gameResultId);
    }

    // 진 직후에는 묻지 않는다 — 낮은 점수가 몰린다
    if (!isWin || finishedGames < minFinishedGames) return false;

    final lastRequestedAt = prefs.getInt(_lastRequestedAtKey);
    if (lastRequestedAt == null) return true;
    final elapsed = _now().difference(
      DateTime.fromMillisecondsSinceEpoch(lastRequestedAt),
    );
    // 저장된 시각이 미래면 기기 시계가 틀렸던 것 — 영영 막히지 않게 대상으로 본다.
    // 실제 노출 횟수는 스토어가 따로 막는다.
    return elapsed.isNegative || elapsed >= minInterval;
  }

  /// 스토어 리뷰 창을 요청한다. 실패해도 호출자 흐름을 막지 않는다 (fail-open).
  Future<void> requestReview() async {
    try {
      // 요청 시각을 먼저 남긴다 — 창이 실패해도 매 판 다시 시도하지 않게
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastRequestedAtKey, _now().millisecondsSinceEpoch);

      await _requestStoreReview();
    } catch (e) {
      debugPrint('[ReviewPromptService] ⚠️ 리뷰 창 요청 실패(무시): $e');
    }
  }
}

/// in_app_review 실제 구현 (시스템 경계 — 단위 테스트 대상 아님)
Future<void> _requestInAppReview() async {
  final inAppReview = InAppReview.instance;
  if (await inAppReview.isAvailable()) {
    await inAppReview.requestReview();
  }
}
