import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../features/game/domain/entities/area_shape.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_icons.dart';
import '../../constants/spacing_and_radius.dart';
import '../../constants/text_styles.dart';
import '../../services/vibration_service.dart';
import '../../utils/zone_metric_formatter.dart';

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
/// - 구역 설정 전/후 상태에 따른 동적 색상 변경
/// - 서브텍스트는 도형에 맞게 표시 (원형=반경, 폴리곤=면적)
/// - 우측 화살표 아이콘 표시
/// - Column-Row 구조로 레이아웃 구성 (label + icon을 Row로, 그 아래 subtitle)
///
/// **색상 규칙**:
/// - **플레이그라운드 (Playground)**:
///   - 배경: blue100
///   - 구역 미설정: label_16 blue800, tag_12 blue800
///   - 구역 설정됨: label_16 blue, tag_12 blue800
///
/// - **감옥 (Prison)**:
///   - 배경: red100
///   - 구역 미설정: label_16 red800, tag_12 red800
///   - 구역 설정됨: label_16 red, tag_12 red800
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
/// // 구역 미설정
/// ZoneSettingButton(
///   zoneType: ZoneType.playground,
///   title: '플레이그라운드',
///   onPressed: () => Navigator.push(...),
/// )
///
/// // 구역 설정됨 (subtitle 자동 표시, 높이 자동 증가)
/// ZoneSettingButton(
///   zoneType: ZoneType.playground,
///   title: '플레이그라운드',
///   shape: AreaShape.circle(center: center, radiusInMeters: 400),
///   onPressed: () => Navigator.push(...),
/// )
/// ```
class ZoneSettingButton extends StatelessWidget {
  const ZoneSettingButton({
    super.key,
    required this.zoneType,
    required this.title,
    required this.onPressed,
    this.shape,
  });

  /// 구역 타입 (Playground / Prison)
  final ZoneType zoneType;

  /// 구역 이름 (예: "플레이그라운드", "감옥")
  final String title;

  /// 설정된 구역 도형 (null이면 미설정 상태)
  final AreaShape? shape;

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

  /// 메인 텍스트 색상 (구역 설정 여부에 따라 변경)
  Color get _mainTextColor {
    if (shape != null) {
      // 구역 설정됨: 진한 색상 (blue / red)
      return zoneType == ZoneType.playground ? AppColors.blue : AppColors.red;
    } else {
      // 구역 미설정: 중간 색상 (blue800 / red800)
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

  /// 서브텍스트 (구역 크기) — 원형은 반경, 폴리곤은 면적
  ///
  /// 예: "반경 400m" / "반경 1.50km" / "면적 31,416m²" (locale에 따라 i18n 적용)
  String? _subtitleOf(BuildContext context) =>
      shape?.metricText(AppLocalizations.of(context));

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
                    AppIcons.arrow,
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
