import 'package:flutter/material.dart';

import 'app_colors.dart';

/// 앱 전역 쉐도우 토큰
/// App Global Shadow Tokens
///
/// 새 코드는 값을 새로 만들지 않고 이 중 하나를 골라 쓴다.
/// 모두 `List<BoxShadow>`를 반환해 `boxShadow:`에 바로 대입할 수 있다.
///
/// 사용법:
/// - BoxDecoration(boxShadow: AppShadows.ver2)
class AppShadows {
  // Private 생성자 - 인스턴스화 방지
  // Private constructor to prevent instantiation
  AppShadows._();

  /// ver2 - 카드·버튼용 부드러운 확산 쉐도우 (x0 y0 blur10, 7%)
  static List<BoxShadow> get ver2 => [
    BoxShadow(
      offset: const Offset(0, 0),
      blurRadius: 10,
      color: AppColors.black.withValues(alpha: 0.07),
    ),
  ];

  /// 우하단으로 살짝 떨어지는 기본 쉐도우 (x1 y1 blur8, 10%)
  static List<BoxShadow> get soft => [
    BoxShadow(
      offset: const Offset(1, 1),
      blurRadius: 8,
      color: AppColors.black.withValues(alpha: 0.1),
    ),
  ];

  /// [soft]의 다크모드 대응 변형 — 다크에서는 흰색 글로우로 뒤집는다
  static List<BoxShadow> softThemed(bool isDarkMode) => [
    BoxShadow(
      offset: const Offset(1, 1),
      blurRadius: 8,
      spreadRadius: 0,
      color: isDarkMode
          ? AppColors.white.withValues(alpha: 0.2)
          : AppColors.black.withValues(alpha: 0.1),
    ),
  ];

  /// 하단 시트가 위로 떠 보이게 하는 위쪽 방향 쉐도우 (x0 y-2 blur10, 10%)
  static List<BoxShadow> get topLift => [
    BoxShadow(
      offset: const Offset(0, -2),
      blurRadius: 10,
      color: AppColors.black.withValues(alpha: 0.1),
    ),
  ];

  /// [topLift]의 다크모드 대응 변형
  static List<BoxShadow> topLiftThemed(bool isDarkMode) => [
    BoxShadow(
      offset: const Offset(0, -2),
      blurRadius: 10,
      color: isDarkMode ? AppColors.black : AppColors.black200,
    ),
  ];

  /// 리스트 카드용 얕은 쉐도우 (x0 y1 blur4)
  static List<BoxShadow> get card => [
    BoxShadow(
      offset: const Offset(0, 1),
      blurRadius: 4,
      color: AppColors.black100,
    ),
  ];

  /// shadow_vague - 은은하게 퍼지는 쉐도우 (x0 y0 blur4, 10%)
  static List<BoxShadow> get vague => [
    BoxShadow(
      offset: const Offset(0, 0),
      blurRadius: 4,
      color: AppColors.black.withValues(alpha: 0.1),
    ),
  ];
}
