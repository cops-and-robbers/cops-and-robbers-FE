import 'package:flutter/material.dart';

/// 첫 로그인 시 온보딩 화면
///
/// 이용약관 동의 및 닉네임 설정을 수행합니다.
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Onboarding')),
      body: const Center(child: Text('Onboarding')),
    );
  }
}
