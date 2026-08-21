import 'package:flutter/material.dart';
import 'package:zishu_ai/models/chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final isProactive = message.type == MessageType.proactive;
    final isSystem = message.type == MessageType.system;

    Color? backgroundColor;
    Color? textColor;
    Widget? prefixIcon;

    if (isSystem) {
      backgroundColor = Colors.grey.withOpacity(0.1);
      textColor = Colors.grey;
      prefixIcon = const Icon(Icons.info_outline, size: 16, color: Colors.grey);
    } else if (isProactive) {
      backgroundColor = Theme.of(context).primaryColor.withOpacity(0.1);
      textColor = Theme.of(context).primaryColor;
      prefixIcon = Icon(
        Icons.notifications_active,
        size: 16,
        color: Theme.of(context).primaryColor,
      );
    } else if (isUser) {
      backgroundColor = Theme.of(context).primaryColor;
      textColor = Colors.white;
    } else {
      backgroundColor = Theme.of(context).cardColor;
      textColor = Theme.of(context).textTheme.bodyLarge?.color;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 18,
              backgroundColor: Theme.of(context).primaryColor,
              child: const Text(
                'Z',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomLeft: isUser
                      ? const Radius.circular(20)
                      : const Radius.circular(4),
                  bottomRight: isUser
                      ? const Radius.circular(4)
                      : const Radius.circular(20),
                ),
                border: isProactive || isSystem
                    ? Border.all(
                        color: (isProactive
                            ? Theme.of(context).primaryColor
                            : Colors.grey).withOpacity(0.2),
                      )
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isProactive || isSystem) ...[
                    Row(
                      children: [
                        if (prefixIcon != null) ...[
                          prefixIcon,
                          const SizedBox(width: 4),
                        ],
                        Text(
                          isProactive ? 'Zishu Reminder' : 'System',
                          style: TextStyle(
                            color: textColor?.withOpacity(0.7),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    message.text,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: isUser
                          ? Colors.white70
                          : Theme.of(context).hintColor,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey.shade300,
              child: const Icon(Icons.person, size: 18),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
