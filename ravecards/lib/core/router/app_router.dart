// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/phone_verify_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) async {
      // Guard básico de auth — se expande en tasks siguientes
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/verify-otp',
        builder: (context, state) => PhoneVerifyPage(
          verificationId: state.extra as String,
        ),
      ),
      GoRoute(
        path: '/card',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('My Card — Task 14', style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
      GoRoute(
        path: '/create-card',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Create Card — Task 14', style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    ],
  );
}
