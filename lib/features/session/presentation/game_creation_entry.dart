import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/permission/game_entry_gate.dart';
import '../../../core/services/permission/location_permission_messages.dart';
import '../../../core/services/storage/session_draft_storage_service.dart';
import '../../../router/route_paths.dart';

/// 게임 생성 플로우 진입 — 위치 권한 게이트와 이전 초안 정리를 여기서 보장한다.
///
/// 진입 전 처리를 진입점마다 각각 붙이면 새로 생긴 진입점이 또 빠뜨린다.
/// 실제로 두 번 그랬다.
///
/// - #432: 딥링크 진입이 홈에만 있던 위치 권한 게이트를 우회했다. 그때 게이트를
///   [GameEntryGate] 로 추출했지만 "생성 플로우로 들어가려면 반드시 거친다"를
///   강제하는 자리는 두지 않았다.
/// - #525: #516에서 추가된 채팅방 진입이 초안 정리를 빠뜨렸다. 이전 초안이 남아
///   있으면 플로우가 그 `playgroundCenter` 를 복원하고, 구역 설정 지도는
///   `initialCenter` 가 채워진 것을 보고 **현재 위치 조회를 건너뛴다**
///   (`zone_setting_widget.dart` 의 `initialCenter ?? 현재위치 ?? fallback`).
///   그래서 지도가 매번 과거 좌표에서 열렸다.
///
/// 그래서 게이트·초안 정리·라우팅을 이 함수 하나에 묶는다. 새 진입점은 이 함수만
/// 부르면 되고, 부르지 않으면 리뷰에서 드러난다.
///
/// - [communityPostId] 모집글 채팅방에서 왔을 때의 글 번호. 플로우가 생성 직후
///   그 방에 GAME_INVITE 를 쏘는 데 쓴다 (#516).
/// - [replace] 현재 화면을 대체할지(`go`) 위에 쌓을지(`push`). 홈은 대체하고,
///   채팅방은 쌓아 두어 뒤로가기로 방에 돌아온다.
Future<void> startGameCreation({
  required BuildContext context,
  required WidgetRef ref,
  int? communityPostId,
  bool replace = false,
}) async {
  final passed = await ref
      .read(gameEntryGateProvider)
      .ensure(
        context: context,
        locationContext: LocationPermissionContext.home,
      );
  // 미통과 시 게이트가 이미 안내 다이얼로그를 띄운 상태 → 호출한 화면에 머무른다
  if (!passed || !context.mounted) return;

  await SessionDraftStorageService().clearDraft();
  if (!context.mounted) return;

  if (replace) {
    context.go(RoutePaths.sessionCreationFlow, extra: communityPostId);
  } else {
    context.push(RoutePaths.sessionCreationFlow, extra: communityPostId);
  }
}
