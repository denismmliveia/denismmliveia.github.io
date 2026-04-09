// test/features/card/presentation/cubit/card_cubit_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:ravecards/core/error/failures.dart';
import 'package:ravecards/features/card/domain/entities/card_entity.dart';
import 'package:ravecards/features/card/domain/usecases/create_card.dart';
import 'package:ravecards/features/card/domain/usecases/get_card.dart';
import 'package:ravecards/features/card/domain/usecases/refresh_qr_token.dart';
import 'package:ravecards/features/card/presentation/cubit/card_cubit.dart';
import 'package:ravecards/features/card/presentation/cubit/card_state.dart';

import 'card_cubit_test.mocks.dart';

@GenerateMocks([GetCard, CreateCard, RefreshQrToken])
void main() {
  late CardCubit cubit;
  late MockGetCard mockGetCard;
  late MockCreateCard mockCreateCard;
  late MockRefreshQrToken mockRefreshQrToken;

  const tCard = CardEntity(
    uid: 'uid-123',
    displayName: 'TECHNO GHOST',
    photoUrl: 'https://example.com/photo.jpg',
    genre: 'Techno',
    orientation: 'Bisexual',
    relationshipStatus: 'Free agent',
    favoriteTheme: 'Industrial',
  );

  setUp(() {
    mockGetCard = MockGetCard();
    mockCreateCard = MockCreateCard();
    mockRefreshQrToken = MockRefreshQrToken();
    cubit = CardCubit(
      getCard: mockGetCard,
      createCard: mockCreateCard,
      refreshQrToken: mockRefreshQrToken,
    );
  });

  tearDown(() => cubit.close());

  group('loadCard', () {
    blocTest<CardCubit, CardState>(
      'emits [CardLoading, CardLoaded] when getCard succeeds',
      build: () {
        when(mockGetCard(any)).thenAnswer((_) async => const Right(tCard));
        return cubit;
      },
      act: (c) => c.loadCard('uid-123'),
      expect: () => [CardLoading(), const CardLoaded(tCard)],
    );

    blocTest<CardCubit, CardState>(
      'emits [CardLoading, CardError] when getCard fails',
      build: () {
        when(mockGetCard(any))
            .thenAnswer((_) async => const Left(CardFailure('Not found')));
        return cubit;
      },
      act: (c) => c.loadCard('uid-123'),
      expect: () => [CardLoading(), const CardError('Not found')],
    );
  });

  group('refreshQr', () {
    blocTest<CardCubit, CardState>(
      'emits [CardQrRefreshing, CardLoaded] with new token when refresh succeeds',
      build: () {
        when(mockRefreshQrToken(any)).thenAnswer((_) async => const Right('new-token'));
        return cubit;
      },
      seed: () => const CardLoaded(tCard),
      act: (c) => c.refreshQr('uid-123'),
      expect: () => [
        const CardQrRefreshing(tCard),
        CardLoaded(tCard.copyWith(activeQrToken: 'new-token')),
      ],
    );
  });
}
