import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'analytics_service.g.dart';

/// Analytics 서비스 Provider (앱 생애주기 동안 단일 인스턴스)
@Riverpod(keepAlive: true)
AnalyticsService analyticsService(Ref ref) {
  // Firebase 초기화 실패 시에도 앱은 구동되므로(main.dart fail-open 패턴)
  // 가용 여부를 확인해 null이면 전체 no-op으로 동작한다
  return AnalyticsService(
    analytics: Firebase.apps.isNotEmpty ? FirebaseAnalytics.instance : null,
  );
}

/// Firebase Analytics 래퍼
///
/// 모든 이벤트 기록은 fail-safe — Analytics 실패가 앱 흐름에 영향을 주지 않는다.
/// [analytics]가 null이면(Firebase 미초기화) 모든 메서드는 no-op.
class AnalyticsService {
  AnalyticsService({required FirebaseAnalytics? analytics})
    : _analytics = analytics;

  final FirebaseAnalytics? _analytics;

  Future<void> _log(String name, [Map<String, Object>? parameters]) async {
    try {
      await _analytics?.logEvent(name: name, parameters: parameters);
    } catch (e) {
      debugPrint('[Analytics] ⚠️ 이벤트 기록 실패 ($name): $e');
    }
  }

  /// 로그인 성공 (GA4 표준 이벤트) — [method]: 'google' | 'apple'
  Future<void> logLogin({required String method}) async {
    try {
      await _analytics?.logLogin(loginMethod: method);
    } catch (e) {
      debugPrint('[Analytics] ⚠️ 이벤트 기록 실패 (login): $e');
    }
  }

  /// 방 생성 완료
  Future<void> logGameCreate({
    required int participantLimit,
    required int roundMinutes,
  }) => _log('game_create', {
    'participant_limit': participantLimit,
    'round_minutes': roundMinutes,
  });

  /// 방 참가 성공 — [method]: 'code' | 'deeplink'
  Future<void> logGameJoin({required String method}) =>
      _log('game_join', {'method': method});

  /// 게임 시작 (GAME_START 수신)
  Future<void> logGameStart({
    required String team,
    required int participantCount,
  }) =>
      _log('game_start', {'team': team, 'participant_count': participantCount});

  /// 게임 종료 (GAME_OVER 수신)
  Future<void> logGameOver({
    required String result,
    required String team,
    required String reason,
    required int durationMinutes,
  }) => _log('game_over', {
    'result': result,
    'team': team,
    'reason': reason,
    'duration_minutes': durationMinutes,
  });

  /// 결과 다이얼로그 이탈 선택 — [choice]: 'home' | 'rematch'
  Future<void> logGameExitChoice({required String choice}) =>
      _log('game_exit_choice', {'choice': choice});

  /// 닉네임 변경 성공
  Future<void> logNicknameChange() => _log('nickname_change');

  /// 모집글 공유 버튼 탭
  Future<void> logCommunityPostShare() => _log('community_post_share');

  /// 딥링크로 모집글 상세 진입 — [entry]: 'cold' | 'warm' | 'pending'
  Future<void> logCommunityPostDeeplink({required String entry}) =>
      _log('community_post_deeplink', {'entry': entry});

  /// 인게임 튜토리얼 완료

  /// 전면 광고 표시 시도 결과 — [status]: 'shown' | 'not_loaded' | 'failed'
  Future<void> logAdInterstitialResult({required String status}) =>
      _log('ad_interstitial_result', {'status': status});
}
