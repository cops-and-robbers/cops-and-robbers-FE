import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/spacing_and_radius.dart';

/// 모든 다이얼로그·모달이 쓰는 카드 틀 (디자인 모달_GUI, #713)
///
/// 화면 좌우 36 · 모서리 24 · 안쪽 24 · 배경색만 정한다. 안에 무엇을 넣을지는
/// 각 다이얼로그가 정한다. 카드 가장자리에 무언가를 붙이는 화면(게임 결과의
/// 캐릭터 팔)은 [margin]을 0으로 주고 바깥에서 36을 띄운다.
class DialogCard extends StatelessWidget {
  const DialogCard({
    super.key,
    required this.child,
    this.color = AppColors.white,
    this.margin,
  });

  final Widget child;
  final Color color;

  /// 화면 좌우 여백 (기본 36)
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: margin ?? AppPadding.horizontal36,
      padding: AppPadding.all24,
      decoration: BoxDecoration(color: color, borderRadius: AppRadius.xxlarge),
      child: Material(color: Colors.transparent, child: child),
    );
  }
}
