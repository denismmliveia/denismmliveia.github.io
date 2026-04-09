// lib/features/scan/presentation/pages/scan_linked_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/scan_cubit.dart';
import '../cubit/scan_state.dart';

class ScanLinkedPage extends StatefulWidget {
  const ScanLinkedPage({super.key});

  @override
  State<ScanLinkedPage> createState() => _ScanLinkedPageState();
}

class _ScanLinkedPageState extends State<ScanLinkedPage> {
  int _selectedDurationHours = 4;

  static const _durations = [
    (hours: 4, label: '4 horas'),
    (hours: 12, label: '12 horas'),
    (hours: 24, label: '24 horas'),
    (hours: 72, label: '3 días'),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocListener<ScanCubit, ScanState>(
      listener: (context, state) {
        if (state is ScanConfirmed) {
          context.go('/links');
        } else if (state is ScanError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: BlocBuilder<ScanCubit, ScanState>(
        builder: (context, state) {
          if (state is! ScanLinked && state is! ScanConfirming) {
            return const Scaffold(
              backgroundColor: AppColors.background,
              body: Center(
                  child: CircularProgressIndicator(color: AppColors.purple)),
            );
          }

          final isConfirmer =
              state is ScanLinked ? state.isConfirmer : true;
          final linkId = state is ScanLinked
              ? state.linkId
              : (state as ScanConfirming).linkId;
          final isConfirming = state is ScanConfirming;

          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: isConfirmer
                      ? _buildConfirmerView(context, linkId, isConfirming)
                      : _buildReceiverView(context),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildConfirmerView(
      BuildContext context, String linkId, bool isConfirming) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('¡ENLACE DETECTADO!',
            style: TextStyle(
              color: AppColors.green,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
            )),
        const SizedBox(height: 8),
        const Text(
          '¿Cuánto tiempo quieres\nque dure este enlace?',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.white, fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 32),
        ...(_durations.map((d) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: GestureDetector(
                onTap: () =>
                    setState(() => _selectedDurationHours = d.hours),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: _selectedDurationHours == d.hours
                        ? AppColors.purple
                        : Colors.transparent,
                    border: Border.all(
                      color: _selectedDurationHours == d.hours
                          ? AppColors.purple
                          : AppColors.white.withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    d.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _selectedDurationHours == d.hours
                          ? AppColors.white
                          : AppColors.white.withValues(alpha: 0.7),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ))),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isConfirming
                ? null
                : () => context
                    .read<ScanCubit>()
                    .onConfirmLink(linkId, _selectedDurationHours),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: isConfirming
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.black, strokeWidth: 2),
                  )
                : const Text('CONFIRMAR ENLACE',
                    style: TextStyle(
                      letterSpacing: 3,
                      fontWeight: FontWeight.bold,
                    )),
          ),
        ),
      ],
    );
  }

  Widget _buildReceiverView(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('¡ENLAZADOS!',
            style: TextStyle(
              color: AppColors.green,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
            )),
        const SizedBox(height: 16),
        const Text(
          'El enlace ha sido confirmado.\nDisfruta mientras dure.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.white, fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 48),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => context.go('/links'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.purple,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('VER VÍNCULOS',
                style: TextStyle(letterSpacing: 3, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}
