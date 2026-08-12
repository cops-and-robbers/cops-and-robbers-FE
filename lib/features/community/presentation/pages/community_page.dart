import 'package:flutter/material.dart';

import '../../../../core/widgets/pages/placeholder_page.dart';
import '../../../../l10n/app_localizations.dart';

/// 커뮤니티 탭 — 현재는 준비중 placeholder
class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PlaceholderPage(
      title: l10n.bottomNavCommunity,
      message: l10n.comingSoonMessage,
    );
  }
}
