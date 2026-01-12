import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../router/route_paths.dart';

/// 앱 시작 시 초기 화면
///
/// 2초간 Splash 화면을 표시한 후 자동으로 적절한 화면으로 리다이렉트합니다.
/// - 비인증: login 화면으로 이동
/// - 인증 + 온보딩 미완료: onboarding 화면으로 이동
/// - 인증 + 온보딩 완료: home 화면으로 이동
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  /// 2초 후 다음 화면으로 자동 이동
  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 2));

    // Widget이 여전히 마운트되어 있는지 확인 (메모리 누수 방지)
    if (!mounted) return;

    // TODO: 인증 상태에 따라 분기 처리
    // 현재는 무조건 로그인 화면으로 이동
    // 향후 Auth Provider 구현 후 다음과 같이 분기:
    // - 비인증 → login
    // - 인증 + 온보딩 미완료 → onboarding
    // - 인증 + 온보딩 완료 → home
    context.go(RoutePaths.login);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Splash')));
  }
}
