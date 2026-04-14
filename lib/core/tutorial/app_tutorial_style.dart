import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../constants/app_colors.dart';
import '../constants/text_styles.dart';

/// 텍스트 정렬 위치 (패키지 타입 캡슐화)
enum TutorialAlign { top, bottom, left, right }

/// 하이라이트 형태 (패키지 타입 캡슐화)
enum TutorialShape { circle, roundedRect }

/// 튜토리얼 코치마크 공통 스타일 및 헬퍼
///
/// tutorial_coach_mark 패키지 의존성을 이 파일에 격리하여
/// 페이지에서 패키지를 직접 import하지 않도록 한다.
class AppTutorialStyle {
  AppTutorialStyle._();

  /// 튜토리얼 타겟 정의 (패키지 타입을 노출하지 않는 래퍼)
  static TutorialTarget target({
    required GlobalKey keyTarget,
    required String description,
    TutorialAlign align = TutorialAlign.bottom,
    TutorialShape shape = TutorialShape.roundedRect,
    EdgeInsets? padding,
  }) {
    return TutorialTarget(
      keyTarget: keyTarget,
      description: description,
      align: align,
      shape: shape,
      padding: padding,
    );
  }

  /// 튜토리얼 표시
  ///
  /// [context] — BuildContext
  /// [targets] — target()으로 생성한 목록
  /// [onFinish] — 완료 콜백
  static void show({
    required BuildContext context,
    required List<TutorialTarget> targets,
    VoidCallback? onFinish,
  }) {
    final focusTargets = targets.map((t) => t._toTargetFocus()).toList();

    TutorialCoachMark(
      targets: focusTargets,
      colorShadow: AppColors.black,
      opacityShadow: 0.8,
      hideSkip: true,
      onFinish: onFinish,
    ).show(context: context);
  }
}

/// 패키지 타입을 숨기는 내부 래퍼
class TutorialTarget {
  const TutorialTarget({
    required this.keyTarget,
    required this.description,
    required this.align,
    required this.shape,
    this.padding,
  });

  final GlobalKey keyTarget;
  final String description;
  final TutorialAlign align;
  final TutorialShape shape;
  final EdgeInsets? padding;

  TargetFocus _toTargetFocus() {
    return TargetFocus(
      keyTarget: keyTarget,
      alignSkip: Alignment.topRight,
      shape: _mapShape(shape),
      radius: 8,
      contents: [
        TargetContent(
          align: _mapAlign(align),
          builder: (context, controller) {
            return Padding(
              padding:
                  padding ??
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                description,
                style: AppTextStyles.paragraph_14.copyWith(
                  color: AppColors.white,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  static ContentAlign _mapAlign(TutorialAlign align) => switch (align) {
    TutorialAlign.top => ContentAlign.top,
    TutorialAlign.bottom => ContentAlign.bottom,
    TutorialAlign.left => ContentAlign.left,
    TutorialAlign.right => ContentAlign.right,
  };

  static ShapeLightFocus _mapShape(TutorialShape shape) => switch (shape) {
    TutorialShape.circle => ShapeLightFocus.Circle,
    TutorialShape.roundedRect => ShapeLightFocus.RRect,
  };
}
