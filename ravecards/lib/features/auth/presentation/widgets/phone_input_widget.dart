// lib/features/auth/presentation/widgets/phone_input_widget.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class PhoneInputWidget extends StatefulWidget {
  final void Function(String phone) onSubmit;
  const PhoneInputWidget({super.key, required this.onSubmit});

  @override
  State<PhoneInputWidget> createState() => _PhoneInputWidgetState();
}

class _PhoneInputWidgetState extends State<PhoneInputWidget> {
  final _controller = TextEditingController();
  final String _prefix = '+34';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            // Prefijo de país simplificado — expandible en el futuro
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.purple.withValues(alpha: 0.4)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(_prefix, style: const TextStyle(color: AppColors.white)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _controller,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: AppColors.white),
                decoration: const InputDecoration(
                  labelText: 'Número de teléfono',
                  hintText: '600 000 000',
                  hintStyle: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            final phone = '$_prefix${_controller.text.replaceAll(' ', '')}';
            widget.onSubmit(phone);
          },
          child: const Text('ENVIAR CÓDIGO'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
