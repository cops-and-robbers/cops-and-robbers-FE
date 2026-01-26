import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../router/route_paths.dart';

/// 게임 종료 결과 화면
///
/// 게임 종료 후 승패 결과, 통계, MVP 등을 표시합니다.
class ResultsPage extends StatelessWidget {
  const ResultsPage({required this.sessionId, super.key});

  /// 게임 세션 ID
  final String sessionId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('게임 결과')),
      body: Center(
        child: Padding(
          padding: AppPadding.all20,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('게임 종료', style: AppTextStyles.heading_24),
              SizedBox(height: AppSpacing.vertical20),
              Text('Session ID: $sessionId', style: AppTextStyles.label_16),
              SizedBox(height: AppSpacing.vertical20),
              Text('게임 결과 통계', style: AppTextStyles.subHeading_18),
              SizedBox(height: AppSpacing.vertical64),
              ElevatedButton(
                onPressed: () => context.go(RoutePaths.home),
                child: const Text('홈으로 나가기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
