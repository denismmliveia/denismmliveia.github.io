// lib/features/moderation/domain/repositories/moderation_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

abstract class ModerationRepository {
  Future<Either<ModerationFailure, void>> revokeLink(String linkId);
  Future<Either<ModerationFailure, void>> blockUser({
    required String targetUid,
    String? linkId,
  });
  Future<Either<ModerationFailure, void>> reportUser({
    required String targetUid,
    required String reason,
    String? linkId,
  });
}
