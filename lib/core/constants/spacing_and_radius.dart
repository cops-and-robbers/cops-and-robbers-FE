import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ============================================
// AppSpacing - 간격 규칙
// ============================================

/// 앱 전역 간격 상수 (숫자 값)
///
/// 사용법:
/// - SizedBox(height: AppSpacing.s16)
/// - Padding(padding: EdgeInsets.all(AppSpacing.s12))
class AppSpacing {
  // Private 생성자 - 인스턴스화 방지
  AppSpacing._();

  /// 4px 간격
  static double get s4 => 4.w;

  /// 8px 간격
  static double get s8 => 8.w;

  /// 12px 간격
  static double get s12 => 12.w;

  /// 16px 간격
  static double get s16 => 16.w;

  /// 20px 간격
  static double get s20 => 20.w;

  /// 24px 간격
  static double get s24 => 24.w;

  /// 32px 간격
  static double get s32 => 32.w;

  /// 40px 간격
  static double get s40 => 40.w;

  /// 48px 간격
  static double get s48 => 48.w;

  /// 56px 간격
  static double get s56 => 56.w;

  /// 64px 간격
  static double get s64 => 64.w;
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

  /// 모든 방향 4px
  static EdgeInsets get all4 => EdgeInsets.all(4.w);

  /// 모든 방향 8px
  static EdgeInsets get all8 => EdgeInsets.all(8.w);

  /// 모든 방향 12px
  static EdgeInsets get all12 => EdgeInsets.all(12.w);

  /// 모든 방향 16px
  static EdgeInsets get all16 => EdgeInsets.all(16.w);

  /// 모든 방향 20px
  static EdgeInsets get all20 => EdgeInsets.all(20.w);

  /// 모든 방향 24px
  static EdgeInsets get all24 => EdgeInsets.all(24.w);

  // ============================================
  // Horizontal 패턴 - 좌우 간격
  // ============================================

  /// 좌우 8px
  static EdgeInsets get horizontal8 => EdgeInsets.symmetric(horizontal: 8.w);

  /// 좌우 12px
  static EdgeInsets get horizontal12 => EdgeInsets.symmetric(horizontal: 12.w);

  /// 좌우 16px
  static EdgeInsets get horizontal16 => EdgeInsets.symmetric(horizontal: 16.w);

  /// 좌우 20px
  static EdgeInsets get horizontal20 => EdgeInsets.symmetric(horizontal: 20.w);

  /// 좌우 24px
  static EdgeInsets get horizontal24 => EdgeInsets.symmetric(horizontal: 24.w);

  // ============================================
  // Vertical 패턴 - 상하 간격
  // ============================================

  /// 상하 8px
  static EdgeInsets get vertical8 => EdgeInsets.symmetric(vertical: 8.h);

  /// 상하 12px
  static EdgeInsets get vertical12 => EdgeInsets.symmetric(vertical: 12.h);

  /// 상하 16px
  static EdgeInsets get vertical16 => EdgeInsets.symmetric(vertical: 16.h);

  /// 상하 20px
  static EdgeInsets get vertical20 => EdgeInsets.symmetric(vertical: 20.h);

  /// 상하 24px
  static EdgeInsets get vertical24 => EdgeInsets.symmetric(vertical: 24.h);

  // ============================================
  // 조합 패턴 - 자주 사용하는 특정 조합
  // ============================================

  /// 화면 전체 기본 패딩 (좌우 20px, 상하 16px)
  static EdgeInsets get screenPadding =>
      EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h);

  /// 카드 내부 패딩 (모든 방향 16px)
  static EdgeInsets get cardPadding => EdgeInsets.all(16.w);

  /// 리스트 아이템 패딩 (좌우 16px, 상하 12px)
  static EdgeInsets get listItemPadding =>
      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h);

  /// 버튼 내부 패딩 (좌우 24px, 상하 12px)
  static EdgeInsets get buttonPadding =>
      EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h);
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

  /// 라운드 없음 (0px)
  static BorderRadius get none => BorderRadius.zero;

  /// 작은 라운드 (4px)
  static BorderRadius get small => BorderRadius.circular(4.r);

  /// 중간 라운드 (8px)
  static BorderRadius get medium => BorderRadius.circular(8.r);

  /// 큰 라운드 (12px)
  static BorderRadius get large => BorderRadius.circular(12.r);

  /// 매우 큰 라운드 (16px)
  static BorderRadius get xlarge => BorderRadius.circular(16.r);

  /// 초대형 라운드 (24px)
  static BorderRadius get xxlarge => BorderRadius.circular(24.r);

  // ============================================
  // 특수 목적 프리셋
  // ============================================

  /// 버튼용 라운드 (8px)
  static BorderRadius get button => BorderRadius.circular(8.r);

  /// 카드용 라운드 (12px)
  static BorderRadius get card => BorderRadius.circular(12.r);

  /// 모달 상단 라운드 (상단만 16px)
  static BorderRadius get modal =>
      BorderRadius.vertical(top: Radius.circular(16.r));

  /// 칩/태그용 라운드 (완전 둥글게)
  static BorderRadius get chip => BorderRadius.circular(100.r);

  /// 입력 필드용 라운드 (8px)
  static BorderRadius get input => BorderRadius.circular(8.r);
}
