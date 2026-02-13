import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/chat_stomp_datasource.dart';
import '../providers/chat_provider.dart';
import 'chat_input_bar.dart';
import 'chat_message_list.dart';

/// TODO: 임시 UI
///
/// 채팅 오버레이 위젯
///
/// 게임 화면 하단에 표시되는 채팅 UI입니다.
/// 축소/확장 가능하며, 실시간 메시지를 표시합니다.
class ChatOverlay extends ConsumerStatefulWidget {
  const ChatOverlay({
    required this.gameId,
    required this.myParticipantId,
    required this.myTeam,
    super.key,
  });

  final int gameId;
  final int myParticipantId;
  final String myTeam;

  @override
  ConsumerState<ChatOverlay> createState() => _ChatOverlayState();
}

class _ChatOverlayState extends ConsumerState<ChatOverlay> {
  bool _isExpanded = false;

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _handleSend(String message, String scope) {
    ref.read(chatNotifierProvider.notifier).sendMessage(
          gameId: widget.gameId,
          message: message,
          scope: scope,
        );
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatNotifierProvider);
    final isConnected =
        chatState.connectionState == StompConnectionState.connected;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      height: _isExpanded ? 300 : 44,
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // 헤더 (확장/축소 토글, 연결 상태)
          _buildHeader(chatState.connectionState),

          // 메시지 목록 (확장 시에만 표시)
          if (_isExpanded) ...[
            Expanded(
              child: ChatMessageList(
                messages: chatState.messages,
                myParticipantId: widget.myParticipantId,
                myTeam: widget.myTeam,
              ),
            ),
            // 입력 바 (확장 시에만 표시)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: ChatInputBar(
                onSend: _handleSend,
                enabled: isConnected,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(StompConnectionState connectionState) {
    return GestureDetector(
      onTap: _toggleExpand,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            // 연결 상태 인디케이터
            _buildConnectionIndicator(connectionState),
            const SizedBox(width: 8),

            // 채팅 라벨
            const Text(
              '채팅',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),

            const Spacer(),

            // 확장/축소 아이콘
            Icon(
              _isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
              color: Colors.white70,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionIndicator(StompConnectionState state) {
    Color color;
    String tooltip;

    switch (state) {
      case StompConnectionState.connected:
        color = Colors.green;
        tooltip = '연결됨';
      case StompConnectionState.connecting:
        color = Colors.orange;
        tooltip = '연결 중...';
      case StompConnectionState.disconnected:
        color = Colors.grey;
        tooltip = '연결 끊김';
      case StompConnectionState.error:
        color = Colors.red;
        tooltip = '연결 오류';
    }

    return Tooltip(
      message: tooltip,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}