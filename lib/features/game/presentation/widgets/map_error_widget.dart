import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';

/// 지도 로드 실패 시 표시하는 공통 에러 위젯
class MapErrorWidget extends StatelessWidget {
  const MapErrorWidget({super.key, required this.mapName, required this.error});

  final String mapName;
  final Object error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.red),
          SizedBox(height: AppSpacing.vertical16),
          Text('$mapName 로드 실패'),
          SizedBox(height: AppSpacing.vertical8),
          Text('Error: $error', style: AppTextStyles.tag_12),
        ],
      ),
    );
  }
}
