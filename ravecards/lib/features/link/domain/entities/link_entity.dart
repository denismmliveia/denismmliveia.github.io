// lib/features/link/domain/entities/link_entity.dart
import 'package:equatable/equatable.dart';

class LinkEntity extends Equatable {
  final String linkId;
  final String userA;
  final String userB;
  final String status; // 'pending' | 'linked' | 'expired' | 'revoked'
  final String initiatedBy;
  final DateTime? pendingExpiresAt;
  final DateTime? linkedAt;
  final DateTime? expiresAt;
  final int? duration; // hours: 4, 12, 24, 72
  final String? revokedBy;
  final DateTime? createdAt;

  const LinkEntity({
    required this.linkId,
    required this.userA,
    required this.userB,
    required this.status,
    required this.initiatedBy,
    this.pendingExpiresAt,
    this.linkedAt,
    this.expiresAt,
    this.duration,
    this.revokedBy,
    this.createdAt,
  });

  String otherUser(String myUid) => userA == myUid ? userB : userA;

  bool get isPending => status == 'pending';
  bool get isLinked => status == 'linked';
  bool get isExpired => status == 'expired';
  bool get isRevoked => status == 'revoked';

  /// Seconds remaining in the 60s pending window. Returns 0 if expired.
  int get pendingSecondsRemaining {
    if (pendingExpiresAt == null) return 0;
    final remaining = pendingExpiresAt!.difference(DateTime.now()).inSeconds;
    return remaining < 0 ? 0 : remaining;
  }

  /// Duration remaining for an active link. Returns Duration.zero if expired.
  Duration get linkDurationRemaining {
    if (expiresAt == null) return Duration.zero;
    final remaining = expiresAt!.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  @override
  List<Object?> get props => [
        linkId, userA, userB, status, initiatedBy,
        pendingExpiresAt, linkedAt, expiresAt, duration, revokedBy, createdAt,
      ];
}
