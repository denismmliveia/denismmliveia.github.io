// lib/features/memories/presentation/pages/memories_stub_page.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class MemoriesStubPage extends StatelessWidget {
  const MemoriesStubPage({super.key});

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
      body: const Center(
        child: Text(
          'Los recuerdos llegarán\ncuando los vínculos expiren.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.white,
            height: 1.6,
          ),
        ),
      ),
    );
  }
}
