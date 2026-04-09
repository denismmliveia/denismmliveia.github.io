// lib/features/card/presentation/pages/my_card_page.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/card_cubit.dart';
import '../cubit/card_state.dart';
import '../widgets/rave_card_widget.dart';

class MyCardPage extends StatelessWidget {
  const MyCardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    return BlocProvider(
      create: (_) => sl<CardCubit>()..loadCard(uid),
      child: const _MyCardView(),
    );
  }
}

class _MyCardView extends StatelessWidget {
  const _MyCardView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CardCubit, CardState>(
      builder: (context, state) {
        if (state is CardNotFound) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => context.go('/create-card'),
          );
          return const SizedBox.shrink();
        }

        if (state is CardLoading || state is CardInitial) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.purple),
          );
        }

        if (state is CardError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(state.message, style: const TextStyle(color: AppColors.error)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<CardCubit>().loadCard(
                        FirebaseAuth.instance.currentUser?.uid ?? '',
                      ),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        final card = state is CardLoaded
            ? state.card
            : (state as CardQrRefreshing).card;
        final isRefreshing = state is CardQrRefreshing;

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                RaveCardWidget(
                  card: card,
                  isQrRefreshing: isRefreshing,
                  onScanTap: () => context.push('/scan'),
                ),
                const SizedBox(height: 12),
                const _AccountMenu(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AccountMenu extends StatelessWidget {
  const _AccountMenu();

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        switch (value) {
          case 'delete':
            final confirm = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                backgroundColor: AppColors.surface,
                title: const Text('Borrar tarjeta'),
                content: const Text(
                  '¿Seguro que quieres borrar tu RaveCard? Podrás crear una nueva después.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Borrar',
                        style: TextStyle(color: AppColors.error)),
                  ),
                ],
              ),
            );
            if (confirm == true && context.mounted) {
              final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
              context.read<CardCubit>().deleteCard(uid);
            }
          case 'logout':
            await FirebaseAuth.instance.signOut();
            if (context.mounted) context.go('/login');
        }
      },
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 16, color: AppColors.textSecondary),
              SizedBox(width: 8),
              Text(
                'Borrar tarjeta',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, size: 16, color: AppColors.textSecondary),
              SizedBox(width: 8),
              Text(
                'Cerrar sesión',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.more_horiz,
              size: 18,
              color: AppColors.white.withValues(alpha: 0.5)),
          const SizedBox(width: 4),
          Text(
            'cuenta',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1.5,
              color: AppColors.white.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}
