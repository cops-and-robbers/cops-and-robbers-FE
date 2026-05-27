import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// 스킨 토글 시 화면 전체를 잠깐 검정으로 덮었다가 다시 사라지는 트랜지션.
///
/// 시퀀스 (총 600ms):
/// - 0~200ms : opacity 0 → 1 (어두워짐)
/// - 200~300ms : 중간 시점, [onMidpoint] 호출 (Provider 토글 시점)
/// - 300~600ms : opacity 1 → 0 (밝아짐)
///
/// 트랜지션 진행 중 모든 사용자 입력은 [AbsorbPointer] 로 차단한다.
///
/// 사용 예:
/// ```dart
/// showFadeSkinTransition(context, onMidpoint: () {
///   ref.read(characterSkinProvider.notifier).toggle();
/// });
/// ```
void showFadeSkinTransition(
  BuildContext context, {
  required VoidCallback onMidpoint,
}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _FadeSkinTransitionLayer(
      onMidpoint: onMidpoint,
      onComplete: () => entry.remove(),
    ),
  );
  overlay.insert(entry);
}

class _FadeSkinTransitionLayer extends StatefulWidget {
  const _FadeSkinTransitionLayer({
    required this.onMidpoint,
    required this.onComplete,
  });

  final VoidCallback onMidpoint;
  final VoidCallback onComplete;

  @override
  State<_FadeSkinTransitionLayer> createState() =>
      _FadeSkinTransitionLayerState();
}

class _FadeSkinTransitionLayerState extends State<_FadeSkinTransitionLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  bool _midpointFired = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // 0.0~0.333 (0~200ms) : 0 → 1
    // 0.333~0.5  (200~300ms) : 1 유지 (스킨 swap 시점)
    // 0.5~1.0   (300~600ms) : 1 → 0
    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 200),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 100),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 300),
    ]).animate(_controller);

    _controller.addListener(_handleProgress);
    _controller.addStatusListener(_handleStatus);
    _controller.forward();
  }

  void _handleProgress() {
    // 중간 시점(검정으로 완전히 덮인 구간 시작)에 한 번만 콜백 발화
    if (!_midpointFired && _controller.value >= (200 / 600)) {
      _midpointFired = true;
      widget.onMidpoint();
    }
  }

  void _handleStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.onComplete();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleProgress);
    _controller.removeStatusListener(_handleStatus);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      child: AnimatedBuilder(
        animation: _opacity,
        builder: (context, _) {
          return Opacity(
            opacity: _opacity.value,
            child: Container(color: AppColors.black),
          );
        },
      ),
    );
  }
}
