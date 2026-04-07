// lib/core/router/app_router.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/phone_verify_page.dart';
import '../../features/card/presentation/pages/create_card_page.dart';
import '../../features/card/presentation/pages/my_card_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) async {
      final user = FirebaseAuth.instance.currentUser;
      final isOnAuth = state.matchedLocation.startsWith('/login') ||
          state.matchedLocation.startsWith('/verify-otp');

      if (user == null && !isOnAuth) return '/login';
      if (user != null && isOnAuth) return '/card';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(
        path: '/verify-otp',
        builder: (_, state) =>
            PhoneVerifyPage(verificationId: state.extra as String),
      ),
      GoRoute(path: '/create-card', builder: (_, __) => const CreateCardPage()),
      GoRoute(
        path: '/card',
        builder: (_, __) => const MyCardPage(),
      ),
      // Placeholder para Plan 2
      GoRoute(
        path: '/scan',
        builder: (_, __) => const Scaffold(
          body: Center(
            child: Text('Scan — Plan 2', style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    ],
  );
}
