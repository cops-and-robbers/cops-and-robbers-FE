import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// 프로필 이미지 동전 뒤집기 위젯
///
/// [assets] 가 2개 이상이면 [interval] 마다 Y축으로 180도 회전하며
/// 중앙(90도)에서 다음 이미지로 교체된다. 1개 이하면 애니메이션 없이 정적으로 표시.
class FlippingProfileImage extends StatefulWidget {
  const FlippingProfileImage({
    super.key,
    required this.assets,
    required this.size,
    this.interval = const Duration(seconds: 3),
    this.flipDuration = const Duration(milliseconds: 700),
  });

  final List<String> assets;
  final double size;

  /// 다음 뒤집기까지 대기 시간
  final Duration interval;

  /// 뒤집는 동작 자체의 소요 시간
  final Duration flipDuration;

  @override
  State<FlippingProfileImage> createState() => _FlippingProfileImageState();
}

class _FlippingProfileImageState extends State<FlippingProfileImage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  int _currentIndex = 0;
  bool _swapped = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.flipDuration,
    );
    // 중앙(50%)을 지나는 순간 이미지 교체 — 뒷면이 보이지 않도록
    _controller.addListener(_onTick);
    _controller.addStatusListener(_onStatus);

    if (widget.assets.length > 1) {
      _scheduleNextFlip();
    }
  }

  void _onTick() {
    if (!_swapped && _controller.value >= 0.5) {
      _swapped = true;
      setState(() {
        _currentIndex = (_currentIndex + 1) % widget.assets.length;
      });
    }
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _controller.reset();
      _swapped = false;
      _scheduleNextFlip();
    }
  }

  void _scheduleNextFlip() {
    Future.delayed(widget.interval, () {
      if (!mounted) return;
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onTick);
    _controller.removeStatusListener(_onStatus);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final image = _buildImage(widget.assets.isEmpty ? null : widget.assets[_currentIndex]);

    if (widget.assets.length <= 1) {
      return image;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final angle = _controller.value * math.pi;
        // 뒷면(90~180도)에서는 다시 정방향으로 보이도록 미러링
        final displayAngle = angle > math.pi / 2 ? angle - math.pi : angle;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // 원근감
            ..rotateY(displayAngle),
          child: child,
        );
      },
      child: image,
    );
  }

  Widget _buildImage(String? asset) {
    return ClipOval(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: asset == null
            ? _fallback()
            : Image.asset(
                asset,
                fit: BoxFit.cover,
                gaplessPlayback: true,
                errorBuilder: (context, error, stackTrace) => _fallback(),
              ),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      color: AppColors.black800,
      alignment: Alignment.center,
      child: Icon(
        Icons.person,
        size: widget.size * 0.5,
        color: AppColors.black400,
      ),
    );
  }
}
