import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ravecards/features/chat/data/models/message_model.dart';
import 'package:ravecards/features/chat/domain/entities/message_entity.dart';

class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  late MockDocumentSnapshot doc;

  setUp(() => doc = MockDocumentSnapshot());

  group('MessageModel.fromFirestore', () {
    test('parses text message correctly', () {
      when(() => doc.id).thenReturn('msg-1');
      when(() => doc.data()).thenReturn({
        'type': 'text',
        'senderId': 'uid-alice',
        'text': 'Hola',
        'photoRef': null,
        'viewedBy': [],
        'deletedFromStorage': false,
        'createdAt': Timestamp.fromDate(DateTime(2026, 4, 9, 22, 0)),
      });

      final model = MessageModel.fromFirestore(doc);

      expect(model.id, 'msg-1');
      expect(model.type, MessageType.text);
      expect(model.senderId, 'uid-alice');
      expect(model.text, 'Hola');
      expect(model.photoRef, isNull);
      expect(model.viewedBy, isEmpty);
      expect(model.deletedFromStorage, isFalse);
      expect(model.createdAt, DateTime(2026, 4, 9, 22, 0));
    });

    test('parses photo_once message correctly', () {
      when(() => doc.id).thenReturn('msg-2');
      when(() => doc.data()).thenReturn({
        'type': 'photo_once',
        'senderId': 'uid-bob',
        'text': null,
        'photoRef': 'chat/link-1/msg-2/uid-bob_1234.jpg',
        'viewedBy': ['uid-alice'],
        'deletedFromStorage': false,
        'createdAt': null,
      });

      final model = MessageModel.fromFirestore(doc);

      expect(model.type, MessageType.photoOnce);
      expect(model.photoRef, 'chat/link-1/msg-2/uid-bob_1234.jpg');
      expect(model.viewedBy, ['uid-alice']);
      expect(model.createdAt, isNull);
    });

    test('defaults deletedFromStorage to false when missing', () {
      when(() => doc.id).thenReturn('msg-3');
      when(() => doc.data()).thenReturn({
        'type': 'text',
        'senderId': 'uid-alice',
        'text': 'hey',
        'photoRef': null,
        'viewedBy': [],
        'createdAt': null,
        // deletedFromStorage key missing
      });

      final model = MessageModel.fromFirestore(doc);
      expect(model.deletedFromStorage, isFalse);
    });
  });
}
