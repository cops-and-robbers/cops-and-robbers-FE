import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';

/// 채팅 입력 바 위젯
///
/// 채팅 메시지 입력 필드와 전송 버튼을 포함합니다.
/// 전송 범위(scope)는 외부에서 현재 탭에 따라 결정됩니다.
class ChatInputBar extends StatefulWidget {
  const ChatInputBar({
    required this.onSend,
    required this.enabled,
    this.onFocusGain,
    this.isDarkMode = false,
    this.unreadAllCount = 0,
    this.unreadTeamCount = 0,
    super.key,
  });

  /// 메시지 전송 콜백
  final void Function(String message) onSend;

  /// 입력 가능 여부 (STOMP 연결 상태에 따라)
  final bool enabled;

  /// 입력창 포커스 획득 시 콜백 (채팅창 자동 확장용)
  final VoidCallback? onFocusGain;

  /// 다크 모드 여부
  final bool isDarkMode;

  /// 전체 채팅 읽지 않은 메시지 수
  final int unreadAllCount;

  /// 팀 채팅 읽지 않은 메시지 수
  final int unreadTeamCount;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;

  /// 사용자가 TextField를 직접 탭했는지 여부
  bool _userTapped = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      if (!_userTapped) {
        // 다이얼로그 닫힘 등 프로그래매틱 포커스 복원 → 즉시 해제
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _focusNode.hasFocus && !_userTapped) {
            _focusNode.unfocus();
          }
        });
        return;
      }
      widget.onFocusGain?.call();
    } else {
      // 포커스 상실 시 플래그 리셋
      _userTapped = false;
    }
  }

  /// TextField 직접 탭 시 플래그 설정
  void _onInputTap() {
    _userTapped = true;
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  /// 읽지 않은 메시지 힌트 텍스트 생성
  String? _buildUnreadHint() {
    final all = widget.unreadAllCount;
    final team = widget.unreadTeamCount;
    if (all == 0 && team == 0) return null;

    final parts = <String>[];
    if (all > 0) parts.add('전체 $all개');
    if (team > 0) parts.add('팀 $team개');
    return '안 읽은 메시지 ${parts.join(' · ')}';
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty || !widget.enabled) return;

    widget.onSend(text);
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // 화면 아래에서 45px 위에 위치 (SafeArea 포함하여 외부에서 처리)
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      color: widget.isDarkMode ? AppColors.black900 : AppColors.black100,
      child: Container(
        height: 48.h,
        padding: EdgeInsets.only(left: 16.w, right: 8.w),
        decoration: BoxDecoration(
          color: widget.isDarkMode ? AppColors.black : AppColors.white,
          borderRadius: AppRadius.large,
        ),
        child: Row(
          children: [
            Expanded(
              child: Listener(
                onPointerDown: (_) => _userTapped = true,
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: widget.enabled,
                  style: AppTextStyles.paragraph_14.copyWith(
                    color: widget.isDarkMode
                        ? AppColors.black200
                        : AppColors.black900,
                  ),
                  decoration: InputDecoration(
                    hintText: !widget.enabled
                        ? '연결 중...'
                        : _buildUnreadHint() ?? '채팅을 입력하세요',
                    hintStyle: AppTextStyles.label16Medium.copyWith(
                      color: widget.isDarkMode
                          ? AppColors.black200
                          : AppColors.black400,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                  ),
                  onTap: _onInputTap,
                  onSubmitted: (_) => _handleSend(),
                ),
              ),
            ),
            SizedBox(width: AppSpacing.horizontal8),
            _buildSendButton(),
          ],
        ),
      ),
    );
  }

  /// 전송 버튼 (32x32, 텍스트 유무에 따라 blue/black200, icon_arrow 위 방향)
  Widget _buildSendButton() {
    return GestureDetector(
      onTap: widget.enabled ? _handleSend : null,
      child: Container(
        width: 32.w,
        height: 32.w,
        decoration: BoxDecoration(
          color: widget.isDarkMode
              ? (_hasText ? AppColors.green : AppColors.black900)
              : (_hasText ? AppColors.blue : AppColors.black200),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Transform.rotate(
            angle: -math.pi / 2,
            child: SvgPicture.asset(
              'assets/icons/icon_arrow.svg',
              width: 20.w,
              height: 20.w,
              colorFilter: ColorFilter.mode(
                widget.isDarkMode
                    ? (_hasText ? AppColors.black : AppColors.black400)
                    : AppColors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
