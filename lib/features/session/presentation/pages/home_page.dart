import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../router/route_paths.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// 홈 화면
///
/// 게임 세션 생성 또는 참가를 선택할 수 있는 메인 화면입니다.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  /// 방 참여 다이얼로그 표시
  void _showJoinRoomDialog(BuildContext context) {
    final TextEditingController codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('방 참여하기'),
          content: TextField(
            controller: codeController,
            decoration: const InputDecoration(
              hintText: '초대 코드를 입력하세요',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.characters,
            maxLength: 6,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                final code = codeController.text.trim();
                if (code.isNotEmpty) {
                  Navigator.of(dialogContext).pop();
                  context.go(RoutePaths.waitingRoomWithId(code));
                }
              },
              child: const Text('참여'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          // 로그아웃 버튼
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: '로그아웃',
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).signOut();
              // GoRouter가 자동으로 LoginPage로 이동 (redirect 함수가 처리)
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: AppPadding.all20,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Home', style: AppTextStyles.heading01),
              SizedBox(height: AppSpacing.vertical64),
              ElevatedButton(
                onPressed: () => context.go(RoutePaths.selectArea),
                child: const Text('방 만들기'),
              ),
              SizedBox(height: AppSpacing.vertical20),
              ElevatedButton(
                onPressed: () => _showJoinRoomDialog(context),
                child: const Text('방 참여하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
