// lib/features/link/presentation/widgets/link_card_widget.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/link_entity.dart';
import 'countdown_widget.dart';

class LinkCardWidget extends StatelessWidget {
  final LinkEntity link;
  final String myUid;

  const LinkCardWidget({super.key, required this.link, required this.myUid});

  @override
  Widget build(BuildContext context) {
    final otherUid = link.otherUser(myUid);

    return GestureDetector(
      onTap: link.isLinked
          ? () => context.push('/chat/${link.linkId}') // Plan 3 route
          : null,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border.all(
            color: link.isLinked
                ? AppColors.purple.withValues(alpha: 0.6)
                : AppColors.white.withValues(alpha: 0.2),
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: link.isLinked
              ? [
                  BoxShadow(
                    color: AppColors.purple.withValues(alpha: 0.15),
                    blurRadius: 12,
                  )
                ]
              : null,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.purple.withValues(alpha: 0.3),
              child: Text(
                otherUid.substring(0, 2).toUpperCase(),
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    otherUid, // Plan 3 will show displayName
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (link.isPending)
                    const Text(
                      'Esperando escaneo de vuelta…',
                      style: TextStyle(color: AppColors.purple, fontSize: 12),
                    )
                  else
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: const BoxDecoration(
                            color: AppColors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        CountdownWidget(expiresAt: link.expiresAt),
                      ],
                    ),
                ],
              ),
            ),
            if (link.isLinked)
              const Icon(Icons.chevron_right, color: AppColors.white),
          ],
        ),
      ),
    );
  }
}
