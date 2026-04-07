// lib/features/card/presentation/widgets/qr_display_widget.dart
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/theme/app_colors.dart';

class QrDisplayWidget extends StatelessWidget {
  final String? token;
  final bool isRefreshing;

  const QrDisplayWidget({super.key, this.token, this.isRefreshing = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 180,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withValues(alpha: 0.4),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: isRefreshing
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.purple),
            )
          : token == null
              ? const Center(
                  child: Icon(Icons.qr_code_2, size: 60, color: AppColors.textSecondary),
                )
              : QrImageView(
                  data: token!,
                  version: QrVersions.auto,
                  backgroundColor: AppColors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: AppColors.background,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: AppColors.background,
                  ),
                ),
    );
  }
}
