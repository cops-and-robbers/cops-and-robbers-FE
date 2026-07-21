import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import 'custom_progress_bar.dart';
import 'loading_content_view.dart';

/// 로딩 중 표시하는 전체 페이지
///
/// 스플래시·딥링크 참가처럼 **화면 자체가 로딩인** 경우 사용한다.
/// 비동기 작업 중 잠깐 덮는 경우에는 `AppLoading.show()`(오버레이)를 쓴다.
/// 두 진입점은 같은 뷰([LoadingContentView])를 공유한다.
///
/// ```dart
/// LoadingPage(message: '작전 지역으로 복귀 중...', subtitle: '잠시만 기다려주세요')
/// LoadingPage(message: '방 입장 중...', progress: 0.7, showPercentage: true)
/// ```
class LoadingPage extends StatelessWidget {
  const LoadingPage({
    super.key,
    required this.message,
    this.subtitle,
    this.progress,
    this.showPercentage = false,
    this.isDarkMode = false,
  });

  /// 제목 (필수)
  final String message;

  /// 안심 서브카피 (선택)
  final String? subtitle;

  /// 진행률 0.0~1.0. null이면 진행률 바를 숨긴다(진행률을 알 수 없는 경우)
  final double? progress;

  /// 진행률 퍼센트 표시 여부
  final bool showPercentage;

  /// true = 도둑(다크), false = 경찰(라이트, 기본값)
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.black : AppColors.white,
      body: LoadingContentView(
        message: message,
        subtitle: subtitle,
        isDarkMode: isDarkMode,
        bottom: progress == null
            ? null
            : CustomProgressBar(
                progress: progress!,
                showPercentage: showPercentage,
              ),
      ),
    );
  }
}
