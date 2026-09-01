import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/navigation/app_top_bar.dart';
import '../../../../core/widgets/indicators/step_indicator.dart';
import '../../../../l10n/app_localizations.dart';

/// 세션 생성 단계별 공통 레이아웃 위젯
///
/// 4단계 세션 생성 프로세스(구역 설정 → 인원 설정 → 게임 설정 → 초대 코드)에서
/// 공통으로 사용되는 UI 구조를 제공합니다.
///
/// **주요 기능**:
/// - StepIndicator가 포함된 AppBar
/// - 제목 + 설명 헤더 섹션
/// - 페이지별 컨텐츠 영역
/// - 하단 액션 버튼
/// - 로딩 상태 처리
///
/// **사용 예시**:
/// ```dart
/// SessionStepLayout(
///   currentStep: 0,
///   title: '구역을 먼저 설정할까요?',
///   description: '게임에 필요한 구역을 설정해요',
///   content: _buildZoneButtons(),
///   buttonText: '다음',
///   isButtonEnabled: isComplete,
///   onNext: _onNextPressed,
/// )
/// ```
class SessionStepLayout extends StatelessWidget {
  const SessionStepLayout({
    super.key,
    required this.currentStep,
    required this.title,
    required this.description,
    required this.content,
    this.buttonText,
    this.isButtonEnabled = true,
    required this.onNext,
    this.onPrevious,
    this.isLoading = false,
  });

  // ============================================
  // Properties
  // ============================================

  /// 현재 단계 (0~3)
  final int currentStep;

  /// 헤더 제목 (예: "구역을 먼저 설정할까요?")
  final String title;

  /// 헤더 설명 (예: "게임에 필요한 구역을 설정해요")
  final String description;

  /// 페이지별 메인 컨텐츠 위젯
  final Widget content;

  /// 하단 버튼 텍스트 (null이면 l10n 기본값 "다음" 사용)
  final String? buttonText;

  /// 하단 버튼 활성화 여부 (기본값: true)
  final bool isButtonEnabled;

  /// 하단 버튼 클릭 시 콜백
  final VoidCallback onNext;

  /// 뒤로가기 버튼 클릭 시 콜백 (null이면 기본 context.pop())
  final VoidCallback? onPrevious;

  /// 로딩 중 여부 (true면 CircularProgressIndicator 표시)
  final bool isLoading;

  // ============================================
  // Build Methods
  // ============================================

  @override
  Widget build(BuildContext context) {
    // 로딩 중이면 로딩 인디케이터 표시
    if (isLoading) {
      return Scaffold(
        backgroundColor: AppColors.white,
        appBar: _buildAppBar(context),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // 정상 레이아웃
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Padding(
          padding: AppPadding.all20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppSpacing.vertical16),
              _buildHeader(),
              SizedBox(height: AppSpacing.vertical28),
              content,
              const Spacer(),
              _buildNextButton(l10n),
            ],
          ),
        ),
      ),
    );
  }

  /// AppBar 생성 (StepIndicator + PreviousButton)
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppTopBar(
      titleWidget: StepIndicator(totalSteps: 4, currentStep: currentStep),
      centerTitle: false,
      titleSpacing: 0,
      onBack: onPrevious ?? () => context.pop(),
      actions: [SizedBox(width: AppSpacing.horizontal20)],
    );
  }

  /// 헤더 섹션 (제목 + 설명)
  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.horizontal4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.heading_24.copyWith(color: AppColors.black),
          ),
          SizedBox(height: AppSpacing.vertical16),
          Text(
            description,
            style: AppTextStyles.paragraph_14_100.copyWith(
              color: AppColors.black600,
            ),
          ),
        ],
      ),
    );
  }

  /// 하단 버튼 (다음/참여하기)
  Widget _buildNextButton(AppLocalizations l10n) {
    return AppButton(
      text: buttonText ?? l10n.buttonNext,
      onPressed: isButtonEnabled ? onNext : null,
    );
  }
}
