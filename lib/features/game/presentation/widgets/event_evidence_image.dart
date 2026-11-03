import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/event_evidence.dart';

/// 증거 사진 한 장. 원격 사진을 못 받으면 앱에 든 사진으로 대신한다.
class EventEvidenceImage extends StatelessWidget {
  const EventEvidenceImage({required this.photo, super.key});

  final EventEvidencePhoto photo;

  @override
  Widget build(BuildContext context) {
    final bundled = Image.asset(photo.assetPath, fit: BoxFit.contain);
    final url = photo.url;
    if (url == null) return bundled;

    return Image.network(
      url,
      fit: BoxFit.contain,
      // 홈 배너와 달리 증거 자리는 숨길 수 없어서 앱 사진으로 채운다
      errorBuilder: (_, _, _) => bundled,
      frameBuilder: (_, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) return child;
        return _SlowLoadingPlaceholder(fallback: bundled);
      },
    );
  }
}

/// 받는 동안은 회색 면을 보여 주고, 통신이 멈춰 오래 걸리면 앱 사진으로 바꾼다.
/// 다 받으면 원격 사진이 이 자리를 대신한다.
class _SlowLoadingPlaceholder extends StatefulWidget {
  const _SlowLoadingPlaceholder({required this.fallback});

  final Widget fallback;

  @override
  State<_SlowLoadingPlaceholder> createState() =>
      _SlowLoadingPlaceholderState();
}

class _SlowLoadingPlaceholderState extends State<_SlowLoadingPlaceholder> {
  static const Duration _patience = Duration(seconds: 5);

  late final Timer _timer;
  bool _showFallback = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(_patience, () => setState(() => _showFallback = true));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showFallback) return widget.fallback;
    return const ColoredBox(
      color: AppColors.black100,
      child: SizedBox.expand(),
    );
  }
}
