import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 앱 전역 TextStyle 상수
///
/// 사용법:
/// ```dart
/// // 기본 사용
/// Text('제목', style: AppTextStyles.heading01)
/// Text('본문', style: AppTextStyles.paragraph)
///
/// // 색상 변경
/// Text('빨간 제목', style: AppTextStyles.heading01.copyWith(color: Colors.red))
/// ```
///
/// Weight:
/// - SemiBold: heading01, heading02, subHeading, label
/// - Medium: paragraph, toast, callout, calloutSmall
class AppTextStyles {
  // Private 생성자 - 인스턴스화 방지
  AppTextStyles._();

  // ============================================
  // Heading Styles (SemiBold)
  // ============================================

  /// Heading01 - 메인 타이틀 (24px SemiBold)
  /// Line Height: 100%, Letter Spacing: -0.32px
  static TextStyle get heading01 => TextStyle(
    fontFamily: 'Pretendard-SemiBold',
    fontSize: 24.sp,
    height: 1.0, // 100% line height
    letterSpacing: -0.32,
  );

  /// Heading02 - 섹션 제목 (20px SemiBold)
  /// Line Height: 100%, Letter Spacing: -0.32px
  static TextStyle get heading02 => TextStyle(
    fontFamily: 'Pretendard-SemiBold',
    fontSize: 20.sp,
    height: 1.0, // 100% line height
    letterSpacing: -0.32,
  );

  /// SubHeading - 서브 제목 (18px SemiBold)
  /// Line Height: 100%, Letter Spacing: -0.32px
  static TextStyle get subHeading => TextStyle(
    fontFamily: 'Pretendard-SemiBold',
    fontSize: 18.sp,
    height: 1.0, // 100% line height
    letterSpacing: -0.32,
  );

  /// Label - 라벨, 강조 텍스트 (16px SemiBold)
  /// Line Height: 100%, Letter Spacing: -0.32px
  static TextStyle get label => TextStyle(
    fontFamily: 'Pretendard-SemiBold',
    fontSize: 16.sp,
    height: 1.0, // 100% line height
    letterSpacing: -0.32,
  );

  // ============================================
  // Body Styles (Medium)
  // ============================================

  /// Paragraph - 본문 (14px Medium)
  /// Line Height: 140%, Letter Spacing: -0.32px
  static TextStyle get paragraph => TextStyle(
    fontFamily: 'Pretendard-Medium',
    fontSize: 14.sp,
    height: 1.4, // 140% line height
    letterSpacing: -0.32,
  );

  /// Toast - 알림 메시지 (14px Medium)
  /// Line Height: 140%, Letter Spacing: -0.32px
  static TextStyle get toast => TextStyle(
    fontFamily: 'Pretendard-Medium',
    fontSize: 14.sp,
    height: 1.4, // 140% line height
    letterSpacing: -0.32,
  );

  // ============================================
  // Small Styles (Medium)
  // ============================================

  /// Callout / Tag - 작은 라벨, 태그 (12px Medium)
  /// Line Height: 140%, Letter Spacing: -0.32px
  static TextStyle get callout => TextStyle(
    fontFamily: 'Pretendard-Medium',
    fontSize: 12.sp,
    height: 1.4, // 140% line height
    letterSpacing: -0.32,
  );

  /// Tag - Callout의 alias (디자인 스펙 용어)
  static TextStyle get tag => callout;

  /// CalloutSmall / TagSmall - 매우 작은 라벨 (10px Medium)
  /// Line Height: 140%, Letter Spacing: -0.32px
  static TextStyle get calloutSmall => TextStyle(
    fontFamily: 'Pretendard-Medium',
    fontSize: 10.sp,
    height: 1.4, // 140% line height
    letterSpacing: -0.32,
  );

  /// TagSmall - CalloutSmall의 alias (디자인 스펙 용어)
  static TextStyle get tagSmall => calloutSmall;

  // ============================================
  // Special Styles
  // ============================================

  /// InviteCode - 초대 코드 표시 (32px SemiBold)
  /// Line Height: 100%, Letter Spacing: 4px
  static TextStyle get inviteCode => TextStyle(
    fontFamily: 'Pretendard-SemiBold',
    fontSize: 32.sp,
    height: 1.0, // 100% line height
    letterSpacing: 4,
  );
}
