import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ravecards/core/error/failures.dart';
import 'package:ravecards/features/memories/domain/entities/memory_entity.dart';
import 'package:ravecards/features/memories/domain/usecases/watch_memories.dart';
import 'package:ravecards/features/memories/presentation/cubit/memories_cubit.dart';
import 'package:ravecards/features/memories/presentation/cubit/memories_state.dart';

class MockWatchMemories extends Mock implements WatchMemories {}

final tMemory = MemoryEntity(
  linkId: 'link-1',
  otherUid: 'uid-b',
  otherUserName: 'Marco',
  endedAt: DateTime(2026, 4, 9, 22),
  status: MemoryStatus.expired,
);

void main() {
  late MockWatchMemories watchMemories;

  setUp(() => watchMemories = MockWatchMemories());

  group('MemoriesCubit', () {
    blocTest<MemoriesCubit, MemoriesState>(
      'emits [loading, loaded] when watchMemories returns memories',
      build: () {
        when(() => watchMemories()).thenAnswer(
          (_) => Stream.value(Right([tMemory])),
        );
        return MemoriesCubit(watchMemories: watchMemories);
      },
      act: (cubit) => cubit.watch(),
      expect: () => [
        const MemoriesLoading(),
        MemoriesLoaded(memories: [tMemory]),
      ],
    );

    blocTest<MemoriesCubit, MemoriesState>(
      'emits [loading, error] when watchMemories returns failure',
      build: () {
        when(() => watchMemories()).thenAnswer(
          (_) => Stream.value(Left(const MemoryFailure('error'))),
        );
        return MemoriesCubit(watchMemories: watchMemories);
      },
      act: (cubit) => cubit.watch(),
      expect: () => [
        const MemoriesLoading(),
        const MemoriesError(message: 'error'),
      ],
    );

    blocTest<MemoriesCubit, MemoriesState>(
      'emits [loading, loaded(empty)] when no memories',
      build: () {
        when(() => watchMemories()).thenAnswer(
          (_) => Stream.value(const Right([])),
        );
        return MemoriesCubit(watchMemories: watchMemories);
      },
      act: (cubit) => cubit.watch(),
      expect: () => [
        const MemoriesLoading(),
        const MemoriesLoaded(memories: []),
      ],
    );
  });
}
