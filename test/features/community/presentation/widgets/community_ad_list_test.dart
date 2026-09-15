import 'package:cops_and_robbers/core/services/ads/ad_service.dart';
import 'package:cops_and_robbers/features/community/presentation/widgets/community_ad_list.dart';
import 'package:cops_and_robbers/features/community/presentation/widgets/community_native_ad.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('keeps_top_and_five_item_ad_slots_when_content_changes', (
    tester,
  ) async {
    for (final (count, expectedAds) in [
      (0, 1),
      (4, 1),
      (5, 2),
      (6, 2),
      (10, 3),
      (0, 1),
    ]) {
      await tester.pumpWidget(_list(count));
      await tester.pumpAndSettle();

      expect(
        find.byType(CommunityNativeAd, skipOffstage: false),
        findsNWidgets(expectedAds),
      );
      expect(find.text('empty'), count == 0 ? findsOneWidget : findsNothing);
      for (var i = 0; i < count; i++) {
        expect(find.text('item $i'), findsOneWidget);
      }
      if (count >= 5) {
        final ads = find.byType(CommunityNativeAd, skipOffstage: false);
        expect(tester.getTopLeft(ads.first).dy, 16);
        expect(tester.getTopLeft(ads.at(1)).dy, 264);
      }
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('keeps_content_spacing_without_ads_when_placement_is_disabled', (
    tester,
  ) async {
    await tester.pumpWidget(_list(6, showAds: false));
    await tester.pumpAndSettle();

    expect(find.byType(CommunityNativeAd, skipOffstage: false), findsNothing);
    expect(tester.getTopLeft(find.text('item 0')).dy, 16);
    expect(tester.getTopLeft(find.text('item 5')).dy, 276);
    expect(tester.takeException(), isNull);
  });
}

Widget _list(int count, {bool showAds = true}) => ProviderScope(
  overrides: [
    // 실제 광고 SDK를 호출하지 않아도 슬롯 배치와 미노출 시 여백을 검증한다.
    adsEnabledProvider.overrideWith((ref) => Stream.value(false)),
  ],
  child: MaterialApp(
    home: Scaffold(
      body: CommunityAdList(
        padding: const EdgeInsets.all(16),
        spacing: 12,
        emptyState: const Center(child: Text('empty')),
        showAds: showAds,
        itemCount: count,
        itemBuilder: (_, i) => SizedBox(height: 40, child: Text('item $i')),
      ),
    ),
  ),
);
