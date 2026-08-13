import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ============================================
// AppSpacing - 간격 규칙
// ============================================

/// 앱 전역 간격 상수 (숫자 값)
///
/// 사용법:
/// - SizedBox(height: AppSpacing.vertical16)  // 세로 간격 (높이 기준)
/// - SizedBox(width: AppSpacing.horizontal16)  // 가로 간격 (너비 기준)
/// - EdgeInsets.only(left: AppSpacing.horizontal20)
/// - EdgeInsets.only(top: AppSpacing.vertical20)
class AppSpacing {
  // Private 생성자 - 인스턴스화 방지
  AppSpacing._();

  // ============================================
  // Horizontal Spacing - 좌우 간격 (너비 기준)
  // ============================================

  /// 좌우 2px 간격 (아이콘 ↔ 숫자)
  static double get horizontal2 => 2.w;

  /// 좌우 4px 간격
  static double get horizontal4 => 4.w;

  /// 좌우 6px 간격
  static double get horizontal6 => 6.w;

  /// 좌우 8px 간격
  static double get horizontal8 => 8.w;

  /// 좌우 10px 간격
  static double get horizontal10 => 10.w;

  /// 좌우 12px 간격
  static double get horizontal12 => 12.w;

  /// 좌우 16px 간격
  static double get horizontal16 => 16.w;

  /// 좌우 18px 간격
  static double get horizontal18 => 18.w;

  /// 좌우 20px 간격
  static double get horizontal20 => 20.w;

  /// 좌우 24px 간격
  static double get horizontal24 => 24.w;

  /// 좌우 22px 간격 (커뮤니티 카드 좌우 패딩)
  static double get horizontal22 => 22.w;

  /// 좌우 26px 간격 (바텀시트 구분선 인셋)
  static double get horizontal26 => 26.w;

  // ============================================
  // Vertical Spacing - 상하 간격 (높이 기준)
  // ============================================

  /// 상하 4px 간격
  static double get vertical4 => 4.h;

  /// 상하 6px 간격
  static double get vertical6 => 6.h;

  /// 상하 8px 간격
  static double get vertical8 => 8.h;

  // 상하 10px 간격
  static double get vertical10 => 10.h;

  /// 상하 12px 간격
  static double get vertical12 => 12.h;

  /// 상하 14px 간격
  static double get vertical14 => 14.h;

  /// 상하 16px 간격
  static double get vertical16 => 16.h;

  /// 상하 18px 간격
  static double get vertical18 => 18.h;

  /// 상하 20px 간격
  static double get vertical20 => 20.h;

  /// 상하 24px 간격
  static double get vertical24 => 24.h;

  /// 상하 26px 간격 (커뮤니티 범위 토글 ↔ 정렬 라벨)
  static double get vertical26 => 26.h;

  /// 상하 28px 간격
  static double get vertical28 => 28.h;

  /// 상하 32px 간격
  static double get vertical32 => 32.h;

  /// 상하 40px 간격
  static double get vertical40 => 40.h;

  /// 상하 48px 간격
  static double get vertical48 => 48.h;

  /// 상하 50px 간격
  static double get vertical50 => 50.h;

  /// 상하 58px 간격
  static double get vertical58 => 58.h;

  /// 상하 64px 간격
  static double get vertical64 => 64.h;
}

// ============================================
// AppPadding - EdgeInsets 프리셋
// ============================================

/// 앱 전역 Padding 프리셋
///
/// 사용법:
/// - Padding(padding: AppPadding.all16)
/// - Container(padding: AppPadding.horizontal20)
class AppPadding {
  // Private 생성자 - 인스턴스화 방지
  AppPadding._();

  // ============================================
  // All 패턴 - 모든 방향 동일한 간격
  // ============================================

  /// 모든 방향 16px
  static EdgeInsets get all16 => EdgeInsets.all(16.w);

  /// 모든 방향 20px
  static EdgeInsets get all20 => EdgeInsets.all(20.w);

  /// 모든 방향 24px
  static EdgeInsets get all24 => EdgeInsets.all(24.w);

  // ============================================
  // Horizontal 패턴 - 좌우 간격
  // ============================================

  /// 좌우 16px
  static EdgeInsets get horizontal16 => EdgeInsets.symmetric(horizontal: 16.w);

  /// 좌우 20px
  static EdgeInsets get horizontal20 => EdgeInsets.symmetric(horizontal: 20.w);

  /// 좌우 24px
  static EdgeInsets get horizontal24 => EdgeInsets.symmetric(horizontal: 24.w);

  /// 좌우 36px
  static EdgeInsets get horizontal36 => EdgeInsets.symmetric(horizontal: 36.w);
}

// ============================================
// AppRadius - BorderRadius 프리셋
// ============================================

/// 앱 전역 BorderRadius 상수
///
/// 사용법:
/// - Container(decoration: BoxDecoration(borderRadius: AppRadius.medium))
/// - Card(shape: RoundedRectangleBorder(borderRadius: AppRadius.large))
class AppRadius {
  // Private 생성자 - 인스턴스화 방지
  AppRadius._();

  // ============================================
  // 기본 라운드 값
  // ============================================

  /// 중간 라운드 (8px)
  static BorderRadius get medium => BorderRadius.circular(8.r);

  /// 큰 라운드 (12px)
  static BorderRadius get large => BorderRadius.circular(12.r);

  /// 매우 큰 라운드 (16px)
  static BorderRadius get xlarge => BorderRadius.circular(16.r);

  /// 18px 라운드 - 바텀시트 상단
  static BorderRadius get xl18 => BorderRadius.circular(18.r);

  /// 20px 라운드
  static BorderRadius get xl20 => BorderRadius.circular(20.r);

  /// 매우 매우 큰 라운드 (24px) - 다이얼로그 등
  static BorderRadius get xxlarge => BorderRadius.circular(24.r);

  /// 완전 원형 (pill/stadium) - 플로팅 바, 태그 등
  static BorderRadius get pill => BorderRadius.circular(9999.r);
}
