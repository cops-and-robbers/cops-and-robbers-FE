import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../font_test_page.dart'; // ⚠️ 임시 개발용 - 테스트 후 제거 필요
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
          content: Text(errorMessage, style: AppTextStyles.toast),
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
          content: Text(errorMessage, style: AppTextStyles.toast),
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
      appBar: AppBar(
        title: Text('Login', style: AppTextStyles.subHeading),
        // ⚠️ 개발용 버튼 - 프로덕션 배포 전 제거 필요
        actions: [
          IconButton(
            icon: const Icon(Icons.text_fields),
            tooltip: 'Font Test',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FontTestPage()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Login', style: AppTextStyles.heading01),
            SizedBox(height: AppSpacing.vertical40),

            // TODO: Google 로그인 버튼 디자인 만들어지면 바뀌어야함
            ElevatedButton.icon(
              onPressed: authState.isLoading
                  ? null // 로딩 중에는 버튼 비활성화
                  : () => _handleGoogleSignIn(context, ref),
              icon: const Icon(Icons.login),
              label: const Text('Google 로그인'),
              style: ElevatedButton.styleFrom(
                padding: AppPadding.buttonPadding,
                textStyle: AppTextStyles.label,
              ),
            ),

            // iOS에서만 Apple 로그인 버튼 표시
            if (Platform.isIOS) ...[
              SizedBox(height: AppSpacing.vertical16),
              // TODO: Apple 로그인 버튼 디자인 만들어지면 바뀌어야함
              ElevatedButton.icon(
                onPressed: authState.isLoading
                    ? null // 로딩 중에는 버튼 비활성화
                    : () => _handleAppleSignIn(context, ref),
                icon: const Icon(Icons.apple),
                label: const Text('Apple 로그인'),
                style: ElevatedButton.styleFrom(
                  padding: AppPadding.buttonPadding,
                  textStyle: AppTextStyles.label,
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
              ),
            ],

            // 로딩 인디케이터
            if (authState.isLoading)
              Padding(
                padding: EdgeInsets.only(top: AppSpacing.vertical20),
                child: const CircularProgressIndicator(),
              ),

            // 에러 메시지 (선택사항 - SnackBar와 중복이므로 간단하게 표시)
            if (authState.hasError && !authState.isLoading)
              Padding(
                padding: EdgeInsets.only(
                  top: AppSpacing.vertical20,
                  left: AppSpacing.horizontal20,
                  right: AppSpacing.horizontal20,
                ),
                child: Text(
                  authState.error is AuthException
                      ? (authState.error as AuthException).message
                      : '로그인에 실패했습니다.',
                  style: AppTextStyles.paragraph.copyWith(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
