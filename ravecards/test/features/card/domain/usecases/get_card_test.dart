// test/features/card/domain/usecases/get_card_test.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:ravecards/core/error/failures.dart';
import 'package:ravecards/features/card/domain/entities/card_entity.dart';
import 'package:ravecards/features/card/domain/repositories/card_repository.dart';
import 'package:ravecards/features/card/domain/usecases/get_card.dart';

import 'get_card_test.mocks.dart';

@GenerateMocks([CardRepository])
void main() {
  late GetCard usecase;
  late MockCardRepository mockRepo;

  setUp(() {
    mockRepo = MockCardRepository();
    usecase = GetCard(mockRepo);
  });

  const tCard = CardEntity(
    uid: 'uid-123',
    displayName: 'TECHNO GHOST',
    photoUrl: 'https://example.com/photo.jpg',
    genre: 'Techno',
    orientation: 'Bisexual',
    relationshipStatus: 'Free agent',
    favoriteTheme: 'Industrial',
  );

  test('should return CardEntity from repository', () async {
    when(mockRepo.getCard(any)).thenAnswer((_) async => const Right(tCard));

    final result = await usecase('uid-123');

    expect(result, const Right(tCard));
    verify(mockRepo.getCard('uid-123'));
  });

  test('should return CardFailure when repository fails', () async {
    when(mockRepo.getCard(any))
        .thenAnswer((_) async => const Left(CardFailure('Not found')));

    final result = await usecase('uid-123');

    expect(result, const Left(CardFailure('Not found')));
  });
}
