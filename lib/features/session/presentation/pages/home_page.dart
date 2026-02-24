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
import '../../../../core/widgets/dialogs/app_dialog.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../../../../core/widgets/speech_bubble.dart';
import '../../../../router/route_paths.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/game_participant_provider.dart';
import '../providers/session_provider.dart';

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

  /// [임시] 게임 퇴장 다이얼로그
  void _showLeaveGameDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();

    AppDialog.show(
      context: context,
      title: '게임 퇴장',
      customContent: AppTextField(
        controller: controller,
        hintText: 'Game ID를 입력하세요',
        keyboardType: TextInputType.number,
      ),
      cancelText: '취소',
      confirmText: '퇴장',
      validator: () => controller.text.trim().isNotEmpty,
      onConfirm: () async {
        final gameId = int.tryParse(controller.text.trim());
        if (gameId == null || gameId < 1) return;

        final result = await ref.read(leaveGameProvider(gameId).future);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result != null ? '게임 $gameId 퇴장 완료' : '게임 $gameId 퇴장 실패',
              ),
            ),
          );
        }
      },
    );
  }

  /// 방 참여 다이얼로그 표시
  void _showJoinRoomDialog(BuildContext context, WidgetRef ref) {
    final codeController = TextEditingController();

    AppDialog.show(
      context: context,
      title: '방 참여하기',
      customContent: AppTextField(
        controller: codeController,
        hintText: '참여코드를 입력하세요',
        maxLength: 6,
      ),
      cancelText: '취소',
      confirmText: '참여하기',
      validator: () => codeController.text.trim().length == 6,
      onConfirm: () async {
        final code = codeController.text.trim();
        final response = await ref.read(
          joinGameProvider(inviteCode: code).future,
        );

        if (response != null && context.mounted) {
          final myNickname =
              ref.read(authNotifierProvider).value?.nickname ?? '';
          // TODO(로비 조회 API): 현재 joinGame 응답에는 gameId, participantId만 포함됨.
          // 로비 조회 API 연동 후 아래 항목들도 설정 필요:
          //   - maxParticipants: 팀별 최대 인원 계산에 사용 (현재 참가자는 기본값 10 적용)
          //   - locationRevealIntervalMinutes: 게임 규칙 다이얼로그에 표시
          //   - nickname: 현재는 authNotifierProvider에서 읽으나, 로비 API로 검증 가능
          ref
              .read(gameParticipantNotifierProvider.notifier)
              .setGameInfo(
                gameId: response.gameId,
                nickname: myNickname,
                participantId: response.participantId,
                isHost: false,
              );
          context.go(
            '${RoutePaths.waitingRoomWithId('${response.gameId}')}?inviteCode=$code',
          );
        } else if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('참여에 실패했습니다. 초대 코드를 확인해주세요.')),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: false,
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
                            context.push(RoutePaths.notices);
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
                onPressed: () => _showJoinRoomDialog(context, ref),
                backgroundColor: AppColors.black100,
                foregroundColor: AppColors.black600,
                showBorder: false,
              ),
              // ── [임시] 디버그 버튼들 ──
              SizedBox(height: AppSpacing.vertical12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => _showLeaveGameDialog(context, ref),
                    child: Text(
                      '[임시] 퇴장',
                      style: AppTextStyles.tag_12.copyWith(
                        color: AppColors.black400,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.horizontal16),
                  GestureDetector(
                    onTap: () =>
                        context.go(RoutePaths.waitingRoomWithId('A1B2C3')),
                    child: Text(
                      '[임시] 대기실 UI',
                      style: AppTextStyles.tag_12.copyWith(
                        color: AppColors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.vertical20),
            ],
          ),
        ),
      ),
    );
  }
}
