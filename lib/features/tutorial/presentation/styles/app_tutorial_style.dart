import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text_styles.dart';

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
  ///
  /// 반환된 [AppTutorialController]로 진행 중 타겟 위치 재계산(`refresh()`)이
  /// 가능하다. 하위 호환을 위해 반환값 무시해도 동작은 그대로.
  static AppTutorialController show({
    required BuildContext context,
    required List<TutorialTarget> targets,
    VoidCallback? onFinish,
  }) {
    final focusTargets = targets.map((t) => t._toTargetFocus()).toList();

    final coach = TutorialCoachMark(
      targets: focusTargets,
      colorShadow: AppColors.black,
      opacityShadow: 0.8,
      hideSkip: true,
      onFinish: onFinish,
    );
    coach.show(context: context);
    return AppTutorialController._(coach);
  }
}

/// 표시 중인 튜토리얼을 제어하는 핸들
///
/// 패키지의 `TutorialCoachMark`를 캡슐화하여 상위 코드가 직접 의존하지
/// 않도록 한다. 레이아웃이 변한 시점에 `refresh()`를 호출하면 현재
/// 활성화된 타겟의 화면 좌표를 다시 계산한다.
class AppTutorialController {
  AppTutorialController._(this._coach);

  final TutorialCoachMark _coach;

  /// 튜토리얼 오버레이가 떠 있는지 여부
  bool get isShowing => _coach.isShowing;

  /// 현재 타겟 위치 재계산
  ///
  /// 패키지가 `refreshTargetPosition()`을 외부로 직접 노출하지 않기 때문에,
  /// 내부의 `didChangeMetrics` 경로를 빌려 좌표를 강제 재계산한다.
  /// (패키지 내부에서 `didChangeMetrics`가 `refreshTargetPosition()`을 호출)
  ///
  /// 레이아웃이 실제로 변하지 않은 위젯은 `handleMetricsChanged`로 인한
  /// 리빌드가 발생해도 대부분 no-op이므로 성능 영향은 미미하다.
  void refresh() {
    if (!_coach.isShowing) return;
    WidgetsBinding.instance.handleMetricsChanged();
  }

  /// 튜토리얼 강제 종료
  void finish() => _coach.finish();
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
