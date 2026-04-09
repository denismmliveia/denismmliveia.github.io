import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ravecards/features/memories/data/models/memory_model.dart';
import 'package:ravecards/features/memories/domain/entities/memory_entity.dart';

class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  late MockDocumentSnapshot doc;

  setUp(() => doc = MockDocumentSnapshot());

  group('MemoryModel.fromFirestore', () {
    test('parses expired memory correctly', () {
      when(() => doc.id).thenReturn('link-1');
      when(() => doc.data()).thenReturn({
        'otherUid': 'uid-b',
        'otherUserName': 'Marco',
        'otherUserPhotoUrl': 'https://example.com/b.jpg',
        'linkedAt': Timestamp.fromDate(DateTime(2026, 4, 9, 20, 0)),
        'endedAt': Timestamp.fromDate(DateTime(2026, 4, 9, 22, 0)),
        'status': 'expired',
        'createdAt': Timestamp.fromDate(DateTime(2026, 4, 9, 22, 0)),
      });

      final model = MemoryModel.fromFirestore(doc);

      expect(model.linkId, 'link-1');
      expect(model.otherUid, 'uid-b');
      expect(model.otherUserName, 'Marco');
      expect(model.otherUserPhotoUrl, 'https://example.com/b.jpg');
      expect(model.linkedAt, DateTime(2026, 4, 9, 20, 0));
      expect(model.endedAt, DateTime(2026, 4, 9, 22, 0));
      expect(model.status, MemoryStatus.expired);
    });

    test('parses revoked memory with null photo', () {
      when(() => doc.id).thenReturn('link-2');
      when(() => doc.data()).thenReturn({
        'otherUid': 'uid-c',
        'otherUserName': 'Lena',
        'otherUserPhotoUrl': null,
        'linkedAt': null,
        'endedAt': Timestamp.fromDate(DateTime(2026, 4, 9, 23, 0)),
        'status': 'revoked',
        'createdAt': null,
      });

      final model = MemoryModel.fromFirestore(doc);

      expect(model.status, MemoryStatus.revoked);
      expect(model.otherUserPhotoUrl, isNull);
      expect(model.linkedAt, isNull);
    });

    test('defaults status to expired for unknown value', () {
      when(() => doc.id).thenReturn('link-3');
      when(() => doc.data()).thenReturn({
        'otherUid': 'uid-d',
        'otherUserName': 'X',
        'otherUserPhotoUrl': null,
        'linkedAt': null,
        'endedAt': Timestamp.fromDate(DateTime(2026, 4, 9)),
        'status': 'unknown',
        'createdAt': null,
      });

      final model = MemoryModel.fromFirestore(doc);
      expect(model.status, MemoryStatus.expired);
    });
  });
}
