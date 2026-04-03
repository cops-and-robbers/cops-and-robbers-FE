import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../constants/app_colors.dart';
import '../../constants/spacing_and_radius.dart';

/// 참가자 목록 로딩 중 shimmer 스켈레톤
///
/// 대기방(waiting_room_page)과 인게임 참가자 오버레이(participant_overlay) 공용.
/// 팀 헤더 2개 + 카드 4개×2행 플레이스홀더를 shimmer 효과로 표시한다.
class ShimmerParticipantSkeleton extends StatelessWidget {
  const ShimmerParticipantSkeleton({this.isDarkMode = false, super.key});

  final bool isDarkMode;

  /// 한 줄에 표시할 카드 수
  static const int _cardsPerRow = 4;

  @override
  Widget build(BuildContext context) {
    final baseColor = isDarkMode ? AppColors.black800 : AppColors.black100;
    final highlightColor = isDarkMode ? AppColors.black600 : AppColors.black200;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Padding(
        padding: AppPadding.horizontal20.copyWith(
          top: AppSpacing.vertical16,
          bottom: AppSpacing.vertical16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTeamHeader(baseColor),
            SizedBox(height: AppSpacing.vertical16),
            _buildCardSkeletonRow(baseColor),
            SizedBox(height: AppSpacing.vertical24),
            _buildTeamHeader(baseColor),
            SizedBox(height: AppSpacing.vertical16),
            _buildCardSkeletonRow(baseColor),
          ],
        ),
      ),
    );
  }

  /// 팀 헤더 플레이스홀더
  Widget _buildTeamHeader(Color color) {
    return Container(
      width: 80.w,
      height: AppSpacing.vertical16,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4.r),
      ),
    );
  }

  /// 카드 스켈레톤 한 줄
  Widget _buildCardSkeletonRow(Color color) {
    return Row(
      children: List.generate(_cardsPerRow, (i) {
        return Padding(
          padding: EdgeInsets.only(
            right: i < _cardsPerRow - 1 ? AppSpacing.horizontal12 : 0,
          ),
          child: Column(
            children: [
              // 아바타 플레이스홀더 (72x84)
              Container(
                width: 72.w,
                height: 84.h,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              SizedBox(height: AppSpacing.vertical4),
              // 닉네임 플레이스홀더
              Container(
                width: 48.w,
                height: 10.h,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
