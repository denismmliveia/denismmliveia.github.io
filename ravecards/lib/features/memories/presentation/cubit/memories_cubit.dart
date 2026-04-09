// lib/features/memories/presentation/cubit/memories_cubit.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/watch_memories.dart';
import 'memories_state.dart';

@injectable
class MemoriesCubit extends Cubit<MemoriesState> {
  final WatchMemories _watchMemories;
  StreamSubscription? _sub;

  MemoriesCubit({required WatchMemories watchMemories})
      : _watchMemories = watchMemories,
        super(const MemoriesInitial());

  void watch() {
    _sub?.cancel();
    emit(const MemoriesLoading());
    _sub = _watchMemories().listen(
      (result) => result.fold(
        (failure) => emit(MemoriesError(message: failure.message)),
        (memories) => emit(MemoriesLoaded(memories: memories)),
      ),
      onError: (e) => emit(MemoriesError(message: e.toString())),
    );
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
