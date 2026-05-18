import 'package:cops_and_robbers/core/i18n/error_message_mapper.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_urls.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/snackbars/app_snackbar.dart';
import '../../../settings/presentation/pages/legal_document_page.dart';
import '../providers/agreement_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/agreement_all_checkbox.dart';
import '../widgets/agreement_item.dart';

/// 약관 동의 페이지
///
/// 로그인 후 필수 약관 미동의 사용자에게 노출되며, 동의 완료 전까지
/// 앱의 다른 화면으로 진입할 수 없습니다 (AppBar 없음, PopScope로 백 차단).
class AgreementPage extends ConsumerWidget {
  const AgreementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(agreementNotifierProvider);
    final notifier = ref.read(agreementNotifierProvider.notifier);
    final l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Padding(
            padding: AppPadding.all24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 50.h),
                        _buildHeader(l10n),
                        SizedBox(height: AppSpacing.vertical24),
                        AgreementAllCheckbox(
                          checked: state.allAgreed,
                          onToggle: () => notifier.toggleAll(!state.allAgreed),
                        ),
                        SizedBox(height: AppSpacing.vertical6),
                        const Divider(color: AppColors.black100, height: 1),
                        SizedBox(height: AppSpacing.vertical6),
                        AgreementItem(
                          checked: state.termsOfService,
                          required: true,
                          title: l10n.linkTermsOfService,
                          onToggle: notifier.toggleTerms,
                          onDetailTap: () => _openDetail(
                            context,
                            title: l10n.linkTermsOfService,
                            assetPath: 'assets/legals/terms_of_service.json',
                            externalUrl: AppUrls.termsOfService,
                          ),
                        ),
                        AgreementItem(
                          checked: state.privacyPolicy,
                          required: true,
                          title: l10n.linkPrivacyPolicy,
                          onToggle: notifier.togglePrivacy,
                          onDetailTap: () => _openDetail(
                            context,
                            title: l10n.linkPrivacyPolicy,
                            assetPath: 'assets/legals/privacy_policy.json',
                            externalUrl: AppUrls.privacyPolicy,
                          ),
                        ),
                        AgreementItem(
                          checked: state.locationTerms,
                          required: true,
                          title: l10n.linkLocationTerms,
                          onToggle: notifier.toggleLocation,
                          onDetailTap: () => _openDetail(
                            context,
                            title: l10n.linkLocationTerms,
                            assetPath: 'assets/legals/location_terms.json',
                            externalUrl: AppUrls.locationTerms,
                          ),
                        ),
                        AgreementItem(
                          checked: state.marketing,
                          required: false,
                          title: l10n.linkMarketingConsent,
                          onToggle: notifier.toggleMarketing,
                          onDetailTap: () => _openDetail(
                            context,
                            title: l10n.linkMarketingConsent,
                            assetPath: 'assets/legals/marketing_consent.json',
                            externalUrl: AppUrls.marketingConsent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                AppButton(
                  text: l10n.agreementPageAgreeButton,
                  onPressed: state.hasAllRequired && !state.isSubmitting
                      ? () => _onSubmit(context, ref)
                      : null,
                  isLoading: state.isSubmitting,
                  showBorder: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.agreementPageTitle,
          style: AppTextStyles.heading_24.copyWith(
            color: AppColors.black,
            height: 1.4,
          ),
        ),
        SizedBox(height: AppSpacing.vertical24),
        Text(
          l10n.agreementPageRequiredNotice,
          style: AppTextStyles.paragraph_14_100.copyWith(
            color: AppColors.black600,
          ),
        ),
      ],
    );
  }

  void _openDetail(
    BuildContext context, {
    required String title,
    required String assetPath,
    String? externalUrl,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LegalDocumentPage(
          title: title,
          assetPath: assetPath,
          externalUrl: externalUrl,
        ),
      ),
    );
  }

  Future<void> _onSubmit(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(agreementNotifierProvider.notifier);
    final result = await notifier.submit();

    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context);

    switch (result) {
      case AgreementSubmitResult.success:
        ref.read(authNotifierProvider.notifier).markAgreementCompleted();
      case AgreementSubmitResult.offline:
        AppSnackbar.show(
          context,
          message: l10n.errorNetworkNotConnected,
          backgroundColor: AppColors.red,
        );
      case AgreementSubmitResult.missingRequired:
        AppSnackbar.show(
          context,
          message: l10n.errorRequiredAgreementsMissing,
          backgroundColor: AppColors.red,
        );
      case AgreementSubmitResult.failure:
        // 백엔드 메시지가 있으면 i18n 키로 변환, 없으면 일반 폴백 사용
        final lastError = notifier.lastError;
        final message = lastError != null
            ? l10n.errorByException(lastError)
            : l10n.errorTemporaryRetry;
        AppSnackbar.show(
          context,
          message: message,
          backgroundColor: AppColors.red,
        );
    }
  }
}
