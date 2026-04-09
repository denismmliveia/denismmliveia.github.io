// lib/features/moderation/data/repositories/moderation_repository_impl.dart
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/moderation_repository.dart';

@LazySingleton(as: ModerationRepository)
class ModerationRepositoryImpl implements ModerationRepository {
  final FirebaseFunctions _functions;

  ModerationRepositoryImpl({required FirebaseFunctions functions})
      : _functions = functions;

  @override
  Future<Either<ModerationFailure, void>> revokeLink(String linkId) async {
    try {
      await _functions
          .httpsCallable('revokeLink')
          .call({'linkId': linkId});
      return const Right(null);
    } catch (e) {
      return Left(ModerationFailure(e.toString()));
    }
  }

  @override
  Future<Either<ModerationFailure, void>> blockUser({
    required String targetUid,
    String? linkId,
  }) async {
    try {
      await _functions.httpsCallable('blockUser').call({
        'targetUid': targetUid,
        if (linkId != null) 'linkId': linkId,
      });
      return const Right(null);
    } catch (e) {
      return Left(ModerationFailure(e.toString()));
    }
  }

  @override
  Future<Either<ModerationFailure, void>> reportUser({
    required String targetUid,
    required String reason,
    String? linkId,
  }) async {
    try {
      await _functions.httpsCallable('reportUser').call({
        'targetUid': targetUid,
        'reason': reason,
        if (linkId != null) 'linkId': linkId,
      });
      return const Right(null);
    } catch (e) {
      return Left(ModerationFailure(e.toString()));
    }
  }
}
