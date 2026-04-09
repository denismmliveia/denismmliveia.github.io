import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.type,
    required super.senderId,
    super.text,
    super.photoRef,
    super.viewedBy,
    super.deletedFromStorage,
    super.createdAt,
  });

  factory MessageModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return MessageModel(
      id: doc.id,
      type: data['type'] == 'photo_once' ? MessageType.photoOnce : MessageType.text,
      senderId: data['senderId'] as String,
      text: data['text'] as String?,
      photoRef: data['photoRef'] as String?,
      viewedBy: List<String>.from(data['viewedBy'] ?? []),
      deletedFromStorage: data['deletedFromStorage'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
