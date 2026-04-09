import 'package:flutter/material.dart';
import '../../domain/entities/message_entity.dart';

class PhotoBubbleWidget extends StatelessWidget {
  final MessageEntity message;
  final bool isOwn;
  final String currentUid;
  final VoidCallback onHoldStart;
  final VoidCallback onHoldEnd;

  const PhotoBubbleWidget({
    super.key,
    required this.message,
    required this.isOwn,
    required this.currentUid,
    required this.onHoldStart,
    required this.onHoldEnd,
  });

  @override
  Widget build(BuildContext context) {
    final alreadyViewed = message.viewedBy.contains(currentUid);
    final deleted = message.deletedFromStorage;

    final String label;
    final bool canView;
    final Color labelColor;
    final IconData icon;

    if (deleted) {
      label = 'Foto eliminada';
      canView = false;
      labelColor = Colors.white38;
      icon = Icons.image_not_supported;
    } else if (alreadyViewed) {
      label = 'Ya vista';
      canView = false;
      labelColor = Colors.white38;
      icon = Icons.visibility_off;
    } else if (isOwn) {
      label = 'Foto enviada';
      canView = false;
      labelColor = Colors.white54;
      icon = Icons.camera_alt;
    } else {
      label = 'Mantén para ver 📸';
      canView = true;
      labelColor = const Color(0xFF39FF14);
      icon = Icons.camera_alt;
    }

    return Align(
      alignment: isOwn ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPressStart: canView ? (_) => onHoldStart() : null,
        onLongPressEnd: canView ? (_) => onHoldEnd() : null,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A0A2E),
            borderRadius: BorderRadius.circular(16),
            border: canView
                ? Border.all(color: const Color(0xFF39FF14), width: 1)
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: labelColor, size: 18),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(color: labelColor, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}
