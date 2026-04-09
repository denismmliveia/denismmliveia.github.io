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
              ],
            ),
          ),
        );
      },
    );
  }
}
