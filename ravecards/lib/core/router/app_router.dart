// lib/core/router/app_router.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../di/injection_container.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/phone_verify_page.dart';
import '../../features/card/presentation/pages/create_card_page.dart';
import '../../features/card/presentation/pages/my_card_page.dart';
import '../../features/chat/presentation/cubit/chat_cubit.dart';
import '../../features/chat/presentation/pages/chat_page.dart';
import '../../features/link/domain/entities/link_entity.dart';
import '../../features/link/presentation/pages/links_page.dart';
import '../../features/memories/presentation/pages/memories_page.dart';
import '../../features/scan/presentation/cubit/scan_cubit.dart';
import '../../features/scan/presentation/pages/scan_camera_page.dart';
import '../../features/scan/presentation/pages/scan_linked_page.dart';
import '../../features/scan/presentation/pages/scan_pending_page.dart';
import '../../features/scan/presentation/pages/scan_preview_page.dart';
import '../presentation/pages/main_scaffold.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/card',
    redirect: (context, state) async {
      final user = FirebaseAuth.instance.currentUser;
      final loc = state.matchedLocation;
      final isOnAuth =
          loc.startsWith('/login') || loc.startsWith('/verify-otp');

      if (user == null && !isOnAuth) return '/login';
      if (user != null && isOnAuth) return '/card';
      return null;
    },
    routes: [
      // Auth routes (outside shell — no bottom nav)
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(
        path: '/verify-otp',
        builder: (_, state) =>
            PhoneVerifyPage(verificationId: state.extra as String),
      ),
      GoRoute(
          path: '/create-card', builder: (_, __) => const CreateCardPage()),

      // Scan routes (full-screen — outside shell, ScanCubit provided here)
      GoRoute(
        path: '/scan',
        builder: (_, __) => BlocProvider(
          create: (_) => sl<ScanCubit>(),
          child: const ScanCameraPage(),
        ),
        routes: [
          GoRoute(
            path: 'preview',
            builder: (context, __) => BlocProvider.value(
              value: BlocProvider.of<ScanCubit>(context),
              child: const ScanPreviewPage(),
            ),
          ),
          GoRoute(
            path: 'pending/:linkId',
            builder: (context, __) => BlocProvider.value(
              value: BlocProvider.of<ScanCubit>(context),
              child: const ScanPendingPage(),
            ),
          ),
          GoRoute(
            path: 'linked/:linkId',
            builder: (context, __) => BlocProvider.value(
              value: BlocProvider.of<ScanCubit>(context),
              child: const ScanLinkedPage(),
            ),
          ),
        ],
      ),

      // Chat route (full-screen — outside shell, no bottom nav)
      GoRoute(
        path: '/chat/:linkId',
        builder: (_, state) {
          final linkId = state.pathParameters['linkId']!;
          final link = state.extra as LinkEntity;
          return BlocProvider(
            create: (_) => sl<ChatCubit>(),
            child: ChatPage(linkId: linkId, link: link),
          );
        },
      ),

      // Main shell with bottom navigation
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(path: '/card', builder: (_, __) => const MyCardPage()),
          GoRoute(path: '/links', builder: (_, __) => const LinksPage()),
          GoRoute(
              path: '/memories',
              builder: (_, __) => const MemoriesPage()),
        ],
      ),
    ],
  );
}
