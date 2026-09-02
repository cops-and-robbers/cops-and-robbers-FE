import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';
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
  /// 로그인 공통 — 이 글 알림 켜기/끄기 (남의 글도 켤 수 있다)
  toggleNotification,

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
/// 로그인 두 갈래에는 이 글 알림 토글이 맨 위에 붙는다 — 서버가 설정을 준 경우에만
/// (목록 경유 카드·비로그인 단건은 null).
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
    this.iconSize = 18,
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
          iconPath: AppIcons.person,
          iconColor: AppColors.black700,
          label: l10n.communityMenuLoginRequired,
          onTap: () => onAction(CommunityPostMenuAction.login),
        ),
      ];
    }

    // 서버가 설정을 준 경우에만 그린다. 남의 글도 켤 수 있다 — 명시적으로 켠
    // 제3자도 수신자다(DEC-0042 구현). 아이콘도 라벨과 같이 "누르면 되는 것"을
    // 가리킨다(모집중↔마감 항목과 같은 이유) — 한 줄 안에서 아이콘만 현재 상태를
    // 쓰면 둘이 반대를 가리켜 헷갈린다. 라벨 없이 아이콘만 있는 표면(채팅방 정보
    // 앱바)은 반대로 현재 상태를 쓴다. 두 종은 다색 SVG라 틴트하지 않는다.
    final setting = post.notificationSetting;
    final notification = setting == null
        ? null
        : CommunityMenuItem(
            iconPath: setting.enabled ? AppIcons.bellBlock : AppIcons.bell,
            label: setting.enabled
                ? l10n.communityMenuNotificationOff
                : l10n.communityMenuNotificationOn,
            onTap: () => onAction(CommunityPostMenuAction.toggleNotification),
          );

    if (currentUserId != post.writerId) {
      return [
        if (notification != null) notification,
        CommunityMenuItem(
          iconPath: AppIcons.warningLight,
          label: l10n.buttonReport,
          onTap: () => onAction(CommunityPostMenuAction.report),
          isDestructive: true,
        ),
      ];
    }

    return [
      if (notification != null) notification,
      CommunityMenuItem(
        iconPath: AppIcons.write,
        label: l10n.communityMenuEdit,
        onTap: () => onAction(CommunityPostMenuAction.edit),
      ),
      // 종료된 글은 상태를 바꿔도 서버가 조회 시 다시 ENDED로 판정한다 —
      // 눌러도 아무 변화가 없어 사용자 눈에는 버그로 보인다.
      if (post.status != CommunityPostStatus.ended)
        CommunityMenuItem(
          iconPath: AppIcons.check,
          // 체크는 단색(#333D48) 선 아이콘이다. 쓰기 아이콘의 파랑(#339DFF)에
          // 맞춰 칠해 두 항목이 같은 계열로 읽히게 한다.
          iconColor: AppColors.blueVer2Basic,
          // 라벨은 "지금 누르면 무엇이 되는지"를 쓴다 — 현재 상태를 쓰면
          // 모집중인 글에서 "모집중"이 보여 눌러도 될지 알 수 없다.
          label: post.status == CommunityPostStatus.recruiting
              ? l10n.communityMenuMarkCompleted
              : l10n.communityMenuMarkRecruiting,
          onTap: () => onAction(CommunityPostMenuAction.toggleStatus),
        ),
      CommunityMenuItem(
        iconPath: AppIcons.trash,
        label: l10n.communityMenuDelete,
        onTap: () => onAction(CommunityPostMenuAction.delete),
        isDestructive: true,
      ),
    ];
  }
}
