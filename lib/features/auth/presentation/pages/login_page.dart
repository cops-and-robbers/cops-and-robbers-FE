import 'dart:io';

import 'package:cops_and_robbers/core/constants/spacing_and_radius.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_urls.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/utils/url_launcher_util.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/buttons/social_login_button.dart';
import '../../../../router/route_paths.dart';
import '../providers/auth_provider.dart';

/// Google 로그인 화면
///
/// Google/Apple Sign-In을 통해 사용자 인증을 수행합니다.
/// 앱바가 없는 전체 화면 레이아웃으로 구성되며,
/// 로고는 중앙에, 소셜 로그인 버튼은 하단에 고정됩니다.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  /// Google 로그인 로딩 상태
  bool _isGoogleLoading = false;

  /// Apple 로그인 로딩 상태
  bool _isAppleLoading = false;

  /// 개인정보 처리방침 탭 인식기
  late final TapGestureRecognizer _privacyRecognizer;

  /// 이용약관 탭 인식기
  late final TapGestureRecognizer _termsRecognizer;

  @override
  void initState() {
    super.initState();
    _privacyRecognizer = TapGestureRecognizer()
      ..onTap = () async => await launchExternalUrl(AppUrls.privacyPolicy);
    _termsRecognizer = TapGestureRecognizer()
      ..onTap = () async => await launchExternalUrl(AppUrls.termsOfService);
  }

  @override
  void dispose() {
    _privacyRecognizer.dispose();
    _termsRecognizer.dispose();
    super.dispose();
  }

  /// Google 로그인 버튼 핸들러
  ///
  /// Google 로그인을 수행하고 에러 발생 시 SnackBar를 표시합니다.
  Future<void> _handleGoogleSignIn(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    // 로딩 시작
    setState(() => _isGoogleLoading = true);

    try {
      // AuthNotifier로 로그인 수행 (Firebase + 백엔드)
      await ref.read(authNotifierProvider.notifier).signInWithGoogle();

      if (!mounted) return;

      // 로그인 성공 후 isNewUser에 따라 분기
      _navigateAfterLogin();
    } catch (e) {
      // AuthNotifier에서 rethrow한 에러를 여기서 처리
      if (!mounted) return;
      _showLoginError(scaffoldMessenger, '로그인 중 오류가 발생했습니다.');
    } finally {
      // 로딩 종료 (에러 발생 시에도 반드시 실행)
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  /// Apple 로그인 버튼 핸들러
  ///
  /// Apple 로그인을 수행하고 에러 발생 시 SnackBar를 표시합니다.
  Future<void> _handleAppleSignIn(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    // 로딩 시작
    setState(() => _isAppleLoading = true);

    try {
      // AuthNotifier로 로그인 수행 (Firebase + 백엔드)
      await ref.read(authNotifierProvider.notifier).signInWithApple();

      if (!mounted) return;

      // 로그인 성공 후 isNewUser에 따라 분기
      _navigateAfterLogin();
    } catch (e) {
      // AuthNotifier에서 rethrow한 에러를 여기서 처리
      if (!mounted) return;
      _showLoginError(scaffoldMessenger, 'Apple 로그인 중 오류가 발생했습니다.');
    } finally {
      // 로딩 종료 (에러 발생 시에도 반드시 실행)
      if (mounted) {
        setState(() => _isAppleLoading = false);
      }
    }
  }

  /// 로그인 성공 후 네비게이션 분기
  ///
  /// - isNewUser == true → 닉네임 설정 페이지
  /// - isNewUser == false → 홈 페이지
  void _navigateAfterLogin() {
    final authState = ref.read(authNotifierProvider);
    final authResult = authState.value;

    if (authResult != null && authResult.isNewUser) {
      // 신규 회원: 닉네임 설정 페이지로 이동
      context.go(
        Uri(
          path: RoutePaths.nicknameSetup,
          queryParameters: {'nickname': authResult.nickname},
        ).toString(),
      );
    } else {
      // 기존 회원: 홈으로 이동
      context.go(RoutePaths.home);
    }
  }

  /// 로그인 에러 SnackBar 표시
  void _showLoginError(
    ScaffoldMessengerState messenger,
    String fallbackMessage,
  ) {
    final authState = ref.read(authNotifierProvider);

    final errorMessage =
        (authState.hasError && authState.error is AuthException)
        ? (authState.error as AuthException).message
        : fallbackMessage;

    //TODO: 스낵바 나중에 디자인 만들어지면 바뀌어야함.
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(errorMessage, style: AppTextStyles.paragraph_14),
        backgroundColor: AppColors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  // 앱 로고
                  Image.asset(
                    'assets/app_icon_512.png',
                    width: 224.w,
                    height: 224.w,
                  ),

                  // 로고와 버튼 사이 간격 (플랫폼별)
                  SizedBox(height: Platform.isIOS ? 155.h : 185.h),

                  // Google 로그인 버튼
                  GoogleLoginButton(
                    onPressed: _isAppleLoading
                        ? null
                        : () => _handleGoogleSignIn(context),
                    isLoading: _isGoogleLoading,
                  ),

                  // iOS에서만 Apple 로그인 버튼 표시
                  if (Platform.isIOS) ...[
                    SizedBox(height: AppSpacing.vertical12),
                    AppleLoginButton(
                      onPressed: _isGoogleLoading
                          ? null
                          : () => _handleAppleSignIn(context),
                      isLoading: _isAppleLoading,
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
                      const TextSpan(text: '로그인 시 '),
                      TextSpan(
                        text: '개인정보 처리방침',
                        style: AppTextStyles.tag_12.copyWith(
                          color: AppColors.black600,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: _privacyRecognizer,
                      ),
                      const TextSpan(text: ' 및 '),
                      TextSpan(
                        text: '이용약관',
                        style: AppTextStyles.tag_12.copyWith(
                          color: AppColors.black600,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: _termsRecognizer,
                      ),
                      const TextSpan(text: '에 동의합니다'),
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
