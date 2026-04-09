// lib/features/memories/domain/usecases/watch_memories.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/memory_entity.dart';
import '../repositories/memory_repository.dart';

@injectable
class WatchMemories {
  final MemoryRepository _repo;
  WatchMemories(this._repo);

  Stream<Either<MemoryFailure, List<MemoryEntity>>> call() => _repo.watchMemories();
}
