// lib/features/scan/presentation/pages/scan_preview_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../card/presentation/widgets/rave_card_widget.dart';
import '../cubit/scan_cubit.dart';
import '../cubit/scan_state.dart';

class ScanPreviewPage extends StatelessWidget {
  const ScanPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ScanCubit, ScanState>(
      listener: (context, state) {
        if (state is ScanPending) {
          context.go('/scan/pending/${state.linkId}');
        } else if (state is ScanLinked) {
          context.go('/scan/linked/${state.linkId}');
        } else if (state is ScanError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
          context.go('/scan');
        }
      },
      child: BlocBuilder<ScanCubit, ScanState>(
        builder: (context, state) {
          if (state is! ScanPreview && state is! ScanInitiating) {
            return const Scaffold(
              backgroundColor: AppColors.background,
              body: Center(child: CircularProgressIndicator(color: AppColors.purple)),
            );
          }

          final card = state is ScanPreview
              ? state.otherCard
              : (state as ScanInitiating).otherCard;
          final token = state is ScanPreview ? state.token : null;
          final isLoading = state is ScanInitiating;

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.background,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.white),
                onPressed: () => context.go('/scan'),
              ),
              title: const Text(
                'NUEVA CONEXIÓN',
                style: TextStyle(
                  color: AppColors.purple,
                  letterSpacing: 3,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    RaveCardWidget(card: card, isQrRefreshing: false),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading || token == null
                            ? null
                            : () => context
                                .read<ScanCubit>()
                                .onInitiateLink(token, card),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.purple,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: AppColors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'INICIAR ENLACE',
                                style: TextStyle(
                                  letterSpacing: 3,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
