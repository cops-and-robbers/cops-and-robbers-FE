import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/i18n/locale_provider.dart';
import '../../../../core/widgets/buttons/previous_button.dart';
import '../../../../l10n/app_localizations.dart';

/// 언어 설정 페이지 (설정 내부)
///
/// 4개 옵션 (시스템 따름 / 한국어 / English / 日本語) 중 하나를 선택하면
/// 즉시 적용되고 [PreviousButton]으로 페이지를 나간다.
/// `AgreementSettingsPage`와 동일한 AppBar 스타일로 설정 UI 일관성을 유지한다.
///
/// **즉시 적용 패턴**: 저장 버튼 없이 옵션 탭 → `notifier.setLocale()` 호출
/// → `appLocaleProvider` 갱신 → `_LocalizedApp`(main.dart)이 watch 중이므로
/// `MaterialApp` 통째로 재구성되어 페이지 내 텍스트도 즉시 새 언어로 갱신된다.
///
/// **`ConsumerStatefulWidget` 이유**: `isFollowingSystem`은 Notifier 내부 bool 필드라
/// `ref.watch`로 받지 못한다. 옵션 탭 후 선택 마크가 즉시 갱신되려면 `setState`가 필요하다.
class LanguageSettingsPage extends ConsumerStatefulWidget {
  const LanguageSettingsPage({super.key});

  @override
  ConsumerState<LanguageSettingsPage> createState() =>
      _LanguageSettingsPageState();
}

class _LanguageSettingsPageState extends ConsumerState<LanguageSettingsPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentLocale = ref.watch(appLocaleProvider);
    // notifier 메서드 접근 + isFollowingSystem 일회성 조회 (watch 불가)
    final notifier = ref.read(appLocaleProvider.notifier);
    final isFollowingSystem = notifier.isFollowingSystem;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: PreviousButton(onPressed: () => Navigator.of(context).pop()),
        centerTitle: true,
        title: Text(
          l10n.settingsLanguagePageTitle,
          style: AppTextStyles.heading_20.copyWith(color: AppColors.black),
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LanguageOptionTile(
              label: l10n.settingsLanguageOptionSystem,
              selected: isFollowingSystem,
              onTap: () async {
                await notifier.followSystem();
                if (mounted) setState(() {});
              },
            ),
            _buildItemDivider(),
            _LanguageOptionTile(
              label: l10n.settingsLanguageOptionKorean,
              selected:
                  !isFollowingSystem && currentLocale.languageCode == 'ko',
              onTap: () async {
                await notifier.setLocale(const Locale('ko'));
                if (mounted) setState(() {});
              },
            ),
            _buildItemDivider(),
            _LanguageOptionTile(
              label: l10n.settingsLanguageOptionEnglish,
              selected:
                  !isFollowingSystem && currentLocale.languageCode == 'en',
              onTap: () async {
                await notifier.setLocale(const Locale('en'));
                if (mounted) setState(() {});
              },
            ),
            _buildItemDivider(),
            _LanguageOptionTile(
              label: l10n.settingsLanguageOptionJapanese,
              selected:
                  !isFollowingSystem && currentLocale.languageCode == 'ja',
              onTap: () async {
                await notifier.setLocale(const Locale('ja'));
                if (mounted) setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 옵션 간 구분선 — `settings_page._buildItemDivider`와 동일한 패턴
  /// (좌우 20px 패딩, h=1, black100) — 설정 화면 전반의 일관성 유지
  Widget _buildItemDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.horizontal20),
      child: const Divider(color: AppColors.black100, height: 1),
    );
  }
}

/// 언어 옵션 행 — 라벨 + 선택 시 우측 체크 아이콘
class _LanguageOptionTile extends StatelessWidget {
  const _LanguageOptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.horizontal24,
          vertical: AppSpacing.vertical16,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.label_16.copyWith(
                  color: selected ? AppColors.blue : AppColors.black,
                ),
              ),
            ),
            if (selected)
              Icon(Icons.check_rounded, size: 16.r, color: AppColors.blue),
          ],
        ),
      ),
    );
  }
}
