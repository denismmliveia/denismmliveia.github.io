// lib/features/scan/presentation/pages/scan_camera_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/scan_cubit.dart';
import '../cubit/scan_state.dart';

class ScanCameraPage extends StatefulWidget {
  const ScanCameraPage({super.key});

  @override
  State<ScanCameraPage> createState() => _ScanCameraPageState();
}

class _ScanCameraPageState extends State<ScanCameraPage> {
  late final MobileScannerController _controller;
  bool _scanned = false; // prevent double-fire

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ScanCubit, ScanState>(
      listener: (context, state) {
        if (state is ScanPreview) {
          context.go('/scan/preview');
        } else if (state is ScanError) {
          _scanned = false; // allow retry
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: const Text(
            'ESCANEAR QR',
            style: TextStyle(
              color: AppColors.purple,
              letterSpacing: 3,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.close, color: AppColors.white),
            onPressed: () => context.pop(),
          ),
        ),
        body: Stack(
          children: [
            MobileScanner(
              controller: _controller,
              onDetect: (capture) {
                if (_scanned) return;
                final barcode = capture.barcodes.firstOrNull;
                if (barcode?.rawValue == null) return;
                _scanned = true;
                context.read<ScanCubit>().onQrScanned(barcode!.rawValue!);
              },
            ),
            // Overlay with scan frame
            Center(
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.purple, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            // Loading indicator during validation
            BlocBuilder<ScanCubit, ScanState>(
              builder: (context, state) {
                if (state is ScanValidating) {
                  return Container(
                    color: Colors.black54,
                    child: const Center(
                      child: CircularProgressIndicator(color: AppColors.purple),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
