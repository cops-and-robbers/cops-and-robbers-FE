import 'package:flutter/material.dart';
import 'package:cops_and_robbers/core/constants/text_styles.dart';
import 'package:cops_and_robbers/core/constants/spacing_and_radius.dart';

/// ⚠️ 임시 개발용 페이지 - 테스트 후 삭제 예정
///
/// TextStyles 데모 페이지
/// - 8가지 TextStyle 확인
/// - 색상 변경 예시
/// - Spacing & Radius 테스트
class FontTestPage extends StatelessWidget {
  const FontTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('AppTextStyles 테스트', style: AppTextStyles.heading_20),
      ),
      body: SingleChildScrollView(
        padding: AppPadding.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Spacing & Radius 테스트
            Container(
              padding: AppPadding.cardPadding,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: AppRadius.card,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Spacing & Radius 테스트', style: AppTextStyles.heading_20),
                  SizedBox(height: AppSpacing.vertical8),
                  Text(
                    'AppPadding.cardPadding + AppRadius.card 적용됨',
                    style: AppTextStyles.tag_12,
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.vertical24),

            // Heading Styles (SemiBold)
            Text('Heading Styles (SemiBold)', style: AppTextStyles.heading_20),
            SizedBox(height: AppSpacing.vertical12),
            Text('Pretendard-SemiBold 24sp', style: AppTextStyles.tag_12),
            Text('Heading01 24sp', style: AppTextStyles.heading_24),
            Divider(height: AppSpacing.vertical24),
            Text('Pretendard-SemiBold 20sp', style: AppTextStyles.tag_12),
            Text('Heading02 20sp', style: AppTextStyles.heading_20),
            Divider(height: AppSpacing.vertical24),
            Text('Pretendard-SemiBold 18sp', style: AppTextStyles.tag_12),
            Text('SubHeading 18sp', style: AppTextStyles.subHeading_18),
            Divider(height: AppSpacing.vertical24),
            Text('Pretendard-SemiBold 16sp', style: AppTextStyles.tag_12),
            Text('Label 16sp', style: AppTextStyles.label_16),
            SizedBox(height: AppSpacing.vertical32),

            // Body Styles (Medium)
            Text('Body Styles (Medium)', style: AppTextStyles.heading_20),
            SizedBox(height: AppSpacing.vertical12),
            Text('Pretendard-Medium 14sp', style: AppTextStyles.tag_12),
            Text('Paragraph 14sp', style: AppTextStyles.paragraph_14),
            Divider(height: AppSpacing.vertical24),
            Text('Pretendard-Medium 14sp', style: AppTextStyles.tag_12),
            Text('Toast 14sp', style: AppTextStyles.paragraph_14),
            SizedBox(height: AppSpacing.vertical32),

            // Small Styles (Medium)
            Text('Small Styles (Medium)', style: AppTextStyles.heading_20),
            SizedBox(height: AppSpacing.vertical12),
            Text('Pretendard-Medium 12sp', style: AppTextStyles.tag_12),
            Text('Callout/Tag 12sp', style: AppTextStyles.tag_12),
            Divider(height: AppSpacing.vertical24),
            Text('Pretendard-Medium 10sp', style: AppTextStyles.tag_12),
            Text('CalloutSmall/TagSmall 10sp', style: AppTextStyles.tag_10),
            SizedBox(height: AppSpacing.vertical32),

            // 색상 변경 예시
            Text('색상 변경 예시', style: AppTextStyles.heading_20),
            SizedBox(height: AppSpacing.vertical12),
            Text(
              '빨간 Heading01',
              style: AppTextStyles.heading_24.copyWith(color: Colors.red),
            ),
            Text(
              '파란 Label 16sp',
              style: AppTextStyles.label_16.copyWith(color: Colors.blue),
            ),
            Text(
              '회색 Callout 12sp',
              style: AppTextStyles.tag_12.copyWith(color: Colors.grey),
            ),

            SizedBox(height: AppSpacing.vertical32),
          ],
        ),
      ),
    );
  }
}
