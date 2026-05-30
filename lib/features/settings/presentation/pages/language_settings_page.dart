import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/i18n/locale_provider.dart';
import '../../../../core/services/app_icon/startup_app_icon.dart';
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
class LanguageSettingsPage extends ConsumerWidget {
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final localeState = ref.watch(appLocaleProvider);
    final notifier = ref.read(appLocaleProvider.notifier);
    final isFollowingSystem = localeState.isFollowingSystem;
    final currentCode = localeState.locale.languageCode;

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
              onTap: () => _followSystemAndApplyIcon(notifier),
            ),
            _buildItemDivider(),
            _LanguageOptionTile(
              label: l10n.settingsLanguageOptionKorean,
              selected: !isFollowingSystem && currentCode == 'ko',
              onTap: () => _setLocaleAndApplyIcon(notifier, const Locale('ko')),
            ),
            _buildItemDivider(),
            _LanguageOptionTile(
              label: l10n.settingsLanguageOptionEnglish,
              selected: !isFollowingSystem && currentCode == 'en',
              onTap: () => _setLocaleAndApplyIcon(notifier, const Locale('en')),
            ),
            _buildItemDivider(),
            _LanguageOptionTile(
              label: l10n.settingsLanguageOptionJapanese,
              selected: !isFollowingSystem && currentCode == 'ja',
              onTap: () => _setLocaleAndApplyIcon(notifier, const Locale('ja')),
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

void _setLocaleAndApplyIcon(AppLocale notifier, Locale locale) {
  unawaited(() async {
    await notifier.setLocale(locale);
    await applyLocaleIcon(locale);
  }());
}

void _followSystemAndApplyIcon(AppLocale notifier) {
  unawaited(() async {
    await notifier.followSystem();
    await applyStartupLocaleIcon();
  }());
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
