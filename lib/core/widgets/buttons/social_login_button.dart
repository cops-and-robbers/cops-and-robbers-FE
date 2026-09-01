import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../constants/app_colors.dart';
import '../../constants/spacing_and_radius.dart';
import 'app_button.dart';

/// Google 소셜 로그인 버튼
///
/// **디자인 스펙**:
/// - 배경색: AppColors.black100 (#EDF0F2)
/// - 텍스트색: AppColors.black (#080A0C)
/// - 아이콘: assets/icons/icon_google.svg (20x20)
/// - 아이콘-텍스트 간격: 8px
///
/// **사용 예시**:
/// ```dart
/// GoogleLoginButton(
///   onPressed: () => handleGoogleLogin(),
///   isLoading: isLoading,
/// )
/// ```
class GoogleLoginButton extends StatelessWidget {
  const GoogleLoginButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  /// 버튼 클릭 핸들러
  final VoidCallback? onPressed;

  /// 로딩 상태
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: AppLocalizations.of(context).buttonGoogleSignIn,
      onPressed: onPressed,
      icon: SvgPicture.asset(
        'assets/icons/icon_google.svg',
        width: AppSpacing.horizontal20,
        height: AppSpacing.vertical20,
      ),
      iconPosition: IconPosition.leading,
      backgroundColor: AppColors.white,
      foregroundColor: const Color(0xFF000000),
      showBorder: true,
      isLoading: isLoading,
    );
  }
}

/// Apple 소셜 로그인 버튼
///
/// **디자인 스펙**:
/// - 배경색: AppColors.black (#080A0C)
/// - 텍스트색: AppColors.white (#FFFFFF)
/// - 아이콘: assets/icons/icon_apple.svg (20x20)
/// - 아이콘-텍스트 간격: 8px
///
/// **사용 예시**:
/// ```dart
/// AppleLoginButton(
///   onPressed: () => handleAppleLogin(),
///   isLoading: isLoading,
/// )
/// ```
class AppleLoginButton extends StatelessWidget {
  const AppleLoginButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  /// 버튼 클릭 핸들러
  final VoidCallback? onPressed;

  /// 로딩 상태
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: AppLocalizations.of(context).buttonAppleSignIn,
      onPressed: onPressed,
      icon: SvgPicture.asset(
        'assets/icons/icon_apple.svg',
        width: AppSpacing.horizontal20,
        height: AppSpacing.vertical20,
      ),
      iconPosition: IconPosition.leading,
      backgroundColor: AppColors.black,
      isLoading: isLoading,
    );
  }
}
