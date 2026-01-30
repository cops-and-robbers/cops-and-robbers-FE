import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';

/// 단계별 진행 상황을 시각적으로 표시하는 선형 막대 인디케이터
///
/// 온보딩, 회원가입 플로우, 게임 세션 생성 등 여러 단계로 이루어진 프로세스에 사용합니다.
/// 각 단계를 막대기(bar) 형태로 표시하며, 완료된 단계는 채워진 색상으로 표시됩니다.
///
/// **기본 스펙**:
/// - 전체 단계 수와 현재 단계를 기반으로 표시
/// - 완료된 막대: AppColors.black (기본)
/// - 미완료 막대: AppColors.black100 (기본)
/// - 애니메이션: 300ms 부드러운 전환
///
/// **사용 예시**:
/// ```dart
/// // 기본 사용 (4단계 중 2단계 완료)
/// StepIndicator(
///   totalSteps: 4,
///   currentStep: 1, // 0-based index
/// )
///
/// // 색상 커스터마이징
/// StepIndicator(
///   totalSteps: 3,
///   currentStep: 0,
///   activeColor: AppColors.green,
///   inactiveColor: AppColors.black200,
/// )
///
/// // 크기 조절
/// StepIndicator(
///   totalSteps: 5,
///   currentStep: 2,
///   barHeight: 6.0,
///   spacing: 8.0,
/// )
/// ```
class StepIndicator extends StatelessWidget {
  const StepIndicator({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    this.activeColor,
    this.inactiveColor,
    this.barHeight = 4.0,
    this.spacing = 8.0,
  }) : assert(totalSteps > 0, 'totalSteps must be greater than 0'),
       assert(currentStep >= 0, 'currentStep must be non-negative'),
       assert(
         currentStep < totalSteps,
         'currentStep must be less than totalSteps',
       );

  /// 전체 단계 수 (필수)
  final int totalSteps;

  /// 현재 단계 (0-based index, 필수)
  ///
  /// 예: 3단계 중 2단계면 currentStep = 1
  final int currentStep;

  /// 완료된 막대 색상 (기본: AppColors.black)
  final Color? activeColor;

  /// 미완료 막대 색상 (기본: AppColors.black100)
  final Color? inactiveColor;

  /// 막대 높이 (기본: 4.0px)
  final double barHeight;

  /// 막대 간격 (기본: 8.0px)
  final double spacing;

  // ============================================
  // 기본값 Getter 메서드
  // ============================================

  /// 기본 활성 색상
  Color get _effectiveActiveColor => activeColor ?? AppColors.black;

  /// 기본 비활성 색상
  Color get _effectiveInactiveColor => inactiveColor ?? AppColors.black100;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        totalSteps * 2 - 1, // 막대 + 간격 (마지막 간격 제외)
        (index) {
          // 짝수 인덱스: 막대, 홀수 인덱스: 간격
          if (index.isOdd) {
            return SizedBox(width: spacing.w);
          }

          final stepIndex = index ~/ 2;
          final isCompleted = stepIndex <= currentStep;

          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: barHeight.h,
              decoration: BoxDecoration(
                color: isCompleted
                    ? _effectiveActiveColor
                    : _effectiveInactiveColor,
                borderRadius: BorderRadius.circular(barHeight.r / 2),
              ),
            ),
          );
        },
      ),
    );
  }
}
