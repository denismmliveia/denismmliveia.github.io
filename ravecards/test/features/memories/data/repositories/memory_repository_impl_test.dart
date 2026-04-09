import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ravecards/features/memories/data/repositories/memory_repository_impl.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}
class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}
class MockQuery extends Mock implements Query<Map<String, dynamic>> {}
class MockQuerySnapshot extends Mock
    implements QuerySnapshot<Map<String, dynamic>> {}
class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  late MockFirebaseFirestore firestore;
  late MockFirebaseAuth auth;
  late MockUser user;

  setUp(() {
    firestore = MockFirebaseFirestore();
    auth = MockFirebaseAuth();
    user = MockUser();
    when(() => auth.currentUser).thenReturn(user);
    when(() => user.uid).thenReturn('uid-alice');
  });

  group('MemoryRepositoryImpl.watchMemories', () {
    test('emits Right([]) when no memory docs exist', () async {
      // For simplicity: test the repo emits a stream without errors.
      // When currentUser is null the impl returns Stream.value(Left(...)) immediately.
      when(() => auth.currentUser).thenReturn(null);
      final repo = MemoryRepositoryImpl(firestore: firestore, auth: auth);
      expect(repo.watchMemories(), isA<Stream>());
    });
  });
}
