import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/services/vibration_service.dart';

/// 더보기 메뉴 한 항목의 표시 정보
class CommunityMenuItem {
  const CommunityMenuItem({
    required this.iconPath,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final String iconPath;
  final String label;

  /// 메뉴가 닫힌 뒤 호출된다 — 다이얼로그를 띄우는 항목이 있어 순서가 중요하다.
  final VoidCallback onTap;

  /// 되돌릴 수 없는 항목(삭제·신고)은 빨강으로 구분한다.
  final bool isDestructive;
}

/// 커뮤니티 더보기(⋮) 버튼
///
/// 모집글 메뉴와 댓글 메뉴가 같은 표면을 쓴다 — 보이는 항목만 호출부가 정한다.
class CommunityMenuButton extends StatelessWidget {
  const CommunityMenuButton({
    super.key,
    required this.items,
    this.iconSize = 16,
    this.iconColor,
  });

  final List<CommunityMenuItem> items;

  /// ⋮ 아이콘 크기. 목록 카드는 16, 상세는 더 크게 쓴다.
  final double iconSize;

  /// ⋮ 아이콘 색. null이면 SVG에 박힌 색(#B1BCC8 = black300)을 그대로 쓴다 —
  /// 목록 카드가 이 기본값이다. 상세는 앱바라 더 진한 색을 넘긴다.
  final Color? iconColor;

  /// 메뉴 표면 — 테스트에서 열림 여부를 확인한다.
  static const Key surfaceKey = Key('community_menu_surface');

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<void>(
      // 메뉴 표면은 아래 컨테이너가 직접 그린다 — Material elevation으로는
      // AppShadows.ver2(blur 10, 7%)를 못 만들기 때문에 프레임워크 쪽은 투명하게 비운다.
      color: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.transparent,
      menuPadding: EdgeInsets.zero,
      position: PopupMenuPosition.under,
      // 메뉴가 뜨기 전에 터치가 먹혔음을 알린다 (정렬 라벨이 시트를 열 때와 같은 탭 햅틱).
      onOpened: () => VibrationService.instance().buttonTap(),
      // 기본 툴팁("Show menu")이 영어라 롱프레스 시 떠버린다.
      tooltip: '',
      // 메뉴 폭 204. `_PopupMenu`의 IntrinsicWidth(stepWidth: 56)가 폭을 56 배수로
      // 올림하므로 tight 제약으로 못 박는다 — 안 하면 224가 되어 우측으로 20 밀린다.
      constraints: BoxConstraints.tightFor(width: 204.w),
      // icon: 대신 child: 를 쓴다. icon:은 IconButton으로 감싸져 최소 48×48이 붙고,
      // 그만큼 제목 행 높이가 늘어난다.
      child: SvgPicture.asset(
        'assets/icons/icon_meatballs.svg',
        width: iconSize.w,
        height: iconSize.h,
        colorFilter: iconColor == null
            ? null
            : ColorFilter.mode(iconColor!, BlendMode.srcIn),
      ),
      itemBuilder: (_) => [
        // 항목마다 PopupMenuItem을 쪼개면 각자 테두리·그림자를 그려 카드가 여러 장
        // 겹친 것처럼 보인다. 표면 하나에 행을 쌓고, 각 행이 스스로 메뉴를 닫는다.
        PopupMenuItem<void>(
          padding: EdgeInsets.zero,
          child: _MenuSurface(items: items),
        ),
      ],
    );
  }
}

/// 항목들을 담는 메뉴 표면 (테두리·그림자를 한 번만 그린다)
class _MenuSurface extends StatelessWidget {
  const _MenuSurface({required this.items});

  final List<CommunityMenuItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: CommunityMenuButton.surfaceKey,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.large,
        border: Border.all(color: AppColors.black100),
        boxShadow: AppShadows.ver2,
      ),
      // 표면이 radius를 갖는데 행이 사각이면 모서리에서 삐져나온다.
      child: ClipRRect(
        borderRadius: AppRadius.large,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) Divider(height: 1.h, color: AppColors.black100),
              _MenuRow(
                item: items[i],
                onTap: () {
                  VibrationService.instance().buttonTap();
                  // 메뉴를 먼저 닫는다 — 화면이 다이얼로그를 띄우는 항목이 있어
                  // 팝업 route가 남아 있으면 그 위에 겹친다.
                  Navigator.of(context).pop();
                  items[i].onTap();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 메뉴 한 줄 (아이콘 + 라벨)
class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.item, required this.onTap});

  final CommunityMenuItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 아이콘과 글자 사이 빈 곳도 눌리게 한다.
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 52.h,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.horizontal20),
        child: Row(
          children: [
            // 경고 아이콘은 빨강·회색 다색이라 덧칠하면 뭉개진다. 단색 아이콘만
            // 파괴적 항목 색으로 맞춘다.
            SvgPicture.asset(
              item.iconPath,
              width: 16.w,
              height: 16.h,
              colorFilter: item.isDestructive
                  ? null
                  : ColorFilter.mode(AppColors.black700, BlendMode.srcIn),
            ),
            SizedBox(width: AppSpacing.horizontal14),
            Expanded(
              child: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.label_16.copyWith(
                  color: item.isDestructive ? AppColors.red : AppColors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
