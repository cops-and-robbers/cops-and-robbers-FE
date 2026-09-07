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

/// 도둑 체포 시 화면 잠금 오버레이
///
/// - 배경: black 40% 반투명 → 지도·AppBar·우측 버튼 터치 차단
/// - 중앙: 불투명 모달 카드 (아바타 + 체포 메시지)
/// - 하단: GPS 문제에 대비한 수동 탈옥 버튼
/// - 채팅은 이 오버레이 위(Stack index 7)에 렌더링되어 사용 가능
class ArrestLockOverlay extends ConsumerWidget {
  const ArrestLockOverlay({
    required this.gameId,
    required this.myParticipantId,
    super.key,
  });

  /// 게임 ID
  final int gameId;

  /// 내 참가자 ID
  final int myParticipantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isEscapeInFlight = ref.watch(
      gameEventNotifierProvider.select((state) => state.isEscapeInFlight),
    );
    return Positioned.fill(
      child: Container(
        // 배경: black 40% 반투명 딤 처리
        color: AppColors.black.withValues(alpha: 0.4),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 중앙 모달 카드: width 320 고정, height는 내용에 맞춤
              // 고정 높이를 두면 영어/일본어처럼 줄바꿈 횟수가 늘어나는 로케일에서
              // 본문과 하단 버튼이 충돌해 overflow가 발생함 → 다국어 대응 위해 내용 기반 자동 확장
              Container(
                width: 320.w,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 24.h),
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
                              GameActionModal.show(
                                context: context,
                                title: l10n.buttonEscape,
                                message: l10n.dialogEscapeAttemptMessage,
                                confirmLabel: l10n.buttonEscape,
                                isDarkMode: true,
                                onConfirm: () => ref
                                    .read(gameEventNotifierProvider.notifier)
                                    .escape(
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
      ),
    );
  }
}
