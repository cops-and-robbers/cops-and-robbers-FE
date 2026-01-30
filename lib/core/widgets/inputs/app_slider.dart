import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/spacing_and_radius.dart';
import '../../constants/text_styles.dart';

/// 앱 전역에서 사용하는 공용 슬라이더 컴포넌트
///
/// **기본 스펙**:
/// - 라벨 + 현재 값 표시 (상단)
/// - 슬라이더 (중간)
/// - 최소/최대 값 표시 (하단)
/// - 내부 패딩: 16px 고정
///
/// **색상 커스터마이징**:
/// - activeTrackColor: 슬라이더 활성 트랙 색상 (기본: AppColors.black800)
/// - thumbColor: 슬라이더 헤드(Thumb) 색상 (기본: AppColors.black)
/// - inactiveTrackColor: 슬라이더 비활성 트랙 색상 (기본: AppColors.black100)
///
/// **사용 예시**:
/// ```dart
/// // 기본 슬라이더 (검정 계열, 카드 스타일)
/// AppSlider(
///   label: '최대 인원',
///   value: _maxPlayers,
///   min: 5,
///   max: 50,
///   unit: '명',
///   onChanged: (value) => setState(() => _maxPlayers = value),
/// )
///
/// // 파란색 슬라이더
/// AppSlider(
///   label: '반경',
///   value: _radius,
///   min: 100,
///   max: 1000,
///   unit: 'm',
///   activeTrackColor: AppColors.blue800,
///   thumbColor: AppColors.blue,
///   inactiveTrackColor: AppColors.blue100,
///   onChanged: (value) => setState(() => _radius = value),
/// )
///
/// // 지도 위 오버레이 슬라이더 (컨테이너 없음)
/// AppSlider(
///   label: '플레이그라운드 반경',
///   value: _radius,
///   min: 100,
///   max: 1000,
///   unit: 'm',
///   showContainer: false,
///   width: 353.w,
///   onChanged: (value) => setState(() => _radius = value),
/// )
///
/// // 복합 텍스트 스타일 (NEW - 권장)
/// AppSlider(
///   label: '경찰 시작 시간',
///   value: _policeWaitTime,
///   min: 1,
///   max: 10,
///   unit: '분',
///   displayPrefix: '도둑 시작 후',
///   displaySuffix: '뒤',
///   onChanged: (value) => setState(() => _policeWaitTime = value),
/// )
///
/// // 커스텀 표시값 사용 (레거시)
/// AppSlider(
///   label: '경찰 시작 시간',
///   value: _policeWaitTime,
///   min: 1,
///   max: 10,
///   unit: '분',
///   displayValue: '도둑 시작 후 ${_policeWaitTime.toInt()}분 뒤',
///   onChanged: (value) => setState(() => _policeWaitTime = value),
/// )
///
/// // 값 변환 (m → km)
/// AppSlider(
///   label: '반경',
///   value: _radius,
///   min: 50,
///   max: 500,
///   unit: 'km',
///   divisions: 45,
///   valueFormatter: (value) => (value / 1000).toStringAsFixed(2),
///   onChanged: (value) => setState(() => _radius = value),
/// )
/// ```
class AppSlider extends StatelessWidget {
  const AppSlider({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
    required this.onChanged,
    this.displayValue,
    this.displayPrefix,
    this.displaySuffix,
    this.valueFormatter,
    this.activeTrackColor,
    this.thumbColor,
    this.inactiveTrackColor,
    this.backgroundColor,
    this.showMinMax = true,
    this.divisions,
    this.width,
    this.showContainer = true,
    this.labelColor,
    this.valueColor,
    this.minMaxColor,
  });

  /// 라벨 텍스트 (예: '최대 인원', '반경')
  final String label;

  /// 현재 슬라이더 값
  final double value;

  /// 최소값 (필수)
  final double min;

  /// 최대값 (필수)
  final double max;

  /// 단위 표시 (예: '명', '분', 'm')
  final String unit;

  /// 값 변경 콜백
  final ValueChanged<double> onChanged;

  /// 커스텀 표시값 (선택 사항, 예: '도둑 시작 후 5분 뒤')
  /// null이면 기본 포맷: '{value}{unit}'
  /// displayPrefix/displaySuffix와 함께 사용 불가
  final String? displayValue;

  /// 값 앞 설명 텍스트 (예: '도둑 시작 후')
  /// paragraph_14_100 스타일 + black800 색상 사용
  final String? displayPrefix;

  /// 값 뒤 추가 텍스트 (예: '뒤', '이내')
  /// label_16 스타일 + valueColor 사용
  final String? displaySuffix;

  /// 값 변환 함수 (예: m → km 변환)
  /// null이면 value를 그대로 사용
  final String Function(double)? valueFormatter;

  /// 슬라이더 활성 트랙 색상 (기본: AppColors.black800)
  final Color? activeTrackColor;

  /// 슬라이더 헤드(Thumb) 색상 (기본: AppColors.black)
  final Color? thumbColor;

  /// 슬라이더 비활성 트랙 색상 (기본: AppColors.black100)
  final Color? inactiveTrackColor;

  /// 컨테이너 배경색 (기본: AppColors.white)
  final Color? backgroundColor;

  /// 최소/최대 값 표시 여부 (기본: true)
  final bool showMinMax;

  /// 슬라이더 구간 분할 개수 (선택 사항)
  /// null이면 연속적으로 움직임
  /// 예: divisions: 45 → 5~50명을 45구간으로 분할 (1명 단위)
  final int? divisions;

  /// 슬라이더 너비 (선택 사항)
  /// - null: 부모 위젯의 너비에 맞춤 (권장)
  /// - double.infinity: 가능한 최대 너비
  /// - 특정 값: 고정 너비 (예: 300.w)
  final double? width;

  /// 컨테이너 표시 여부 (기본: true)
  /// - true: 카드 스타일 (Container + 패딩 + 테두리 + 배경)
  /// - false: 최소 스타일 (지도 오버레이용, 투명 배경)
  final bool showContainer;

  /// 라벨 텍스트 색상 (기본: AppColors.black)
  final Color? labelColor;

  /// 값 표시 텍스트 색상 (기본: thumbColor)
  final Color? valueColor;

  /// 최소/최대 라벨 색상 (기본: AppColors.black600)
  final Color? minMaxColor;

  // ============================================
  // 기본값 Getter 메서드
  // ============================================

  /// 활성 트랙 색상 (기본: AppColors.black800)
  Color get _effectiveActiveTrackColor {
    return activeTrackColor ?? AppColors.black800;
  }

  /// 헤드(Thumb) 색상 (기본: AppColors.black)
  Color get _effectiveThumbColor {
    return thumbColor ?? AppColors.black;
  }

  /// 비활성 트랙 색상 (기본: AppColors.black100)
  Color get _effectiveInactiveTrackColor {
    return inactiveTrackColor ?? AppColors.black100;
  }

  /// 배경색 (기본: AppColors.white)
  Color get _effectiveBackgroundColor {
    return backgroundColor ?? AppColors.white;
  }

  /// 라벨 색상 (기본: AppColors.black)
  Color get _effectiveLabelColor {
    return labelColor ?? AppColors.black;
  }

  /// 값 표시 색상 (기본: thumbColor)
  Color get _effectiveValueColor {
    return valueColor ?? _effectiveThumbColor;
  }

  /// 최소/최대 라벨 색상 (기본: AppColors.black600)
  Color get _effectiveMinMaxColor {
    return minMaxColor ?? AppColors.black600;
  }

  /// 트랙 높이 (showContainer에 따라 다름)
  /// - true (카드): 2px
  /// - false (오버레이): 8px
  double get _effectiveTrackHeight {
    return showContainer ? 2.h : 6.h;
  }

  /// 헤드 반지름 (showContainer에 따라 다름)
  /// - true (카드): 8px (지름 16px)
  /// - false (오버레이): 12px (지름 24px)
  double get _effectiveThumbRadius {
    return showContainer ? 8.r : 12.r;
  }

  /// Overlay 반지름 (헤드의 2배)
  /// - true (카드): 16px
  /// - false (오버레이): 24px
  double get _effectiveOverlayRadius {
    return showContainer ? 16.r : 24.r;
  }

  // ============================================
  // Widget Build
  // ============================================

  @override
  Widget build(BuildContext context) {
    // 컨테이너 없는 최소 스타일 (지도 오버레이용 - 슬라이더만)
    if (!showContainer) {
      return SizedBox(width: width, child: _buildSlider());
    }

    // 카드 스타일 (전체 콘텐츠 포함)
    return Container(
      width: width,
      padding: AppPadding.all20, // 외부 패딩 20px
      decoration: BoxDecoration(
        color: _effectiveBackgroundColor,
        borderRadius: AppRadius.xl20, // 20px 라운드
        border: Border.all(color: AppColors.black100, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. 헤더: 라벨 + 현재 값 (좌우 4px 패딩 추가)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: _buildHeader(),
          ),

          SizedBox(height: AppSpacing.vertical8),

          // 2. 슬라이더 (좌우 4px 패딩 추가)
          _buildSlider(),

          // 3. 최소/최대 라벨 (패딩 없음 - 넓게 유지)
          if (showMinMax) ...[_buildMinMaxLabels()],
        ],
      ),
    );
  }

  // ============================================
  // Private Helper Methods
  // ============================================

  /// 헤더: 라벨(좌) + 현재 값(우)
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 라벨 (label_16 사용)
        Text(
          label,
          style: AppTextStyles.label_16.copyWith(color: _effectiveLabelColor),
        ),

        // 현재 값
        _buildValueDisplay(),
      ],
    );
  }

  /// 값 표시 위젯 (스타일 분리 지원)
  Widget _buildValueDisplay() {
    // displayValue 사용 시 (레거시)
    if (displayValue != null) {
      return Text(
        displayValue!,
        style: AppTextStyles.label_16.copyWith(
          color: valueColor ?? AppColors.black800,
        ),
      );
    }

    // prefix/suffix 사용 시 (복합 스타일)
    if (displayPrefix != null || displaySuffix != null) {
      return RichText(
        text: TextSpan(
          children: [
            // 설명 부분 (paragraph_14_100 + black800)
            if (displayPrefix != null)
              TextSpan(
                text: '$displayPrefix ',
                style: AppTextStyles.paragraph_14_100.copyWith(
                  color: AppColors.black800,
                ),
              ),
            // 값 부분 (label_16 + thumbColor)
            TextSpan(
              text: '${value.toInt()}$unit',
              style: AppTextStyles.label_16.copyWith(
                color: valueColor ?? _effectiveThumbColor,
              ),
            ),
            // 뒤 추가 텍스트 (label_16 + thumbColor)
            if (displaySuffix != null)
              TextSpan(
                text: ' $displaySuffix',
                style: AppTextStyles.label_16.copyWith(
                  color: valueColor ?? _effectiveThumbColor,
                ),
              ),
          ],
        ),
      );
    }

    // 기본 형식 (label_16 + thumbColor)
    return Text(
      '${value.toInt()}$unit',
      style: AppTextStyles.label_16.copyWith(color: _effectiveValueColor),
    );
  }

  /// 슬라이더 위젯
  Widget _buildSlider() {
    return SliderTheme(
      data: SliderThemeData(
        // ============================================
        // 트랙 색상
        // ============================================

        /// 활성 트랙 (왼쪽, 값이 포함된 부분)
        activeTrackColor: _effectiveActiveTrackColor,

        /// 비활성 트랙 (오른쪽, 아직 포함되지 않은 부분)
        inactiveTrackColor: _effectiveInactiveTrackColor,

        // ============================================
        // 트랙 높이 및 모양
        // ============================================

        /// 트랙 높이 (showContainer에 따라 다름)
        trackHeight: _effectiveTrackHeight,

        /// 트랙 모양 (패딩 제거 커스텀)
        trackShape: _CustomSliderTrackShape(),

        // ============================================
        // Thumb (헤드) 스타일
        // ============================================

        /// Thumb 색상
        thumbColor: _effectiveThumbColor,

        /// Thumb 크기 (showContainer에 따라 다름)
        thumbShape: RoundSliderThumbShape(
          enabledThumbRadius: _effectiveThumbRadius,
        ),

        // ============================================
        // Overlay (탭 시 퍼지는 효과)
        // ============================================

        /// Overlay 색상 (Thumb 색상의 투명도 버전)
        overlayColor: _effectiveThumbColor.withValues(alpha: 0.2),

        /// Overlay 크기 (showContainer에 따라 다름)
        overlayShape: RoundSliderOverlayShape(
          overlayRadius: _effectiveOverlayRadius,
        ),

        // ============================================
        // 값 표시 (드래그 중 표시되는 툴팁)
        // ============================================

        /// 값 표시 비활성화 (헤더에 이미 표시되므로)
        showValueIndicator: ShowValueIndicator.never,

        // ============================================
        // Tick Marks (구간 표시 점)
        // ============================================

        /// 활성 구간 점 색상 (숨김)
        activeTickMarkColor: Colors.transparent,

        /// 비활성 구간 점 색상 (숨김)
        inactiveTickMarkColor: Colors.transparent,
      ),
      child: Slider(
        value: value,
        min: min,
        max: max,
        divisions: divisions, // null이면 연속, 숫자면 구간 분할
        onChanged: onChanged,
      ),
    );
  }

  /// 최소/최대 값 라벨
  Widget _buildMinMaxLabels() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 최소값 (black600 기본)
        Text(
          '${min.toInt()}$unit',
          style: AppTextStyles.tag_12.copyWith(color: _effectiveMinMaxColor),
        ),

        // 최대값 (black600 기본)
        Text(
          '${max.toInt()}$unit',
          style: AppTextStyles.tag_12.copyWith(color: _effectiveMinMaxColor),
        ),
      ],
    );
  }
}

/// 패딩 제거 커스텀 슬라이더 트랙 Shape
///
/// Flutter의 기본 슬라이더는 24px의 좌우 패딩을 가지고 있어서
/// 트랙이 양쪽에서 안쪽으로 들어가 보입니다.
/// 이 커스텀 Shape는 패딩을 제거하여 트랙이 전체 너비를 차지하도록 합니다.
class _CustomSliderTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight ?? 4.0;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
