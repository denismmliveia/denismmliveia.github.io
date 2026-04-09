// lib/features/link/presentation/pages/links_page.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/links_cubit.dart';
import '../cubit/links_state.dart';
import '../widgets/link_card_widget.dart';

class LinksPage extends StatelessWidget {
  const LinksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    return BlocProvider(
      create: (_) => sl<LinksCubit>()..watchLinks(uid),
      child: _LinksView(myUid: uid),
    );
  }
}

class _LinksView extends StatelessWidget {
  final String myUid;
  const _LinksView({required this.myUid});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LinksCubit, LinksState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            title: const Text(
              'VÍNCULOS',
              style: TextStyle(
                color: AppColors.purple,
                letterSpacing: 4,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            automaticallyImplyLeading: false,
          ),
          body: switch (state) {
            LinksInitial() => const Center(
                child: CircularProgressIndicator(color: AppColors.purple)),
            LinksError(:final message) => Center(
                child: Text(message,
                    style: const TextStyle(color: AppColors.error))),
            LinksLoaded(:final links) when links.isEmpty => const Center(
                child: Text(
                  'Sin vínculos activos.\nEscanea el QR de alguien.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.white, height: 1.6),
                ),
              ),
            LinksLoaded(:final links) => ListView.builder(
                itemCount: links.length,
                itemBuilder: (context, i) => InkWell(
                  onTap: () => context.push(
                    '/chat/${links[i].linkId}',
                    extra: links[i],
                  ),
                  child: LinkCardWidget(
                    link: links[i],
                    myUid: myUid,
                  ),
                ),
              ),
            _ => const SizedBox.shrink(),
          },
        );
      },
    );
  }
}
