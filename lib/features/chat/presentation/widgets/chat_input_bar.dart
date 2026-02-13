import 'package:flutter/material.dart';

/// TODO: 임시 UI
///
/// 채팅 입력 바 위젯
///
/// 채팅 메시지 입력 필드와 전송 버튼, 범위(ALL/TEAM) 선택 토글을 포함합니다.
class ChatInputBar extends StatefulWidget {
  const ChatInputBar({
    required this.onSend,
    required this.enabled,
    super.key,
  });

  /// 메시지 전송 콜백
  /// [message]: 메시지 내용
  /// [scope]: "ALL" 또는 "TEAM"
  final void Function(String message, String scope) onSend;

  /// 입력 가능 여부 (STOMP 연결 상태에 따라)
  final bool enabled;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final TextEditingController _controller = TextEditingController();
  bool _isTeamChat = false; // false: ALL, true: TEAM

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty || !widget.enabled) return;

    widget.onSend(text, _isTeamChat ? 'TEAM' : 'ALL');
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // 범위 토글 버튼 (ALL <-> TEAM)
          _buildScopeToggle(),
          const SizedBox(width: 8),

          // 입력 필드
          Expanded(
            child: TextField(
              controller: _controller,
              enabled: widget.enabled,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: widget.enabled ? '채팅을 입력하세요' : '연결 중...',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 14,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
              onSubmitted: (_) => _handleSend(),
            ),
          ),
          const SizedBox(width: 8),

          // 전송 버튼
          _buildSendButton(),
        ],
      ),
    );
  }

  Widget _buildScopeToggle() {
    return GestureDetector(
      onTap: widget.enabled
          ? () {
              setState(() {
                _isTeamChat = !_isTeamChat;
              });
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: _isTeamChat
              ? Colors.orange.withValues(alpha: 0.8)
              : Colors.blue.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          _isTeamChat ? '팀' : '전체',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return GestureDetector(
      onTap: widget.enabled ? _handleSend : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: widget.enabled
              ? (_isTeamChat ? Colors.orange : Colors.blue)
              : Colors.grey,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Text(
          '전송',
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
