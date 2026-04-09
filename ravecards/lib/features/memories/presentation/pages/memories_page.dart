// lib/features/memories/presentation/pages/memories_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/memories_cubit.dart';
import '../cubit/memories_state.dart';
import '../widgets/memory_card_widget.dart';

class MemoriesPage extends StatelessWidget {
  const MemoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MemoriesCubit>()..watch(),
      child: const _MemoriesView(),
    );
  }
}

class _MemoriesView extends StatelessWidget {
  const _MemoriesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        automaticallyImplyLeading: false,
        title: const Text(
          'RECUERDOS',
          style: TextStyle(
            color: AppColors.purple,
            letterSpacing: 4,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocBuilder<MemoriesCubit, MemoriesState>(
        builder: (context, state) => switch (state) {
          MemoriesInitial() || MemoriesLoading() =>
            const Center(child: CircularProgressIndicator(color: AppColors.purple)),
          MemoriesError(:final message) =>
            Center(child: Text(message, style: const TextStyle(color: AppColors.error))),
          MemoriesLoaded(:final memories) when memories.isEmpty =>
            const Center(
              child: Text(
                'Los recuerdos llegarán\ncuando los vínculos expiren.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.white, height: 1.6),
              ),
            ),
          MemoriesLoaded(:final memories) => ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: memories.length,
              itemBuilder: (_, i) => MemoryCardWidget(memory: memories[i]),
            ),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}
