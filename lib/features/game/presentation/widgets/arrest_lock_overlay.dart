import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/character_assets.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../providers/game_event_provider.dart';
import 'game_action_modal.dart';
import 'package:cops_and_robbers/core/constants/game_team.dart';

/// 수감 버튼으로 여는 안내. 닫으면 지도 조작으로 돌아간다.
class ArrestLockOverlay extends ConsumerWidget {
  const ArrestLockOverlay({
    required this.gameId,
    required this.myParticipantId,
    required this.onClose,
    super.key,
  });

  /// 게임 ID
  final int gameId;

  /// 내 참가자 ID
  final int myParticipantId;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isEscapeInFlight = ref.watch(
      gameEventNotifierProvider.select((state) => state.isEscapeInFlight),
    );
    return Positioned.fill(
      child: Stack(
        fit: StackFit.expand,
        children: [
          ModalBarrier(
            color: AppColors.black.withValues(alpha: 0.4),
            onDismiss: onClose,
            semanticsLabel: l10n.buttonClose,
          ),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 중앙 모달 카드: width 320 고정, height는 내용에 맞춤
                // 고정 높이를 두면 영어/일본어처럼 줄바꿈 횟수가 늘어나는 로케일에서
                // 본문과 하단 버튼이 충돌해 overflow가 발생함 → 다국어 대응 위해 내용 기반 자동 확장
                Container(
                  width: 320.w,
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 24.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.black,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 도둑 수감 캐릭터
                      SizedBox(
                        width: 92.w,
                        height: 108.h,
                        child: SvgPicture.asset(
                          characterAssetPath(
                            team: GameTeam.toLowerKey(GameTeam.robber),
                            state: 'jailed',
                          ),
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        l10n.gameArrestOverlayTitle,
                        style: AppTextStyles.robberHeading.copyWith(
                          color: AppColors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        l10n.gameArrestOverlayMessage,
                        style: AppTextStyles.paragraph_14.copyWith(
                          color: AppColors.black400,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      // 본문 ↔ 버튼 사이 명시적 간격 (이전 spaceBetween 대체)
                      SizedBox(height: 24.h),

                      // 자동 감지 실패에 대비한 수동 탈옥 버튼
                      AppButton(
                        text: l10n.gameArrestOverlayEscapeCompleteButton,
                        width: 288.w,
                        height: 48.h,
                        backgroundColor: AppColors.green,
                        foregroundColor: AppColors.black,
                        textStyle: AppTextStyles.robberLabel,
                        isLoading: isEscapeInFlight,
                        onPressed: isEscapeInFlight
                            ? null
                            : () {
                                final arrestRevision = ref
                                    .read(gameEventNotifierProvider)
                                    .localArrestRevision;
                                // 확인창이 열린 사이 자동 탈옥으로 이 오버레이가 사라질 수 있다.
                                // 해제된 위젯의 ref를 쓰지 않도록 notifier를 미리 잡아 둔다.
                                final notifier = ref.read(
                                  gameEventNotifierProvider.notifier,
                                );
                                GameActionModal.show(
                                  context: context,
                                  title: l10n.buttonEscape,
                                  message: l10n.dialogEscapeAttemptMessage,
                                  confirmLabel: l10n.buttonEscape,
                                  isDarkMode: true,
                                  onConfirm: () => notifier.escape(
                                    gameId,
                                    myParticipantId,
                                    expectedArrestRevision: arrestRevision,
                                  ),
                                );
                              },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
