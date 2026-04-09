// lib/features/auth/presentation/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/phone_input_widget.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthCubit>(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthOtpSent) {
            context.push('/verify-otp', extra: state.verificationId);
          } else if (state is AuthAuthenticated) {
            context.go(state.user.hasCard ? '/card' : '/create-card');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  // Logo / título
                  Text(
                    'RAVECARDS',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      shadows: [const Shadow(color: AppColors.purple, blurRadius: 20)],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ENCUENTRA · ESCANEA · CONECTA',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const Spacer(),
                  if (state is AuthLoading)
                    const Center(child: CircularProgressIndicator(color: AppColors.purple))
                  else ...[
                    PhoneInputWidget(
                      onSubmit: (phone) =>
                          context.read<AuthCubit>().sendOtp(phone),
                    ),
                    const SizedBox(height: 16),
                    const Row(children: [
                      Expanded(child: Divider(color: AppColors.textSecondary)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('o', style: TextStyle(color: AppColors.textSecondary)),
                      ),
                      Expanded(child: Divider(color: AppColors.textSecondary)),
                    ]),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => context.read<AuthCubit>().signInWithGoogle(),
                      icon: const Icon(Icons.g_mobiledata, color: AppColors.white),
                      label: const Text('Continuar con Google',
                          style: TextStyle(color: AppColors.white)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.purple.withValues(alpha: 0.4)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                  const Spacer(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
