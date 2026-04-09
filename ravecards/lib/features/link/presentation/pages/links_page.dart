// lib/features/link/presentation/pages/links_page.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../moderation/domain/usecases/revoke_link.dart';
import '../../../moderation/domain/usecases/block_user.dart';
import '../../../moderation/domain/usecases/report_user.dart';
import '../cubit/links_cubit.dart';
import '../cubit/links_state.dart';
import '../widgets/link_card_widget.dart';

class LinksPage extends StatelessWidget {
  const LinksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    return BlocProvider(
      create: (_) => sl<LinksCubit>()..watchLinks(uid),
      child: _LinksView(myUid: uid),
    );
  }
}

class _LinksView extends StatelessWidget {
  final String myUid;
  const _LinksView({required this.myUid});

  Future<void> _confirmRevoke(BuildContext context, String linkId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0D0020),
        title: const Text('Revocar vínculo',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          '¿Seguro? El chat y el vínculo desaparecerán para ambos.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Revocar',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      final result = await sl<RevokeLink>().call(linkId);
      if (context.mounted) {
        result.fold(
          (f) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(f.message),
                backgroundColor: AppColors.error),
          ),
          (_) {},
        );
      }
    }
  }

  Future<void> _confirmBlock(
      BuildContext context, String targetUid, String linkId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0D0020),
        title: const Text('Bloquear usuario',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          'Esta persona no podrá verte ni escanearte. El vínculo actual también se revocará.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Bloquear',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      final result =
          await sl<BlockUser>().call(targetUid: targetUid, linkId: linkId);
      if (context.mounted) {
        result.fold(
          (f) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(f.message),
                backgroundColor: AppColors.error),
          ),
          (_) {},
        );
      }
    }
  }

  Future<void> _showReportDialog(
      BuildContext context, String targetUid, String linkId) async {
    String? selectedReason;
    final reasons = ['Acoso', 'Contenido inapropiado', 'Spam', 'Otro'];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: const Color(0xFF0D0020),
          title: const Text('Reportar usuario',
              style: TextStyle(color: Colors.white)),
          content: RadioGroup<String>(
            groupValue: selectedReason,
            onChanged: (v) => setState(() => selectedReason = v),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: reasons
                  .map((r) => InkWell(
                        onTap: () => setState(() => selectedReason = r),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
                          child: Row(
                            children: [
                              Radio<String>(
                                value: r,
                                activeColor: AppColors.purple,
                              ),
                              Text(r,
                                  style: const TextStyle(
                                      color: Colors.white70)),
                            ],
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child:
                  const Text('Cancelar', style: TextStyle(color: Colors.white54)),
            ),
            TextButton(
              onPressed: selectedReason == null
                  ? null
                  : () => Navigator.of(ctx).pop(true),
              child: const Text('Reportar',
                  style: TextStyle(color: AppColors.error)),
            ),
          ],
        ),
      ),
    );
    if (confirmed == true && selectedReason != null && context.mounted) {
      final result = await sl<ReportUser>()
          .call(targetUid: targetUid, reason: selectedReason!, linkId: linkId);
      if (context.mounted) {
        result.fold(
          (f) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(f.message),
                backgroundColor: AppColors.error),
          ),
          (_) {},
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LinksCubit, LinksState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            title: const Text(
              'VÍNCULOS',
              style: TextStyle(
                color: AppColors.purple,
                letterSpacing: 4,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            automaticallyImplyLeading: false,
          ),
          body: switch (state) {
            LinksInitial() => const Center(
                child: CircularProgressIndicator(color: AppColors.purple)),
            LinksError(:final message) => Center(
                child: Text(message,
                    style: const TextStyle(color: AppColors.error))),
            LinksLoaded(:final links) when links.isEmpty => const Center(
                child: Text(
                  'Sin vínculos activos.\nEscanea el QR de alguien.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.white, height: 1.6),
                ),
              ),
            LinksLoaded(:final links) => ListView.builder(
                itemCount: links.length,
                itemBuilder: (context, i) {
                  final link = links[i];
                  final otherUid = link.otherUser(myUid);
                  return Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => context.push(
                            '/chat/${link.linkId}',
                            extra: link,
                          ),
                          child: LinkCardWidget(link: link, myUid: myUid),
                        ),
                      ),
                      if (link.isLinked)
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert,
                              color: Colors.white38),
                          color: const Color(0xFF0D0020),
                          onSelected: (value) {
                            if (value == 'revoke') {
                              _confirmRevoke(context, link.linkId);
                            } else if (value == 'block') {
                              _confirmBlock(context, otherUid, link.linkId);
                            } else if (value == 'report') {
                              _showReportDialog(context, otherUid, link.linkId);
                            }
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                              value: 'revoke',
                              child: Text('Revocar vínculo',
                                  style: TextStyle(color: Colors.white70)),
                            ),
                            const PopupMenuItem(
                              value: 'block',
                              child: Text('Bloquear',
                                  style: TextStyle(color: Colors.white70)),
                            ),
                            const PopupMenuItem(
                              value: 'report',
                              child: Text('Reportar',
                                  style: TextStyle(color: AppColors.error)),
                            ),
                          ],
                        ),
                    ],
                  );
                },
              ),
            _ => const SizedBox.shrink(),
          },
        );
      },
    );
  }
}
