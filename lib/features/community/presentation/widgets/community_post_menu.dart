import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/services/vibration_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/community_post_entity.dart';
import '../../domain/entities/community_post_status.dart';

/// 더보기 메뉴에서 사용자가 고른 항목
///
/// 위젯은 "무엇을 골랐는지"만 알리고 실제 처리는 화면이 한다 — 목록과 상세가
/// 같은 항목에 다르게 반응해야 하기 때문이다(예: 삭제 후 목록은 제자리 갱신,
/// 상세는 뒤로 나가기).
enum CommunityPostMenuAction {
  /// 내 글 — 수정 화면으로
  edit,

  /// 내 글 — 삭제 (확인 절차는 화면 몫)
  delete,

  /// 내 글 — 모집중 ↔ 마감 전환
  toggleStatus,

  /// 남의 글 — 신고하기
  report,

  /// 비로그인 — 로그인 유도
  login,
}

/// 커뮤니티 모집글 더보기(⋮) 메뉴
///
/// 목록 카드와 상세 화면이 함께 쓴다. 보이는 항목은 세 갈래로 갈린다:
/// 내 글(수정·삭제·상태 변경) / 남의 글(신고) / 비로그인(로그인 유도).
///
/// 판정 기준은 [CommunityPostEntity.writerId]와 로그인 사용자 id 비교 하나뿐이다.
/// 로그인 상태가 확정되기 전(로딩)에는 `currentUserId`가 null이라 비로그인으로
/// 취급된다 — 잠깐 로그인 유도가 보이는 편이, 남의 글에 수정 버튼을 띄웠다가
/// 403을 받는 것보다 낫다.
class CommunityPostMenu extends ConsumerWidget {
  const CommunityPostMenu({
    super.key,
    required this.post,
    required this.onAction,
    this.iconSize = 16,
    this.iconColor,
  });

  final CommunityPostEntity post;
  final ValueChanged<CommunityPostMenuAction> onAction;

  /// ⋮ 아이콘 크기. 목록 카드는 16, 상세는 더 크게 쓴다.
  final double iconSize;

  /// ⋮ 아이콘 색. null이면 SVG에 박힌 색(#B1BCC8 = black300)을 그대로 쓴다 —
  /// 목록 카드가 이 기본값이다. 상세는 앱바라 더 진한 색을 넘긴다.
  final Color? iconColor;

  /// 메뉴 표면 — 테스트에서 열림 여부를 확인한다.
  static const Key surfaceKey = Key('community_post_menu_surface');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final currentUserId = ref.watch(currentUserIdProvider);
    final items = _itemsFor(currentUserId, l10n);

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
          child: _MenuSurface(items: items, onAction: onAction),
        ),
      ],
    );
  }

  /// 로그인 상태와 작성자 일치 여부로 보여줄 항목을 고른다.
  List<_MenuItem> _itemsFor(int? currentUserId, AppLocalizations l10n) {
    if (currentUserId == null) {
      return [
        _MenuItem(
          action: CommunityPostMenuAction.login,
          iconPath: 'assets/icons/icon_person.svg',
          label: l10n.communityMenuLoginRequired,
        ),
      ];
    }

    if (currentUserId != post.writerId) {
      return [
        _MenuItem(
          action: CommunityPostMenuAction.report,
          iconPath: 'assets/icons/icon_warning_light.svg',
          label: l10n.buttonReport,
          isDestructive: true,
        ),
      ];
    }

    return [
      _MenuItem(
        action: CommunityPostMenuAction.edit,
        iconPath: 'assets/icons/icon_write.svg',
        label: l10n.communityMenuEdit,
      ),
      _MenuItem(
        action: CommunityPostMenuAction.toggleStatus,
        iconPath: 'assets/icons/icon_check.svg',
        // 라벨은 "지금 누르면 무엇이 되는지"를 쓴다 — 현재 상태를 쓰면
        // 모집중인 글에서 "모집중"이 보여 눌러도 될지 알 수 없다.
        label: post.status == CommunityPostStatus.recruiting
            ? l10n.communityMenuMarkCompleted
            : l10n.communityMenuMarkRecruiting,
      ),
      _MenuItem(
        action: CommunityPostMenuAction.delete,
        iconPath: 'assets/icons/icon_trash.svg',
        label: l10n.communityMenuDelete,
        isDestructive: true,
      ),
    ];
  }
}

/// 메뉴 한 항목의 표시 정보
class _MenuItem {
  const _MenuItem({
    required this.action,
    required this.iconPath,
    required this.label,
    this.isDestructive = false,
  });

  final CommunityPostMenuAction action;
  final String iconPath;
  final String label;

  /// 되돌릴 수 없는 항목(삭제·신고)은 빨강으로 구분한다.
  final bool isDestructive;
}

/// 항목들을 담는 메뉴 표면 (테두리·그림자를 한 번만 그린다)
class _MenuSurface extends StatelessWidget {
  const _MenuSurface({required this.items, required this.onAction});

  final List<_MenuItem> items;
  final ValueChanged<CommunityPostMenuAction> onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: CommunityPostMenu.surfaceKey,
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
                  onAction(items[i].action);
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

  final _MenuItem item;
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
