import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/buttons/social_login_button.dart';
import '../../../../router/route_paths.dart';
import '../../../../test_widget_page.dart';
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

  /// Google 로그인 버튼 핸들러
  ///
  /// Google 로그인을 수행하고 에러 발생 시 SnackBar를 표시합니다.
  Future<void> _handleGoogleSignIn(BuildContext context) async {
    // 로딩 시작
    setState(() => _isGoogleLoading = true);

    try {
      // AuthNotifier로 로그인 수행
      await ref.read(authNotifierProvider.notifier).signInWithGoogle();

      // 성공 시 GoRouter가 자동으로 HomePage로 리다이렉트
    } catch (e) {
      // AuthNotifier에서 rethrow한 에러를 여기서 처리
      if (!mounted) return;

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
    // 로딩 시작
    setState(() => _isAppleLoading = true);

    try {
      // AuthNotifier로 로그인 수행
      await ref.read(authNotifierProvider.notifier).signInWithApple();

      // 성공 시 GoRouter가 자동으로 HomePage로 리다이렉트
    } catch (e) {
      // AuthNotifier에서 rethrow한 에러를 여기서 처리
      if (!mounted) return;

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
    } finally {
      // 로딩 종료 (에러 발생 시에도 반드시 실행)
      if (mounted) {
        setState(() => _isAppleLoading = false);
      }
    }
  }

  /// 개발자 도구 메뉴 표시
  ///
  /// 생명주기 테스트와 위젯 테스트 페이지로 이동할 수 있는 다이얼로그를 표시합니다.
  /// 개발 모드(kDebugMode)에서만 동작합니다.
  void _showDevMenu(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('개발자 도구', style: AppTextStyles.heading_20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.pending_actions),
              title: Text('Lifecycle Test', style: AppTextStyles.paragraph_14),
              onTap: () {
                Navigator.pop(context);
                context.push(RoutePaths.lifecycleTest);
              },
            ),
            ListTile(
              leading: const Icon(Icons.widgets),
              title: Text('Test Widget', style: AppTextStyles.paragraph_14),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TestWidgetPage(),
                  ),
                );
              },
            ),
          ],
        ),
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
                    SizedBox(height: 12.h),
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

            // 에러 메시지 (선택사항 - SnackBar와 중복이므로 간단하게 표시)
          ],
        ),
      ),

      // 개발 모드에서만 개발자 도구 버튼 표시
      floatingActionButton: kDebugMode
          ? FloatingActionButton(
              mini: true,
              backgroundColor: AppColors.black.withValues(alpha: 0.7),
              foregroundColor: AppColors.white,
              onPressed: () => _showDevMenu(context),
              child: const Icon(Icons.bug_report),
            )
          : null,
    );
  }
}
