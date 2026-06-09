import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../constants/app_colors.dart';
import '../../constants/spacing_and_radius.dart';
import '../../constants/text_styles.dart';
import '../../services/vibration_service.dart';

/// 구역 타입 Enum
///
/// 플레이그라운드 (파란색 계열) vs 감옥 (빨간색 계열)
enum ZoneType {
  /// 플레이그라운드 (Playground) - 파란색 계열
  playground,

  /// 감옥 (Prison) - 빨간색 계열
  prison,
}

/// 구역 설정 페이지로 이동하는 버튼
///
/// **기능**:
/// - 구역 타입별 색상 자동 적용 (Playground: blue, Prison: red)
/// - 반경 설정 전/후 상태에 따른 동적 색상 변경
/// - 우측 화살표 아이콘 표시
/// - Column-Row 구조로 레이아웃 구성 (label + icon을 Row로, 그 아래 subtitle)
///
/// **색상 규칙**:
/// - **플레이그라운드 (Playground)**:
///   - 배경: blue100
///   - 반경 미설정: label_16 blue800, tag_12 blue800
///   - 반경 설정됨: label_16 blue, tag_12 blue800
///
/// - **감옥 (Prison)**:
///   - 배경: red100
///   - 반경 미설정: label_16 red800, tag_12 red800
///   - 반경 설정됨: label_16 red, tag_12 red800
///
/// **레이아웃 구조**:
/// ```
/// Container (고정 높이: 56h/76h, 패딩 없음)
///   └─ Padding (좌우 24px)
///       └─ Column (mainAxisAlignment: center, crossAxisAlignment: stretch)
///           ├─ Row (label + icon, spaceBetween)
///           ├─ SizedBox(8px) [조건부: subtitle 있을 때만]
///           └─ Text(subtitle) [조건부: subtitle 있을 때만]
/// ```
///
/// **사용 예시**:
/// ```dart
/// // 반경 미설정
/// ZoneSettingButton(
///   zoneType: ZoneType.playground,
///   title: '플레이그라운드',
///   onPressed: () => Navigator.push(...),
/// )
///
/// // 반경 설정됨 (subtitle 자동 표시, 높이 자동 증가)
/// ZoneSettingButton(
///   zoneType: ZoneType.playground,
///   title: '플레이그라운드',
///   radiusMeters: 400,
///   onPressed: () => Navigator.push(...),
/// )
/// ```
class ZoneSettingButton extends StatelessWidget {
  const ZoneSettingButton({
    super.key,
    required this.zoneType,
    required this.title,
    required this.onPressed,
    this.radiusMeters,
  });

  /// 구역 타입 (Playground / Prison)
  final ZoneType zoneType;

  /// 구역 이름 (예: "플레이그라운드", "감옥")
  final String title;

  /// 반경 (미터 단위, null이면 미설정 상태)
  final double? radiusMeters;

  /// 버튼 클릭 핸들러
  final VoidCallback onPressed;

  // ============================================
  // 색상 계산 Getter
  // ============================================

  /// 배경색 (구역 타입별)
  Color get _backgroundColor {
    return zoneType == ZoneType.playground
        ? AppColors.blue100
        : AppColors.red100;
  }

  /// 메인 텍스트 색상 (반경 설정 여부에 따라 변경)
  Color get _mainTextColor {
    if (radiusMeters != null) {
      // 반경 설정됨: 진한 색상 (blue / red)
      return zoneType == ZoneType.playground ? AppColors.blue : AppColors.red;
    } else {
      // 반경 미설정: 중간 색상 (blue800 / red800)
      return zoneType == ZoneType.playground
          ? AppColors.blue800
          : AppColors.red800;
    }
  }

  /// 서브 텍스트 색상 (항상 800 계열)
  Color get _subtitleColor {
    return zoneType == ZoneType.playground
        ? AppColors.blue800
        : AppColors.red800;
  }

  /// 아이콘 색상 (메인 텍스트와 동일)
  Color get _iconColor => _mainTextColor;

  /// 서브텍스트 (반경 미터 정보) — locale에 따라 i18n 적용
  ///
  /// 1000m 미만: "반경 400m" / "Radius 400m"
  /// 1000m 이상: "반경 1.50km" / "Radius 1.50km" (소수점 2자리 고정)
  String? _subtitleOf(BuildContext context) {
    if (radiusMeters == null) return null;
    final l10n = AppLocalizations.of(context);
    if (radiusMeters! >= 1000) {
      final km = (radiusMeters! / 1000).toStringAsFixed(2);
      return l10n.zoneRadiusKm(km);
    }
    return l10n.zoneRadiusMeter(radiusMeters!.toInt().toString());
  }

  // ============================================
  // Widget Build
  // ============================================

  @override
  Widget build(BuildContext context) {
    final subtitle = _subtitleOf(context);
    return InkWell(
      onTap: () {
        VibrationService.instance().buttonTap();
        onPressed();
      },
      borderRadius: AppRadius.xlarge,
      child: Container(
        width: 353.w,
        height: subtitle != null ? 76.h : 56.h,
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: AppRadius.xlarge,
        ),
        child: Padding(
          padding: EdgeInsets.only(left: 24.w, right: 16.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Row: label + icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.label_16.copyWith(
                      color: _mainTextColor,
                    ),
                  ),
                  SvgPicture.asset(
                    'assets/icons/icon_arrow.svg',
                    width: 24.w,
                    height: 24.h,
                    colorFilter: ColorFilter.mode(_iconColor, BlendMode.srcIn),
                  ),
                ],
              ),

              // 조건부: subtitle이 있을 때만 간격 + subtitle 표시
              if (subtitle != null) ...[
                SizedBox(height: AppSpacing.vertical4),
                Text(
                  subtitle,
                  style: AppTextStyles.tag_12.copyWith(color: _subtitleColor),
                ),
                SizedBox(height: AppSpacing.vertical8),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
