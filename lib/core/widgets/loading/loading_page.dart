import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/spacing_and_radius.dart';
import '../../constants/text_styles.dart';
import 'custom_progress_bar.dart';

/// 로딩 중 표시하는 페이지
///
/// 로그인, 방 입장, 게임 시작 등 비동기 작업 진행 중 사용자에게 피드백을 제공합니다.
/// CustomProgressBar를 사용하여 진행률을 시각적으로 표시할 수 있습니다.
///
/// **기본 스펙**:
/// - 배경색: AppColors.white (기본)
/// - 메시지: 중앙 표시
/// - ProgressBar: 하단에서 56px 위치
/// - 패딩: 20px (좌우)
///
/// **사용 예시**:
/// ```dart
/// // 기본 사용 (진행률 없음)
/// LoadingPage(
///   message: '로그인 중...',
/// )
///
/// // 진행률 표시
/// LoadingPage(
///   message: '방 입장 중...',
///   progress: 0.7,
///   showPercentage: true,
/// )
///
/// // 서브 메시지 포함
/// LoadingPage(
///   message: '게임 준비 중...',
///   subtitle: '잠시만 기다려주세요',
///   progress: 0.5,
/// )
///
/// // 어두운 배경
/// LoadingPage(
///   message: '로딩 중...',
///   backgroundColor: AppColors.black,
///   textColor: AppColors.white,
/// )
/// ```
class LoadingPage extends StatelessWidget {
  const LoadingPage({
    super.key,
    required this.message,
    this.subtitle,
    this.progress,
    this.showPercentage = false,
    this.backgroundColor,
    this.textColor,
  });

  /// 로딩 메시지 (필수)
  ///
  /// 중앙에 표시되는 메인 메시지
  /// 예: '로그인 중...', '방 입장 중...'
  final String message;

  /// 서브 메시지 (선택)
  ///
  /// 메인 메시지 아래 작게 표시되는 추가 설명
  /// 예: '잠시만 기다려주세요', '플레이어 동기화 중...'
  final String? subtitle;

  /// 진행률 0.0~1.0 (선택)
  ///
  /// null이면 ProgressBar 숨김 (진행률 알 수 없는 경우)
  /// 0.0 = 0%, 1.0 = 100%
  final double? progress;

  /// 진행률 퍼센트 표시 여부 (기본: false)
  final bool showPercentage;

  /// 배경색 (기본: AppColors.white)
  final Color? backgroundColor;

  /// 텍스트 색상 (기본: AppColors.black)
  final Color? textColor;

  // ============================================
  // 기본값 Getter 메서드
  // ============================================

  /// 기본 배경색
  Color get _effectiveBackgroundColor => backgroundColor ?? AppColors.white;

  /// 기본 텍스트 색상
  Color get _effectiveTextColor => textColor ?? AppColors.black;

  /// 서브 텍스트 색상 (약간 연하게)
  Color get _effectiveSubtitleColor =>
      textColor?.withValues(alpha: 0.7) ?? AppColors.black600;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _effectiveBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: AppPadding.all20,
          child: Column(
            children: [
              // 중앙 영역 (메시지)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 메인 메시지
                      Text(
                        message,
                        style: AppTextStyles.heading_20.copyWith(
                          color: _effectiveTextColor,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      // 서브 메시지 (있을 경우)
                      if (subtitle != null) ...[
                        SizedBox(height: AppSpacing.vertical8),
                        Text(
                          subtitle!,
                          style: AppTextStyles.paragraph_14.copyWith(
                            color: _effectiveSubtitleColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // ProgressBar (진행률이 있을 때만 표시)
              if (progress != null)
                CustomProgressBar(
                  progress: progress!,
                  showPercentage: showPercentage,
                ),

              // 하단 여백 (56px)
              SizedBox(height: 56.h),
            ],
          ),
        ),
      ),
    );
  }
}
