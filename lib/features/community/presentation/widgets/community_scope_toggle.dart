import 'package:flutter/material.dart';

import '../../../../core/widgets/toggles/segmented_toggle.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/community_scope.dart';

/// 커뮤니티 목록 범위 토글 (전체 / 우리 동네 / 내 모임)
///
/// 트랙·애니메이션·햅틱·접근성은 공용 [SegmentedToggle]이 담당하고, 이 위젯은
/// `CommunityScope` ↔ 세그먼트 인덱스 변환만 한다. 폭을 주지 않아 부모가 준
/// 폭을 채운다 — 아래 카드 목록과 좌우가 맞아야 한다.
class CommunityScopeToggle extends StatelessWidget {
  const CommunityScopeToggle({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final CommunityScope selected;
  final ValueChanged<CommunityScope> onChanged;

  /// 세그먼트 표시 순서 — 인덱스 ↔ enum 변환의 단일 기준
  static const List<CommunityScope> _order = [
    CommunityScope.all,
    CommunityScope.nearby,
    CommunityScope.mine,
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SegmentedToggle(
      labels: [
        l10n.communityScopeAll,
        l10n.communityScopeNearby,
        l10n.communityScopeMine,
      ],
      selectedIndex: _order.indexOf(selected),
      onChanged: (index) => onChanged(_order[index]),
    );
  }
}
