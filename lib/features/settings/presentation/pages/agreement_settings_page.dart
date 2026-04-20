import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/buttons/previous_button.dart';
import '../../../../core/widgets/snackbars/app_snackbar.dart';
import '../../../auth/presentation/widgets/agreement_item.dart';
import '../../../user/domain/entities/agreement_status_entity.dart';
import '../../../user/presentation/providers/user_provider.dart';
import 'legal_document_page.dart';

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
        message: '아직 네트워크에 연결되지 않았어요',
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

      AppSnackbar.show(context, message: '변경사항이 저장되었어요');
    } catch (e) {
      if (!mounted) return;
      final message = e is AppException
          ? e.message
          : '일시적인 오류가 발생했습니다. 다시 시도해주세요.';
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

  void _openDetail({required String title, required String assetPath}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LegalDocumentPage(title: title, assetPath: assetPath),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: PreviousButton(onPressed: () => Navigator.of(context).pop()),
        centerTitle: true,
        title: Text(
          '약관 동의 관리',
          style: AppTextStyles.heading_20.copyWith(color: AppColors.black),
        ),
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
    final message = error is AppException
        ? error.message
        : '약관 동의 현황을 불러올 수 없습니다.';
    return Padding(
      padding: AppPadding.all20,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 40, color: AppColors.black400),
          SizedBox(height: AppSpacing.vertical16),
          Text(
            message,
            style: AppTextStyles.paragraph_14.copyWith(
              color: AppColors.black600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.vertical16),
          AppButton(
            text: '다시 시도',
            onPressed: () {
              setState(() => _status = const AsyncValue.loading());
              _loadAgreements();
            },
            showBorder: false,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AgreementStatusEntity status) {
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
                    title: '이용약관',
                    onToggle: () {},
                    onDetailTap: () => _openDetail(
                      title: '이용약관',
                      assetPath: 'assets/legal/terms_of_service.json',
                    ),
                  ),
                  SizedBox(height: AppSpacing.vertical6),
                  Divider(color: AppColors.black100, height: 1),
                  SizedBox(height: AppSpacing.vertical6),
                  AgreementItem(
                    checked: status.privacyPolicy,
                    required: true,
                    readOnly: true,
                    title: '개인정보 처리방침',
                    onToggle: () {},
                    onDetailTap: () => _openDetail(
                      title: '개인정보 처리방침',
                      assetPath: 'assets/legal/privacy_policy.json',
                    ),
                  ),
                  SizedBox(height: AppSpacing.vertical6),
                  Divider(color: AppColors.black100, height: 1),
                  SizedBox(height: AppSpacing.vertical6),
                  AgreementItem(
                    checked: status.locationTerms,
                    required: true,
                    readOnly: true,
                    title: '위치정보 이용약관',
                    onToggle: () {},
                    onDetailTap: () => _openDetail(
                      title: '위치정보 이용약관',
                      assetPath: 'assets/legal/location_terms.json',
                    ),
                  ),
                  SizedBox(height: AppSpacing.vertical6),
                  Divider(color: AppColors.black100, height: 1),
                  SizedBox(height: AppSpacing.vertical6),
                  AgreementItem(
                    checked: _newMarketing,
                    required: false,
                    title: '마케팅 정보 수신',
                    onToggle: () =>
                        setState(() => _newMarketing = !_newMarketing),
                    onDetailTap: () => _openDetail(
                      title: '마케팅 정보 수신',
                      assetPath: 'assets/legal/marketing_consent.json',
                    ),
                  ),
                ],
              ),
            ),
          ),
          AppButton(
            text: '변경사항 저장',
            onPressed: _hasChanges && !_isSaving ? _save : null,
            isLoading: _isSaving,
            showBorder: false,
          ),
        ],
      ),
    );
  }
}
