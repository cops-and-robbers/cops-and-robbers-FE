import 'package:cops_and_robbers/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/services/storage/session_draft_storage_service.dart';
import '../../../../router/route_paths.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/session_provider.dart';

/// 홈 화면
///
/// 게임 세션 생성 또는 참가를 선택할 수 있는 메인 화면입니다.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  /// 방 만들기 버튼 클릭 시
  ///
  /// 이전 세션 생성 임시 데이터를 초기화한 후 세션 생성 플로우로 이동합니다.
  Future<void> _onCreateSession(BuildContext context) async {
    // 1. 이전 임시 저장 데이터 초기화
    await SessionDraftStorageService().clearDraft();

    // 2. 세션 생성 플로우 시작 (새 PageView 기반 플로우)
    if (context.mounted) {
      context.go(RoutePaths.sessionCreationFlow);
    }
  }

  /// 방 참여 다이얼로그 표시
  void _showJoinRoomDialog(BuildContext context, WidgetRef ref) {
    final TextEditingController codeController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                enabled: !isLoading,
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.of(dialogContext).pop(),
                  child: const Text('취소'),
                ),
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          final code = codeController.text.trim();
                          if (code.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('초대 코드를 입력해주세요.')),
                            );
                            return;
                          }

                          setState(() => isLoading = true);

                          // 참여 API 호출
                          final response = await ref.read(
                            joinGameProvider(inviteCode: code).future,
                          );

                          if (response != null) {
                            // 성공: 대기실로 이동
                            if (dialogContext.mounted) {
                              Navigator.of(dialogContext).pop();
                            }
                            if (context.mounted) {
                              context.go(RoutePaths.waitingRoomWithId('${response.gameId}'));
                            }
                          } else {
                            // 실패
                            setState(() => isLoading = false);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('참여에 실패했습니다. 초대 코드를 확인해주세요.')),
                              );
                            }
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('참여'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
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
              Text('Home', style: AppTextStyles.heading_24),
              SizedBox(height: AppSpacing.vertical64),
              ElevatedButton(
                onPressed: () => _onCreateSession(context),
                child: const Text('방 만들기'),
              ),
              SizedBox(height: AppSpacing.vertical20),
              ElevatedButton(
                onPressed: () => _showJoinRoomDialog(context, ref),
                child: const Text('방 참여하기'),
              ),
              SizedBox(height: AppSpacing.vertical64),
              // 개발 전용: 생명주기 테스트 버튼
              OutlinedButton.icon(
                onPressed: () => context.push(RoutePaths.lifecycleTest),
                icon: const Icon(Icons.bug_report, size: 16),
                label: const Text('생명주기 테스트', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey,
                  side: const BorderSide(color: Colors.grey),
                ),
              ),
              // ============================================================
              // TODO: 임시 디버그 버튼 (게임 1~20 강제 퇴장)
              // ============================================================
              const SizedBox(height: 16),
                OutlinedButton.icon(
                onPressed: () async {
                  debugPrint('[DEBUG] 게임 1~20 강제 퇴장 시작...');
                  for (int gameId = 1; gameId <= 20; gameId++) {
                    try {
                      await ref.read(leaveGameProvider(gameId).future);
                      debugPrint('[DEBUG] 게임 $gameId 퇴장 완료');
                    } catch (e) {
                      debugPrint('[DEBUG] 게임 $gameId 퇴장 실패: $e');
                    }
                  }
                  debugPrint('[DEBUG] 강제 퇴장 완료!');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('게임 1~20 퇴장 완료!')),
                    );
                  }
                },
                icon: const Icon(Icons.exit_to_app, size: 16, color: Colors.red),
                label: const Text(
                  '[임시] 게임 1~20 강제 퇴장',
                  style: TextStyle(fontSize: 12, color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                ),
              ),
              // ============================================================
            ],
          ),
        ),
      ),
    );
  }
}
