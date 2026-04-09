import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:ravecards/features/scan/data/repositories/scan_repository_impl.dart';
import 'package:ravecards/features/scan/domain/entities/scan_result_entity.dart';

import 'scan_repository_impl_test.mocks.dart';

@GenerateMocks([
  FirebaseFunctions,
  HttpsCallable,
  HttpsCallableResult,
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot,
])
void main() {
  late MockFirebaseFunctions mockFunctions;
  late MockFirebaseFirestore mockFirestore;
  late ScanRepositoryImpl repository;

  setUp(() {
    mockFunctions = MockFirebaseFunctions();
    mockFirestore = MockFirebaseFirestore();
    repository = ScanRepositoryImpl(mockFunctions, mockFirestore);
  });

  group('validateQrToken', () {
    test('returns uid on valid token', () async {
      final mockCallable = MockHttpsCallable();
      final mockResult = MockHttpsCallableResult();

      when(mockFunctions.httpsCallable('validateQrToken'))
          .thenReturn(mockCallable);
      when(mockCallable.call({'token': 'jwt-token-123'}))
          .thenAnswer((_) async => mockResult);
      when(mockResult.data).thenReturn({'valid': true, 'uid': 'uid-b'});

      final result = await repository.validateQrToken('jwt-token-123');

      expect(result, const Right('uid-b'));
    });

    test('returns ScanFailure when valid is false', () async {
      final mockCallable = MockHttpsCallable();
      final mockResult = MockHttpsCallableResult();

      when(mockFunctions.httpsCallable('validateQrToken'))
          .thenReturn(mockCallable);
      when(mockCallable.call({'token': 'bad-token'}))
          .thenAnswer((_) async => mockResult);
      when(mockResult.data).thenReturn({'valid': false});

      final result = await repository.validateQrToken('bad-token');

      expect(result.isLeft(), isTrue);
    });
  });

  group('initiateLink', () {
    test('returns InitiateLinkResult with isMutual false for new PENDING', () async {
      final mockCallable = MockHttpsCallable();
      final mockResult = MockHttpsCallableResult();

      when(mockFunctions.httpsCallable('initiateLink'))
          .thenReturn(mockCallable);
      when(mockCallable.call({'token': 'jwt-token-123'}))
          .thenAnswer((_) async => mockResult);
      when(mockResult.data).thenReturn({
        'status': 'pending',
        'linkId': 'link-xyz',
        'isMutual': false,
      });

      final result = await repository.initiateLink('jwt-token-123');

      expect(result, const Right(InitiateLinkResult(linkId: 'link-xyz', isMutual: false)));
    });

    test('returns InitiateLinkResult with isMutual true for mutual scan', () async {
      final mockCallable = MockHttpsCallable();
      final mockResult = MockHttpsCallableResult();

      when(mockFunctions.httpsCallable('initiateLink'))
          .thenReturn(mockCallable);
      when(mockCallable.call({'token': 'jwt-token-456'}))
          .thenAnswer((_) async => mockResult);
      when(mockResult.data).thenReturn({
        'status': 'linked',
        'linkId': 'link-xyz',
        'isMutual': true,
      });

      final result = await repository.initiateLink('jwt-token-456');

      expect(result, const Right(InitiateLinkResult(linkId: 'link-xyz', isMutual: true)));
    });
  });

  group('confirmLink', () {
    test('returns unit on success', () async {
      final mockCallable = MockHttpsCallable();
      final mockResult = MockHttpsCallableResult();

      when(mockFunctions.httpsCallable('confirmLink')).thenReturn(mockCallable);
      when(mockCallable.call({'linkId': 'link-xyz', 'duration': 4}))
          .thenAnswer((_) async => mockResult);
      when(mockResult.data).thenReturn({'success': true});

      final result = await repository.confirmLink('link-xyz', 4);

      expect(result, const Right(unit));
    });
  });
}
