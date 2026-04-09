import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:ravecards/features/chat/data/models/message_model.dart';
import 'package:ravecards/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:ravecards/features/chat/domain/entities/message_entity.dart';

// Mocks
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockFirebaseFunctions extends Mock implements FirebaseFunctions {}
class MockHttpClient extends Mock implements http.Client {}
class MockUser extends Mock implements User {}
class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}
class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}
class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}
class MockQuerySnapshot extends Mock
    implements QuerySnapshot<Map<String, dynamic>> {}
class MockQuery extends Mock implements Query<Map<String, dynamic>> {}

void main() {
  late ChatRepositoryImpl repo;
  late MockFirebaseFirestore firestore;
  late MockFirebaseAuth auth;
  late MockFirebaseFunctions functions;
  late MockHttpClient httpClient;
  late MockUser user;
  late MockCollectionReference linksCollection;
  late MockDocumentReference linkDoc;
  late MockCollectionReference messagesCollection;
  late MockQuery orderedQuery;
  late MockQuery limitedQuery;

  setUp(() {
    firestore = MockFirebaseFirestore();
    auth = MockFirebaseAuth();
    functions = MockFirebaseFunctions();
    httpClient = MockHttpClient();
    user = MockUser();

    linksCollection = MockCollectionReference();
    linkDoc = MockDocumentReference();
    messagesCollection = MockCollectionReference();
    orderedQuery = MockQuery();
    limitedQuery = MockQuery();

    when(() => auth.currentUser).thenReturn(user);
    when(() => user.uid).thenReturn('uid-alice');
    when(() => firestore.collection('links')).thenReturn(linksCollection);
    when(() => linksCollection.doc(any())).thenReturn(linkDoc);
    when(() => linkDoc.collection('messages')).thenReturn(messagesCollection);
    when(() => messagesCollection.orderBy('createdAt', descending: false))
        .thenReturn(orderedQuery);
    when(() => orderedQuery.limit(100)).thenReturn(limitedQuery);

    repo = ChatRepositoryImpl(
      firestore: firestore,
      auth: auth,
      functions: functions,
      httpClient: httpClient,
    );
  });

  group('watchMessages', () {
    test('returns empty list when no messages', () async {
      final controller = StreamController<QuerySnapshot<Map<String, dynamic>>>();
      final mockSnapshot = MockQuerySnapshot();
      when(() => mockSnapshot.docs).thenReturn([]);
      when(() => limitedQuery.snapshots()).thenAnswer((_) => controller.stream);

      final stream = repo.watchMessages('link-1');
      controller.add(mockSnapshot);

      final result = await stream.first;
      expect(result.isRight(), isTrue);
      result.fold((_) {}, (list) => expect(list, isEmpty));
      await controller.close();
    });
  });

  group('sendText', () {
    test('writes correct fields to Firestore', () async {
      when(() => messagesCollection.add(any())).thenAnswer((_) async => linkDoc);

      final result = await repo.sendText('link-1', 'Hola');

      expect(result, equals(const Right(unit)));
      final captured = verify(() => messagesCollection.add(captureAny())).captured.single
          as Map<String, dynamic>;
      expect(captured['type'], 'text');
      expect(captured['senderId'], 'uid-alice');
      expect(captured['text'], 'Hola');
      expect(captured['photoRef'], isNull);
      expect(captured['viewedBy'], isEmpty);
      expect(captured['deletedFromStorage'], isFalse);
    });

    test('returns ChatFailure when Firestore throws', () async {
      when(() => messagesCollection.add(any())).thenThrow(Exception('network'));

      final result = await repo.sendText('link-1', 'Hola');

      expect(result.isLeft(), isTrue);
    });
  });

  group('getOtherUserProfile', () {
    late MockCollectionReference usersCollection;
    late MockDocumentReference userDoc;
    late MockDocumentSnapshot userSnapshot;

    setUp(() {
      usersCollection = MockCollectionReference();
      userDoc = MockDocumentReference();
      userSnapshot = MockDocumentSnapshot();

      when(() => firestore.collection('users')).thenReturn(usersCollection);
      when(() => usersCollection.doc('uid-bob')).thenReturn(userDoc);
      when(() => userDoc.get()).thenAnswer((_) async => userSnapshot);
    });

    test('returns displayName and photoUrl', () async {
      when(() => userSnapshot.data()).thenReturn({
        'displayName': 'Bob',
        'photoUrl': 'https://example.com/bob.jpg',
      });

      final result = await repo.getOtherUserProfile('uid-bob');

      expect(result.isRight(), isTrue);
      result.fold((_) {}, (map) {
        expect(map['displayName'], equals('Bob'));
        expect(map['photoUrl'], equals('https://example.com/bob.jpg'));
      });
    });

    test('returns ChatFailure on Firestore error', () async {
      when(() => userDoc.get()).thenThrow(Exception('not found'));

      final result = await repo.getOtherUserProfile('uid-bob');

      expect(result.isLeft(), isTrue);
    });
  });
}
