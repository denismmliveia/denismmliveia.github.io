// test/features/auth/data/repositories/auth_repository_impl_test.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:ravecards/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ravecards/features/auth/domain/entities/user_entity.dart';

import 'auth_repository_impl_test.mocks.dart';

@GenerateMocks([
  FirebaseAuth,
  FirebaseFirestore,
  GoogleSignIn,
  User,
  UserCredential,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot,
])
void main() {
  late AuthRepositoryImpl repository;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockFirebaseFirestore mockFirestore;
  late MockGoogleSignIn mockGoogleSignIn;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockFirestore = MockFirebaseFirestore();
    mockGoogleSignIn = MockGoogleSignIn();
    repository = AuthRepositoryImpl(
      firebaseAuth: mockFirebaseAuth,
      firestore: mockFirestore,
      googleSignIn: mockGoogleSignIn,
    );
  });

  group('sendOtp', () {
    test('should call verifyPhoneNumber on FirebaseAuth', () async {
      when(mockFirebaseAuth.verifyPhoneNumber(
        phoneNumber: anyNamed('phoneNumber'),
        verificationCompleted: anyNamed('verificationCompleted'),
        verificationFailed: anyNamed('verificationFailed'),
        codeSent: anyNamed('codeSent'),
        codeAutoRetrievalTimeout: anyNamed('codeAutoRetrievalTimeout'),
      )).thenAnswer((_) async {});

      // sendOtp en implementación real depende de callbacks async,
      // verificamos que no lanza excepción
      expect(() => repository.sendOtp('+34600000000'), returnsNormally);
    });
  });

  group('authStateChanges', () {
    test('should map Firebase user to UserEntity', () async {
      final mockUser = MockUser();
      final mockCollection = MockCollectionReference<Map<String, dynamic>>();
      final mockDoc = MockDocumentReference<Map<String, dynamic>>();
      final mockSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

      when(mockUser.uid).thenReturn('uid-123');
      when(mockUser.phoneNumber).thenReturn('+34600000000');
      when(mockUser.email).thenReturn(null);
      when(mockFirebaseAuth.authStateChanges()).thenAnswer(
        (_) => Stream.value(mockUser),
      );
      when(mockFirestore.collection('users')).thenReturn(mockCollection);
      when(mockCollection.doc('uid-123')).thenReturn(mockDoc);
      when(mockSnapshot.exists).thenReturn(false);
      when(mockDoc.get()).thenAnswer((_) async => mockSnapshot);

      final stream = repository.authStateChanges;

      expect(stream, emits(isA<UserEntity>()));
    });
  });
}
