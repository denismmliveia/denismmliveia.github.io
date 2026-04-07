// test/features/card/data/repositories/card_repository_impl_test.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:ravecards/features/card/data/repositories/card_repository_impl.dart';

import 'card_repository_impl_test.mocks.dart';

@GenerateMocks([
  FirebaseFirestore,
  FirebaseStorage,
  FirebaseFunctions,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot,
  Reference,
  UploadTask,
  TaskSnapshot,
  HttpsCallable,
  HttpsCallableResult,
])
void main() {
  late CardRepositoryImpl repository;
  late MockFirebaseFirestore mockFirestore;
  late MockFirebaseStorage mockStorage;
  late MockFirebaseFunctions mockFunctions;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockStorage = MockFirebaseStorage();
    mockFunctions = MockFirebaseFunctions();

    repository = CardRepositoryImpl(
      firestore: mockFirestore,
      storage: mockStorage,
      functions: mockFunctions,
    );
  });

  group('getCard', () {
    test('should return CardEntity when document exists', () async {
      final mockCollection = MockCollectionReference<Map<String, dynamic>>();
      final mockDoc = MockDocumentReference<Map<String, dynamic>>();
      final mockSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

      when(mockFirestore.collection('users')).thenReturn(mockCollection);
      when(mockCollection.doc('uid-123')).thenReturn(mockDoc);
      when(mockDoc.get()).thenAnswer((_) async => mockSnapshot);
      when(mockSnapshot.exists).thenReturn(true);
      when(mockSnapshot.id).thenReturn('uid-123');
      when(mockSnapshot.data()).thenReturn({
        'displayName': 'TECHNO GHOST',
        'photoUrl': 'https://example.com/photo.jpg',
        'genre': 'Techno',
        'orientation': 'Bisexual',
        'relationshipStatus': 'Free agent',
        'favoriteTheme': 'Industrial',
      });

      final result = await repository.getCard('uid-123');

      expect(result.isRight(), true);
      result.fold(
        (l) => fail('Expected Right'),
        (card) {
          expect(card.uid, 'uid-123');
          expect(card.displayName, 'TECHNO GHOST');
        },
      );
    });

    test('should return CardFailure when document does not exist', () async {
      final mockCollection = MockCollectionReference<Map<String, dynamic>>();
      final mockDoc = MockDocumentReference<Map<String, dynamic>>();
      final mockSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

      when(mockFirestore.collection('users')).thenReturn(mockCollection);
      when(mockCollection.doc('uid-123')).thenReturn(mockDoc);
      when(mockDoc.get()).thenAnswer((_) async => mockSnapshot);
      when(mockSnapshot.exists).thenReturn(false);

      final result = await repository.getCard('uid-123');

      expect(result.isLeft(), true);
    });
  });
}
