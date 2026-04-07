// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Login — próximamente', style: TextStyle(color: Colors.white))),
        ),
      ),
      GoRoute(
        path: '/card',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('My Card — próximamente', style: TextStyle(color: Colors.white))),
        ),
      ),
    ],
  );
}
