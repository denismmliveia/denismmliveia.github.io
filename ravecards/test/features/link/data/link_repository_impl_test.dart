import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:ravecards/features/link/data/repositories/link_repository_impl.dart';
import 'package:ravecards/features/link/domain/entities/link_entity.dart';

import 'link_repository_impl_test.mocks.dart';

@GenerateMocks([
  FirebaseFirestore,
  CollectionReference,
  Query,
  DocumentReference,
  DocumentSnapshot,
  QuerySnapshot,
  QueryDocumentSnapshot,
])
void main() {
  late MockFirebaseFirestore mockFirestore;
  late LinkRepositoryImpl repository;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    repository = LinkRepositoryImpl(mockFirestore);
  });

  MockQueryDocumentSnapshot<Map<String, dynamic>> _buildLinkDoc({
    String id = 'link-1',
    String userA = 'uid-a',
    String userB = 'uid-b',
    String status = 'pending',
    String initiatedBy = 'uid-a',
  }) {
    final doc = MockQueryDocumentSnapshot<Map<String, dynamic>>();
    when(doc.id).thenReturn(id);
    when(doc.data()).thenReturn({
      'userA': userA,
      'userB': userB,
      'status': status,
      'initiatedBy': initiatedBy,
      'pendingExpiresAt': null,
      'linkedAt': null,
      'expiresAt': null,
      'duration': null,
      'revokedBy': null,
      'createdAt': null,
    });
    return doc;
  }

  group('watchMyLinks', () {
    test('emits combined list from userA and userB queries', () async {
      // Set up mocks for two separate query chains on the same collection
      final mockCollection = MockCollectionReference<Map<String, dynamic>>();

      // userA query chain
      final mockQueryA1 = MockQuery<Map<String, dynamic>>();
      final mockQueryA2 = MockQuery<Map<String, dynamic>>();
      // userB query chain
      final mockQueryB1 = MockQuery<Map<String, dynamic>>();
      final mockQueryB2 = MockQuery<Map<String, dynamic>>();

      final snapA = MockQuerySnapshot<Map<String, dynamic>>();
      final snapB = MockQuerySnapshot<Map<String, dynamic>>();

      final docA = _buildLinkDoc(id: 'link-1', userA: 'uid-a', userB: 'uid-x');
      final docB = _buildLinkDoc(id: 'link-2', userA: 'uid-x', userB: 'uid-a');

      when(snapA.docs).thenReturn([docA]);
      when(snapB.docs).thenReturn([docB]);

      // Both queries call collection('links') — same mock
      when(mockFirestore.collection('links'))
          .thenReturn(mockCollection as CollectionReference<Map<String, dynamic>>);

      // userA query chain: where(userA) -> where(status) -> snapshots
      when(mockCollection.where('userA', isEqualTo: 'uid-a')).thenReturn(mockQueryA1);
      when(mockQueryA1.where('status', whereIn: anyNamed('whereIn'))).thenReturn(mockQueryA2);
      when(mockQueryA2.snapshots()).thenAnswer((_) => Stream.value(snapA));

      // userB query chain: where(userB) -> where(status) -> snapshots
      when(mockCollection.where('userB', isEqualTo: 'uid-a')).thenReturn(mockQueryB1);
      when(mockQueryB1.where('status', whereIn: anyNamed('whereIn'))).thenReturn(mockQueryB2);
      when(mockQueryB2.snapshots()).thenAnswer((_) => Stream.value(snapB));

      // Collect all emitted values
      final emitted = <List<LinkEntity>>[];
      final sub = repository.watchMyLinks('uid-a').listen((result) {
        result.fold((_) {}, (links) => emitted.add(links));
      });

      // Allow streams to emit
      await Future.delayed(Duration.zero);
      sub.cancel();

      // Should have received at least one emission containing both links
      expect(emitted, isNotEmpty);
      final allLinkIds = emitted.last.map((l) => l.linkId).toList();
      expect(allLinkIds, containsAll(['link-1', 'link-2']));
    });
  });

  group('watchLink', () {
    test('emits LinkEntity for the given linkId', () async {
      final mockCollection = MockCollectionReference<Map<String, dynamic>>();
      final mockDocRef = MockDocumentReference<Map<String, dynamic>>();
      final mockDoc = MockDocumentSnapshot<Map<String, dynamic>>();

      when(mockFirestore.collection('links'))
          .thenReturn(mockCollection as CollectionReference<Map<String, dynamic>>);
      when(mockCollection.doc('link-1'))
          .thenReturn(mockDocRef as DocumentReference<Map<String, dynamic>>);
      when(mockDocRef.snapshots()).thenAnswer((_) => Stream.value(mockDoc));
      when(mockDoc.id).thenReturn('link-1');
      when(mockDoc.exists).thenReturn(true);
      when(mockDoc.data()).thenReturn({
        'userA': 'uid-a',
        'userB': 'uid-b',
        'status': 'linked',
        'initiatedBy': 'uid-a',
        'pendingExpiresAt': null,
        'linkedAt': null,
        'expiresAt': null,
        'duration': 4,
        'revokedBy': null,
        'createdAt': null,
      });

      final stream = repository.watchLink('link-1');
      final result = await stream.first;

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('should be right'),
        (link) {
          expect(link.linkId, 'link-1');
          expect(link.status, 'linked');
          expect(link.duration, 4);
        },
      );
    });

    test('emits Left when link does not exist', () async {
      final mockCollection = MockCollectionReference<Map<String, dynamic>>();
      final mockDocRef = MockDocumentReference<Map<String, dynamic>>();
      final mockDoc = MockDocumentSnapshot<Map<String, dynamic>>();

      when(mockFirestore.collection('links'))
          .thenReturn(mockCollection as CollectionReference<Map<String, dynamic>>);
      when(mockCollection.doc('missing'))
          .thenReturn(mockDocRef as DocumentReference<Map<String, dynamic>>);
      when(mockDocRef.snapshots()).thenAnswer((_) => Stream.value(mockDoc));
      when(mockDoc.exists).thenReturn(false);

      final stream = repository.watchLink('missing');
      final result = await stream.first;

      expect(result.isLeft(), isTrue);
    });
  });
}
