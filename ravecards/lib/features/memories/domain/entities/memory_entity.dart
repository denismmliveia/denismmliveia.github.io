// lib/features/memories/domain/entities/memory_entity.dart
import 'package:equatable/equatable.dart';

enum MemoryStatus { expired, revoked }

class MemoryEntity extends Equatable {
  final String linkId;
  final String otherUid;
  final String otherUserName;
  final String? otherUserPhotoUrl;
  final DateTime? linkedAt;
  final DateTime endedAt;
  final MemoryStatus status;

  const MemoryEntity({
    required this.linkId,
    required this.otherUid,
    required this.otherUserName,
    this.otherUserPhotoUrl,
    this.linkedAt,
    required this.endedAt,
    required this.status,
  });

  @override
  List<Object?> get props => [
        linkId, otherUid, otherUserName, otherUserPhotoUrl,
        linkedAt, endedAt, status,
      ];
}
