import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:ravecards/features/link/domain/entities/link_entity.dart';
import 'package:ravecards/features/link/domain/repositories/link_repository.dart';
import 'package:ravecards/features/link/domain/usecases/watch_link.dart';
import 'package:ravecards/features/link/domain/usecases/watch_my_links.dart';

import 'watch_my_links_test.mocks.dart';

@GenerateMocks([LinkRepository])
void main() {
  late MockLinkRepository mockRepo;

  const tLink = LinkEntity(
    linkId: 'link-1',
    userA: 'uid-a',
    userB: 'uid-b',
    status: 'pending',
    initiatedBy: 'uid-a',
  );

  setUp(() => mockRepo = MockLinkRepository());

  group('WatchMyLinks', () {
    test('streams list from repository', () {
      when(mockRepo.watchMyLinks('uid-a'))
          .thenAnswer((_) => Stream.value(const Right([tLink])));

      final useCase = WatchMyLinks(mockRepo);
      expect(useCase('uid-a'), emits(const Right<dynamic, List<LinkEntity>>([tLink])));
    });
  });

  group('WatchLink', () {
    test('streams single link from repository', () {
      when(mockRepo.watchLink('link-1'))
          .thenAnswer((_) => Stream.value(const Right(tLink)));

      final useCase = WatchLink(mockRepo);
      expect(useCase('link-1'), emits(const Right<dynamic, LinkEntity>(tLink)));
    });
  });
}
