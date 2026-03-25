import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/text_styles.dart';

/// 정보 표시용 칩 컴포넌트
///
/// Stack 기반 레이아웃으로 "반경 400m" 형태의 정보를 표시합니다.
/// prefix는 paragraph_14_100, value는 label_16 스타일을 사용합니다.
/// prefix는 절대 위치에 고정되어 value 변경 시에도 위치가 변하지 않습니다.
///
/// [editable]이 true이면 value 영역을 탭하여 키보드로 직접 입력할 수 있습니다.
/// 입력값은 [minValue]~[maxValue] 범위로 클램핑됩니다.
///
/// 사용 예시:
/// ```dart
/// // 기본 (파란색, 읽기 전용)
/// InfoRadiusChip(
///   prefix: '반경',
///   value: '400m',
/// )
///
/// // 편집 가능 모드
/// InfoRadiusChip(
///   prefix: '반경',
///   value: '400m',
///   editable: true,
///   minValue: 100,
///   maxValue: 1000,
///   onValueChanged: (newRadius) {
///     // newRadius: 사용자가 입력한 미터 값 (double)
///   },
/// )
/// ```
class InfoRadiusChip extends StatefulWidget {
  const InfoRadiusChip({
    super.key,
    required this.prefix,
    required this.value,
    this.backgroundColor,
    this.prefixColor,
    this.valueColor,
    this.width,
    this.height,
    this.borderRadius,
    this.editable = false,
    this.minValue,
    this.maxValue,
    this.onValueChanged,
    this.onEditingChanged,
  });

  /// prefix 텍스트 (예: "반경")
  final String prefix;

  /// value 텍스트 (예: "400m")
  final String value;

  /// 배경색 (기본: AppColors.blue)
  final Color? backgroundColor;

  /// prefix 텍스트 색상 (기본: AppColors.white)
  final Color? prefixColor;

  /// value 텍스트 색상 (기본: AppColors.white)
  final Color? valueColor;

  /// 너비 (기본: 110.w)
  final double? width;

  /// 높이 (기본: 40.h)
  final double? height;

  /// 모서리 둥글기 (기본: 12.r)
  final double? borderRadius;

  /// 편집 가능 여부 (기본: false)
  final bool editable;

  /// 최소 값 (미터, 편집 모드 전용)
  final double? minValue;

  /// 최대 값 (미터, 편집 모드 전용)
  final double? maxValue;

  /// 값 변경 콜백 (미터 단위 double, 편집 모드 전용)
  final ValueChanged<double>? onValueChanged;

  /// 편집 모드 변경 콜백 (true: 편집 시작, false: 편집 종료)
  final ValueChanged<bool>? onEditingChanged;

  @override
  State<InfoRadiusChip> createState() => _InfoRadiusChipState();
}

class _InfoRadiusChipState extends State<InfoRadiusChip> {
  bool _isEditing = false;
  late TextEditingController _textController;
  late FocusNode _focusNode;
  Timer? _debounceTimer;

  // ============================================
  // 기본값 Getter 메서드
  // ============================================

  /// 배경색 (기본: AppColors.blue)
  Color get _effectiveBackgroundColor =>
      widget.backgroundColor ?? AppColors.blue;

  /// prefix 색상 (기본: AppColors.white)
  Color get _effectivePrefixColor => widget.prefixColor ?? AppColors.white;

  /// value 색상 (기본: AppColors.white)
  Color get _effectiveValueColor => widget.valueColor ?? AppColors.white;

  /// 너비 (기본: 110.w)
  double get _effectiveWidth => widget.width ?? 110.w;

  /// 높이 (기본: 40.h)
  double get _effectiveHeight => widget.height ?? 40.h;

  /// 모서리 둥글기 (기본: 12.r)
  double get _effectiveBorderRadius => widget.borderRadius ?? 12.r;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  /// 포커스 해제 시 편집 완료 처리
  void _onFocusChanged() {
    if (!_focusNode.hasFocus && _isEditing) {
      _completeEditing();
    }
  }

  /// 편집 모드 진입
  void _startEditing() {
    if (!widget.editable) return;

    // value에서 숫자만 추출 (예: "400m" → "400", "1.50km" → "1500")
    final numericValue = _extractMeters(widget.value);
    setState(() {
      _isEditing = true;
      _textController.text = numericValue;
      _textController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: numericValue.length,
      );
    });

    widget.onEditingChanged?.call(true);

    // 다음 프레임에서 포커스 요청 (TextField가 빌드된 후)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  /// 입력값 디바운싱 (500ms 후 부모에 반영)
  void _onTextChanged(String text) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 100), () {
      _applyCurrentInput();
    });
  }

  /// 현재 입력값을 클램핑 후 부모에 반영
  void _applyCurrentInput() {
    final inputText = _textController.text.trim();
    final parsed = double.tryParse(inputText);
    if (parsed != null && widget.onValueChanged != null) {
      final min = widget.minValue ?? 0;
      final max = widget.maxValue ?? double.infinity;
      final clamped = parsed.clamp(min, max);
      widget.onValueChanged!(clamped);
    }
  }

  /// value 문자열에서 미터 값을 추출
  String _extractMeters(String value) {
    if (value.endsWith('km')) {
      final kmStr = value.replaceAll('km', '');
      final km = double.tryParse(kmStr);
      if (km != null) return (km * 1000).toInt().toString();
    }
    // "400m" → "400"
    return value.replaceAll(RegExp(r'[^0-9.]'), '');
  }

  /// 입력값 제출 및 편집 모드 종료
  ///
  /// [fromSubmit]이 true이면 키보드 done 키에서 호출된 것이므로
  /// 포커스 해제 후 콜백이 중복 호출되지 않도록 가드합니다.
  void _completeEditing() {
    if (!_isEditing) return; // 중복 호출 방지

    // 대기 중인 디바운스 취소 후 즉시 반영
    _debounceTimer?.cancel();
    _applyCurrentInput();

    // 편집 모드 종료
    setState(() => _isEditing = false);
    widget.onEditingChanged?.call(false);

    // 포커스가 남아있으면 해제 (키보드 닫기)
    if (_focusNode.hasFocus) _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.editable && !_isEditing ? _startEditing : null,
      child: Container(
        width: _effectiveWidth,
        height: _effectiveHeight,
        decoration: BoxDecoration(
          color: _effectiveBackgroundColor,
          borderRadius: BorderRadius.circular(_effectiveBorderRadius),
        ),
        child: Stack(
          children: [
            // prefix: 절대 위치 고정 (왼쪽에서 AppSpacing.horizontal12)
            Positioned(
              left: 14.w,
              top: 0,
              bottom: 0,
              child: Center(
                child: Text(
                  widget.prefix,
                  style: AppTextStyles.paragraph_14_100.copyWith(
                    color: _effectivePrefixColor,
                  ),
                ),
              ),
            ),
            // value: 오른쪽 정렬 (우측 공간 최소화)
            Positioned(
              right: 14.w,
              top: 0,
              bottom: 0,
              child: Center(
                child: _isEditing ? _buildTextField() : _buildValueText(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 읽기 전용 value 텍스트
  Widget _buildValueText() {
    return Text(
      widget.value,
      style: AppTextStyles.label_16.copyWith(color: _effectiveValueColor),
    );
  }

  /// 편집 모드 TextField (동일한 스타일, 투명 배경)
  Widget _buildTextField() {
    return SizedBox(
      width: 50.w,
      child: TextField(
        controller: _textController,
        focusNode: _focusNode,
        keyboardType: const TextInputType.numberWithOptions(decimal: false),
        textAlign: TextAlign.right,
        style: AppTextStyles.label_16.copyWith(color: _effectiveValueColor),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.zero,
          border: InputBorder.none,
        ),
        onChanged: _onTextChanged,
        onSubmitted: (_) => _completeEditing(),
      ),
    );
  }
}
