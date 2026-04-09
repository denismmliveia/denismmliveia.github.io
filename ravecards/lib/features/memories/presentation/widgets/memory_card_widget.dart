// lib/features/memories/presentation/widgets/memory_card_widget.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/memory_entity.dart';

class MemoryCardWidget extends StatelessWidget {
  final MemoryEntity memory;

  const MemoryCardWidget({super.key, required this.memory});

  @override
  Widget build(BuildContext context) {
    final statusLabel = memory.status == MemoryStatus.revoked ? 'Revocado' : 'Expirado';
    final statusColor =
        memory.status == MemoryStatus.revoked ? AppColors.error : Colors.white38;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0020),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.purple.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          if (memory.otherUserPhotoUrl != null)
            CircleAvatar(
              radius: 22,
              backgroundImage: NetworkImage(memory.otherUserPhotoUrl!),
            )
          else
            const CircleAvatar(
              radius: 22,
              backgroundColor: Color(0xFF6600CC),
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  memory.otherUserName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(memory.endedAt),
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            statusLabel,
            style: TextStyle(color: statusColor, fontSize: 11),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
