import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../remote_config/remote_config_service.dart';
import 'ad_unit_ids.dart';

part 'ad_service.g.dart';

/// 로드된 전면 광고 1건의 경계 인터페이스 — google_mobile_ads SDK 경계.
/// 테스트에서는 fake 구현으로 대체한다.
abstract class LoadedInterstitial {
  /// 광고를 표시한다. 닫히거나 표시에 실패하면 [onComplete]를 정확히 1회 호출한다.
  void show({required VoidCallback onComplete});
}

/// 전면 광고 로더 시그니처 — 로드 실패 시 null 반환 (throw 금지)
typedef InterstitialLoader =
    Future<LoadedInterstitial?> Function(String adUnitId);

/// SDK 초기화 함수 시그니처 — 성공 여부 반환 (throw 금지)
typedef SdkInitializer = Future<bool> Function();

/// 전면 광고 표시 시도 결과 — Analytics `ad_interstitial_result.status` 값
enum AdShowResult {
  shown('shown'),
  notLoaded('not_loaded'),
  failed('failed');

  const AdShowResult(this.analyticsValue);

  final String analyticsValue;
}

/// 광고 서비스 Provider (앱 생애주기 동안 단일 인스턴스 — 로드된 광고 보관)
@Riverpod(keepAlive: true)
AdService adService(Ref ref) {
  return AdService(isAdsEnabled: () => RemoteConfigService.instance.adsEnabled);
}

/// AdMob 전면 광고 서비스
///
/// 원칙 (fail-open): 광고는 게임 이탈 흐름을 절대 막지 않는다.
/// 초기화/로드/표시 어느 단계가 실패해도 호출자 흐름은 그대로 진행된다.
class AdService {
  AdService({
    required bool Function() isAdsEnabled,
    InterstitialLoader? loader,
    SdkInitializer? sdkInitializer,
  }) : _isAdsEnabled = isAdsEnabled,
       _loader = loader ?? _loadGmaInterstitial,
       _sdkInitializer = sdkInitializer ?? _initializeGmaSdk;

  final bool Function() _isAdsEnabled;
  final InterstitialLoader _loader;
  final SdkInitializer _sdkInitializer;

  bool _sdkInitialized = false;
  bool _isLoading = false;
  LoadedInterstitial? _gameEndAd;

  /// UMP 동의 플로우 → Mobile Ads SDK 초기화.
  /// 동의 폼 표시가 가능하도록 첫 프레임 이후(스플래시)에 호출해야 한다.
  Future<void> initialize() async {
    if (_sdkInitialized) return;
    _sdkInitialized = await _sdkInitializer();
  }

  /// 게임 종료 전면 광고 사전 로드 (GAME_OVER 수신 시점에 호출)
  ///
  /// 게이팅: SDK 초기화 완료 + Remote Config ads_enabled + 미로드 상태일 때만.
  Future<void> preloadGameEndInterstitial() async {
    if (!_sdkInitialized || _isLoading || _gameEndAd != null) return;
    if (!_isAdsEnabled()) return;

    _isLoading = true;
    try {
      _gameEndAd = await _loader(AdUnitIds.gameEndInterstitial);
      if (_gameEndAd != null) {
        debugPrint('[AdService] ✅ 게임 종료 전면 광고 로드 완료');
      }
    } catch (e) {
      // 로더는 null 반환 계약이지만, 예외가 새어 나와도 흐름을 막지 않는다
      debugPrint('[AdService] ⚠️ 전면 광고 로드 예외: $e');
      _gameEndAd = null;
    } finally {
      _isLoading = false;
    }
  }

  /// 로드된 전면 광고를 표시하고 닫히면 [onComplete] 호출.
  /// 광고가 없으면 [onComplete]를 즉시 호출한다 (fail-open).
  ///
  /// 광고는 1회 소비된다 — 같은 로드로 두 번 표시되지 않는다.
  AdShowResult showGameEndInterstitial({required VoidCallback onComplete}) {
    final ad = _gameEndAd;
    _gameEndAd = null;

    if (ad == null) {
      onComplete();
      return AdShowResult.notLoaded;
    }

    try {
      ad.show(onComplete: onComplete);
      return AdShowResult.shown;
    } catch (e) {
      debugPrint('[AdService] ⚠️ 전면 광고 표시 실패: $e');
      onComplete();
      return AdShowResult.failed;
    }
  }
}

// ============================================================
// google_mobile_ads 실제 구현 (시스템 경계 — 단위 테스트 대상 아님)
// ============================================================

/// UMP 동의 수집 → Mobile Ads SDK 초기화
Future<bool> _initializeGmaSdk() async {
  try {
    await _gatherConsent();

    // 동의 거부(EEA) 시 광고 요청 불가 — SDK 초기화 생략
    if (!await ConsentInformation.instance.canRequestAds()) {
      debugPrint('[AdService] ⚠️ 광고 요청 불가 상태 (동의 미완료)');
      return false;
    }

    await MobileAds.instance.initialize();
    debugPrint('[AdService] ✅ Mobile Ads SDK 초기화 완료');
    return true;
  } catch (e) {
    debugPrint('[AdService] ❌ SDK 초기화 실패 (광고 없이 진행): $e');
    return false;
  }
}

/// UMP 동의 플로우 — EEA 사용자에게만 동의 폼이 표시된다 (그 외 지역 즉시 통과)
Future<void> _gatherConsent() {
  final completer = Completer<void>();
  ConsentInformation.instance.requestConsentInfoUpdate(
    ConsentRequestParameters(),
    () {
      ConsentForm.loadAndShowConsentFormIfRequired((FormError? error) {
        if (error != null) {
          debugPrint('[AdService] ⚠️ 동의 폼 오류: ${error.message}');
        }
        completer.complete();
      });
    },
    (FormError error) {
      debugPrint('[AdService] ⚠️ 동의 정보 갱신 실패: ${error.message}');
      completer.complete();
    },
  );
  return completer.future;
}

/// google_mobile_ads 전면 광고 로더 (기본 구현)
Future<LoadedInterstitial?> _loadGmaInterstitial(String adUnitId) {
  final completer = Completer<LoadedInterstitial?>();
  InterstitialAd.load(
    adUnitId: adUnitId,
    request: const AdRequest(),
    adLoadCallback: InterstitialAdLoadCallback(
      onAdLoaded: (ad) => completer.complete(_GmaLoadedInterstitial(ad)),
      onAdFailedToLoad: (error) {
        debugPrint('[AdService] ⚠️ 전면 광고 로드 실패: ${error.message}');
        completer.complete(null);
      },
    ),
  );
  return completer.future;
}

/// InterstitialAd를 LoadedInterstitial 계약으로 감싼 구현
class _GmaLoadedInterstitial implements LoadedInterstitial {
  _GmaLoadedInterstitial(this._ad);

  final InterstitialAd _ad;

  @override
  void show({required VoidCallback onComplete}) {
    // SDK 콜백이 중복 호출되더라도 onComplete(=라우팅)는 정확히 1회만
    var completed = false;
    void completeOnce() {
      if (completed) return;
      completed = true;
      onComplete();
    }

    _ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        completeOnce();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('[AdService] ⚠️ 전면 광고 표시 실패: ${error.message}');
        ad.dispose();
        completeOnce();
      },
    );
    _ad.show();
  }
}
