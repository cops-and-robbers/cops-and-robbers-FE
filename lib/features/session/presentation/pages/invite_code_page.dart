import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../router/route_paths.dart';

/// 초대 코드 생성 및 공유 화면
///
/// 생성된 게임 세션의 초대 코드를 표시하고 공유합니다.
class InviteCodePage extends StatelessWidget {
  const InviteCodePage({super.key});

  static const String inviteCode = 'A1B2C3';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('초대 코드')),
      body: Center(
        child: Padding(
          padding: AppPadding.all20,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('방이 생성되었습니다!', style: AppTextStyles.heading02),
              SizedBox(height: AppSpacing.vertical40),
              Container(
                padding: AppPadding.all24,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 2),
                  borderRadius: AppRadius.large,
                ),
                child: Text(inviteCode, style: AppTextStyles.inviteCode),
              ),
              SizedBox(height: AppSpacing.vertical20),
              const Text('이 코드를 친구들에게 공유하세요'),
              SizedBox(height: AppSpacing.vertical40),
              ElevatedButton(
                onPressed: () =>
                    context.go(RoutePaths.waitingRoomWithId(inviteCode)),
                child: const Text('대기실 입장'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
