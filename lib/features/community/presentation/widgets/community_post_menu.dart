import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/community_post_entity.dart';
import '../../domain/entities/community_post_status.dart';
import 'community_menu_button.dart';

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

  /// ⋮ 아이콘 색. null이면 SVG에 박힌 색을 그대로 쓴다.
  final Color? iconColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final currentUserId = ref.watch(currentUserIdProvider);

    return CommunityMenuButton(
      items: _itemsFor(currentUserId, l10n),
      iconSize: iconSize,
      iconColor: iconColor,
    );
  }

  /// 로그인 상태와 작성자 일치 여부로 보여줄 항목을 고른다.
  List<CommunityMenuItem> _itemsFor(int? currentUserId, AppLocalizations l10n) {
    if (currentUserId == null) {
      return [
        CommunityMenuItem(
          iconPath: 'assets/icons/icon_person.svg',
          label: l10n.communityMenuLoginRequired,
          onTap: () => onAction(CommunityPostMenuAction.login),
        ),
      ];
    }

    if (currentUserId != post.writerId) {
      return [
        CommunityMenuItem(
          iconPath: 'assets/icons/icon_warning_light.svg',
          label: l10n.buttonReport,
          onTap: () => onAction(CommunityPostMenuAction.report),
          isDestructive: true,
        ),
      ];
    }

    return [
      CommunityMenuItem(
        iconPath: 'assets/icons/icon_write.svg',
        label: l10n.communityMenuEdit,
        onTap: () => onAction(CommunityPostMenuAction.edit),
      ),
      CommunityMenuItem(
        iconPath: 'assets/icons/icon_check.svg',
        // 라벨은 "지금 누르면 무엇이 되는지"를 쓴다 — 현재 상태를 쓰면
        // 모집중인 글에서 "모집중"이 보여 눌러도 될지 알 수 없다.
        label: post.status == CommunityPostStatus.recruiting
            ? l10n.communityMenuMarkCompleted
            : l10n.communityMenuMarkRecruiting,
        onTap: () => onAction(CommunityPostMenuAction.toggleStatus),
      ),
      CommunityMenuItem(
        iconPath: 'assets/icons/icon_trash.svg',
        label: l10n.communityMenuDelete,
        onTap: () => onAction(CommunityPostMenuAction.delete),
        isDestructive: true,
      ),
    ];
  }
}
