import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/services/ads/ad_service.dart';
import '../../../../core/services/ads/ad_unit_ids.dart';
import '../../../../l10n/app_localizations.dart';

/// 슬롯별 광고를 소유한다. OFF·미로드·실패 시 여백도 남기지 않는다.
class CommunityNativeAd extends ConsumerWidget {
  const CommunityNativeAd({super.key, this.margin = EdgeInsets.zero});

  final EdgeInsets margin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!(ref.watch(adsEnabledProvider).valueOrNull ?? false)) {
      return const SizedBox.shrink();
    }
    return LayoutBuilder(
      builder: (context, constraints) => _NativeAdCard(
        key: ValueKey((
          Localizations.localeOf(context),
          MediaQuery.textScalerOf(context),
          constraints.maxWidth - margin.horizontal,
        )),
        service: ref.read(adServiceProvider),
        margin: margin,
        width: constraints.maxWidth - margin.horizontal,
      ),
    );
  }
}

class _NativeAdCard extends StatefulWidget {
  const _NativeAdCard({
    super.key,
    required this.service,
    required this.margin,
    required this.width,
  });

  final AdService service;
  final EdgeInsets margin;
  final double width;

  @override
  State<_NativeAdCard> createState() => _NativeAdCardState();
}

class _NativeAdCardState extends State<_NativeAdCard> {
  NativeAd? _ad;
  bool _started = false;
  bool _loaded = false;
  late double _height;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final scaler = MediaQuery.textScalerOf(context);
    final headlineSize = scaler.scale(AppTextStyles.label_16.fontSize!);
    final bodySize = scaler.scale(AppTextStyles.tag_12.fontSize!);
    final captionSize = scaler.scale(AppTextStyles.tag_10.fontSize!);
    // MediaView는 동영상 최소 크기인 120×120을 보장한다.
    // 위아래 1pt씩 확보해 화면 좌표 변환 시 광고 경계 이탈 판정을 피한다.
    _height =
        2 +
        math.max(
          120,
          math.max(headlineSize * 1.4, captionSize * 1.4 + 4) +
              bodySize * 1.4 +
              math.max(24, math.max(captionSize, bodySize) * 1.4) +
              8,
        );
    unawaited(
      _load({
        'width': widget.width,
        'height': _height,
        'adLabel': AppLocalizations.of(context).nativeAdLabel,
        'headlineSize': headlineSize,
        'bodySize': bodySize,
        'captionSize': captionSize,
        'textColor': AppColors.black.toARGB32(),
        'secondaryColor': AppColors.black600.toARGB32(),
        'accentColor': AppColors.blue.toARGB32(),
        'badgeColor': AppColors.black100.toARGB32(),
      }),
    );
  }

  Future<void> _load(Map<String, Object> options) async {
    try {
      await widget.service.initialize();
      if (!mounted || !widget.service.isInitialized) return;
      final ad = NativeAd(
        adUnitId: AdUnitIds.communityNative,
        factoryId: 'communityNative',
        request: const AdRequest(),
        customOptions: options,
        nativeAdOptions: NativeAdOptions(
          adChoicesPlacement: AdChoicesPlacement.topRightCorner,
          videoOptions: VideoOptions(startMuted: true),
        ),
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            if (!mounted || !identical(_ad, ad)) return;
            setState(() => _loaded = true);
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint('[CommunityNativeAd] 로드 실패: $error');
            if (identical(_ad, ad)) _ad = null;
            unawaited(ad.dispose());
          },
        ),
      );
      _ad = ad;
      await ad.load();
    } catch (error) {
      debugPrint('[CommunityNativeAd] 광고 없이 진행: $error');
      final ad = _ad;
      _ad = null;
      if (ad != null) unawaited(ad.dispose());
    }
  }

  @override
  void dispose() {
    final ad = _ad;
    _ad = null;
    if (ad != null) unawaited(ad.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (!_loaded || ad == null) return const SizedBox.shrink();
    return Container(
      margin: widget.margin,
      height: _height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.ver2,
      ),
      child: AdWidget(ad: ad),
    );
  }
}
