import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../router/route_paths.dart';

/// Google 로그인 화면
///
/// Google Sign-In을 통해 사용자 인증을 수행합니다.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Login'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go(RoutePaths.home),
              child: const Text('홈으로 이동'),
            ),
          ],
        ),
      ),
    );
  }
}
