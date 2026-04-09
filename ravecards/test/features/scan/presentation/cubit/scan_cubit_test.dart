import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:ravecards/core/error/failures.dart';
import 'package:ravecards/features/card/domain/entities/card_entity.dart';
import 'package:ravecards/features/link/domain/entities/link_entity.dart';
import 'package:ravecards/features/link/domain/usecases/watch_link.dart';
import 'package:ravecards/features/scan/domain/entities/scan_result_entity.dart';
import 'package:ravecards/features/scan/domain/usecases/confirm_link.dart';
import 'package:ravecards/features/scan/domain/usecases/initiate_link.dart';
import 'package:ravecards/features/scan/domain/usecases/preview_card.dart';
import 'package:ravecards/features/scan/domain/usecases/validate_qr_token.dart';
import 'package:ravecards/features/scan/presentation/cubit/scan_cubit.dart';
import 'package:ravecards/features/scan/presentation/cubit/scan_state.dart';

import 'scan_cubit_test.mocks.dart';

@GenerateMocks([ValidateQrToken, PreviewCard, InitiateLink, ConfirmLink, WatchLink])
void main() {
  late ScanCubit cubit;
  late MockValidateQrToken mockValidate;
  late MockPreviewCard mockPreview;
  late MockInitiateLink mockInitiate;
  late MockConfirmLink mockConfirm;
  late MockWatchLink mockWatch;

  const tCard = CardEntity(
    uid: 'uid-b',
    displayName: 'DJ GHOST',
    photoUrl: 'https://example.com/photo.jpg',
    genre: 'Techno',
    orientation: 'Bisexual',
    relationshipStatus: 'Free',
    favoriteTheme: 'Industrial',
  );

  const tToken = 'jwt-token-abc';
  const tLinkId = 'link-xyz';

  setUp(() {
    mockValidate = MockValidateQrToken();
    mockPreview = MockPreviewCard();
    mockInitiate = MockInitiateLink();
    mockConfirm = MockConfirmLink();
    mockWatch = MockWatchLink();
    cubit = ScanCubit(
      validateQrToken: mockValidate,
      previewCard: mockPreview,
      initiateLink: mockInitiate,
      confirmLink: mockConfirm,
      watchLink: mockWatch,
    );
  });

  tearDown(() => cubit.close());

  group('onQrScanned', () {
    blocTest<ScanCubit, ScanState>(
      'emits [Validating, Preview] on success',
      build: () {
        when(mockValidate(tToken)).thenAnswer((_) async => const Right('uid-b'));
        when(mockPreview('uid-b')).thenAnswer((_) async => const Right(tCard));
        return cubit;
      },
      act: (c) => c.onQrScanned(tToken),
      expect: () => [
        const ScanValidating(),
        const ScanPreview(otherCard: tCard, token: tToken),
      ],
    );

    blocTest<ScanCubit, ScanState>(
      'emits [Validating, ScanError] when validateQrToken fails',
      build: () {
        when(mockValidate(tToken))
            .thenAnswer((_) async => const Left(ScanFailure('Invalid token')));
        return cubit;
      },
      act: (c) => c.onQrScanned(tToken),
      expect: () => [
        const ScanValidating(),
        const ScanError('Invalid token'),
      ],
    );
  });

  group('onInitiateLink', () {
    blocTest<ScanCubit, ScanState>(
      'emits [ScanInitiating, ScanPending] for new PENDING',
      build: () {
        when(mockInitiate(tToken)).thenAnswer((_) async =>
            const Right(InitiateLinkResult(linkId: tLinkId, isMutual: false)));
        when(mockWatch(tLinkId))
            .thenAnswer((_) => const Stream.empty());
        return cubit;
      },
      seed: () => const ScanPreview(otherCard: tCard, token: tToken),
      act: (c) => c.onInitiateLink(tToken, tCard),
      expect: () => [
        const ScanInitiating(otherCard: tCard),
        ScanPending(linkId: tLinkId, otherCard: tCard, remainingSeconds: 60),
      ],
    );

    blocTest<ScanCubit, ScanState>(
      'emits [ScanInitiating, ScanLinked(isConfirmer:true)] for mutual scan',
      build: () {
        when(mockInitiate(tToken)).thenAnswer((_) async =>
            const Right(InitiateLinkResult(linkId: tLinkId, isMutual: true)));
        return cubit;
      },
      seed: () => const ScanPreview(otherCard: tCard, token: tToken),
      act: (c) => c.onInitiateLink(tToken, tCard),
      expect: () => [
        const ScanInitiating(otherCard: tCard),
        ScanLinked(linkId: tLinkId, otherCard: tCard, isConfirmer: true),
      ],
    );
  });

  group('onLinkStatusChanged', () {
    const tLinkLinked = LinkEntity(
      linkId: tLinkId,
      userA: 'uid-a',
      userB: 'uid-b',
      status: 'linked',
      initiatedBy: 'uid-a',
      createdAt: null,
    );

    blocTest<ScanCubit, ScanState>(
      'emits ScanLinked(isConfirmer:false) when stream shows linked status',
      build: () => cubit,
      seed: () => ScanPending(linkId: tLinkId, otherCard: tCard, remainingSeconds: 45),
      act: (c) => c.onLinkStatusChanged(tLinkLinked),
      expect: () => [
        ScanLinked(linkId: tLinkId, otherCard: tCard, isConfirmer: false),
      ],
    );
  });

  group('onCountdownTick', () {
    blocTest<ScanCubit, ScanState>(
      'decrements remaining seconds',
      build: () => cubit,
      seed: () => ScanPending(linkId: tLinkId, otherCard: tCard, remainingSeconds: 10),
      act: (c) => c.onCountdownTick(),
      expect: () => [
        ScanPending(linkId: tLinkId, otherCard: tCard, remainingSeconds: 9),
      ],
    );

    blocTest<ScanCubit, ScanState>(
      'emits ScanError when countdown reaches 0',
      build: () => cubit,
      seed: () => ScanPending(linkId: tLinkId, otherCard: tCard, remainingSeconds: 1),
      act: (c) => c.onCountdownTick(),
      expect: () => [isA<ScanError>()],
    );
  });

  group('onConfirmLink', () {
    blocTest<ScanCubit, ScanState>(
      'emits [ScanConfirming, ScanConfirmed] on success',
      build: () {
        when(mockConfirm(tLinkId, 4)).thenAnswer((_) async => const Right(unit));
        return cubit;
      },
      seed: () => ScanLinked(linkId: tLinkId, otherCard: tCard, isConfirmer: true),
      act: (c) => c.onConfirmLink(tLinkId, 4),
      expect: () => [
        const ScanConfirming(linkId: tLinkId),
        const ScanConfirmed(linkId: tLinkId),
      ],
    );

    blocTest<ScanCubit, ScanState>(
      'emits ScanError when confirmLink fails',
      build: () {
        when(mockConfirm(tLinkId, 4))
            .thenAnswer((_) async => const Left(ScanFailure('Expired')));
        return cubit;
      },
      seed: () => ScanLinked(linkId: tLinkId, otherCard: tCard, isConfirmer: true),
      act: (c) => c.onConfirmLink(tLinkId, 4),
      expect: () => [
        const ScanConfirming(linkId: tLinkId),
        const ScanError('Expired'),
      ],
    );
  });
}
