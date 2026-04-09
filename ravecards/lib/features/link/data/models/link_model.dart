// lib/features/link/data/models/link_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/link_entity.dart';

class LinkModel extends LinkEntity {
  const LinkModel({
    required super.linkId,
    required super.userA,
    required super.userB,
    required super.status,
    required super.initiatedBy,
    super.pendingExpiresAt,
    super.linkedAt,
    super.expiresAt,
    super.duration,
    super.revokedBy,
    super.createdAt,
  });

  factory LinkModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LinkModel(
      linkId: doc.id,
      userA: data['userA'] as String,
      userB: data['userB'] as String,
      status: data['status'] as String,
      initiatedBy: data['initiatedBy'] as String,
      pendingExpiresAt: (data['pendingExpiresAt'] as Timestamp?)?.toDate(),
      linkedAt: (data['linkedAt'] as Timestamp?)?.toDate(),
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate(),
      duration: data['duration'] as int?,
      revokedBy: data['revokedBy'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
