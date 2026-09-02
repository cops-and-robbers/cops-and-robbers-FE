import 'dart:math' as math;

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

/// 당겨서 새로고침 (pull-to-refresh)
///
/// Material 기본 동작 — 흰 원판이 위에서 내려왔다 올라가는 그 움직임 — 을 그대로
/// 쓰고, 안에서 도는 표시만 앱 색으로 바꾼다. 위치·속도·감촉은 프레임워크가
/// 정한 값을 따른다.
///
/// 프레임워크의 `RefreshIndicator` 대신 이걸 쓰는 이유는 **안쪽 내용을 넘길 수
/// 있어서**다. `RefreshIndicator`는 `color`·`strokeWidth` 정도만 열려 있어
/// 진행도 링을 우리가 그릴 수 없다.
///
/// 사용:
/// ```dart
/// AppRefreshControl(
///   onRefresh: _refresh,
///   child: ListView.separated(...),
/// )
/// ```
class AppRefreshControl extends StatelessWidget {
  const AppRefreshControl({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  /// 새로고침 동작. 이 Future가 끝날 때까지 표시가 돈다.
  final Future<void> Function() onRefresh;

  /// 감쌀 스크롤 위젯.
  final Widget child;

  /// 스피너 최소 표시 시간
  ///
  /// 캐시가 물려 응답이 즉시 오면 스피너가 번쩍이고 사라져, 오히려 아무 일도
  /// 안 일어난 것처럼 보인다. 전체 화면 로딩이 같은 이유로 최소 시간을 두고
  /// 있다 (`AppLoading.minVisibleDuration`). 여긴 훨씬 가벼운 표시라 그보다
  /// 짧게 잡는다.
  static const Duration _minimumSpin = Duration(milliseconds: 200);

  /// 새로고침이 아무리 빨리 끝나도 [_minimumSpin]만큼은 돌게 한다.
  ///
  /// 지연을 먼저 걸어 두고 `finally`에서 기다리므로, 실제 조회가 그보다 오래
  /// 걸리면 아무것도 늘어나지 않는다 — 느린 요청에 200ms를 더 얹지 않는다.
  /// 실패해도 같은 시간을 유지한다(에러 스낵바가 뜰 자리를 만들어 준다).
  Future<void> _refreshAtLeastBriefly() async {
    final minimum = Future<void>.delayed(_minimumSpin);
    try {
      await onRefresh();
    } finally {
      await minimum;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomMaterialIndicator(
      onRefresh: _refreshAtLeastBriefly,
      backgroundColor: AppColors.white,
      indicatorBuilder: (context, controller) => Padding(
        padding: const EdgeInsets.all(6),
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: AppColors.logo,
          // 당기는 동안에는 얼마나 더 가야 하는지를 링으로 보여 주고, 요청이
          // 날아간 뒤에는 끝을 모르니 무한 회전으로 바꾼다.
          value: controller.state.isLoading
              ? null
              : math.min(controller.value, 1),
        ),
      ),
      child: child,
    );
  }
}
