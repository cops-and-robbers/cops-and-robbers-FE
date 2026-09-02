import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 앱 전역 TextStyle 상수
///
/// 사용법:
/// ```dart
/// // 기본 사용
/// Text('제목', style: AppTextStyles.heading_24)
/// Text('본문', style: AppTextStyles.paragraph_14)
///
/// // 색상 변경
/// Text('빨간 제목', style: AppTextStyles.heading_24.copyWith(color: Colors.red))
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

  /// SemiBold56 - 초대형 숫자 (56px SemiBold) — 게임 결과 이동 거리
  /// Line Height: 100%, Letter Spacing: -0.32px
  static TextStyle get semibold_56 => TextStyle(
    fontFamily: 'Pretendard-SemiBold',
    fontSize: 56.sp,
    height: 1.0,
    letterSpacing: -0.32,
  );

  /// SemiBold44 - 대형 숫자 (44px SemiBold)
  /// Line Height: 100%, Letter Spacing: -0.32px
  static TextStyle get semibold_44 => TextStyle(
    fontFamily: 'Pretendard-SemiBold',
    fontSize: 44.sp,
    height: 1.0,
    letterSpacing: -0.32,
  );

  /// SemiBold28 - 초대 코드 (28px SemiBold)
  /// Line Height: 100%, Letter Spacing: -0.32px
  static TextStyle get semibold_28 => TextStyle(
    fontFamily: 'Pretendard-SemiBold',
    fontSize: 28.sp,
    height: 1.0, // 100% line height
    letterSpacing: -0.32,
  );

  /// Heading01 - 메인 타이틀 (24px SemiBold)
  /// Line Height: 100%, Letter Spacing: -0.32px
  static TextStyle get heading_24 => TextStyle(
    fontFamily: 'Pretendard-SemiBold',
    fontSize: 24.sp,
    height: 1.0, // 100% line height
    letterSpacing: -0.32,
  );

  /// Heading02 - 섹션 제목 (20px SemiBold)
  /// Line Height: 100%, Letter Spacing: -0.32px
  static TextStyle get heading_20 => TextStyle(
    fontFamily: 'Pretendard-SemiBold',
    fontSize: 20.sp,
    height: 1.0, // 100% line height
    letterSpacing: -0.32,
  );

  /// SubHeading - 서브 제목 (18px SemiBold)
  /// Line Height: 100%, Letter Spacing: -0.32px
  static TextStyle get subHeading_18 => TextStyle(
    fontFamily: 'Pretendard-SemiBold',
    fontSize: 18.sp,
    height: 1.0, // 100% line height
    letterSpacing: -0.32,
  );

  // ============================================
  // Body Styles (Medium)
  // ============================================

  /// Label - 라벨, 강조 텍스트 (16px SemiBold)
  /// Line Height: 140%, Letter Spacing: -0.32px
  static TextStyle get label_16 => TextStyle(
    fontFamily: 'Pretendard-SemiBold',
    fontSize: 16.sp,
    height: 1.0, // 140% line height
    letterSpacing: -0.32,
  );

  /// Label - 버튼 기본 텍스트 (18px SemiBold) - AppButton 기본값 (#540)
  /// Line Height: 100%, Letter Spacing: -0.32px (전 스타일 공통 고정값)
  static TextStyle get label_18 => TextStyle(
    fontFamily: 'Pretendard-SemiBold',
    fontSize: 18.sp,
    height: 1.0, // 100% line height
    letterSpacing: -0.32,
  );

  static TextStyle get label16Medium => TextStyle(
    fontFamily: 'Pretendard-Medium',
    fontSize: 16.sp,
    height: 1.0, // 140% line height
    letterSpacing: -0.32,
  );

  /// Paragraph - 본문 (14px Medium)
  /// Line Height: 140%, Letter Spacing: -0.32px
  static TextStyle get paragraph_14 => TextStyle(
    fontFamily: 'Pretendard-Medium',
    fontSize: 14.sp,
    height: 1.4, // 140% line height
    letterSpacing: -0.32,
  );

  static TextStyle get paragraph14Regular => TextStyle(
    fontFamily: 'Pretendard-Regular',
    fontSize: 14.sp,
    height: 1.0, // 100% line height
    letterSpacing: -0.32,
  );

  static TextStyle get paragraph_14_100 => TextStyle(
    fontFamily: 'Pretendard-Medium',
    fontSize: 14.sp,
    height: 1.0, // 100% line height
    letterSpacing: -0.32,
  );

  static TextStyle get paragraph14bold => TextStyle(
    fontFamily: 'Pretendard-Bold',
    fontSize: 14.sp,
    height: 1.0, // 100% line height
    letterSpacing: -0.32,
  );

  static TextStyle get paragraph14Semibold => TextStyle(
    fontFamily: 'Pretendard-SemiBold',
    fontSize: 14.sp,
    height: 1.0, // 100% line height
    letterSpacing: -0.32,
  );

  // ============================================
  // Small Styles (Medium)
  // ============================================

  /// Callout / Tag - 작은 라벨, 태그 (12px Medium)
  /// Line Height: 140%, Letter Spacing: -0.32px

  /// Tag SemiBold - 강조 태그, 배지 (12px SemiBold)
  /// Line Height: 100%, Letter Spacing: -0.32px
  static TextStyle get tag12Semibold => TextStyle(
    fontFamily: 'Pretendard-SemiBold',
    fontSize: 12.sp,
    height: 1.0,
    letterSpacing: -0.32,
  );

  static TextStyle get tag_12 => TextStyle(
    fontFamily: 'Pretendard-Medium',
    fontSize: 12.sp,
    height: 1.0, // 100% line height
    letterSpacing: -0.32,
  );

  static TextStyle get tag_14 => TextStyle(
    fontFamily: 'Pretendard-Medium',
    fontSize: 14.sp,
    height: 1.0, // 100% line height
    letterSpacing: -0.32,
  );

  static TextStyle get tag_10 => TextStyle(
    fontFamily: 'Pretendard-Medium',
    fontSize: 10.sp,
    height: 1.0, // 100% line height
    letterSpacing: -0.32,
  );

  /// Chatroom Text - 커뮤니티 채팅 말풍선 본문 (14px Medium)
  /// Line Height: 140%, Letter Spacing: -0.32px
  // ignore: non_constant_identifier_names
  static TextStyle get chatroom_text_14 => TextStyle(
    fontFamily: 'Pretendard-Medium',
    fontSize: 14.sp,
    height: 1.4, // 140% line height
    letterSpacing: -0.32,
  );

  /// Tag Bold - 강조 태그 (10px Bold)
  /// Line Height: 100%, Letter Spacing: -0.32px
  static TextStyle get tag10Bold => TextStyle(
    fontFamily: 'Pretendard-Bold',
    fontSize: 10.sp,
    height: 1.0,
    letterSpacing: -0.32,
  );

  // ============================================
  // Robber Styles (Moneygraphy)
  // ============================================

  /// Robber Heading 24 (24px Moneygraphy)
  /// Line Height: 100%, Letter Spacing: -0.32px
  static TextStyle get robberHeading24 => TextStyle(
    fontFamily: 'Moneygraphy',
    fontSize: 24.sp,
    height: 1.0,
    letterSpacing: -0.32,
  );

  /// Robber Heading (20px Moneygraphy)
  /// Line Height: 100%, Letter Spacing: -0.32px
  static TextStyle get robberHeading => TextStyle(
    fontFamily: 'Moneygraphy',
    fontSize: 20.sp,
    height: 1.0,
    letterSpacing: -0.32,
  );

  /// Robber SubHeading (18px Moneygraphy)
  /// Line Height: 100%, Letter Spacing: -0.32px
  static TextStyle get robberSubHeading => TextStyle(
    fontFamily: 'Moneygraphy',
    fontSize: 18.sp,
    height: 1.0,
    letterSpacing: -0.32,
  );

  /// Robber Label (16px Moneygraphy)
  /// Line Height: 100%, Letter Spacing: -0.32px
  static TextStyle get robberLabel => TextStyle(
    fontFamily: 'Moneygraphy',
    fontSize: 16.sp,
    height: 1.0,
    letterSpacing: -0.32,
  );

  /// Robber Paragraph (14px Moneygraphy)
  /// Line Height: 100%, Letter Spacing: -0.32px
  static TextStyle get robberParagraph => TextStyle(
    fontFamily: 'Moneygraphy',
    fontSize: 14.sp,
    height: 1.0,
    letterSpacing: -0.32,
  );
}
