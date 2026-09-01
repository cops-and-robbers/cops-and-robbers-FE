import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/spacing_and_radius.dart';
import '../../constants/text_styles.dart';
import '../buttons/app_button.dart';
import '../buttons/previous_button.dart';
import '../../utils/utf16_length_limiting_formatter.dart';
import '../navigation/app_top_bar.dart';

/// 텍스트 입력 + 제출 버튼으로 구성된 범용 페이지
///
/// 신고 작성, 버그 제보, 피드백 등 텍스트 입력이 필요한 곳에서 재사용합니다.
///
/// **사용 예시**:
/// ```dart
/// // 신고 작성
/// TextSubmitPage(
///   title: '신고하기',
///   label: '신고 내용',
///   hintText: '신고 사유를 자세히 작성해 주세요\n(상황 또는 대화 내용을 포함해 주세요)',
///   submitText: '신고하기',
///   isDestructive: true,
///   onSubmit: (text) => reportUser(text),
/// );
///
/// // 버그 제보
/// TextSubmitPage(
///   title: '버그 제보',
///   label: '버그 내용',
///   hintText: '발생한 버그를 자세히 설명해 주세요',
///   submitText: '제보하기',
///   onSubmit: (text) => submitBug(text),
/// );
/// ```
class TextSubmitPage extends StatefulWidget {
  const TextSubmitPage({
    super.key,
    required this.title,
    required this.label,
    required this.hintText,
    required this.submitText,
    required this.onSubmit,
    this.isDestructive = false,
    this.isDarkMode = false,
    this.minLines = 8,
    this.maxLength,
  });

  /// AppBar 타이틀
  final String title;

  /// 입력 필드 위 라벨
  final String label;

  /// 입력 필드 힌트 텍스트
  final String hintText;

  /// 제출 버튼 텍스트
  final String submitText;

  /// 제출 콜백 (입력된 텍스트 전달)
  final void Function(String text) onSubmit;

  /// 위험 액션 여부 (true면 버튼 빨간색)
  final bool isDestructive;

  /// 다크 모드 여부
  final bool isDarkMode;

  /// 입력 필드 최소 줄 수
  final int minLines;

  /// 입력 가능한 최대 글자 수. null이면 제한 없음.
  ///
  /// 설정하면 그 길이에서 입력이 막힌다. 남은 글자 수는 따로 보여 주지 않는다 —
  /// 댓글·채팅 입력과 같은 방식이다.
  /// 서버 검증값을 그대로 넣는다 — 세는 단위도 서버와 같은 UTF-16이다.
  final int? maxLength;

  @override
  State<TextSubmitPage> createState() => _TextSubmitPageState();
}

class _TextSubmitPageState extends State<TextSubmitPage> {
  final _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasText) {
        setState(() => _hasText = hasText);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final maxLength = widget.maxLength;

    return Scaffold(
      backgroundColor: isDark ? AppColors.black900 : AppColors.white,
      appBar: AppTopBar(
        title: widget.title,
        isDarkMode: isDark,
        leading: Padding(
          padding: EdgeInsets.only(left: 4.w),
          child: PreviousButton(
            onPressed: () => Navigator.of(context).pop(),
            color: isDark ? AppColors.white : null,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: AppPadding.horizontal20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppSpacing.vertical20),

              // 라벨
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.horizontal4,
                ),
                child: Text(
                  widget.label,
                  style: AppTextStyles.label_16.copyWith(
                    color: isDark ? AppColors.white : AppColors.black,
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.vertical16),

              // 입력 필드 (Expanded로 남은 공간 차지, 스크롤 가능)
              Expanded(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: 300.h),
                    child: TextField(
                      controller: _controller,
                      // 길이 제한은 아래 포매터가 건다 — Flutter 기본 maxLength는
                      // 세는 단위가 서버와 달라 쓰지 않는다.
                      inputFormatters: maxLength == null
                          ? null
                          : [Utf16LengthLimitingFormatter(maxLength)],
                      maxLines: null,
                      minLines: 7,
                      textAlignVertical: TextAlignVertical.top,
                      style: AppTextStyles.paragraph_14.copyWith(
                        color: isDark ? AppColors.white : AppColors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: widget.hintText,
                        hintStyle: AppTextStyles.paragraph_14.copyWith(
                          color: AppColors.black400,
                        ),
                        // 기본 카운터는 입력창 아래 한 줄을 더 먹는다. 제한은
                        // 걸되 표시는 않는다 (댓글·채팅 입력과 같은 처리).
                        counterText: '',
                        filled: true,
                        fillColor: isDark
                            ? AppColors.black900
                            : AppColors.white,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.horizontal24,
                          vertical: AppSpacing.vertical20,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: AppRadius.xlarge,
                          borderSide: BorderSide(
                            color: isDark
                                ? AppColors.black800
                                : AppColors.black100,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: AppRadius.xlarge,
                          borderSide: BorderSide(
                            color: isDark
                                ? AppColors.black800
                                : AppColors.black100,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: AppRadius.xlarge,
                          borderSide: BorderSide(
                            color: isDark
                                ? AppColors.black800
                                : AppColors.black100,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 제출 버튼 (하단 고정)
              AppButton(
                text: widget.submitText,
                onPressed: _hasText
                    ? () => widget.onSubmit(_controller.text.trim())
                    : null,
                width: double.infinity,
                backgroundColor: widget.isDestructive
                    ? AppColors.red
                    : (isDark ? AppColors.green : AppColors.blue),
                textStyle: isDark
                    ? AppTextStyles.robberLabel
                    : AppTextStyles.label_16,
              ),
              SizedBox(height: AppSpacing.vertical16),
            ],
          ),
        ),
      ),
    );
  }
}
