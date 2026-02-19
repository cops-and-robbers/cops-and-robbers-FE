import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/services/storage/session_draft_storage_service.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/buttons/svg_icon_button.dart';
import '../../../../core/widgets/speech_bubble.dart';
import '../../../../router/route_paths.dart';

/// 홈 화면
///
/// 게임 세션 생성 또는 참가를 선택할 수 있는 메인 화면입니다.
/// 디자인: LOGO + 설정, 공지/역할 아이콘, 말풍선, 아바타, 방만들기/참여하기 버튼
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  /// 방 만들기 버튼 클릭 시
  ///
  /// 이전 세션 생성 임시 데이터를 초기화한 후 세션 생성 플로우로 이동합니다.
  Future<void> _onCreateSession(BuildContext context) async {
    await SessionDraftStorageService().clearDraft();
    if (context.mounted) {
      context.go(RoutePaths.sessionCreationFlow);
    }
  }

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
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: AppPadding.horizontal20,
          child: Column(
            children: [
              SizedBox(height: AppSpacing.vertical16),

              // ── Top Bar: LOGO + Settings (좌우 24px) ──
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.horizontal4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'LOGO',
                      style: AppTextStyles.heading_20.copyWith(
                        color: AppColors.black,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        context.push(RoutePaths.settings);
                      },
                      child: SvgPicture.asset(
                        'assets/icons/icon_setting_1.svg',
                        width: 24.w,
                        height: 24.h,
                        colorFilter: const ColorFilter.mode(
                          AppColors.black800,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Middle Content (Expandable) ──
              Expanded(
                child: Column(
                  children: [
                    SizedBox(height: AppSpacing.vertical32),

                    // ── Icon Buttons Row (aligned right) ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SvgIconButton(
                          assetPath: 'assets/icons/Loudspeaker.svg',
                          onPressed: () {
                            // TODO: 공지사항 페이지 네비게이션 (별도 이슈에서 구현)
                          },
                        ),
                        SizedBox(width: AppSpacing.horizontal8),
                        SvgIconButton(
                          assetPath: 'assets/icons/Top_hat.svg',
                          onPressed: () {
                            // TODO: 역할 선택 또는 테마 관련 기능
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: AppSpacing.vertical48),

                    // ── Speech Bubble ──
                    const SpeechBubble(text: '너무 기대 돼\n이번에는 어떤 역할을 할까?'),

                    // ── Avatar Placeholder ──
                    Image.asset(
                      'assets/app_icon_512.png',
                      width: 223.w,
                      height: 260.h,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),

              // ── Bottom Buttons ──
              AppButton(
                text: '방 만들기',
                onPressed: () => _onCreateSession(context),
                showBorder: false,
              ),
              SizedBox(height: AppSpacing.vertical12),
              AppButton(
                text: '방 참여하기',
                onPressed: () => _showJoinRoomDialog(context),
                backgroundColor: AppColors.black100,
                foregroundColor: AppColors.black600,
                showBorder: false,
              ),
              SizedBox(height: AppSpacing.vertical20),
            ],
          ),
        ),
      ),
    );
  }
}
