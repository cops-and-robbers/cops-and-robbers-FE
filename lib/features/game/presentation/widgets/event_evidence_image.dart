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
        return const ColoredBox(
          color: AppColors.black100,
          child: SizedBox.expand(),
        );
      },
    );
  }
}
