// lib/features/link/presentation/widgets/countdown_widget.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Displays a ticking countdown for a given [expiresAt] date.
/// Rebuilds every minute (or every second if [highPrecision] is true).
class CountdownWidget extends StatefulWidget {
  final DateTime? expiresAt;
  final bool highPrecision;

  const CountdownWidget({
    super.key,
    required this.expiresAt,
    this.highPrecision = false,
  });

  @override
  State<CountdownWidget> createState() => _CountdownWidgetState();
}

class _CountdownWidgetState extends State<CountdownWidget> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      widget.highPrecision
          ? const Duration(seconds: 1)
          : const Duration(minutes: 1),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.expiresAt == null) {
      return const Text('—', style: TextStyle(color: AppColors.white));
    }

    final remaining = widget.expiresAt!.difference(DateTime.now());
    if (remaining.isNegative) {
      return const Text(
        'Expirado',
        style: TextStyle(color: AppColors.error, fontSize: 12),
      );
    }

    final h = remaining.inHours;
    final m = remaining.inMinutes % 60;
    final label = h > 0 ? '${h}h ${m}m' : '${m}m';

    return Text(
      label,
      style: const TextStyle(
        color: AppColors.green,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
