import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 방향성 슬라이드 전환을 위한 CustomTransitionPage 빌더
///
/// GoRouter의 CustomTransitionPage를 사용하여 명시적인 방향 제어를 제공합니다.
/// [isForward]가 true면 우→좌 슬라이드, false면 좌→우 슬라이드 애니메이션을 적용합니다.
///
/// 사용 예시:
/// ```dart
/// pageBuilder: (context, state) => buildDirectionalSlide(
///   child: const MyPage(),
///   key: state.pageKey,
///   isForward: true, // 우→좌 슬라이드
/// )
/// ```
CustomTransitionPage<T> buildDirectionalSlide<T>({
  required Widget child,
  required LocalKey key,
  required bool isForward,
  Duration? duration,
  Duration? reverseDuration,
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // 명시적 방향 제어
      // isForward = true: 우→좌 (Offset(1.0, 0.0) → Offset.zero)
      // isForward = false: 좌→우 (Offset(-1.0, 0.0) → Offset.zero)
      final offset = isForward
          ? const Offset(1.0, 0.0) // 우→좌
          : const Offset(-1.0, 0.0); // 좌→우

      final tween = Tween(
        begin: offset,
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeInOut));

      return SlideTransition(position: animation.drive(tween), child: child);
    },
    transitionDuration: duration ?? const Duration(milliseconds: 300),
    reverseTransitionDuration:
        reverseDuration ?? const Duration(milliseconds: 200),
  );
}

/// 애니메이션 없는 즉각 전환
///
/// Splash 화면 등에서 사용하여 페이지 전환 시 애니메이션을 완전히 제거합니다.
/// Duration.zero를 사용하여 즉각적인 전환을 제공합니다.
///
/// 사용 예시:
/// ```dart
/// pageBuilder: (context, state) => buildInstantTransition(
///   child: const SplashPage(),
///   key: state.pageKey,
/// )
/// ```
CustomTransitionPage<T> buildInstantTransition<T>({
  required Widget child,
  required LocalKey key,
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
    transitionsBuilder: (_, _, _, child) => child,
  );
}

/// 부드러운 페이드 전환
///
/// 매우 짧은 페이드 애니메이션으로 깜빡임 없이 부드럽게 전환합니다.
/// 세션 생성 단계 간 전환에 적합합니다.
///
/// 사용 예시:
/// ```dart
/// pageBuilder: (context, state) => buildSmoothFade(
///   child: const SessionStepPage(),
///   key: state.pageKey,
/// )
/// ```
CustomTransitionPage<T> buildSmoothFade<T>({
  required Widget child,
  required LocalKey key,
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 150),
    reverseTransitionDuration: const Duration(milliseconds: 150),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}
