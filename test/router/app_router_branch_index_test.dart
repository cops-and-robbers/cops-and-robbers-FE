import 'package:cops_and_robbers/features/auth/domain/entities/auth_result_entity.dart';
import 'package:cops_and_robbers/features/auth/presentation/providers/auth_provider.dart';
import 'package:cops_and_robbers/router/app_router.dart';
import 'package:cops_and_robbers/router/route_paths.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// authNotifierProvider의 콜드 스타트는 Firebase currentUser를 직접 읽는다 —
/// 여기서는 라우터 "구성"만 읽을 뿐 리다이렉트를 평가하지 않으므로, 그 시스템
/// 경계를 끊어 Firebase 미초기화 상태에서도 routerProvider를 만들 수 있게 한다.
class _StubAuthNotifier extends AuthNotifier {
  @override
  Future<AuthResultEntity?> build() async => null;
}

void main() {
  test('community_branch_is_at_the_index_route_paths_declares', () {
    final container = ProviderContainer(
      overrides: [authNotifierProvider.overrideWith(_StubAuthNotifier.new)],
    );
    addTearDown(container.dispose);

    final router = container.read(routerProvider);
    addTearDown(router.dispose);

    final shellRoute = router.configuration.routes
        .whereType<StatefulShellRoute>()
        .single;

    final communityBranchIndex = shellRoute.branches.indexWhere(
      (branch) => branch.routes.whereType<GoRoute>().any(
        (route) => route.name == RoutePaths.communityName,
      ),
    );

    // 브랜치 순서를 바꾸면 커뮤니티 화면의 탭 복귀 트리거(RoutePaths.
    // communityBranchIndex)가 조용히 엉뚱한 탭에 붙는다 — 여기서 실제
    // 라우터 구성과의 어긋남을 잡는다.
    expect(communityBranchIndex, RoutePaths.communityBranchIndex);
  });
}
