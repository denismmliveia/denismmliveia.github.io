// lib/features/memories/domain/repositories/memory_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/memory_entity.dart';

abstract class MemoryRepository {
  Stream<Either<MemoryFailure, List<MemoryEntity>>> watchMemories();
}
