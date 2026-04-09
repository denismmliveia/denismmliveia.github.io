import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:ravecards/core/error/failures.dart';
import 'package:ravecards/features/link/domain/entities/link_entity.dart';
import 'package:ravecards/features/link/domain/usecases/watch_my_links.dart';
import 'package:ravecards/features/link/presentation/cubit/links_cubit.dart';
import 'package:ravecards/features/link/presentation/cubit/links_state.dart';

import 'links_cubit_test.mocks.dart';

@GenerateMocks([WatchMyLinks])
void main() {
  late LinksCubit cubit;
  late MockWatchMyLinks mockWatchMyLinks;

  const tLink = LinkEntity(
    linkId: 'link-1',
    userA: 'uid-me',
    userB: 'uid-other',
    status: 'linked',
    initiatedBy: 'uid-me',
    createdAt: null,
  );

  setUp(() {
    mockWatchMyLinks = MockWatchMyLinks();
    cubit = LinksCubit(watchMyLinks: mockWatchMyLinks);
  });

  tearDown(() => cubit.close());

  blocTest<LinksCubit, LinksState>(
    'emits LinksLoaded when stream emits a list',
    build: () {
      when(mockWatchMyLinks('uid-me'))
          .thenAnswer((_) => Stream.value(const Right([tLink])));
      return cubit;
    },
    act: (c) => c.watchLinks('uid-me'),
    expect: () => [const LinksLoaded([tLink])],
  );

  blocTest<LinksCubit, LinksState>(
    'emits LinksError when stream emits a failure',
    build: () {
      when(mockWatchMyLinks('uid-me'))
          .thenAnswer((_) => Stream.value(const Left(LinkFailure('error'))));
      return cubit;
    },
    act: (c) => c.watchLinks('uid-me'),
    expect: () => [const LinksError('error')],
  );
}
