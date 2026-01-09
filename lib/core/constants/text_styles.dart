import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 앱 전역 TextStyle 상수
///
/// 사용법:
/// ```dart
/// // 1. 기본 사용
/// Text('제목', style: AppTextStyles.heading1)
/// Text('본문', style: AppTextStyles.body1)
///
/// // 2. Weight 변경 (Extension 활용)
/// Text('굵은 제목', style: AppTextStyles.heading1.bold())
/// Text('중간 굵기', style: AppTextStyles.body2.medium())
/// Text('가벼운 텍스트', style: AppTextStyles.caption.light())
///
/// // 3. 색상 및 기타 속성 변경
/// Text('빨간 글씨', style: AppTextStyles.body1.copyWith(color: Colors.red))
/// Text('밑줄', style: AppTextStyles.body2.medium().copyWith(decoration: TextDecoration.underline))
///
/// // 4. Weight + 색상 조합
/// Text('진한 파란 제목', style: AppTextStyles.heading2.bold().copyWith(color: Colors.blue))
/// ```
class AppTextStyles {
  // Private 생성자 - 인스턴스화 방지
  AppTextStyles._();

  // ============================================
  // Heading Styles (제목)
  // ============================================

  /// Heading 1 - 메인 타이틀 (32sp)
  static TextStyle get heading1 =>
      TextStyle(fontFamily: 'Pretendard-Regular', fontSize: 32.sp);

  /// Heading 2 - 섹션 제목 (28sp)
  static TextStyle get heading2 =>
      TextStyle(fontFamily: 'Pretendard-Regular', fontSize: 28.sp);

  /// Heading 3 - 서브 제목 (24sp)
  static TextStyle get heading3 =>
      TextStyle(fontFamily: 'Pretendard-Regular', fontSize: 24.sp);

  /// Heading 4 - 작은 제목 (20sp)
  static TextStyle get heading4 =>
      TextStyle(fontFamily: 'Pretendard-Regular', fontSize: 20.sp);

  // ============================================
  // Body Styles (본문)
  // ============================================

  /// Body 1 - 본문 강조 (16sp)
  static TextStyle get body1 =>
      TextStyle(fontFamily: 'Pretendard-Regular', fontSize: 16.sp);

  /// Body 2 - 본문 기본 (14sp)
  static TextStyle get body2 =>
      TextStyle(fontFamily: 'Pretendard-Regular', fontSize: 14.sp);

  // ============================================
  // Small Styles (작은 텍스트)
  // ============================================

  /// Caption - 설명, 라벨 (12sp)
  static TextStyle get caption =>
      TextStyle(fontFamily: 'Pretendard-Regular', fontSize: 12.sp);

  /// Overline - 작은 라벨 (10sp)
  static TextStyle get overline =>
      TextStyle(fontFamily: 'Pretendard-Regular', fontSize: 10.sp);
}

/// TextStyle Extension - Pretendard Weight 변경 메서드
///
/// 사용 예시:
/// - AppTextStyles.heading1.bold()
/// - AppTextStyles.body1.medium()
extension TextStyleExtension on TextStyle {
  /// Thin (100) - 장식적 대형 텍스트
  TextStyle thin() => copyWith(fontFamily: 'Pretendard-Thin');

  /// ExtraLight (200) - 매우 얇은 텍스트
  TextStyle extraLight() => copyWith(fontFamily: 'Pretendard-ExtraLight');

  /// Light (300) - 부드러운 제목
  TextStyle light() => copyWith(fontFamily: 'Pretendard-Light');

  /// Regular (400) - 기본 본문
  TextStyle regular() => copyWith(fontFamily: 'Pretendard-Regular');

  /// Medium (500) - 강조 본문
  TextStyle medium() => copyWith(fontFamily: 'Pretendard-Medium');

  /// SemiBold (600) - 서브 제목
  TextStyle semiBold() => copyWith(fontFamily: 'Pretendard-SemiBold');

  /// Bold (700) - 강조 제목
  TextStyle bold() => copyWith(fontFamily: 'Pretendard-Bold');

  /// ExtraBold (800) - 매우 강한 강조
  TextStyle extraBold() => copyWith(fontFamily: 'Pretendard-ExtraBold');

  /// Black (900) - 특별 강조
  TextStyle black() => copyWith(fontFamily: 'Pretendard-Black');
}
