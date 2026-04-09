// lib/features/moderation/domain/usecases/block_user.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/moderation_repository.dart';

@injectable
class BlockUser {
  final ModerationRepository _repo;
  BlockUser(this._repo);
  Future<Either<ModerationFailure, void>> call({
    required String targetUid,
    String? linkId,
  }) =>
      _repo.blockUser(targetUid: targetUid, linkId: linkId);
}
