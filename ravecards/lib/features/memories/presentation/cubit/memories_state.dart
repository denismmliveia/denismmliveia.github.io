// lib/features/memories/presentation/cubit/memories_state.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/memory_entity.dart';

sealed class MemoriesState extends Equatable {
  const MemoriesState();
}

class MemoriesInitial extends MemoriesState {
  const MemoriesInitial();
  @override List<Object?> get props => [];
}

class MemoriesLoading extends MemoriesState {
  const MemoriesLoading();
  @override List<Object?> get props => [];
}

class MemoriesLoaded extends MemoriesState {
  final List<MemoryEntity> memories;
  const MemoriesLoaded({required this.memories});
  @override List<Object?> get props => [memories];
}

class MemoriesError extends MemoriesState {
  final String message;
  const MemoriesError({required this.message});
  @override List<Object?> get props => [message];
}
