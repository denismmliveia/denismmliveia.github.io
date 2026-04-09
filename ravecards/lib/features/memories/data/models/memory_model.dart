// lib/features/memories/data/models/memory_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/memory_entity.dart';

class MemoryModel extends MemoryEntity {
  const MemoryModel({
    required super.linkId,
    required super.otherUid,
    required super.otherUserName,
    super.otherUserPhotoUrl,
    super.linkedAt,
    required super.endedAt,
    required super.status,
  });

  factory MemoryModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    MemoryStatus parseStatus(String? s) {
      if (s == 'revoked') return MemoryStatus.revoked;
      return MemoryStatus.expired;
    }

    DateTime? tsToDate(dynamic ts) =>
        ts is Timestamp ? ts.toDate() : null;

    return MemoryModel(
      linkId: doc.id,
      otherUid: data['otherUid'] as String,
      otherUserName: data['otherUserName'] as String? ?? 'Desconocido',
      otherUserPhotoUrl: data['otherUserPhotoUrl'] as String?,
      linkedAt: tsToDate(data['linkedAt']),
      endedAt: tsToDate(data['endedAt']) ?? DateTime.now(),
      status: parseStatus(data['status'] as String?),
    );
  }
}
