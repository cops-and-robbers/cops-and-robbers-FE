import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';

/// 플레이그라운드 구역 설정 화면
///
/// 지도에서 게임이 진행될 플레이그라운드 범위를 지정합니다.
class SetupPlaygroundPage extends StatelessWidget {
  const SetupPlaygroundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('플레이그라운드 설정')),
      body: Center(
        child: Padding(
          padding: AppPadding.all20,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('플레이그라운드 구역', style: AppTextStyles.heading02),
              SizedBox(height: AppSpacing.vertical20),
              const Text('지도에서 플레이그라운드 범위를 지정하세요'),
              SizedBox(height: AppSpacing.vertical40),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('설정 완료'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
