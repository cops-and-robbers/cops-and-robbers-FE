import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../lobby/data/models/lobby_event_dto.dart';

/// 참가자 카드 위젯
///
/// 대기실 팀 섹션 내 참가자를 표시합니다.
/// 아바타(72x84) + 닉네임, 방장은 왕관 아이콘 표시.
class ParticipantCard extends StatelessWidget {
  const ParticipantCard({
    required this.participant,
    this.isHost = false,
    this.onTap,
    this.isDarkMode = false,
    super.key,
  });

  final LobbyParticipantInfo participant;
  final bool isHost;

  /// 카드 탭 콜백 (null이면 탭 비활성화)
  final VoidCallback? onTap;

  /// 다크 모드 여부
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 아바타 영역 (72x84)
          SizedBox(
            width: 72.w,
            height: 84.h,
            child: Container(
              decoration: BoxDecoration(
                color: _avatarColor,
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Center(
                child: Icon(Icons.person, color: AppColors.white, size: 32.w),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.vertical4),
          // 닉네임 (방장은 왕관 아이콘)
          SizedBox(
            width: 72.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isHost) ...[
                  SvgPicture.asset(
                    'assets/icons/icon_crown.svg',
                    width: 12.w,
                    height: 12.w,
                  ),
                  SizedBox(width: 4.w),
                ],
                Flexible(
                  child: Text(
                    participant.nickname,
                    style: AppTextStyles.tag_10.copyWith(
                      color: isDarkMode
                          ? AppColors.black300
                          : AppColors.black800,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color get _avatarColor {
    if (isHost) return AppColors.black600;
    return participant.isReady ? AppColors.black600 : AppColors.black300;
  }
}

/// 빈 슬롯 카드 위젯
///
/// 대기실 팀 섹션 내 비어 있는 참가자 슬롯을 표시합니다.
class EmptySlotCard extends StatelessWidget {
  const EmptySlotCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 72.w,
          height: 84.h,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.black100,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Center(
              child: Text(
                '대기 중',
                style: AppTextStyles.tag_12.copyWith(color: AppColors.black400),
              ),
            ),
          ),
        ),
        SizedBox(height: AppSpacing.vertical4),
        // 닉네임 영역 높이 맞춤용
        SizedBox(width: 72.w, height: AppTextStyles.tag_10.fontSize),
      ],
    );
  }
}

/// + 버튼 슬롯 카드 위젯
///
/// 대기실 팀 섹션 첫 번째 칸에 표시되며, 탭 시 해당 팀으로 변경합니다.
class AddSlotCard extends StatelessWidget {
  const AddSlotCard({this.onTap, this.isDarkMode = false, super.key});

  /// 카드 탭 콜백 (팀 변경 트리거)
  final VoidCallback? onTap;

  /// 다크 모드 여부
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 72.w,
            height: 84.h,
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.black800 : AppColors.black100,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/plus.svg',
                  width: 17.w,
                  height: 17.w,
                  colorFilter: ColorFilter.mode(
                    isDarkMode ? AppColors.black400 : AppColors.black300,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.vertical4),
          // 닉네임 영역 높이 맞춤용
          SizedBox(width: 72.w, height: AppTextStyles.tag_10.fontSize),
        ],
      ),
    );
  }
}
