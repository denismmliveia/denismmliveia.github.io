// lib/features/card/presentation/widgets/rave_card_widget.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/card_entity.dart';
import 'qr_display_widget.dart';

class RaveCardWidget extends StatelessWidget {
  final CardEntity card;
  final bool isQrRefreshing;
  final VoidCallback? onScanTap;

  const RaveCardWidget({
    super.key,
    required this.card,
    this.isQrRefreshing = false,
    this.onScanTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 420),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.purple.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withValues(alpha: 0.1),
            blurRadius: 40,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Grid de fondo
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CustomPaint(painter: _GridPainter()),
            ),
          ),
          // Glow superior
          Positioned(
            top: -80,
            left: 0,
            right: 0,
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [AppColors.purple.withValues(alpha: 0.15), Colors.transparent],
                  radius: 0.65,
                ),
              ),
            ),
          ),
          // Contenido
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('RAVE CARD',
                        style: Theme.of(context).textTheme.labelSmall),
                    Row(
                      children: [
                        _StatusDot(),
                        const SizedBox(width: 5),
                        const Text('ACTIVE',
                            style: TextStyle(
                              fontSize: 9,
                              color: AppColors.green,
                              letterSpacing: 2,
                            )),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Foto circular
                Container(
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.purple, width: 2),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.purple.withValues(alpha: 0.5),
                          blurRadius: 20),
                      BoxShadow(
                          color: AppColors.purple.withValues(alpha: 0.2),
                          blurRadius: 48),
                    ],
                  ),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: card.photoUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          const CircularProgressIndicator(color: AppColors.purple),
                      errorWidget: (_, __, ___) =>
                          const Icon(Icons.person, color: AppColors.purple, size: 40),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Nombre
                Text(
                  card.displayName.toUpperCase(),
                  style: Theme.of(context).textTheme.displayLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  card.favoriteTheme.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).textTheme.labelSmall?.color?.withValues(alpha: 0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Campos de identidad
                _FieldRow(label: 'GÉNERO FAV', value: card.genre),
                const SizedBox(height: 8),
                _FieldRow(label: 'ORIENTACIÓN', value: card.orientation),
                const SizedBox(height: 8),
                _FieldRow(label: 'ESTADO', value: card.relationshipStatus),
                const SizedBox(height: 24),
                // QR
                QrDisplayWidget(
                  token: card.activeQrToken,
                  isRefreshing: isQrRefreshing,
                ),
                const SizedBox(height: 16),
                // Botón escanear
                if (onScanTap != null)
                  ElevatedButton.icon(
                    onPressed: onScanTap,
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('ESCANEAR'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green.withValues(alpha: 0.15),
                      foregroundColor: AppColors.green,
                      side: const BorderSide(color: AppColors.green, width: 1),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusDot extends StatefulWidget {
  @override
  State<_StatusDot> createState() => _StatusDotState();
}

class _StatusDotState extends State<_StatusDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _opacity = Tween(begin: 1.0, end: 0.3).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.green,
          boxShadow: [BoxShadow(color: AppColors.green, blurRadius: 6)],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _FieldRow extends StatelessWidget {
  final String label;
  final String value;
  const _FieldRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
              fontSize: 9,
              color: AppColors.textSecondary,
              letterSpacing: 2,
            )),
        Text(value,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.white,
              letterSpacing: 1,
            )),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.purple.withValues(alpha: 0.06)
      ..strokeWidth = 1;
    const step = 28.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
