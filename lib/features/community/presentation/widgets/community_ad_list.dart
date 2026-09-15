import 'package:flutter/material.dart';

import 'community_native_ad.dart';

/// 상단 1개 + 콘텐츠 5개마다 광고. 빈 목록에도 상단 광고와 안내를 함께 둔다.
class CommunityAdList extends StatelessWidget {
  const CommunityAdList({
    super.key,
    required this.emptyState,
    required this.padding,
    required this.spacing,
    this.itemCount = 0,
    this.itemBuilder,
    this.controller,
    this.trailing,
    this.showAds = true,
  }) : assert(itemCount == 0 || itemBuilder != null);

  final Widget emptyState;
  final EdgeInsets padding;
  final double spacing;
  final int itemCount;
  final IndexedWidgetBuilder? itemBuilder;
  final ScrollController? controller;
  final Widget? trailing;
  final bool showAds;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: controller,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: padding.copyWith(bottom: 0),
          sliver: SliverMainAxisGroup(
            slivers: [
              if (showAds)
                SliverToBoxAdapter(
                  child: CommunityNativeAd(
                    margin: EdgeInsets.only(bottom: spacing),
                  ),
                ),
              SliverList.separated(
                itemCount: itemCount,
                separatorBuilder: (_, _) => SizedBox(height: spacing),
                itemBuilder: (context, index) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    itemBuilder!(context, index),
                    if (showAds && (index + 1) % 5 == 0)
                      CommunityNativeAd(margin: EdgeInsets.only(top: spacing)),
                  ],
                ),
              ),
              if (trailing != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: spacing),
                    child: trailing,
                  ),
                ),
            ],
          ),
        ),
        if (itemCount == 0)
          SliverFillRemaining(hasScrollBody: false, child: emptyState)
        else
          SliverToBoxAdapter(child: SizedBox(height: padding.bottom)),
      ],
    );
  }
}
