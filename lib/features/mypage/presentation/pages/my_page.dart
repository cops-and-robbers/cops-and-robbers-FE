import 'package:flutter/material.dart';

import '../../../../core/widgets/pages/placeholder_page.dart';
import '../../../../l10n/app_localizations.dart';

/// 마이페이지 탭 — 현재는 준비중 placeholder
class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PlaceholderPage(
      title: l10n.bottomNavMyPage,
      message: l10n.comingSoonMessage,
    );
  }
}
