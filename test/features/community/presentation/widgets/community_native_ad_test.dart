import 'dart:async';

import 'package:cops_and_robbers/core/services/ads/ad_service.dart';
import 'package:cops_and_robbers/features/community/presentation/widgets/community_native_ad.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_mobile_ads/src/ad_instance_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  int? adId;
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(instanceManager.channel, (call) async {
          if (call.method == 'loadNativeAd') {
            adId = call.arguments['adId'] as int;
          }
          return null;
        });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          SystemChannels.platform_views,
          (_) async => null,
        );
  });

  for (final event in ['onAdLoaded', 'onAdFailedToLoad']) {
    testWidgets(
      'keeps_next_item_position_after_$event',
      (tester) async {
        final initialization = Completer<bool>();
        await tester.pumpWidget(_screen(initialization));
        await tester.pump();
        final position = tester.getTopLeft(find.text('next item'));
        initialization.complete(true);
        await tester.pump();
        await tester.pump();
        await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
          instanceManager.channel.name,
          instanceManager.channel.codec.encodeMethodCall(
            MethodCall('onAdEvent', {
              'adId': adId!,
              'eventName': event,
              if (event == 'onAdFailedToLoad')
                'loadAdError': LoadAdError(3, 'test', 'no fill', null),
            }),
          ),
          (_) {},
        );
        await tester.pump();
        expect(tester.getTopLeft(find.text('next item')), position);
        expect(
          event == 'onAdLoaded' ? find.byType(AdWidget) : find.text('모집글 작성'),
          findsOneWidget,
        );
        await tester.pumpWidget(const SizedBox());
        await tester.pump();
        expect(tester.takeException(), isNull);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );
  }

  testWidgets('keeps_space_on_timeout_and_ignores_late_initialization', (
    tester,
  ) async {
    final initialization = Completer<bool>();
    await tester.pumpWidget(_screen(initialization));
    await tester.pump();
    final position = tester.getTopLeft(find.text('next item'));
    await tester.pump(const Duration(seconds: 15));
    expect(find.text('모집글 작성'), findsOneWidget);
    initialization.complete(true);
    await tester.pump();
    expect(find.text('모집글 작성'), findsOneWidget);
    expect(tester.getTopLeft(find.text('next item')), position);
  });

  testWidgets('removes_slot_when_community_switch_turns_off', (tester) async {
    final enabled = StreamController<bool>();
    final initialization = Completer<bool>();
    await tester.pumpWidget(
      _screen(initialization, communityEnabled: enabled.stream),
    );
    enabled.add(true);
    await tester.pump();
    expect(
      tester.getTopLeft(find.text('next item')).dy,
      greaterThanOrEqualTo(122),
    );
    enabled.add(false);
    await tester.pump();
    expect(tester.getTopLeft(find.text('next item')).dy, 0);
    initialization.complete(false);
    await tester.pump();
    await enabled.close();
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps_next_item_position_when_initialization_fails', (
    tester,
  ) async {
    final initialization = Completer<bool>();
    await tester.pumpWidget(_screen(initialization));
    await tester.pump();
    final loadingPosition = tester.getTopLeft(find.text('next item'));
    expect(loadingPosition.dy, greaterThanOrEqualTo(122));

    initialization.complete(false);
    await tester.pump();
    expect(find.text('모집글 작성'), findsOneWidget);
    expect(tester.getTopLeft(find.text('next item')), loadingPosition);
    expect(tester.takeException(), isNull);
  });

  testWidgets('can_remove_slot_while_initialization_is_pending', (
    tester,
  ) async {
    final initialization = Completer<bool>();
    await tester.pumpWidget(_screen(initialization));
    await tester.pump();
    await tester.pumpWidget(const SizedBox());
    initialization.complete(false);
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}

Widget _screen(
  Completer<bool> initialization, {
  Stream<bool>? communityEnabled,
}) => ProviderScope(
  overrides: [
    communityAdsEnabledProvider.overrideWith(
      (ref) => communityEnabled ?? Stream.value(true),
    ),
    adsEnabledProvider.overrideWith((ref) => Stream.value(true)),
    adServiceProvider.overrideWith(
      (ref) => AdService(
        isAdsEnabled: () => true,
        sdkInitializer: () => initialization.future,
      ),
    ),
  ],
  child: ScreenUtilInit(
    designSize: const Size(390, 844),
    builder: (_, _) => const MaterialApp(
      locale: Locale('ko'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Column(children: [CommunityNativeAd(), Text('next item')]),
      ),
    ),
  ),
);
