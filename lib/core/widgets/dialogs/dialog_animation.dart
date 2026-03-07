import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

/// 다이얼로그/팝업 공용 애니메이션 설정
///
/// AppDialog, AppPopup 등 모든 다이얼로그 계열 위젯이
/// 동일한 트랜지션(스케일 + 페이드)을 공유합니다.
class DialogAnimation {
  DialogAnimation._();

  /// 애니메이션 지속 시간 (250ms)
  static const duration = Duration(milliseconds: 250);

  /// 애니메이션 커브 (easeOutBack)
  static const curve = Curves.easeOutBack;

  /// 배리어 색상 (반투명 검정)
  static Color get barrierColor => AppColors.black.withValues(alpha: 0.5);

  /// 스케일 + 페이드 트랜지션 빌더
  static Widget buildTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return ScaleTransition(
      scale: CurvedAnimation(parent: animation, curve: curve),
      child: FadeTransition(opacity: animation, child: child),
    );
  }
}
