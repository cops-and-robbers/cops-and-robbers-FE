import 'package:flutter/material.dart';

import '../../data/models/chat_message_dto.dart';

/// TODO: 임시 UI
///
/// 채팅 메시지 버블 위젯
///
/// 개별 채팅 메시지를 표시합니다.
/// 본인 메시지는 오른쪽, 다른 사람 메시지는 왼쪽에 표시됩니다.
class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    required this.message,
    required this.isMe,
    required this.myTeam,
    super.key,
  });

  final ChatMessageDto message;
  final bool isMe;
  final String myTeam;

  @override
  Widget build(BuildContext context) {
    final isTeamChat = message.scope == 'TEAM';
    final senderTeam = message.sender.team.toUpperCase();
    final isMyTeam = senderTeam == myTeam.toUpperCase();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            _buildNicknameTag(isMyTeam, senderTeam),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 220),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _getBubbleColor(isMe, isTeamChat),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
              ),
              child: Text(
                message.message,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black87,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 6),
            _buildScopeIndicator(isTeamChat),
          ],
        ],
      ),
    );
  }

  Widget _buildNicknameTag(bool isMyTeam, String team) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _getTeamColor(team).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message.sender.nickname,
        style: TextStyle(
          color: _getTeamColor(team),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildScopeIndicator(bool isTeamChat) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: isTeamChat
            ? Colors.orange.withValues(alpha: 0.3)
            : Colors.grey.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isTeamChat ? '팀' : '전체',
        style: TextStyle(
          color: isTeamChat ? Colors.orange.shade700 : Colors.grey.shade600,
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getBubbleColor(bool isMe, bool isTeamChat) {
    if (isMe) {
      return isTeamChat ? Colors.orange : Colors.blue;
    }
    return Colors.grey.shade200;
  }

  Color _getTeamColor(String team) {
    switch (team.toUpperCase()) {
      case 'POLICE':
        return Colors.blue;
      case 'ROBBER':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
