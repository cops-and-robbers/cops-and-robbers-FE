import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/spacing_and_radius.dart';
import '../../constants/text_styles.dart';

// TODO: 세 번째 편집 가능 텍스트 사용처가 생기면
// EditableNumberText로 추출하여 공용화한다.
// 참고 구현: lib/core/widgets/chips/info_radius_chip.dart

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
    this.isDarkMode = false,
    this.valueTextStyle,
    this.editable = false,
    this.onEditingChanged,
  }) : assert(
         !(editable && displayValue != null),
         'AppSlider: editable과 displayValue는 함께 사용할 수 없다 '
         '(displayValue는 임의 문자열이라 숫자 입력 위치를 알 수 없음)',
       );

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

  /// 다크 모드 여부 (텍스트 스타일 및 기본 색상 전환)
  final bool isDarkMode;

  /// 값 텍스트 스타일 (null이면 AppTextStyles.label_16 사용)
  final TextStyle? valueTextStyle;

  /// 값 표시 영역 탭 시 숫자 키패드 입력 모드 활성화 (기본: false)
  ///
  /// `displayValue`와 함께 사용할 수 없다 (assert 실패).
  /// `displayPrefix`/`displaySuffix`와는 호환된다.
  final bool editable;

  /// 편집 모드 진입/종료 콜백 (선택)
  /// - true: 편집 시작 (탭 → TextField 표시)
  /// - false: 편집 종료 (포커스 해제 또는 키보드 완료)
  final ValueChanged<bool>? onEditingChanged;

  // ============================================
  // 기본값 Getter 메서드
  // ============================================

  /// 활성 트랙 색상 (기본: AppColors.black800, 다크: AppColors.green800)
  Color get _effectiveActiveTrackColor {
    return activeTrackColor ??
        (isDarkMode ? AppColors.green800 : AppColors.black800);
  }

  /// 헤드(Thumb) 색상 (기본: AppColors.black, 다크: AppColors.green)
  Color get _effectiveThumbColor {
    return thumbColor ?? (isDarkMode ? AppColors.green : AppColors.black);
  }

  /// 비활성 트랙 색상 (기본: AppColors.black100, 다크: AppColors.black800)
  Color get _effectiveInactiveTrackColor {
    return inactiveTrackColor ??
        (isDarkMode ? AppColors.black800 : AppColors.black100);
  }

  /// 배경색 (기본: AppColors.white, 다크: AppColors.black900)
  Color get _effectiveBackgroundColor {
    return backgroundColor ??
        (isDarkMode ? AppColors.black900 : AppColors.white);
  }

  /// 라벨 색상 (기본: AppColors.black, 다크: AppColors.white)
  Color get _effectiveLabelColor {
    return labelColor ?? (isDarkMode ? AppColors.white : AppColors.black);
  }

  /// 값 표시 색상 (기본: thumbColor)
  Color get _effectiveValueColor {
    return valueColor ?? _effectiveThumbColor;
  }

  /// 최소/최대 라벨 색상 (기본: AppColors.black600, 다크: AppColors.black400)
  Color get _effectiveMinMaxColor {
    return minMaxColor ??
        (isDarkMode ? AppColors.black400 : AppColors.black600);
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
        border: Border.all(
          color: isDarkMode ? AppColors.black800 : AppColors.black100,
          width: 1.0,
        ),
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
        Flexible(
          child: Text(
            label,
            style: AppTextStyles.label_16.copyWith(color: _effectiveLabelColor),
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // 현재 값
        _buildValueDisplay(),
      ],
    );
  }

  /// 값 표시 위젯 (스타일 분리 지원)
  Widget _buildValueDisplay() {
    // 모드 1: displayValue 사용 시 (레거시)
    // editable은 assert로 금지됐지만, release 빌드에서도 displayValue가
    // 우선 반환되므로 자연스럽게 편집 비활성 상태가 된다.
    if (displayValue != null) {
      return Text(
        displayValue!,
        style: AppTextStyles.label_16.copyWith(
          color: valueColor ?? AppColors.black800,
        ),
      );
    }

    // 모드 2: prefix/suffix 사용 시 (복합 스타일)
    // 편집 모드를 지원하기 위해 기존 RichText 구조를 Row로 재구성한다.
    // prefix/suffix는 Text 위젯으로 남기고, 값 부분만 조건부로 _EditableValueText로 교체.
    if (displayPrefix != null || displaySuffix != null) {
      final prefixStyle = AppTextStyles.paragraph_14_100.copyWith(
        color: isDarkMode ? AppColors.black200 : AppColors.black800,
      );
      final valueStyle = (valueTextStyle ?? AppTextStyles.label_16).copyWith(
        color: valueColor ?? _effectiveThumbColor,
      );

      final Widget valueWidget = editable
          ? _EditableValueText(
              value: value,
              min: min,
              max: max,
              unit: unit,
              textStyle: valueStyle,
              onChanged: onChanged,
              onEditingChanged: onEditingChanged,
            )
          : Text(
              '${value.toInt()}$unit',
              style: valueStyle,
            );

      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (displayPrefix != null)
              Text('$displayPrefix ', style: prefixStyle),
            valueWidget,
            if (displaySuffix != null)
              Text(' $displaySuffix', style: valueStyle),
          ],
        ),
      );
    }

    // 모드 3: 기본 (valueTextStyle ?? label_16 + thumbColor)
    final valueStyle = (valueTextStyle ?? AppTextStyles.label_16).copyWith(
      color: _effectiveValueColor,
    );

    if (editable) {
      return _EditableValueText(
        value: value,
        min: min,
        max: max,
        unit: unit,
        textStyle: valueStyle,
        onChanged: onChanged,
        onEditingChanged: onEditingChanged,
      );
    }

    return Text(
      '${value.toInt()}$unit',
      style: valueStyle,
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

/// 슬라이더 값 영역의 편집 가능 텍스트
///
/// 비편집 모드에서는 일반 Text로 보이고, 탭하면 TextField로 전환된다.
/// 입력값은 100ms 디바운스 후 [min]~[max] 범위로 클램핑되어 [onChanged]로 전달된다.
///
/// 이 위젯은 `_EditableValueText` 라는 이름 그대로 `app_slider.dart` 내부 private이며,
/// `InfoRadiusChip`의 편집 로직과 의도적으로 동일한 메서드 구조를 가진다. 향후 세 번째
/// 사용처가 생기면 둘을 `EditableNumberText`로 통합할 수 있도록 미러링 구조를 유지한다.
class _EditableValueText extends StatefulWidget {
  const _EditableValueText({
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
    required this.textStyle,
    required this.onChanged,
    this.onEditingChanged,
  });

  /// 현재 값 (부모 슬라이더의 value)
  final double value;

  /// 클램핑 하한
  final double min;

  /// 클램핑 상한
  final double max;

  /// 단위 문자열 (예: '분', '명', 'm')
  final String unit;

  /// 표시·편집 모두에 적용되는 텍스트 스타일 (값 색상 포함)
  final TextStyle textStyle;

  /// 클램핑된 값을 부모에 전달하는 콜백
  final ValueChanged<double> onChanged;

  /// 편집 모드 진입/종료 콜백 (선택)
  final ValueChanged<bool>? onEditingChanged;

  @override
  State<_EditableValueText> createState() => _EditableValueTextState();
}

class _EditableValueTextState extends State<_EditableValueText> {
  bool _isEditing = false;
  late final TextEditingController _textController;
  late final FocusNode _focusNode;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _EditableValueText oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 편집 중에는 부모 prop으로 controller를 덮어쓰지 않는다 (사용자 입력 보호).
    // 편집 종료 후 다음 _startEditing()에서 최신 widget.value로 다시 채워진다.
  }

  /// 포커스 해제 시 자동으로 편집 종료
  void _onFocusChanged() {
    if (!_focusNode.hasFocus && _isEditing) {
      _completeEditing();
    }
  }

  /// 편집 모드 진입: 값을 controller에 채우고 전체 선택 후 포커스 요청
  void _startEditing() {
    final text = widget.value.toInt().toString();
    setState(() {
      _isEditing = true;
      _textController.text = text;
      _textController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: text.length,
      );
    });
    widget.onEditingChanged?.call(true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  /// 입력 변경 시 100ms 디바운스로 부모 콜백 호출
  void _onTextChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 100), _applyCurrentInput);
  }

  /// 현재 입력값을 클램핑해 부모에 전달. 빈 입력은 무시.
  void _applyCurrentInput() {
    final input = _textController.text.trim();
    if (input.isEmpty) return;

    final parsed = int.tryParse(input);
    if (parsed == null) return;

    final clamped = parsed.toDouble().clamp(widget.min, widget.max);
    widget.onChanged(clamped);
  }

  /// 편집 종료: 디바운스 취소 후 즉시 적용, 포커스 해제, 편집 모드 끔
  void _completeEditing() {
    if (!_isEditing) return;

    _debounce?.cancel();
    _applyCurrentInput();

    setState(() => _isEditing = false);
    widget.onEditingChanged?.call(false);

    if (_focusNode.hasFocus) _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isEditing) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _startEditing,
        child: Text(
          '${widget.value.toInt()}${widget.unit}',
          style: widget.textStyle,
        ),
      );
    }

    // 편집 중: 좁은 폭의 TextField + 단위 텍스트
    final maxDigits = widget.max.toInt().toString().length;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IntrinsicWidth(
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: 24.w),
            child: TextField(
              controller: _textController,
              focusNode: _focusNode,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: false),
              textAlign: TextAlign.center,
              maxLength: maxDigits,
              style: widget.textStyle,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                counterText: '',
              ),
              onChanged: _onTextChanged,
              onSubmitted: (_) => _completeEditing(),
            ),
          ),
        ),
        Text(widget.unit, style: widget.textStyle),
      ],
    );
  }
}
