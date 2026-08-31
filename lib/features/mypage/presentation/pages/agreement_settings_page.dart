import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/legal_doc.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/i18n/error_message_mapper.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/navigation/app_top_bar.dart';
import '../../../../core/widgets/dividers/solid_divider.dart';
import '../../../../core/widgets/load_failure_view.dart';
import '../../../../core/widgets/snackbars/app_snackbar.dart';
import '../../../../router/route_paths.dart';
import '../../../auth/presentation/widgets/agreement_item.dart';
import '../../../user/domain/entities/agreement_status_entity.dart';
import '../../../user/presentation/providers/user_provider.dart';

/// 약관 동의 관리 페이지 (설정 내부)
///
/// 현재 사용자의 약관 동의 현황을 조회하고, 마케팅 수신 동의만 토글할 수 있습니다.
/// 필수 3종(이용약관·개인정보 처리방침·위치정보 이용약관)은 서비스 이용에 필수이므로
/// 읽기 전용으로 표시됩니다 (백엔드가 해제 시 400 에러 반환).
class AgreementSettingsPage extends ConsumerStatefulWidget {
  const AgreementSettingsPage({super.key});

  @override
  ConsumerState<AgreementSettingsPage> createState() =>
      _AgreementSettingsPageState();
}

class _AgreementSettingsPageState extends ConsumerState<AgreementSettingsPage> {
  AsyncValue<AgreementStatusEntity> _status = const AsyncValue.loading();
  bool _newMarketing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadAgreements();
  }

  Future<void> _loadAgreements() async {
    try {
      final repo = ref.read(userRepositoryProvider);
      final status = await repo.getAgreements();
      if (!mounted) return;
      setState(() {
        _status = AsyncValue.data(status);
        _newMarketing = status.marketing;
      });
    } catch (e, stack) {
      if (!mounted) return;
      setState(() {
        _status = AsyncValue.error(e, stack);
      });
    }
  }

  bool get _hasChanges {
    final current = _status.valueOrNull;
    if (current == null) return false;
    return _newMarketing != current.marketing;
  }

  Future<void> _save() async {
    if (_isSaving || !_hasChanges) return;

    // 네트워크 사전 체크
    final connectivity = ref.read(connectivityServiceProvider);
    final isConnected = await connectivity.isConnected();
    if (!isConnected) {
      if (!mounted) return;
      AppSnackbar.show(
        context,
        message: AppLocalizations.of(context).errorNetworkNotConnected,
        backgroundColor: AppColors.red,
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(userRepositoryProvider);
      await repo.updateAgreements(marketing: _newMarketing);

      if (!mounted) return;

      // 로컬 상태도 동기화
      final current = _status.valueOrNull;
      if (current != null) {
        setState(() {
          _status = AsyncValue.data(current.copyWith(marketing: _newMarketing));
        });
      }

      AppSnackbar.show(
        context,
        message: AppLocalizations.of(context).messageChangesSaved,
      );
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      final message = e is AppException
          ? l10n.errorByException(e)
          : l10n.errorTemporaryRetry;
      AppSnackbar.show(
        context,
        message: message,
        backgroundColor: AppColors.red,
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppTopBar(
        title: l10n.pageAgreementSettingsTitle,
        onBack: () => Navigator.of(context).pop(),
      ),
      body: SafeArea(
        child: _status.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _buildError(error),
          data: (status) => _buildContent(status),
        ),
      ),
    );
  }

  Widget _buildError(Object error) {
    final l10n = AppLocalizations.of(context);
    final message = error is AppException
        ? l10n.errorByException(error)
        : l10n.errorAgreementLoadFailed;
    return LoadFailureView(
      message: message,
      onRetry: () {
        setState(() => _status = const AsyncValue.loading());
        _loadAgreements();
      },
    );
  }

  Widget _buildContent(AgreementStatusEntity status) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: AppPadding.all24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AgreementItem(
                    checked: status.termsOfService,
                    required: true,
                    readOnly: true,
                    title: l10n.linkTermsOfService,
                    onToggle: () {},
                    onDetailTap: () => context.push(
                      RoutePaths.legalDocumentOf(LegalDoc.terms),
                    ),
                  ),
                  SizedBox(height: AppSpacing.vertical6),
                  const SolidDivider(),
                  SizedBox(height: AppSpacing.vertical6),
                  AgreementItem(
                    checked: status.privacyPolicy,
                    required: true,
                    readOnly: true,
                    title: l10n.linkPrivacyPolicy,
                    onToggle: () {},
                    onDetailTap: () => context.push(
                      RoutePaths.legalDocumentOf(LegalDoc.privacy),
                    ),
                  ),
                  SizedBox(height: AppSpacing.vertical6),
                  const SolidDivider(),
                  SizedBox(height: AppSpacing.vertical6),
                  AgreementItem(
                    checked: status.locationTerms,
                    required: true,
                    readOnly: true,
                    title: l10n.linkLocationTerms,
                    onToggle: () {},
                    onDetailTap: () => context.push(
                      RoutePaths.legalDocumentOf(LegalDoc.location),
                    ),
                  ),
                  SizedBox(height: AppSpacing.vertical6),
                  const SolidDivider(),
                  SizedBox(height: AppSpacing.vertical6),
                  AgreementItem(
                    checked: _newMarketing,
                    required: false,
                    title: l10n.linkMarketingConsent,
                    onToggle: () =>
                        setState(() => _newMarketing = !_newMarketing),
                    onDetailTap: () => context.push(
                      RoutePaths.legalDocumentOf(LegalDoc.marketing),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AppButton(
            text: l10n.buttonSaveChanges,
            onPressed: _hasChanges && !_isSaving ? _save : null,
            isLoading: _isSaving,
          ),
        ],
      ),
    );
  }
}
