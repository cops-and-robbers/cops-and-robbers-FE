import 'dart:io';

import 'package:cops_and_robbers/core/constants/spacing_and_radius.dart';
import 'package:cops_and_robbers/core/i18n/error_message_mapper.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_urls.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/i18n/locale_brand_assets.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/widgets/buttons/social_login_button.dart';
import '../../../../core/widgets/dialogs/app_dialog.dart';
import '../../../../core/widgets/snackbars/app_snackbar.dart';
import '../../../settings/presentation/pages/legal_document_page.dart';
import '../providers/auth_provider.dart';

/// Google 로그인 화면
///
/// Google/Apple Sign-In을 통해 사용자 인증을 수행합니다.
/// 앱바가 없는 전체 화면 레이아웃으로 구성되며,
/// 로고는 중앙에, 소셜 로그인 버튼은 하단에 고정됩니다.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  /// 연령 확인 상태 초기화 (로그아웃 시 호출)
  static void resetAgeVerification() => _LoginPageState._ageVerified = false;

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  /// Google 로그인 로딩 상태
  bool _isGoogleLoading = false;

  /// Apple 로그인 로딩 상태
  bool _isAppleLoading = false;

  /// 만 14세 미만 선택 시 로그인 차단
  bool _isUnder14 = false;

  /// 연령 확인 다이얼로그 표시 여부 (로그인 세션 단위 1회)
  static bool _ageVerified = false;

  /// 개인정보 처리방침 탭 인식기
  late final TapGestureRecognizer _privacyRecognizer;

  /// 이용약관 탭 인식기
  late final TapGestureRecognizer _termsRecognizer;

  /// 위치정보 이용약관 탭 인식기
  late final TapGestureRecognizer _locationRecognizer;

  @override
  void initState() {
    super.initState();
    _privacyRecognizer = TapGestureRecognizer()
      ..onTap = () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LegalDocumentPage(
            title: AppLocalizations.of(context).linkPrivacyPolicy,
            assetPath: 'assets/legals/privacy_policy.json',
            externalUrl: AppUrls.privacyPolicy,
          ),
        ),
      );
    _termsRecognizer = TapGestureRecognizer()
      ..onTap = () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LegalDocumentPage(
            title: AppLocalizations.of(context).linkTermsOfService,
            assetPath: 'assets/legals/terms_of_service.json',
            externalUrl: AppUrls.termsOfService,
          ),
        ),
      );
    _locationRecognizer = TapGestureRecognizer()
      ..onTap = () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LegalDocumentPage(
            title: AppLocalizations.of(context).linkLocationTerms,
            assetPath: 'assets/legals/location_terms.json',
            externalUrl: AppUrls.locationTerms,
          ),
        ),
      );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // 회원 탈퇴 완료 메시지 표시
      final accountDeleted = GoRouterState.of(
        context,
      ).uri.queryParameters['accountDeleted'];
      // 강제 로그아웃 사유 messageKey (토큰 재발급 실패 등) — errorByKey로 i18n 변환
      final forceLogoutKey = ref.read(forceLogoutMessageKeyProvider);
      if (forceLogoutKey != null) {
        ref.read(forceLogoutMessageKeyProvider.notifier).state = null;
      }

      if (accountDeleted == 'true') {
        AppSnackbar.show(
          context,
          message: AppLocalizations.of(context).messageAccountDeleted,
          backgroundColor: AppColors.blue,
        );
      } else if (forceLogoutKey != null) {
        AppSnackbar.show(
          context,
          message: AppLocalizations.of(context).errorByKey(forceLogoutKey),
          backgroundColor: AppColors.red,
        );
      }

      // 만 14세 이상 연령 확인 다이얼로그 (세션 단위 1회)
      if (!_ageVerified) _showAgeVerificationDialog();
    });
  }

  /// 만 14세 이상 연령 확인 다이얼로그
  void _showAgeVerificationDialog() {
    final l10n = AppLocalizations.of(context);
    AppDialog.show(
      context: context,
      title: l10n.dialogAge14ConfirmTitle,
      message: l10n.dialogAge14ConfirmMessage,
      confirmText: l10n.buttonYes,
      cancelText: l10n.buttonNo,
      barrierDismissible: false,
      onConfirm: () {
        _ageVerified = true;
      },
      onCancel: () {
        if (mounted) setState(() => _isUnder14 = true);
      },
    );
  }

  @override
  void dispose() {
    _privacyRecognizer.dispose();
    _termsRecognizer.dispose();
    _locationRecognizer.dispose();
    super.dispose();
  }

  /// Google 로그인 버튼 핸들러
  ///
  /// Google 로그인을 수행하고 에러 발생 시 SnackBar를 표시합니다.
  /// 로그인 성공 후 네비게이션은 GoRouter의 redirect가 처리합니다.
  Future<void> _handleGoogleSignIn(BuildContext context) async {
    setState(() => _isGoogleLoading = true);

    try {
      await ref.read(authNotifierProvider.notifier).signInWithGoogle();
      // 네비게이션은 app_router.dart의 redirect가 처리
      // (_GoRouterRefreshNotifier가 auth 상태 변경 감지 → GoRouter redirect 실행)
    } on AuthCancelledException {
      if (!mounted) return;
      // ignore_for_file: use_build_context_synchronously
      AppSnackbar.show(
        context,
        message: AppLocalizations.of(context).errorAuthLoginCancelled,
      );
    } catch (e) {
      if (!mounted) return;
      _showLoginError(AppLocalizations.of(context).errorLoginGeneric);
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  /// Apple 로그인 버튼 핸들러
  ///
  /// Apple 로그인을 수행하고 에러 발생 시 SnackBar를 표시합니다.
  /// 로그인 성공 후 네비게이션은 GoRouter의 redirect가 처리합니다.
  Future<void> _handleAppleSignIn(BuildContext context) async {
    setState(() => _isAppleLoading = true);

    try {
      await ref.read(authNotifierProvider.notifier).signInWithApple();
      // 네비게이션은 app_router.dart의 redirect가 처리
      // (_GoRouterRefreshNotifier가 auth 상태 변경 감지 → GoRouter redirect 실행)
    } on AuthCancelledException {
      if (!mounted) return;
      AppSnackbar.show(
        context,
        message: AppLocalizations.of(context).errorAuthLoginCancelled,
      );
    } catch (e) {
      if (!mounted) return;
      _showLoginError(AppLocalizations.of(context).errorAppleLoginFailed);
    } finally {
      if (mounted) {
        setState(() => _isAppleLoading = false);
      }
    }
  }

  /// 로그인 에러 SnackBar 표시
  void _showLoginError(String fallbackMessage) {
    final authState = ref.read(authNotifierProvider);
    final l10n = AppLocalizations.of(context);

    // AuthException이면 messageKey 기반 i18n 변환, 아니면 fallback
    final errorMessage =
        (authState.hasError && authState.error is AuthException)
        ? l10n.errorByException(authState.error as AuthException)
        : fallbackMessage;

    AppSnackbar.show(
      context,
      message: errorMessage,
      backgroundColor: AppColors.red,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // 로고와 버튼을 Column으로 배치 (정확한 간격 제어)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 120.h),
                  // 앱 로고 (로케일별 워드마크) — 폭 고정, 높이는 비율 자동
                  SvgPicture.asset(
                    localizedAppLogo(Localizations.localeOf(context)),
                    width: 220.w,
                  ),

                  // 로고와 한 줄 소개 사이 간격
                  SizedBox(height: AppSpacing.vertical16),

                  // 앱 한 줄 소개 카피
                  Text(
                    l10n.loginPageTagline,
                    style: AppTextStyles.paragraph_14.copyWith(
                      color: AppColors.black800,
                    ),
                  ),

                  // 로고·카피 블록과 버튼 사이 간격 (플랫폼별)
                  SizedBox(height: Platform.isIOS ? 180.h : 210.h),

                  // Google 로그인 버튼
                  GoogleLoginButton(
                    onPressed: _isUnder14 || _isAppleLoading
                        ? null
                        : () => _handleGoogleSignIn(context),
                    isLoading: _isGoogleLoading,
                  ),

                  // iOS에서만 Apple 로그인 버튼 표시
                  if (Platform.isIOS) ...[
                    SizedBox(height: AppSpacing.vertical12),
                    AppleLoginButton(
                      onPressed: _isUnder14 || _isGoogleLoading
                          ? null
                          : () => _handleAppleSignIn(context),
                      isLoading: _isAppleLoading,
                    ),
                  ],

                  // 만 14세 미만 안내
                  if (_isUnder14) ...[
                    SizedBox(height: AppSpacing.vertical12),
                    Text(
                      l10n.errorAgeRestrictionUnder14,
                      style: AppTextStyles.tag_12.copyWith(
                        color: AppColors.red,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // 약관 동의 안내 텍스트 (하단 고정)
            Positioned(
              left: 0,
              right: 0,
              bottom: Platform.isIOS ? 10.h : 30.h,
              child: Padding(
                padding: AppPadding.horizontal20,
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: AppTextStyles.tag_12.copyWith(
                      color: AppColors.black400,
                    ),
                    children: [
                      TextSpan(text: l10n.loginPageAgreementPrefix),
                      const TextSpan(text: ' '),

                      TextSpan(
                        text: l10n.linkPrivacyPolicy,
                        style: AppTextStyles.tag_12.copyWith(
                          color: AppColors.black600,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: _privacyRecognizer,
                      ),
                      const TextSpan(text: ', '),
                      TextSpan(
                        text: l10n.linkTermsOfService,
                        style: AppTextStyles.tag_12.copyWith(
                          color: AppColors.black600,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: _termsRecognizer,
                      ),
                      const TextSpan(text: ', '),
                      TextSpan(
                        text: l10n.linkLocationTerms,
                        style: AppTextStyles.tag_12.copyWith(
                          color: AppColors.black600,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: _locationRecognizer,
                      ),
                      TextSpan(text: l10n.loginPageAgreementSuffix),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
