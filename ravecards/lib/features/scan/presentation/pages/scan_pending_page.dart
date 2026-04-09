// lib/features/scan/presentation/pages/scan_pending_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/scan_cubit.dart';
import '../cubit/scan_state.dart';

class ScanPendingPage extends StatelessWidget {
  const ScanPendingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ScanCubit, ScanState>(
      listener: (context, state) {
        if (state is ScanLinked) {
          context.go('/scan/linked/${state.linkId}');
        } else if (state is ScanError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
          context.go('/card');
        }
      },
      child: BlocBuilder<ScanCubit, ScanState>(
        builder: (context, state) {
          final remaining =
              state is ScanPending ? state.remainingSeconds : 0;
          final pct = remaining / 60.0;

          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 140,
                        height: 140,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: pct,
                              strokeWidth: 6,
                              color: AppColors.green,
                              backgroundColor:
                                  AppColors.green.withValues(alpha: 0.15),
                            ),
                            Text(
                              '$remaining',
                              style: const TextStyle(
                                color: AppColors.green,
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      const Text(
                        'ESPERANDO...',
                        style: TextStyle(
                          color: AppColors.purple,
                          letterSpacing: 4,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Pídele que te escanee\nde vuelta antes de que\nel tiempo se acabe',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 48),
                      TextButton(
                        onPressed: () => context.go('/card'),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(
                            color: AppColors.white,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
