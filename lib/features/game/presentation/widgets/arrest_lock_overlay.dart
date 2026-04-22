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
/// - 중앙: 불투명 모달 카드 (아바타 + 체포 메시지)
/// - 하단: "탈옥 완료" 버튼 → [GameActionModal] → [GameEventNotifier.escape]
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
                          '체포되어 있는 동안에는 게임 상황을 확인할 수 없어요\n같은 팀에게 구조 요청을 하며 빠르게 탈옥해요!',
                          style: AppTextStyles.paragraph_14.copyWith(
                            color: AppColors.black300,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),

                    // 탈옥 완료 버튼: 288 x 48, green
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
