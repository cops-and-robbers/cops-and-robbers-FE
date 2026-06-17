import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cops_and_robbers/core/services/ads/ad_service.dart';

/// LoadedInterstitial fake — 닫힘 시점을 테스트가 제어한다
class _FakeLoadedInterstitial implements LoadedInterstitial {
  _FakeLoadedInterstitial({this.throwOnShow = false});

  final bool throwOnShow;
  VoidCallback? capturedOnComplete;
  int showCallCount = 0;

  @override
  void show({required VoidCallback onComplete}) {
    showCallCount++;
    if (throwOnShow) throw StateError('show failed');
    capturedOnComplete = onComplete;
  }
}

void main() {
  group('AdService', () {
    test('preload_skips_loader_when_ads_disabled', () async {
      var loaderCalls = 0;
      final service = AdService(
        isAdsEnabled: () => false,
        sdkInitializer: () async => true,
        loader: (_) async {
          loaderCalls++;
          return _FakeLoadedInterstitial();
        },
      );
      await service.initialize();

      await service.preloadGameEndInterstitial();

      expect(loaderCalls, 0);
    });

    test('preload_skips_loader_when_sdk_init_failed', () async {
      var loaderCalls = 0;
      final service = AdService(
        isAdsEnabled: () => true,
        sdkInitializer: () async => false,
        loader: (_) async {
          loaderCalls++;
          return _FakeLoadedInterstitial();
        },
      );
      await service.initialize();

      await service.preloadGameEndInterstitial();

      expect(loaderCalls, 0);
    });

    test('show_completes_immediately_with_not_loaded_when_no_ad', () {
      final service = AdService(
        isAdsEnabled: () => true,
        sdkInitializer: () async => true,
        loader: (_) async => null,
      );

      var completed = false;
      final result = service.showGameEndInterstitial(
        onComplete: () => completed = true,
      );

      // fail-open: 광고 없으면 즉시 통과
      expect(result, AdShowResult.notLoaded);
      expect(completed, isTrue);
    });

    test('show_displays_ad_then_completes_when_dismissed', () async {
      final fakeAd = _FakeLoadedInterstitial();
      final service = AdService(
        isAdsEnabled: () => true,
        sdkInitializer: () async => true,
        loader: (_) async => fakeAd,
      );
      await service.initialize();
      await service.preloadGameEndInterstitial();

      var completed = false;
      final result = service.showGameEndInterstitial(
        onComplete: () => completed = true,
      );

      expect(result, AdShowResult.shown);
      expect(fakeAd.showCallCount, 1);
      expect(completed, isFalse); // 광고가 아직 닫히지 않음

      fakeAd.capturedOnComplete!(); // 광고 닫힘 시뮬레이션
      expect(completed, isTrue);
    });

    test(
      'show_consumes_ad_so_second_show_falls_back_when_called_twice',
      () async {
        final service = AdService(
          isAdsEnabled: () => true,
          sdkInitializer: () async => true,
          loader: (_) async => _FakeLoadedInterstitial(),
        );
        await service.initialize();
        await service.preloadGameEndInterstitial();

        final first = service.showGameEndInterstitial(onComplete: () {});
        final second = service.showGameEndInterstitial(onComplete: () {});

        expect(first, AdShowResult.shown);
        expect(second, AdShowResult.notLoaded); // 1회 소비됨
      },
    );

    test('show_returns_failed_and_completes_when_ad_show_throws', () async {
      final service = AdService(
        isAdsEnabled: () => true,
        sdkInitializer: () async => true,
        loader: (_) async => _FakeLoadedInterstitial(throwOnShow: true),
      );
      await service.initialize();
      await service.preloadGameEndInterstitial();

      var completed = false;
      final result = service.showGameEndInterstitial(
        onComplete: () => completed = true,
      );

      expect(result, AdShowResult.failed);
      expect(completed, isTrue); // fail-open
    });

    test('show_skips_loaded_ad_when_kill_switch_disabled_after_load', () async {
      var adsEnabled = true; // 로드 시점엔 켜짐
      final fakeAd = _FakeLoadedInterstitial();
      final service = AdService(
        isAdsEnabled: () => adsEnabled,
        sdkInitializer: () async => true,
        loader: (_) async => fakeAd,
      );
      await service.initialize();
      await service.preloadGameEndInterstitial(); // 광고 로드됨

      adsEnabled = false; // 표시 직전 킬 스위치 OFF

      var completed = false;
      final result = service.showGameEndInterstitial(
        onComplete: () => completed = true,
      );

      // 이미 로드된 광고라도 노출하지 않고 즉시 통과 (킬 스위치 방어)
      expect(result, AdShowResult.notLoaded);
      expect(fakeAd.showCallCount, 0);
      expect(completed, isTrue);
    });

    test('preload_loads_only_once_when_ad_already_cached', () async {
      var loaderCalls = 0;
      final service = AdService(
        isAdsEnabled: () => true,
        sdkInitializer: () async => true,
        loader: (_) async {
          loaderCalls++;
          return _FakeLoadedInterstitial();
        },
      );
      await service.initialize();

      await service.preloadGameEndInterstitial();
      await service.preloadGameEndInterstitial(); // 이미 로드됨 → 스킵

      expect(loaderCalls, 1);
    });

    test('preload_retries_with_backoff_when_no_fill', () async {
      var loaderCalls = 0;
      final service = AdService(
        isAdsEnabled: () => true,
        sdkInitializer: () async => true,
        retryBaseDelay: Duration.zero, // 테스트에서 실제 대기 제거
        loader: (_) async {
          loaderCalls++;
          // 2회 no-fill 후 3번째 성공 (일시적 "No ad to show" 회복 시나리오)
          return loaderCalls < 3 ? null : _FakeLoadedInterstitial();
        },
      );
      await service.initialize();

      await service.preloadGameEndInterstitial();

      expect(loaderCalls, 3);
      expect(
        service.showGameEndInterstitial(onComplete: () {}),
        AdShowResult.shown,
      );
    });

    test('preload_gives_up_after_max_attempts_when_always_no_fill', () async {
      var loaderCalls = 0;
      final service = AdService(
        isAdsEnabled: () => true,
        sdkInitializer: () async => true,
        retryBaseDelay: Duration.zero,
        loader: (_) async {
          loaderCalls++;
          return null;
        },
      );
      await service.initialize();

      await service.preloadGameEndInterstitial();

      expect(loaderCalls, 3); // 첫 시도 + 재시도 2회에서 멈춤

      // 끝내 실패해도 fail-open — 이탈 흐름은 즉시 진행
      var completed = false;
      expect(
        service.showGameEndInterstitial(onComplete: () => completed = true),
        AdShowResult.notLoaded,
      );
      expect(completed, isTrue);
    });
  });
}
