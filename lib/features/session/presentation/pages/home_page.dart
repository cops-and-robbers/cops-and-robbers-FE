import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
import '../../../../core/widgets/dialogs/dialog_animation.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../../../../core/widgets/speech_bubble.dart';
import '../../../../router/route_paths.dart';
import '../../../../test_widget_page.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/game_participant_provider.dart';
import '../../data/models/join_game_response.dart';
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

  /// 개발자 도구 메뉴 표시
  void _showDevMenu(BuildContext context) {
    AppDialog.show(
      context: context,
      title: '개발자 도구',
      showButtons: false,
      customContent: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.pending_actions),
            title: Text('Lifecycle Test', style: AppTextStyles.paragraph_14),
            onTap: () {
              Navigator.pop(context);
              context.push(RoutePaths.lifecycleTest);
            },
          ),
          ListTile(
            leading: const Icon(Icons.widgets),
            title: Text('Test Widget', style: AppTextStyles.paragraph_14),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TestWidgetPage()),
              );
            },
          ),
        ],
      ),
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
      cancelText: '닫기',
      confirmText: '참여하기',
      validator: () => codeController.text.trim().length == 6,
      onConfirm: () async {
        // AppDialog가 pop() 직후 이 콜백을 실행하므로,
        // 다이얼로그 닫힘 애니메이션(250ms)이 완료되기 전에 context.go()가 호출되면
        // Duplicate GlobalKeys 오류가 발생할 수 있습니다.
        // pop() 호출 시각을 기록하여 필요한 나머지 시간만 대기합니다.
        final dialogCloseStart = DateTime.now();
        final code = codeController.text.trim();

        JoinGameResponse? response;
        try {
          response = await ref.read(joinGameProvider(inviteCode: code).future);
        } on DioException catch (e) {
          if (e.response?.statusCode == 409 && context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('이미 참가 중인 게임입니다.')));
          }
          return;
        }

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
          // 다이얼로그 닫힘 애니메이션 완료 + overlay cleanup frame 대기
          // transitionDuration(250ms) 이후 Flutter는 다음 frame에서 OverlayEntry를
          // 실제로 제거한다. 정확히 250ms에 context.go()를 호출하면 cleanup frame 전에
          // GoRouter가 _Theater를 rebuild하여 Duplicate GlobalKey 충돌이 발생한다.
          // +32ms(~2 frames)를 추가하여 cleanup이 완료된 이후에 네비게이션을 수행한다.
          final elapsed = DateTime.now().difference(dialogCloseStart);
          final remaining =
              DialogAnimation.duration +
              const Duration(milliseconds: 32) -
              elapsed;
          if (remaining > Duration.zero) {
            await Future.delayed(remaining);
          }
          if (context.mounted) {
            context.go(
              '${RoutePaths.waitingRoomWithId('${response.gameId}')}?inviteCode=$code',
            );
          }
        } else if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('참여에 실패했습니다. 초대 코드를 확인해주세요.')),
          );
        }
      },
    ).whenComplete(() {
      // 다이얼로그 닫힘 애니메이션(250ms) 완료 후 dispose
      // whenComplete는 pop() 직후 실행되므로 즉시 dispose하면
      // 아직 애니메이션 중인 AppTextField가 disposed controller를 참조해 에러 발생
      Future.delayed(
        DialogAnimation.duration + const Duration(milliseconds: 50),
        codeController.dispose,
      );
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: false,

      // floatingActionButton: kDebugMode
      // ? FloatingActionButton(
      //     mini: true,
      //     backgroundColor: AppColors.black.withValues(alpha: 0.7),
      //     foregroundColor: AppColors.white,
      //     onPressed: () => _showDevMenu(context),
      //     child: const Icon(Icons.bug_report),
      //   )
      // : null,

      // 개발자 도구 버튼 (디버그 모드에서만 표시)
      floatingActionButton: kDebugMode
          ? FloatingActionButton(
              mini: true,
              backgroundColor: AppColors.black.withValues(alpha: 0.7),
              foregroundColor: AppColors.white,
              onPressed: () => _showDevMenu(context),
              child: const Icon(Icons.bug_report),
            )
          : null,

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
              SizedBox(height: AppSpacing.vertical20),
            ],
          ),
        ),
      ),
    );
  }
}
