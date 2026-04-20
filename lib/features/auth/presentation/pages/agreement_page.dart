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
                        _buildHeader(),
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
                          title: '이용약관',
                          onToggle: notifier.toggleTerms,
                          onDetailTap: () => _openDetail(
                            context,
                            title: '이용약관',
                            assetPath: 'assets/legal/terms_of_service.json',
                            externalUrl: AppUrls.termsOfService,
                          ),
                        ),
                        AgreementItem(
                          checked: state.privacyPolicy,
                          required: true,
                          title: '개인정보 처리방침',
                          onToggle: notifier.togglePrivacy,
                          onDetailTap: () => _openDetail(
                            context,
                            title: '개인정보 처리방침',
                            assetPath: 'assets/legal/privacy_policy.json',
                            externalUrl: AppUrls.privacyPolicy,
                          ),
                        ),
                        AgreementItem(
                          checked: state.locationTerms,
                          required: true,
                          title: '위치정보 이용약관',
                          onToggle: notifier.toggleLocation,
                          onDetailTap: () => _openDetail(
                            context,
                            title: '위치정보 이용약관',
                            assetPath: 'assets/legal/location_terms.json',
                            externalUrl: AppUrls.locationTerms,
                          ),
                        ),
                        AgreementItem(
                          checked: state.marketing,
                          required: false,
                          title: '마케팅 정보 수신',
                          onToggle: notifier.toggleMarketing,
                          onDetailTap: () => _openDetail(
                            context,
                            title: '마케팅 정보 수신',
                            assetPath: 'assets/legal/marketing_consent.json',
                            externalUrl: AppUrls.marketingConsent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                AppButton(
                  text: '동의하고 시작하기',
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

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '서비스 이용을 위해\n약관에 동의해주세요',
          style: AppTextStyles.heading_24.copyWith(color: AppColors.black),
        ),
        SizedBox(height: AppSpacing.vertical24),
        Text(
          '필수 약관에 모두 동의해야 서비스를 이용하실 수 있어요',
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

    switch (result) {
      case AgreementSubmitResult.success:
        ref.read(authNotifierProvider.notifier).markAgreementCompleted();
      case AgreementSubmitResult.offline:
        AppSnackbar.show(
          context,
          message: '아직 네트워크에 연결되지 않았어요',
          backgroundColor: AppColors.red,
        );
      case AgreementSubmitResult.missingRequired:
        AppSnackbar.show(
          context,
          message: '필수 약관에 모두 동의해주세요',
          backgroundColor: AppColors.red,
        );
      case AgreementSubmitResult.failure:
        final message =
            notifier.lastError?.message ?? '일시적인 오류가 발생했습니다. 다시 시도해주세요.';
        AppSnackbar.show(
          context,
          message: message,
          backgroundColor: AppColors.red,
        );
    }
  }
}
