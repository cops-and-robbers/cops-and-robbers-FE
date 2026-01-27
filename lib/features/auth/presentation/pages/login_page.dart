import 'dart:io';

import 'package:cops_and_robbers/core/constants/app_colors.dart';
import 'package:cops_and_robbers/test_widget_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/buttons/social_login_button.dart';
import '../../../../router/route_paths.dart';
import '../providers/auth_provider.dart';

/// Google 로그인 화면
///
/// Google Sign-In을 통해 사용자 인증을 수행합니다.
class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  /// Google 로그인 버튼 핸들러
  ///
  /// Google 로그인을 수행하고 에러 발생 시 SnackBar를 표시합니다.
  Future<void> _handleGoogleSignIn(BuildContext context, WidgetRef ref) async {
    // AuthNotifier로 로그인 수행
    await ref.read(authNotifierProvider.notifier).signInWithGoogle();

    // 에러 체크 및 SnackBar 표시
    if (!context.mounted) return;

    final authState = ref.read(authNotifierProvider);

    if (authState.hasError) {
      final errorMessage = authState.error is AuthException
          ? (authState.error as AuthException).message
          : '로그인 중 오류가 발생했습니다.';

      //TODO: 스낵바 나중에 디자인 만들어지면 바뀌어야함.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage, style: AppTextStyles.paragraph_14),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }

    // 성공 시 GoRouter가 자동으로 HomePage로 리다이렉트
  }

  /// Apple 로그인 버튼 핸들러
  ///
  /// Apple 로그인을 수행하고 에러 발생 시 SnackBar를 표시합니다.
  Future<void> _handleAppleSignIn(BuildContext context, WidgetRef ref) async {
    // AuthNotifier로 로그인 수행
    await ref.read(authNotifierProvider.notifier).signInWithApple();

    // 에러 체크 및 SnackBar 표시
    if (!context.mounted) return;

    final authState = ref.read(authNotifierProvider);

    if (authState.hasError) {
      final errorMessage = authState.error is AuthException
          ? (authState.error as AuthException).message
          : 'Apple 로그인 중 오류가 발생했습니다.';

      //TODO: 스낵바 나중에 디자인 만들어지면 바뀌어야함.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage, style: AppTextStyles.paragraph_14),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }

    // 성공 시 GoRouter가 자동으로 HomePage로 리다이렉트
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: Text('Login', style: AppTextStyles.subHeading_18),
        // ⚠️ 개발용 버튼 - 프로덕션 배포 전 제거 필요
        actions: [
          // 생명주기 테스트 화면 이동
          IconButton(
            icon: const Icon(Icons.pending_actions),
            tooltip: 'Lifecycle Test',
            onPressed: () {
              context.push(RoutePaths.lifecycleTest);
            },
          ),
          // 폰트 테스트 화면 이동
          IconButton(
            icon: const Icon(Icons.widgets),
            tooltip: 'Test Widget',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TestWidgetPage()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Login', style: AppTextStyles.heading_24),
            SizedBox(height: AppSpacing.vertical40),

            // Google 로그인 버튼
            GoogleLoginButton(
              onPressed: () => _handleGoogleSignIn(context, ref),
              isLoading: authState.isLoading,
            ),
            SizedBox(height: AppSpacing.vertical12),

            // iOS에서만 Apple 로그인 버튼 표시
            if (Platform.isIOS) ...[
              // Apple 로그인 버튼
              AppleLoginButton(
                onPressed: () => _handleAppleSignIn(context, ref),
                isLoading: authState.isLoading,
              ),
              SizedBox(height: AppSpacing.vertical12),
            ],

            // 에러 메시지 (선택사항 - SnackBar와 중복이므로 간단하게 표시)
            if (authState.hasError && !authState.isLoading)
              Padding(
                padding: EdgeInsets.only(
                  top: AppSpacing.vertical12,
                  left: AppSpacing.horizontal20,
                  right: AppSpacing.horizontal20,
                ),
                child: Text(
                  authState.error is AuthException
                      ? (authState.error as AuthException).message
                      : '로그인에 실패했습니다.',
                  style: AppTextStyles.paragraph_14.copyWith(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
