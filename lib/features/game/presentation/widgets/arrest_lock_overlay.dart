import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/character_assets.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../providers/game_event_provider.dart';
import 'game_action_modal.dart';

/// 도둑 체포 시 화면 잠금 오버레이
///
/// - 배경: black 40% 반투명 → 지도·AppBar·우측 버튼 터치 차단
/// - 중앙: 불투명 모달 카드 (아바타 + 체포 메시지 + 안내/버튼)
/// - 채팅은 이 오버레이 위(Stack index 7)에 렌더링되어 사용 가능
///
/// **평시(자동) 모드**: GPS 기반 자동 탈옥 안내 문구만 표시. 수동 버튼 없음.
/// **폴백 모드** ([showManualFallback] == true): 자동 탈옥 API가 실패한 경우에만
/// 노출되며, 기존 "탈옥 완료" 버튼과 [GameActionModal] 확인 다이얼로그 흐름을
/// 그대로 사용해 사용자가 직접 탈출할 수 있는 안전망.
class ArrestLockOverlay extends ConsumerWidget {
  const ArrestLockOverlay({
    required this.gameId,
    required this.myParticipantId,
    this.showManualFallback = false,
    super.key,
  });

  /// 게임 ID
  final int gameId;

  /// 내 참가자 ID
  final int myParticipantId;

  /// 자동 탈옥 API 실패 후 폴백 버튼/안내를 노출할지 여부
  final bool showManualFallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Positioned.fill(
      child: Container(
        // 배경: black 40% 반투명 딤 처리
        color: AppColors.black.withValues(alpha: 0.4),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 중앙 모달 카드: 320 x 304, black
              Container(
                width: 320.w,
                height: 304.h,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 24.h),
                decoration: BoxDecoration(
                  color: AppColors.black,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 아바타 + 텍스트
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 도둑 수감 캐릭터 — 스킨 default 고정
                        // (다른 참가자 카드에도 동일하게 jailed 상태가 표시되므로 본인 오버레이도 동일 에셋 사용)
                        SizedBox(
                          width: 92.w,
                          height: 108.h,
                          child: SvgPicture.asset(
                            characterAssetPath(team: 'robber', state: 'jailed'),
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Text(
                          '체포되었어요!',
                          style: AppTextStyles.robberHeading.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          showManualFallback
                              ? '자동 탈옥 처리에 실패했어요.\n직접 탈출하시겠어요?'
                              : '감옥 영역에 들어갔다가 다시 벗어나면\n자동으로 탈옥됩니다',
                          style: AppTextStyles.paragraph_14.copyWith(
                            color: AppColors.black300,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    // 폴백 모드: 수동 탈옥 버튼 노출
                    // 평시 모드: 자리 유지를 위한 빈 SizedBox (spaceBetween 레이아웃 유지)
                    if (showManualFallback)
                      AppButton(
                        text: '탈옥 완료',
                        width: 288.w,
                        height: 48.h,
                        borderRadius: AppRadius.medium,
                        backgroundColor: AppColors.green,
                        foregroundColor: AppColors.black,
                        showBorder: false,
                        textStyle: AppTextStyles.robberLabel,
                        onPressed: () {
                          GameActionModal.show(
                            context: context,
                            title: '탈옥',
                            message: '탈옥하시겠습니까?',
                            confirmLabel: '탈옥',
                            isDarkMode: true,
                            onConfirm: () => ref
                                .read(gameEventNotifierProvider.notifier)
                                .escape(gameId, myParticipantId),
                          );
                        },
                      )
                    else
                      SizedBox(height: 48.h),
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
