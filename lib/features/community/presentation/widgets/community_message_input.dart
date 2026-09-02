import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/services/vibration_service.dart';
import '../../../../core/utils/utf16_length_limiting_formatter.dart';

/// 화면 하단 입력 바 — 채팅방과 모집글 댓글이 함께 쓴다
///
/// 두 화면의 시안이 같은 컴포넌트라 하나로 둔다. 생김새는 댓글 입력창 쪽으로
/// 맞췄다(회색 필드·모서리 12·상단 구분선).
///
/// 키보드 오른쪽 아래 키는 전송이 아니라 **개행**이다 — 전송은 옆의 아이콘이
/// 맡으므로 키보드까지 전송을 쥐면 여러 줄을 쓸 방법이 사라진다. 그래서 필드도
/// [maxLines]까지 자란다(한 줄로 묶으면 개행 키가 눌려도 안 들어가는 죽은 키가 된다).
///
/// 여백은 눈에 보이는 값 기준으로 좌 16 · 필드~아이콘 14 · 우 16이다. 전송
/// 버튼이 40 탭 영역에 24 아이콘이라 안에서 이미 8이 비므로, 오른쪽 패딩과
/// 필드 간격에서 각각 8을 빼서 보정한다.
///
/// 게임 `ChatInputBar`는 다크 모드·미읽음 힌트·포커스 가드가 얽혀 있어 대상이 아니다.
class CommunityMessageInput extends StatefulWidget {
  const CommunityMessageInput({
    required this.hintText,
    required this.onSubmit,
    required this.maxLength,
    this.enabled = true,
    this.focusNode,
    super.key,
  });

  final String hintText;

  /// 전송. 이 Future가 끝날 때까지 버튼이 스피너로 바뀌고 중복 탭을 막는다.
  /// 예외가 나면 입력 내용을 지우지 않는다 — 사용자가 다시 보낼 수 있어야 한다.
  final Future<void> Function(String text) onSubmit;

  /// 서버 검증값과 맞춘 길이 상한. 카운터는 시안에 없어 숨긴다.
  final int maxLength;

  /// 연결이 끊긴 동안 false — 보내도 실패만 쌓인다.
  final bool enabled;

  /// 밖에서 포커스를 줘야 할 때만 넘긴다 (댓글의 답글 모드 등).
  final FocusNode? focusNode;

  /// 여기까지 자란 뒤로는 안쪽에서 스크롤한다 — 입력창이 화면을 다 먹으면 안 된다.
  static const maxLines = 4;

  @override
  State<CommunityMessageInput> createState() => _CommunityMessageInputState();
}

class _CommunityMessageInputState extends State<CommunityMessageInput> {
  final _controller = TextEditingController();
  bool _hasText = false;

  /// 전송 중 중복 탭 방지. 두 번 누르면 같은 내용이 두 번 나간다.
  bool _isSubmitting = false;

  bool get _canSend => _hasText && widget.enabled && !_isSubmitting;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);
  }

  Future<void> _submit() async {
    if (!_canSend) return;

    VibrationService.instance().buttonTap();
    setState(() => _isSubmitting = true);
    try {
      await widget.onSubmit(_controller.text.trim());
      if (mounted) _controller.clear();
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.black100)),
      ),
      // 키보드가 올라오면 그 위로, 내려가면 홈 인디케이터 위로 붙는다.
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.horizontal16,
            right: AppSpacing.horizontal8, // + 탭 영역 여백 8 = 16
            top: AppSpacing.vertical8,
            bottom: AppSpacing.vertical8,
          ),
          child: Row(
            // 여러 줄로 자라도 전송 버튼은 아래에 붙어 있어야 한다.
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: _buildField()),
              SizedBox(width: AppSpacing.horizontal6), // + 탭 영역 여백 8 = 14
              _buildSendButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField() {
    return TextField(
      controller: _controller,
      focusNode: widget.focusNode,
      enabled: widget.enabled,
      maxLines: CommunityMessageInput.maxLines,
      minLines: 1,
      // 서버와 같은 단위(UTF-16)로 막는다 — Flutter 기본 maxLength는 자소 단위라
      // 이모지가 섞이면 앱은 통과시키고 서버가 400을 준다.
      inputFormatters: [Utf16LengthLimitingFormatter(widget.maxLength)],
      // 전송은 옆 아이콘이 맡는다 — 키보드 키는 개행.
      textInputAction: TextInputAction.newline,
      style: AppTextStyles.paragraph_14.copyWith(color: AppColors.black),
      decoration: InputDecoration(
        isDense: true,
        hintText: widget.hintText,
        hintStyle: AppTextStyles.paragraph_14.copyWith(
          color: AppColors.black400,
        ),
        filled: true,
        fillColor: AppColors.black100,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.horizontal16,
          vertical: AppSpacing.vertical12,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.large,
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  /// 40 탭 영역 안의 24 아이콘 — 보낼 수 없는 동안은 회색으로 죽여 둔다.
  Widget _buildSendButton() {
    return GestureDetector(
      onTap: _canSend ? _submit : null,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 40.w,
        height: 40.w,
        child: Center(
          child: _isSubmitting
              ? SizedBox(
                  width: 16.w,
                  height: 16.w,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                )
              : SvgPicture.asset(
                  AppIcons.sending,
                  width: 24.w,
                  height: 24.w,
                  colorFilter: ColorFilter.mode(
                    _canSend ? AppColors.blueVer2Basic : AppColors.black400,
                    BlendMode.srcIn,
                  ),
                ),
        ),
      ),
    );
  }
}
