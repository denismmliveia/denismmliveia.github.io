import 'package:flutter/material.dart';
import '../../domain/entities/message_entity.dart';

class TextBubbleWidget extends StatelessWidget {
  final MessageEntity message;
  final bool isOwn;

  const TextBubbleWidget({
    super.key,
    required this.message,
    required this.isOwn,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isOwn ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isOwn ? const Color(0xFF6600CC) : const Color(0xFF1A0A2E),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isOwn
              ? [
                  BoxShadow(
                    color: const Color(0xFFB300FF).withValues(alpha: 0.3),
                    blurRadius: 8,
                  )
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.text ?? '',
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
            if (message.createdAt != null)
              Text(
                _formatTime(message.createdAt!),
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
