import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:ravecards/features/link/data/models/link_model.dart';
import 'package:ravecards/features/link/domain/entities/link_entity.dart';

import 'link_model_test.mocks.dart';

@GenerateMocks([DocumentSnapshot])
void main() {
  late MockDocumentSnapshot mockDoc;

  setUp(() {
    mockDoc = MockDocumentSnapshot();
    when(mockDoc.id).thenReturn('link-abc');
    when(mockDoc.data()).thenReturn({
      'userA': 'uid-a',
      'userB': 'uid-b',
      'status': 'pending',
      'initiatedBy': 'uid-a',
      'pendingExpiresAt': Timestamp.fromDate(DateTime(2026, 4, 8, 12, 0, 0)),
      'linkedAt': null,
      'expiresAt': null,
      'duration': null,
      'revokedBy': null,
      'createdAt': Timestamp.fromDate(DateTime(2026, 4, 8, 11, 59, 0)),
    });
  });

  test('fromFirestore maps all fields correctly', () {
    final model = LinkModel.fromFirestore(mockDoc);

    expect(model.linkId, 'link-abc');
    expect(model.userA, 'uid-a');
    expect(model.userB, 'uid-b');
    expect(model.status, 'pending');
    expect(model.initiatedBy, 'uid-a');
    expect(model.pendingExpiresAt, DateTime(2026, 4, 8, 12, 0, 0));
    expect(model.linkedAt, isNull);
    expect(model.expiresAt, isNull);
    expect(model.duration, isNull);
    expect(model.revokedBy, isNull);
    expect(model.createdAt, DateTime(2026, 4, 8, 11, 59, 0));
  });

  test('fromFirestore returns a LinkEntity subtype', () {
    final model = LinkModel.fromFirestore(mockDoc);
    expect(model, isA<LinkEntity>());
  });
}
