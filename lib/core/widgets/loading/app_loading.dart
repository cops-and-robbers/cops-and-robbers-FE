import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/app_colors.dart';
import '../../services/loading_message_service.dart';
import '../../theme/role_theme_provider.dart';
import '../dialogs/dialog_animation.dart';
import 'loading_content_view.dart';

/// 최소 표시 시간 대비 남은 대기 시간 (이미 초과했으면 [Duration.zero])
///
/// 틱 카운팅이 아니라 시각 차이 기반이라, 앱이 백그라운드에 다녀와도 정확하다.
@visibleForTesting
Duration remainingVisibleDuration({
  required DateTime shownAt,
  required DateTime now,
  Duration minVisible = AppLoading.minVisibleDuration,
}) {
  final remaining = minVisible - now.difference(shownAt);
  return remaining.isNegative ? Duration.zero : remaining;
}

/// 풀스크린 로딩 화면 진입점 (오버레이)
///
/// 닫기는 반드시 반환된 [LoadingHandle]로만 한다.
/// `Navigator.pop()`은 최상단 라우트를 닫으므로, 타이밍이 어긋나면
/// 로딩이 아닌 다른 화면을 닫을 수 있다.
///
/// ```dart
/// final loading = AppLoading.show(context, LoadingCategory.joinRoom);
/// try {
///   await api();
/// } finally {
///   await loading.close();   // 최소 표시 시간은 핸들이 보장
/// }
/// ```
class AppLoading {
  AppLoading._();

  /// 최소 표시 시간
  ///
  /// 도허티 임계(400ms 이내 피드백)를 지키려고 로딩은 즉시 띄운다.
  /// 다만 API가 100ms에 끝나면 화면이 번쩍이고 사라져 오히려 불안감을 주므로,
  /// 이 시간만큼은 유지한다.
  static const Duration minVisibleDuration = Duration(milliseconds: 600);

  /// 카테고리 기반 로딩 화면 표시 (제목 랜덤 + 서브카피 고정)
  static LoadingHandle show(BuildContext context, LoadingCategory category) {
    return _open(
      context,
      message: LoadingMessageService.getMessage(context, category),
      subtitle: LoadingMessageService.getSubtitle(context, category),
    );
  }

  /// 문구를 직접 지정하는 로딩 화면 표시 (카테고리가 없는 경우)
  static LoadingHandle showMessage(
    BuildContext context, {
    required String message,
    String? subtitle,
  }) {
    return _open(context, message: message, subtitle: subtitle);
  }

  static LoadingHandle _open(
    BuildContext context, {
    required String message,
    String? subtitle,
  }) {
    // 팀 테마는 진입점에서 한 번만 읽고 prop으로 내린다
    final isDarkMode = ProviderScope.containerOf(
      context,
      listen: false,
    ).read(roleThemeProvider);
    final backgroundColor = isDarkMode ? AppColors.black : AppColors.white;

    // 자기 라우트만 정확히 닫기 위해 dialog route의 context를 캡처한다
    BuildContext? dialogContext;

    showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Loading',
      // 불투명 배리어 — 뒤 화면이 비치지 않아 '화면 전환'처럼 보인다
      barrierColor: backgroundColor,
      transitionDuration: DialogAnimation.duration,
      pageBuilder: (ctx, animation, secondaryAnimation) {
        dialogContext = ctx;
        return PopScope(
          // 로딩 중 뒤로가기 차단 (Overlay로는 막을 수 없어 dialog route를 쓴다)
          canPop: false,
          child: LoadingContentView(
            message: message,
            subtitle: subtitle,
            isDarkMode: isDarkMode,
          ),
        );
      },
      transitionBuilder: (ctx, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
    );

    return LoadingHandle._(
      shownAt: DateTime.now(),
      pop: () {
        final ctx = dialogContext;
        if (ctx != null && ctx.mounted) Navigator.of(ctx).pop();
      },
    );
  }
}

/// 로딩 화면 닫기 핸들
class LoadingHandle {
  LoadingHandle._({required DateTime shownAt, required VoidCallback pop})
    : _shownAt = shownAt,
      _pop = pop;

  final DateTime _shownAt;
  final VoidCallback _pop;
  bool _closed = false;

  /// 최소 표시 시간 미달분만큼 대기한 뒤 **자기 라우트만** 닫는다.
  ///
  /// 중복 호출은 무시된다(idempotent) — 성공 경로와 `finally`에서 모두 불러도 안전하다.
  Future<void> close() async {
    if (_closed) return;
    _closed = true;

    final wait = remainingVisibleDuration(
      shownAt: _shownAt,
      now: DateTime.now(),
    );
    if (wait > Duration.zero) await Future<void>.delayed(wait);

    _pop();
  }
}
