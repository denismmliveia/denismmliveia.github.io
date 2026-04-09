import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:ravecards/features/card/domain/entities/card_entity.dart';
import 'package:ravecards/features/scan/domain/entities/scan_result_entity.dart';
import 'package:ravecards/features/scan/domain/repositories/scan_repository.dart';
import 'package:ravecards/features/scan/domain/usecases/confirm_link.dart';
import 'package:ravecards/features/scan/domain/usecases/initiate_link.dart';
import 'package:ravecards/features/scan/domain/usecases/preview_card.dart';
import 'package:ravecards/features/scan/domain/usecases/validate_qr_token.dart';

import 'scan_usecases_test.mocks.dart';

@GenerateMocks([ScanRepository])
void main() {
  late MockScanRepository mockRepo;

  const tCard = CardEntity(
    uid: 'uid-b',
    displayName: 'DJ GHOST',
    photoUrl: 'https://example.com/photo.jpg',
    genre: 'Techno',
    orientation: 'Bisexual',
    relationshipStatus: 'Free',
    favoriteTheme: 'Industrial',
  );

  const tResult = InitiateLinkResult(linkId: 'link-1', isMutual: false);

  setUp(() => mockRepo = MockScanRepository());

  test('ValidateQrToken delegates to repository', () async {
    when(mockRepo.validateQrToken('token-123'))
        .thenAnswer((_) async => const Right('uid-b'));
    final result = await ValidateQrToken(mockRepo)('token-123');
    expect(result, const Right('uid-b'));
  });

  test('PreviewCard delegates to repository', () async {
    when(mockRepo.previewCard('uid-b'))
        .thenAnswer((_) async => const Right(tCard));
    final result = await PreviewCard(mockRepo)('uid-b');
    expect(result, const Right(tCard));
  });

  test('InitiateLink delegates to repository', () async {
    when(mockRepo.initiateLink('token-123'))
        .thenAnswer((_) async => const Right(tResult));
    final result = await InitiateLink(mockRepo)('token-123');
    expect(result, const Right(tResult));
  });

  test('ConfirmLink delegates to repository', () async {
    when(mockRepo.confirmLink('link-1', 4))
        .thenAnswer((_) async => const Right(unit));
    final result = await ConfirmLink(mockRepo)('link-1', 4);
    expect(result, const Right(unit));
  });
}
