import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/community_post_entity.dart';
import '../../domain/entities/community_post_status.dart';

/// 커뮤니티 모집글 카드
///
/// 높이 98은 고정이 아니라 최소값이다 — 시스템 글자 크기를 키우면 넘치는데,
/// 박아두면 그때 글자가 경고 없이 잘린다 (`NoticeCard`와 같은 판단).
/// 98 = padding 16×2 + 칩 18 + 12 + 위치 14 + 8 + 메타 14.
///
/// 하트·북마크는 표시 전용이다. 토글은 상세 화면에서 한다.
class CommunityPostCard extends StatelessWidget {
  const CommunityPostCard({super.key, required this.post, this.onTap});

  final CommunityPostEntity post;

  /// 상세 화면이 생기면 연결한다. 지금은 null.
  final VoidCallback? onTap;

  /// 주소 미제공 시 숨겨지는 행 — 테스트에서 존재 여부를 확인한다.
  static const Key locationRowKey = Key('community_post_card_location_row');

  /// 마감 시 흐려지는 콘텐츠 래퍼 — 테스트에서 opacity를 확인한다.
  static const Key contentOpacityKey = Key('community_post_card_content');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isCompleted = post.status == CommunityPostStatus.completed;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(minHeight: 98.h),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.horizontal22,
          vertical: AppSpacing.vertical16,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.large,
          boxShadow: AppShadows.ver2,
        ),
        // 마감은 콘텐츠만 흐린다. 카드째 감싸면 그림자까지 흐려져 배경에 묻힌다.
        child: Opacity(
          key: contentOpacityKey,
          opacity: isCompleted ? 0.6 : 1.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTitleRow(),
              SizedBox(height: AppSpacing.vertical12),
              // 주소는 백엔드 추가 예정. 좌표만 있는 상태에서는 행 자체를 숨긴다.
              if (post.address != null) ...[
                _buildLocationRow(post.address!),
                SizedBox(height: AppSpacing.vertical8),
              ],
              _buildMetaRow(l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleRow() {
    return Row(
      children: [
        _StatusChip(status: post.status),
        SizedBox(width: AppSpacing.horizontal8),
        Expanded(
          child: Text(
            post.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.label_16.copyWith(color: AppColors.black),
          ),
        ),
        // 메뉴 항목(수정·삭제·신고)은 상세 화면 작업에서 붙인다. 지금은 탭을 받지 않는다.
        Icon(Icons.more_vert, size: 20.w, color: AppColors.black300),
      ],
    );
  }

  Widget _buildLocationRow(String address) {
    return Row(
      key: locationRowKey,
      children: [
        SvgPicture.asset(
          'assets/icons/icon_location.svg',
          width: 14.w,
          height: 14.h,
        ),
        SizedBox(width: AppSpacing.horizontal4),
        Expanded(
          child: Text(
            address,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.tag_12.copyWith(color: AppColors.black700),
          ),
        ),
      ],
    );
  }

  Widget _buildMetaRow(AppLocalizations l10n) {
    final headcount = post.currentParticipants == null
        ? l10n.communityHeadcountMaxOnly(post.maxParticipants)
        : l10n.communityHeadcount(
            post.currentParticipants!,
            post.maxParticipants,
          );

    return Row(
      children: [
        // 글자 크기가 커져도 우측 카운트를 밀어내지 않고 잘리도록 Expanded로 감싼다.
        Expanded(
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/icons/icon_date.svg',
                width: 14.w,
                height: 14.h,
              ),
              SizedBox(width: AppSpacing.horizontal4),
              Flexible(
                child: Text(
                  _formatMeetingAt(l10n),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.tag_12.copyWith(
                    color: AppColors.black700,
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.horizontal16),
              SvgPicture.asset(
                'assets/icons/icon_headcount.svg',
                width: 14.w,
                height: 14.h,
              ),
              SizedBox(width: AppSpacing.horizontal4),
              Flexible(
                child: Text(
                  headcount,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.tag_12.copyWith(
                    color: AppColors.black600,
                  ),
                ),
              ),
            ],
          ),
        ),
        // 표시 전용 — 백엔드가 카운트를 주기 전에는 0으로 보인다.
        // on/off 아이콘이 생겼지만 "내가 눌렀는지"를 주는 필드가 API에 아직 없어
        // off로 고정한다. 토글이 붙는 상세 화면에서 on을 쓰게 된다.
        _CountLabel(
          assetPath: 'assets/icons/icon_like_off.svg',
          count: post.likeCount ?? 0,
        ),
        SizedBox(width: AppSpacing.horizontal10),
        _CountLabel(
          assetPath: 'assets/icons/icon_save_off.svg',
          count: post.bookmarkCount ?? 0,
        ),
      ],
    );
  }

  /// `9/10 (목) 18:00`
  ///
  /// `DateFormat`에 로케일을 넘기려면 `initializeDateFormatting`이 필요한데
  /// 이 앱은 그걸 호출하지 않는다. 채팅 날짜 구분선과 같은 방식으로 요일 라벨을
  /// ARB에서 꺼내 조립한다 (`chat_message_list.dart:280`).
  String _formatMeetingAt(AppLocalizations l10n) {
    final weekdays = [
      l10n.weekdayMon,
      l10n.weekdayTue,
      l10n.weekdayWed,
      l10n.weekdayThu,
      l10n.weekdayFri,
      l10n.weekdaySat,
      l10n.weekdaySun,
    ];
    final dt = post.meetingAt;
    final time =
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
    return l10n.communityMeetingAt(
      dt.month.toString(),
      dt.day.toString(),
      weekdays[dt.weekday - 1],
      time,
    );
  }
}

/// 모집 상태 배지
///
/// 폭·높이를 고정하지 않는다 — 좌우 8 / 상하 4 패딩만 주면 글자 크기에 따라
/// 함께 커진다. 시안의 42×18은 "모집중" 3자 + 패딩의 결과값이다.
///
/// radius 16은 현재 높이(18)에서 Flutter가 절반(9)으로 clamp하므로 pill과 같게
/// 그려진다. 글자 크기가 커져 높이가 32를 넘으면 그때부터 16이 살아난다.
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final CommunityPostStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isRecruiting = status == CommunityPostStatus.recruiting;

    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.horizontal8,
        vertical: AppSpacing.vertical4,
      ),
      decoration: BoxDecoration(
        // 마감을 로고색으로 두면 끝난 모임이 모집중처럼 눈에 띈다.
        color: isRecruiting ? AppColors.logo : AppColors.black300,
        borderRadius: AppRadius.xlarge,
      ),
      child: Text(
        isRecruiting
            ? l10n.communityStatusRecruiting
            : l10n.communityStatusCompleted,
        style: AppTextStyles.tag_10.copyWith(color: AppColors.white),
      ),
    );
  }
}

/// 아이콘 + 숫자 (좋아요 / 스크랩)
///
/// 색은 SVG에 박혀 있으므로 `colorFilter`를 주지 않는다 (`NoticeCard`의
/// `icon_pin`과 같은 처리).
class _CountLabel extends StatelessWidget {
  const _CountLabel({required this.assetPath, required this.count});

  final String assetPath;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(assetPath, width: 12.w, height: 12.h),
        SizedBox(width: AppSpacing.horizontal2),
        Text(
          '$count',
          style: AppTextStyles.tag_12.copyWith(color: AppColors.black600),
        ),
      ],
    );
  }
}
