import 'package:flutter/material.dart';

/// 앱 전역 색상 팔레트
/// App Global Color Palette
///
/// 사용법:
/// - Container(color: AppColors.primary)
class AppColors {
  // Private 생성자 - 인스턴스화 방지
  // Private constructor to prevent instantiation
  AppColors._();

  // ============================================
  // 주요 색상 (Primary Colors)
  // ============================================

  /// 주요 색상 (Primary)
  /// Main brand color
  static const Color primary = Color(0xFF4A90E2);

  /// 보조 색상 (Secondary)
  /// Secondary brand color
  static const Color secondary = Color(0xFF64B5F6);

  // ============================================
  // 팀 색상 (Team Colors)
  // ============================================

  /// 경찰 팀 색상
  /// Police team color
  static const Color policeTeam = Color(0xFF2196F3);

  /// 도둑 팀 색상
  /// Robber team color
  static const Color robberTeam = Color(0xFFE53935);

  // ============================================
  // 배경 색상 (Background Colors)
  // ============================================

  /// 메인 배경색
  /// Main background color
  static const Color background = Color(0xFFFFFFFF);

  /// 서브 배경색
  /// Sub background color
  static const Color surfaceBackground = Color(0xFFF5F5F5);

  // ============================================
  // 텍스트 색상 (Text Colors)
  // ============================================

  /// 주요 텍스트 색상
  /// Primary text color
  static const Color textPrimary = Color(0xFF212121);

  /// 보조 텍스트 색상
  /// Secondary text color
  static const Color textSecondary = Color(0xFF757575);

  /// 비활성화 텍스트 색상
  /// Disabled text color
  static const Color textDisabled = Color(0xFFBDBDBD);

  // ============================================
  // 상태 색상 (Status Colors)
  // ============================================

  /// 성공 색상
  /// Success color
  static const Color success = Color(0xFF4CAF50);

  /// 경고 색상
  /// Warning color
  static const Color warning = Color(0xFFFF9800);

  /// 에러 색상
  /// Error color
  static const Color error = Color(0xFFF44336);

  /// 정보 색상
  /// Info color
  static const Color info = Color(0xFF2196F3);
}
