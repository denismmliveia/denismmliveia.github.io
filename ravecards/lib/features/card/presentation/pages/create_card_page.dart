// lib/features/card/presentation/pages/create_card_page.dart
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/card_cubit.dart';
import '../cubit/card_state.dart';

class CreateCardPage extends StatefulWidget {
  const CreateCardPage({super.key});

  @override
  State<CreateCardPage> createState() => _CreateCardPageState();
}

class _CreateCardPageState extends State<CreateCardPage> {
  final _nameController = TextEditingController();
  File? _photo;
  String _genre = 'Techno';
  String _orientation = 'Heterosexual';
  String _status = 'Soltero/a';
  String _theme = 'Industrial';

  final _genres = ['Techno', 'House', 'Trance', 'Drum & Bass', 'Ambient', 'Otro'];
  final _orientations = ['Heterosexual', 'Gay / Lesbiana', 'Bisexual', 'Pansexual', 'Prefiero no decirlo'];
  final _statuses = ['Soltero/a', 'En pareja', 'Free agent', 'Complicado', 'Prefiero no decirlo'];
  final _themes = ['Industrial', 'Club oscuro', 'Festival', 'After', 'Colectivo', 'Underground'];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CardCubit>(),
      child: BlocConsumer<CardCubit, CardState>(
        listener: (context, state) {
          if (state is CardLoaded) {
            context.go('/card');
          } else if (state is CardError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: const Text('Crea tu RaveCard')),
            body: state is CardCreating
                ? const Center(child: CircularProgressIndicator(color: AppColors.purple))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Foto
                        GestureDetector(
                          onTap: _pickPhoto,
                          child: Center(
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.purple, width: 2),
                              ),
                              child: ClipOval(
                                child: _photo != null
                                    ? Image.file(_photo!, fit: BoxFit.cover)
                                    : const Icon(Icons.add_a_photo,
                                        color: AppColors.purple, size: 40),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Center(
                          child: Text('Toca para añadir foto *',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        ),
                        const SizedBox(height: 24),
                        // Nombre
                        TextField(
                          controller: _nameController,
                          textCapitalization: TextCapitalization.characters,
                          style: const TextStyle(color: AppColors.white, letterSpacing: 3),
                          decoration: const InputDecoration(labelText: 'Nombre visible *'),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 16),
                        // Dropdowns
                        _Dropdown(
                          label: 'Género favorito',
                          value: _genre,
                          items: _genres,
                          onChanged: (v) => setState(() => _genre = v!),
                        ),
                        const SizedBox(height: 12),
                        _Dropdown(
                          label: 'Orientación',
                          value: _orientation,
                          items: _orientations,
                          onChanged: (v) => setState(() => _orientation = v!),
                        ),
                        const SizedBox(height: 12),
                        _Dropdown(
                          label: 'Estado',
                          value: _status,
                          items: _statuses,
                          onChanged: (v) => setState(() => _status = v!),
                        ),
                        const SizedBox(height: 12),
                        _Dropdown(
                          label: 'Temática favorita',
                          value: _theme,
                          items: _themes,
                          onChanged: (v) => setState(() => _theme = v!),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: _canSubmit() ? () => _submit(context) : null,
                          child: const Text('CREAR MI RAVECARD'),
                        ),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }

  bool _canSubmit() =>
      _photo != null && _nameController.text.trim().isNotEmpty;

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) setState(() => _photo = File(picked.path));
  }

  void _submit(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    context.read<CardCubit>().createCard(CreateCardParams(
      uid: uid,
      displayName: _nameController.text.trim(),
      photo: _photo!,
      genre: _genre,
      orientation: _orientation,
      relationshipStatus: _status,
      favoriteTheme: _theme,
    ));
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}

class _Dropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final void Function(String?) onChanged;

  const _Dropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(labelText: label),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: AppColors.surface,
          style: const TextStyle(color: AppColors.white),
          isExpanded: true,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
