import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/spacing_and_radius.dart';
import '../../constants/text_styles.dart';

/// 아직 구현되지 않은 탭을 위한 공용 "준비중" 화면
///
/// 커뮤니티·마이페이지처럼 바텀 네비게이션 진입점은 있지만
/// 실제 화면이 아직 없는 탭에서 사용한다.
class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          title,
          style: AppTextStyles.subHeading_18.copyWith(
            color: AppColors.black800,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: AppPadding.horizontal20,
          child: Text(
            message,
            style: AppTextStyles.paragraph_14.copyWith(
              color: AppColors.black600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
